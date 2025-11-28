import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:word_master/viewmodel/words_list_vm.dart';
import 'package:word_master/core/utils/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'widgets/ad_banner_widget.dart';
import 'widgets/reusable_filter_chip.dart';
import '../l10n/app_localizations.dart';

class WordsListScreen extends StatefulWidget {
  const WordsListScreen({super.key});

  @override
  State<WordsListScreen> createState() => _WordsListScreenState();
}

class _WordsListScreenState extends State<WordsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all'; // Internal key, not displayed
  String _searchQuery = '';

  // Filter keys for internal use
  static const String _filterAll = 'all';
  static const String _filterNew = 'new';

  @override
  void initState() {
    super.initState();
    // Load words after the first frame to avoid build-phase issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WordsListViewModel>().loadWords();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredWords(WordsListViewModel vm) {
    // Combine all words into a single list
    List<Map<String, dynamic>> allWords = [];
    allWords.addAll(vm.todaysWords);
    allWords.addAll(vm.yesterdaysWords);
    for (var words in vm.olderWords.values) {
      allWords.addAll(words);
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      allWords = allWords.where((word) {
        final wordText = (word['word'] ?? '').toString().toLowerCase();
        final meaning = (word['meaning'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return wordText.contains(query) || meaning.contains(query);
      }).toList();
    }

    // Apply category filter
    if (_selectedFilter == _filterNew) {
      // Filter words added in last 7 days
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      allWords = allWords.where((word) {
        final dateStr = word['dateAdded']?.toString();
        if (dateStr == null) return false;
        try {
          final date = DateTime.parse(dateStr);
          return date.isAfter(weekAgo);
        } catch (e) {
          return false;
        }
      }).toList();
    }
    // else: 'all' - no additional filtering

    // Sort by date (newest first)
    allWords.sort((a, b) {
      final dateA = a['dateAdded']?.toString();
      final dateB = b['dateAdded']?.toString();
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      try {
        return DateTime.parse(dateB).compareTo(DateTime.parse(dateA));
      } catch (e) {
        return 0;
      }
    });

    return allWords;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WordsListViewModel>();
    final filteredWords = _getFilteredWords(vm);
    final hasWords = filteredWords.isNotEmpty;

    return Scaffold(
      backgroundColor: ThemeColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeColors.getBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: ThemeColors.getTextColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.yourLibrary,
          style: TextStyle(
            color: ThemeColors.getTextColor(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => vm.loadWords(),
        child: Column(
          children: [
            // Search and Filter Section
            _buildSearchAndFilter(),

            // Words List
            Expanded(
              child: hasWords
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredWords.length,
                      itemBuilder: (context, index) {
                        return _buildModernWordCard(filteredWords[index]);
                      },
                    )
                  : _buildEmptyState(),
            ),
            // Ad Banner at bottom
            const AdBannerWidget(margin: EdgeInsets.symmetric(vertical: 8)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: ThemeColors.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchWords,
                hintStyle: TextStyle(
                  color: ThemeColors.getSecondaryTextColor(
                    context,
                  ).withValues(alpha: 0.7),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: ThemeColors.getSecondaryTextColor(context),
                ),

                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: TextStyle(
                fontSize: 16,
                color: ThemeColors.getTextColor(context),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Filter Chips
          Row(
            children: [
              _buildFilterChip(AppLocalizations.of(context)!.all),
              const SizedBox(width: 8),
              _buildFilterChip(AppLocalizations.of(context)!.newWords),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    // Map localized label to internal filter key
    String filterKey = _filterAll;
    if (label == AppLocalizations.of(context)!.newWords) {
      filterKey = _filterNew;
    }
    final isSelected = _selectedFilter == filterKey;
    return ReusableFilterChip(
      label: label,
      isSelected: isSelected,
      onTap: () {
        setState(() {
          // Map localized label to internal filter key
          if (label == AppLocalizations.of(context)!.newWords) {
            _selectedFilter = _filterNew;
          } else {
            _selectedFilter = _filterAll;
          }
        });
      },
    );
  }

  Widget _buildModernWordCard(Map<String, dynamic> word) {
    final vm = context.read<WordsListViewModel>();
    final wordIndex = word['index'] as int? ?? 0;
    final wordText = word['word']?.toString() ?? '';
    final meaning = word['meaning']?.toString() ?? '';

    // Use ViewModel methods for business logic
    final reviewStatus = vm.getWordReviewStatus(word);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/word-details', extra: wordIndex);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeColors.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Bookmark Icon
            Icon(
              Icons.bookmark_border,
              color: ThemeColors.getTextColor(context),
              size: 20,
            ),
            const SizedBox(width: 16),

            // Word Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Word
                  Text(
                    wordText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.getTextColor(context),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Meaning and Review Status
                  Text(
                    meaning.isNotEmpty
                        ? "$meaning • $reviewStatus"
                        : reviewStatus,
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.getSecondaryTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.chevron_right,
              color: ThemeColors.getSecondaryTextColor(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books,
            size: 80,
            color: ThemeColors.getSecondaryTextColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noWordsFound,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? AppLocalizations.of(context)!.tryAdjustingSearch
                : AppLocalizations.of(context)!.startAddingWords,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: ThemeColors.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
