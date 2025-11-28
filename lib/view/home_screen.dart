import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:word_master/core/utils/app_colors.dart';
import '../viewmodel/streak_vm.dart';
import '../viewmodel/quiz_vm.dart';
import '../viewmodel/words_list_vm.dart';
import '../core/model/word_model.dart';
import '../core/model/quiz_model.dart';
import 'widgets/quiz_dialog.dart';
import 'widgets/ad_banner_widget.dart';
import 'widgets/reusable_loading_overlay.dart';
import '../l10n/app_localizations.dart';

/// Home Screen - Uses StreakViewModel, QuizViewModel, and WordsListViewModel
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> todaysWords = [];
  int streak = 0;
  int totalWordsCount = 0;
  bool isLoading = false;
  final flutterTts = FlutterTts();
  List<Word> _allWords = [];

  // Word card state
  List<Map<String, dynamic>> _wordStack = [];
  int _currentCardIndex = 0;
  late AnimationController _cardAnimationController;

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Delay initialization to ensure all providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Add a longer delay to ensure all providers and router are ready
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _loadDataSafely();
          }
        });
      }
    });
  }

  /// Safely load data with error handling and timeouts
  Future<void> _loadDataSafely() async {
    if (!mounted) return;

    try {
      await _loadData().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Data loading timeout');
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      debugPrint('Error in _loadDataSafely: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  /// Refresh data without showing loading state (for background updates)
  /// Also explicitly updates streak to ensure it's current after word addition
  Future<void> _refreshData() async {
    if (!mounted || isLoading) return;

    // First, explicitly update streak (in case word was just added)
    try {
      final streakVm = context.read<StreakViewModel>();
      await streakVm.updateStreak();
    } catch (e) {
      debugPrint('Error updating streak in refresh: $e');
    }

    // Then load all data
    await _loadData();
  }

  /// Force refresh data (can be called from external sources)
  Future<void> forceRefresh() async {
    if (!mounted) return;
    await _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (!mounted) return;

      // Safely access ViewModels with error handling
      StreakViewModel? streakVm;
      WordsListViewModel? wordsListVm;

      try {
        streakVm = context.read<StreakViewModel>();
      } catch (e) {
        debugPrint('Error accessing StreakViewModel: $e');
      }

      try {
        wordsListVm = context.read<WordsListViewModel>();
      } catch (e) {
        debugPrint('Error accessing WordsListViewModel: $e');
      }

      // Load data with timeouts to prevent hanging
      if (streakVm != null) {
        try {
          await streakVm.validateStreak().timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('Streak validation timeout');
            },
          );
        } catch (e) {
          debugPrint('Error validating streak: $e');
        }
      }

      if (!mounted) return;

      if (wordsListVm != null) {
        try {
          await wordsListVm.loadWords().timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('Words load timeout');
            },
          );
        } catch (e) {
          debugPrint('Error loading words: $e');
        }
      }

      if (!mounted) return;

      // Get sorted words safely
      List<Map<String, dynamic>> allWordsSorted = [];
      if (wordsListVm != null) {
        try {
          allWordsSorted = wordsListVm.getAllWordsSortedByTime();
          _allWords = allWordsSorted
              .map((w) {
                try {
                  return Word.fromMap(w);
                } catch (e) {
                  debugPrint('Error parsing word: $e');
                  return Word(
                    word: '',
                    meaning: '',
                    synonyms: '',
                    antonyms: '',
                  );
                }
              })
              .where((w) => w.word.isNotEmpty)
              .toList();
        } catch (e) {
          debugPrint('Error getting sorted words: $e');
        }
      }

      if (mounted) {
        setState(() {
          todaysWords = allWordsSorted;
          totalWordsCount = allWordsSorted.length;
          _wordStack = List<Map<String, dynamic>>.from(allWordsSorted);
          _currentCardIndex = 0;
        });

        debugPrint(
          'Loaded ${allWordsSorted.length} words, current index: $_currentCardIndex',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading data: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        try {
          final errorMessage = AppLocalizations.of(context)!.failedToLoadData;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$errorMessage: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } catch (e2) {
          debugPrint('Error showing error message: $e2');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _speak(String text) async {
    if (text.isEmpty) return;
    try {
      await flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS Error: $e');
    }
  }

  /// Handle swipe gesture to start quiz
  Future<void> _handleSwipeQuiz(QuizType type) async {
    if (!mounted) return;

    final noWordsMessage = AppLocalizations.of(
      context,
    )!.noWordsAvailableForQuiz;

    if (_allWords.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(noWordsMessage),
            backgroundColor: AppColors.lightGreen,
          ),
        );
      }
      return;
    }

    if (_wordStack.isEmpty || _currentCardIndex >= _wordStack.length) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(noWordsMessage),
            backgroundColor: AppColors.lightGreen,
          ),
        );
      }
      return;
    }

    final currentWordData = _wordStack[_currentCardIndex];
    final currentWord = Word.fromMap(currentWordData);

    if (!mounted) return;
    final quizVm = context.read<QuizViewModel>();
    final question = await quizVm.generateQuestion(
      currentWord,
      type,
      _allWords,
    );

    if (!mounted) return;
    if (question == null) {
      if (quizVm.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(quizVm.error!), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuizDialog(question: question),
    );

    // Quiz completed
    if (result == true && mounted) {
      // Refresh data if needed
    }
  }

  /// Move to next card (swipe down)
  void _moveToNextCard() {
    if (!mounted || _wordStack.isEmpty) return;

    if (_currentCardIndex < _wordStack.length - 1) {
      if (mounted) {
        setState(() {
          _currentCardIndex++;
        });
      }
      _cardAnimationController.forward(from: 0.0);
      debugPrint('Moved to next card. Index: $_currentCardIndex');
    } else if (_currentCardIndex == _wordStack.length - 1) {
      if (mounted) {
        setState(() {
          _currentCardIndex++;
        });
      }
      _cardAnimationController.forward(from: 0.0);
      debugPrint('Reached end of word stack');
    }
  }

  /// Refresh cards to show most recent words
  Future<void> _refreshCards() async {
    if (!mounted) return;

    try {
      final wordsListVm = context.read<WordsListViewModel>();
      await wordsListVm.loadWords();
      if (!mounted) return;

      final allWordsSorted = wordsListVm.getAllWordsSortedByTime();
      _allWords = allWordsSorted.map((w) => Word.fromMap(w)).toList();

      if (mounted) {
        setState(() {
          _wordStack = List<Map<String, dynamic>>.from(allWordsSorted);
          _currentCardIndex = 0;
          todaysWords = allWordsSorted;
          totalWordsCount = allWordsSorted.length;
        });
        _cardAnimationController.forward(from: 0.0);
      }
    } catch (e) {
      debugPrint('Error refreshing cards: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              AppLocalizations.of(context)!.exitApp,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ThemeColors.getTextColor(context),
              ),
            ),
            content: Text(
              AppLocalizations.of(context)!.exitConfirm,
              style: TextStyle(color: ThemeColors.getTextColor(context)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: TextStyle(
                    color: ThemeColors.getSecondaryTextColor(context),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  SystemNavigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: AppColors.darkGray,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.exit),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: ThemeColors.getBackgroundColor(context),
        appBar: AppBar(
          backgroundColor: ThemeColors.getBackgroundColor(context),
          elevation: 0,
          title: Text(
            AppLocalizations.of(context)!.home,
            style: TextStyle(
              color: ThemeColors.getTextColor(context),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Consumer<StreakViewModel>(
              builder: (context, streakVm, child) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeColors.getCardColor(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: AppColors.fireOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${streakVm.streak.currentStreak} ${AppLocalizations.of(context)!.day}',
                        style: TextStyle(
                          color: ThemeColors.getTextColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.settings,
                color: ThemeColors.getTextColor(context),
              ),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _loadData,
                    child: SafeArea(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildCardStack(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  if (isLoading)
                    ReusableLoadingOverlay(
                      isLoading: true,
                      child: const SizedBox.shrink(),
                    ),
                  _buildCurvedFABs(),
                ],
              ),
            ),
            // Ad Banner at bottom
            const AdBannerWidget(margin: EdgeInsets.symmetric(vertical: 8)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardStack() {
    if (_wordStack.isEmpty) {
      return _buildEmptyCardState();
    }

    if (_currentCardIndex >= _wordStack.length || _currentCardIndex < 0) {
      return _buildNoMoreWordsState();
    }

    // Safety check for word data
    final wordData = _wordStack[_currentCardIndex];
    if (wordData.isEmpty) {
      return _buildEmptyCardState();
    }

    // Show single word card
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _buildWordCard(wordData),
      ),
    );
  }

  Widget _buildWordCard(Map<String, dynamic> wordData) {
    // Extract word data
    final wordText = wordData['word']?.toString() ?? '';
    final meaning = wordData['meaning']?.toString() ?? '';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: (details) {
        // Swipe Up - Quiz (Meaning) - negative velocity means upward
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -200) {
          _handleSwipeQuiz(QuizType.meaning);
        }
        // Swipe Down - Next Card - positive velocity means downward
        else if (details.primaryVelocity != null &&
            details.primaryVelocity! > 200) {
          _moveToNextCard();
        }
      },
      onHorizontalDragEnd: (details) {
        // Swipe Left - Quiz (Synonym) - negative velocity means leftward
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -200) {
          _handleSwipeQuiz(QuizType.synonym);
        }
        // Swipe Right - Quiz (Antonym) - positive velocity means rightward
        else if (details.primaryVelocity != null &&
            details.primaryVelocity! > 200) {
          _handleSwipeQuiz(QuizType.antonym);
        }
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380, minHeight: 400),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: ThemeColors.getCardColor(context),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.15),
                blurRadius: 28,
                offset: const Offset(0, 10),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: SizedBox(
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with refresh button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.todayWords,
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeColors.getTextColor(context),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: ThemeColors.getSecondaryTextColor(context),
                          size: 20,
                        ),
                        onPressed: _refreshCards,
                        tooltip: 'Refresh to most recent',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Word
                  Text(
                    wordText.isNotEmpty
                        ? wordText
                        : AppLocalizations.of(context)!.noWordsToday,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.getTextColor(context),
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Meaning
                  Text(
                    meaning.isNotEmpty
                        ? meaning
                        : AppLocalizations.of(context)!.addFirstWord,
                    style: TextStyle(
                      fontSize: 16,
                      color: ThemeColors.getSecondaryTextColor(context),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Listen Button - FloatingActionButton style
                  Center(
                    child: FloatingActionButton.extended(
                      heroTag: 'listen_button',
                      onPressed: wordText.isNotEmpty
                          ? () => _speak(wordText)
                          : null,
                      backgroundColor: ThemeColors.getButtonColor(context),
                      foregroundColor: AppColors.darkGray,
                      icon: const Icon(Icons.volume_up_rounded, size: 20),
                      label: Text(
                        AppLocalizations.of(context)!.listen,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  // Swipe instructions
                  if (wordText.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSwipeHint(
                          context: context,
                          icon: Icons.arrow_upward_rounded,
                          label: 'Quiz',
                          color: ThemeColors.getButtonColor(context),
                        ),
                        const SizedBox(width: 16),
                        _buildSwipeHint(
                          context: context,
                          icon: Icons.arrow_back_rounded,
                          label: 'Synonym',
                          color: ThemeColors.getButtonColor(context),
                        ),
                        const SizedBox(width: 16),
                        _buildSwipeHint(
                          context: context,
                          icon: Icons.arrow_forward_rounded,
                          label: 'Antonym',
                          color: ThemeColors.getButtonColor(context),
                        ),
                        const SizedBox(width: 16),
                        _buildSwipeHint(
                          context: context,
                          icon: Icons.arrow_downward_rounded,
                          label: 'Next',
                          color: ThemeColors.getButtonColor(context),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeHint({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: ThemeColors.getSecondaryTextColor(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCardState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: ThemeColors.getCardColor(context),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book_outlined,
                  size: 64,
                  color: ThemeColors.getSecondaryTextColor(context),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.noWordsToday,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.addFirstWord,
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeColors.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoMoreWordsState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: ThemeColors.getCardColor(context),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 25,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.todayWords,
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeColors.getSecondaryTextColor(context),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: ThemeColors.getSecondaryTextColor(context),
                      size: 20,
                    ),
                    onPressed: _refreshCards,
                    tooltip: 'Refresh to most recent',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: ThemeColors.getPrimaryColor(context),
              ),
              const SizedBox(height: 16),
              Text(
                'No More Words',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.getTextColor(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ve viewed all words!',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeColors.getSecondaryTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FloatingActionButton.extended(
                heroTag: 'add_word_empty',
                onPressed: () async {
                  await context.push('/add-word');
                  _refreshData();
                },
                backgroundColor: ThemeColors.getButtonColor(context),
                foregroundColor: AppColors.darkGray,
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context)!.addWord),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurvedFABs() {
    return Positioned(
      right: 20,
      bottom: 24,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildCurvedFAB(
              heroTag: 'review_fab',
              icon: Icons.access_time_rounded,
              label: AppLocalizations.of(context)!.review,
              onTap: () async {
                await context.push('/list');
                _refreshData();
              },
            ),
            const SizedBox(height: 16),
            _buildCurvedFAB(
              heroTag: 'add_word_fab',
              icon: Icons.add_rounded,
              label: AppLocalizations.of(context)!.addWord,
              onTap: () async {
                await context.push('/add-word');
                _refreshData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurvedFAB({
    required String heroTag,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return FloatingActionButton.extended(
      heroTag: heroTag,
      onPressed: onTap,
      backgroundColor: ThemeColors.getButtonColor(context),
      foregroundColor: AppColors.darkGray,
      icon: Icon(icon, size: 22),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    );
  }
}
