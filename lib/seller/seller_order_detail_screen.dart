import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class SellerOrderDetailScreen extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> order;

  const SellerOrderDetailScreen({
    super.key,
    required this.orderId,
    required this.order,
  });

  @override
  State<SellerOrderDetailScreen> createState() =>
      _SellerOrderDetailScreenState();
}

class _SellerOrderDetailScreenState extends State<SellerOrderDetailScreen> {
  late String status;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    status = widget.order['status'] ?? 'Pending';
  }

  String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    )}đ';
  }

  String statusText(String status) {
    switch (status) {
      case 'Pending':
        return 'Chờ xác nhận';
      case 'Processing':
        return 'Đã xác nhận';
      case 'Shipping':
        return 'Đang giao';
      case 'Delivered':
        return 'Giao thành công';
      case 'Cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'Processing':
        return AppColors.primary;
      case 'Shipping':
        return const Color(0xFF8B5CF6);
      case 'Delivered':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.accentRed;
      default:
        return AppColors.textGrey;
    }
  }

  IconData statusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.hourglass_empty_rounded;
      case 'Processing':
        return Icons.task_alt_rounded;
      case 'Shipping':
        return Icons.local_shipping_rounded;
      case 'Delivered':
        return Icons.check_circle_rounded;
      case 'Cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Future<void> updateStatus(String newStatus) async {
    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'status': newStatus,
        'updatedAt': Timestamp.now(),
      });

      if (!mounted) return;

      setState(() {
        status = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật: ${statusText(newStatus)}'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi cập nhật: $e'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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

  Widget buildHeader() {
    return Container(
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
              "Đơn hàng\n#${(widget.order['orderId'] ?? widget.orderId).toString().substring(0, 8)}",
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
              Icons.manage_accounts_rounded,
              color: AppColors.secondary,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusCard() {
    final color = statusColor(status);

    return buildCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              statusIcon(status),
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Trạng thái hiện tại",
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  statusText(status),
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.4,
              ),
            ),
        ],
      ),
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
                  color: AppColors.textGrey,
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
                    fontSize: 14.5,
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

  Widget buildSummaryRow({
    required String title,
    required int value,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: bold ? AppColors.textDark : AppColors.textGrey,
              fontSize: bold ? 16 : 14.5,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            formatPrice(value),
            style: TextStyle(
              color: bold ? AppColors.primary : AppColors.textDark,
              fontSize: bold ? 22 : 15,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
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
            color: AppColors.primary.withOpacity(0.08),
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

  Widget actionButton({
    required String text,
    required String newStatus,
    required Color color,
    required IconData icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : () => updateStatus(newStatus),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15.5,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withOpacity(0.55),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  List<Widget> buildActionButtons() {
    if (status == 'Pending') {
      return [
        actionButton(
          text: 'Xác nhận đơn hàng',
          newStatus: 'Processing',
          color: AppColors.primary,
          icon: Icons.task_alt_rounded,
        ),
        const SizedBox(height: 12),
        actionButton(
          text: 'Hủy đơn hàng',
          newStatus: 'Cancelled',
          color: AppColors.accentRed,
          icon: Icons.cancel_outlined,
        ),
      ];
    }

    if (status == 'Processing') {
      return [
        actionButton(
          text: 'Chuyển sang đang giao',
          newStatus: 'Shipping',
          color: const Color(0xFF8B5CF6),
          icon: Icons.local_shipping_rounded,
        ),
      ];
    }

    if (status == 'Shipping') {
      return [
        actionButton(
          text: 'Xác nhận giao thành công',
          newStatus: 'Delivered',
          color: AppColors.success,
          icon: Icons.check_circle_outline_rounded,
        ),
      ];
    }

    return [
      buildCard(
        child: Row(
          children: [
            Icon(
              statusIcon(status),
              color: statusColor(status),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                status == 'Delivered'
                    ? 'Đơn hàng đã hoàn tất'
                    : 'Đơn hàng đã kết thúc',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
    final total = (order['total'] as num?)?.toInt() ?? 0;
    final subtotal = (order['subtotal'] as num?)?.toInt() ?? 0;
    final shippingFee = (order['shippingFee'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Chi tiết đơn hàng',
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
          buildHeader(),

          const SizedBox(height: 20),

          buildStatusCard(),

          const SizedBox(height: 20),

          buildCard(
            child: Column(
              children: [
                buildInfoRow(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Mã đơn',
                  value: (order['orderId'] ?? widget.orderId).toString(),
                ),
                buildInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Khách hàng',
                  value: order['fullName']?.toString() ?? '',
                ),
                buildInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'SĐT',
                  value: order['phone']?.toString() ?? '',
                ),
                buildInfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Địa chỉ',
                  value: order['address']?.toString() ?? '',
                ),
                buildInfoRow(
                  icon: Icons.payments_outlined,
                  label: 'Thanh toán',
                  value: order['paymentMethod']?.toString() ?? '',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          buildSectionTitle(
            title: 'Sản phẩm',
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
                  title: 'Tạm tính',
                  value: subtotal,
                ),
                buildSummaryRow(
                  title: 'Phí vận chuyển',
                  value: shippingFee,
                ),
                const Divider(height: 24, color: AppColors.border),
                buildSummaryRow(
                  title: 'Tổng cộng',
                  value: total,
                  bold: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          buildSectionTitle(
            title: 'Cập nhật đơn hàng',
            icon: Icons.update_rounded,
          ),

          const SizedBox(height: 14),

          ...buildActionButtons(),
        ],
      ),
    );
  }
}