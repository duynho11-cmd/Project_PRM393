import 'package:flutter/material.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String categoryName;

  const ProductListScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String selectedSort = 'Phổ biến';

  final List<Map<String, dynamic>> products = const [
    {
      'name': 'LEGO Classic Creative Bricks',
      'category': 'LEGO',
      'price': '549.000đ',
      'oldPrice': '699.000đ',
      'rating': '4.9',
      'image':
      'https://www.lego.com/cdn/cs/set/assets/blt9b6ed2e5657c45a1/11033.png',
    },
    {
      'name': 'LEGO Technic Siêu Xe',
      'category': 'LEGO',
      'price': '1.450.000đ',
      'oldPrice': '1.700.000đ',
      'rating': '4.8',
      'image':
      'https://www.lego.com/cdn/cs/set/assets/blt45f8e777457f6869/10337_boxprod_v39_sha.jpg',
    },
    {
      'name': 'Teddy Bear Brown',
      'category': 'Teddy Bears',
      'price': '249.000đ',
      'oldPrice': '320.000đ',
      'rating': '4.7',
      'image':
      'https://images.unsplash.com/photo-1559454403-b8fb88521f11?q=80&w=800',
    },
    {
      'name': 'Educational Blocks',
      'category': 'Educational Toys',
      'price': '399.000đ',
      'oldPrice': '450.000đ',
      'rating': '4.6',
      'image':
      'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?q=80&w=800',
    },
    {
      'name': 'Remote Control Car',
      'category': 'Remote Control Toys',
      'price': '590.000đ',
      'oldPrice': '720.000đ',
      'rating': '4.8',
      'image':
      'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?q=80&w=800',
    },
    {
      'name': 'Outdoor Toy Set',
      'category': 'Outdoor Toys',
      'price': '199.000đ',
      'oldPrice': '260.000đ',
      'rating': '4.5',
      'image':
      'https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?q=80&w=800',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = widget.categoryName == 'Tất cả'
        ? products
        : products
        .where((item) => item['category'] == widget.categoryName)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
          ),
        ],
      ),
      body: Column(
        children: [
          _filterBar(filteredProducts.length),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: .62,
              ),
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return _productCard(product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBar(int total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            '$total sản phẩm',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const Spacer(),
          _filterChip(Icons.tune, 'Lọc'),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                selectedSort = value;
              });
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'Phổ biến', child: Text('Phổ biến')),
              PopupMenuItem(value: 'Giá thấp', child: Text('Giá thấp')),
              PopupMenuItem(value: 'Giá cao', child: Text('Giá cao')),
            ],
            child: _filterChip(Icons.sort, selectedSort),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF4F46E5)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(Map<String, dynamic> product) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
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
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Image.network(
                    product['image'],
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        height: 130,
                        color: const Color(0xFFEDE9FE),
                        child: const Icon(Icons.image_not_supported_outlined),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: Colors.red.shade400,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                product['category'],
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                product['name'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFFFB800), size: 14),
                  Text(
                    ' ${product['rating']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      product['price'],
                      style: const TextStyle(
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4F46E5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}