import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodel/streak_vm.dart';
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

  @override
  void initState() {
    super.initState();
    // Load data after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    // Load streak
    final streakVm = context.read<StreakViewModel>();
    await streakVm.loadStreak();

    // Load today's words
    final wordRepo = context.read<WordRepository>();
    final words = await wordRepo.getTodaysWords();

    if (mounted) {
      setState(() {
        todaysWords = words;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.7,
        shadowColor: Colors.grey.withOpacity(0.5),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Hello, Learner!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // Today's Words Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Today's Words",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (todaysWords.isEmpty)
                        const Text(
                          'No words today',
                          style: TextStyle(fontSize: 16),
                        )
                      else
                        SizedBox(
                          height: 60,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: todaysWords.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final word = todaysWords[index]['word'] ?? '';
                              return Chip(
                                label: Text(
                                  word,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: Colors.indigo.shade50,
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.go('/list'),
                        child: const Text('Review Now'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Streak Card - Using StreakViewModel
              Consumer<StreakViewModel>(
                builder: (context, streakVm, child) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.local_fire_department,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Streak",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            streakVm.getStreakDisplayText(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: streakVm.getStreakProgress(),
                            color: Colors.orange,
                            backgroundColor: Colors.orange.shade100,
                          ),
                          if (streakVm.isStreakAtRisk &&
                              streakVm.streak.currentStreak > 0) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Add a word today to keep your streak!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Quick Actions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _quickAction(context, Icons.add, "Add Word", '/add-word'),
                  _quickAction(
                    context,
                    Icons.menu_book,
                    "Review Words",
                    '/list',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Placeholder for future content
              const Center(
                child: Text(
                  'Keep learning! 📚',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAction(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.indigo.shade50,
            child: Icon(icon, color: Colors.indigo, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
