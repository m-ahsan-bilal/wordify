import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:word_master/viewmodel/words_list_vm.dart';
import 'package:go_router/go_router.dart';

class WordsListScreen extends StatefulWidget {
  const WordsListScreen({super.key});

  @override
  State<WordsListScreen> createState() => _WordsListScreenState();
}

class _WordsListScreenState extends State<WordsListScreen> {
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
  Widget build(BuildContext context) {
    final vm = context.watch<WordsListViewModel>();

    final hasWords =
        vm.todaysWords.isNotEmpty ||
        vm.yesterdaysWords.isNotEmpty ||
        vm.olderWords.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/home')),
        title: const Text("Your Words"),
        centerTitle: true,
        elevation: 0.7,
        shadowColor: Colors.grey.withOpacity(0.5),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => vm.loadWords(),
        child: hasWords
            ? ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (vm.todaysWords.isNotEmpty)
                    _buildCollapsibleSection("Today", vm.todaysWords),
                  if (vm.yesterdaysWords.isNotEmpty)
                    _buildCollapsibleSection("Yesterday", vm.yesterdaysWords),
                  if (vm.olderWords.isNotEmpty)
                    ...vm.olderWords.entries.map((entry) {
                      final formatted = DateFormat(
                        'MMM dd, yyyy',
                      ).format(DateTime.parse(entry.key));
                      return _buildCollapsibleSection(formatted, entry.value);
                    }),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.book_rounded, size: 80, color: Colors.indigo),
                    SizedBox(height: 16),
                    Text(
                      "No words added yet!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Start adding your words to see them here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCollapsibleSection(
    String title,
    List<Map<String, dynamic>> words,
  ) {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      children: words.map((word) => _buildWordTile(word)).toList(),
    );
  }

  Widget _buildWordTile(Map<String, dynamic> word) {
    final wordIndex = word['index'] as int? ?? 0;

    return GestureDetector(
      onTap: () {
        context.go('/word-details', extra: wordIndex);
      },
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          title: Text(
            word['word'] ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            word['meaning'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        ),
      ),
    );
  }
}
