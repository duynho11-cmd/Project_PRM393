import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/cart_service.dart';
import '../utils/app_responsive.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  String _fmt(int price) => '${price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';

  int _total(List<Map<String, dynamic>> items) {
    int t = 0;
    for (final i in items) {
      t += ((i['price'] as num?)?.toInt() ?? 0) *
          ((i['quantity'] as num?)?.toInt() ?? 0);
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accentRed,
              padding: EdgeInsets.symmetric(horizontal: r.p(16)),
            ),
            child: Text('Xoá tất cả',
                style: TextStyle(
                    fontSize: r.sp(13), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: CartService().getCartItems(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                CircularProgressIndicator(color: AppColors.primary));
          }
          final items = snap.data ?? [];
          if (items.isEmpty) return _buildEmpty(r);
          final total = _total(items);
          return Column(children: [
            Expanded(
              child: ListView.separated(
                padding: r.fromLTRB(20, 12, 20, 16),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: r.h(12)),
                itemBuilder: (_, i) => _buildItem(r, items[i]),
              ),
            ),
            _buildCheckoutPanel(r, total, context, items.length),
          ]);
        },
      ),
    );
  }

  Widget _buildEmpty(AppResponsive r) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: r.w(100), height: r.w(100),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(AppColors.radiusXl),
            ),
            child: Icon(Icons.shopping_bag_outlined,
                size: r.icon(52), color: AppColors.primary),
          ),
          SizedBox(height: r.h(20)),
          Text('Giỏ hàng trống',
              style: TextStyle(
                  fontSize: r.sp(20),
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  letterSpacing: -0.3)),
          SizedBox(height: r.h(8)),
          Text('Hãy thêm sản phẩm yêu thích\ncủa bé vào giỏ hàng.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: r.sp(14),
                  color: AppColors.textGrey,
                  height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildItem(AppResponsive r, Map<String, dynamic> item) {
    final id       = item['id'];
    final name     = item['name'] ?? '';
    final image    = item['image'] ?? '';
    final price    = (item['price'] as num?)?.toInt() ?? 0;
    final qty      = (item['quantity'] as num?)?.toInt() ?? 1;
    final stock    = (item['stock'] as num?)?.toInt() ?? 1;
    final subtotal = price * qty;

    return Container(
      padding: r.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.radiusXl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow(),
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          child: CachedNetworkImage(
              imageUrl: image,
              width: r.w(86), height: r.w(86), fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                  width: r.w(86), height: r.w(86),
                  color: AppColors.surfaceVariant),
              errorWidget: (_, __, ___) => Container(
                width: r.w(86), height: r.w(86),
                color: AppColors.surfaceVariant,
                child: Icon(Icons.image_not_supported_outlined,
                    color: AppColors.textLight,
                    size: r.icon(24)),
              )),
        ),
        SizedBox(width: r.w(14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Text(name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w700,
                          fontSize: r.sp(14),
                          height: 1.3)),
                ),
                GestureDetector(
                  onTap: () => CartService().removeFromCart(id),
                  child: Container(
                    width: r.w(28), height: r.w(28),
                    decoration: BoxDecoration(
                      color: AppColors.accentRed.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(r.r(8)),
                    ),
                    child: Icon(Icons.close_rounded,
                        size: r.icon(16), color: AppColors.accentRed),
                  ),
                ),
              ]),
              SizedBox(height: r.h(6)),
              Text(_fmt(price),
                  style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: r.sp(13),
                      fontWeight: FontWeight.w500)),
              SizedBox(height: r.h(10)),
              Row(children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius:
                    BorderRadius.circular(AppColors.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ctrlBtn(r,
                          icon: Icons.remove_rounded, active: qty > 1,
                          onTap: () => CartService().updateQuantity(
                              productId: id, quantity: qty - 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: r.p(10)),
                        child: Text('$qty',
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: r.sp(14),
                                color: AppColors.textDark)),
                      ),
                      _ctrlBtn(r,
                          icon: Icons.add_rounded,
                          active: qty < stock,
                          onTap: () => CartService().updateQuantity(
                              productId: id, quantity: qty + 1)),
                    ],
                  ),
                ),
                const Spacer(),
                Text(_fmt(subtotal),
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: r.sp(15))),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _ctrlBtn(AppResponsive r,
      {required IconData icon,
        required bool active,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Padding(
        padding: r.all(7),
        child: Icon(icon,
            size: r.icon(16),
            color: active ? AppColors.textDark : AppColors.textLight),
      ),
    );
  }

  Widget _buildCheckoutPanel(
      AppResponsive r, int total, BuildContext context, int itemCount) {
    return Container(
      padding: r.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: AppColors.floatingShadow(),
      ),
      child: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _summaryRow(r, 'Tạm tính ($itemCount sản phẩm)', _fmt(total)),
          SizedBox(height: r.h(6)),
          _summaryRow(r, 'Phí vận chuyển', 'Miễn phí',
              valueColor: AppColors.success),
          Padding(
            padding: EdgeInsets.symmetric(vertical: r.p(12)),
            child: const Divider(height: 1),
          ),
          Row(children: [
            Text('Tổng thanh toán',
                style: TextStyle(
                    fontSize: r.sp(15),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
            const Spacer(),
            Text(_fmt(total),
                style: TextStyle(
                    fontSize: r.sp(22),
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: -0.5)),
          ]),
          SizedBox(height: r.h(14)),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/checkout'),
            child: Container(
              width: double.infinity,
              height: r.h(54),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius:
                BorderRadius.circular(AppColors.radiusMd),
                boxShadow: AppColors.coloredShadow(AppColors.primary),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment_rounded,
                      color: Colors.white, size: r.icon(20)),
                  SizedBox(width: r.w(8)),
                  Text('Thanh toán ngay',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: r.sp(16),
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          SizedBox(height: r.h(8)),
        ]),
      ),
    );
  }

  Widget _summaryRow(AppResponsive r, String label, String value,
      {Color valueColor = AppColors.textDark}) {
    return Row(children: [
      Text(label,
          style: TextStyle(
              fontSize: r.sp(13),
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500)),
      const Spacer(),
      Text(value,
          style: TextStyle(
              fontSize: r.sp(13),
              fontWeight: FontWeight.w700,
              color: valueColor)),
    ]);
  }
}
