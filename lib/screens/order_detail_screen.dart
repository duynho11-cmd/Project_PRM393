import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    )}đ';
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

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
    final total = (order['total'] as num?)?.toInt() ?? 0;
    final subtotal = (order['subtotal'] as num?)?.toInt() ?? 0;
    final shippingFee = (order['shippingFee'] as num?)?.toInt() ?? 0;
    final status = order['status'] ?? 'Pending';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Chi tiết đơn hàng"),
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF0B4DBA),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Mã đơn: ${order['orderId']}"),
                const SizedBox(height: 8),
                Text("Trạng thái: ${getStatusText(status)}"),
                const SizedBox(height: 8),
                Text("Thanh toán: ${order['paymentMethod']}"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Thông tin giao hàng",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text("Người nhận: ${order['fullName']}"),
                Text("SĐT: ${order['phone']}"),
                Text("Địa chỉ: ${order['address']}"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "Sản phẩm",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...items.map((item) {
            final name = item['name'] ?? '';
            final image = item['image'] ?? '';
            final price = (item['price'] as num?)?.toInt() ?? 0;
            final quantity = (item['quantity'] as num?)?.toInt() ?? 0;

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
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}