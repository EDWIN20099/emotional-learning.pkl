import 'package:flutter/material.dart';

class EmotionDetailPage extends StatelessWidget {
  final Map<String, dynamic> emotion;

  const EmotionDetailPage({
    super.key,
    required this.emotion,
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

  String getHowToHandle(String name) {
    switch (name.toLowerCase()) {
      case 'senang':
        return 'Nikmati perasaan senangmu dan bagikan kebahagiaan kepada orang lain. Kamu juga bisa bersyukur atas hal-hal baik yang terjadi hari ini! ✨';

      case 'sedih':
        return 'Tidak apa-apa untuk merasa sedih. Cobalah bercerita kepada orang yang kamu percaya, menarik napas dengan tenang, atau melakukan kegiatan yang kamu sukai. 💙';

      case 'marah':
        return 'Saat marah, coba berhenti sejenak dan tarik napas dalam-dalam. Beri dirimu waktu untuk tenang sebelum berbicara atau mengambil keputusan. 🌟';

      case 'jijik':
        return 'Jika merasa jijik atau tidak nyaman, menjauhlah dari hal yang membuatmu tidak nyaman. Kamu juga bisa mengatakan perasaanmu dengan cara yang baik. 🌱';

      default:
        return 'Kenali perasaanmu dan cobalah mencari cara yang sehat untuk mengelolanya. 🚀';
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = emotion['name']?.toString() ?? 'Emosi';

    final description =
        emotion['description']?.toString() ??
        'Belum ada deskripsi untuk emosi ini.';

    final icon = getEmotionIcon(name);
    final color = getEmotionColor(name);
    final howToHandle = getHowToHandle(name);

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
          'Detail Emosi 🌈',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Color(0xFF1B3B6F),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Lingkaran Ikon Emosi yang Ceria
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.4),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 65,
                color: color,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1B3B6F),
              ),
            ),

            const SizedBox(height: 24),

            // Kartu Deskripsi Emosi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Apa itu emosi ini? 🤔',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B3B6F),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4A6572),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Kartu Cara Mengelola
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bagaimana cara mengelolanya? 💡',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B3B6F),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    howToHandle,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4A6572),
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
}