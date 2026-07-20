import 'package:flutter/material.dart';

class AppColors {
  // ─── Brand Colors ───────────────────────────────────────────────────────────
  static const primary       = Color(0xFF2563EB); // Blue 600
  static const primaryDark   = Color(0xFF1D4ED8); // Blue 700
  static const primaryLight  = Color(0xFF3B82F6); // Blue 500
  static const secondary     = Color(0xFFF59E0B); // Amber 500
  static const secondaryDark = Color(0xFFD97706); // Amber 600
  static const accentRed     = Color(0xFFEF4444); // Red 500
  static const success       = Color(0xFF10B981); // Emerald 500
  static const successLight  = Color(0xFFD1FAE5); // Emerald 100

  // ─── Neutral / Surface Colors ────────────────────────────────────────────────
  static const background    = Color(0xFFF8FAFF); // Slightly blue-tinted white
  static const surface       = Color(0xFFFFFFFF);
  static const surfaceVariant= Color(0xFFF1F5F9); // Slate 100
  static const cardBg        = Colors.white;

  // ─── Text Colors ─────────────────────────────────────────────────────────────
  static const textDark      = Color(0xFF0F172A); // Slate 900
  static const textMedium    = Color(0xFF334155); // Slate 700
  static const textGrey      = Color(0xFF64748B); // Slate 500
  static const textLight     = Color(0xFF94A3B8); // Slate 400

  // ─── Border / Divider ────────────────────────────────────────────────────────
  static const border        = Color(0xFFE2E8F0); // Slate 200
  static const borderFocus   = Color(0xFF93C5FD); // Blue 300

  // ─── Gradients ───────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
  );

  static const LinearGradient primaryGradientV = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF0F7FF), Color(0xFFF8FAFF)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
  );

  // ─── Shadows (cached statics — không tạo List mới mỗi frame) ────────────────
  static const List<BoxShadow> _softShadowCache = [
    BoxShadow(
      color: Color(0x0A0F172A), // 0x0A ≈ 0.04 opacity
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> _floatingShadowCache = [
    BoxShadow(
      color: Color(0x1A0F172A), // 0x1A ≈ 0.10 opacity
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> _premiumShadowCache = [
    BoxShadow(
      color: Color(0x0F0F172A), // 0x0F ≈ 0.06 opacity
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  /// Dùng khi không cần custom color/blur
  static List<BoxShadow> softShadow() => _softShadowCache;

  /// Dùng khi không cần custom color/blur
  static List<BoxShadow> floatingShadow() => _floatingShadowCache;

  static List<BoxShadow> premiumShadow({
    Color? color,
    double blur = 20,
    Offset offset = const Offset(0, 8),
    double spread = 0,
  }) {
    // Trả về cached list nếu dùng default values
    if (color == null && blur == 20 && offset == const Offset(0, 8) && spread == 0) {
      return _premiumShadowCache;
    }
    return [
      BoxShadow(
        color: color ?? const Color(0x0F0F172A),
        blurRadius: blur,
        offset: offset,
        spreadRadius: spread,
      ),
    ];
  }

  static List<BoxShadow> coloredShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.28),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ─── Border Radius Constants ─────────────────────────────────────────────────
  static const double radiusSm  = 12;
  static const double radiusMd  = 16;
  static const double radiusLg  = 20;
  static const double radiusXl  = 24;
  static const double radiusXxl = 32;

  // ─── Spacing ────────────────────────────────────────────────────────────────
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
}
