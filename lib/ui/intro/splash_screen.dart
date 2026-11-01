import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/state/app_settings.dart';
import '../../data/services/storage_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // 1. Smooth Logo Entry Scale
    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Logo Fade In
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    // 3. Shimmer Sweep Effect across the Logo
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeInOut),
      ),
    );

    // 4. Tagline Soft Fade In
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.55, 0.95, curve: Curves.easeIn),
      ),
    );

    _animController.forward();
    _navigateToNext();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNext() async {
    // Check login state concurrently during the motion
    final isLoggedIn = await StorageService.isLoggedIn();

    // Wait until motion completes smoothly
    await Future.delayed(const Duration(milliseconds: 1450));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) =>
            isLoggedIn ? const DashboardScreen() : const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      body: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Logo Container with Motion Scale & Shimmer
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft Ambient Backlight Glow
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? AppColors.primary.withOpacity(0.18)
                                : AppColors.primary.withOpacity(0.10),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? AppColors.primary.withOpacity(0.35)
                                    : AppColors.primary.withOpacity(0.20),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),

                        // The Theme-Adaptive Logo with Shimmer Mask
                        ShaderMask(
                          blendMode: BlendMode.srcATop,
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [
                                (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                                _shimmerAnimation.value.clamp(0.0, 1.0),
                                (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                              ],
                              colors: isDark
                                  ? [
                                      Colors.white,
                                      const Color(0xFF34D399),
                                      Colors.white,
                                    ]
                                  : [
                                      const Color(0xFF0F172A),
                                      const Color(0xFF0D9488),
                                      const Color(0xFF0F172A),
                                    ],
                            ).createShader(bounds);
                          },
                          child: Image.asset(
                            // Strict rule: Light logo for Light mode, Dark logo for Dark mode!
                            isDark
                                ? 'assets/images/logo-white.png'
                                : 'assets/images/logo-light.png',
                            width: 180,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Image.asset(
                              isDark
                                  ? 'assets/images/icon-dark.png'
                                  : 'assets/images/icon-light.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // 2. Elegant Tagline Motion
                Opacity(
                  opacity: _taglineOpacity.value,
                  child: Column(
                    children: [
                      Text(
                        'ACCESS',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.5,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppSettings.isArabic
                            ? 'بطاقات الأعمال الذكية • Smart Cards'
                            : 'Smart Digital Business Cards',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white54 : const Color(0xFF64748B),
                          letterSpacing: 0.5,
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
}
