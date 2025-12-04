// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/model/word_model.dart';
import '../core/utils/app_colors.dart';
import '../viewmodel/add_word_vm.dart';
import 'widgets/ad_banner_widget.dart';
import 'widgets/reusable_text_field.dart';
import 'widgets/reusable_card.dart';
import 'widgets/reusable_section_header.dart';
import 'widgets/reusable_primary_button.dart';
import 'widgets/reusable_secondary_button.dart';
import '../l10n/app_localizations.dart';

// Add Word Screen - Uses AddWordViewModel to manage word addition
class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
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
    _scrollController.dispose();
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

  /// Scroll to first field with validation error
  void _scrollToFirstError() {
    // Check which fields have errors and scroll to the first one
    if (_wordController.text.trim().isEmpty) {
      _wordFocus.requestFocus();
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } else if (_meaningController.text.trim().isEmpty) {
      _meaningFocus.requestFocus();
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } else if (_synonymsController.text.trim().isEmpty) {
      _synonymsFocus.requestFocus();
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } else if (_antonymsController.text.trim().isEmpty) {
      _antonymsFocus.requestFocus();
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          300,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _saveWord() async {
    // First, manually check all required fields before form validation
    final wordText = _wordController.text.trim();
    final meaningText = _meaningController.text.trim();
    final synonymsText = _synonymsController.text.trim();
    final antonymsText = _antonymsController.text.trim();

    // Check if any required field is empty
    bool hasEmptyField =
        wordText.isEmpty ||
        meaningText.isEmpty ||
        synonymsText.isEmpty ||
        antonymsText.isEmpty;

    // Validate form - this will show field-level errors
    final isFormValid = _formKey.currentState!.validate();

    // If form validation failed OR we detected empty fields, show error
    if (!isFormValid || hasEmptyField) {
      // Provide haptic feedback for validation failure
      HapticFeedback.heavyImpact();

      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: ThemeColors.getTextColor(context),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('Please fill all required fields')),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      // Scroll to first error field
      _scrollToFirstError();
      return;
    }

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Create Word object (we've already validated all fields are filled)
    final word = Word(
      word: wordText,
      meaning: meaningText,
      synonyms: synonymsText,
      antonyms: antonymsText,
      sentence: _sentenceController.text.trim(),
      source: _selectedSource,
    );

    final viewModel = context.read<AddWordViewModel>();
    final result = await viewModel.addWord(word);

    if (!mounted) return;

    if (result) {
      // Show success feedback
      HapticFeedback.mediumImpact();

      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.wordAddedSuccess)),
            ],
          ),
          backgroundColor: AppColors.lightGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
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
              Icon(Icons.error, color: ThemeColors.getTextColor(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  viewModel.error ??
                      AppLocalizations.of(context)!.failedToAddWord,
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
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
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
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
                ),
                // Ad Banner at bottom
                const AdBannerWidget(margin: EdgeInsets.symmetric(vertical: 8)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWordSection() {
    return ReusableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReusableSectionHeader(
            title: AppLocalizations.of(context)!.word,
            isRequired: true,
          ),
          const SizedBox(height: 12),
          ReusableTextField(
            controller: _wordController,
            focusNode: _wordFocus,
            nextFocusNode: _meaningFocus,
            hintText: AppLocalizations.of(context)!.enterTheNewWord,
            isRequired: true,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return AppLocalizations.of(context)!.pleaseEnterAWord;
              }
              return null;
            },
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
    return ReusableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReusableSectionHeader(
            title: AppLocalizations.of(context)!.meanings,
            isRequired: true,
          ),
          const SizedBox(height: 12),
          ReusableTextField(
            controller: _meaningController,
            focusNode: _meaningFocus,
            nextFocusNode: _synonymsFocus,
            hintText: AppLocalizations.of(context)!.meaningsHint,
            maxLines: 3,
            validator: (v) => v == null || v.trim().isEmpty
                ? AppLocalizations.of(context)!.pleaseEnterTheMeaning
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSynonymsSection() {
    return ReusableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReusableSectionHeader(
            title: AppLocalizations.of(context)!.synonyms,
            isRequired: true,
          ),
          const SizedBox(height: 12),
          ReusableTextField(
            controller: _synonymsController,
            focusNode: _synonymsFocus,
            nextFocusNode: _antonymsFocus,
            hintText: AppLocalizations.of(context)!.synonymsHint,
            validator: (v) => v == null || v.trim().isEmpty
                ? AppLocalizations.of(context)!.thisFieldIsRequired
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAntonymsSection() {
    return ReusableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReusableSectionHeader(
            title: AppLocalizations.of(context)!.antonyms,
            isRequired: true,
          ),
          const SizedBox(height: 12),
          ReusableTextField(
            controller: _antonymsController,
            focusNode: _antonymsFocus,
            nextFocusNode: _sentenceFocus,
            hintText: AppLocalizations.of(context)!.antonymsHint,
            validator: (v) => v == null || v.trim().isEmpty
                ? AppLocalizations.of(context)!.thisFieldIsRequired
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceSection() {
    return ReusableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReusableSectionHeader(
            title: AppLocalizations.of(context)!.useInSentence,
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
          ReusableTextField(
            controller: _sentenceController,
            focusNode: _sentenceFocus,
            hintText: AppLocalizations.of(context)!.sentenceHint,
            maxLines: 3,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSection() {
    return ReusableCard(
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
            : AppColors.lightLavender.withValues(alpha: 0.5),
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
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
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
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
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
              ? source['color'].withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? source['color']
                : AppColors.lightGray.withValues(alpha: 0.3),
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
    return ReusablePrimaryButton(
      label: AppLocalizations.of(context)!.saveWord,
      onPressed: _saveWord,
      isLoading: viewModel.isLoading,
    );
  }

  Widget _buildCancelButton() {
    return ReusableSecondaryButton(
      label: AppLocalizations.of(context)!.cancel,
      onPressed: () => Navigator.pop(context),
      height: 48,
    );
  }
}
