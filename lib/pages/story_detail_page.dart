import 'package:flutter/material.dart';
import 'quiz_page.dart';

class StoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> story;

  const StoryDetailPage({
    super.key,
    required this.story,
  });

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
    final emotion = story['emotions'];

    final emotionName = emotion is Map
        ? emotion['name']?.toString() ?? 'Emosi'
        : 'Emosi';

    final title =
        story['title']?.toString() ?? 'Tanpa Judul';

    final content =
        story['content']?.toString() ?? '';

    final emotionColor =
        getEmotionColor(emotionName);

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
          'Detail Cerita 📖',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Color(0xFF1B3B6F),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          32,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // =========================
            // HEADER CERITA
            // =========================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: emotionColor.withValues(
                  alpha: 0.15,
                ),
                borderRadius:
                    BorderRadius.circular(28),
                border: Border.all(
                  color: emotionColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
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
                      getEmotionIcon(
                        emotionName,
                      ),
                      size: 42,
                      color: emotionColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: emotionColor,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      emotionName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 1.3,
                      fontWeight:
                          FontWeight.w900,
                      color: Color(0xFF1B3B6F),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // ISI CERITA
            // =========================

            const Text(
              'Baca ceritanya 📖',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1B3B6F),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFDCE8F5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4A6572),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // INFO QUIZ
            // =========================

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE066).withValues(alpha: 0.3),
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFFC928).withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    '💡',
                    style: TextStyle(fontSize: 28),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Sudah selesai membaca? Yuk coba quiz untuk menguji pemahamanmu! ✨',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        fontWeight:
                            FontWeight.w900,
                        color: Color(0xFF855D00),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // TOMBOL QUIZ
            // =========================

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final result =
                      await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          QuizPage(
                        story: story,
                      ),
                    ),
                  );

                  // Quiz mengembalikan true
                  // jika user berhasil/lulus.
                  if (result == true &&
                      context.mounted) {
                    Navigator.pop(
                      context,
                      true,
                    );
                  }
                },
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC928),
                  foregroundColor: const Color(0xFF1B3B6F),
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lanjut ke Quiz 🧩',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}