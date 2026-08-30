import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'emotion_story_page.dart';
import 'garden_page.dart';
import 'emotion_gallery_page.dart';

class HomeMainPage extends StatefulWidget {
  const HomeMainPage({super.key});

  @override
  State<HomeMainPage> createState() => _HomeMainPageState();
}

class _HomeMainPageState extends State<HomeMainPage>
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

  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal logout: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> showLogoutConfirmation() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Keluar dari akun?',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: navyColor,
            ),
          ),
          content: const Text(
            'Kamu yakin ingin keluar dari Emotional Learning?',
            style: TextStyle(
              fontSize: 14,
              color: textSoft,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: textSoft,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(
                Icons.logout_rounded,
                size: 18,
              ),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: orangeColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await logout();
    }
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
                size: 120,
                color: const Color(0xFFFFE7A3),
              ),
            ),

            Positioned(
              top: 190,
              left: -45,
              child: _decorativeCircle(
                size: 100,
                color: const Color(0xFFDDF5FF),
              ),
            ),

            Positioned(
              bottom: 80,
              right: -40,
              child: _decorativeCircle(
                size: 110,
                color: const Color(0xFFE9DEFF),
              ),
            ),

            // =====================================================
            // MAIN CONTENT
            // =====================================================

            ListView(
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
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: yellowColor.withValues(alpha: 0.28),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '🧸',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 13),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dunia Emosi',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: navyColor,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Belajar • Bermain • Bertumbuh ✨',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: textSoft,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =================================================
                    // LOGOUT BUTTON
                    // =================================================

                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: showLogoutConfirmation,
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFFFD9CC),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: orangeColor.withValues(
                                  alpha: 0.15,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: orangeColor,
                            size: 27,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // =================================================
                // HERO / MOOD ADVENTURE
                // =================================================

                Container(
                  height: 205,
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
                        top: -35,
                        child: _decorativeCircle(
                          size: 100,
                          color: Colors.white.withValues(alpha: 0.20),
                        ),
                      ),

                      Positioned(
                        right: 75,
                        bottom: -35,
                        child: _decorativeCircle(
                          size: 75,
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),

                      // =================================================
                      // ANIMATED SPARKLES AROUND LION
                      // =================================================

                      Positioned(
                        top: 17,
                        right: 122,
                        child: _sparkle(
                          size: 20,
                          color: Colors.white,
                          delay: 0.0,
                        ),
                      ),

                      Positioned(
                        top: 45,
                        right: 17,
                        child: _sparkle(
                          size: 15,
                          color: Colors.white,
                          delay: 0.35,
                        ),
                      ),

                      Positioned(
                        top: 103,
                        right: 6,
                        child: _sparkle(
                          size: 11,
                          color: const Color(0xFFFFF8D6),
                          delay: 0.7,
                        ),
                      ),

                      Positioned(
                        bottom: 20,
                        right: 110,
                        child: _sparkle(
                          size: 17,
                          color: Colors.white,
                          delay: 0.5,
                        ),
                      ),

                      Positioned(
                        bottom: 48,
                        right: 28,
                        child: _sparkle(
                          size: 10,
                          color: const Color(0xFFFFF4B0),
                          delay: 0.9,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          22,
                          20,
                          16,
                          18,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.65,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(30),
                                    ),
                                    child: const Text(
                                      '👋 Hai, Teman!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF805D00),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 11),

                                  const Text(
                                    'Bagaimana\nperasaanmu?',
                                    style: TextStyle(
                                      fontSize: 27,
                                      height: 1.05,
                                      fontWeight: FontWeight.w900,
                                      color: navyColor,
                                    ),
                                  ),

                                  const SizedBox(height: 9),

                                  const Text(
                                    'Yuk kenali emosimu\nhari ini! 🌈',
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.3,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF806000),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // =================================================
                            // LION
                            // =================================================

                            SizedBox(
                              width: 108,
                              height: 125,
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
                                        width: 91 + (value * 10),
                                        height: 91 + (value * 10),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withValues(
                                            alpha:
                                                0.14 + (value * 0.10),
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  Container(
                                    width: 105,
                                    height: 105,
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
                                        '🦁',
                                        style: TextStyle(
                                          fontSize: 56,
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
                ),

                const SizedBox(height: 28),

                // =================================================
                // SECTION HEADER
                // =================================================

                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 27,
                      decoration: BoxDecoration(
                        color: purpleColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Pilih Petualanganmu!',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: navyColor,
                        ),
                      ),
                    ),
                    _floatingEmoji(
                      emoji: '🚀',
                      size: 24,
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                const Padding(
                  padding: EdgeInsets.only(left: 17),
                  child: Text(
                    'Ada banyak hal seru yang bisa kamu jelajahi!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textSoft,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // =================================================
                // CERITA
                // =================================================

                _menuCard(
                  context,
                  emoji: '📖',
                  title: 'Cerita Seru',
                  subtitle: 'Jelajahi cerita dan\njawab kuisnya!',
                  color: orangeColor,
                  lightColor: const Color(0xFFFFE5D7),
                  badge: 'PETUALANGAN',
                  sparkleColor: const Color(0xFFFFB07C),
                  delay: 0.0,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const EmotionStoryPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 15),

                // =================================================
                // GALERI EMOSI
                // =================================================

                _menuCard(
                  context,
                  emoji: '🌈',
                  title: 'Galeri Emosi',
                  subtitle:
                      'Kenali perasaan dan\ncara menghadapinya!',
                  color: blueColor,
                  lightColor: const Color(0xFFDDF4FF),
                  badge: 'KENALI EMOSI',
                  sparkleColor: const Color(0xFF9BDFFF),
                  delay: 0.45,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const EmotionGalleryPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 15),

                // =================================================
                // GARDEN
                // =================================================

                _menuCard(
                  context,
                  emoji: '🌻',
                  title: 'Taman Emosi',
                  subtitle:
                      'Kumpulkan bunga dan\nlihat hadiahmu!',
                  color: greenColor,
                  lightColor: const Color(0xFFDDF7E9),
                  badge: 'KOLEKSI HADIAH',
                  sparkleColor: const Color(0xFFA6E8BE),
                  delay: 0.9,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const GardenPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 22),

                // =================================================
                // MOTIVATION CARD
                // =================================================

                Container(
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
                              'Pesan Hari Ini ✨',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: navyColor,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Semua perasaan itu penting. '
                              'Tidak apa-apa merasakan semuanya! 🌷',
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
                ),

                const SizedBox(height: 18),

                // =================================================
                // FOOTER
                // =================================================

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      '🌱',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 7),
                    Text(
                      'Terus belajar mengenal dirimu!',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF91A17F),
                      ),
                    ),
                    SizedBox(width: 7),
                    Text(
                      '🌱',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ],
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
        double progress =
            (_sparkleController.value + delay) % 1.0;

        double opacity =
            (math.sin(progress * math.pi * 2) + 1) / 2;

        double scale =
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
  // MENU CARD
  // =========================================================

  Widget _menuCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required Color lightColor,
    required String badge,
    required Color sparkleColor,
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
                  // ICON AREA
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
                                  color: color.withValues(
                                    alpha: 0.28,
                                  ),
                                  blurRadius: 9,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(
                                  fontSize: 31,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        right: -5,
                        top: -8,
                        child: _sparkle(
                          size: 16,
                          color: sparkleColor,
                          delay: delay,
                        ),
                      ),

                      Positioned(
                        left: -5,
                        bottom: -5,
                        child: _sparkle(
                          size: 10,
                          color: sparkleColor,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: lightColor,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            badge,
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
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: navyColor,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          subtitle,
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
                          color: color.withValues(alpha: 0.22),
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