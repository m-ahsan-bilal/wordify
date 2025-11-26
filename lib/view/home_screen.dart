import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:word_master/core/utils/app_colors.dart';
import '../viewmodel/streak_vm.dart';
import '../viewmodel/xp_vm.dart';
import '../viewmodel/quiz_vm.dart';
import '../viewmodel/words_list_vm.dart';
import '../core/model/word_model.dart';
import '../core/model/quiz_model.dart';
import 'widgets/quiz_dialog.dart';
import '../l10n/app_localizations.dart';

/// Home Screen - Uses StreakViewModel, XPViewModel, QuizViewModel, and WordsListViewModel
/// Follows MVVM pattern: UI talks only to ViewModels
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

  // Card stack state
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only refresh if we've loaded initial data (to avoid duplicate loads)
    // Removed automatic refresh to prevent infinite loops
    // Data will be refreshed when explicitly needed (pull to refresh, etc.)
  }

  /// Refresh data without showing loading state (for background updates)
  Future<void> _refreshData() async {
    if (!mounted || isLoading) return;
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
      final streakVm = context.read<StreakViewModel>();
      // Validate streak first (will reset if broken, then load)
      await streakVm.validateStreak();

      final xpVm = context.read<XPViewModel>();
      await xpVm.loadXP();

      // Use WordsListViewModel to get all words sorted by time
      final wordsListVm = context.read<WordsListViewModel>();
      await wordsListVm.loadWords();

      // Get all words sorted by time (most recent first)
      final allWordsSorted = wordsListVm.getAllWordsSortedByTime();

      // Load all words for quiz generation
      _allWords = allWordsSorted.map((w) => Word.fromMap(w)).toList();

      if (mounted) {
        // Check if words actually changed before updating
        final wordsChanged =
            _wordStack.length != allWordsSorted.length ||
            _wordStack.isEmpty ||
            !_areWordStacksEqual(_wordStack, allWordsSorted);

        setState(() {
          todaysWords = allWordsSorted; // Keep for compatibility
          totalWordsCount = allWordsSorted.length;

          // Always update word stack and reset to first card on refresh
          _wordStack = List<Map<String, dynamic>>.from(allWordsSorted);
          _currentCardIndex = 0; // Reset to first card when data is refreshed
        });

        // Debug: Print loaded words with their timestamps (only when changed)
        if (wordsChanged) {
          debugPrint(
            'Loaded ${allWordsSorted.length} words (latest first): ${allWordsSorted.take(5).map((w) => '${w['word']} (${w['dateAdded']})').join(', ')}',
          );
          debugPrint('Total words count: ${allWordsSorted.length}');
          debugPrint(
            'Word stack initialized with ${_wordStack.length} words, current index: $_currentCardIndex',
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.failedToLoadData}: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
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
      // Handle TTS errors gracefully
      debugPrint('TTS Error: $e');
    }
  }

  /// Handle swipe gesture to start quiz
  Future<void> _handleSwipeQuiz(QuizType type) async {
    if (_allWords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noWordsAvailableForQuiz),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Get current word from card stack
    if (_wordStack.isEmpty || _currentCardIndex >= _wordStack.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noWordsAvailableForQuiz),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final currentWordData = _wordStack[_currentCardIndex];
    final currentWord = Word.fromMap(currentWordData);

    final quizVm = context.read<QuizViewModel>();
    final question = await quizVm.generateQuestion(
      currentWord,
      type,
      _allWords,
    );

    if (question == null) {
      if (quizVm.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(quizVm.error!), backgroundColor: Colors.red),
        );
      }
      return;
    }

    // Show quiz dialog
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuizDialog(question: question),
    );

    // Refresh XP if answer was correct
    if (result == true) {
      final xpVm = context.read<XPViewModel>();
      await xpVm.loadXP();
    }
  }

  /// Move to next card (swipe down)
  void _moveToNextCard() {
    if (_wordStack.isEmpty) return;

    if (_currentCardIndex < _wordStack.length - 1) {
      // Move to next word in the list
      setState(() {
        _currentCardIndex++;
      });
      _cardAnimationController.forward(from: 0.0);
      debugPrint(
        'Moved to next card. Index: $_currentCardIndex, Word: ${_wordStack[_currentCardIndex]['word']}',
      );
    } else if (_currentCardIndex == _wordStack.length - 1) {
      // Move past the last card to show "no more words"
      setState(() {
        _currentCardIndex++;
      });
      _cardAnimationController.forward(from: 0.0);
      debugPrint('Reached end of word stack');
    }
  }

  /// Check if two word stacks are equal
  bool _areWordStacksEqual(
    List<Map<String, dynamic>> stack1,
    List<Map<String, dynamic>> stack2,
  ) {
    if (stack1.length != stack2.length) return false;
    for (int i = 0; i < stack1.length; i++) {
      final word1 = stack1[i]['word']?.toString() ?? '';
      final word2 = stack2[i]['word']?.toString() ?? '';
      if (word1 != word2) return false;
    }
    return true;
  }

  /// Refresh cards to show most recent words
  Future<void> _refreshCards() async {
    // Reload words from ViewModel
    final wordsListVm = context.read<WordsListViewModel>();
    await wordsListVm.loadWords();

    // Get updated words
    final allWordsSorted = wordsListVm.getAllWordsSortedByTime();

    // Also update _allWords for quiz generation
    _allWords = allWordsSorted.map((w) => Word.fromMap(w)).toList();

    setState(() {
      _wordStack = List<Map<String, dynamic>>.from(allWordsSorted);
      _currentCardIndex = 0; // Reset to first card
      todaysWords = allWordsSorted; // Update for compatibility
      totalWordsCount = allWordsSorted.length;
    });
    _cardAnimationController.forward(from: 0.0);
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
                  SystemNavigator.pop(); // Exit the app
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
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
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
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
            // Settings Button
            IconButton(
              icon: Icon(
                Icons.settings,
                color: ThemeColors.getTextColor(context),
              ),
              onPressed: () {
                context.push('/settings');
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _loadData,
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Tinder-style Card Stack
                    SizedBox(height: 500, child: _buildCardStack()),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Loading overlay
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
            // Curved Floating Action Buttons
            _buildCurvedFABs(),
          ],
        ),
      ), // End of Scaffold
    ); // End of PopScope
  }

  Widget _buildCardStack() {
    if (_wordStack.isEmpty) {
      return _buildEmptyCardState();
    }

    // Check if we've reached the last card
    if (_currentCardIndex >= _wordStack.length) {
      return _buildNoMoreWordsState();
    }

    // Only show the current card - clean single card view
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _buildWordCard(_wordStack[_currentCardIndex], isTopCard: true),
      ),
    );
  }

  Widget _buildWordCard(
    Map<String, dynamic> wordData, {
    required bool isTopCard,
  }) {
    final wordText = wordData['word']?.toString() ?? '';
    final meaning = wordData['meaning']?.toString() ?? '';

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (!isTopCard) return;
        // Swipe Up - Quiz (Meaning)
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -300) {
          _handleSwipeQuiz(QuizType.meaning);
        }
        // Swipe Down - Next Card
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          _moveToNextCard();
        }
      },
      onHorizontalDragEnd: (details) {
        if (!isTopCard) return;
        // Swipe Left - Quiz (Synonym)
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -300) {
          _handleSwipeQuiz(QuizType.synonym);
        }
        // Swipe Right - Quiz (Antonym)
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          _handleSwipeQuiz(QuizType.antonym);
        }
      },
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 380, minHeight: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            // Soft, subtle elevation
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
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
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: Colors.grey[400],
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
                // Word - Large, bold, prominent
                Text(
                  wordText.isNotEmpty
                      ? wordText
                      : AppLocalizations.of(context)!.noWordsToday,
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                // Meaning - Simple description
                Text(
                  meaning.isNotEmpty
                      ? meaning
                      : AppLocalizations.of(context)!.addFirstWord,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                // Listen Button - Simple, clean
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: wordText.isNotEmpty
                        ? () => _speak(wordText)
                        : null,
                    icon: Icon(
                      Icons.volume_up_rounded,
                      size: 20,
                      color: wordText.isNotEmpty
                          ? ThemeColors.getPrimaryColor(context)
                          : Colors.grey[400],
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.listen,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ThemeColors.getPrimaryColor(context),
                      side: BorderSide(
                        color: wordText.isNotEmpty
                            ? ThemeColors.getPrimaryColor(
                                context,
                              ).withOpacity(0.3)
                            : Colors.grey[300]!,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
              color: Colors.black.withOpacity(0.1),
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
              color: Colors.black.withOpacity(0.15),
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
              // Header with refresh button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.todayWords,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    onPressed: _refreshCards,
                    tooltip: 'Refresh to most recent',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Spacer(),
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
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () async {
                  await context.push('/add-word');
                  _refreshData();
                },
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context)!.addWord),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.getPrimaryColor(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
            // Review Button (top)
            _buildCurvedFAB(
              icon: Icons.access_time_rounded,
              label: 'Review',
              onTap: () async {
                await context.push('/list');
                _refreshData();
              },
            ),
            const SizedBox(height: 16),
            // Add Word Button (bottom)
            _buildCurvedFAB(
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
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ThemeColors.getPrimaryColor(context),
                ThemeColors.getPrimaryColor(context).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: ThemeColors.getPrimaryColor(context).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
