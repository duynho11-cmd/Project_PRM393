import 'package:flutter/material.dart';

/// AppResponsive — scale mọi kích thước theo chiều rộng màn hình.
///
/// Cách dùng:
///   final r = AppResponsive(context);
///   r.sp(14)    → font size
///   r.w(60)     → width / horizontal length
///   r.h(40)     → height / vertical length
///   r.p(20)     → padding / margin value
///   r.icon(24)  → icon size
///   r.r(16)     → border radius
///
/// Baseline: 390 px wide (iPhone 14, thiết bị phổ biến nhất 2024)
class AppResponsive {
  AppResponsive(BuildContext context) {
    final mq = MediaQuery.of(context);
    _width  = mq.size.width;
    _height = mq.size.height;
    _scale  = (_width / _baseline).clamp(_minScale, _maxScale);
  }

  static const double _baseline  = 390.0;
  /// Không scale quá nhỏ (điện thoại cũ 320px) và quá lớn (tablet 800px+)
  static const double _minScale  = 0.82;
  static const double _maxScale  = 1.20;

  late final double _width;
  late final double _height;
  late final double _scale;

  /// Trả về true nếu màn hình được coi là tablet (≥ 600 dp)
  bool get isTablet => _width >= 600;

  /// Chiều rộng màn hình thực
  double get screenWidth  => _width;
  double get screenHeight => _height;

  // ── Scale helpers ──────────────────────────────────────────────────────────

  /// Font size — scale theo _scale, min 10, max 38
  double sp(double size) => (size * _scale).clamp(10.0, 38.0);

  /// Width / horizontal dimension
  double w(double size) => size * _scale;

  /// Height / vertical dimension
  double h(double size) => size * _scale;

  /// Padding / margin value (same ratio as width)
  double p(double size) => size * _scale;

  /// Icon size
  double icon(double size) => (size * _scale).clamp(12.0, 48.0);

  /// Border radius
  double r(double size) => size * _scale;

  // ── Percentage helpers ─────────────────────────────────────────────────────

  /// % chiều rộng màn hình (0.0 – 1.0)
  double wp(double pct) => _width * pct;

  /// % chiều cao màn hình (0.0 – 1.0)
  double hp(double pct) => _height * pct;

  // ── EdgeInsets shortcuts ───────────────────────────────────────────────────

  EdgeInsets symH(double h) => EdgeInsets.symmetric(horizontal: p(h));
  EdgeInsets symV(double v) => EdgeInsets.symmetric(vertical: p(v));
  EdgeInsets sym(double h, double v) =>
      EdgeInsets.symmetric(horizontal: p(h), vertical: p(v));
  EdgeInsets all(double v) => EdgeInsets.all(p(v));
  EdgeInsets only({
    double left   = 0,
    double right  = 0,
    double top    = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(
        left:   p(left),
        right:  p(right),
        top:    p(top),
        bottom: p(bottom),
      );
  EdgeInsets fromLTRB(double l, double t, double rr, double b) =>
      EdgeInsets.fromLTRB(p(l), p(t), p(rr), p(b));
}
