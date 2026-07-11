import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

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

  Widget buildCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
  }) {
    return Container(
      padding: padding,
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
      child: child,
    );
  }

  Widget buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textGrey, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: textDark,
                  fontSize: 14.5,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      color: textGrey,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
              fontSize: isTotal ? 23 : 15,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductItem(Map<String, dynamic> item) {
    final name = item['name'] ?? '';
    final image = item['image'] ?? '';
    final price = (item['price'] as num?)?.toInt() ?? 0;
    final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
    final itemTotal = price * quantity;

    return buildCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              image,
              width: 76,
              height: 76,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 76,
                height: 76,
                color: const Color(0xFFF1F5F9),
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: textGrey,
                ),
              ),
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'x$quantity',
                        style: const TextStyle(
                          color: darkBlue,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatPrice(price),
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatPrice(itemTotal),
            style: const TextStyle(
              color: darkBlue,
              fontWeight: FontWeight.w900,
              fontSize: 14.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle({
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: darkBlue, size: 21),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: textDark,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
    final total = (order['total'] as num?)?.toInt() ?? 0;
    final subtotal = (order['subtotal'] as num?)?.toInt() ?? 0;
    final shippingFee = (order['shippingFee'] as num?)?.toInt() ?? 0;
    final status = order['status'] ?? 'Pending';
    final statusColor = getStatusColor(status);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Chi tiết đơn hàng",
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
      body: ListView(
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
                Expanded(
                  child: Text(
                    "Đơn hàng\n#${order['orderId'] ?? ''}",
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
                    Icons.receipt_long_rounded,
                    color: primaryYellow,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          buildCard(
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    getStatusIcon(status),
                    color: statusColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Trạng thái đơn hàng",
                        style: TextStyle(
                          color: textGrey,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        getStatusText(status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          buildCard(
            child: Column(
              children: [
                buildInfoRow(
                  icon: Icons.confirmation_number_outlined,
                  label: "Mã đơn",
                  value: order['orderId']?.toString() ?? '',
                ),
                buildInfoRow(
                  icon: Icons.payments_outlined,
                  label: "Thanh toán",
                  value: order['paymentMethod']?.toString() ?? '',
                ),
                buildInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: "Người nhận",
                  value: order['fullName']?.toString() ?? '',
                ),
                buildInfoRow(
                  icon: Icons.phone_outlined,
                  label: "Số điện thoại",
                  value: order['phone']?.toString() ?? '',
                ),
                buildInfoRow(
                  icon: Icons.location_on_outlined,
                  label: "Địa chỉ",
                  value: order['address']?.toString() ?? '',
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          buildSectionTitle(
            title: "Sản phẩm",
            icon: Icons.shopping_bag_outlined,
          ),

          const SizedBox(height: 14),

          ...items.map(
                (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: buildProductItem(item),
            ),
          ),

          const SizedBox(height: 10),

          buildCard(
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
                const Divider(height: 24),
                buildSummaryRow(
                  label: "Tổng cộng",
                  value: formatPrice(total),
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}