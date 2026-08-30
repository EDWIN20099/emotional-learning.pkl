import 'package:flutter/material.dart';

import '../services/story_service.dart';
import 'story_level_page.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({super.key});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final StoryService _storyService = StoryService();

  late Future<List<Map<String, dynamic>>> _stories;

  @override
  void initState() {
    super.initState();
    _stories = _storyService.getStories();
  }

  IconData getEmotionIcon(String name) {
    switch (name.toLowerCase()) {
      case 'senang':
        return Icons.sentiment_very_satisfied_rounded;
      case 'sedih':
        return Icons.sentiment_dissatisfied_rounded;
      case 'marah':
        return Icons.sentiment_very_dissatisfied_rounded;
      case 'jijik':
        return Icons.sick_rounded;
      default:
        return Icons.emoji_emotions_rounded;
    }
  }

  Color getEmotionColor(String name) {
    switch (name.toLowerCase()) {
      case 'senang':
        return const Color(0xFFFFB300);
      case 'sedih':
        return const Color(0xFF42A5F5);
      case 'marah':
        return const Color(0xFFEF5350);
      case 'jijik':
        return const Color(0xFF66BB6A);
      default:
        return const Color(0xFFFFA726);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5), // Warna latar krem hangat khas TK
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFDCE8F5),
                width: 1.5,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF1B3B6F),
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Cerita Emosi 📖',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Color(0xFF1B3B6F),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _stories,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF8E42),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Oops! Cerita belum bisa dimuat.\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B3B6F),
                  ),
                ),
              ),
            );
          }

          final stories = snapshot.data ?? [];

          if (stories.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '📚',
                    style: TextStyle(fontSize: 60),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Belum ada cerita.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B3B6F),
                    ),
                  ),
                ],
              ),
            );
          }

          // Mengelompokkan cerita berdasarkan emosi.
          final Map<String, Map<String, dynamic>>
              emotionMap = {};

          for (final story in stories) {
            final emotion = story['emotions'];

            if (emotion is Map) {
              final emotionId =
                  emotion['id']?.toString();

              final emotionName =
                  emotion['name']?.toString();

              if (emotionId != null &&
                  emotionName != null &&
                  !emotionMap.containsKey(emotionId)) {
                emotionMap[emotionId] = {
                  'id': emotionId,
                  'name': emotionName,
                };
              }
            }
          }

          final emotions = emotionMap.values.toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              32,
            ),
            children: [
              // Hero Card Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE066),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC928).withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yuk baca cerita! 📖',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1B3B6F),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Pilih emosi dan ikuti kisah seru\nsesuai tahapnya ya! ✨',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF855D00),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '📚',
                        style: TextStyle(fontSize: 38),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Pilih Emosi 🌈',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B3B6F),
                ),
              ),

              const SizedBox(height: 16),

              ...emotions.map(
                (emotion) {
                  final emotionId =
                      emotion['id']?.toString() ?? '';

                  final emotionName =
                      emotion['name']?.toString() ??
                          'Emosi';

                  final color =
                      getEmotionColor(emotionName);

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16,
                    ),
                    child: _emotionCard(
                      emotionName: emotionName,
                      color: color,
                      icon: getEmotionIcon(
                        emotionName,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StoryLevelPage(
                              emotionId: emotionId,
                              emotionName:
                                  emotionName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _emotionCard({
    required String emotionName,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 38,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      emotionName,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B3B6F),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Lihat cerita ${emotionName.toLowerCase()} ✨',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8A9DBF),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}