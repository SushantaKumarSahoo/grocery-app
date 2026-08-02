import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/animated_blobs.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/screen_backdrop.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/tappable.dart';
import '../../data/models/category.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/order_provider.dart';
import 'widgets/occasion_chip.dart';
import 'widgets/category_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedOccasionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadHome();
      context.read<OrderProvider>().loadMyOrders();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<CatalogProvider>().loadHome(),
      context.read<OrderProvider>().loadMyOrders(),
    ]);
  }

  void _pickOccasion(Occasion o) {
    setState(() => _selectedOccasionId = o.id);
    context.read<CartProvider>().eventDetails.occasion = o.name;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ordering for ${o.name} — start adding products'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.push('/browse');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final profile = context.watch<AuthProvider>().profile;
    final firstName = (profile?.fullName.isNotEmpty ?? false)
        ? profile!.fullName.split(' ').first
        : 'there';
    final catalog = context.watch<CatalogProvider>();
    final recentOrders = context.watch<OrderProvider>().orders.take(2).toList();

    return Scaffold(
      backgroundColor: colors.bg,
      body: ScreenBackdrop(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good day 👋',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Hello, $firstName',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tappable(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colors.card,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadow,
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.notifications_none_rounded,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 350.ms),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Tappable(
                      onTap: () {},
                      pressedScale: 0.98,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: colors.textMuted),
                            const SizedBox(width: 10),
                            Text(
                              'Search rice, oil, spices...',
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 80.ms, duration: 350.ms),
                ),
                SliverToBoxAdapter(
                  child:
                      Padding(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                height: 152,
                                padding: const EdgeInsets.all(22),
                                decoration: const BoxDecoration(
                                  gradient: AppColors.heroGradient,
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: AnimatedBlobs(
                                        colors: const [
                                          Colors.white,
                                          Color(0xFFFDE68A),
                                          Colors.white,
                                        ],
                                        opacity: 0.16,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.18),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        100,
                                                      ),
                                                ),
                                                child: const Text(
                                                  'BULK ORDERING',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                'Get a custom quotation\nfor your next event',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w800,
                                                  height: 1.25,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                              Icons.local_florist_rounded,
                                              color: Colors.white24,
                                              size: 70,
                                            )
                                            .animate(
                                              onPlay: (c) =>
                                                  c.repeat(reverse: true),
                                            )
                                            .moveY(
                                              begin: -4,
                                              end: 4,
                                              duration: 2200.ms,
                                              curve: Curves.easeInOut,
                                            )
                                            .then()
                                            .rotate(
                                              begin: -0.02,
                                              end: 0.02,
                                              duration: 2200.ms,
                                            ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 140.ms, duration: 400.ms)
                          .slideY(
                            begin: 0.06,
                            end: 0,
                            delay: 140.ms,
                            duration: 400.ms,
                          ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: const SectionHeader(title: 'Shop by Occasion'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 110,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      scrollDirection: Axis.horizontal,
                      itemCount: occasions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, i) {
                        final o = occasions[i];
                        return OccasionCard(
                              occasion: o,
                              index: i,
                              selected: _selectedOccasionId == o.id,
                              onTap: () => _pickOccasion(o),
                            )
                            .animate()
                            .fadeIn(delay: (60 * i).ms, duration: 320.ms)
                            .slideX(
                              begin: 0.15,
                              end: 0,
                              delay: (60 * i).ms,
                              duration: 320.ms,
                            );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                    child: const SectionHeader(title: 'Categories'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: staticCategories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.82,
                          ),
                      itemBuilder: (context, i) {
                        final c = staticCategories[i];
                        return CategoryTile(
                              category: c,
                              onTap: () => context.push(
                                '/category/${Uri.encodeComponent(c.name)}',
                              ),
                            )
                            .animate()
                            .fadeIn(delay: (30 * i).ms, duration: 280.ms)
                            .scale(
                              begin: const Offset(0.85, 0.85),
                              end: const Offset(1, 1),
                              delay: (30 * i).ms,
                              duration: 280.ms,
                              curve: Curves.easeOutBack,
                            );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: SectionHeader(
                      title: 'Popular Bulk Products',
                      actionLabel: 'See all',
                      onAction: () {},
                    ),
                  ),
                ),
                if (catalog.loading && catalog.featuredProducts.isEmpty)
                  const SliverToBoxAdapter(child: _ProductRowSkeleton())
                else if (catalog.featuredProducts.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: Text(
                        'No products available yet. Check back soon.',
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 232,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                        scrollDirection: Axis.horizontal,
                        itemCount: catalog.featuredProducts.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, i) {
                          final p = catalog.featuredProducts[i];
                          return SizedBox(
                                width: 160,
                                child: ProductCard(
                                  product: p,
                                  onTap: () => context.push(
                                    '/product/${p.id}',
                                    extra: p,
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(delay: (50 * i).ms, duration: 300.ms)
                              .slideX(
                                begin: 0.12,
                                end: 0,
                                delay: (50 * i).ms,
                                duration: 300.ms,
                              );
                        },
                      ),
                    ),
                  ),
                if (recentOrders.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: SectionHeader(
                        title: 'Recent Orders',
                        actionLabel: 'View all',
                        onAction: () {},
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: Column(
                        children: recentOrders
                            .map(
                              (o) => Tappable(
                                onTap: () => context.push('/order/${o.id}'),
                                pressedScale: 0.98,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: colors.card,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colors.shadow,
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: colors.isDark
                                                ? AppColors.secondary
                                                      .withValues(alpha: 0.22)
                                                : AppColors.secondaryLight,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.receipt_long_rounded,
                                            color: colors.isDark
                                                ? const Color(0xFF93C5FD)
                                                : AppColors.secondary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                o.orderNumber.isNotEmpty
                                                    ? o.orderNumber
                                                    : o.id.substring(0, 8),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13.5,
                                                  color: colors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                o.occasion,
                                                style: TextStyle(
                                                  color: colors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        StatusBadge(status: o.status),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductRowSkeleton extends StatelessWidget {
  const _ProductRowSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.border,
      highlightColor: colors.bg,
      child: SizedBox(
        height: 232,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, i) => Container(
            width: 160,
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
