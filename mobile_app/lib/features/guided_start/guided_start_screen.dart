import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/screen_backdrop.dart';
import '../../core/widgets/tappable.dart';
import '../../data/models/category.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/locale_provider.dart';

class GuestOption {
  final String labelKey;
  final int guests;
  const GuestOption(this.labelKey, this.guests);
}

const guestOptions = [
  GuestOption('guests_upto_50', 50),
  GuestOption('guests_50_100', 100),
  GuestOption('guests_100_250', 250),
  GuestOption('guests_250_plus', 400),
];

/// A short, playful "help me get started" wizard for shoppers who land on
/// the homepage and aren't sure what to order. It asks for the occasion and
/// a rough guest count, then always surfaces the same curated set of
/// popular essentials — the point isn't a real recommendation engine, it's
/// giving hesitant/new users a guided, low-effort on-ramp into browsing.
class GuidedStartScreen extends StatefulWidget {
  const GuidedStartScreen({super.key});

  @override
  State<GuidedStartScreen> createState() => _GuidedStartScreenState();
}

class _GuidedStartScreenState extends State<GuidedStartScreen> {
  final _pageController = PageController();
  int _step = 0;
  Occasion? _selectedOccasion;
  GuestOption? _selectedGuests;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catalog = context.read<CatalogProvider>();
      if (catalog.featuredProducts.isEmpty && !catalog.loading) {
        catalog.loadHome();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish() {
    final cart = context.read<CartProvider>();
    cart.setOccasion(_selectedOccasion?.name ?? '');
    cart.eventDetails.expectedGuests = _selectedGuests?.guests ?? 0;
    context.push('/browse');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lang = context.watch<LocaleProvider>().language;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: Text(t(lang, 'guided_appbar_title'))),
      body: ScreenBackdrop(
        occasionOverride: _selectedOccasion?.name,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                child: _StepProgress(step: _step, total: 3),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _OccasionStep(
                      lang: lang,
                      selected: _selectedOccasion,
                      onSelect: (o) => setState(() => _selectedOccasion = o),
                      onNext: () => _goTo(1),
                    ),
                    _GuestStep(
                      lang: lang,
                      selected: _selectedGuests,
                      onSelect: (g) => setState(() => _selectedGuests = g),
                      onNext: () => _goTo(2),
                      onBack: () => _goTo(0),
                    ),
                    _ResultStep(
                      lang: lang,
                      onBack: () => _goTo(1),
                      onFinish: _finish,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  final int step;
  final int total;

  const _StepProgress({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: List.generate(total, (i) {
        final done = i <= step;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 8),
            height: 6,
            decoration: BoxDecoration(
              color: done ? AppColors.primary : colors.border,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        );
      }),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StepHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFonts.display(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _OccasionStep extends StatelessWidget {
  final AppLanguage lang;
  final Occasion? selected;
  final ValueChanged<Occasion> onSelect;
  final VoidCallback onNext;

  const _OccasionStep({
    required this.lang,
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StepHeader(
          title: t(lang, 'occasion_step_title'),
          subtitle: t(lang, 'occasion_step_subtitle'),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            itemCount: occasions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, i) {
              final o = occasions[i];
              final isSelected = selected?.id == o.id;
              return _SelectableCard(
                icon: o.icon,
                label: o.name,
                selected: isSelected,
                onTap: () => onSelect(o),
              ).animate().fadeIn(delay: (25 * i).ms, duration: 260.ms);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: PrimaryButton(
            label: t(lang, 'next'),
            icon: Icons.arrow_forward_rounded,
            onPressed: selected == null ? null : onNext,
          ),
        ),
      ],
    );
  }
}

class _GuestStep extends StatelessWidget {
  final AppLanguage lang;
  final GuestOption? selected;
  final ValueChanged<GuestOption> onSelect;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _GuestStep({
    required this.lang,
    required this.selected,
    required this.onSelect,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StepHeader(
          title: t(lang, 'guest_step_title'),
          subtitle: t(lang, 'guest_step_subtitle'),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            itemCount: guestOptions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, i) {
              final g = guestOptions[i];
              final isSelected = selected?.guests == g.guests;
              return _SelectableCard(
                icon: Icons.groups_rounded,
                label: t(lang, g.labelKey),
                selected: isSelected,
                onTap: () => onSelect(g),
              ).animate().fadeIn(delay: (25 * i).ms, duration: 260.ms);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(t(lang, 'back')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size.fromHeight(54),
                    textStyle: const TextStyle(
                      inherit: false,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: t(lang, 'next'),
                  icon: Icons.arrow_forward_rounded,
                  onPressed: selected == null ? null : onNext,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultStep extends StatelessWidget {
  final AppLanguage lang;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  const _ResultStep({
    required this.lang,
    required this.onBack,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final catalog = context.watch<CatalogProvider>();
    final items = catalog.featuredProducts.take(6).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.celebration_rounded,
                    color: AppColors.accent,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t(lang, 'result_title'),
                      style: AppFonts.display(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                t(lang, 'result_subtitle'),
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
              ),
            ],
          ),
        ),
        Expanded(
          child: catalog.loading && items.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, i) {
                    final p = items[i];
                    return ProductCard(
                      product: p,
                      onTap: () =>
                          context.push('/product/${p.id}', extra: p),
                    ).animate().fadeIn(delay: (40 * i).ms, duration: 280.ms);
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(t(lang, 'back')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size.fromHeight(54),
                    textStyle: const TextStyle(
                      inherit: false,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: t(lang, 'start_shopping'),
                  icon: Icons.shopping_bag_outlined,
                  onPressed: onFinish,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectableCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tappable(
      onTap: onTap,
      pressedScale: 0.97,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? (colors.isDark
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.primaryLight)
              : colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : colors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : (colors.isDark
                        ? AppColors.secondary.withValues(alpha: 0.22)
                        : AppColors.secondaryLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected
                    ? Colors.white
                    : (colors.isDark
                        ? const Color(0xFF93C5FD)
                        : AppColors.secondary),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? AppColors.primary : colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
