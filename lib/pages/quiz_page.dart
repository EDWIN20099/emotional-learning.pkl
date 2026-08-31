import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuizPage extends StatefulWidget {
  final Map<String, dynamic> story;

  const QuizPage({super.key, required this.story});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> questions = [];

  int currentQuestion = 0;
  int score = 0;

  bool isLoading = true;
  String? selectedAnswer;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  // ============================================================
  // LOAD QUESTIONS
  // ============================================================

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

  // ============================================================
  // TENTUKAN REWARD
  // ============================================================

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

  // ============================================================
  // EMOJI REWARD
  // ============================================================

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

  // ============================================================
  // DESKRIPSI REWARD
  // ============================================================

  String getRewardDescription() {
    final rewardName = getRewardName();

    switch (rewardName) {
      case 'Bunga Tulip':
        return 'Bunga Tulip siap menghiasi taman emosimu!';

      case 'Bunga Mawar':
        return 'Bunga Mawar siap menghiasi taman emosimu!';

      case 'Bunga Daisy':
        return 'Bunga Daisy siap menghiasi taman emosimu!';

      case 'Bunga Matahari':
      default:
        return 'Bunga Matahari siap menghiasi taman emosimu!';
    }
  }

  // ============================================================
  // SIMPAN REWARD
  // ============================================================

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

      // --------------------------------------------------------
      // CEK REWARD YANG SUDAH PERNAH DIDAPAT
      // --------------------------------------------------------

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

      // --------------------------------------------------------
      // SIMPAN REWARD
      // --------------------------------------------------------

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

  // ============================================================
  // CEK JAWABAN
  // ============================================================

  void checkAnswer() {
    if (selectedAnswer == null) {
      return;
    }

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

  // ============================================================
  // HASIL QUIZ
  // ============================================================

  Future<void> showResult() async {
    final passed = score >= 3;

    bool newReward = false;

    if (passed) {
      newReward = await saveReward();
    }

    if (!mounted) return;

    final rewardName = getRewardName();

    final rewardEmoji = getRewardEmoji();

    final rewardDescription = getRewardDescription();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _ResultDialog(
          passed: passed,
          newReward: newReward,
          score: score,
          totalQuestions: questions.length,
          rewardName: rewardName,
          rewardEmoji: rewardEmoji,
          rewardDescription: rewardDescription,
          onFinish: () {
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
        );
      },
    );
  }

  // ============================================================
  // BACK BUTTON
  // ============================================================

  Widget buildBackButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget buildLoading() {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: buildBackButton(),
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

  // ============================================================
  // EMPTY QUIZ
  // ============================================================

  Widget buildEmptyQuiz() {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: buildBackButton(),
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
          padding: EdgeInsets.all(24),
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

  // ============================================================
  // OPTION CARD
  // ============================================================

  Widget buildOptionCard(String option) {
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
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              color: isSelected
                  ? const Color(0xFFFF8E42)
                  : const Color(0xFF1B3B6F),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MAIN QUIZ
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final title = widget.story['title']?.toString() ?? 'Quiz Cerita';

    if (isLoading) {
      return buildLoading();
    }

    if (questions.isEmpty) {
      return buildEmptyQuiz();
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
        leading: buildBackButton(),
        title: const Text(
          'Quiz Seru 🧩',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Color(0xFF1B3B6F),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isLandscape ? 18 : 20,
              isLandscape ? 4 : 10,
              isLandscape ? 18 : 20,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --------------------------------------------------------
                // JUDUL CERITA
                // --------------------------------------------------------

                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isLandscape ? 19 : 22,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1B3B6F),
                  ),
                ),

                const SizedBox(height: 6),

                // --------------------------------------------------------
                // NOMOR SOAL
                // --------------------------------------------------------
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
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
                ),

                SizedBox(height: isLandscape ? 10 : 18),

                // --------------------------------------------------------
                // QUESTION
                // --------------------------------------------------------
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLandscape ? 16 : 16,
                    vertical: isLandscape ? 11 : 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFDCE8F5),
                      width: 2,
                    ),
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
                    style: TextStyle(
                      fontSize: isLandscape ? 14 : 16,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1B3B6F),
                      height: 1.4,
                    ),
                  ),
                ),

                SizedBox(height: isLandscape ? 10 : 14),

                // --------------------------------------------------------
                // OPTIONS
                // --------------------------------------------------------
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 10,
                    mainAxisExtent: isLandscape ? 52 : 58,
                  ),
                  itemBuilder: (context, index) {
                    return buildOptionCard(options[index]);
                  },
                ),

                SizedBox(height: isLandscape ? 12 : 18),

                // --------------------------------------------------------
                // BUTTON
                // --------------------------------------------------------
                SizedBox(
                  height: isLandscape ? 50 : 56,
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
          );
        },
      ),
    );
  }
}

// ============================================================================
// RESULT DIALOG
// ============================================================================

class _ResultDialog extends StatelessWidget {
  final bool passed;
  final bool newReward;
  final int score;
  final int totalQuestions;
  final String rewardName;
  final String rewardEmoji;
  final String rewardDescription;
  final VoidCallback onFinish;

  const _ResultDialog({
    required this.passed,
    required this.newReward,
    required this.score,
    required this.totalQuestions,
    required this.rewardName,
    required this.rewardEmoji,
    required this.rewardDescription,
    required this.onFinish,
  });

  // ============================================================
  // SCORE CARD
  // ============================================================

  Widget buildScoreCard(bool isLandscape) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isLandscape ? 8 : 12,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4CE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD95A), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          const Text(
            'Nilai kamu',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF8B6914),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$score / $totalQuestions',
            style: TextStyle(
              fontSize: isLandscape ? 22 : 26,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1B3B6F),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REWARD CARD
  // ============================================================

  Widget buildRewardCard(bool isLandscape) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 18 : 20,
        vertical: isLandscape ? 10 : 15,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8D7), Color(0xFFE6F8E8)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ------------------------------------------------------
          // HADIAH
          // ------------------------------------------------------

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC928),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '🎁 HADIAH UNTUKMU!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Color(0xFF7A5A00),
              ),
            ),
          ),

          SizedBox(height: isLandscape ? 4 : 7),

          // ------------------------------------------------------
          // EMOJI BUNGA BESAR
          // ------------------------------------------------------
          Text(rewardEmoji, style: TextStyle(fontSize: isLandscape ? 55 : 68)),

          // ------------------------------------------------------
          // LABEL
          // ------------------------------------------------------
          const Text(
            'KAMU MENDAPATKAN',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: Color(0xFF66809F),
            ),
          ),

          const SizedBox(height: 2),

          // ------------------------------------------------------
          // NAMA BUNGA - BESAR & JELAS
          // ------------------------------------------------------
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              rewardName,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isLandscape ? 22 : 25,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1B3B6F),
              ),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            rewardDescription,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: Color(0xFF789080),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FAILED CARD
  // ============================================================

  Widget buildFailedCard(bool isLandscape) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 18,
        vertical: isLandscape ? 11 : 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F0),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD5C7), width: 2),
      ),
      child: Column(
        children: [
          Text('🌱', style: TextStyle(fontSize: isLandscape ? 38 : 46)),
          const SizedBox(height: 4),
          const Text(
            'Belum dapat bunga kali ini',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B3B6F),
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Tidak apa-apa! Yuk belajar dan coba lagi 💪✨',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF789080),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape =
              MediaQuery.of(context).size.width >
              MediaQuery.of(context).size.height;

          return Container(
            constraints: const BoxConstraints(maxWidth: 470),
            padding: EdgeInsets.fromLTRB(
              isLandscape ? 20 : 22,
              isLandscape ? 14 : 18,
              isLandscape ? 20 : 22,
              isLandscape ? 12 : 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF5),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ======================================================
                  // TITLE
                  // ======================================================

                  Text(
                    passed
                        ? newReward
                              ? '🎉 Hore, Kamu Hebat!'
                              : '🌟 Hebat, Lulus Lagi!'
                        : '💪 Yuk, Coba Lagi!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isLandscape ? 20 : 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1B3B6F),
                    ),
                  ),

                  SizedBox(height: isLandscape ? 8 : 12),

                  // ======================================================
                  // REWARD
                  // ======================================================
                  if (passed && newReward) buildRewardCard(isLandscape),

                  if (passed && !newReward)
                    Column(
                      children: [
                        buildScoreCard(isLandscape),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF8FF),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            '🌸 Kamu sudah mendapatkan '
                            '$rewardEmoji $rewardName dari cerita ini.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF66809F),
                            ),
                          ),
                        ),
                      ],
                    ),

                  // ======================================================
                  // SCORE UNTUK REWARD BARU
                  // ======================================================
                  if (passed && newReward)
                    Padding(
                      padding: const EdgeInsets.only(top: 9),
                      child: buildScoreCard(isLandscape),
                    ),

                  // ======================================================
                  // GAGAL
                  // ======================================================
                  if (!passed)
                    Column(
                      children: [
                        buildScoreCard(isLandscape),
                        const SizedBox(height: 10),
                        buildFailedCard(isLandscape),
                      ],
                    ),

                  SizedBox(height: isLandscape ? 10 : 14),

                  // ======================================================
                  // BUTTON SELESAI / COBA LAGI
                  // ======================================================
                  SizedBox(
                    width: double.infinity,
                    height: isLandscape ? 48 : 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC928),
                        foregroundColor: const Color(0xFF1B3B6F),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: onFinish,
                      child: Text(
                        passed ? 'Selesai ✨' : 'Coba Lagi 🚀',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
