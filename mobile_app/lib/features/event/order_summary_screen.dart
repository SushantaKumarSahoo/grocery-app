import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/screen_backdrop.dart';
import '../../data/models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/order_provider.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  bool _submitting = false;

  Future<void> _submit() async {
    final profile = context.read<AuthProvider>().profile;
    if (profile == null) return;
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) return;

    if (!context.read<LocationProvider>().canOrder) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: const Text(
            'We don\'t deliver to your area yet. Check delivery availability to place this order.',
          ),
          action: SnackBarAction(
            label: 'Check',
            onPressed: () => context.push('/location-check'),
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final orderProvider = context.read<OrderProvider>();
    List<BulkOrder> createdOrders;
    try {
      createdOrders = await orderProvider.submitOrder(
        items: cart.items,
        eventDetails: cart.eventDetails,
        profile: profile,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not submit your order: $e')),
      );
      return;
    }
    if (!mounted) return;
    cart.clear();
    setState(() => _submitting = false);
    final order = createdOrders.first;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Request Submitted!',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Your bulk order request ${order.orderNumber} has been sent. You will receive a quotation shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'Track Order',
                onPressed: () {
                  context.pop();
                  context.go('/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final ed = cart.eventDetails;
    final colors = context.colors;
    final canOrder = context.watch<LocationProvider>().canOrder;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: const Text('Order Summary')),
      body: ScreenBackdrop(
        themed: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            if (!canOrder)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: colors.isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off_rounded, color: AppColors.warning, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'We don\'t deliver to your area yet. You can review this order, but placing it is blocked until your location is serviceable.',
                        style: TextStyle(fontSize: 12, color: colors.textSecondary, height: 1.4),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/location-check'),
                      child: const Text('Check', style: TextStyle(fontSize: 12.5)),
                    ),
                  ],
                ),
              ),
            _sectionCard(
              title: 'Event Details',
              child: Column(
                children: [
                  if (ed.occasion.isNotEmpty) _row('Occasion', ed.occasion),
                  _row(
                    'Event Date',
                    ed.eventDate == null
                        ? '-'
                        : '${ed.eventDate!.day}/${ed.eventDate!.month}/${ed.eventDate!.year}',
                  ),
                  _row('Delivery Time', ed.preferredDeliveryTime),
                  _row('Address', ed.deliveryAddress),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Requested Products (${cart.items.length})',
              child: Column(
                children: cart.items
                    .map(
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    i.product.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${i.quantity.toStringAsFixed(0)} ${i.product.unit} · ${i.packaging ?? ""}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: colors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${i.subtotal.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Estimated Total',
              child: _row(
                'Subtotal (before quotation)',
                '₹${cart.subtotal.toStringAsFixed(0)}',
                bold: true,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Final pricing, transport charges, GST and discounts will be confirmed in your quotation.',
              style: TextStyle(fontSize: 12, color: colors.textMuted),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: BoxDecoration(
          color: colors.card,
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: PrimaryButton(
            label: 'Submit Order Request',
            icon: Icons.send_rounded,
            loading: _submitting,
            onPressed: _submit,
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
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
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                fontSize: bold ? 16 : 13,
                color: bold ? AppColors.primaryDark : colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
