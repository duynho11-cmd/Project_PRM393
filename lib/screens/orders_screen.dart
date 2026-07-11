import 'package:flutter/material.dart';

import '../services/cart_service.dart';
import '../services/order_service.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

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

  String shortOrderId(dynamic orderId) {
    final id = orderId?.toString() ?? '';
    if (id.length <= 8) return id;
    return id.substring(0, 8);
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Processing':
        return primaryBlue;
      case 'Shipping':
        return const Color(0xFF8B5CF6);
      case 'Delivered':
        return const Color(0xFF22C55E);
      default:
        return textGrey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.hourglass_empty_rounded;
      case 'Processing':
        return Icons.settings_rounded;
      case 'Shipping':
        return Icons.local_shipping_rounded;
      case 'Delivered':
        return Icons.check_circle_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'Pending':
        return 'Chờ xử lý';
      case 'Processing':
        return 'Đang xử lý';
      case 'Shipping':
        return 'Đang giao';
      case 'Delivered':
        return 'Đã giao';
      default:
        return status;
    }
  }

  Widget buildEmptyOrders() {
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
                Icons.receipt_long_outlined,
                size: 48,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Chưa có đơn hàng",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Các đơn hàng của bạn sẽ được hiển thị tại đây.",
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

  Widget buildHeader(int orderCount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 6, 18, 18),
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
          Expanded(
            child: Text(
              "Theo dõi\n$orderCount đơn hàng",
              style: const TextStyle(
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
              Icons.inventory_2_rounded,
              color: primaryYellow,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusChip(String status) {
    final color = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getStatusIcon(status),
            color: color,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            getStatusText(status),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOrderCard({
    required BuildContext context,
    required Map<String, dynamic> order,
  }) {
    final orderId = order['orderId'] ?? order['id'];
    final status = order['status'] ?? 'Pending';
    final total = (order['total'] as num?)?.toInt() ?? 0;
    final paymentMethod = order['paymentMethod'] ?? 'COD';
    final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
    final itemCount = items.fold<int>(
      0,
          (sum, item) => sum + ((item['quantity'] as num?)?.toInt() ?? 0),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(order: order),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: darkBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Đơn hàng #${shortOrderId(orderId)}",
                        style: const TextStyle(
                          color: textDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "$itemCount sản phẩm • $paymentMethod",
                        style: const TextStyle(
                          color: textGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: textGrey,
                  size: 16,
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                buildStatusChip(status),
                const Spacer(),
                Text(
                  formatPrice(total),
                  style: const TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ],
            ),

            if (status == 'Delivered') ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final error = await CartService().addOrderItemsToCart(items);

                    if (!context.mounted) return;

                    if (error == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Đã thêm lại sản phẩm vào giỏ hàng"),
                        ),
                      );

                      Navigator.pushNamed(context, '/cart');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    }
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text(
                    "Mua lại",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
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
          "Đơn hàng của tôi",
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
        stream: OrderService().getMyOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: darkBlue),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return buildEmptyOrders();
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: orders.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              if (index == 0) {
                return buildHeader(orders.length);
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: buildOrderCard(
                  context: context,
                  order: orders[index - 1],
                ),
              );
            },
          );
        },
      ),
    );
  }
}