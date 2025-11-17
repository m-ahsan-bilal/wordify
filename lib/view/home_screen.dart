import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:word_master/core/local_db/words_service.dart';
import 'package:word_master/core/local_db/settings_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch today's words and current streak
    final todaysWords = WordsService().getTodaysWords();
    final streak = SettingsService().getStreak();

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
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Hello, Ahsan",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Today's Words Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
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
            ),

            const SizedBox(height: 24),

            // Streak Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
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
                        "$streak-day streak",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: (streak % 7) / 7,
                        color: Colors.orange,
                        backgroundColor: Colors.orange.shade100,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _quickAction(context, Icons.add, "Add Word", '/add-word'),
                  _quickAction(
                    context,
                    Icons.menu_book,
                    "Review Words",
                    '/list',
                  ),
                  // _quickAction(context, Icons.quiz, "Play Quiz", '/quiz'),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text('Firebase Crashlytics Test Crash'),
            // Crashlytics Test Button
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    debugPrint('Crash button pressed..............');
                    // Trigger a test crash
                    FirebaseCrashlytics.instance.crash();
                  },
                  child: const Text(
                    'Make Me Crash',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Placeholder for future content
            const Expanded(child: Center(child: Text('AD Area'))),
          ],
        ),
      ),

      // bottomNavigationBar: BottomNavigationBar(
      //   selectedItemColor: Colors.indigo,
      //   unselectedItemColor: Colors.grey,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      //     BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Words"),
      //     BottomNavigationBarItem(icon: Icon(Icons.quiz), label: "Quiz"),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      //   ],
      //   currentIndex: 0,
      //   onTap: (index) {
      //     switch (index) {
      //       case 0:
      //         context.go('/home');
      //         break;
      //       case 1:
      //         context.go('/words-detail');
      //         break;
      //       case 2:
      //         context.go('/quiz');
      //         break;
      //       case 3:
      //         context.go('/profile');
      //         break;
      //     }
      //   },
      // ),
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
