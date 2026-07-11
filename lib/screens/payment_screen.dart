import 'package:flutter/material.dart';
import '../services/order_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color darkBlue = Color(0xFF0B4DBA);
  static const Color primaryYellow = Color(0xFFFFD93D);
  static const Color bgColor = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF64748B);

  String paymentMethod = 'COD';
  bool isLoading = false;

  String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    )}đ';
  }

  Future<void> confirmPayment(Map<String, dynamic> data) async {
    setState(() => isLoading = true);

    final error = await OrderService().createOrder(
      items: List<Map<String, dynamic>>.from(data['items']),
      fullName: data['fullName'],
      phone: data['phone'],
      address: data['address'],
      subtotal: data['subtotal'],
      shippingFee: data['shippingFee'],
      total: data['total'],
      paymentMethod: paymentMethod,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (error == null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/order-confirmation',
            (route) => false,
        arguments: {
          'total': data['total'],
          'paymentMethod': paymentMethod,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  String paymentName(String value) {
    switch (value) {
      case 'COD':
        return 'Thanh toán khi nhận hàng';
      case 'Banking':
        return 'Chuyển khoản ngân hàng';
      case 'Momo':
        return 'Ví điện tử MoMo';
      case 'ZaloPay':
        return 'Ví điện tử ZaloPay';
      default:
        return value;
    }
  }

  Widget buildPaymentOption({
    required String value,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final bool selected = paymentMethod == value;

    return InkWell(
      onTap: () => setState(() => paymentMethod = value),
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? darkBlue : const Color(0xFFE5E7EB),
            width: selected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? darkBlue.withOpacity(0.12)
                  : Colors.black.withOpacity(0.04),
              blurRadius: selected ? 22 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      color: textGrey,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: selected ? darkBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected ? darkBlue : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(
                Icons.check_rounded,
                size: 17,
                color: Colors.white,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSummaryRow({
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? textDark : textGrey,
              fontSize: isTotal ? 16 : 14.5,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? darkBlue : textDark,
              fontSize: isTotal ? 24 : 15,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: darkBlue,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Thông tin nhận hàng',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              data['fullName'] ?? '',
              style: const TextStyle(
                color: textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              data['phone'] ?? '',
              style: const TextStyle(
                color: textGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              data['address'] ?? '',
              style: const TextStyle(
                color: textGrey,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomButton(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : () => confirmPayment(data),
            icon: isLoading
                ? const SizedBox()
                : const Icon(Icons.check_circle_outline_rounded),
            label: isLoading
                ? const SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.6,
              ),
            )
                : const Text(
              "Xác nhận đặt hàng",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: darkBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: darkBlue.withOpacity(0.65),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final subtotal = data['subtotal'] as int;
    final shippingFee = data['shippingFee'] as int;
    final total = data['total'] as int;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Phương thức thanh toán",
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: bgColor,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBar: buildBottomButton(data),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    darkBlue,
                    primaryBlue,
                  ],
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Chọn cách thanh toán\nphù hợp với bạn",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                  ),
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.payments_rounded,
                      color: primaryYellow,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            buildInfoCard(data),

            const SizedBox(height: 22),

            const Text(
              "Phương thức thanh toán",
              style: TextStyle(
                color: textDark,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 14),

            buildPaymentOption(
              value: 'COD',
              title: 'Thanh toán khi nhận hàng',
              description: 'Trả tiền mặt khi đơn hàng được giao tới bạn.',
              icon: Icons.local_shipping_outlined,
              color: darkBlue,
            ),
            buildPaymentOption(
              value: 'Banking',
              title: 'Chuyển khoản ngân hàng',
              description: 'Thanh toán qua tài khoản ngân hàng.',
              icon: Icons.account_balance_rounded,
              color: const Color(0xFF22C55E),
            ),
            buildPaymentOption(
              value: 'Momo',
              title: 'Ví điện tử MoMo',
              description: 'Thanh toán nhanh qua ví MoMo.',
              icon: Icons.account_balance_wallet_outlined,
              color: const Color(0xFFEC4899),
            ),
            buildPaymentOption(
              value: 'ZaloPay',
              title: 'Ví điện tử ZaloPay',
              description: 'Thanh toán bằng ví điện tử ZaloPay.',
              icon: Icons.payments_outlined,
              color: const Color(0xFF2563EB),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  buildSummaryRow(
                    label: "Tạm tính",
                    value: formatPrice(subtotal),
                  ),
                  buildSummaryRow(
                    label: "Phí vận chuyển",
                    value: formatPrice(shippingFee),
                  ),
                  const Divider(height: 22),
                  buildSummaryRow(
                    label: "Tổng thanh toán",
                    value: formatPrice(total),
                    isTotal: true,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        color: Color(0xFF22C55E),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Đơn hàng sẽ được tạo sau khi xác nhận.",
                          style: TextStyle(
                            color: textGrey.withOpacity(0.95),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}