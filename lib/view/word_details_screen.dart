import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/model/word_model.dart';
import '../core/repositories/word_repository.dart';
import '../viewmodel/add_word_vm.dart';

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

  // Controllers
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, TextEditingController> _chipsControllers = {};

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

        // Initialize controllers for text fields
        for (var key in ['meaning', 'sentence', 'source']) {
          _textControllers[key] =
              TextEditingController(text: wordData[key] ?? '');
        }

        // Initialize controllers for chips
        for (var key in ['synonyms', 'antonyms']) {
          _chipsControllers[key] = TextEditingController();
        }
      });
    }
  }

  @override
  void dispose() {
    _textControllers.forEach((_, controller) => controller.dispose());
    _chipsControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _toggleEdit() {
    setState(() => isEditing = !isEditing);
  }

  void _speak(String text) async {
    if (text.isEmpty) return;
    await flutterTts.speak(text);
  }

  void _saveChanges() async {
    // Update text fields
    _textControllers.forEach((key, controller) {
      wordData[key] = controller.text;
    });

    final word = Word.fromMap(wordData);
    final viewModel = context.read<AddWordViewModel>();
    final success = await viewModel.updateWord(widget.wordIndex, word);

    if (!mounted) return;

    if (success) {
      setState(() => isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.error ?? 'Failed to save changes')),
      );
    }
  }

  void _deleteWord() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Word'),
        content: const Text('Are you sure you want to delete this word?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
        const SnackBar(content: Text('Word deleted!')),
      );
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.error ?? 'Failed to delete word')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.go('/home')),
          title: const Text('Loading...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/home')),
        title: Text(wordData['word'] ?? ''),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEdit,
          ),
          if (isEditing) ...[
            IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
            IconButton(icon: const Icon(Icons.delete), onPressed: _deleteWord),
          ],
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => _speak(wordData['word'] ?? ''),
          ),
        ],
      ),
      body: Consumer<AddWordViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTextSection('Meaning', 'meaning'),
                  _buildChipsSection('Synonyms', 'synonyms'),
                  _buildChipsSection('Antonyms', 'antonyms'),
                  _buildTextSection('Example Sentence', 'sentence'),
                  _buildTextSection('Source', 'source'),
                ],
              ),
              if (viewModel.isLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextSection(String title, String key) {
    final controller = _textControllers[key]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          isEditing
              ? TextField(
                  controller: controller,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Enter $title',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )
              : Text(controller.text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildChipsSection(String title, String key) {
    List<String> items = [];
    if (wordData[key] != null && wordData[key].toString().isNotEmpty) {
      items = wordData[key].toString().split(',').map((e) => e.trim()).toList();
    }

    final controller = _chipsControllers[key]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Wrap(
            spacing: 8,
            children: items
                .map(
                  (e) => Chip(
                    label: Text(e),
                    onDeleted: isEditing
                        ? () {
                            setState(() {
                              items.remove(e);
                              wordData[key] = items.join(', ');
                            });
                          }
                        : null,
                  ),
                )
                .toList(),
          ),
          if (isEditing)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Add $title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (controller.text.isEmpty) return;
                    setState(() {
                      items.add(controller.text.trim());
                      wordData[key] = items.join(', ');
                      controller.clear();
                    });
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
