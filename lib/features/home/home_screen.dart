import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../product/category_screen.dart';
import '../product/product_list_screen.dart';
// import '../cart/cart_screen.dart';
// import '../order/order_history_screen.dart';
// import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  String fullName = 'Khách hàng';
  String email = '';

  final List<Map<String, dynamic>> categories = const [
    {
      'title': 'LEGO xây dựng',
      'image':
      'https://images.unsplash.com/photo-1587654780291-39c9404d746b?q=80&w=500',
    },
    {
      'title': 'LEGO ninja go',
      'image':
      'https://images.unsplash.com/photo-1608889175123-8ee362201f81?q=80&w=500',
    },
    {
      'title': 'LEGO chima',
      'image':
      'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?q=80&w=500',
    },
    {
      'title': 'LEGO siêu xe',
      'image':
      'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?q=80&w=500',
    },
    {
      'title': 'LEGO tự do',
      'image':
      'https://images.unsplash.com/photo-1585366119957-e9730b6d0f60?q=80&w=500',
    },
  ];

  final List<Map<String, dynamic>> products = const [
    {
      'name': 'Bộ lắp ráp LEGO Technic Siêu Xe',
      'category': 'LEGO siêu xe',
      'price': '1.450.000đ',
      'oldPrice': '1.700.000đ',
      'rating': '4.9',
      'stock': '20',
      'image':
      'https://www.lego.com/cdn/cs/set/assets/blt45f8e777457f6869/10337_boxprod_v39_sha.jpg?fit=crop&quality=80&width=800&height=800&dpr=1',
    },
    {
      'name': 'LEGO siêu robot',
      'category': 'LEGO robot',
      'price': '890.000đ',
      'oldPrice': '1.100.000đ',
      'rating': '4.8',
      'stock': '15',
      'image': 'https://i.ebayimg.com/images/g/7x8AAOSwjsVey-Ix/s-l400.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    await FirebaseAuth.instance.currentUser?.reload();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      fullName = user.displayName ?? 'Khách hàng';
      email = user.email ?? '';
    });
  }

  void _openCategoryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CategoryScreen(),
      ),
    );
  }

  void _openProductList(String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductListScreen(categoryName: categoryName),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        _openCategoryScreen();
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Màn Đơn hàng chưa tạo')),
        );
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Màn Giỏ hàng chưa tạo')),
        );
        break;
      case 4:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Màn Tài khoản chưa tạo')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 18),
              _searchBox(),
              const SizedBox(height: 18),
              _banner(),
              const SizedBox(height: 24),
              _sectionTitle('Danh Mục Sản Phẩm', 'Xem tất cả'),
              const SizedBox(height: 14),
              _categoryList(),
              const SizedBox(height: 26),
              _sectionTitle('Sản Phẩm Nổi Bật', 'Tất cả'),
              const SizedBox(height: 14),
              _productGrid(),
              const SizedBox(height: 22),
              _suggestionCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _header() {
    final avatarText = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF5B35F5),
          child: Text(
            avatarText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chào buổi sáng,',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              Text(
                '$fullName 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_none),
        ),
      ],
    );
  }

  Widget _searchBox() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Tìm đồ chơi yêu thích của bé...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _banner() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1587654780291-39c9404d746b?q=80&w=1200',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(.58),
              Colors.black.withOpacity(.10),
            ],
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              label: Text(
                'Ưu đãi tháng 10',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
              backgroundColor: Color(0xFFFFB800),
            ),
            Spacer(),
            Text(
              'Thế Giới LEGO\nGiảm Đến 40%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String action) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: Color(0xFF111827),
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: () {
            if (title == 'Danh Mục Sản Phẩm') {
              _openCategoryScreen();
            }
          },
          child: Text(
            action,
            style: const TextStyle(
              color: Color(0xFF5B35F5),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryList() {
    return SizedBox(
      height: 105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final item = categories[index];

          return InkWell(
            onTap: () => _openProductList(item['title']),
            child: SizedBox(
              width: 82,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      item['image'],
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _productGrid() {
    return GridView.builder(
      itemCount: products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: .62,
      ),
      itemBuilder: (context, index) {
        return _productCard(products[index]);
      },
    );
  }

  Widget _productCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            product['image'],
            height: 130,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(product['category']),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              product['name'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              product['price'],
              style: const TextStyle(
                color: Color(0xFF4F46E5),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Text(
        'Gợi ý cho bé 3-5 tuổi\nNhững bộ đồ chơi phát triển trí tuệ tốt nhất',
        style: TextStyle(
          color: Color(0xFF4F46E5),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: const Color(0xFF5B35F5),
      unselectedItemColor: const Color(0xFF9CA3AF),
      type: BottomNavigationBarType.fixed,
      onTap: _onBottomNavTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Danh mục',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Đơn hàng',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'Giỏ hàng',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Tài khoản',
        ),
      ],
    );
  }
}