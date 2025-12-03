import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/utils/app_colors.dart';
import '../core/utils/safe_fonts.dart' as SafeFonts;
import '../viewmodel/settings_vm.dart';

/// Onboarding Screen - Tutorial-style with animations
/// Shows users how to use the app: Add words, Quizzes, Swipes
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightLavender,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: 5,
              onPageChanged: (index) {
                setState(() => currentPage = index);
              },
              itemBuilder: (_, index) {
                switch (index) {
                  case 0:
                    return _WelcomePage(key: ValueKey('page_$index'));
                  case 1:
                    return _AddWordTutorialPage(key: ValueKey('page_$index'));
                  case 2:
                    return _QuizTutorialPage(key: ValueKey('page_$index'));
                  case 3:
                    return _SwipeTutorialPage(key: ValueKey('page_$index'));
                  case 4:
                    return _GetStartedPage(key: ValueKey('page_$index'));
                  default:
                    return _WelcomePage(key: ValueKey('page_$index'));
                }
              },
            ),
            // Skip button
            if (currentPage < 4)
              Positioned(
                top: 16,
                right: 20,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: SafeFonts.safeGoogleFonts(
                      fontFamily: 'inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGray,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavigation(
        controller: _controller,
        currentPage: currentPage,
        onNext: () {
          if (!mounted) return;
          if (currentPage < 4) {
            try {
              _controller.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } catch (e) {
              debugPrint('Error navigating to next page: $e');
            }
          } else {
            _completeOnboarding();
          }
        },
        onComplete: _completeOnboarding,
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    if (!mounted) return;
    try {
      final settings = context.read<SettingsViewModel>();
      await settings.setOnboardingSeen();
      if (!mounted) return;
      if (context.mounted) {
        context.go('/home');
      }
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      if (mounted && context.mounted) {
        context.go('/home');
      }
    }
  }
}

/// Page 1: Welcome
class _WelcomePage extends StatefulWidget {
  const _WelcomePage({super.key});

  @override
  State<_WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<_WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            // Logo/Icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.lightPurple,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkPurple.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 60,
                  color: AppColors.darkPurple,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Welcome to Word Master',
                style: SafeFonts.safeGoogleFonts(
                  fontFamily: 'inter',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Build your vocabulary one word at a time with interactive learning',
                style: SafeFonts.safeGoogleFonts(
                  fontFamily: 'inter',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: AppColors.lightGray,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

/// Page 2: Add Word Tutorial
class _AddWordTutorialPage extends StatefulWidget {
  const _AddWordTutorialPage({super.key});

  @override
  State<_AddWordTutorialPage> createState() => _AddWordTutorialPageState();
}

class _AddWordTutorialPageState extends State<_AddWordTutorialPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonPulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _buttonPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Add New Words',
                style: SafeFonts.safeGoogleFonts(
                  fontFamily: 'inter',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Tap the "Add Word" button to start building your vocabulary',
                style: SafeFonts.safeGoogleFonts(
                  fontFamily: 'inter',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: AppColors.lightGray,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            // Animated demo card
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Word input demo
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.lightLavender,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_note_rounded,
                              color: AppColors.darkPurple,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Enter word...',
                                style: SafeFonts.safeGoogleFonts(
                                  fontFamily: 'inter',
                                  fontSize: 16,
                                  color: AppColors.lightGray,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Meaning input demo
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.lightLavender,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.description_rounded,
                              color: AppColors.darkPurple,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Add meaning...',
                                style: SafeFonts.safeGoogleFonts(
                                  fontFamily: 'inter',
                                  fontSize: 16,
                                  color: AppColors.lightGray,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Animated Add Word button
                      ScaleTransition(
                        scale: _buttonPulseAnimation,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.lightPurple,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_rounded,
                                color: AppColors.darkGray,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Add Word',
                                style: SafeFonts.safeGoogleFonts(
                                  fontFamily: 'inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// Page 3: Quiz Tutorial
class _QuizTutorialPage extends StatefulWidget {
  const _QuizTutorialPage({super.key});

  @override
  State<_QuizTutorialPage> createState() => _QuizTutorialPageState();
}

class _QuizTutorialPageState extends State<_QuizTutorialPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _quizCardAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _quizCardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Interactive Quizzes',
                style: SafeFonts.safeGoogleFonts(
                  fontFamily: 'inter',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Swipe on word cards to test your knowledge',
                style: SafeFonts.safeGoogleFonts(
                  fontFamily: 'inter',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: AppColors.lightGray,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            // Animated quiz demo - made scrollable to prevent overflow
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: FadeTransition(
                        opacity: _quizCardAnimation,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: EdgeInsets.all(constraints.maxHeight < 600 ? 16 : 24),
                          constraints: BoxConstraints(
                            maxWidth: 400,
                            minHeight: constraints.maxHeight * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Word card
                              Container(
                                padding: EdgeInsets.all(constraints.maxHeight < 600 ? 16 : 20),
                                decoration: BoxDecoration(
                                  color: AppColors.lightLavender,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Eloquent',
                                      style: SafeFonts.safeGoogleFonts(
                                        fontFamily: 'inter',
                                        fontSize: constraints.maxHeight < 600 ? 20 : 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkGray,
                                      ),
                                    ),
                                    SizedBox(height: constraints.maxHeight < 600 ? 6 : 8),
                                    Text(
                                      'Fluent and persuasive in speaking or writing',
                                      style: SafeFonts.safeGoogleFonts(
                                        fontFamily: 'inter',
                                        fontSize: constraints.maxHeight < 600 ? 12 : 14,
                                        color: AppColors.lightGray,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: constraints.maxHeight < 600 ? 16 : 24),
                              // Quiz question
                              Text(
                                'What is the meaning?',
                                style: SafeFonts.safeGoogleFonts(
                                  fontFamily: 'inter',
                                  fontSize: constraints.maxHeight < 600 ? 16 : 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkGray,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: constraints.maxHeight < 600 ? 12 : 16),
                              // Options
                              ...[
                                'A) Clear',
                                'B) Confusing',
                                'C) Fluent',
                                'D) Silent',
                              ].map(
                                (option) => Container(
                                  margin: EdgeInsets.only(bottom: constraints.maxHeight < 600 ? 8 : 12),
                                  padding: EdgeInsets.all(constraints.maxHeight < 600 ? 12 : 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightLavender,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.lightPurple,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    option,
                                    style: SafeFonts.safeGoogleFonts(
                                      fontFamily: 'inter',
                                      fontSize: constraints.maxHeight < 600 ? 14 : 16,
                                      color: AppColors.darkGray,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Page 4: Swipe Gestures Tutorial
class _SwipeTutorialPage extends StatefulWidget {
  const _SwipeTutorialPage({super.key});

  @override
  State<_SwipeTutorialPage> createState() => _SwipeTutorialPageState();
}

class _SwipeTutorialPageState extends State<_SwipeTutorialPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<AnimationController> _swipeControllers;
  late List<Animation<Offset>> _swipeAnimations;
  int _currentSwipeIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Create animations for each swipe direction
    _swipeControllers = List.generate(4, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
    });

    _swipeAnimations = [
      Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.3)).animate(
        CurvedAnimation(parent: _swipeControllers[0], curve: Curves.easeInOut),
      ), // Up
      Tween<Offset>(begin: Offset.zero, end: const Offset(0, 0.3)).animate(
        CurvedAnimation(parent: _swipeControllers[1], curve: Curves.easeInOut),
      ), // Down
      Tween<Offset>(begin: Offset.zero, end: const Offset(-0.3, 0)).animate(
        CurvedAnimation(parent: _swipeControllers[2], curve: Curves.easeInOut),
      ), // Left
      Tween<Offset>(begin: Offset.zero, end: const Offset(0.3, 0)).animate(
        CurvedAnimation(parent: _swipeControllers[3], curve: Curves.easeInOut),
      ), // Right
    ];

    _controller.forward();
    _startSwipeAnimation();
  }

  void _startSwipeAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _animateNextSwipe();
      }
    });
  }

  void _animateNextSwipe() {
    if (!mounted) return;
    _swipeControllers[_currentSwipeIndex].forward().then((_) {
      if (mounted) {
        _swipeControllers[_currentSwipeIndex].reverse().then((_) {
          if (mounted) {
            _currentSwipeIndex = (_currentSwipeIndex + 1) % 4;
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                _animateNextSwipe();
              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var ctrl in _swipeControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Swipe Gestures',
                style: SafeFonts.safeGoogleFonts(
                  fontFamily: 'inter',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Learn how to interact with word cards',
                style: SafeFonts.safeGoogleFonts(
                  fontFamily: 'inter',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: AppColors.lightGray,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            // Animated swipe demo - made scrollable to prevent overflow
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Card with swipe animation
                          SlideTransition(
                            position: _swipeAnimations[_currentSwipeIndex],
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(maxWidth: 280),
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Eloquent',
                                    style: SafeFonts.safeGoogleFonts(
                                      fontFamily: 'inter',
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkGray,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Fluent and persuasive',
                                    style: SafeFonts.safeGoogleFonts(
                                      fontFamily: 'inter',
                                      fontSize: 16,
                                      color: AppColors.lightGray,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight < 600 ? 20 : 40),
                          // Swipe instructions - responsive layout
                          if (constraints.maxHeight < 600)
                            // Compact layout for small screens
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _buildSwipeInstruction(
                                  icon: Icons.arrow_upward_rounded,
                                  label: 'Swipe Up',
                                  description: 'Quiz: Meaning',
                                  color: AppColors.lightGreen,
                                  isActive: _currentSwipeIndex == 0,
                                  isCompact: true,
                                ),
                                _buildSwipeInstruction(
                                  icon: Icons.arrow_downward_rounded,
                                  label: 'Swipe Down',
                                  description: 'Next Word',
                                  color: AppColors.lightPurple,
                                  isActive: _currentSwipeIndex == 1,
                                  isCompact: true,
                                ),
                                _buildSwipeInstruction(
                                  icon: Icons.arrow_back_rounded,
                                  label: 'Swipe Left',
                                  description: 'Quiz: Synonym',
                                  color: AppColors.lightBlue,
                                  isActive: _currentSwipeIndex == 2,
                                  isCompact: true,
                                ),
                                _buildSwipeInstruction(
                                  icon: Icons.arrow_forward_rounded,
                                  label: 'Swipe Right',
                                  description: 'Quiz: Antonym',
                                  color: AppColors.purple,
                                  isActive: _currentSwipeIndex == 3,
                                  isCompact: true,
                                ),
                              ],
                            )
                          else
                            // Full layout for larger screens
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildSwipeInstruction(
                                  icon: Icons.arrow_upward_rounded,
                                  label: 'Swipe Up',
                                  description: 'Quiz: Meaning',
                                  color: AppColors.lightGreen,
                                  isActive: _currentSwipeIndex == 0,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: _buildSwipeInstruction(
                                        icon: Icons.arrow_back_rounded,
                                        label: 'Swipe Left',
                                        description: 'Quiz: Synonym',
                                        color: AppColors.lightBlue,
                                        isActive: _currentSwipeIndex == 2,
                                        isCompact: true,
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Flexible(
                                      child: _buildSwipeInstruction(
                                        icon: Icons.arrow_forward_rounded,
                                        label: 'Swipe Right',
                                        description: 'Quiz: Antonym',
                                        color: AppColors.purple,
                                        isActive: _currentSwipeIndex == 3,
                                        isCompact: true,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildSwipeInstruction(
                                  icon: Icons.arrow_downward_rounded,
                                  label: 'Swipe Down',
                                  description: 'Next Word',
                                  color: AppColors.lightPurple,
                                  isActive: _currentSwipeIndex == 1,
                                ),
                              ],
                            ),
                          SizedBox(height: constraints.maxHeight < 600 ? 20 : 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeInstruction({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required bool isActive,
    bool isCompact = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isCompact ? 10 : 14),
      constraints: BoxConstraints(
        maxWidth: isCompact ? 140 : double.infinity,
        minWidth: isCompact ? 120 : 200,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? color.withValues(alpha: 0.2)
            : AppColors.lightLavender,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? color : AppColors.lightGray,
            size: isCompact ? 20 : 24,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: SafeFonts.safeGoogleFonts(
                    fontFamily: 'inter',
                    fontSize: isCompact ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: isActive ? color : AppColors.darkGray,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isCompact)
                  Text(
                    description,
                    style: SafeFonts.safeGoogleFonts(
                      fontFamily: 'inter',
                      fontSize: 11,
                      color: AppColors.lightGray,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Page 5: Get Started
class _GetStartedPage extends StatefulWidget {
  const _GetStartedPage({super.key});

  @override
  State<_GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<_GetStartedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            // Success icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lightGreen.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'You\'re All Set!',
                style: SafeFonts.safeGoogleFonts(
                  fontFamily: 'inter',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Start building your vocabulary and track your progress',
                style: SafeFonts.safeGoogleFonts(
                  fontFamily: 'inter',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: AppColors.lightGray,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

/// Bottom navigation with animated progress dots and next button
class _BottomNavigation extends StatefulWidget {
  final PageController controller;
  final int currentPage;
  final VoidCallback onNext;
  final VoidCallback onComplete;

  const _BottomNavigation({
    required this.controller,
    required this.currentPage,
    required this.onNext,
    required this.onComplete,
  });

  @override
  State<_BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<_BottomNavigation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      decoration: BoxDecoration(
        color: AppColors.lightLavender,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return _AnimatedProgressDot(
                isActive: index == widget.currentPage,
                delay: index * 50,
              );
            }),
          ),
          const SizedBox(height: 24),
          // Next/Get Started button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.currentPage == 4
                  ? widget.onComplete
                  : widget.onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPurple,
                foregroundColor: AppColors.darkGray,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.currentPage == 4)
                    Text(
                      'Get Started',
                      style: SafeFonts.safeGoogleFonts(
                        fontFamily: 'inter',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      ),
                    )
                  else ...[
                    Text(
                      'Next',
                      style: SafeFonts.safeGoogleFonts(
                        fontFamily: 'inter',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: AppColors.darkGray,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated progress dot
class _AnimatedProgressDot extends StatefulWidget {
  final bool isActive;
  final int delay;

  const _AnimatedProgressDot({required this.isActive, this.delay = 0});

  @override
  State<_AnimatedProgressDot> createState() => _AnimatedProgressDotState();
}

class _AnimatedProgressDotState extends State<_AnimatedProgressDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isActive) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) {
          _controller.forward();
          _controller.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void didUpdateWidget(_AnimatedProgressDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      if (mounted && !_controller.isAnimating) {
        _controller.forward();
        _controller.repeat(reverse: true);
      }
    } else if (!widget.isActive && oldWidget.isActive) {
      if (mounted) {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isActive ? _scaleAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isActive
                  ? AppColors.darkPurple
                  : AppColors.progressGray,
            ),
          ),
        );
      },
    );
  }
}
