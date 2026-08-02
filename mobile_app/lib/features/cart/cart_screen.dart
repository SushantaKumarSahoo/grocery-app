import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/qty_stepper.dart';
import '../../core/widgets/screen_backdrop.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  final bool embedded;
  const CartScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final colors = context.colors;

    final body = cart.isEmpty
        ? EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Your bulk order is empty',
            message:
                'Browse our categories and add products to build your bulk order.',
            action: PrimaryButton(
              label: 'Browse Products',
              height: 46,
              onPressed: () {
                if (!embedded) context.pop();
              },
            ),
          )
        : ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
            children: [
              ...cart.items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Dismissible(
                      key: ValueKey(item.product.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => context
                          .read<CartProvider>()
                          .removeItem(item.product.id),
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: item.product.imageUrl.isEmpty
                                  ? Container(
                                      width: 64,
                                      height: 64,
                                      color: AppColors.primaryLight,
                                      child: const Icon(
                                        Icons.inventory_2_rounded,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    )
                                  : Image.network(
                                      item.product.imageUrl,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Container(
                                        width: 64,
                                        height: 64,
                                        color: AppColors.primaryLight,
                                        child: const Icon(
                                          Icons.image_not_supported_rounded,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.product.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: colors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => context
                                            .read<CartProvider>()
                                            .removeItem(item.product.id),
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                          color: colors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  if (item.packaging != null &&
                                      item.packaging!.isNotEmpty)
                                    Text(
                                      item.packaging!,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: colors.textMuted,
                                      ),
                                    ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      QtyStepper(
                                        value: item.quantity,
                                        min: item.product.minOrderQty,
                                        step: 5,
                                        onChanged: (v) => context
                                            .read<CartProvider>()
                                            .updateQuantity(item.product.id, v),
                                      ),
                                      Text(
                                        '₹${item.subtotal.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryDark,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: (40 * i).ms, duration: 280.ms)
                    .slideX(
                      begin: 0.08,
                      end: 0,
                      delay: (40 * i).ms,
                      duration: 280.ms,
                    );
              }),
              OutlinedButton.icon(
                onPressed: () {
                  if (!embedded) context.pop();
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add More Products'),
              ),
            ],
          );

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: const Text('Bulk Order Cart')),
      body: ScreenBackdrop(child: body),
      bottomNavigationBar: cart.isEmpty
          ? null
          : Container(
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
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subtotal',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colors.textMuted,
                            ),
                          ),
                          Text(
                            '₹${cart.subtotal.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: PrimaryButton(
                        label: 'Continue',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => context.push('/event-details'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
