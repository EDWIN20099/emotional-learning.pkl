import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuizPage extends StatefulWidget {
  final Map<String, dynamic> story;

  const QuizPage({super.key, required this.story});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> questions = [];

  int currentQuestion = 0;
  int score = 0;

  bool isLoading = true;
  String? selectedAnswer;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  // =========================
  // LOAD QUESTIONS
  // =========================

  Future<void> loadQuestions() async {
    try {
      final storyId = widget.story['id']?.toString();

      debugPrint('STORY ID QUIZ: $storyId');

      if (storyId == null || storyId.isEmpty) {
        throw Exception('ID cerita tidak ditemukan.');
      }

      final data = await supabase
          .from('story_questions')
          .select()
          .eq('story_id', storyId)
          .order('id');

      debugPrint('JUMLAH SOAL: ${data.length}');

      if (!mounted) return;

      setState(() {
        questions = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('ERROR LOAD QUESTIONS: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat quiz: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // =========================
  // TENTUKAN REWARD
  // =========================

  String getRewardName() {
    final emotion = widget.story['emotions'];

    String emotionName = '';

    if (emotion is Map) {
      emotionName = emotion['name']?.toString().toLowerCase() ?? '';
    }

    switch (emotionName) {
      case 'senang':
        return 'Bunga Matahari';

      case 'sedih':
        return 'Bunga Tulip';

      case 'marah':
        return 'Bunga Mawar';

      case 'jijik':
        return 'Bunga Daisy';

      default:
        return 'Bunga Matahari';
    }
  }

  String getRewardEmoji() {
    final rewardName = getRewardName();

    switch (rewardName) {
      case 'Bunga Tulip':
        return '🌷';

      case 'Bunga Mawar':
        return '🌹';

      case 'Bunga Daisy':
        return '🌼';

      case 'Bunga Matahari':
      default:
        return '🌻';
    }
  }

  // =========================
  // SIMPAN REWARD
  // =========================

  Future<bool> saveReward() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        debugPrint('USER BELUM LOGIN');
        return false;
      }

      final storyId = widget.story['id']?.toString();

      if (storyId == null || storyId.isEmpty) {
        debugPrint('STORY ID TIDAK ADA');
        return false;
      }

      final rewardName = getRewardName();

      final existingReward = await supabase
          .from('user_rewards')
          .select('id')
          .eq('user_id', user.id)
          .eq('story_id', storyId)
          .maybeSingle();

      if (existingReward != null) {
        debugPrint('REWARD UNTUK CERITA INI SUDAH ADA');

        return false;
      }

      await supabase.from('user_rewards').insert({
        'user_id': user.id,
        'story_id': storyId,
        'reward_type': 'flower',
        'reward_name': rewardName,
        'reward_image': null,
      });

      debugPrint('REWARD BERHASIL DISIMPAN: $rewardName');

      return true;
    } catch (e) {
      debugPrint('ERROR SAVE REWARD: $e');
      return false;
    }
  }

  // =========================
  // CEK JAWABAN
  // =========================

  void checkAnswer() {
    if (selectedAnswer == null) return;

    final question = questions[currentQuestion];

    final correctAnswer = question['correct_answer']?.toString();

    if (selectedAnswer == correctAnswer) {
      score++;
    }

    if (currentQuestion == questions.length - 1) {
      showResult();
    } else {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
      });
    }
  }

  // =========================
  // HASIL QUIZ
  // =========================

  Future<void> showResult() async {
    final passed = score >= 3;

    bool newReward = false;

    if (passed) {
      newReward = await saveReward();
    }

    if (!mounted) return;

    final rewardName = getRewardName();
    final rewardEmoji = getRewardEmoji();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            passed
                ? newReward
                      ? '🎉 Hore, Lulus!'
                      : '🌟 Hebat, Lulus Lagi!'
                : '💪 Yuk, Coba Lagi!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: Color(0xFF1B3B6F),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD13B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$score / ${questions.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B3B6F),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                passed
                    ? newReward
                          ? 'Kamu hebat berhasil lulus quiz dan mendapatkan $rewardEmoji $rewardName!'
                          : 'Kamu sudah pernah mendapatkan $rewardEmoji $rewardName dari cerita ini.'
                    : 'Tidak apa-apa, tetap semangat ya! Yuk coba quiz sekali lagi. ✨',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8A9DBF),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC928),
                  foregroundColor: const Color(0xFF1B3B6F),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);

                  if (passed) {
                    Navigator.pop(context, true);
                  } else {
                    setState(() {
                      currentQuestion = 0;
                      score = 0;
                      selectedAnswer = null;
                    });
                  }
                },
                child: Text(
                  passed ? 'Selesai ✨' : 'Coba Lagi 🚀',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    final title = widget.story['title']?.toString() ?? 'Quiz Cerita';

    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFDF5),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Quiz Cerita 🧩',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B3B6F),
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF8E42)),
        ),
      );
    }

    if (questions.isEmpty) {
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
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          title: const Text(
            'Quiz Cerita 🧩',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B3B6F),
            ),
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🌱', style: TextStyle(fontSize: 50)),
                SizedBox(height: 12),
                Text(
                  'Belum ada pertanyaan untuk cerita ini.',
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
        ),
      );
    }

    final question = questions[currentQuestion];

    final questionText = question['question']?.toString() ?? '';

    final rawOptions = question['options'];

    final List<String> options = rawOptions is List
        ? rawOptions.take(4).map((option) => option.toString()).toList()
        : [];

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
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Quiz Seru 🧩',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Color(0xFF1B3B6F),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1B3B6F),
              ),
            ),

            const SizedBox(height: 6),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCE8F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Pertanyaan ${currentQuestion + 1} dari ${questions.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1B3B6F),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFDCE8F5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                questionText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B3B6F),
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 14),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: options.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 58,
              ),
              itemBuilder: (context, index) {
                final option = options[index];

                final isSelected = selectedAnswer == option;

                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedAnswer = option;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFF8E42)
                              : const Color(0xFFDCE8F5),
                          width: isSelected ? 2.5 : 2,
                        ),
                        color: isSelected
                            ? const Color(0xFFFF8E42).withValues(alpha: 0.08)
                            : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        option,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w900
                              : FontWeight.w700,
                          color: isSelected
                              ? const Color(0xFFFF8E42)
                              : const Color(0xFF1B3B6F),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedAnswer == null
                      ? const Color(0xFFE0E0E0)
                      : const Color(0xFFFFC928),
                  foregroundColor: const Color(0xFF1B3B6F),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: selectedAnswer == null ? null : checkAnswer,
                child: Text(
                  currentQuestion == questions.length - 1
                      ? 'Lihat Hasil 🌟'
                      : 'Berikutnya 🚀',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
