import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/constants/index.dart';
import 'package:life_stream/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigate();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scale = Tween<double>(
      begin: 0.75,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  bool _isTimerDone = false;
  bool _navigated = false;

  void _navigate() async {
    // 1. Wait for minimum splash time
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    _isTimerDone = true;
    _checkAndNavigate();
  }

  void _checkAndNavigate() {
    if (_navigated) return;

    final authState = ref.read(authProvider);

    // Only navigate if BOTH timer is done AND auth is initialized
    if (_isTimerDone && authState.isInitialized) {
      _navigated = true;
      context.go(authState.isAuthenticated ? '/home' : '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes to trigger navigation once initialized
    ref.listen(authProvider, (previous, next) {
      if (next.isInitialized && _isTimerDone) {
        _checkAndNavigate();
      }
    });

    // Use fixed primary color for splash to ensure consistency
    const primary = Color(0xFF6366F1); // AppColors.lightPrimary

    return Scaffold(
      body: Stack(
        children: [
          // Animated Gradient Background
          AnimatedContainer(
            duration: const Duration(seconds: 3),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary.withOpacity(0.9),
                  primary.withOpacity(0.6),
                  primary.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Main Content
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glowing Logo
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.5),
                            blurRadius: 35,
                            spreadRadius: 3,
                          ),
                        ],
                        gradient: LinearGradient(
                          colors: [primary, primary.withOpacity(0.7)],
                        ),
                      ),
                      child: const Icon(
                        Icons.health_and_safety_rounded, // UPDATED ICON
                        size: 80, // UPDATED SIZE
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // App Name
                    Text(
                      AppConstants.appName,
                      style: AppTextStyles.displaySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Shimmer Loading Text
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white,
                          Colors.white.withOpacity(0.2),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds),
                      child: Text(
                        "Loading...",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
