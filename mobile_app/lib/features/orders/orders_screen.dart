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

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = const <String, OrderStatus?>{
    'All': null,
    'Pending': OrderStatus.pending,
    'Quotation Sent': OrderStatus.quotationSent,
    'Accepted': OrderStatus.accepted,
    'Preparing': OrderStatus.preparing,
    'Ready': OrderStatus.ready,
    'Delivered': OrderStatus.delivered,
    'Cancelled': OrderStatus.cancelled,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadMyOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BulkOrder> _filter(List<BulkOrder> orders, OrderStatus? status) {
    if (status == null) return orders;
    return orders.where((o) => o.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final orders = orderProvider.orders;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12.5,
          ),
          tabs: _tabs.keys.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: ScreenBackdrop(
        child: orderProvider.loading && orders.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : RefreshIndicator(
                onRefresh: () => context.read<OrderProvider>().loadMyOrders(),
                color: AppColors.primary,
                child: TabBarView(
                  controller: _tabController,
                  children: _tabs.values.map((status) {
                    final list = _filter(orders, status);
                    if (list.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 120),
                          EmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: 'No orders here',
                            message: 'Orders in this status will show up here.',
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final o = list[i];
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
                      },
                    );
                  }).toList(),
                ),
              ),
      ),
    );
  }
}
