import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import '../core/utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _floatController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Progress bar animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.33).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Scale animation for icon
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Floating animation for background shapes
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _progressController.forward();
    _floatController.repeat(reverse: true);

    _navigateAfterDelay();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterDelay() async {
    // Wait for splash screen duration
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check if user has seen onboarding
    try {
      final box = await Hive.openBox('settings');
      final hasSeenOnboarding = box.get('onboarding', defaultValue: false);

      if (!mounted) return;

      if (hasSeenOnboarding) {
        if (context.mounted) {
          context.go('/home');
        }
      } else {
        if (context.mounted) {
          context.go('/onboarding');
        }
      }
    } catch (e) {
      debugPrint('Error navigating from splash: $e');
      // If there's an error, default to onboarding
      if (mounted && context.mounted) {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Gradient background with animated layered shapes
          _BackgroundGradient(animation: _floatAnimation),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Premium button in top right with fade animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _PremiumButton(),
                    ),
                  ),
                ),

                // Spacer to push content to center
                const Spacer(),

                // Central card with fade and scale animations
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _SplashCard(
                    scaleAnimation: _scaleAnimation,
                    progressAnimation: _progressAnimation,
                  ),
                ),

                // Spacer
                const Spacer(),

                // Bottom text with fade animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: _BottomText(),
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

/// Reusable background gradient with animated layered shapes
class _BackgroundGradient extends StatelessWidget {
  final Animation<double> animation;

  const _BackgroundGradient({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.lightLavender, AppColors.white],
            ),
          ),
          child: Stack(
            children: [
              // Large rounded rectangle - top left (floating)
              Positioned(
                top: -50 + animation.value,
                left: -50 + animation.value * 0.5,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.lightPurple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              // Medium rounded rectangle - top right (floating)
              Positioned(
                top: 100 - animation.value * 0.7,
                right: -30 - animation.value * 0.3,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              // Small rounded rectangle - middle left (floating)
              Positioned(
                top: 250 + animation.value * 0.5,
                left: 20 - animation.value * 0.4,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.lightPurple.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              // Medium rounded rectangle - bottom right (floating)
              Positioned(
                bottom: 100 - animation.value,
                right: -40 + animation.value * 0.6,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(35),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Reusable Premium button
class _PremiumButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightPurple,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkPurple, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 16, color: AppColors.darkGray),
          const SizedBox(width: 6),
          Text(
            'Premium',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable central splash card with animations
class _SplashCard extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final Animation<double> progressAnimation;

  const _SplashCard({
    required this.scaleAnimation,
    required this.progressAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with scale animation
          ScaleTransition(
            scale: scaleAnimation,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.lightPurple,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ImageIcon(
                AssetImage('assets/icons/logo.png'),
                size: 32,
                color: AppColors.darkGray,
              ),
              // child: Icon(Icons.edit_note, size: 32, color: AppColors.darkGray),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            'WordMaster',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Learn powerful words effortlessly.',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: AppColors.lightGray,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Animated progress bar
          _AnimatedProgressBar(animation: progressAnimation),
        ],
      ),
    );
  }
}

/// Animated progress bar
class _AnimatedProgressBar extends StatelessWidget {
  final Animation<double> animation;

  const _AnimatedProgressBar({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.progressGray,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: animation.value,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Reusable bottom text
class _BottomText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Designed for focus • Built for consistency',
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.lightGray,
      ),
      textAlign: TextAlign.center,
    );
  }
}
