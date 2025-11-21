import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:word_master/core/utils/app_colors.dart';
import 'package:word_master/core/utils/theme_provider.dart';
import '../viewmodel/streak_vm.dart';
import '../viewmodel/xp_vm.dart';
import '../core/repositories/word_repository.dart';

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
      await streakVm.loadStreak();

      final xpVm = context.read<XPViewModel>();
      await xpVm.loadXP();

      final wordRepo = context.read<WordRepository>();
      final words = await wordRepo.getTodaysWords();
      final wordsCount = await wordRepo.getWordsCount();

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
            content: Text('Failed to load data: ${e.toString()}'),
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

  Future<bool> _onWillPop() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Exit App',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ThemeColors.getTextColor(context),
              ),
            ),
            content: Text(
              'Are you sure you want to exit Word Master?',
              style: TextStyle(color: ThemeColors.getTextColor(context)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
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
                child: const Text('Exit'),
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
            'Home ',
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
                        '${streakVm.streak.currentStreak} day',
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
            // More Options Button
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: ThemeColors.getTextColor(context),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'theme':
                        themeProvider.toggleTheme();
                        break;
                      case 'about':
                        context.push('/about');
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'theme',
                      child: Row(
                        children: [
                          Icon(
                            themeProvider.isDarkMode
                                ? Icons.light_mode
                                : Icons.dark_mode,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            themeProvider.isDarkMode
                                ? 'Light Mode'
                                : 'Dark Mode',
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'about',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline),
                          SizedBox(width: 8),
                          Text('About Word Master'),
                        ],
                      ),
                    ),
                  ],
                );
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
                // Today's Word Card
                Container(
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
                        "Today's word",
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  todaysWords.isNotEmpty
                                      ? todaysWords[0]['word'] ?? 'No word'
                                      : 'No words today',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColors.getTextColor(context),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  todaysWords.isNotEmpty
                                      ? todaysWords[0]['meaning'] ??
                                            'No meaning available'
                                      : 'You have no added words today',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ThemeColors.getSecondaryTextColor(
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
                                  ? () => _speak(todaysWords[0]['word'] ?? '')
                                  : null,
                              icon: const Icon(Icons.volume_up),
                              label: const Text('Listen'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ThemeColors.getTextColor(
                                  context,
                                ),
                                side: BorderSide(
                                  color: ThemeColors.getBorderColor(context),
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
                    ],
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
                                  color: ThemeColors.getPrimaryColor(context),
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
                                            color: ThemeColors.getPrimaryColor(
                                              context,
                                            ),
                                            isCompact: true,
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
                                        color: ThemeColors.getPrimaryColor(
                                          context,
                                        ),
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.local_fire_department,
                                    value: streakVm.streak.currentStreak
                                        .toString(),
                                    label: 'Day streak',
                                    color: ThemeColors.getPrimaryColor(context),
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
                                        color: ThemeColors.getPrimaryColor(
                                          context,
                                        ),
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
                                    color: ThemeColors.getPrimaryColor(context),
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
                                  label: 'Add Word',
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
                              label: 'Add Word',
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
                  hintText: 'Search words...',
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
                  _buildFilterChip('All', isSelected: true),
                  const SizedBox(width: 8),
                  _buildFilterChip('New', isSelected: false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Mastered', isSelected: false),
                ],
              ),

              const SizedBox(height: 16),

              // Your Library
              const Text(
                "Your Library",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
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
                        level: 'Lv ${word['level'] ?? 1}',
                        lastReviewed: 'Last reviewed 2d ago',
                      ),
                    )
              else
                _buildWordCard(
                  word: 'Ebullient',
                  definition: 'Last reviewed 2d ago • Syn ✓ • Ant ✓',
                  level: 'Lv 3',
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
            child: const Center(
              child: CircularProgressIndicator(),
            ),
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
    required Color color,
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      constraints: const BoxConstraints(minWidth: 80, maxWidth: 120),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: ThemeColors.getTextColor(context),
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
                color: ThemeColors.getTextColor(context),
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
                color: ThemeColors.getSecondaryTextColor(context),
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
