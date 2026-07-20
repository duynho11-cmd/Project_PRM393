import 'package:flutter/material.dart';

import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../constants/app_colors.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const int _ordersPerPage = 5;
  late final Stream<List<Map<String, dynamic>>> _ordersStream;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _ordersStream = OrderService().getMyOrders();
  }

  String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
  }

  String shortOrderId(dynamic orderId) {
    final id = orderId?.toString() ?? '';
    if (id.length <= 8) return id;
    return id.substring(0, 8);
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
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Chưa có đơn hàng",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Các đơn hàng của bạn sẽ được hiển thị tại đây.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textGrey,
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
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 18),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: AppColors.primaryGradient,
        boxShadow: AppColors.premiumShadow(
          color: AppColors.primary.withValues(alpha: 0.2),
          blur: 24,
          offset: const Offset(0, 10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Theo dõi\n$orderCount đơn hàng",
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
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: AppColors.secondary,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusChip(String status) {
    final color = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(getStatusIcon(status), color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            getStatusText(status),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
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
          MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadow(),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.primary,
                    size: 24,
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
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$itemCount sản phẩm • $paymentMethod",
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textLight,
                  size: 14,
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
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            if (status == 'Delivered') ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: AppColors.primaryGradient,
                ),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final error = await CartService().addOrderItemsToCart(
                      items,
                    );

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
                        SnackBar(
                          content: Text(error),
                          backgroundColor: AppColors.accentRed,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.replay_rounded, color: Colors.white),
                  label: const Text(
                    "Mua lại",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

  Widget buildPagination({required int currentPage, required int totalPages}) {
    final canGoBack = currentPage > 0;
    final canGoForward = currentPage < totalPages - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: canGoBack
                  ? () => setState(() => _currentPage = currentPage - 1)
                  : null,
              icon: const Icon(Icons.chevron_left_rounded),
              label: const Text('Trước'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${currentPage + 1}/$totalPages',
              semanticsLabel:
              'Trang ${currentPage + 1} trên tổng số $totalPages trang',
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: canGoForward
                  ? () => setState(() => _currentPage = currentPage + 1)
                  : null,
              icon: const Icon(Icons.chevron_right_rounded),
              label: const Text('Sau'),
              iconAlignment: IconAlignment.end,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                disabledForegroundColor: AppColors.textLight,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Đơn hàng của tôi",
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return buildEmptyOrders();
          }

          final totalPages = (orders.length / _ordersPerPage).ceil();
          final currentPage = _currentPage.clamp(0, totalPages - 1);
          final startIndex = currentPage * _ordersPerPage;
          final endIndex = (startIndex + _ordersPerPage).clamp(
            0,
            orders.length,
          );
          final visibleOrders = orders.sublist(startIndex, endIndex);

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 24),
            physics: const ClampingScrollPhysics(),
            cacheExtent: 400,
            itemCount: visibleOrders.length + 2,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              if (index == 0) {
                return buildHeader(orders.length);
              }

              if (index == visibleOrders.length + 1) {
                return buildPagination(
                  currentPage: currentPage,
                  totalPages: totalPages,
                );
              }

              final order = visibleOrders[index - 1];

              return RepaintBoundary(
                key: ValueKey(order['orderId'] ?? order['id']),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: buildOrderCard(context: context, order: order),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
