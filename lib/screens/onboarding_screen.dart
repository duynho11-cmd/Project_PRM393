import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_images.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color primaryYellow = Color(0xFFFFD93D);
  static const Color primaryGreen = Color(0xFF22C55E);

  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      'image': AppImages.onboarding1,
      'title': 'Chào mừng đến với LegoKing',
      'description': 'Khám phá hàng ngàn món đồ chơi LEGO hấp dẫn cho bé yêu.',
      'color': primaryBlue,
    },
    {
      'image': AppImages.onboarding2,
      'title': 'Khám phá danh mục',
      'description':
      'Tìm kiếm LEGO, gấu bông, xe điều khiển và nhiều sản phẩm thú vị.',
      'color': primaryYellow,
    },
    {
      'image': AppImages.onboarding3,
      'title': 'An toàn - Chất lượng',
      'description': 'Sản phẩm chính hãng, an toàn và phù hợp cho trẻ em.',
      'color': primaryGreen,
    },
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _nextPage() {
    if (currentPage == pages.length - 1) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildIndicator(int index) {
    final bool isActive = currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: isActive ? 28 : 9,
      height: 9,
      decoration: BoxDecoration(
        color: isActive ? primaryBlue : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = pages[currentPage];

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              (page['color'] as Color).withOpacity(0.18),
              const Color(0xFFF8FAFC),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'LegoKing',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text(
                        'Bỏ qua',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = pages[index];
                    final Color itemColor = item['color'] as Color;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 330,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(36),
                              boxShadow: [
                                BoxShadow(
                                  color: itemColor.withOpacity(0.25),
                                  blurRadius: 30,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(36),
                              child: Image.asset(
                                item['image'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          const SizedBox(height: 46),

                          Text(
                            item['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            item['description'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                      (index) => _buildIndicator(index),
                ),
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Text(
                      currentPage == pages.length - 1
                          ? 'Bắt đầu ngay'
                          : 'Tiếp tục',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),
            ],
          ),
        ),
      ),
    );
  }
}