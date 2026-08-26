import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/screen_backdrop.dart';
import '../../data/models/order.dart';
import '../../data/repositories/support_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';

const _flow = [
  OrderStatus.pending,
  OrderStatus.quotationSent,
  OrderStatus.accepted,
  OrderStatus.preparing,
  OrderStatus.ready,
  OrderStatus.delivered,
];

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<BulkOrder?> _future;
  final _supportRepo = SupportRepository();
  bool _openingChat = false;

  @override
  void initState() {
    super.initState();
    _future = context.read<OrderProvider>().fetchOrderById(widget.orderId);
  }

  void _reload() {
    setState(() {
      _future = context.read<OrderProvider>().fetchOrderById(widget.orderId);
    });
  }

  Future<void> _chatWithShop(BulkOrder order) async {
    final profile = context.read<AuthProvider>().profile;
    if (profile == null || _openingChat) return;
    setState(() => _openingChat = true);
    try {
      final ticket = await _supportRepo.findOrCreateOrderTicket(
        orderId: order.id,
        shopId: order.shopId,
        orderNumber: order.orderNumber.isNotEmpty ? order.orderNumber : order.id,
        customerName: profile.fullName,
        customerEmail: profile.email,
        customerPhone: profile.phone,
      );
      if (!mounted) return;
      context.push('/support/${ticket.id}', extra: ticket.subject);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start chat: $e')),
      );
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: const Text('Order Details')),
      body: ScreenBackdrop(
        child: FutureBuilder<BulkOrder?>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            final order = snapshot.data;
            if (order == null) {
              return const Center(child: Text('Order not found'));
            }

            final cancelled = order.status == OrderStatus.cancelled;
            final currentIndex = cancelled ? -1 : _flow.indexOf(order.status);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderNumber.isNotEmpty
                                ? order.orderNumber
                                : order.id,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.occasion.isEmpty
                                ? 'Bulk order'
                                : order.occasion,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: cancelled
                      ? const Row(
                          children: [
                            Icon(Icons.cancel_rounded, color: AppColors.error),
                            SizedBox(width: 10),
                            Text(
                              'This order has been cancelled',
                              style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: List.generate(_flow.length, (i) {
                            final done = i <= currentIndex;
                            final isLast = i == _flow.length - 1;
                            return IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          AnimatedContainer(
                                            duration: 400.ms,
                                            curve: Curves.easeOutBack,
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              gradient: done
                                                  ? AppColors.primaryGradient
                                                  : null,
                                              color: done
                                                  ? null
                                                  : colors.border,
                                              shape: BoxShape.circle,
                                            ),
                                            child: done
                                                ? const Icon(
                                                    Icons.check_rounded,
                                                    size: 14,
                                                    color: Colors.white,
                                                  )
                                                : null,
                                          ),
                                          if (!isLast)
                                            Expanded(
                                              child: Container(
                                                width: 2,
                                                color: i < currentIndex
                                                    ? AppColors.primary
                                                    : colors.border,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 24,
                                          ),
                                          child: Text(
                                            _flow[i].label,
                                            style: TextStyle(
                                              fontWeight: done
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: done
                                                  ? colors.textPrimary
                                                  : colors.textMuted,
                                              fontSize: 13.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: (80 * i).ms, duration: 300.ms)
                                .slideX(
                                  begin: 0.06,
                                  end: 0,
                                  delay: (80 * i).ms,
                                  duration: 300.ms,
                                );
                          }),
                        ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Items',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...order.items.map(
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  i.productName,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '${i.quantity.toStringAsFixed(0)} ${i.unit}',
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (order.items.isEmpty)
                        Text(
                          'No line items recorded for this order yet.',
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 12.5,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (order.status == OrderStatus.quotationSent ||
                    order.status == OrderStatus.accepted) ...[
                  PrimaryButton(
                    label: 'View Quotation',
                    icon: Icons.request_quote_outlined,
                    onPressed: () => context
                        .push('/quotation/${order.id}')
                        .then((_) => _reload()),
                  ),
                  const SizedBox(height: 12),
                ],
                if (order.status == OrderStatus.accepted && order.paymentMethod == null) ...[
                  _PaymentPromptBanner(
                    message: 'Choose how you\'d like to pay the advance to move this order forward.',
                    buttonLabel: 'Choose Payment Method',
                    onTap: () => context
                        .push('/payment/${order.id}')
                        .then((_) => _reload()),
                  ),
                  const SizedBox(height: 12),
                ],
                if (order.status == OrderStatus.ready && order.paymentStatus != 'paid') ...[
                  _PaymentPromptBanner(
                    message: 'Complete the final payment to receive your delivery.',
                    buttonLabel: 'Complete Final Payment',
                    onTap: () => context
                        .push('/payment/${order.id}')
                        .then((_) => _reload()),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: _openingChat ? null : () => _chatWithShop(order),
                  icon: _openingChat
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(Icons.storefront_outlined, size: 18),
                  label: const Text('Chat with Shop about this Order'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PaymentPromptBanner extends StatelessWidget {
  final String message;
  final String buttonLabel;
  final VoidCallback onTap;

  const _PaymentPromptBanner({
    required this.message,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: colors.isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_rounded, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12.5, color: colors.textSecondary, height: 1.4),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onTap,
            child: Text(buttonLabel, style: const TextStyle(fontSize: 12.5)),
          ),
        ],
      ),
    );
  }
}
