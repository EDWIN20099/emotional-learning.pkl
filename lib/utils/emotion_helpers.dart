import 'package:flutter/material.dart';

/// =====================================================================
/// EMOTION HELPERS
/// =====================================================================
/// Dipakai di semua halaman yang menampilkan data emosi (emotion_page,
/// emotion_gallery_page, emotion_detail_page, story_page, story_detail_page)
/// biar konsisten dan sumbernya cuma 1 tempat.
///
/// Semua data (icon_name, color_hex, light_color_hex, how_to_handle)
/// diambil dari tabel `emotions` di Supabase. Warna dan teks 100% bebas
/// diubah dari Supabase tanpa sentuh kode. Icon harus salah satu nama
/// yang sudah didaftarkan di _iconMap di bawah (lihat catatan di SQL).
/// =====================================================================

class EmotionHelpers {
  // Kalau mau nambah icon baru yang bisa dipakai dari Supabase,
  // tambahin 1 baris di sini.
  static const Map<String, IconData> _iconMap = {
    'sentiment_very_satisfied_rounded': Icons.sentiment_very_satisfied_rounded,
    'sentiment_satisfied_rounded': Icons.sentiment_satisfied_rounded,
    'sentiment_neutral_rounded': Icons.sentiment_neutral_rounded,
    'sentiment_dissatisfied_rounded': Icons.sentiment_dissatisfied_rounded,
    'sentiment_very_dissatisfied_rounded':
        Icons.sentiment_very_dissatisfied_rounded,
    'sick_rounded': Icons.sick_rounded,
    'mood_bad_rounded': Icons.mood_bad_rounded,
    'warning_rounded': Icons.warning_rounded,
    'bedtime_rounded': Icons.bedtime_rounded,
    'favorite_rounded': Icons.favorite_rounded,
    'emoji_emotions_rounded': Icons.emoji_emotions_rounded,
  };

  static IconData iconFromName(String? name) {
    if (name == null) return Icons.emoji_emotions_rounded;
    return _iconMap[name] ?? Icons.emoji_emotions_rounded;
  }

  static Color colorFromHex(String? hex, {Color fallback = Colors.orange}) {
    if (hex == null || hex.isEmpty) return fallback;

    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(cleaned, radix: 16);

    if (value == null) return fallback;

    return Color(value);
  }

  /// Helper serba-bisa: ambil icon langsung dari Map data emosi
  /// yang datang dari Supabase (row tabel `emotions`).
  static IconData iconFromEmotion(Map<String, dynamic> emotion) {
    return iconFromName(emotion['icon_name']?.toString());
  }

  static Color colorFromEmotion(Map<String, dynamic> emotion) {
    return colorFromHex(emotion['color_hex']?.toString());
  }

  static Color lightColorFromEmotion(Map<String, dynamic> emotion) {
    return colorFromHex(
      emotion['light_color_hex']?.toString(),
      fallback: const Color(0xFFFFE5D7),
    );
  }

  static String howToHandleFromEmotion(Map<String, dynamic> emotion) {
    return emotion['how_to_handle']?.toString() ??
        'Kenali perasaanmu dan cobalah mencari cara yang sehat untuk mengelolanya. 🚀';
  }
}
