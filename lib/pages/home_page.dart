import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // =========================================================
  // COLOR PALETTE (disamakan dengan halaman lain)
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

  Future<void> logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Keluar dari akun?',
            style: TextStyle(fontWeight: FontWeight.w900, color: navyColor),
          ),
          content: const Text(
            'Kamu yakin ingin keluar dari Emotional Learning?',
            style: TextStyle(fontSize: 14, color: textSoft, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Batal',
                style: TextStyle(fontWeight: FontWeight.w700, color: textSoft),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
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

    if (shouldLogout == true && context.mounted) {
      await logout(context);
    }
  }

  // =========================================================
  // DECORATIVE CIRCLE
  // =========================================================

  Widget _decorativeCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // =========================================================
  // QUICK ACTION CARD
  // =========================================================

  Widget _quickAction({
    required BuildContext context,
    required String emoji,
    required String label,
    required Color color,
    required String routeName,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, routeName),
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: color.withValues(alpha: 0.25),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: navyColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['name'] ?? 'Sahabat Kecil';

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
              top: 210,
              left: -45,
              child: _decorativeCircle(
                size: 100,
                color: const Color(0xFFDDF5FF),
              ),
            ),
            Positioned(
              bottom: 30,
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
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 35),
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
                          colors: [Color(0xFFFFE77A), Color(0xFFFFC83D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: yellowColor.withValues(alpha: 0.28),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🧸', style: TextStyle(fontSize: 30)),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dunia Emosi',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: navyColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Halo, $name 👋',
                            style: const TextStyle(
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
                        onTap: () => _showLogoutConfirmation(context),
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
                                color: orangeColor.withValues(alpha: 0.15),
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
                // WELCOME HERO CARD
                // =================================================
                Container(
                  padding: const EdgeInsets.all(24),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE98A), Color(0xFFFFC85A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: yellowColor.withValues(alpha: 0.30),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        right: -10,
                        top: -18,
                        child: Text(
                          '🌈',
                          style: TextStyle(
                            fontSize: 70,
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'SELAMAT DATANG',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: navyColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Halo, $name! ✨',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: navyColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Yuk lanjut bermain dan belajar'
                            'mengenal perasaanmu hari ini! 🎈',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF7A5B12),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // =================================================
                // QUICK ACTIONS
                // =================================================
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    'Mau main apa hari ini?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: navyColor,
                    ),
                  ),
                ),

                Row(
                  children: [
                    _quickAction(
                      context: context,
                      emoji: '🙂',
                      label: 'Emosiku',
                      color: orangeColor,
                      routeName: '/emotion',
                    ),
                    const SizedBox(width: 12),
                    _quickAction(
                      context: context,
                      emoji: '🏡',
                      label: 'Beranda',
                      color: blueColor,
                      routeName: '/home-main',
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // =================================================
                // BOTTOM MESSAGE
                // =================================================
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF0F5), Color(0xFFFFF8FB)],
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
                          child: Text('💖', style: TextStyle(fontSize: 29)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              'Kamu hebat karena mau belajar mengenalinya! 🌷',
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
