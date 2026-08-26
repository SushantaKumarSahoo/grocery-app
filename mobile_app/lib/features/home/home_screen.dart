import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/animated_blobs.dart';
import '../../core/widgets/ikat_pattern.dart';
import '../../core/widgets/screen_backdrop.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/tappable.dart';
import '../../core/widgets/tilt_card.dart';
import '../../data/models/category.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/locale_provider.dart';
import 'widgets/occasion_chip.dart';
import 'widgets/category_showcase_deck.dart';

/// Occasions are grouped into two tabs on the homepage so the section stays
/// compact (one row at a time) instead of dumping all 9 occasions on the
/// user at once.
enum _OccasionGroup { celebrations, businessBulk }

/// Only the most-shopped categories get a shortcut on the homepage — the
/// full taxonomy already lives on the dedicated Categories tab, so we don't
/// duplicate it here.
const _homeCategoryNames = ['Rice', 'Dal', 'Oil', 'Vegetables', 'Spices', 'Dairy'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedOccasionId;
  _OccasionGroup _occasionGroup = _OccasionGroup.celebrations;
  bool _promoDismissed = false;
  int _bannerPage = 0;
  final _bannerController = PageController(viewportFraction: 0.92);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadHome();
      context.read<CatalogProvider>().loadCategoryPreviews(_homeCategoryNames);
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final catalog = context.read<CatalogProvider>();
    await Future.wait([
      catalog.loadHome(),
      catalog.loadCategoryPreviews(_homeCategoryNames),
    ]);
  }

  void _pickOccasion(Occasion o) {
    setState(() => _selectedOccasionId = o.id);
    context.read<CartProvider>().setOccasion(o.name);
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
    final lang = context.watch<LocaleProvider>().language;
    final homeCategories = staticCategories
        .where((c) => _homeCategoryNames.contains(c.name))
        .toList();
    final groupedOccasions = occasions
        .where((o) => _occasionGroup == _OccasionGroup.celebrations
            ? celebrationOccasionIds.contains(o.id)
            : !celebrationOccasionIds.contains(o.id))
        .toList();

    return Scaffold(
      backgroundColor: colors.bg,
      body: ScreenBackdrop(
        themed: true,
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
                                t(lang, 'good_day'),
                                style: TextStyle(
                                  fontSize: 14.5,
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${t(lang, 'greeting')} $firstName',
                                style: AppFonts.display(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tappable(
                          onTap: () => context.push('/support'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.card,
                              borderRadius: BorderRadius.circular(14),
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
                              size: 26,
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
                      onTap: () => context.push('/browse'),
                      pressedScale: 0.98,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.border),
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
                            Icon(
                              Icons.search_rounded,
                              color: colors.textMuted,
                              size: 26,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                t(lang, 'search_hint'),
                                style: TextStyle(
                                  color: colors.textMuted,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w500,
                                ),
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
                            child: SizedBox(
                              height: 152,
                              child: PageView.builder(
                                controller: _bannerController,
                                padEnds: false,
                                onPageChanged: (i) =>
                                    setState(() => _bannerPage = i),
                                itemCount: _promoDismissed ? 1 : 2,
                                itemBuilder: (context, i) {
                                  final banner = i == 0
                                      ? _HeroCard(lang: lang)
                                      : _PromoBanner(
                                          lang: lang,
                                          onShopNow: () =>
                                              context.push('/browse'),
                                          onDismiss: () {
                                            setState(() {
                                              _promoDismissed = true;
                                              _bannerPage = 0;
                                            });
                                            if (_bannerController.hasClients) {
                                              _bannerController.jumpToPage(0);
                                            }
                                          },
                                        );
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: i == 0 ? 12 : 0,
                                    ),
                                    child: banner,
                                  );
                                },
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
                if (!_promoDismissed)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(2, (i) {
                          final active = i == _bannerPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: active ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: active ? AppColors.primary : colors.border,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Tappable(
                      onTap: () => context.push('/guided-start'),
                      pressedScale: 0.98,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                gradient: AppColors.oceanGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t(lang, 'guided_entry_title'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    t(lang, 'guided_entry_subtitle'),
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: colors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: colors.textMuted),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 220.ms, duration: 350.ms),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
                    child: SectionHeader(title: t(lang, 'shop_by_occasion')),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: _OccasionGroupToggle(
                      group: _occasionGroup,
                      onChanged: (g) => setState(() => _occasionGroup = g),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100,
                    child: ListView.separated(
                      key: ValueKey(_occasionGroup),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      scrollDirection: Axis.horizontal,
                      itemCount: groupedOccasions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final o = groupedOccasions[i];
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
                    child: SectionHeader(
                      title: t(lang, 'shop_by_category'),
                      actionLabel: t(lang, 'more'),
                      onAction: () => context.push('/browse'),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
                    child: Text(
                      t(lang, 'swipe_categories_hint'),
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child:
                      Padding(
                            padding: const EdgeInsets.fromLTRB(20, 14, 0, 0),
                            child: CategoryShowcaseDeck(
                              categories: homeCategories,
                              previews: catalog.categoryPreviews,
                              loading: catalog.categoryPreviewsLoading,
                              lang: lang,
                              onSeeAll: (c) => context.push(
                                '/category/${Uri.encodeComponent(c.name)}',
                              ),
                              onProductTap: (p) => context.push(
                                '/product/${p.id}',
                                extra: p,
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 350.ms)
                          .slideY(
                            begin: 0.06,
                            end: 0,
                            delay: 100.ms,
                            duration: 350.ms,
                          ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Two-way pill switch that swaps the single occasion row between the
/// "Celebrations" (wedding/birthday/reception) and "Business & Bulk" groups,
/// so the homepage only ever shows one compact row instead of all 9 chips.
class _OccasionGroupToggle extends StatelessWidget {
  final _OccasionGroup group;
  final ValueChanged<_OccasionGroup> onChanged;

  const _OccasionGroupToggle({required this.group, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lang = context.watch<LocaleProvider>().language;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.isDark
            ? Colors.white.withValues(alpha: 0.06)
            : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: _OccasionGroup.values.map((g) {
          final selected = g == group;
          final label = g == _OccasionGroup.celebrations
              ? t(lang, 'celebrations')
              : t(lang, 'business_bulk');
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(g),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : colors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Bulk-quotation hero — the first card in the swipeable banner row.
class _HeroCard extends StatelessWidget {
  final AppLanguage lang;

  const _HeroCard({required this.lang});

  @override
  Widget build(BuildContext context) {
    return TiltCard(
      maxTilt: 0.03,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 152,
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBlobs(
                  colors: const [
                    Colors.white,
                    Color(0xFFEACB7C),
                    Colors.white,
                  ],
                  opacity: 0.16,
                ),
              ),
              const Positioned.fill(
                child: IkatWeaveBackdrop(
                  color: Colors.white,
                  opacity: 0.13,
                  spacing: 22,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            t(lang, 'bulk_ordering'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          t(lang, 'hero_title'),
                          style: AppFonts.display(
                            color: Colors.white,
                            fontSize: 18.5,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const IkatRosette(
                        size: 66,
                        color: Colors.white24,
                        strokeWidth: 3,
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(
                        begin: -4,
                        end: 4,
                        duration: 2200.ms,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .rotate(begin: -0.02, end: 0.02, duration: 2200.ms),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// New-user discount banner. Dismissible for the session — not persisted,
/// since it should reappear on the next cold start until the user actually
/// places their first order.
class _PromoBanner extends StatelessWidget {
  final AppLanguage lang;
  final VoidCallback onShopNow;
  final VoidCallback onDismiss;

  const _PromoBanner({
    required this.lang,
    required this.onShopNow,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onShopNow,
      pressedScale: 0.98,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 152,
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          decoration: const BoxDecoration(gradient: AppColors.sunsetGradient),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                right: -18,
                top: -22,
                child: Icon(
                  Icons.card_giftcard_rounded,
                  size: 96,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              Positioned(
                top: -2,
                right: -4,
                child: Tappable(
                  onTap: onDismiss,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.85),
                      size: 20,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.local_offer_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            t(lang, 'promo_badge'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t(lang, 'promo_title'),
                          style: AppFonts.display(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t(lang, 'promo_subtitle'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            t(lang, 'promo_cta'),
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
