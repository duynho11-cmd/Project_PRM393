import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    )}đ';
  }

  String paymentName(String method) {
    switch (method) {
      case 'COD':
        return 'Thanh toán khi nhận hàng';
      case 'Banking':
        return 'Chuyển khoản ngân hàng';
      case 'Momo':
        return 'Ví điện tử MoMo';
      case 'ZaloPay':
        return 'Ví điện tử ZaloPay';
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final total = (data['total'] as num?)?.toInt() ?? 0;
    final paymentMethod = data['paymentMethod']?.toString() ?? 'COD';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  shape: BoxShape.circle,
                  boxShadow: AppColors.premiumShadow(
                    color: AppColors.success.withOpacity(0.1),
                    blur: 16,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 72,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Đặt hàng thành công!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Cảm ơn bạn đã mua sắm tại LegoKing.\nĐơn hàng của bạn đã được ghi nhận.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.premiumShadow(),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Phương thức",
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            paymentName(paymentMethod),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 28, color: AppColors.border),

                    Row(
                      children: [
                        const Text(
                          "Tổng thanh toán",
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formatPrice(total),
                          style: const TextStyle(
                            fontSize: 22,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: AppColors.primaryGradient,
                  boxShadow: AppColors.premiumShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blur: 16,
                    offset: const Offset(0, 6),
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  icon: const Icon(Icons.home_rounded, color: Colors.white),
                  label: const Text(
                    "Về trang chủ",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Clear stack về home rồi push orders lên trên
                    // → orders screen sẽ có nút quay lại về home
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                          (route) => false,
                    );
                    Navigator.pushNamed(context, '/orders');
                  },
                  icon: const Icon(Icons.receipt_long_rounded),
                  label: const Text(
                    "Xem đơn hàng",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}