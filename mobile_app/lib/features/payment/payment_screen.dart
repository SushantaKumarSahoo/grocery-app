import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/category.dart' show isEventOccasionName;
import '../../data/models/order.dart';
import '../../data/repositories/payment_repository.dart';
import '../../providers/order_provider.dart';
import '../../providers/payment_provider.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  const PaymentScreen({super.key, required this.orderId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Future<BulkOrder?> _orderFuture;

  @override
  void initState() {
    super.initState();
    _orderFuture = context.read<OrderProvider>().fetchOrderById(widget.orderId);
  }

  PaymentStage? _stageFor(BulkOrder order) {
    if (order.status == OrderStatus.accepted) return PaymentStage.advance;
    if (order.status == OrderStatus.ready) return PaymentStage.final_;
    return null;
  }

  void _continue() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: const Text('Payment')),
      body: SafeArea(
        child: FutureBuilder<BulkOrder?>(
          future: _orderFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            final order = snapshot.data;
            if (order == null) {
              return const EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Order not found',
                message: 'Could not load this order.',
              );
            }
            final stage = _stageFor(order);
            if (stage == null) {
              return EmptyState(
                icon: Icons.check_circle_outline_rounded,
                title: 'Nothing to pay right now',
                message: 'There\'s no payment step pending for this order at the moment.',
                action: PrimaryButton(label: 'Continue', onPressed: _continue),
              );
            }
            return ChangeNotifierProvider<PaymentProvider>(
              create: (_) => PaymentProvider()..loadSummary(order.id),
              child: _PaymentBody(order: order, stage: stage, onDone: _continue),
            );
          },
        ),
      ),
    );
  }
}

class _PaymentBody extends StatefulWidget {
  final BulkOrder order;
  final PaymentStage stage;
  final VoidCallback onDone;

  const _PaymentBody({required this.order, required this.stage, required this.onDone});

  @override
  State<_PaymentBody> createState() => _PaymentBodyState();
}

class _PaymentBodyState extends State<_PaymentBody> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (!mounted) return;
    context.read<PaymentProvider>().confirmAfterGateway(widget.order.id, widget.stage);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    context.read<PaymentProvider>().gatewayDismissedWithError(
          'Error ${response.code}: ${response.message ?? "The payment failed."}',
        );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    context.read<PaymentProvider>().gatewayDismissedWithError(
          'External wallet ${response.walletName} is not currently supported.',
        );
  }

  Future<void> _payOnline() async {
    final payment = context.read<PaymentProvider>();
    final result = await payment.startOnlinePayment(widget.order.id, widget.stage);
    if (result == null || !result.sessionRequired) return; // error, or already fully settled
    if (!mounted) return;
    
    var options = {
      'key': result.razorpayKeyId,
      'amount': (result.amount * 100).toInt(),
      'name': 'BulkMart',
      'description': widget.stage == PaymentStage.advance ? 'Advance Payment' : 'Final Payment',
      'order_id': result.razorpayOrderId,
      'prefill': {
        'contact': result.customerPhone ?? '',
        'email': result.customerEmail ?? ''
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      if (mounted) {
        context.read<PaymentProvider>().gatewayDismissedWithError('Could not open payment gateway.');
      }
    }
  }

  Future<void> _payOffline(String method) {
    return context.read<PaymentProvider>().chooseOfflineMethod(widget.order.id, widget.stage, method);
  }

  List<String> get _allowedMethods => isEventOccasionName(widget.order.occasion)
      ? const ['advance_online', 'cod_cash']
      : const ['advance_online', 'cod_cheque', 'cod_cash'];

  @override
  Widget build(BuildContext context) {
    final payment = context.watch<PaymentProvider>();
    final amount = widget.stage == PaymentStage.advance
        ? (payment.summary?.advanceAmount ?? widget.order.advanceAmount)
        : (payment.summary?.remainingAmount ?? 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          _StatusPanel(status: payment.status, amount: amount, stage: widget.stage, errorMessage: payment.errorMessage),
          const Spacer(),
          _Actions(
            status: payment.status,
            methods: _allowedMethods,
            onPayOnline: _payOnline,
            onPayOffline: _payOffline,
            onRetry: () => context.read<PaymentProvider>().reset(),
            onDone: widget.onDone,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  final PaymentFlowStatus status;
  final double amount;
  final PaymentStage stage;
  final String? errorMessage;

  const _StatusPanel({
    required this.status,
    required this.amount,
    required this.stage,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    late final IconData icon;
    late final Color iconColor;
    late final String title;
    late final String message;
    var showSpinner = false;

    switch (status) {
      case PaymentFlowStatus.idle:
        icon = Icons.receipt_long_rounded;
        iconColor = AppColors.primary;
        title = stage == PaymentStage.advance ? 'Pay Advance' : 'Complete Final Payment';
        message = stage == PaymentStage.advance
            ? 'Confirm this order by paying the advance now, or choose to pay on delivery.'
            : 'Settle the remaining balance to complete this order.';
        break;
      case PaymentFlowStatus.startingOnline:
      case PaymentFlowStatus.awaitingGateway:
        showSpinner = true;
        icon = Icons.payment_rounded;
        iconColor = AppColors.primary;
        title = 'Starting payment...';
        message = 'Please wait while we set up your secure checkout.';
        break;
      case PaymentFlowStatus.confirming:
        showSpinner = true;
        icon = Icons.hourglass_top_rounded;
        iconColor = AppColors.primary;
        title = 'Confirming your payment...';
        message = 'This usually takes just a few seconds.';
        break;
      case PaymentFlowStatus.submittingOffline:
        showSpinner = true;
        icon = Icons.hourglass_top_rounded;
        iconColor = AppColors.primary;
        title = 'Confirming...';
        message = 'Saving your payment choice.';
        break;
      case PaymentFlowStatus.succeeded:
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.success;
        title = 'Payment successful!';
        message = stage == PaymentStage.advance
            ? 'Your order is confirmed and moving into preparation.'
            : 'Your order is now complete.';
        break;
      case PaymentFlowStatus.offlineConfirmed:
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.success;
        title = 'Choice saved!';
        message = stage == PaymentStage.advance
            ? 'Your order is confirmed and moving into preparation. Have the amount ready at delivery.'
            : 'Your order is now complete. Have the amount ready at delivery.';
        break;
      case PaymentFlowStatus.failed:
        icon = Icons.error_outline_rounded;
        iconColor = AppColors.error;
        title = 'Something went wrong';
        message = errorMessage ?? 'Please try again.';
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: colors.isDark ? 0.18 : 0.12),
            shape: BoxShape.circle,
          ),
          child: showSpinner
              ? const Center(
                  child: SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
                  ),
                )
              : Icon(icon, size: 46, color: iconColor),
        ),
        const SizedBox(height: 20),
        if (status == PaymentFlowStatus.idle)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '₹${amount.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppFonts.display(fontSize: 20, fontWeight: FontWeight.w700, color: colors.textPrimary),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.5, color: colors.textSecondary, height: 1.5),
        ),
      ],
    );
  }
}

const _methodLabels = {
  'advance_online': 'Pay Online (UPI / Card)',
  'cod_cash': 'Cash on Delivery',
  'cod_cheque': 'Cheque on Delivery',
};

const _methodIcons = {
  'advance_online': Icons.bolt_rounded,
  'cod_cash': Icons.payments_rounded,
  'cod_cheque': Icons.receipt_rounded,
};

class _Actions extends StatelessWidget {
  final PaymentFlowStatus status;
  final List<String> methods;
  final VoidCallback onPayOnline;
  final ValueChanged<String> onPayOffline;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  const _Actions({
    required this.status,
    required this.methods,
    required this.onPayOnline,
    required this.onPayOffline,
    required this.onRetry,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case PaymentFlowStatus.idle:
        return Column(
          children: methods.map((method) {
            final isOnline = method == 'advance_online';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: isOnline
                  ? PrimaryButton(
                      label: _methodLabels[method]!,
                      icon: _methodIcons[method],
                      onPressed: onPayOnline,
                    )
                  : OutlinedButton.icon(
                      onPressed: () => onPayOffline(method),
                      icon: Icon(_methodIcons[method]),
                      label: Text(_methodLabels[method]!),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
            );
          }).toList(),
        );
      case PaymentFlowStatus.startingOnline:
      case PaymentFlowStatus.awaitingGateway:
      case PaymentFlowStatus.confirming:
      case PaymentFlowStatus.submittingOffline:
        return const SizedBox(height: 54);
      case PaymentFlowStatus.succeeded:
      case PaymentFlowStatus.offlineConfirmed:
        return PrimaryButton(label: 'Done', icon: Icons.arrow_forward_rounded, onPressed: onDone);
      case PaymentFlowStatus.failed:
        return Column(
          children: [
            PrimaryButton(label: 'Try Again', icon: Icons.refresh_rounded, onPressed: onRetry),
            const SizedBox(height: 8),
            TextButton(onPressed: onDone, child: const Text('I\'ll do this later')),
          ],
        );
    }
  }
}
