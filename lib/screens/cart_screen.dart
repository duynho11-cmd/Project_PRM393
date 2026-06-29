import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color darkBlue = Color(0xFF0B4DBA);
  static const Color primaryYellow = Color(0xFFFFD93D);
  static const Color bgColor = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF64748B);

  String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    )}đ';
  }

  int getTotal(List<Map<String, dynamic>> items) {
    int total = 0;

    for (final item in items) {
      final int price = (item['price'] as num?)?.toInt() ?? 0;
      final int quantity = (item['quantity'] as num?)?.toInt() ?? 0;
      total += price * quantity;
    }

    return total;
  }

  Widget buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Giỏ hàng trống",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Hãy thêm sản phẩm yêu thích của bé vào giỏ hàng.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: textGrey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCartItem(Map<String, dynamic> item) {
    final productId = item['id'];
    final name = item['name'] ?? '';
    final image = item['image'] ?? '';
    final price = (item['price'] as num?)?.toInt() ?? 0;
    final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
    final stock = (item['stock'] as num?)?.toInt() ?? 1;
    final itemTotal = price * quantity;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              image,
              width: 94,
              height: 94,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 94,
                  height: 94,
                  color: const Color(0xFFF1F5F9),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: textGrey,
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  formatPrice(price),
                  style: const TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Tạm tính: ${formatPrice(itemTotal)}",
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: quantity > 1
                                ? () {
                              CartService().updateQuantity(
                                productId: productId,
                                quantity: quantity - 1,
                              );
                            }
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.remove_rounded,
                                size: 18,
                                color: quantity > 1 ? textDark : Colors.grey,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              quantity.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: textDark,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: quantity < stock
                                ? () {
                              CartService().updateQuantity(
                                productId: productId,
                                quantity: quantity + 1,
                              );
                            }
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.add_rounded,
                                size: 18,
                                color: quantity < stock ? darkBlue : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      stock > 0 ? "Còn $stock" : "Hết hàng",
                      style: TextStyle(
                        fontSize: 12,
                        color: stock > 0 ? textGrey : Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              CartService().removeFromCart(productId);
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomCheckout({
    required int total,
    required BuildContext context,
  }) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  "Tổng thanh toán",
                  style: TextStyle(
                    fontSize: 15,
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

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/checkout');
                },
                icon: const Icon(Icons.payment_rounded),
                label: const Text(
                  "Thanh toán ngay",
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Giỏ hàng",
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: CartService().getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: darkBlue),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return buildEmptyCart();
          }

          final total = getTotal(items);

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(18, 6, 18, 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
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
                        "Kiểm tra sản phẩm\ntrước khi thanh toán",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                        ),
                      ),
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        color: primaryYellow,
                        size: 38,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    return buildCartItem(items[index]);
                  },
                ),
              ),

              buildBottomCheckout(
                total: total,
                context: context,
              ),
            ],
          );
        },
      ),
    );
  }
}