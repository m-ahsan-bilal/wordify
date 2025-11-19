import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:word_master/core/utils/app_colors.dart';
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
  final flutterTts = FlutterTts();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final streakVm = context.read<StreakViewModel>();
    await streakVm.loadStreak();

    final wordRepo = context.read<WordRepository>();
    final words = await wordRepo.getTodaysWords();

    if (mounted) {
      setState(() {
        todaysWords = words;
      });
    }
  }

  void _speak(String text) async {
    if (text.isEmpty) return;
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightLavender,
      appBar: AppBar(
        backgroundColor: AppColors.lightLavender,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.menu, color: AppColors.darkGray),
        //   onPressed: () {
        //     // TODO: Open drawer
        //   },
        // ),
        title: const Text(
          'Home ',
          style: TextStyle(
            color: AppColors.darkGray,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<StreakViewModel>(
            builder: (context, streakVm, child) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${streakVm.streak.currentStreak} day',
                      style: const TextStyle(
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Padding(
          //   padding: const EdgeInsets.only(right: 16),
          //   child: CircleAvatar(
          //     backgroundColor: AppColors.darkPurple,
          //     child: const Icon(Icons.person, color: AppColors.white),
          //   ),
          // ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Today's Word Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's word",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                todaysWords.isNotEmpty
                                    ? todaysWords[0]['word'] ?? ''
                                    : '',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGray,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                todaysWords.isNotEmpty
                                    ? todaysWords[0]['definition'] ??
                                          'You have no added words today'
                                    : 'You have no added words today',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.lightGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: OutlinedButton.icon(
                            onPressed: () => _speak(todaysWords[0]['word']),
                            icon: const Icon(Icons.volume_up),
                            label: const Text('Listen'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.darkGray,
                              side: const BorderSide(
                                color: AppColors.progressGray,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Expanded(
                        //   child: ElevatedButton.icon(
                        //     onPressed: () {
                        //       // TODO: Save word
                        //     },
                        //     icon: const Icon(Icons.add),
                        //     label: const Text('Save'),
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: AppColors.lightPurple,
                        //       foregroundColor: AppColors.darkGray,
                        //       elevation: 0,
                        //       padding: const EdgeInsets.symmetric(vertical: 16),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(12),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Stats Cards
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Consumer<StreakViewModel>(
                  builder: (context, streakVm, child) {
                    return Row(
                      spacing: 20,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatCard(
                          icon: Icons.local_fire_department,
                          value: streakVm.streak.currentStreak.toString(),
                          label: 'Day streak',
                          color: AppColors.lightPurple,
                        ),

                        _buildStatCard(
                          icon: Icons.stars,
                          value: '1,240',
                          label: 'XP',
                          color: AppColors.lightPurple,
                        ),
                        _buildStatCard(
                          icon: Icons.check_circle,
                          value: '46',
                          label: 'Mastered',
                          color: AppColors.lightPurple,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.add_circle_outline,
                      label: 'Add Word',
                      onTap: () => context.go('/add-word'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.auto_awesome,
                      label: 'Start Quiz',
                      onTap: () {
                        // TODO: Navigate to quiz
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.access_time,
                      label: 'Review',
                      onTap: () => context.go('/list'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              /*

              // Today's Goal
              const Text(
                "Today's Goal",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.progressGray,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '12/20 XP • Keep it up!',
                style: TextStyle(color: AppColors.lightGray, fontSize: 14),
              ),

              const SizedBox(height: 24),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search words...',
                  hintStyle: const TextStyle(color: AppColors.lightGray),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.lightGray,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune, color: AppColors.lightGray),
                    onPressed: () {
                      // TODO: Open filters
                    },
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 16),

              // Filter Chips
              Row(
                children: [
                  _buildFilterChip('All', isSelected: true),
                  const SizedBox(width: 8),
                  _buildFilterChip('New', isSelected: false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Mastered', isSelected: false),
                ],
              ),

              const SizedBox(height: 16),

              // Your Library
              const Text(
                "Your Library",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 12),

              // Word List
              if (todaysWords.isNotEmpty)
                ...todaysWords
                    .take(3)
                    .map(
                      (word) => _buildWordCard(
                        word: word['word'] ?? '',
                        definition: word['definition'] ?? '',
                        level: 'Lv ${word['level'] ?? 1}',
                        lastReviewed: 'Last reviewed 2d ago',
                      ),
                    )
              else
                _buildWordCard(
                  word: 'Ebullient',
                  definition: 'Last reviewed 2d ago • Syn ✓ • Ant ✓',
                  level: 'Lv 3',
                  lastReviewed: '',
                  levelColor: AppColors.lightGreen,
                ),
          

          */
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.darkGray),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.lightGray),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.darkGray, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.lightPurple : AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.darkGray,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildWordCard({
    required String word,
    required String definition,
    required String level,
    required String lastReviewed,
    Color? levelColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.bookmark_border, color: AppColors.darkGray),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lastReviewed.isNotEmpty ? lastReviewed : definition,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.lightGray,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: levelColor ?? AppColors.lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              level,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.lightGray),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import '../viewmodel/streak_vm.dart';
// import '../core/repositories/word_repository.dart';

// /// Home Screen - Uses StreakViewModel and WordRepository
// /// Follows MVVM pattern: UI talks only to ViewModels/Repositories
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   List<Map<String, dynamic>> todaysWords = [];
//   int streak = 0;

//   @override
//   void initState() {
//     super.initState();
//     // Load data after the first frame is built
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadData();
//     });
//   }

//   Future<void> _loadData() async {
//     if (!mounted) return;

//     // Load streak
//     final streakVm = context.read<StreakViewModel>();
//     await streakVm.loadStreak();

//     // Load today's words
//     final wordRepo = context.read<WordRepository>();
//     final words = await wordRepo.getTodaysWords();

//     if (mounted) {
//       setState(() {
//         todaysWords = words;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Home',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         elevation: 0.7,
//         shadowColor: Colors.grey.withOpacity(0.5),
//         backgroundColor: Colors.indigo,
//         foregroundColor: Colors.white,
//       ),
//       body: RefreshIndicator(
//         onRefresh: _loadData,
//         child: SafeArea(
//           child: ListView(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             children: [
//               const Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Hello, Learner!",
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Today's Words Card
//               Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 elevation: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "Today's Words",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       if (todaysWords.isEmpty)
//                         const Text(
//                           'No words today',
//                           style: TextStyle(fontSize: 16),
//                         )
//                       else
//                         SizedBox(
//                           height: 60,
//                           child: ListView.separated(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: todaysWords.length,
//                             separatorBuilder: (_, __) =>
//                                 const SizedBox(width: 8),
//                             itemBuilder: (context, index) {
//                               final word = todaysWords[index]['word'] ?? '';
//                               return Chip(
//                                 label: Text(
//                                   word,
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 backgroundColor: Colors.indigo.shade50,
//                               );
//                             },
//                           ),
//                         ),
//                       const SizedBox(height: 12),
//                       ElevatedButton(
//                         onPressed: () => context.go('/list'),
//                         child: const Text('Review Now'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Streak Card - Using StreakViewModel
//               Consumer<StreakViewModel>(
//                 builder: (context, streakVm, child) {
//                   return Card(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     elevation: 4,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: const [
//                               Icon(
//                                 Icons.local_fire_department,
//                                 color: Colors.orange,
//                               ),
//                               SizedBox(width: 8),
//                               Text(
//                                 "Streak",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           Text(
//                             streakVm.getStreakDisplayText(),
//                             style: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           LinearProgressIndicator(
//                             value: streakVm.getStreakProgress(),
//                             color: Colors.orange,
//                             backgroundColor: Colors.orange.shade100,
//                           ),
//                           if (streakVm.isStreakAtRisk &&
//                               streakVm.streak.currentStreak > 0) ...[
//                             const SizedBox(height: 12),
//                             Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: Colors.orange.shade50,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Row(
//                                 children: [
//                                   Icon(
//                                     Icons.warning_amber_rounded,
//                                     color: Colors.orange,
//                                     size: 20,
//                                   ),
//                                   SizedBox(width: 8),
//                                   Expanded(
//                                     child: Text(
//                                       'Add a word today to keep your streak!',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.orange,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),

//               const SizedBox(height: 24),

//               // Quick Actions Row
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _quickAction(context, Icons.add, "Add Word", '/add-word'),
//                   _quickAction(
//                     context,
//                     Icons.menu_book,
//                     "Review Words",
//                     '/list',
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 24),

//               // Placeholder for future content
//               const Center(
//                 child: Text(
//                   'Keep learning! 📚',
//                   style: TextStyle(fontSize: 16, color: Colors.black54),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _quickAction(
//     BuildContext context,
//     IconData icon,
//     String label,
//     String route,
//   ) {
//     return GestureDetector(
//       onTap: () => context.go(route),
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 28,
//             backgroundColor: Colors.indigo.shade50,
//             child: Icon(icon, color: Colors.indigo, size: 28),
//           ),
//           const SizedBox(height: 8),
//           Text(label, style: const TextStyle(fontSize: 14)),
//         ],
//       ),
//     );
//   }
// }
