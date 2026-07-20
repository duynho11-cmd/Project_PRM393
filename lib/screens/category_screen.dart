import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../utils/app_responsive.dart';
import 'product_list_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  // ── Helpers ──────────────────────────────────────────────────────────────
  String _viName(String name) {
    const map = {
      'Educational': 'Giáo dục',
      'LEGO':        'LEGO',
      'Outdoor':     'Ngoài trời',
      'RC Toys':     'Xe điều khiển',
      'Teddy Bears': 'Gấu bông',
    };
    return map[name] ?? name;
  }

  IconData _getIcon(String icon) {
    switch (icon) {
      case 'extension': return Icons.extension_rounded;
      case 'toys':      return Icons.toys_rounded;
      case 'school':    return Icons.school_rounded;
      case 'car':       return Icons.directions_car_rounded;
      case 'outdoor':   return Icons.sports_soccer_rounded;
      default:          return Icons.category_rounded;
    }
  }

  Color _getColor(String color) {
    switch (color) {
      case 'blue':   return AppColors.primary;
      case 'orange': return AppColors.secondary;
      case 'green':  return AppColors.success;
      case 'red':    return AppColors.accentRed;
      case 'purple': return const Color(0xFF8B5CF6);
      default:       return AppColors.primary;
    }
  }

  // ── Category card ─────────────────────────────────────────────────────────
  Widget _buildCard({
    required BuildContext context,
    required AppResponsive r,
    required String displayName,
    required String categoryName,
    required String icon,
    required String color,
  }) {
    final Color itemColor = _getColor(color);

    return InkWell(
      borderRadius: BorderRadius.circular(r.r(26)),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductListScreen(categoryName: categoryName),
        ),
      ),
      child: Container(
        padding: r.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.r(26)),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.premiumShadow(
            color: itemColor.withValues(alpha: 0.06),
            blur: 16,
            offset: const Offset(0, 8),
          ),
        ),
        // Dùng Column với mainAxisSize.min để tránh overflow
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width:  r.w(52),
              height: r.w(52),
              decoration: BoxDecoration(
                color: itemColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(r.r(16)),
              ),
              child: Icon(_getIcon(icon),
                  color: itemColor, size: r.icon(26)),
            ),

            SizedBox(height: r.h(14)),

            // Category name — flexible, không bị overflow
            Text(
              displayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: r.sp(15),
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                height: 1.25,
              ),
            ),

            SizedBox(height: r.h(10)),

            // Footer row
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Xem sản phẩm',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: r.sp(12),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: r.w(6)),
                Container(
                  width:  r.w(28),
                  height: r.w(28),
                  decoration: BoxDecoration(
                    color: itemColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(r.r(10)),
                  ),
                  child: Icon(Icons.arrow_forward_rounded,
                      color: itemColor, size: r.icon(15)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Danh mục sản phẩm',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
            fontSize: r.sp(20),
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: r.all(24),
                child: Text(
                  'Lỗi: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.accentRed,
                    fontWeight: FontWeight.w600,
                    fontSize: r.sp(14),
                  ),
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'Chưa có danh mục nào',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: r.sp(15),
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          // Tablet: 3 cột, phone: 2 cột
          final crossCount = r.isTablet ? 3 : 2;

          return CustomScrollView(
            slivers: [
              // ── Hero banner ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: r.fromLTRB(20, 8, 20, 20),
                  child: Container(
                    padding: r.all(22),
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(AppColors.radiusXl),
                      gradient: AppColors.primaryGradient,
                      boxShadow: AppColors.coloredShadow(AppColors.primary),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Khám phá đồ chơi\nphù hợp cho bé',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: r.sp(20),
                                  fontWeight: FontWeight.w900,
                                  height: 1.3,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: r.h(8)),
                              Text(
                                '${docs.length} danh mục',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: r.sp(13),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.category_rounded,
                            color: AppColors.secondary,
                            size: r.icon(56)),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Grid ─────────────────────────────────────────────
              SliverPadding(
                padding: r.fromLTRB(20, 0, 20, 24),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final data         = docs[index].data();
                      final originalName = data['name'] ?? '';
                      final displayName  = _viName(originalName);
                      final icon         = data['icon']  ?? '';
                      final color        = data['color'] ?? '';

                      return _buildCard(
                        context:      context,
                        r:            r,
                        displayName:  displayName,
                        categoryName: originalName,
                        icon:         icon,
                        color:        color,
                      );
                    },
                    childCount: docs.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:  crossCount,
                    mainAxisSpacing:  r.h(16),
                    crossAxisSpacing: r.w(16),
                    // Tăng ratio để đủ chỗ cho nội dung, tránh overflow
                    childAspectRatio: r.isTablet ? 0.90 : 0.88,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
