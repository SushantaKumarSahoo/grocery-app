import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/screen_backdrop.dart';
import '../../data/models/order.dart';
import '../../providers/order_provider.dart';

class QuotationScreen extends StatefulWidget {
  final String orderId;
  const QuotationScreen({super.key, required this.orderId});

  @override
  State<QuotationScreen> createState() => _QuotationScreenState();
}

class _QuotationScreenState extends State<QuotationScreen> {
  late Future<_QuotationData> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_QuotationData> _load() async {
    final orderProvider = context.read<OrderProvider>();
    final order = await orderProvider.fetchOrderById(widget.orderId);
    final quotation = await orderProvider.fetchQuotation(widget.orderId);
    return _QuotationData(order, quotation);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _requestModification(Quotation quotation) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request a change'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'What would you like changed?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    if (note == null || note.isEmpty || !mounted) return;
    final orderProvider = context.read<OrderProvider>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await orderProvider.requestModification(quotation.id, note);
      if (!mounted) return;
      _reload();
      messenger.showSnackBar(
        const SnackBar(content: Text('Modification request sent to shop owner')),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not send your request. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: const Text('Quotation')),
      body: ScreenBackdrop(
        child: FutureBuilder<_QuotationData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            final data = snapshot.data;
            final order = data?.order;
            final q = data?.quotation;

            if (order == null || q == null) {
              return EmptyState(
                icon: Icons.request_quote_outlined,
                title: 'No quotation yet',
                message:
                    'The shop owner has not sent a quotation for this order yet.',
                action: OutlinedButton(
                  onPressed: _reload,
                  child: const Text('Refresh'),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
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
                        'Requested Products',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...q.lines.map(
                        (l) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  l.productName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.5,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${l.quantity.toStringAsFixed(0)} ${l.unit}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '₹${l.pricePerUnit.toStringAsFixed(0)}/${l.unit}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '₹${l.total.toStringAsFixed(0)}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _priceRow(
                            'Subtotal',
                            q.subtotal,
                            color: Colors.white,
                          ),
                          _priceRow(
                            'Transport Charges',
                            q.transportCharge,
                            color: Colors.white70,
                          ),
                          _priceRow(
                            'GST (${q.gstPercent.toStringAsFixed(0)}%)',
                            q.gstAmount,
                            color: Colors.white70,
                          ),
                          _priceRow(
                            'Discount',
                            -q.discountAmount,
                            color: const Color(0xFFFDE68A),
                          ),
                          const Divider(color: Colors.white30, height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Grand Total',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: q.grandTotal),
                                duration: 900.ms,
                                curve: Curves.easeOutCubic,
                                builder: (context, value, _) => Text(
                                  '₹${value.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.05, end: 0),
                if (q.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.isDark
                          ? AppColors.accent.withValues(alpha: 0.18)
                          : AppColors.accentLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      q.notes,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (q.status == 'sent') ...[
                  PrimaryButton(
                    label: 'Accept Quotation',
                    icon: Icons.check_circle_outline_rounded,
                    loading: _busy,
                    onPressed: () async {
                      final router = GoRouter.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      setState(() => _busy = true);
                      try {
                        await context.read<OrderProvider>().acceptQuotation(
                          q,
                          order.id,
                        );
                        if (!mounted) return;
                        _reload();
                        // Next stop is choosing how to pay the advance —
                        // no snackbar needed, the payment screen makes the
                        // acceptance obvious on its own.
                        router.push('/payment/${order.id}');
                      } catch (_) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Could not accept quotation. Please try again.'),
                          ),
                        );
                      } finally {
                        if (mounted) setState(() => _busy = false);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            setState(() => _busy = true);
                            try {
                              await context.read<OrderProvider>().rejectQuotation(
                                q,
                                order.id,
                              );
                              if (!mounted) return;
                              _reload();
                            } catch (_) {
                              if (!mounted) return;
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Could not reject quotation. Please try again.'),
                                ),
                              );
                            } finally {
                              if (mounted) setState(() => _busy = false);
                            }
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.error,
                          ),
                          label: const Text(
                            'Reject',
                            style: TextStyle(color: AppColors.error),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _requestModification(q),
                          icon: const Icon(Icons.edit_note_rounded, size: 18),
                          label: const Text('Request Change'),
                        ),
                      ),
                    ],
                  ),
                ] else if (q.status == 'changes_requested')
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.isDark
                          ? AppColors.accent.withValues(alpha: 0.18)
                          : AppColors.accentLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.schedule_rounded, color: AppColors.accent),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "You've requested changes. The shop will send an updated quotation shortly.",
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.isDark
                          ? AppColors.primary.withValues(alpha: 0.18)
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This quotation is ${q.status}.',
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _priceRow(String label, double value, {required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 13)),
          Text(
            '${value < 0 ? '-' : ''}₹${value.abs().toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotationData {
  final BulkOrder? order;
  final Quotation? quotation;
  const _QuotationData(this.order, this.quotation);
}
