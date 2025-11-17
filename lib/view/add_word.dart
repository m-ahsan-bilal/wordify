import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/model/word_model.dart';
import '../viewmodel/add_word_vm.dart';

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
  final _sourceController = TextEditingController();

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _synonymsController.dispose();
    _antonymsController.dispose();
    _sentenceController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _saveWord() async {
    if (!_formKey.currentState!.validate()) return;

    final word = Word(
      word: _wordController.text.trim(),
      meaning: _meaningController.text.trim(),
      synonyms: _synonymsController.text.trim(),
      antonyms: _antonymsController.text.trim(),
      sentence: _sentenceController.text.trim(),
      source: _sourceController.text.trim(),
    );

    final viewModel = context.read<AddWordViewModel>();
    final success = await viewModel.addWord(word);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Word added successfully! Streak updated.')),
      );
      // Clear form for next word
      _formKey.currentState!.reset();
      _wordController.clear();
      _meaningController.clear();
      _synonymsController.clear();
      _antonymsController.clear();
      _sentenceController.clear();
      _sourceController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.error ?? 'Failed to add word')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Word'),
        leading: BackButton(onPressed: () => context.go('/home')),
      ),
      body: Consumer<AddWordViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildField('Word', _wordController),
                      _buildField('Meaning(s)', _meaningController, maxLines: 2),
                      _buildField('Synonyms', _synonymsController),
                      _buildField('Antonyms', _antonymsController),
                      _buildField(
                        'Use in a Sentence',
                        _sentenceController,
                        maxLines: 2,
                      ),
                      _buildField('Source', _sourceController),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: viewModel.isLoading ? null : _saveWord,
                          child: viewModel.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save Word',
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Enter $label' : null,
      ),
    );
  }
}
