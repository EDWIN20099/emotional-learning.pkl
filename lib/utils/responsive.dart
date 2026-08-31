import 'package:flutter/material.dart';

/// =====================================================================
/// RESPONSIVE HELPER
/// =====================================================================
/// Semua desain di app ini awalnya dibikin buat lebar layar sekitar
/// 390px (HP standar). Helper ini bikin ukuran (padding, font, icon,
/// tinggi container) otomatis ikut nyesuain ke lebar layar device
/// yang beneran dipakai user, jadi nggak numpuk/overflow di HP kecil
/// dan nggak keliatan kosong/terlalu kecil di HP/tablet besar.
///
/// CARA PAKAI di setiap halaman:
///   final r = Responsive(context);
///   ...
///   width: r.w(58),      // ukuran yang awalnya "58" jadi ikut skala
///   fontSize: r.sp(21),  // ukuran font yang awalnya "21" jadi ikut skala
///   padding: EdgeInsets.all(r.w(20)),
/// =====================================================================

class Responsive {
  Responsive(this.context)
    : screenWidth = MediaQuery.sizeOf(context).width,
      screenHeight = MediaQuery.sizeOf(context).height;

  final BuildContext context;
  final double screenWidth;
  final double screenHeight;

  // Lebar desain awal (base design width).
  static const double _baseWidth = 390;

  // Scale factor, dibatasi (clamp) biar nggak terlalu ekstrim
  // di layar sangat kecil atau sangat besar (misal tablet/desktop).
  double get scale => (screenWidth / _baseWidth).clamp(0.8, 1.3);

  /// Ukuran lebar/tinggi/padding yang ikut skala lebar layar.
  double w(double value) => value * scale;

  /// Ukuran font yang ikut skala, dengan batas lebih ketat
  /// biar teks tetap enak dibaca (nggak kekecilan/kegedean).
  double sp(double value) {
    final fontScale = (screenWidth / _baseWidth).clamp(0.85, 1.15);
    return value * fontScale;
  }

  /// True kalau layar termasuk kecil (HP sempit, contoh: iPhone SE).
  bool get isSmallScreen => screenWidth < 360;

  /// True kalau layar termasuk lebar (tablet ke atas).
  bool get isWideScreen => screenWidth >= 600;

  /// Batas maksimum lebar konten di layar besar (tablet/desktop),
  /// biar konten nggak melebar penuh dan jadi aneh/renggang banget.
  double get maxContentWidth => isWideScreen ? 480 : screenWidth;
}
