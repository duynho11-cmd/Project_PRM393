import 'package:flutter/material.dart';
import '../../shared/constants/app_images.dart';
import '../auth/login.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  final List<OnboardingItem> items = [
    OnboardingItem(
      image: AppImages.onboarding1,
      title: "Chào mừng đến với\nLegoKing",
      description: "Khám phá hàng ngàn món đồ chơi hấp dẫn.",
    ),
    OnboardingItem(
      image: AppImages.onboarding2,
      title: "Khám phá danh mục",
      description: "Dễ dàng tìm kiếm đồ chơi theo từng nhóm.",
    ),
    OnboardingItem(
      image: AppImages.onboarding3,
      title: "An toàn - Chất lượng -\nUy tín",
      description: "Chúng tôi chỉ cung cấp những sản phẩm tốt nhất.",
    ),
  ];

  void nextPage() {
    if (currentIndex == items.length - 1) {
      // TODO: chuyển sang LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void skip() {
    // TODO: chuyển sang LoginScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
    _pageController.animateToPage(
      items.length - 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentIndex == items.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: items.length,
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final item = items[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      children: [
                        const SizedBox(height: 18),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.asset(
                            item.image,
                            height: MediaQuery.of(context).size.height * 0.48,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIndicators(),

                  ElevatedButton(
                    onPressed: nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF349BFF),
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: const Color(0xFF349BFF).withOpacity(.35),
                      padding: EdgeInsets.symmetric(
                        horizontal: isLastPage ? 34 : 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLastPage ? "Bắt đầu ngay" : "Tiếp tục",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (!isLastPage) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ],
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

  Widget _buildHeader() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFF349BFF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                AppImages.logo,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (currentIndex == 2) ...[
            const SizedBox(width: 8),
            const Text(
              "LegoKing",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
          const Spacer(),
          TextButton(
            onPressed: skip,
            child: const Text(
              "Skip",
              style: TextStyle(
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      children: List.generate(
        items.length,
            (index) {
          final active = index == currentIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(right: 8),
            height: 8,
            width: active ? 24 : 8,
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF349BFF)
                  : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }
}

class OnboardingItem {
  final String image;
  final String title;
  final String description;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
  });
}