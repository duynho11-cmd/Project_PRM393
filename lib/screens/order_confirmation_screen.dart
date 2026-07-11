import 'package:flutter/material.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color darkBlue = Color(0xFF0B4DBA);
  static const Color primaryYellow = Color(0xFFFFD93D);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color bgColor = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF64748B);

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
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: successGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: successGreen,
                  size: 78,
                ),
              ),

              const SizedBox(height: 26),

              const Text(
                "Đặt hàng thành công!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Cảm ơn bạn đã mua sắm tại LegoKing.\nĐơn hàng của bạn đã được ghi nhận.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textGrey,
                  fontSize: 15.5,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Phương thức",
                          style: TextStyle(
                            color: textGrey,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            paymentName(paymentMethod),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: textDark,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 26),

                    Row(
                      children: [
                        const Text(
                          "Tổng thanh toán",
                          style: TextStyle(
                            color: textGrey,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formatPrice(total),
                          style: const TextStyle(
                            fontSize: 24,
                            color: darkBlue,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  icon: const Icon(Icons.home_rounded),
                  label: const Text(
                    "Về trang chủ",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/orders');
                  },
                  icon: const Icon(Icons.receipt_long_rounded),
                  label: const Text(
                    "Xem đơn hàng",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: darkBlue,
                    side: const BorderSide(color: darkBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}