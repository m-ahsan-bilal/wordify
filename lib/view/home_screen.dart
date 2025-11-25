import 'dart:math';
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
import '../core/repositories/word_repository.dart';
import '../core/repositories/quiz_repository.dart';
import '../core/model/word_model.dart';
import '../core/model/quiz_model.dart';
import 'widgets/quiz_dialog.dart';
import '../l10n/app_localizations.dart';

/// Home Screen - Uses StreakViewModel and WordRepository
/// Follows MVVM pattern: UI talks only to ViewModels/Repositories
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> todaysWords = [];
  int streak = 0;
  int totalWordsCount = 0;
  bool isLoading = false;
  bool _hasLoadedInitialData = false;
  final flutterTts = FlutterTts();
  List<Word> _allWords = [];
  final _random = Random(); // For random word selection
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only refresh if we've loaded initial data (to avoid duplicate loads)
    if (_hasLoadedInitialData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshData();
      });
    }
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

      final wordRepo = context.read<WordRepository>();
      final words = await wordRepo.getTodaysWords();
      final wordsCount = await wordRepo.getWordsCount();

      // Load all words for quiz generation
      final allWordsData = await wordRepo.getAllWords();
      _allWords = allWordsData.map((w) => Word.fromMap(w)).toList();

      // Sort words by dateAdded to get the most recent first
      final sortedWords = List<Map<String, dynamic>>.from(words);
      sortedWords.sort((a, b) {
        final dateA = a['dateAdded'] as String?;
        final dateB = b['dateAdded'] as String?;

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;

        try {
          final parsedDateA = DateTime.parse(dateA);
          final parsedDateB = DateTime.parse(dateB);
          // Sort in descending order (most recent first)
          return parsedDateB.compareTo(parsedDateA);
        } catch (e) {
          return 0;
        }
      });

      if (mounted) {
        setState(() {
          todaysWords = sortedWords;
          totalWordsCount = wordsCount;
          _hasLoadedInitialData = true;
        });
        // Debug: Print loaded words with their timestamps
        debugPrint(
          'Loaded ${sortedWords.length} words today (latest first): ${sortedWords.map((w) => '${w['word']} (${w['dateAdded']})').join(', ')}',
        );
        debugPrint('Total words count: $wordsCount');
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
          _hasLoadedInitialData = true;
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

    // Get words that should be quizzed (cycles through all words)
    final quizRepository = context.read<QuizRepository>();
    final wordsToQuiz = await quizRepository.getWordsToQuiz(_allWords);

    if (wordsToQuiz.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noWordsAvailableForQuiz),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Randomly select a word from the available words
    final word = wordsToQuiz[_random.nextInt(wordsToQuiz.length)];

    final quizVm = context.read<QuizViewModel>();
    final question = await quizVm.generateQuestion(word, type, _allWords);

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
                    // Today's Word Card with Swipe Gestures
                    GestureDetector(
                      onVerticalDragEnd: (details) {
                        // Swipe Up - lower threshold for better detection
                        if (details.primaryVelocity != null &&
                            details.primaryVelocity! < -300) {
                          _handleSwipeQuiz(QuizType.meaning);
                        }
                      },
                      onHorizontalDragEnd: (details) {
                        // Swipe Left - lower threshold
                        if (details.primaryVelocity != null &&
                            details.primaryVelocity! < -300) {
                          _handleSwipeQuiz(QuizType.synonym);
                        }
                        // Swipe Right - lower threshold
                        if (details.primaryVelocity != null &&
                            details.primaryVelocity! > 300) {
                          _handleSwipeQuiz(QuizType.antonym);
                        }
                      },
                      // Also handle drag updates for better feedback
                      onVerticalDragUpdate: (details) {
                        // Optional: Add visual feedback during drag
                      },
                      onHorizontalDragUpdate: (details) {
                        // Optional: Add visual feedback during drag
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: ThemeColors.getCardColor(context),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.todayWords,
                              style: TextStyle(
                                fontSize: 16,
                                color: ThemeColors.getTextColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        todaysWords.isNotEmpty
                                            ? todaysWords[0]['word'] ??
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.word
                                            : AppLocalizations.of(
                                                context,
                                              )!.noWordsToday,
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: ThemeColors.getTextColor(
                                            context,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        todaysWords.isNotEmpty
                                            ? todaysWords[0]['meaning'] ??
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.meaning
                                            : AppLocalizations.of(
                                                context,
                                              )!.addFirstWord,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              ThemeColors.getSecondaryTextColor(
                                                context,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Flexible(
                                  child: OutlinedButton.icon(
                                    onPressed: todaysWords.isNotEmpty
                                        ? () => _speak(
                                            todaysWords[0]['word'] ?? '',
                                          )
                                        : null,
                                    icon: const Icon(Icons.volume_up),
                                    label: Text(
                                      AppLocalizations.of(context)!.listen,
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: ThemeColors.getTextColor(
                                        context,
                                      ),
                                      side: BorderSide(
                                        color: ThemeColors.getBorderColor(
                                          context,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                            if (_allWords.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.swipe_up,
                                        size: 14,
                                        color:
                                            ThemeColors.getSecondaryTextColor(
                                              context,
                                            ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '↑ ${AppLocalizations.of(context)!.meaning}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              ThemeColors.getSecondaryTextColor(
                                                context,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.swipe_left,
                                        size: 14,
                                        color:
                                            ThemeColors.getSecondaryTextColor(
                                              context,
                                            ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '← ${AppLocalizations.of(context)!.synonym}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              ThemeColors.getSecondaryTextColor(
                                                context,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.swipe_right,
                                        size: 14,
                                        color:
                                            ThemeColors.getSecondaryTextColor(
                                              context,
                                            ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '→ ${AppLocalizations.of(context)!.antonym}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              ThemeColors.getSecondaryTextColor(
                                                context,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Stats Cards
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ThemeColors.getCardColor(context),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Consumer<StreakViewModel>(
                        builder: (context, streakVm, child) {
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              // Use different layouts based on available width
                              if (constraints.maxWidth < 350) {
                                // Stack vertically on very small screens
                                return Column(
                                  children: [
                                    _buildStatCard(
                                      icon: Icons.local_fire_department,
                                      value: streakVm.streak.currentStreak
                                          .toString(),
                                      label: 'Day streak',
                                      isCompact: true,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Consumer<XPViewModel>(
                                            builder: (context, xpVm, child) {
                                              return _buildStatCard(
                                                icon: Icons.stars,
                                                value: xpVm
                                                    .getXPDisplayText()
                                                    .replaceAll(' XP', ''),
                                                label: 'XP',
                                                isCompact: true,
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildStatCard(
                                            icon: Icons.today,
                                            value: todaysWords.length
                                                .toString(),
                                            label: 'Today',
                                            isCompact: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              } else {
                                // Use row layout for larger screens
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        icon: Icons.local_fire_department,
                                        value: streakVm.streak.currentStreak
                                            .toString(),
                                        label: 'Day streak',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Consumer<XPViewModel>(
                                        builder: (context, xpVm, child) {
                                          return _buildStatCard(
                                            icon: Icons.stars,
                                            value: xpVm
                                                .getXPDisplayText()
                                                .replaceAll(' XP', ''),
                                            label: 'XP',
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard(
                                        icon: Icons.today,
                                        value: todaysWords.length.toString(),
                                        label: 'Today',
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quick Actions
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 400) {
                          // Stack actions vertically on small screens
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(
                                      icon: Icons.add_circle_outline,
                                      label: AppLocalizations.of(
                                        context,
                                      )!.addWord,
                                      onTap: () async {
                                        await context.push('/add-word');
                                        // Refresh data when returning from add word screen
                                        _refreshData();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: _buildActionButton(
                                  icon: Icons.access_time,
                                  label: 'Review',
                                  onTap: () async {
                                    await context.push('/list');
                                    // Refresh data when returning from word list
                                    _refreshData();
                                  },
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Use row layout for larger screens
                          return Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.add_circle_outline,
                                  label: AppLocalizations.of(context)!.addWord,
                                  onTap: () async {
                                    await context.push('/add-word');
                                    // Refresh data when returning from add word screen
                                    _refreshData();
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.access_time,
                                  label: 'Review',
                                  onTap: () async {
                                    await context.push('/list');
                                    // Refresh data when returning from word list
                                    _refreshData();
                                  },
                                ),
                              ),
                              // Expanded(
                              //   child: _buildActionButton(
                              //     icon: Icons.auto_awesome,
                              //     label: 'Start Quiz',
                              //     onTap: () {
                              //       // TODO: Navigate to quiz
                              //     },
                              //   ),
                              // ),
                              // const SizedBox(width: 12),
                              // Expanded(
                              //   child: _buildActionButton(
                              //     icon: Icons.access_time,
                              //     label: 'Review',
                              //     onTap: () => context.push('/list'),
                              //   ),
                              // ),
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 24),
                    /*

              // Today's Goal
              const Text(
                "Today's Goal",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.progressGray,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '12/20 XP • Keep it up!',
                style: TextStyle(color: AppColors.lightGray, fontSize: 14),
              ),

              const SizedBox(height: 24),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchWords,
                  hintStyle: const TextStyle(color: AppColors.lightGray),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.lightGray,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune, color: AppColors.lightGray),
                    onPressed: () {
                      // TODO: Open filters
                    },
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 16),

              // Filter Chips
              Row(
                children: [
                  _buildFilterChip(AppLocalizations.of(context)!.all, isSelected: true),
                  const SizedBox(width: 8),
                  _buildFilterChip(AppLocalizations.of(context)!.newWords, isSelected: false),
                  const SizedBox(width: 8),
                  _buildFilterChip(AppLocalizations.of(context)!.mastered, isSelected: false),
                ],
              ),

              const SizedBox(height: 16),

              // Your Library
              Text(
                AppLocalizations.of(context)!.yourLibrary,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.getTextColor(context),
                ),
              ),
              const SizedBox(height: 12),

              // Word List
              if (todaysWords.isNotEmpty)
                ...todaysWords
                    .take(3)
                    .map(
                      (word) => _buildWordCard(
                        word: word['word'] ?? '',
                        definition: word['definition'] ?? '',
                        level: AppLocalizations.of(context)!.levelLabelWithNumber(word['level'] ?? 1),
                        lastReviewed: 'Last reviewed 2d ago',
                      ),
                    )
              else
                _buildWordCard(
                  word: 'Ebullient',
                  definition: 'Last reviewed 2d ago • Syn ✓ • Ant ✓',
                  level: AppLocalizations.of(context)!.levelLabelWithNumber(3),
                  lastReviewed: '',
                  levelColor: AppColors.lightGreen,
                ),
          

          */
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
          ],
        ),
      ), // End of Scaffold
    ); // End of PopScope
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    bool isCompact = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      constraints: const BoxConstraints(minWidth: 80, maxWidth: 120),
      decoration: BoxDecoration(
        // Use splash screen logo container color
        color: ThemeColors.getStatCardColor(context),
        borderRadius: BorderRadius.circular(16),
        // Add subtle shadow for depth
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            // Use splash screen icon color
            color: ThemeColors.getStatCardIconColor(context),
            size: isCompact ? 20 : 24,
          ),
          SizedBox(height: isCompact ? 4 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isCompact ? 20 : 24,
                fontWeight: FontWeight.bold,
                // Use splash screen text color
                color: ThemeColors.getStatCardIconColor(context),
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isCompact ? 10 : 12,
                color: isDark
                    ? ThemeColors.getSecondaryTextColor(context)
                    : AppColors.lightGray,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: ThemeColors.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: ThemeColors.getTextColor(context), size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ThemeColors.getTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? ThemeColors.getPrimaryColor(context)
            : ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.darkGray,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildWordCard({
    required String word,
    required String definition,
    required String level,
    required String lastReviewed,
    Color? levelColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.bookmark_border, color: AppColors.darkGray),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lastReviewed.isNotEmpty ? lastReviewed : definition,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.lightGray,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: levelColor ?? AppColors.lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              level,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.lightGray),
        ],
      ),
    );
  }
}
