import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _startLoading();
  }

  void _startLoading() {
    Timer.periodic(
      const Duration(milliseconds: 40),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          progress += 0.02;
          if (progress > 1) progress = 1;
        });

        if (progress >= 1) {
          timer.cancel();
          _checkNavigation();
        }
      },
    );
  }

  Future<void> _checkNavigation() async {
    final prefs = await SharedPreferences.getInstance();

    // Chỉ dùng khi test onboarding
    await prefs.remove('seenOnboarding');

    final bool seenOnboarding =
        prefs.getBool('seenOnboarding') ?? false;

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (!seenOnboarding) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
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
              Color(0xFF4A90E2),
              Color(0xFFFFD93D),
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

                Hero(
                  tag: "logo",
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 260,
                  ),
                ),

                const SizedBox(height: 24),

                // const Text(
                //   "LEGOKING",
                //   style: TextStyle(
                //     fontSize: 38,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.white,
                //     letterSpacing: 1.5,
                //   ),
                // ),

                const SizedBox(height: 8),

                const Text(
                  "THẾ GIỚI LEGO CHÍNH HÃNG",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),

                const Spacer(),

                Text(
                  "Đang chuẩn bị những viên gạch cuối cùng...",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
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
                      color: const Color(0xFFFFD93D),
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
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
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