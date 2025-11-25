import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../core/model/word_model.dart';
import '../core/repositories/word_repository.dart';
import '../core/utils/app_colors.dart';
import '../viewmodel/add_word_vm.dart';
import '../l10n/app_localizations.dart';

/// Word Details Screen - Uses AddWordViewModel for updates/deletes
/// Follows MVVM pattern: UI talks only to ViewModels
class WordDetailsScreen extends StatefulWidget {
  final int wordIndex;
  const WordDetailsScreen({super.key, required this.wordIndex});

  @override
  State<WordDetailsScreen> createState() => _WordDetailsScreenState();
}

class _WordDetailsScreenState extends State<WordDetailsScreen> {
  late Map<String, dynamic> wordData;
  bool isEditing = false;
  final flutterTts = FlutterTts();
  bool isLoading = true;

  // Controllers for editing
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _synonymsController = TextEditingController();
  final _antonymsController = TextEditingController();
  final _sentenceController = TextEditingController();
  final _sourceController = TextEditingController();

  // Focus nodes for keyboard navigation
  final _wordFocus = FocusNode();
  final _meaningFocus = FocusNode();
  final _synonymsFocus = FocusNode();
  final _antonymsFocus = FocusNode();
  final _sentenceFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadWord();
  }

  Future<void> _loadWord() async {
    final wordRepo = context.read<WordRepository>();
    final word = await wordRepo.getWord(widget.wordIndex);

    if (word != null && mounted) {
      setState(() {
        wordData = Map<String, dynamic>.from(word);
        isLoading = false;

        // Initialize controllers with current data
        _wordController.text = wordData['word'] ?? '';
        _meaningController.text = wordData['meaning'] ?? '';
        _synonymsController.text = wordData['synonyms'] ?? '';
        _antonymsController.text = wordData['antonyms'] ?? '';
        _sentenceController.text = wordData['sentence'] ?? '';
        _sourceController.text = wordData['source'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _synonymsController.dispose();
    _antonymsController.dispose();
    _sentenceController.dispose();
    _sourceController.dispose();

    _wordFocus.dispose();
    _meaningFocus.dispose();
    _synonymsFocus.dispose();
    _antonymsFocus.dispose();
    _sentenceFocus.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() => isEditing = !isEditing);
  }

  void _speak(String text) async {
    if (text.isEmpty) return;
    try {
      await flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS Error: $e');
    }
  }

  void _saveChanges() async {
    HapticFeedback.lightImpact();

    // Create updated word from controllers
    final updatedWord = Word(
      word: _wordController.text.trim(),
      meaning: _meaningController.text.trim(),
      synonyms: _synonymsController.text.trim(),
      antonyms: _antonymsController.text.trim(),
      sentence: _sentenceController.text.trim(),
      source: _sourceController.text.trim(),
      dateAdded: DateTime.parse(wordData['dateAdded']), // Keep original date
    );

    final viewModel = context.read<AddWordViewModel>();
    final result = await viewModel.updateWord(widget.wordIndex, updatedWord);

    if (!mounted) return;

    if (result) {
      setState(() {
        isEditing = false;
        // Update local data
        wordData = updatedWord.toMap();
      });

      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.wordUpdatedSuccessfully),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  viewModel.error ??
                      AppLocalizations.of(context)!.failedToSaveChanges,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _deleteWord() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteWord),
        content: Text(AppLocalizations.of(context)!.deleteWordConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final viewModel = context.read<AddWordViewModel>();
    final success = await viewModel.deleteWord(widget.wordIndex);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.wordDeleted)),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.error ?? AppLocalizations.of(context)!.failedToDeleteWord,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
            AppLocalizations.of(context)!.loading,
            style: TextStyle(
              color: ThemeColors.getTextColor(context),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: ThemeColors.getTextColor(context),
          ),
        ),
      );
    }

    final word = Word.fromMap(wordData);

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
          isEditing
              ? AppLocalizations.of(context)!.editWord
              : wordData['word'] ?? '',
          style: TextStyle(
            color: ThemeColors.getTextColor(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (!isEditing) ...[
            IconButton(
              icon: Icon(
                Icons.volume_up,
                color: ThemeColors.getTextColor(context),
              ),
              onPressed: () => _speak(wordData['word'] ?? ''),
              tooltip: AppLocalizations.of(context)!.listenTooltip,
            ),
            IconButton(
              icon: Icon(Icons.edit, color: ThemeColors.getTextColor(context)),
              onPressed: _toggleEdit,
              tooltip: AppLocalizations.of(context)!.editWordTooltip,
            ),
          ] else ...[
            IconButton(
              icon: Icon(Icons.close, color: ThemeColors.getTextColor(context)),
              onPressed: () {
                setState(() => isEditing = false);
                // Reset controllers to original values
                _wordController.text = wordData['word'] ?? '';
                _meaningController.text = wordData['meaning'] ?? '';
                _synonymsController.text = wordData['synonyms'] ?? '';
                _antonymsController.text = wordData['antonyms'] ?? '';
                _sentenceController.text = wordData['sentence'] ?? '';
                _sourceController.text = wordData['source'] ?? '';
              },
              tooltip: AppLocalizations.of(context)!.cancelTooltip,
            ),
          ],
        ],
      ),
      body: Consumer<AddWordViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (!isEditing) ...[
                    // View Mode - Word Header Card
                    _buildWordHeaderCard(word),
                    const SizedBox(height: 16),

                    // View Mode - Details Cards
                    _buildMeaningCard(word),
                    const SizedBox(height: 16),
                    _buildSynonymsAntonymsCard(word),
                    const SizedBox(height: 16),
                    _buildSentenceCard(word),
                    const SizedBox(height: 16),
                    _buildSourceCard(word),
                    const SizedBox(height: 16),
                    _buildStatsCard(word),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                  ] else ...[
                    // Edit Mode - Form
                    _buildEditForm(),
                  ],
                ],
              ),
              if (viewModel.isLoading)
                Container(
                  color: Colors.black26,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: ThemeColors.getTextColor(context),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // View Mode Components
  Widget _buildWordHeaderCard(Word word) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(24),
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
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  word.word,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.getTextColor(context),
                  ),
                ),
              ),
              _buildLevelBadge(word),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            word.reviewStatusText,
            style: TextStyle(
              fontSize: 14,
              color: ThemeColors.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _speak(word.word),
                  icon: const Icon(Icons.volume_up),
                  label: Text(AppLocalizations.of(context)!.listen),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ThemeColors.getTextColor(context),
                    side: BorderSide(
                      color: ThemeColors.getBorderColor(context),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeaningCard(Word word) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.meaning,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            word.meaning.isNotEmpty
                ? word.meaning
                : AppLocalizations.of(context)!.noMeaningProvided,
            style: TextStyle(
              fontSize: 14,
              color: word.meaning.isNotEmpty
                  ? ThemeColors.getTextColor(context)
                  : ThemeColors.getSecondaryTextColor(context),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynonymsAntonymsCard(Word word) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Synonyms Section
          Text(
            AppLocalizations.of(context)!.synonyms,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          if (word.synonyms.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: word.synonyms.split(',').map((synonym) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeColors.getPrimaryColor(
                      context,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ThemeColors.getPrimaryColor(
                        context,
                      ).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    synonym.trim(),
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.getPrimaryColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            )
          else
            Text(
              AppLocalizations.of(context)!.noSynonymsAdded,
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.getSecondaryTextColor(context),
              ),
            ),

          const SizedBox(height: 20),

          // Antonyms Section
          Text(
            AppLocalizations.of(context)!.antonyms,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          if (word.antonyms.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: word.antonyms.split(',').map((antonym) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    antonym.trim(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            )
          else
            Text(
              AppLocalizations.of(context)!.noAntonymsAdded,
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.getSecondaryTextColor(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSentenceCard(Word word) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.exampleSentence,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeColors.getSecondaryColor(context).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              word.sentence.isNotEmpty
                  ? '"${word.sentence}"'
                  : AppLocalizations.of(context)!.noExampleSentenceProvided,
              style: TextStyle(
                fontSize: 14,
                color: word.sentence.isNotEmpty
                    ? ThemeColors.getTextColor(context)
                    : ThemeColors.getSecondaryTextColor(context),
                fontStyle: word.sentence.isNotEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceCard(Word word) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.source,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _getSourceIcon(word.source),
                color: ThemeColors.getSecondaryTextColor(context),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                word.source.isNotEmpty
                    ? word.source
                    : AppLocalizations.of(context)!.noSourceSpecified,
                style: TextStyle(
                  fontSize: 14,
                  color: word.source.isNotEmpty
                      ? ThemeColors.getTextColor(context)
                      : ThemeColors.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Word word) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.wordStatistics,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  AppLocalizations.of(context)!.xpEarnedStat,
                  '${word.xp}',
                  Icons.stars,
                  ThemeColors.getPrimaryColor(context),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  AppLocalizations.of(context)!.levelStat,
                  '${word.level}',
                  Icons.trending_up,
                  ThemeColors.getPrimaryColor(context),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  AppLocalizations.of(context)!.completeness,
                  '${_getCompletenessPercentage(word)}%',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ThemeColors.getTextColor(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: ThemeColors.getSecondaryTextColor(context),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _toggleEdit,
            icon: const Icon(Icons.edit),
            label: Text(AppLocalizations.of(context)!.editWord),
            style: OutlinedButton.styleFrom(
              foregroundColor: ThemeColors.getTextColor(context),
              side: BorderSide(color: ThemeColors.getBorderColor(context)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _deleteWord,
            icon: const Icon(Icons.delete),
            label: Text(AppLocalizations.of(context)!.delete),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelBadge(Word word) {
    if (word.isMastered) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          AppLocalizations.of(context)!.mastered,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
    }

    Color levelColor;
    switch (word.level) {
      case 1:
        levelColor = Colors.orange;
        break;
      case 2:
        levelColor = Colors.blue;
        break;
      case 3:
        levelColor = Colors.green;
        break;
      default:
        levelColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: levelColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: levelColor.withOpacity(0.3)),
      ),
      child: Text(
        AppLocalizations.of(context)!.levelLabelWithNumber(word.level),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: levelColor,
        ),
      ),
    );
  }

  // Edit Mode Component
  Widget _buildEditForm() {
    return Column(
      children: [
        // Word Input
        _buildEditSection(
          AppLocalizations.of(context)!.word,
          _wordController,
          _wordFocus,
          _meaningFocus,
          AppLocalizations.of(context)!.enterTheWord,
          isRequired: true,
        ),
        const SizedBox(height: 16),

        // Meaning Input
        _buildEditSection(
          AppLocalizations.of(context)!.meaning,
          _meaningController,
          _meaningFocus,
          _synonymsFocus,
          AppLocalizations.of(context)!.enterTheMeaning,
          maxLines: 3,
          isRequired: true,
        ),
        const SizedBox(height: 16),

        // Synonyms Input
        _buildEditSection(
          AppLocalizations.of(context)!.synonyms,
          _synonymsController,
          _synonymsFocus,
          _antonymsFocus,
          AppLocalizations.of(context)!.enterSynonymsComma,
        ),
        const SizedBox(height: 16),

        // Antonyms Input
        _buildEditSection(
          AppLocalizations.of(context)!.antonyms,
          _antonymsController,
          _antonymsFocus,
          _sentenceFocus,
          AppLocalizations.of(context)!.enterAntonymsComma,
        ),
        const SizedBox(height: 16),

        // Sentence Input
        _buildEditSection(
          AppLocalizations.of(context)!.exampleSentence,
          _sentenceController,
          _sentenceFocus,
          null,
          AppLocalizations.of(context)!.sentenceHint,
          maxLines: 3,
        ),
        const SizedBox(height: 16),

        // Source Input
        _buildEditSection(
          AppLocalizations.of(context)!.source,
          _sourceController,
          null,
          null,
          AppLocalizations.of(context)!.whereDidYouLearnThisWordShort,
        ),
        const SizedBox(height: 32),

        // Save and Cancel Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => isEditing = false);
                  // Reset controllers
                  _wordController.text = wordData['word'] ?? '';
                  _meaningController.text = wordData['meaning'] ?? '';
                  _synonymsController.text = wordData['synonyms'] ?? '';
                  _antonymsController.text = wordData['antonyms'] ?? '';
                  _sentenceController.text = wordData['sentence'] ?? '';
                  _sourceController.text = wordData['source'] ?? '';
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: ThemeColors.getSecondaryTextColor(context),
                  side: BorderSide(color: ThemeColors.getBorderColor(context)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.saveChanges),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditSection(
    String title,
    TextEditingController controller,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    String hint, {
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.getTextColor(context),
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            textInputAction: nextFocus != null
                ? TextInputAction.next
                : TextInputAction.done,
            onFieldSubmitted: (_) => nextFocus?.requestFocus(),
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: ThemeColors.getSecondaryTextColor(
                  context,
                ).withOpacity(0.7),
              ),
              filled: true,
              fillColor: ThemeColors.getSecondaryColor(
                context,
              ).withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(
              fontSize: 14,
              color: ThemeColors.getTextColor(context),
            ),
            validator: isRequired
                ? (v) => v == null || v.trim().isEmpty
                      ? AppLocalizations.of(context)!.thisFieldIsRequired
                      : null
                : null,
          ),
        ],
      ),
    );
  }

  // Helper Methods
  IconData _getSourceIcon(String source) {
    switch (source.toLowerCase()) {
      case 'book':
        return Icons.menu_book;
      case 'article':
        return Icons.article;
      case 'youtube':
        return Icons.play_circle_filled;
      case 'conversation':
        return Icons.chat_bubble;
      default:
        return Icons.source;
    }
  }

  int _getCompletenessPercentage(Word word) {
    int filledFields = 0;
    int totalFields = 5; // word, meaning, synonyms, antonyms, sentence

    if (word.word.isNotEmpty) filledFields++;
    if (word.meaning.isNotEmpty) filledFields++;
    if (word.synonyms.isNotEmpty) filledFields++;
    if (word.antonyms.isNotEmpty) filledFields++;
    if (word.sentence.isNotEmpty) filledFields++;

    return ((filledFields / totalFields) * 100).round();
  }
}
