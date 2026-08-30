import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmotionPage extends StatefulWidget {
  const EmotionPage({super.key});

  @override
  State<EmotionPage> createState() => _EmotionPageState();
}

class _EmotionPageState extends State<EmotionPage>
    with SingleTickerProviderStateMixin {
  // =========================================================
  // COLOR PALETTE
  // =========================================================

  static const Color backgroundColor = Color(0xFFFFF9F0);
  static const Color navyColor = Color(0xFF203864);
  static const Color textSoft = Color(0xFF7183A0);

  static const Color yellowColor = Color(0xFFFFD54F);
  static const Color orangeColor = Color(0xFFFF9364);
  static const Color blueColor = Color(0xFF62C7FF);
  static const Color greenColor = Color(0xFF66D39A);
  static const Color pinkColor = Color(0xFFFF8FB1);
  static const Color purpleColor = Color(0xFFA98CFF);

  // =========================================================
  // SUPABASE
  // =========================================================

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> emotions = [];
  bool isLoading = true;

  // =========================================================
  // ANIMATION
  // =========================================================

  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    loadEmotions();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  // =========================================================
  // LOAD EMOTIONS
  // =========================================================

  Future<void> loadEmotions() async {
    try {
      final data = await supabase
          .from('emotions')
          .select()
          .order('name');

      if (!mounted) return;

      setState(() {
        emotions = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil emosi: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  // =========================================================
  // EMOTION ICON
  // =========================================================

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

  // =========================================================
  // EMOTION COLOR
  // =========================================================

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
        return orangeColor;
    }
  }

  // =========================================================
  // EMOTION LIGHT COLOR
  // =========================================================

  Color getEmotionLightColor(String name) {
    switch (name.toLowerCase()) {
      case 'senang':
        return const Color(0xFFFFF2C2);

      case 'sedih':
        return const Color(0xFFE0F3FF);

      case 'marah':
        return const Color(0xFFFFE3E1);

      case 'jijik':
        return const Color(0xFFE1F7E8);

      default:
        return const Color(0xFFFFE5D7);
    }
  }

  // =========================================================
  // EMOTION DESCRIPTION / TIP
  // =========================================================

  String getEmotionTip(String name) {
    switch (name.toLowerCase()) {
      case 'senang':
        return 'Wah, kamu sedang merasa senang! 🌟 '
            'Nikmati perasaan positifmu dan jangan lupa berbagi kebahagiaan dengan orang lain.';

      case 'sedih':
        return 'Tidak apa-apa merasa sedih. 💙 '
            'Cobalah bercerita kepada orang yang kamu percaya dan lakukan sesuatu yang membuatmu nyaman.';

      case 'marah':
        return 'Kamu sedang merasa marah. ❤️‍🩹 '
            'Coba tarik napas perlahan dan beri dirimu waktu untuk tenang sebelum melakukan sesuatu.';

      case 'jijik':
        return 'Kamu merasa tidak nyaman atau jijik. 🌱 '
            'Jauhi hal yang membuatmu tidak nyaman dan ceritakan perasaanmu dengan cara yang baik.';

      default:
        return 'Tidak apa-apa merasakan emosi apa pun. '
            'Yuk kenali perasaanmu dan belajar mengelolanya dengan baik.';
    }
  }

  // =========================================================
  // SELECT EMOTION
  // =========================================================

  Future<void> selectEmotion(Map<String, dynamic> emotion) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Silakan login terlebih dahulu.',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

      return;
    }

    try {
      await supabase.from('user_emotions').insert({
        'user_id': user.id,
        'emotion_id': emotion['id'],
      });

      if (!mounted) return;

      final name = emotion['name']?.toString() ?? 'emosi';
      final color = getEmotionColor(name);

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return _emotionDialog(
            name: name,
            color: color,
          );
        },
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/home-main',
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan emosi: $e',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  // =========================================================
  // EMOTION DIALOG
  // =========================================================

  Widget _emotionDialog({
    required String name,
    required Color color,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 35,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          24,
          25,
          24,
          22,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.18),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                ),

                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.30),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    getEmotionIcon(name),
                    size: 46,
                    color: color,
                  ),
                ),

                Positioned(
                  top: 0,
                  right: 0,
                  child: _sparkle(
                    size: 20,
                    color: color,
                    delay: 0.2,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              'Kamu sedang $name! ✨',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
                color: navyColor,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              getEmotionTip(name),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: textSoft,
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Mengerti 👍',
                  style: TextStyle(
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
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // =====================================================
            // BACKGROUND DECORATIONS
            // =====================================================

            Positioned(
              top: -35,
              right: -35,
              child: _decorativeCircle(
                size: 125,
                color: const Color(0xFFFFE7A3),
              ),
            ),

            Positioned(
              top: 155,
              left: -45,
              child: _decorativeCircle(
                size: 100,
                color: const Color(0xFFDDF5FF),
              ),
            ),

            Positioned(
              bottom: 50,
              right: -45,
              child: _decorativeCircle(
                size: 115,
                color: const Color(0xFFE9DEFF),
              ),
            ),

            // =====================================================
            // MAIN CONTENT
            // =====================================================

            isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: orangeColor,
                    ),
                  )
                : emotions.isEmpty
                    ? _emptyState()
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          18,
                          20,
                          35,
                        ),
                        children: [
                          // =================================================
                          // HEADER
                          // =================================================

                          Row(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFE77A),
                                      Color(0xFFFFC83D),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: yellowColor.withValues(
                                        alpha: 0.28,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    '🌈',
                                    style: TextStyle(
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 13),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kenali Emosimu',
                                      style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w900,
                                        color: navyColor,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Kenali • Rasakan • Kelola ✨',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: textSoft,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              _floatingEmoji(
                                emoji: '✨',
                                size: 25,
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // =================================================
                          // HERO CARD
                          // =================================================

                          _heroCard(),

                          const SizedBox(height: 27),

                          // =================================================
                          // SECTION TITLE
                          // =================================================

                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 27,
                                decoration: BoxDecoration(
                                  color: purpleColor,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),

                              const SizedBox(width: 10),

                              const Expanded(
                                child: Text(
                                  'Pilih Perasaanmu!',
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                    color: navyColor,
                                  ),
                                ),
                              ),

                              _floatingEmoji(
                                emoji: '💖',
                                size: 24,
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),

                          const Padding(
                            padding: EdgeInsets.only(left: 17),
                            child: Text(
                              'Tidak ada jawaban yang salah. Semua emosi itu penting! 🌱',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: textSoft,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // =================================================
                          // EMOTION CARDS
                          // =================================================

                          ...emotions.asMap().entries.map(
                            (entry) {
                              final index = entry.key;
                              final emotion = entry.value;

                              final name =
                                  emotion['name']?.toString() ??
                                      'Emosi';

                              final description =
                                  emotion['description']
                                          ?.toString() ??
                                      '';

                              final color =
                                  getEmotionColor(name);

                              final lightColor =
                                  getEmotionLightColor(name);

                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 15,
                                ),
                                child: _emotionCard(
                                  name: name,
                                  description: description,
                                  color: color,
                                  lightColor: lightColor,
                                  icon: getEmotionIcon(name),
                                  delay: index * 0.25,
                                  onTap: () {
                                    selectEmotion(emotion);
                                  },
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 5),

                          // =================================================
                          // BOTTOM MESSAGE
                          // =================================================

                          _bottomMessage(),
                        ],
                      ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HERO CARD
  // =========================================================

  Widget _heroCard() {
    return Container(
      height: 190,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFE98A),
            Color(0xFFFFC85A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC83D).withValues(
              alpha: 0.25,
            ),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -30,
            child: _decorativeCircle(
              size: 105,
              color: Colors.white.withValues(alpha: 0.20),
            ),
          ),

          Positioned(
            left: -25,
            bottom: -40,
            child: _decorativeCircle(
              size: 85,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),

          // Sparkles
          Positioned(
            top: 15,
            right: 130,
            child: _sparkle(
              size: 20,
              color: Colors.white,
              delay: 0.0,
            ),
          ),

          Positioned(
            top: 40,
            right: 20,
            child: _sparkle(
              size: 15,
              color: Colors.white,
              delay: 0.3,
            ),
          ),

          Positioned(
            bottom: 22,
            right: 105,
            child: _sparkle(
              size: 17,
              color: Colors.white,
              delay: 0.6,
            ),
          ),

          Positioned(
            bottom: 48,
            right: 25,
            child: _sparkle(
              size: 11,
              color: const Color(0xFFFFF4B0),
              delay: 0.8,
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              22,
              18,
              15,
              16,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        '🌟 Petualangan Emosi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF805D00),
                        ),
                      ),

                      SizedBox(height: 9),

                      Text(
                        'Bagaimana\nperasaanmu?',
                        style: TextStyle(
                          fontSize: 26,
                          height: 1.05,
                          fontWeight: FontWeight.w900,
                          color: navyColor,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        'Yuk pilih emosi yang\npaling kamu rasakan! 🌈',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF806000),
                        ),
                      ),
                    ],
                  ),
                ),

                // =================================================
                // EMOJI
                // =================================================

                SizedBox(
                  width: 110,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _sparkleController,
                        builder: (context, child) {
                          final value =
                              (math.sin(
                                        _sparkleController
                                                .value *
                                            math.pi *
                                            2,
                                      ) +
                                      1) /
                                  2;

                          return Container(
                            width: 85 + (value * 10),
                            height: 85 + (value * 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(
                                alpha: 0.13 + (value * 0.10),
                              ),
                            ),
                          );
                        },
                      ),

                      Container(
                        width: 102,
                        height: 102,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.88,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.08,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '🥰',
                            style: TextStyle(
                              fontSize: 54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EMOTION CARD
  // =========================================================

  Widget _emotionCard({
    required String name,
    required String description,
    required Color color,
    required Color lightColor,
    required IconData icon,
    required double delay,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(27),
        splashColor: color.withValues(alpha: 0.10),
        highlightColor: color.withValues(alpha: 0.05),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(27),
                border: Border.all(
                  color: lightColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.12),
                    blurRadius: 17,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // =================================================
                  // ICON
                  // =================================================

                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: lightColor,
                          borderRadius:
                              BorderRadius.circular(23),
                        ),
                        child: Center(
                          child: Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius:
                                  BorderRadius.circular(19),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      color.withValues(
                                    alpha: 0.28,
                                  ),
                                  blurRadius: 9,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              icon,
                              size: 34,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        right: -5,
                        top: -8,
                        child: _sparkle(
                          size: 16,
                          color: color,
                          delay: delay,
                        ),
                      ),

                      Positioned(
                        left: -5,
                        bottom: -5,
                        child: _sparkle(
                          size: 10,
                          color: color,
                          delay: delay + 0.35,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 15),

                  // =================================================
                  // TEXT
                  // =================================================

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: lightColor,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            _emotionBadge(name),
                            style: TextStyle(
                              fontSize: 8.5,
                              letterSpacing: 0.4,
                              fontWeight: FontWeight.w900,
                              color: color,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: navyColor,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: textSoft,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 7),

                  // =================================================
                  // ARROW
                  // =================================================

                  Container(
                    width: 39,
                    height: 39,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(
                            alpha: 0.22,
                          ),
                          blurRadius: 7,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // EMOTION BADGE
  // =========================================================

  String _emotionBadge(String name) {
    switch (name.toLowerCase()) {
      case 'senang':
        return 'PERASAAN POSITIF';

      case 'sedih':
        return 'BUTUH KENYAMANAN';

      case 'marah':
        return 'BUTUH KETENANGAN';

      case 'jijik':
        return 'RASA TIDAK NYAMAN';

      default:
        return 'KENALI EMOSIMU';
    }
  }

  // =========================================================
  // BOTTOM MESSAGE
  // =========================================================

  Widget _bottomMessage() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF0F5),
            Color(0xFFFFF8FB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(
          color: const Color(0xFFFFD7E4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: pinkColor.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: pinkColor.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '💖',
                style: TextStyle(
                  fontSize: 29,
                ),
              ),
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingat ya! ✨',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: navyColor,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Semua perasaan itu penting. '
                  'Kamu hebat karena mau mengenali emosimu! 🌷',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: textSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EMPTY STATE
  // =========================================================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFFE6EEF7),
              width: 2,
            ),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🌱',
                style: TextStyle(
                  fontSize: 55,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Belum ada data emosi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: navyColor,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Data emosi belum tersedia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // ANIMATED SPARKLE
  // =========================================================

  Widget _sparkle({
    required double size,
    required Color color,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        final progress =
            (_sparkleController.value + delay) % 1.0;

        final opacity =
            (math.sin(progress * math.pi * 2) + 1) / 2;

        final scale =
            0.65 + (opacity * 0.55);

        return Opacity(
          opacity: 0.25 + (opacity * 0.75),
          child: Transform.scale(
            scale: scale,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: size,
              color: color,
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // FLOATING EMOJI
  // =========================================================

  Widget _floatingEmoji({
    required String emoji,
    required double size,
  }) {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        final movement =
            math.sin(
                  _sparkleController.value *
                      math.pi *
                      2,
                ) *
                3;

        return Transform.translate(
          offset: Offset(0, movement),
          child: Text(
            emoji,
            style: TextStyle(
              fontSize: size,
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // DECORATIVE CIRCLE
  // =========================================================

  Widget _decorativeCircle({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}