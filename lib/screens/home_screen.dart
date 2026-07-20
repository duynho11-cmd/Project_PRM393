import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../utils/app_responsive.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fullName     = 'Khách hàng';
  int    _currentIndex = 0;
  String _searchText  = '';
  int    _bannerIndex = 0;
  final  PageController _bannerCtrl = PageController();

  static const _categories = [
    {'name': 'LEGO',       'icon': Icons.extension_rounded,     'color': AppColors.primary},
    {'name': 'Gấu bông',   'icon': Icons.toys_rounded,          'color': AppColors.secondary},
    {'name': 'Giáo dục',   'icon': Icons.school_rounded,        'color': AppColors.success},
    {'name': 'Xe RC',      'icon': Icons.directions_car_rounded, 'color': Color(0xFFFB7185)},
    {'name': 'Ngoài trời', 'icon': Icons.sports_soccer_rounded,  'color': Color(0xFF8B5CF6)},
  ];

  static const List<_BannerItem> _banners = [
    _BannerItem(
      label: 'BỘ SƯU TẬP MỚI', title: 'Giảm giá\ntới 50%',
      icon: Icons.extension_rounded,
      gradient: AppColors.primaryGradient,
      accentColor: AppColors.secondary,
    ),
    _BannerItem(
      label: 'ĐỒ CHƠI GIÁO DỤC', title: 'Phát triển\ntư duy bé',
      icon: Icons.school_rounded,
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF059669), Color(0xFF10B981)],
      ),
      accentColor: Color(0xFFFEF3C7),
    ),
    _BannerItem(
      label: 'XE ĐIỀU KHIỂN', title: 'Tốc độ &\nMạo hiểm',
      icon: Icons.directions_car_rounded,
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFFDB2777), Color(0xFFFB7185)],
      ),
      accentColor: Color(0xFFFEE2E2),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _bannerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users').doc(user.uid).get();
    if (!mounted) return;
    setState(() {
      fullName = doc.data()?['fullName'] ?? user.email ?? 'Khách hàng';
    });
  }

  String _fmt(int price) => '${price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';

  void _handleBottomNav(int index) {
    setState(() => _currentIndex = index);
    if (index == 1) Navigator.pushNamed(context, '/category');
    else if (index == 2) Navigator.pushNamed(context, '/orders');
    else if (index == 3) Navigator.pushNamed(context, '/cart');
    else if (index == 4) Navigator.pushNamed(context, '/profile');
  }

  // ─── Product card ──────────────────────────────────────────────────────────
  Widget _buildProductCard(ProductModel product, AppResponsive r) {
    final bool hasDiscount =
        product.oldPrice > 0 && product.oldPrice > product.price;
    final int discountPct = hasDiscount
        ? ((1 - product.price / product.oldPrice) * 100).round()
        : 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppColors.radiusXl),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadow(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppColors.radiusXl)),
                    child: CachedNetworkImage(
                      imageUrl: product.image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppColors.surfaceVariant,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surfaceVariant,
                        child: Icon(Icons.image_not_supported_outlined,
                            color: AppColors.textLight,
                            size: r.icon(32)),
                      ),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: r.h(10), left: r.w(10),
                      child: Container(
                        padding: r.sym(8, 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentRed,
                          borderRadius:
                          BorderRadius.circular(AppColors.radiusSm),
                        ),
                        child: Text('-$discountPct%',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: r.sp(10),
                                fontWeight: FontWeight.w900)),
                      ),
                    ),
                  // Wishlist
                  Positioned(
                    top: r.h(8), right: r.w(8),
                    child: Container(
                      width: r.w(32), height: r.w(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: AppColors.softShadow(),
                      ),
                      child: Icon(Icons.favorite_border_rounded,
                          size: r.icon(16), color: AppColors.textGrey),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: r.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.category.toUpperCase(),
                      style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: r.sp(9),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2)),
                  SizedBox(height: r.h(3)),
                  Text(product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          fontSize: r.sp(13),
                          height: 1.3)),
                  SizedBox(height: r.h(6)),
                  Row(children: [
                    Icon(Icons.star_rounded,
                        color: AppColors.secondary, size: r.icon(13)),
                    SizedBox(width: r.w(2)),
                    Text(product.rating.toString(),
                        style: TextStyle(
                            fontSize: r.sp(11),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                  ]),
                  SizedBox(height: r.h(8)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_fmt(product.price),
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: r.sp(15))),
                            if (hasDiscount)
                              Text(_fmt(product.oldPrice),
                                  style: TextStyle(
                                      color: AppColors.textLight,
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: r.sp(11))),
                          ],
                        ),
                      ),
                      Container(
                        width: r.w(30), height: r.w(30),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                          BorderRadius.circular(AppColors.radiusSm),
                        ),
                        child: Icon(Icons.add_rounded,
                            color: Colors.white, size: r.icon(18)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Search bar — tách ra widget ngoài để không rebuild HomeScreen ──────────
  Widget _buildSearchBar(AppResponsive r) {
    return _SearchBar(
      onChanged: (v) => setState(() => _searchText = v),
      r: r,
    );
  }

  // ─── Banner carousel ───────────────────────────────────────────────────────
  Widget _buildBannerCarousel(AppResponsive r) {
    return Column(
      children: [
        SizedBox(
          height: r.h(152),
          child: PageView.builder(
            controller: _bannerCtrl,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (_, i) {
              final b = _banners[i];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: r.w(2)),
                padding: r.all(22),
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(AppColors.radiusXl),
                  gradient: b.gradient,
                  boxShadow: AppColors.coloredShadow(AppColors.primary),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: r.sym(10, 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(
                                  AppColors.radiusSm),
                            ),
                            child: Text(b.label,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: r.sp(9),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5)),
                          ),
                          SizedBox(height: r.h(10)),
                          Text(b.title,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: r.sp(22),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  height: 1.2)),
                        ],
                      ),
                    ),
                    Container(
                      width: r.w(80), height: r.w(80),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius:
                        BorderRadius.circular(AppColors.radiusLg),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Icon(b.icon,
                          color: b.accentColor, size: r.icon(44)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: r.h(10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final active = _bannerIndex == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: r.w(3)),
              width:  active ? r.w(20) : r.w(6),
              height: r.h(6),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(r.r(10)),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─── Category chip ─────────────────────────────────────────────────────────
  Widget _buildCategoryChip(Map<String, dynamic> item, AppResponsive r) {
    final Color color = item['color'] as Color;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/category'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: r.w(60), height: r.w(60),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppColors.radiusMd),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(item['icon'] as IconData,
                color: color, size: r.icon(28)),
          ),
          SizedBox(height: r.h(6)),
          Text(item['name'].toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: r.sp(11),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMedium)),
        ],
      ),
    );
  }

  // ─── Bottom nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav(AppResponsive r) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppColors.floatingShadow(),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleBottomNav,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        elevation: 0,
        selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w700, fontSize: r.sp(11)),
        unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500, fontSize: r.sp(11)),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Trang chủ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Danh mục'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Đơn hàng'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag_rounded),
              label: 'Giỏ hàng'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Cá nhân'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNav(r),
      body: SafeArea(
        child: ListView(
          padding: r.fromLTRB(20, 0, 20, 28),
          children: [
            // ── Header ────────────────────────────────────────────
            SizedBox(height: r.h(16)),
            Row(children: [
              Container(
                width: r.w(44), height: r.w(44),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(AppColors.radiusMd),
                  boxShadow: AppColors.softShadow(),
                ),
                padding: r.all(6),
                child: Image.asset('assets/images/logo.png',
                    fit: BoxFit.contain),
              ),
              SizedBox(width: r.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào, ${fullName.split(' ').last} 👋',
                      style: TextStyle(
                          fontSize: r.sp(17),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.3),
                    ),
                    Text('Hôm nay bé muốn chơi gì?',
                        style: TextStyle(
                            fontSize: r.sp(13),
                            color: AppColors.textGrey)),
                  ],
                ),
              ),
              Stack(children: [
                Container(
                  width: r.w(44), height: r.w(44),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(AppColors.radiusMd),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.softShadow(),
                  ),
                  child: Icon(Icons.notifications_none_rounded,
                      color: AppColors.textDark, size: r.icon(22)),
                ),
                Positioned(
                  top: r.h(8), right: r.w(8),
                  child: Container(
                    width: r.w(8), height: r.w(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentRed,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ]),
            ]),

            SizedBox(height: r.h(18)),
            _buildSearchBar(r),

            SizedBox(height: r.h(22)),
            _buildBannerCarousel(r),

            // ── Categories ──────────────────────────────────────────
            SizedBox(height: r.h(26)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Danh mục',
                    style: TextStyle(
                        fontSize: r.sp(18),
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                        letterSpacing: -0.3)),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/category'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Xem tất cả',
                      style: TextStyle(
                          fontSize: r.sp(13),
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            SizedBox(height: r.h(14)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _categories
                  .map((c) => _buildCategoryChip(
                  c as Map<String, dynamic>, r))
                  .toList(),
            ),

            // ── Products ────────────────────────────────────────────
            SizedBox(height: r.h(26)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _searchText.isEmpty
                      ? 'Sản phẩm nổi bật'
                      : 'Kết quả tìm kiếm',
                  style: TextStyle(
                      fontSize: r.sp(18),
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      letterSpacing: -0.3),
                ),
                if (_searchText.isEmpty)
                  Container(
                    padding: r.sym(10, 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius:
                      BorderRadius.circular(AppColors.radiusSm),
                    ),
                    child: Text('Mới nhất',
                        style: TextStyle(
                            fontSize: r.sp(12),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ),
              ],
            ),
            SizedBox(height: r.h(14)),

            StreamBuilder<List<ProductModel>>(
              stream: ProductService().getFeaturedProducts(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: r.all(48),
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    ),
                  );
                }
                if (snap.hasError) {
                  return Padding(
                    padding: r.all(16),
                    child: Text('Lỗi: ${snap.error}',
                        style: const TextStyle(
                            color: AppColors.accentRed)),
                  );
                }
                final products = snap.data ?? [];
                final filtered = _searchText.isEmpty
                    ? products
                    : products
                    .where((p) =>
                p.name
                    .toLowerCase()
                    .contains(_searchText) ||
                    p.category
                        .toLowerCase()
                        .contains(_searchText))
                    .toList();

                if (filtered.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: r.h(40)),
                    child: Center(
                      child: Column(children: [
                        Container(
                          width: r.w(72), height: r.w(72),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(
                                AppColors.radiusLg),
                          ),
                          child: Icon(Icons.search_off_rounded,
                              color: AppColors.textLight,
                              size: r.icon(36)),
                        ),
                        SizedBox(height: r.h(14)),
                        Text(
                          _searchText.isEmpty
                              ? 'Chưa có sản phẩm nào'
                              : 'Không tìm thấy "$_searchText"',
                          style: TextStyle(
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w600,
                              fontSize: r.sp(15)),
                        ),
                      ]),
                    ),
                  );
                }

                // Tablet: 3 cột, phone: 2 cột
                final crossCount = r.isTablet ? 3 : 2;

                return GridView.builder(
                  itemCount: filtered.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    mainAxisSpacing: r.h(14),
                    crossAxisSpacing: r.w(14),
                    childAspectRatio: 0.62,
                  ),
                  itemBuilder: (_, i) =>
                      _buildProductCard(filtered[i], r),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerItem {
  final String label;
  final String title;
  final IconData icon;
  final LinearGradient gradient;
  final Color accentColor;

  const _BannerItem({
    required this.label,
    required this.title,
    required this.icon,
    required this.gradient,
    required this.accentColor,
  });
}

// ─── Search bar tách riêng — chỉ rebuild chính nó khi gõ ─────────────────────
class _SearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final AppResponsive r;

  const _SearchBar({required this.onChanged, required this.r});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow(),
      ),
      child: TextField(
        controller: _ctrl,
        onChanged: (v) => widget.onChanged(v.trim().toLowerCase()),
        style: TextStyle(fontSize: r.sp(15), color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: 'Tìm LEGO, gấu bông, xe điều khiển...',
          prefixIcon: Icon(Icons.search_rounded,
              color: AppColors.textGrey, size: r.icon(22)),
          border: InputBorder.none,
          contentPadding: r.sym(16, 16),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _ctrl,
            builder: (_, val, __) => val.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
              icon: Icon(Icons.clear_rounded,
                  color: AppColors.textGrey, size: r.icon(18)),
              onPressed: () {
                _ctrl.clear();
                widget.onChanged('');
              },
            ),
          ),
        ),
      ),
    );
  }
}
