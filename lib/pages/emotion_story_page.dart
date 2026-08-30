import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/story_service.dart';
import 'story_reader_page.dart';

class EmotionStoryPage extends StatelessWidget {
  const EmotionStoryPage({super.key});

  static const Color backgroundColor = Color(0xFFF4F9FF);
  static const Color navyColor = Color(0xFF193B68);
  static const Color yellowColor = Color(0xFFFFC928);
  static const Color blueColor = Color(0xFF4DA6E8);
  static const Color redColor = Color(0xFFFF6B6B);
  static const Color greenColor = Color(0xFF59B86A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Cerita Emosi',
          style: TextStyle(fontWeight: FontWeight.w900, color: navyColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const Text(
            'Pilih Emosimu! 😊',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: navyColor,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Pilih emosi yang ingin kamu pelajari melalui cerita.',
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Color(0xFF66809F),
            ),
          ),

          const SizedBox(height: 24),

          _emotionCard(
            context,
            emotion: 'Senang',
            description: 'Cerita tentang rasa bahagia',
            emoji: '😊',
            color: yellowColor,
          ),

          const SizedBox(height: 14),

          _emotionCard(
            context,
            emotion: 'Sedih',
            description: 'Cerita tentang memahami kesedihan',
            emoji: '😢',
            color: blueColor,
          ),

          const SizedBox(height: 14),

          _emotionCard(
            context,
            emotion: 'Marah',
            description: 'Cerita tentang mengelola amarah',
            emoji: '😡',
            color: redColor,
          ),

          const SizedBox(height: 14),

          _emotionCard(
            context,
            emotion: 'Jijik',
            description: 'Cerita tentang rasa tidak nyaman',
            emoji: '🤢',
            color: greenColor,
          ),
        ],
      ),
    );
  }

  Widget _emotionCard(
    BuildContext context, {
    required String emotion,
    required String description,
    required String emoji,
    required Color color,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmotionStoriesListPage(
                emotion: emotion,
                color: color,
                emoji: emoji,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 36)),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emotion,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: navyColor,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF66809F),
                      ),
                    ),
                  ],
                ),
              ),

              Icon(Icons.arrow_forward_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HALAMAN LEVEL CERITA
// ============================================================

class EmotionStoriesListPage extends StatefulWidget {
  final String emotion;
  final Color color;
  final String emoji;

  const EmotionStoriesListPage({
    super.key,
    required this.emotion,
    required this.color,
    required this.emoji,
  });

  @override
  State<EmotionStoriesListPage> createState() => _EmotionStoriesListPageState();
}

class _EmotionStoriesListPageState extends State<EmotionStoriesListPage> {
  final StoryService storyService = StoryService();
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> stories = Future.value([]);

  Set<String> completedStories = {};
  bool loadingRewards = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final result = await storyService.getStories();

      final filteredStories = result.where((story) {
        final emotion = story['emotions'];

        if (emotion is Map) {
          final name = emotion['name']?.toString().toLowerCase();

          return name == widget.emotion.toLowerCase();
        }

        return false;
      }).toList();

      const storyOrder = [
        'Hari yang Menyenangkan',
        'Petualangan Baru',
        'Hari Bersama Keluarga',
        'Membantu Teman',
        'Hari yang Istimewa',
      ];

      filteredStories.sort((a, b) {
        final titleA = a['title']?.toString() ?? '';
        final titleB = b['title']?.toString() ?? '';

        final indexA = storyOrder.indexOf(titleA);
        final indexB = storyOrder.indexOf(titleB);

        return (indexA == -1 ? 999 : indexA).compareTo(
          indexB == -1 ? 999 : indexB,
        );
      });

      final user = supabase.auth.currentUser;

      Set<String> rewards = {};

      if (user != null) {
        final rewardData = await supabase
            .from('user_rewards')
            .select('story_id')
            .eq('user_id', user.id);

        rewards = rewardData
            .map<String>((item) => item['story_id'].toString())
            .toSet();
      }

      if (!mounted) return;

      setState(() {
        completedStories = rewards;
        loadingRewards = false;

        stories = Future.value(filteredStories.take(5).toList());
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingRewards = false;
        stories = Future.error(e);
      });
    }
  }

  bool isStageUnlocked(int index, List<Map<String, dynamic>> storyList) {
    // Tahap 1 selalu terbuka.
    if (index == 0) {
      return true;
    }

    // Tahap berikutnya membutuhkan tahap sebelumnya selesai.
    if (index - 1 >= storyList.length) {
      return false;
    }

    final previousStoryId = storyList[index - 1]['id']?.toString();

    return previousStoryId != null &&
        completedStories.contains(previousStoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Cerita ${widget.emotion}',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF193B68),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: stories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              loadingRewards) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat cerita.\n\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final storyList = snapshot.data ?? [];

          if (storyList.isEmpty) {
            return const Center(child: Text('Belum ada cerita.'));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.emoji,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.emotion,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF193B68),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              const Text(
                'Pilih Cerita 📖',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF193B68),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Selesaikan cerita dan quiz untuk membuka tahap berikutnya.',
                style: TextStyle(fontSize: 14, color: Color(0xFF66809F)),
              ),

              const SizedBox(height: 18),

              ...List.generate(5, (index) {
                final hasStory = index < storyList.length;

                final story = hasStory ? storyList[index] : <String, dynamic>{};

                final title = hasStory
                    ? story['title']?.toString() ?? 'Cerita berikutnya'
                    : 'Cerita berikutnya';

                final unlocked = hasStory && isStageUnlocked(index, storyList);

                final completed =
                    hasStory &&
                    completedStories.contains(story['id']?.toString());

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _storyCard(
                    context,
                    story: story,
                    title: title,
                    number: index + 1,
                    isUnlocked: unlocked,
                    isCompleted: completed,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _storyCard(
    BuildContext context, {
    required Map<String, dynamic> story,
    required String title,
    required int number,
    required bool isUnlocked,
    required bool isCompleted,
  }) {
    return Material(
      color: isUnlocked ? Colors.white : const Color(0xFFF1F4F8),
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: isUnlocked
            ? () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoryReaderPage(story: story),
                  ),
                );

                // 🔥 Ambil ulang reward setelah kembali
                // dari Story / Quiz.
                await loadData();
              }
            : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: isUnlocked
                  ? widget.color.withValues(alpha: 0.35)
                  : const Color(0xFFD5DDE7),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? widget.color.withValues(alpha: 0.16)
                      : const Color(0xFFE1E6EC),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Icon(
                  isUnlocked
                      ? isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.menu_book_rounded
                      : Icons.lock_rounded,
                  color: isUnlocked
                      ? isCompleted
                            ? Colors.green
                            : widget.color
                      : const Color(0xFF8995A5),
                  size: 32,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tahap $number',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isUnlocked
                            ? widget.color
                            : const Color(0xFF8995A5),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isUnlocked
                            ? const Color(0xFF193B68)
                            : const Color(0xFF8995A5),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      isCompleted
                          ? 'Selesai ✓'
                          : isUnlocked
                          ? 'Tersedia'
                          : 'Terkunci',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? Colors.green
                            : isUnlocked
                            ? Colors.green
                            : const Color(0xFF8995A5),
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                isUnlocked
                    ? Icons.arrow_forward_rounded
                    : Icons.lock_outline_rounded,
                color: isUnlocked ? widget.color : const Color(0xFF8995A5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
