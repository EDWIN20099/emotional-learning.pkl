import 'package:flutter/material.dart';

import '../services/story_service.dart';
import 'story_reader_page.dart';

class StoryLevelPage extends StatefulWidget {
  final String emotionId;
  final String emotionName;

  const StoryLevelPage({
    super.key,
    required this.emotionId,
    required this.emotionName,
  });

  @override
  State<StoryLevelPage> createState() => _StoryLevelPageState();
}

class _StoryLevelPageState extends State<StoryLevelPage> {
  final StoryService _storyService = StoryService();

  late Future<List<Map<String, dynamic>>> _stories;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  // ============================================================
  // LOAD CERITA
  // ============================================================

  void _loadStories() {
    _stories = _storyService.getStoriesByEmotion(widget.emotionId);
  }

  // ============================================================
  // REFRESH CERITA
  // ============================================================

  Future<void> refreshStories() async {
    if (!mounted) return;

    setState(() {
      _loadStories();
    });

    try {
      await _stories;
    } catch (_) {
      // Error akan ditampilkan oleh FutureBuilder.
    }
  }

  // ============================================================
  // ICON EMOSI
  // ============================================================

  IconData getEmotionIcon() {
    switch (widget.emotionName.toLowerCase()) {
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

  // ============================================================
  // WARNA EMOSI
  // ============================================================

  Color getEmotionColor() {
    switch (widget.emotionName.toLowerCase()) {
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

  // ============================================================
  // URUTKAN CERITA
  // ============================================================

  List<Map<String, dynamic>> sortStories(List<Map<String, dynamic>> stories) {
    final sortedStories = List<Map<String, dynamic>>.from(stories);

    sortedStories.sort((a, b) {
      final dateA =
          DateTime.tryParse(a['created_at']?.toString() ?? '') ??
          DateTime(2100);

      final dateB =
          DateTime.tryParse(b['created_at']?.toString() ?? '') ??
          DateTime(2100);

      return dateA.compareTo(dateB);
    });

    return sortedStories.take(5).toList();
  }

  // ============================================================
  // BUKA CERITA
  // ============================================================

  Future<void> openStory(Map<String, dynamic> story) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoryReaderPage(story: story)),
    );

    if (!mounted) return;

    // ==========================================================
    // SETELAH CERITA / QUIZ SELESAI
    // ==========================================================
    //
    // StoryReaderPage masuk ke Quiz.
    // Setelah Quiz selesai dan mengembalikan true,
    // kita langsung reload status unlock.
    //

    if (result == true) {
      await refreshStories();
    } else {
      // Tetap refresh kalau user kembali secara normal.
      await refreshStories();
    }
  }

  @override
  Widget build(BuildContext context) {
    final emotionColor = getEmotionColor();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: Padding(
          padding: const EdgeInsets.all(8.0),

          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDCE8F5), width: 1.5),
            ),

            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF1B3B6F),
                size: 20,
              ),

              onPressed: () async {
                // Sebelum kembali, pastikan data terbaru
                // sudah diambil.
                await refreshStories();

                if (!context.mounted) return;

                Navigator.pop(context);
              },
            ),
          ),
        ),

        title: const Text(
          'Pilih Cerita 📚',
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
          // ======================================================
          // LOADING
          // ======================================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: emotionColor),
            );
          }

          // ======================================================
          // ERROR
          // ======================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    const Text('😿', style: TextStyle(fontSize: 50)),

                    const SizedBox(height: 12),

                    const Text(
                      'Gagal memuat cerita.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B3B6F),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Coba muat ulang halaman.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8A9DBF),
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: refreshStories,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC928),
                        foregroundColor: const Color(0xFF1B3B6F),
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      child: const Text(
                        'Coba Lagi 🚀',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ======================================================
          // DATA
          // ======================================================

          final stories = sortStories(snapshot.data ?? []);

          if (stories.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Text('🌱', style: TextStyle(fontSize: 50)),

                    SizedBox(height: 12),

                    Text(
                      'Belum ada cerita untuk emosi ini.',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B3B6F),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ======================================================
          // HALAMAN
          // ======================================================

          return RefreshIndicator(
            onRefresh: refreshStories,
            color: emotionColor,

            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),

              children: [
                // ==================================================
                // HEADER
                // ==================================================

                Container(
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: emotionColor.withValues(alpha: 0.15),

                    borderRadius: BorderRadius.circular(28),

                    border: Border.all(
                      color: emotionColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 68,
                        height: 68,

                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,

                          boxShadow: [
                            BoxShadow(
                              color: emotionColor.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: Icon(
                          getEmotionIcon(),
                          size: 38,
                          color: emotionColor,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              widget.emotionName.toUpperCase(),

                              style: TextStyle(
                                color: emotionColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            const SizedBox(height: 4),

                            const Text(
                              'Pilih tahap cerita ✨',

                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1B3B6F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // 5 TAHAP
                // ==================================================
                ...List.generate(5, (index) {
                  final hasStory = index < stories.length;

                  final story = hasStory ? stories[index] : <String, dynamic>{};

                  final title = hasStory
                      ? story['title']?.toString() ?? 'Cerita'
                      : 'Cerita berikutnya';

                  // Status unlock dari StoryService
                  final isUnlocked = hasStory && story['is_unlocked'] == true;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),

                    child: _levelCard(
                      level: index + 1,
                      title: title,
                      isUnlocked: isUnlocked,
                      color: emotionColor,

                      onTap: isUnlocked ? () => openStory(story) : null,
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // LEVEL CARD
  // ============================================================

  Widget _levelCard({
    required int level,
    required String title,
    required bool isUnlocked,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: isUnlocked ? Colors.white : const Color(0xFFF0F4F8),

      borderRadius: BorderRadius.circular(24),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),

        child: Container(
          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),

            border: Border.all(
              color: isUnlocked
                  ? color.withValues(alpha: 0.35)
                  : const Color(0xFFDCE8F5),

              width: isUnlocked ? 2 : 1.5,
            ),

            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),

          child: Row(
            children: [
              // ==================================================
              // ICON
              // ==================================================

              Container(
                width: 60,
                height: 60,

                decoration: BoxDecoration(
                  color: isUnlocked
                      ? color.withValues(alpha: 0.15)
                      : const Color(0xFFDCE8F5),

                  shape: BoxShape.circle,
                ),

                child: Icon(
                  isUnlocked ? Icons.menu_book_rounded : Icons.lock_rounded,

                  color: isUnlocked ? color : const Color(0xFF8A9DBF),

                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // ==================================================
              // TEXT
              // ==================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Tahap $level',

                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,

                        color: isUnlocked ? color : const Color(0xFF8A9DBF),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      title,

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,

                        color: isUnlocked
                            ? const Color(0xFF1B3B6F)
                            : const Color(0xFF8A9DBF),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      isUnlocked ? 'Ayo mulai! ✨' : 'Terkunci 🔒',

                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,

                        color: isUnlocked
                            ? Colors.green.shade700
                            : const Color(0xFF8A9DBF),
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // ICON KANAN
              // ==================================================
              Container(
                width: 38,
                height: 38,

                decoration: BoxDecoration(
                  color: isUnlocked
                      ? color.withValues(alpha: 0.15)
                      : const Color(0xFFDCE8F5).withValues(alpha: 0.5),

                  shape: BoxShape.circle,
                ),

                child: Icon(
                  isUnlocked
                      ? Icons.arrow_forward_rounded
                      : Icons.lock_outline_rounded,

                  size: 18,

                  color: isUnlocked ? color : const Color(0xFF8A9DBF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
