import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../constants/app_images.dart';
import '../utils/app_responsive.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _btnCtrl;
  late final Animation<double>   _btnScale;

  final List<_OnboardPage> _pages = const [
    _OnboardPage(
      image:       AppImages.onboarding1,
      title:       'Chào mừng đến với\nLegoKing',
      description: 'Khám phá hàng ngàn món đồ chơi LEGO hấp dẫn, '
          'được chọn lọc kỹ càng cho bé yêu của bạn.',
      accent: AppColors.primary,
      badge:  '🧱',
    ),
    _OnboardPage(
      image:       AppImages.onboarding2,
      title:       'Đa dạng danh mục\ncho bé',
      description: 'LEGO, gấu bông, xe điều khiển, đồ chơi giáo dục '
          '— tất cả trong một ứng dụng.',
      accent: AppColors.secondary,
      badge:  '🎠',
    ),
    _OnboardPage(
      image:       AppImages.onboarding3,
      title:       'An toàn &\nChất lượng cao',
      description: 'Sản phẩm chính hãng, đạt chuẩn an toàn quốc tế, '
          'giao hàng nhanh đến tận tay.',
      accent: AppColors.success,
      badge:  '✅',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _btnScale = _btnCtrl;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _nextPage() {
    if (_currentPage == _pages.length - 1) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r    = AppResponsive(context);
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Decorative accent circle
          Positioned(
            top:   -r.h(100),
            right: -r.w(60),
            child: Container(
              width: r.w(280), height: r.w(280),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: page.accent.withValues(alpha: 0.08),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ─────────────────────────────────────
                Padding(
                  padding: r.sym(24, 16),
                  child: Row(
                    children: [
                      // Logo pill
                      Container(
                        padding: r.sym(14, 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              AppColors.radiusMd),
                          boxShadow: AppColors.softShadow(),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: r.w(8), height: r.w(8),
                              decoration: BoxDecoration(
                                color: page.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: r.w(7)),
                            Text(
                              'LegoKing',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: r.sp(14),
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _finishOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textGrey,
                          padding: r.sym(14, 8),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppColors.radiusMd),
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                        child: Text(
                          'Bỏ qua',
                          style: TextStyle(
                            fontSize: r.sp(13),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── PageView ─────────────────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (i) =>
                        setState(() => _currentPage = i),
                    itemBuilder: (_, index) =>
                        _buildPage(_pages[index], r),
                  ),
                ),

                // ── Bottom CTA ────────────────────────────────────
                Padding(
                  padding: r.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                              (i) => _buildDot(i, page.accent, r),
                        ),
                      ),
                      SizedBox(height: r.h(28)),

                      // Button
                      GestureDetector(
                        onTapDown:  (_) => _btnCtrl.reverse(),
                        onTapUp:    (_) { _btnCtrl.forward(); _nextPage(); },
                        onTapCancel: () => _btnCtrl.forward(),
                        child: ScaleTransition(
                          scale: _btnScale,
                          child: Container(
                            width: double.infinity,
                            height: r.h(58),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  AppColors.radiusLg),
                              gradient: _currentPage == _pages.length - 1
                                  ? const LinearGradient(
                                colors: [
                                  AppColors.success,
                                  Color(0xFF059669),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                                  : AppColors.primaryGradient,
                              boxShadow: AppColors.coloredShadow(
                                _currentPage == _pages.length - 1
                                    ? AppColors.success
                                    : AppColors.primary,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == _pages.length - 1
                                      ? 'Bắt đầu ngay'
                                      : 'Tiếp tục',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: r.sp(16),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(width: r.w(8)),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: r.icon(20),
                                ),
                              ],
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

  Widget _buildPage(_OnboardPage item, AppResponsive r) {
    return Padding(
      padding: r.symH(24),
      child: Column(
        children: [
          // Image card
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(top: r.h(8), bottom: r.h(16)),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppColors.radiusXxl),
                    boxShadow: AppColors.premiumShadow(
                      color: item.accent.withValues(alpha: 0.10),
                      blur: 30,
                      offset: Offset(0, r.h(14)),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius:
                    BorderRadius.circular(AppColors.radiusXxl),
                    child: Image.asset(item.image, fit: BoxFit.cover),
                  ),
                ),
                // Badge
                Positioned(
                  top:   r.h(20),
                  right: r.w(20),
                  child: Container(
                    width:  r.w(48),
                    height: r.w(48),
                    decoration: BoxDecoration(
                      color: item.accent,
                      borderRadius: BorderRadius.circular(r.r(14)),
                      boxShadow: AppColors.coloredShadow(item.accent),
                    ),
                    child: Center(
                      child: Text(
                        item.badge,
                        style: TextStyle(fontSize: r.sp(22)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Text
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: r.sp(26),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: -0.5,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: r.h(14)),
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: r.sp(15),
                    color: AppColors.textGrey,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, Color accent, AppResponsive r) {
    final bool active = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: r.w(4)),
      width:  active ? r.w(28) : r.w(8),
      height: r.h(8),
      decoration: BoxDecoration(
        color: active ? accent : AppColors.border,
        borderRadius: BorderRadius.circular(r.r(20)),
      ),
    );
  }
}

class _OnboardPage {
  final String image;
  final String title;
  final String description;
  final Color  accent;
  final String badge;

  const _OnboardPage({
    required this.image,
    required this.title,
    required this.description,
    required this.accent,
    required this.badge,
  });
}
