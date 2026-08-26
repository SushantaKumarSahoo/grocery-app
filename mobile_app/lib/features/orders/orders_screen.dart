import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/screen_backdrop.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/tappable.dart';
import '../../data/models/order.dart';
import '../../providers/order_provider.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadMyOrders();
    });
  }

  Map<String, List<BulkOrder>> _groupByMonth(List<BulkOrder> orders) {
    final sorted = [...orders]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final grouped = <String, List<BulkOrder>>{};
    for (final o in sorted) {
      final key = '${_monthNames[o.createdAt.month - 1]} ${o.createdAt.year}';
      grouped.putIfAbsent(key, () => []).add(o);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final orders = orderProvider.orders;
    final colors = context.colors;
    final grouped = _groupByMonth(orders);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: const Text('My Orders')),
      body: ScreenBackdrop(
        child: orderProvider.loading && orders.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : RefreshIndicator(
                onRefresh: () => context.read<OrderProvider>().loadMyOrders(),
                color: AppColors.primary,
                child: orders.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          EmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: 'No orders yet',
                            message: 'Your bulk orders will show up here.',
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        itemCount: grouped.length,
                        itemBuilder: (context, sectionIndex) {
                          final month = grouped.keys.elementAt(sectionIndex);
                          final list = grouped[month]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  4,
                                  sectionIndex == 0 ? 0 : 20,
                                  4,
                                  10,
                                ),
                                child: Text(
                                  month,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              ...list.asMap().entries.map((entry) {
                                final i = entry.key;
                                final o = entry.value;
                                return Tappable(
                                      onTap: () => context.push('/order/${o.id}'),
                                      pressedScale: 0.98,
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 14),
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
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  o.orderNumber.isNotEmpty
                                                      ? o.orderNumber
                                                      : o.id.substring(0, 8),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 15,
                                                    color: colors.textPrimary,
                                                  ),
                                                ),
                                                StatusBadge(status: o.status),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${o.occasion.isEmpty ? "Bulk order" : o.occasion} · ${o.items.length} items',
                                              style: TextStyle(
                                                color: colors.textSecondary,
                                                fontSize: 12.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Placed on ${o.createdAt.day}/${o.createdAt.month}/${o.createdAt.year}',
                                              style: TextStyle(
                                                color: colors.textMuted,
                                                fontSize: 11.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: (40 * i).ms, duration: 280.ms)
                                    .slideY(
                                      begin: 0.06,
                                      end: 0,
                                      delay: (40 * i).ms,
                                      duration: 280.ms,
                                    );
                              }),
                            ],
                          );
                        },
                      ),
              ),
      ),
    );
  }
}
