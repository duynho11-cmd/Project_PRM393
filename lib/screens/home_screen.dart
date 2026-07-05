import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color darkBlue = Color(0xFF0B4DBA);
  static const Color primaryYellow = Color(0xFFFFD93D);
  static const Color bgColor = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF64748B);

  String fullName = 'Khách hàng';
  int currentIndex = 0;
  String searchText = '';

  final categories = [
    {'name': 'LEGO', 'icon': Icons.extension, 'color': primaryBlue},
    {'name': 'Gấu bông', 'icon': Icons.toys, 'color': primaryYellow},
    {'name': 'Giáo dục', 'icon': Icons.school, 'color': Color(0xFF22C55E)},
    {'name': 'Xe RC', 'icon': Icons.directions_car, 'color': Color(0xFFFB7185)},
    {'name': 'outdoor', 'icon': Icons.sports_soccer_rounded, 'color': Color(0xFF8B5CF6)},
  ];

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    setState(() {
      fullName = doc.data()?['fullName'] ?? user.email ?? 'Khách hàng';
    });
  }

  String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    )}đ';
  }

  void handleBottomNav(int index) {
    setState(() => currentIndex = index);

    if (index == 1) {
      Navigator.pushNamed(context, '/category');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/orders');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/cart');
    } else if (index == 4) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  Widget buildProductCard(ProductModel product) {
    final bool hasDiscount =
        product.oldPrice > 0 && product.oldPrice > product.price;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: Image.network(
                      product.image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: textGrey,
                          ),
                        );
                      },
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: primaryYellow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'SALE',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textGrey,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: textDark,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: primaryYellow,
                        size: 17,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Còn ${product.stock}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: darkBlue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    formatPrice(product.price),
                    style: const TextStyle(
                      color: darkBlue,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),

                  if (hasDiscount)
                    Text(
                      formatPrice(product.oldPrice),
                      style: const TextStyle(
                        color: textGrey,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          searchText = value.trim().toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Tìm LEGO, gấu bông, xe điều khiển...',
        prefixIcon: const Icon(Icons.search_rounded, color: textGrey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildBanner() {
    return Container(
      height: 168,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [darkBlue, primaryBlue],
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Bộ sưu tập LEGO mới\nGiảm giá tới 50%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.extension_rounded,
              color: primaryYellow,
              size: 56,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryCard(Map<String, dynamic> item) {
    final Color color = item['color'] as Color;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.pushNamed(context, '/category');
      },
      child: Container(
        width: 108,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item['icon'] as IconData,
              color: color,
              size: 30,
            ),
            const SizedBox(height: 10),
            Text(
              item['name'].toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: darkBlue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: handleBottomNav,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_rounded),
          label: 'Danh mục',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_rounded),
          label: 'Đơn hàng',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_rounded),
          label: 'Giỏ hàng',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Cá nhân',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: buildBottomNav(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 58,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Xin chào, $fullName 👋\nHôm nay bé muốn chơi gì?',
                    style: const TextStyle(
                      fontSize: 16.5,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: primaryYellow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),

            const SizedBox(height: 24),
            buildSearchBar(),

            const SizedBox(height: 24),
            buildBanner(),

            const SizedBox(height: 28),

            const Text(
              'Danh mục',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 108,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  return buildCategoryCard(categories[index]);
                },
              ),
            ),

            const SizedBox(height: 28),

            Text(
              searchText.isEmpty ? 'Sản phẩm nổi bật' : 'Kết quả tìm kiếm',
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),

            const SizedBox(height: 14),

            StreamBuilder<List<ProductModel>>(
              stream: ProductService().getFeaturedProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Text('Lỗi: ${snapshot.error}');
                }

                final products = snapshot.data ?? [];

                final filteredProducts = searchText.isEmpty
                    ? products
                    : products.where((product) {
                  return product.name.toLowerCase().contains(searchText) ||
                      product.category.toLowerCase().contains(searchText);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return Text(
                    searchText.isEmpty
                        ? 'Chưa có sản phẩm nào'
                        : 'Không tìm thấy sản phẩm phù hợp',
                    style: const TextStyle(color: textGrey),
                  );
                }

                return GridView.builder(
                  itemCount: filteredProducts.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.62,
                  ),
                  itemBuilder: (context, index) {
                    return buildProductCard(filteredProducts[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}