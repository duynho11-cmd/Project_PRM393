import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  int shippingFee = 30000;

  String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    )}đ';
  }

  int getSubtotal(List<Map<String, dynamic>> items) {
    int total = 0;

    for (final item in items) {
      final int price = (item['price'] as num?)?.toInt() ?? 0;
      final int quantity = (item['quantity'] as num?)?.toInt() ?? 0;
      total += price * quantity;
    }

    return total;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Widget buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void goToPayment(List<Map<String, dynamic>> items) {
    if (fullNameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    final subtotal = getSubtotal(items);
    final total = subtotal + shippingFee;

    Navigator.pushNamed(
      context,
      '/payment',
      arguments: {
        'items': items,
        'fullName': fullNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'subtotal': subtotal,
        'shippingFee': shippingFee,
        'total': total,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF0B4DBA),
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: CartService().getCartItems(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (items.isEmpty) {
            return const Center(child: Text("Giỏ hàng đang trống"));
          }

          final subtotal = getSubtotal(items);
          final total = subtotal + shippingFee;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      "Thông tin giao hàng",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    buildInput(
                      controller: fullNameController,
                      label: "Họ và tên",
                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 12),

                    buildInput(
                      controller: phoneController,
                      label: "Số điện thoại",
                      icon: Icons.phone_outlined,
                    ),

                    const SizedBox(height: 12),

                    buildInput(
                      controller: addressController,
                      label: "Địa chỉ giao hàng",
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Sản phẩm",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    ...items.map((item) {
                      final name = item['name'] ?? '';
                      final image = item['image'] ?? '';
                      final price = (item['price'] as num?)?.toInt() ?? 0;
                      final quantity =
                          (item['quantity'] as num?)?.toInt() ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                image,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text("x$quantity"),
                            const SizedBox(width: 8),
                            Text(
                              formatPrice(price),
                              style: const TextStyle(
                                color: Color(0xFF0B4DBA),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black12,
                      offset: Offset(0, -2),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text("Tạm tính"),
                        const Spacer(),
                        Text(formatPrice(subtotal)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text("Phí vận chuyển"),
                        const Spacer(),
                        Text(formatPrice(shippingFee)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Text(
                          "Tổng cộng",
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
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => goToPayment(items),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B4DBA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Tiếp tục thanh toán",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}