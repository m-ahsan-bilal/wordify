import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../core/utils/app_colors.dart';
import '../core/utils/safe_fonts.dart';
import '../viewmodel/words_list_vm.dart';
import '../viewmodel/streak_vm.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  AnimationController? _progressController;
  AnimationController? _fadeController;
  AnimationController? _scaleController;
  AnimationController? _floatController;
  Animation<double>? _progressAnimation;
  Animation<double>? _fadeAnimation;
  Animation<double>? _scaleAnimation;
  Animation<double>? _floatAnimation;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateAfterDelay();
  }

  void _initializeAnimations() {
    try {
      // Progress bar animation (1.5 seconds)
      _progressController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
      _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _progressController!, curve: Curves.easeInOut),
      );

      // Fade in animation
      _fadeController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController!, curve: Curves.easeOut),
      );

      // Scale animation for icon
      _scaleController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _scaleController!, curve: Curves.elasticOut),
      );

      // Floating animation for background shapes
      _floatController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
      _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
        CurvedAnimation(parent: _floatController!, curve: Curves.easeInOut),
      );

      // Start animations safely
      _fadeController?.forward();
      _scaleController?.forward();
      _progressController?.forward();
      _floatController?.repeat(reverse: true);
    } catch (e) {
      debugPrint('Error initializing animations: $e');
      // Continue without animations if they fail
    }
  }

  @override
  void dispose() {
    _progressController?.dispose();
    _fadeController?.dispose();
    _scaleController?.dispose();
    _floatController?.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterDelay() async {
    // Prevent multiple navigation attempts
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      // Check onboarding status with timeout and error handling
      Future<bool> checkOnboarding() async {
        try {
          final box = await Hive.openBox('settings').timeout(
            const Duration(milliseconds: 500),
            onTimeout: () {
              debugPrint('Hive box open timeout - using default');
              try {
                return Hive.box('settings');
              } catch (e) {
                debugPrint('Error accessing Hive box: $e');
                return Hive.box('settings');
              }
            },
          );
          final hasSeenOnboarding = box.get('onboarding', defaultValue: false);
          return hasSeenOnboarding;
        } catch (e) {
          debugPrint('Error checking onboarding: $e');
          // Default to onboarding if check fails
          return false;
        }
      }

      // Start onboarding check in parallel (non-blocking)
      final onboardingFuture = checkOnboarding();

      // Show splash screen for 1.5 seconds (minimum display time)
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted || _isNavigating == false) return;

      // Get onboarding status
      bool hasSeenOnboarding = false;
      try {
        hasSeenOnboarding = await onboardingFuture;
      } catch (e) {
        debugPrint('Error getting onboarding status: $e');
        hasSeenOnboarding = false; // Default to onboarding
      }

      if (!mounted) return;

      // Start preloading data in background (non-blocking, won't crash if fails)
      if (hasSeenOnboarding) {
        _preloadHomeScreenData().catchError((e) {
          debugPrint('Error preloading home screen data: $e');
          // Continue navigation even if preload fails
        });
      }

      // Navigate after 1.5 seconds with error handling
      if (mounted && context.mounted) {
        try {
          final route = hasSeenOnboarding ? '/home' : '/onboarding';
          context.go(route);
        } catch (e) {
          debugPrint('Error navigating: $e');
          // Retry navigation after brief delay
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted && context.mounted) {
            try {
              final route = hasSeenOnboarding ? '/home' : '/onboarding';
              context.go(route);
            } catch (e2) {
              debugPrint('Retry navigation failed: $e2');
              // Final fallback - try onboarding
              if (mounted && context.mounted) {
                try {
                  context.go('/onboarding');
                } catch (e3) {
                  debugPrint('Final navigation fallback failed: $e3');
                }
              }
            }
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Critical error in splash navigation: $e');
      debugPrint('Stack trace: $stackTrace');
      // Emergency fallback navigation
      if (mounted && context.mounted) {
        try {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted && context.mounted) {
            context.go('/onboarding');
          }
        } catch (e2) {
          debugPrint('Emergency navigation failed: $e2');
        }
      }
    }
  }

  /// Preload data for home screen - non-blocking, won't crash app
  Future<void> _preloadHomeScreenData() async {
    try {
      if (!mounted || !context.mounted) return;

      // Preload words with error handling
      try {
        final wordsListVm = context.read<WordsListViewModel>();
        await wordsListVm.loadWords().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('Words preload timeout');
          },
        );
      } catch (e) {
        debugPrint('Error preloading words: $e');
        // Continue even if words fail to load
      }

      // Preload streak with error handling
      try {
        if (!mounted || !context.mounted) return;
        final streakVm = context.read<StreakViewModel>();
        await streakVm.validateStreak().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            debugPrint('Streak preload timeout');
          },
        );
      } catch (e) {
        debugPrint('Error preloading streak: $e');
        // Continue even if streak fails to load
      }

      debugPrint('✅ Home screen data preloaded successfully');
    } catch (e) {
      debugPrint('Error in _preloadHomeScreenData: $e');
      // Don't throw - this is background loading
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fallback UI if animations fail to initialize
    if (_fadeAnimation == null ||
        _scaleAnimation == null ||
        _progressAnimation == null ||
        _floatAnimation == null) {
      return _buildFallbackSplash();
    }

    return Scaffold(
      backgroundColor: AppColors.lightLavender,
      body: SafeArea(
        child: Stack(
          children: [
            // Gradient background with animated layered shapes
            _BackgroundGradient(animation: _floatAnimation!),

            // Main content - centered in stack
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Central card with fade and scale animations
                  FadeTransition(
                    opacity: _fadeAnimation!,
                    child: _SplashCard(
                      scaleAnimation: _scaleAnimation!,
                      progressAnimation: _progressAnimation!,
                    ),
                  ),

                  const Spacer(),

                  // Bottom text with fade animation
                  FadeTransition(
                    opacity: _fadeAnimation!,
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 32.0),
                      child: _BottomText(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fallback splash screen if animations fail
  Widget _buildFallbackSplash() {
    return Scaffold(
      backgroundColor: AppColors.lightLavender,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.lightPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.edit_note,
                  size: 32,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'WordMaster',
                style: safeGoogleFonts(
                  fontFamily: 'inter',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Learn powerful words effortlessly.',
                style: safeGoogleFonts(
                  fontFamily: 'inter',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: AppColors.lightGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
          decoration: const BoxDecoration(color: AppColors.lightLavender),
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
                    color: AppColors.lightPurple.withValues(alpha: 0.3),
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
                    color: AppColors.lightBlue.withValues(alpha: 0.4),
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
                    color: AppColors.lightPurple.withValues(alpha: 0.25),
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
                    color: AppColors.lightBlue.withValues(alpha: 0.3),
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

/// Central splash card with animations
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
        color: AppColors.lightLavender,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with scale animation - with fallback
          ScaleTransition(
            scale: scaleAnimation,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.lightPurple,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildLogo(),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            'WordMaster',
            style: safeGoogleFonts(
              fontFamily: 'inter',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Learn powerful words effortlessly.',
            style: safeGoogleFonts(
              fontFamily: 'inter',
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

  Widget _buildLogo() {
    try {
      return ImageIcon(
        const AssetImage('assets/icons/logo.png'),
        size: 32,
        color: AppColors.darkGray,
      );
    } catch (e) {
      debugPrint('Error loading logo: $e');
      // Fallback to icon if image fails
      return const Icon(Icons.edit_note, size: 32, color: AppColors.darkGray);
    }
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

/// Bottom text
class _BottomText extends StatelessWidget {
  const _BottomText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Designed for focus • Built for consistency',
      style: safeGoogleFonts(
        fontFamily: 'inter',
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.lightGray,
      ),
      textAlign: TextAlign.center,
    );
  }
}
