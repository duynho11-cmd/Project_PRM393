import 'package:flutter/material.dart';
import '../services/order_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
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

  Widget paymentOption({
    required String value,
    required String title,
    required IconData icon,
  }) {
    final selected = paymentMethod == value;

    return InkWell(
      onTap: () => setState(() => paymentMethod = value),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF0B4DBA) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0B4DBA)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: paymentMethod,
              activeColor: const Color(0xFF0B4DBA),
              onChanged: (val) {
                setState(() => paymentMethod = val!);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final total = data['total'] as int;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Thanh toán"),
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF0B4DBA),
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            children: [
              paymentOption(
                value: 'COD',
                title: 'Thanh toán khi nhận hàng',
                icon: Icons.local_shipping_outlined,
              ),
              paymentOption(
                value: 'Banking',
                title: 'Chuyển khoản ngân hàng',
                icon: Icons.account_balance,
              ),
              paymentOption(
                value: 'Momo',
                title: 'Ví điện tử MoMo',
                icon: Icons.account_balance_wallet_outlined,
              ),
              paymentOption(
                value: 'ZaloPay',
                title: 'Ví điện tử ZaloPay',
                icon: Icons.payments_outlined,
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Text(
                      "Tổng thanh toán",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      formatPrice(total),
                      style: const TextStyle(
                        color: Color(0xFF0B4DBA),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 90),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => confirmPayment(data),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B4DBA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "Xác nhận đặt hàng",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}