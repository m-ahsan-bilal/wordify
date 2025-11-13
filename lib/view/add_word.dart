import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Word'),
        leading: BackButton(onPressed: () => context.go('/home')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: Save to Hive or Firebase later
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('coming soon...')),
                    );
                  }
                },
                child: const Text('Save Word'),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Enter $label' : null,
      ),
    );
  }
}
