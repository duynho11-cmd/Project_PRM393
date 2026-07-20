import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../utils/app_responsive.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int  _qty   = 1;
  bool _isFav = false;

  String _fmt(int price) => '${price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';

  String _viName(String name) {
    const map = {
      'Educational': 'Giáo dục', 'LEGO': 'LEGO',
      'Outdoor': 'Ngoài trời',   'RC Toys': 'Xe điều khiển',
      'Teddy Bears': 'Gấu bông',
    };
    return map[name] ?? name;
  }

  Future<void> _addToCart(ProductModel product) async {
    if (product.stock <= 0) {
      _showSnack('Sản phẩm đã hết hàng', isError: true); return;
    }
    final err = await CartService()
        .addToCart(product: product, quantity: _qty);
    if (!mounted) return;
    err == null
        ? _showSnack('Đã thêm vào giỏ hàng ✓')
        : _showSnack(err, isError: true);
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.accentRed : AppColors.success,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final r       = AppResponsive(context);
    final product = widget.product;
    final bool hasDiscount =
        product.oldPrice > 0 && product.oldPrice > product.price;
    final int discountPct = hasDiscount
        ? ((1 - product.price / product.oldPrice) * 100).round()
        : 0;
    final bool inStock = product.stock > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: r.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppColors.softShadow(),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  color: AppColors.textDark, size: r.icon(20)),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: r.w(12)),
            child: GestureDetector(
              onTap: () => setState(() => _isFav = !_isFav),
              child: Container(
                width: r.w(40), height: r.w(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.softShadow(),
                ),
                child: Icon(
                  _isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _isFav ? AppColors.accentRed : AppColors.textGrey,
                  size: r.icon(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Hero image ───────────────────────────────────────────
          SizedBox(
            height: MediaQuery.of(context).size.height *
                (r.isTablet ? 0.38 : 0.42),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (_, __) => Container(
                    color: AppColors.surfaceVariant,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.surfaceVariant,
                    child: Icon(Icons.image_not_supported_outlined,
                        size: r.icon(60), color: AppColors.textLight),
                  ),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  height: r.h(80),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.background,
                          AppColors.background.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    bottom: r.h(20), left: r.w(20),
                    child: Container(
                      padding: r.sym(12, 6),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed,
                        borderRadius:
                        BorderRadius.circular(AppColors.radiusSm),
                        boxShadow:
                        AppColors.coloredShadow(AppColors.accentRed),
                      ),
                      child: Text('-$discountPct% GIẢM',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: r.sp(11),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5)),
                    ),
                  ),
              ],
            ),
          ),

          // ── Detail panel ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: r.fromLTRB(20, 4, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + stock
                  Row(children: [
                    Container(
                      padding: r.sym(10, 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius:
                        BorderRadius.circular(AppColors.radiusSm),
                      ),
                      child: Text(
                        _viName(product.category).toUpperCase(),
                        style: TextStyle(
                            fontSize: r.sp(10),
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 1),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: r.sym(10, 4),
                      decoration: BoxDecoration(
                        color: inStock
                            ? AppColors.successLight
                            : const Color(0xFFFEE2E2),
                        borderRadius:
                        BorderRadius.circular(AppColors.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: r.w(6), height: r.w(6),
                            decoration: BoxDecoration(
                              color: inStock
                                  ? AppColors.success
                                  : AppColors.accentRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: r.w(5)),
                          Text(
                            inStock
                                ? 'Còn ${product.stock}'
                                : 'Hết hàng',
                            style: TextStyle(
                                fontSize: r.sp(11),
                                fontWeight: FontWeight.w700,
                                color: inStock
                                    ? AppColors.success
                                    : AppColors.accentRed),
                          ),
                        ],
                      ),
                    ),
                  ]),

                  SizedBox(height: r.h(10)),
                  Text(product.name,
                      style: TextStyle(
                          fontSize: r.sp(22),
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                          letterSpacing: -0.5,
                          height: 1.25)),

                  SizedBox(height: r.h(10)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: r.sym(10, 5),
                        decoration: BoxDecoration(
                          color:
                          AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius:
                          BorderRadius.circular(AppColors.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded,
                                size: r.icon(15),
                                color: AppColors.secondary),
                            SizedBox(width: r.w(4)),
                            Text(product.rating.toString(),
                                style: TextStyle(
                                    fontSize: r.sp(13),
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (hasDiscount)
                            Text(_fmt(product.oldPrice),
                                style: TextStyle(
                                    color: AppColors.textLight,
                                    decoration:
                                    TextDecoration.lineThrough,
                                    fontSize: r.sp(13))),
                          Text(_fmt(product.price),
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: r.sp(26),
                                  letterSpacing: -0.5)),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: r.h(18)),
                  const Divider(height: 1),
                  SizedBox(height: r.h(18)),

                  if (product.description.isNotEmpty) ...[
                    Text('Mô tả sản phẩm',
                        style: TextStyle(
                            fontSize: r.sp(16),
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark)),
                    SizedBox(height: r.h(8)),
                    Text(product.description,
                        style: TextStyle(
                            fontSize: r.sp(14),
                            color: AppColors.textGrey,
                            height: 1.65)),
                    SizedBox(height: r.h(18)),
                    const Divider(height: 1),
                    SizedBox(height: r.h(18)),
                  ],

                  // Quantity
                  Row(children: [
                    Text('Số lượng',
                        style: TextStyle(
                            fontSize: r.sp(15),
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark)),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(AppColors.radiusMd),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _qtyBtn(r,
                              icon: Icons.remove_rounded,
                              active: _qty > 1,
                              onTap: () {
                                if (_qty > 1) setState(() => _qty--);
                              }),
                          SizedBox(
                            width: r.w(36),
                            child: Text('$_qty',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: r.sp(16),
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDark)),
                          ),
                          _qtyBtn(r,
                              icon: Icons.add_rounded,
                              active: _qty < product.stock,
                              onTap: () {
                                if (_qty < product.stock) {
                                  setState(() => _qty++);
                                }
                              }),
                        ],
                      ),
                    ),
                  ]),

                  _buildRelated(r, product),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom CTA ───────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: r.fromLTRB(20, 12, 20, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: AppColors.floatingShadow(),
        ),
        child: SafeArea(
          child: Row(children: [
            Container(
              width: r.w(54), height: r.h(54),
              margin: EdgeInsets.only(right: r.w(12)),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius:
                BorderRadius.circular(AppColors.radiusMd),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: IconButton(
                onPressed: inStock ? () => _addToCart(product) : null,
                icon: Icon(Icons.shopping_cart_outlined,
                    color: AppColors.primary, size: r.icon(22)),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: inStock
                    ? () async {
                  final err = await CartService()
                      .addToCart(product: product, quantity: _qty);
                  if (!mounted) return;
                  if (err == null) {
                    Navigator.pushNamed(context, '/cart');
                  } else {
                    _showSnack(err, isError: true);
                  }
                }
                    : null,
                child: Container(
                  height: r.h(54),
                  decoration: BoxDecoration(
                    gradient:
                    inStock ? AppColors.primaryGradient : null,
                    color: inStock ? null : AppColors.border,
                    borderRadius:
                    BorderRadius.circular(AppColors.radiusMd),
                    boxShadow: inStock
                        ? AppColors.coloredShadow(AppColors.primary)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      inStock ? 'Mua ngay' : 'Hết hàng',
                      style: TextStyle(
                        color: inStock
                            ? Colors.white
                            : AppColors.textLight,
                        fontSize: r.sp(16),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _qtyBtn(AppResponsive r,
      {required IconData icon,
        required bool active,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: active ? onTap : null,
      child: SizedBox(
        width: r.w(36), height: r.w(36),
        child: Icon(icon,
            size: r.icon(18),
            color: active ? AppColors.textDark : AppColors.textLight),
      ),
    );
  }

  Widget _buildRelated(AppResponsive r, ProductModel product) {
    return StreamBuilder<List<ProductModel>>(
      stream: ProductService().getRelatedProducts(
        category: product.category,
        currentProductId: product.id,
      ),
      builder: (context, snap) {
        final items = snap.data ?? [];
        if (snap.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.only(top: r.h(28)),
            child: const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary)),
          );
        }
        if (items.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: r.h(24)),
            const Divider(height: 1),
            SizedBox(height: r.h(20)),
            Text('Gợi ý cùng loại',
                style: TextStyle(
                    fontSize: r.sp(16),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
            SizedBox(height: r.h(14)),
            SizedBox(
              height: r.h(220),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    SizedBox(width: r.w(12)),
                itemBuilder: (_, i) {
                  final item = items[i];
                  final disc = item.oldPrice > 0 &&
                      item.oldPrice > item.price;
                  return GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailScreen(product: item)),
                    ),
                    child: Container(
                      width: r.w(148),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            AppColors.radiusXl),
                        border: Border.all(color: AppColors.border),
                        boxShadow: AppColors.softShadow(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Stack(children: [
                              ClipRRect(
                                borderRadius:
                                const BorderRadius.vertical(
                                    top: Radius.circular(
                                        AppColors.radiusXl)),
                                child: CachedNetworkImage(
                                    imageUrl: item.image,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                        color: AppColors.surfaceVariant),
                                    errorWidget: (_, __, ___) =>
                                        Container(
                                          color: AppColors.surfaceVariant,
                                          child: Icon(
                                              Icons
                                                  .image_not_supported_outlined,
                                              color:
                                              AppColors.textLight,
                                              size: r.icon(24)),
                                        )),
                              ),
                              if (disc)
                                Positioned(
                                  top: r.h(8), left: r.w(8),
                                  child: Container(
                                    padding: r.sym(7, 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentRed,
                                      borderRadius:
                                      BorderRadius.circular(
                                          r.r(6)),
                                    ),
                                    child: Text('SALE',
                                        style: TextStyle(
                                            fontSize: r.sp(9),
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white)),
                                  ),
                                ),
                            ]),
                          ),
                          Padding(
                            padding: r.all(10),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: r.sp(13),
                                        color: AppColors.textDark)),
                                SizedBox(height: r.h(4)),
                                Text(_fmt(item.price),
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w900,
                                        fontSize: r.sp(13))),
                                SizedBox(height: r.h(4)),
                                Row(children: [
                                  Icon(Icons.star_rounded,
                                      size: r.icon(12),
                                      color: AppColors.secondary),
                                  SizedBox(width: r.w(2)),
                                  Text(item.rating.toString(),
                                      style: TextStyle(
                                          fontSize: r.sp(10),
                                          color: AppColors.textGrey,
                                          fontWeight:
                                          FontWeight.w600)),
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
