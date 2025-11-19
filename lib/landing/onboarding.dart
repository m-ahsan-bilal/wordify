import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/utils/app_colors.dart';
import '../viewmodel/settings_vm.dart';

/// Onboarding Screen - Uses SettingsViewModel
/// Follows MVVM pattern
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
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: 3,
              onPageChanged: (index) {
                setState(() => currentPage = index);
              },
              itemBuilder: (_, index) {
                if (index == 0) {
                  return _OnboardingPage1(key: ValueKey('page_$index'));
                } else if (index == 1) {
                  return _OnboardingPage2(key: ValueKey('page_$index'));
                } else {
                  return _OnboardingPage3(key: ValueKey('page_$index'));
                }
              },
            ),
            // Skip button
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
                  style: GoogleFonts.inter(
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
          if (currentPage < 2) {
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

/// Page 1: Upgrade your vocabulary with animations
class _OnboardingPage1 extends StatefulWidget {
  const _OnboardingPage1({super.key});

  @override
  State<_OnboardingPage1> createState() => _OnboardingPage1State();
}

class _OnboardingPage1State extends State<_OnboardingPage1>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top header with progress
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage('assets/icons/logo.png'),
                      size: 20,
                      color: AppColors.darkGray,
                    ),
                    // Icon(Icons.edit_note, size: 20, color: AppColors.darkGray),
                    const SizedBox(width: 8),
                    Text(
                      '1 of 3',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Central graphic area with animation
              _AnimatedCentralGraphicArea(),

              const SizedBox(height: 32),

              // Feature buttons with staggered animation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _AnimatedFeatureButton(
                      icon: Icons.flash_on,
                      label: 'Quick',
                      delay: 0,
                    ),
                    _AnimatedFeatureButton(
                      icon: Icons.psychology,
                      label: 'Smart',
                      delay: 100,
                    ),
                    _AnimatedFeatureButton(
                      icon: Icons.auto_awesome,
                      label: 'Premium',
                      delay: 200,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Upgrade your vocabulary effortlessly.',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Learn powerful words with meanings, examples, quizzes, and more.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: AppColors.lightGray,
                  ),
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

/// Page 2: Discover powerful features with animations
class _OnboardingPage2 extends StatefulWidget {
  const _OnboardingPage2({super.key});

  @override
  State<_OnboardingPage2> createState() => _OnboardingPage2State();
}

class _OnboardingPage2State extends State<_OnboardingPage2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top header with progress
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage('assets/icons/logo.png'),
                      size: 20,
                      color: AppColors.darkGray,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '2 of 3',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Discover powerful features',
                  style: GoogleFonts.inter(
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
                  'A playful, polished toolkit to learn faster and remember longer.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: AppColors.lightGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 32),

              // Feature cards grid with staggered animation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Top row
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _AnimatedFeatureCard(
                              icon: Icons.wb_sunny_outlined,
                              title: 'Word of the Day',
                              description:
                                  'Get a fresh, curated word with usage tips.',
                              buttonText: 'Daily boost',
                              delay: 0,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _AnimatedFeatureCard(
                              icon: Icons.add_circle_outline,
                              title: 'Add New Words',
                              description:
                                  'Capture words from anywhere in seconds.',
                              buttonText: 'Your list',
                              delay: 100,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Middle row
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _AnimatedFeatureCard(
                              icon: Icons.swap_horiz,
                              title: 'Synonyms & Antonyms',
                              description:
                                  'Broaden meaning with related words.',
                              buttonText: 'Connections',
                              delay: 200,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _AnimatedFeatureCard(
                              icon: Icons.hexagon_outlined,
                              title: 'Quick Quizzes',
                              description: 'Test yourself with speedy rounds.',
                              buttonText: 'Gamified',
                              delay: 300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Bottom full width card
                    _AnimatedFeatureCard(
                      icon: Icons.bookmark_border,
                      title: 'Saved Library',
                      description: 'All your favorites, neatly organized.',
                      buttonText: 'Always yours',
                      isFullWidth: true,
                      delay: 400,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

/// Page 3: Final screen with animations
class _OnboardingPage3 extends StatefulWidget {
  const _OnboardingPage3({super.key});

  @override
  State<_OnboardingPage3> createState() => _OnboardingPage3State();
}

class _OnboardingPage3State extends State<_OnboardingPage3>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top header with progress
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    ImageIcon(
                      AssetImage('assets/icons/logo.png'),
                      size: 20,
                      color: AppColors.darkGray,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '3 of 3',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),

              // Central graphic area with animation
              _AnimatedCentralGraphicArea(),

              const SizedBox(height: 40),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Start your learning journey',
                  style: GoogleFonts.inter(
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
                  'Build your vocabulary one word at a time with our smart learning system.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: AppColors.lightGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated central graphic area with animated green bar
class _AnimatedCentralGraphicArea extends StatefulWidget {
  const _AnimatedCentralGraphicArea();

  @override
  State<_AnimatedCentralGraphicArea> createState() =>
      _AnimatedCentralGraphicAreaState();
}

class _AnimatedCentralGraphicAreaState
    extends State<_AnimatedCentralGraphicArea>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
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
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background layered shapes
        Container(
          height: 280,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.lightLavender,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Stack(
            children: [
              // Light blue shape on right
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),

        // White card with icon - animated scale
        Positioned(
          top: 100,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              children: [
                Container(
                  width: 200,
                  padding: const EdgeInsets.all(24),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book,
                        size: 32,
                        color: AppColors.darkGray,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.auto_awesome,
                        size: 24,
                        color: AppColors.darkGray,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated feature button with delay
class _AnimatedFeatureButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final int delay;

  const _AnimatedFeatureButton({
    required this.icon,
    required this.label,
    this.delay = 0,
  });

  @override
  State<_AnimatedFeatureButton> createState() => _AnimatedFeatureButtonState();
}

class _AnimatedFeatureButtonState extends State<_AnimatedFeatureButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.lightPurple,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18, color: AppColors.darkGray),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated feature card with delay
class _AnimatedFeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final bool isFullWidth;
  final int delay;

  const _AnimatedFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    this.isFullWidth = false,
    this.delay = 0,
  });

  @override
  State<_AnimatedFeatureCard> createState() => _AnimatedFeatureCardState();
}

class _AnimatedFeatureCardState extends State<_AnimatedFeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
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
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 28, color: AppColors.darkGray),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: AppColors.lightGray,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightLavender,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.buttonText,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom navigation with animated progress dots, next button, and "How it works" link
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
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            children: List.generate(3, (index) {
              return _AnimatedProgressDot(
                isActive: index == widget.currentPage,
                delay: index * 100,
              );
            }),
          ),

          const SizedBox(height: 24),

          // Next button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.currentPage == 2
                  ? widget.onComplete
                  : widget.onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
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
                  if (widget.currentPage == 2)
                    Text(
                      'Get Started',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      ),
                    )
                  else ...[
                    Text(
                      'Next',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
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
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _colorAnimation = ColorTween(
      begin: AppColors.progressGray,
      end: AppColors.lightGreen,
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
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isActive
                ? (_colorAnimation.value ?? AppColors.lightGreen)
                : AppColors.progressGray,
          ),
          transform: Matrix4.identity()
            ..scale(widget.isActive ? _scaleAnimation.value : 1.0),
        );
      },
    );
  }
}
