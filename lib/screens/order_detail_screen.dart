import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

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

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'Processing':
        return AppColors.primary;
      case 'Shipping':
        return const Color(0xFF8B5CF6);
      case 'Delivered':
        return AppColors.success;
      default:
        return AppColors.textGrey;
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
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.premiumShadow(),
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
          Icon(icon, color: AppColors.textGrey, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14.5,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: AppColors.textDark,
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
              color: isTotal ? AppColors.textDark : AppColors.textGrey,
              fontSize: isTotal ? 16 : 14.5,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? AppColors.primary : AppColors.textDark,
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
            child: CachedNetworkImage(
              imageUrl: image,
              width: 76,
              height: 76,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 76, height: 76,
                color: AppColors.surfaceVariant,
              ),
              errorWidget: (_, __, ___) => Container(
                width: 76,
                height: 76,
                color: const Color(0xFFF1F5F9),
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textLight,
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
                    color: AppColors.textDark,
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
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'x$quantity',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatPrice(price),
                      style: const TextStyle(
                        color: AppColors.textGrey,
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
              color: AppColors.primary,
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
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Chi tiết đơn hàng",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: AppColors.primaryGradient,
              boxShadow: AppColors.premiumShadow(
                color: AppColors.primary.withOpacity(0.2),
                blur: 24,
                offset: const Offset(0, 10),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Đơn hàng\n#${order['orderId'] ?? ''}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.secondary,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          buildCard(
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    getStatusIcon(status),
                    color: statusColor,
                    size: 26,
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
                          color: AppColors.textGrey,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        getStatusText(status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

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

          const SizedBox(height: 24),

          buildSectionTitle(
            title: "Sản phẩm",
            icon: Icons.shopping_bag_outlined,
          ),

          const SizedBox(height: 16),

          ...items.map(
                (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: buildProductItem(item),
            ),
          ),

          const SizedBox(height: 12),

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
                const Divider(height: 24, color: AppColors.border),
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