import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

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

  late Box wordsBox;
  @override
  void initState() {
    super.initState();
    wordsBox = Hive.box('words');
  }

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

  void _saveWord() {
    if (!_formKey.currentState!.validate()) return;
    final wordData = {
      'word': _wordController.text.trim(),
      'meaning': _meaningController.text.trim(),
      'synonyms': _synonymsController.text.trim(),
      'antonyms': _antonymsController.text.trim(),
      'sentence': _sentenceController.text.trim(),
      'source': _sourceController.text.trim(),
      'dateAdded': DateTime.now().toIso8601String().trim(),
    };
    wordsBox.add(wordData);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Word added successfully!')));
    // clear form for next word
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Word'),
        leading: BackButton(onPressed: () => context.go('/home')),
      ),
      body: Padding(
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
                  onPressed: _saveWord,
                  child: const Text(
                    'Save Word',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
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
