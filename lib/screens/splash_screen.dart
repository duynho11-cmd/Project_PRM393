import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../utils/app_responsive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double progress = 0;

  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  late final AnimationController _textCtrl;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  late final AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut);
    _logoFade  = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.5)),
    );

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textFade  = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _logoCtrl.forward().then((_) => _textCtrl.forward());
    _startProgress();
  }

  void _startProgress() {
    Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        progress += 0.018;
        if (progress > 1) progress = 1;
      });
      if (progress >= 1) {
        timer.cancel();
        _navigate();
      }
    });
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('seenOnboarding'); // remove in production
    final bool seen = prefs.getBool('seenOnboarding') ?? false;
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    if (!seen) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r    = AppResponsive(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Stack(
          children: [
            // ── Floating orbs ──────────────────────────────────
            _buildOrb(size, _floatCtrl,
                top: -r.h(80), left: -r.w(60),
                diameter: r.w(260), opacity: 0.12, phase: 0),
            _buildOrb(size, _floatCtrl,
                top: size.height * 0.35, right: -r.w(80),
                diameter: r.w(220), opacity: 0.09, phase: math.pi),
            _buildOrb(size, _floatCtrl,
                bottom: -r.h(100), left: size.width * 0.1,
                diameter: r.w(300), opacity: 0.08, phase: math.pi / 2),

            // Accent dots
            Positioned(
              top:   size.height * 0.18,
              right: size.width  * 0.15,
              child: Container(
                width: r.w(16), height: r.w(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.coloredShadow(AppColors.secondary),
                ),
              ),
            ),
            Positioned(
              bottom: size.height * 0.25,
              left:   size.width  * 0.12,
              child: Container(
                width: r.w(10), height: r.w(10),
                decoration: const BoxDecoration(
                  color: Colors.white54, shape: BoxShape.circle,
                ),
              ),
            ),

            // ── Main content ────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: r.symH(32),
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // Logo
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Hero(
                          tag: 'logo',
                          child: Container(
                            width: r.w(148), height: r.w(148),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(r.r(40)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: r.h(40),
                                  offset: Offset(0, r.h(16)),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  blurRadius: 0,
                                  spreadRadius: r.w(3),
                                ),
                              ],
                            ),
                            padding: r.all(18),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: r.h(36)),

                    // Brand name + tagline
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(
                          children: [
                            Text(
                              'LegoKing',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: r.sp(38),
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                                height: 1,
                              ),
                            ),
                            SizedBox(height: r.h(10)),
                            Container(
                              padding: r.sym(16, 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(r.r(20)),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                'THẾ GIỚI LEGO CHÍNH HÃNG',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: r.sp(11),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 4),

                    // Progress area
                    FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Đang khởi động...',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: r.sp(13),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                padding: r.sym(12, 4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(r.r(20)),
                                  boxShadow: AppColors.coloredShadow(
                                      AppColors.secondary),
                                ),
                                child: Text(
                                  '${(progress * 100).toInt()}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: r.sp(12),
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: r.h(10)),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(r.r(20)),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: progress),
                              duration: const Duration(milliseconds: 60),
                              builder: (_, val, __) => LinearProgressIndicator(
                                value: val,
                                minHeight: r.h(6),
                                backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                                valueColor: const AlwaysStoppedAnimation(
                                    AppColors.secondary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: r.h(40)),

                    FadeTransition(
                      opacity: _textFade,
                      child: Text(
                        'KHÁM PHÁ VÔ HẠN • SÁNG TẠO KHÔNG NGỪNG',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: r.sp(10),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ),

                    SizedBox(height: r.h(28)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrb(
      Size size,
      AnimationController ctrl, {
        double? top, double? bottom,
        double? left, double? right,
        required double diameter,
        required double opacity,
        required double phase,
      }) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final dy = math.sin(ctrl.value * 2 * math.pi + phase) * 14.0;
        return Positioned(
          top:    top    != null ? top    + dy : null,
          bottom: bottom != null ? bottom - dy : null,
          left: left,
          right: right,
          child: Container(
            width: diameter, height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: opacity),
            ),
          ),
        );
      },
    );
  }
}
