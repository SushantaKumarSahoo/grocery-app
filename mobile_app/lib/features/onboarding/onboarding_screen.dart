import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/animated_blobs.dart';
import '../../core/widgets/ikat_pattern.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/tilt_card.dart';
import '../../providers/auth_provider.dart';

class _OnboardPage {
  final IconData icon;
  final String title;
  final String description;
  final LinearGradient gradient;
  const _OnboardPage(this.icon, this.title, this.description, this.gradient);
}

const _pages = [
  _OnboardPage(
    Icons.inventory_2_rounded,
    'Bulk Grocery Orders',
    'Order groceries in bulk quantities for large events, catering and institutions — hassle free.',
    AppColors.heroGradient,
  ),
  _OnboardPage(
    Icons.celebration_rounded,
    'Wedding Supplies',
    'From rice to spices, get everything sorted for weddings and receptions in one platform.',
    AppColors.auroraGradient,
  ),
  _OnboardPage(
    Icons.event_available_rounded,
    'Event Planning',
    'Plan your event details, guest count and delivery schedule with ease.',
    AppColors.oceanGradient,
  ),
  _OnboardPage(
    Icons.request_quote_rounded,
    'Easy Quotation Process',
    'Submit your requirement and receive a transparent, itemised quotation from verified suppliers.',
    AppColors.sunsetGradient,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  void _finish() {
    context.read<AuthProvider>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final page = _pages[_index];
    return Scaffold(
      backgroundColor: colors.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Stack(
                key: ValueKey(_index),
                children: [
                  AnimatedBlobs(
                    colors: page.gradient.colors,
                    opacity: colors.isDark ? 0.16 : 0.10,
                  ),
                  IkatWeaveBackdrop(
                    color: page.gradient.colors.first,
                    opacity: colors.isDark ? 0.13 : 0.11,
                    spacing: 30,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, top: 8),
                    child: TextButton(
                      onPressed: _finish,
                      child: const Text('Skip'),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) {
                      final page = _pages[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TiltCard(
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  gradient: page.gradient,
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [
                                    BoxShadow(
                                      color: page.gradient.colors.first.withValues(alpha: 0.35),
                                      blurRadius: 28,
                                      offset: const Offset(0, 14),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned.fill(
                                      child: IkatWeaveBackdrop(
                                        color: Colors.white,
                                        opacity: 0.10,
                                        spacing: 26,
                                      ),
                                    ),
                                    Icon(page.icon, size: 76, color: Colors.white),
                                  ],
                                ),
                              ),
                            )
                                .animate(key: ValueKey('icon$i'))
                                .fadeIn(duration: 450.ms)
                                .scale(
                                    begin: const Offset(0.8, 0.8),
                                    end: const Offset(1, 1),
                                    curve: Curves.easeOutBack,
                                    duration: 500.ms)
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .moveY(begin: -6, end: 6, duration: 2400.ms, curve: Curves.easeInOut),
                            const SizedBox(height: 40),
                            Text(
                              page.title,
                              textAlign: TextAlign.center,
                              style: AppFonts.display(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            )
                                .animate(key: ValueKey('title$i'))
                                .fadeIn(delay: 100.ms, duration: 400.ms)
                                .slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 14),
                            Text(
                              page.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.5,
                                color: colors.textSecondary,
                                height: 1.5,
                              ),
                            )
                                .animate(key: ValueKey('desc$i'))
                                .fadeIn(delay: 200.ms, duration: 400.ms),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: _pages.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: page.gradient.colors.first,
                    dotColor: colors.border,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: PrimaryButton(
                    label: _index == _pages.length - 1 ? 'Get Started' : 'Next',
                    color: page.gradient.colors.first,
                    onPressed: () {
                      if (_index == _pages.length - 1) {
                        _finish();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
