import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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

      total += (price * quantity);
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Giỏ hàng"),
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF0B4DBA),
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: CartService().getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text(
                "Giỏ hàng của bạn đang trống",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final total = getTotal(items);

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = items[index];

                    final productId = item['id'];
                    final name = item['name'] ?? '';
                    final image = item['image'] ?? '';
                    final price = (item['price'] ?? 0).toInt();
                    final quantity = (item['quantity'] ?? 1).toInt();
                    final stock = (item['stock'] ?? 1).toInt();

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              image,
                              width: 86,
                              height: 86,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return Container(
                                  width: 86,
                                  height: 86,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_not_supported),
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
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  formatPrice(price),
                                  style: const TextStyle(
                                    color: Color(0xFF0B4DBA),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Row(
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
                                      child: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Text(
                                        quantity.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
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
                                      child: const Icon(
                                        Icons.add_circle_outline,
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
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Tổng tiền",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formatPrice(total),
                          style: const TextStyle(
                            fontSize: 22,
                            color: Color(0xFF0B4DBA),
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
          onPressed: () {
          Navigator.pushNamed(context, '/checkout');
          },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B4DBA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Thanh toán",
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