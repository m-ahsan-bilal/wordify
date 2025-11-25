// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/model/word_model.dart';
import '../core/utils/app_colors.dart';
import '../viewmodel/add_word_vm.dart';
import '../l10n/app_localizations.dart';

/// Add Word Screen - Uses AddWordViewModel to manage word addition
/// Follows MVVM pattern: UI talks only to ViewModel
class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _synonymsController = TextEditingController();
  final _antonymsController = TextEditingController();
  final _sentenceController = TextEditingController();

  // Focus nodes for keyboard navigation
  final _wordFocus = FocusNode();
  final _meaningFocus = FocusNode();
  final _synonymsFocus = FocusNode();
  final _antonymsFocus = FocusNode();
  final _sentenceFocus = FocusNode();

  // Selected source
  String _selectedSource = '';

  // Available sources - names are localized via ARB file
  List<Map<String, dynamic>> _getSources(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {'name': l10n.book, 'icon': Icons.menu_book, 'color': Colors.blue},
      {'name': l10n.article, 'icon': Icons.article, 'color': Colors.green},
      {
        'name': l10n.youtube,
        'icon': Icons.play_circle_filled,
        'color': Colors.red,
      },
      {
        'name': l10n.conversation,
        'icon': Icons.chat_bubble,
        'color': Colors.orange,
      },
      {'name': l10n.other, 'icon': Icons.more_horiz, 'color': Colors.grey},
    ];
  }

  @override
  void initState() {
    super.initState();
    // Auto-focus on word field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _wordFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _synonymsController.dispose();
    _antonymsController.dispose();
    _sentenceController.dispose();

    _wordFocus.dispose();
    _meaningFocus.dispose();
    _synonymsFocus.dispose();
    _antonymsFocus.dispose();
    _sentenceFocus.dispose();
    super.dispose();
  }

  void _saveWord() async {
    if (!_formKey.currentState!.validate()) return;

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    final word = Word(
      word: _wordController.text.trim(),
      meaning: _meaningController.text.trim(),
      synonyms: _synonymsController.text.trim(),
      antonyms: _antonymsController.text.trim(),
      sentence: _sentenceController.text.trim(),
      source: _selectedSource,
    );

    final viewModel = context.read<AddWordViewModel>();
    final result = await viewModel.addWord(word);

    if (!mounted) return;

    if (result.success) {
      // Show success feedback
      HapticFeedback.mediumImpact();

      final l10n = AppLocalizations.of(context)!;
      String message = l10n.addWordSuccess(word.xp);
      if (result.leveledUp) {
        message = l10n.addWordLevelUp(word.xp);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                result.leveledUp ? Icons.celebration : Icons.check_circle,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: result.leveledUp ? Colors.purple : Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: result.leveledUp ? 4 : 2),
        ),
      );

      // Clear form for next word
      _clearForm();

      // Auto-focus on word field for next entry
      _wordFocus.requestFocus();
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
                      AppLocalizations.of(context)!.failedToAddWord,
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

  void _clearForm() {
    _formKey.currentState!.reset();
    _wordController.clear();
    _meaningController.clear();
    _synonymsController.clear();
    _antonymsController.clear();
    _sentenceController.clear();
    setState(() {
      _selectedSource = '';
    });
  }

  @override
  Widget build(BuildContext context) {
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
          AppLocalizations.of(context)!.addNewWord,
          style: TextStyle(
            color: ThemeColors.getTextColor(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: ThemeColors.getTextColor(context)),
            onPressed: _clearForm,
            tooltip: AppLocalizations.of(context)!.clearForm,
          ),
        ],
      ),
      body: Consumer<AddWordViewModel>(
        builder: (context, viewModel, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Word Input Section
                _buildWordSection(),
                const SizedBox(height: 24),

                // Meanings Section
                _buildMeaningsSection(),
                const SizedBox(height: 24),

                // Synonyms Section
                _buildSynonymsSection(),
                const SizedBox(height: 24),

                // Antonyms Section
                _buildAntonymsSection(),
                const SizedBox(height: 24),

                // Sentence Section
                _buildSentenceSection(),
                const SizedBox(height: 24),

                // Source Section
                _buildSourceSection(),
                const SizedBox(height: 32),

                // Save Button
                _buildSaveButton(viewModel),
                const SizedBox(height: 16),

                // Cancel Button
                _buildCancelButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWordSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.word,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _wordController,
            focusNode: _wordFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _meaningFocus.requestFocus(),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.enterTheNewWord,
              hintStyle: TextStyle(
                color: ThemeColors.getSecondaryTextColor(
                  context,
                ).withOpacity(0.7),
              ),
              filled: true,
              fillColor: AppColors.lightLavender.withOpacity(0.3),
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
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ThemeColors.getTextColor(context),
            ),
            validator: (v) => v == null || v.trim().isEmpty
                ? AppLocalizations.of(context)!.pleaseEnterAWord
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.autoFocus,
            style: TextStyle(
              fontSize: 12,
              color: ThemeColors.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeaningsSection() {
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
                AppLocalizations.of(context)!.meanings,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.getTextColor(context),
                ),
              ),
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // const Spacer(),
              // IconButton(
              //   onPressed: () {
              //     // TODO: Add meaning functionality
              //   },
              //   icon: const Icon(Icons.add, color: AppColors.darkGray),
              //   iconSize: 20,
              // ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _meaningController,
            focusNode: _meaningFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _synonymsFocus.requestFocus(),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.meaningsHint,
              hintStyle: TextStyle(
                color: ThemeColors.getSecondaryTextColor(
                  context,
                ).withOpacity(0.7),
              ),
              filled: true,
              fillColor: AppColors.lightLavender.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(fontSize: 14, color: AppColors.darkGray),
            validator: (v) => v == null || v.trim().isEmpty
                ? AppLocalizations.of(context)!.pleaseEnterTheMeaning
                : null,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.thisFieldIsRequired,
                style: TextStyle(
                  fontSize: 12,
                  color: ThemeColors.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
          // const SizedBox(height: 12),
          // Wrap(
          //   spacing: 8,
          //   runSpacing: 8,
          //   children: [
          //     _buildMeaningChip('pleasant surprise', true),
          //     _buildMeaningChip('happy accident', false),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildSynonymsSection() {
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
                AppLocalizations.of(context)!.synonyms,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.getTextColor(context),
                ),
              ),
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
            controller: _synonymsController,
            focusNode: _synonymsFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _antonymsFocus.requestFocus(),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.synonymsHint,
              hintStyle: TextStyle(
                color: ThemeColors.getSecondaryTextColor(
                  context,
                ).withOpacity(0.7),
              ),
              filled: true,
              fillColor: AppColors.lightLavender.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(fontSize: 14, color: AppColors.darkGray),
            validator: (v) => v == null || v.trim().isEmpty
                ? AppLocalizations.of(context)!.thisFieldIsRequired
                : null,
          ),
          // const SizedBox(height: 12),
          // Wrap(
          //   spacing: 8,
          //   runSpacing: 8,
          //   children: [
          //     _buildSynonymChip('luck'),
          //     _buildSynonymChip('fluke'),
          //     _buildSynonymChip('providence'),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildAntonymsSection() {
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
                AppLocalizations.of(context)!.antonyms,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.getTextColor(context),
                ),
              ),
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
            controller: _antonymsController,
            focusNode: _antonymsFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _sentenceFocus.requestFocus(),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.antonymsHint,
              hintStyle: TextStyle(
                color: ThemeColors.getSecondaryTextColor(
                  context,
                ).withOpacity(0.7),
              ),
              filled: true,
              fillColor: AppColors.lightLavender.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(fontSize: 14, color: AppColors.darkGray),
            validator: (v) => v == null || v.trim().isEmpty
                ? AppLocalizations.of(context)!.thisFieldIsRequired
                : null,
          ),
          // const SizedBox(height: 12),
          // Wrap(
          //   spacing: 8,
          //   runSpacing: 8,
          //   children: [
          //     _buildAntonymChip('design'),
          //     _buildAntonymChip('premeditation'),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildSentenceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.useInSentence,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.makeItPersonal,
            style: TextStyle(
              fontSize: 12,
              color: ThemeColors.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _sentenceController,
            focusNode: _sentenceFocus,
            textInputAction: TextInputAction.done,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.sentenceHint,
              hintStyle: TextStyle(
                color: ThemeColors.getSecondaryTextColor(
                  context,
                ).withOpacity(0.7),
              ),
              filled: true,
              fillColor: AppColors.lightLavender.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(fontSize: 14, color: AppColors.darkGray),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.whereDidYouLearnThisWord,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.chooseSource,
            style: TextStyle(
              fontSize: 12,
              color: ThemeColors.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _getSources(
              context,
            ).map((source) => _buildSourceChip(source)).toList(),
          ),
          // const SizedBox(height: 16),
          // GestureDetector(
          //   onTap: () {
          //     // TODO: Add custom source functionality
          //   },
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          //     decoration: BoxDecoration(
          //       border: Border.all(color: ThemeColors.getSecondaryTextColor(context).withOpacity(0.3)),
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: Row(
          //       children: [
          //         Icon(Icons.add, color: ThemeColors.getSecondaryTextColor(context), size: 20),
          //         const SizedBox(width: 8),
          //         Text(
          //           'Add custom source',
          //           style: TextStyle(color: ThemeColors.getSecondaryTextColor(context), fontSize: 14),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildMeaningChip(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.lightPurple
            : AppColors.lightLavender.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.darkGray,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSynonymChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAntonymChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSourceChip(Map<String, dynamic> source) {
    final isSelected = _selectedSource == source['name'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSource = isSelected ? '' : source['name'];
        });
        HapticFeedback.selectionClick();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? source['color'].withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? source['color']
                : AppColors.lightGray.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              source['icon'],
              color: isSelected ? source['color'] : AppColors.lightGray,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              source['name'],
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? source['color'] : AppColors.darkGray,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(AddWordViewModel viewModel) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF5A52FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: viewModel.isLoading ? null : _saveWord,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: viewModel.isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                AppLocalizations.of(context)!.saveWord,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          AppLocalizations.of(context)!.cancel,
          style: TextStyle(
            fontSize: 16,
            color: ThemeColors.getSecondaryTextColor(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
