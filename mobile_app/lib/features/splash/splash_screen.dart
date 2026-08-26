import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animated_blobs.dart';
import '../../core/widgets/ikat_loader.dart';
import '../../core/widgets/ikat_pattern.dart';
import '../../core/widgets/odisha_landmarks.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.heroGradient),
          ),
          const AnimatedBlobs(
            colors: [Color(0xFFEACB7C), Color(0xFFC1502E), Colors.white],
            opacity: 0.20,
          ),
          const IkatWeaveBackdrop(color: Colors.white, opacity: 0.11, spacing: 30),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 170,
            child: OdishaSkylineBackdrop(
              color: Colors.white,
              opacity: 0.34,
              rich: true,
              richColors: [Color(0xFFEACB7C), Color(0xFFC98A2C)],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer diamond ring, slow clockwise turn.
                      Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.30),
                                width: 1.2,
                              ),
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat())
                          .rotate(duration: 8000.ms, curve: Curves.linear)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(0.94, 0.94),
                            end: const Offset(1.04, 1.04),
                            duration: 2000.ms,
                            curve: Curves.easeInOut,
                          ),
                      // Inner diamond, counter-rotating in antique gold.
                      Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.65),
                                width: 1.6,
                              ),
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat())
                          .rotate(
                            begin: 0.98,
                            end: 0.23,
                            duration: 6000.ms,
                            curve: Curves.linear,
                          ),
                      // Brand tile — gold-thread tile with a woven rosette mark.
                      Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.20),
                                  blurRadius: 30,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: IkatRosette(
                                size: 46,
                                color: AppColors.primaryDark,
                                strokeWidth: 2.4,
                              ),
                            ),
                          )
                          .animate()
                          .scale(
                            begin: const Offset(0.4, 0.4),
                            end: const Offset(1, 1),
                            duration: 700.ms,
                            curve: Curves.easeOutBack,
                          )
                          .fadeIn(duration: 400.ms)
                          .then(delay: 300.ms)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scaleXY(
                            begin: 1,
                            end: 1.05,
                            duration: 1400.ms,
                            curve: Curves.easeInOut,
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Shimmer.fromColors(
                      baseColor: Colors.white,
                      highlightColor: AppColors.accentLight,
                      period: const Duration(milliseconds: 1800),
                      child: Text(
                        'BulkMart',
                        style: AppFonts.display(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      delay: 300.ms,
                      duration: 500.ms,
                    ),
                const SizedBox(height: 8),
                Text(
                  'Bulk Grocery. Simplified.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                const SizedBox(height: 56),
                IkatLoader(
                  size: 34,
                  color: Colors.white,
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
