import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'product_list_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color darkBlue = Color(0xFF0B4DBA);
  static const Color bgColor = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF64748B);

  String viName(String name) {
    switch (name) {
      case 'Educational':
        return 'Giáo dục';
      case 'LEGO':
        return 'LEGO';
      case 'Outdoor':
        return 'Ngoài trời';
      case 'RC Toys':
        return 'Xe điều khiển';
      case 'Teddy Bears':
        return 'Gấu bông';
      default:
        return name;
    }
  }

  IconData getIcon(String icon) {
    switch (icon) {
      case 'extension':
        return Icons.extension_rounded;
      case 'toys':
        return Icons.toys_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'car':
        return Icons.directions_car_rounded;
      case 'outdoor':
        return Icons.sports_soccer_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color getColor(String color) {
    switch (color) {
      case 'blue':
        return primaryBlue;
      case 'orange':
        return Colors.orange;
      case 'green':
        return const Color(0xFF22C55E);
      case 'red':
        return const Color(0xFFFB7185);
      case 'purple':
        return const Color(0xFF8B5CF6);
      default:
        return darkBlue;
    }
  }

  Widget buildCategoryCard({
    required BuildContext context,
    required String displayName,
    required String categoryName,
    required String icon,
    required String color,
  }) {
    final Color itemColor = getColor(color);

    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductListScreen(
              categoryName: categoryName,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: itemColor.withOpacity(0.12),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: itemColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                getIcon(icon),
                color: itemColor,
                size: 32,
              ),
            ),

            const Spacer(),

            Text(
              displayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: textDark,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Text(
                  'Xem sản phẩm',
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: itemColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: itemColor,
                    size: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: darkBlue,
      ),
    );
  }

  Widget buildEmpty() {
    return const Center(
      child: Text(
        'Chưa có danh mục nào',
        style: TextStyle(
          color: textGrey,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget buildError(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Lỗi: $error',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Danh mục sản phẩm',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: textDark,
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
            return buildLoading();
          }

          if (snapshot.hasError) {
            return buildError(snapshot.error);
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return buildEmpty();
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Container(
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
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Khám phá đồ chơi\nphù hợp cho bé',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.category_rounded,
                          color: Color(0xFFFFD93D),
                          size: 64,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final data = docs[index].data();

                      final originalName = data['name'] ?? '';
                      final displayName = viName(originalName);
                      final icon = data['icon'] ?? '';
                      final color = data['color'] ?? '';

                      return buildCategoryCard(
                        context: context,
                        displayName: displayName,
                        categoryName: originalName,
                        icon: icon,
                        color: color,
                      );
                    },
                    childCount: docs.length,
                  ),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
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