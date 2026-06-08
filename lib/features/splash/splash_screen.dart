import 'dart:async';

import 'package:flutter/material.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_images.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progress = 0;

  @override
  void initState() {
    super.initState();

    Timer.periodic(
      const Duration(milliseconds: 100),
          (timer) {
        if (!mounted) return;

        setState(() {
          progress += 0.01;
        });

        if (progress >= 1) {
          progress = 1;
          timer.cancel();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const OnboardingScreen(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryYellow,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: Column(
              children: [
                const Spacer(),

                // LOGO
                Hero(
                  tag: "logo",
                  child: Image.asset(
                    AppImages.logo,
                    width: 260,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "THẾ GIỚI LEGO CHÍNH HÃNG",
                  style: TextStyle(
                    color: AppColors.white70,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),

                const Spacer(),

                Text(
                  "Đang chuẩn bị những viên gạch cuối cùng...",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.9),
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 18),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation(
                      Color(0xFF1E293B),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${(progress * 100).toInt()}%",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "KHÁM PHÁ VÔ HẠN • SÁNG TẠO KHÔNG NGỪNG",
                  style: TextStyle(
                    color: AppColors.white70,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}