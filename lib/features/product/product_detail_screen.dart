import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _productImage(product),
                    const SizedBox(height: 18),
                    _category(product),
                    const SizedBox(height: 8),
                    _name(product),
                    const SizedBox(height: 10),
                    _rating(product),
                    const SizedBox(height: 14),
                    _price(product),
                    const SizedBox(height: 22),
                    _sectionTitle('Mô tả sản phẩm'),
                    const SizedBox(height: 8),
                    _description(),
                    const SizedBox(height: 22),
                    _sectionTitle('Số lượng'),
                    const SizedBox(height: 10),
                    _quantitySelector(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          const Spacer(),
          const Text(
            'Chi tiết sản phẩm',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
          ),
        ],
      ),
    );
  }

  Widget _productImage(Map<String, dynamic> product) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          product['image'],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 46,
                color: Color(0xFF5B35F5),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _category(Map<String, dynamic> product) {
    return Text(
      product['category'] ?? 'Sản phẩm',
      style: const TextStyle(
        color: Color(0xFF5B35F5),
        fontWeight: FontWeight.w800,
        fontSize: 13,
      ),
    );
  }

  Widget _name(Map<String, dynamic> product) {
    return Text(
      product['name'] ?? '',
      style: const TextStyle(
        color: Color(0xFF111827),
        fontWeight: FontWeight.w900,
        fontSize: 24,
        height: 1.15,
      ),
    );
  }

  Widget _rating(Map<String, dynamic> product) {
    return Row(
      children: [
        const Icon(Icons.star, color: Color(0xFFFFB800), size: 18),
        const SizedBox(width: 4),
        Text(
          product['rating'] ?? '4.8',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          '|',
          style: TextStyle(color: Color(0xFFD1D5DB)),
        ),
        const SizedBox(width: 8),
        Text(
          'Còn ${product['stock'] ?? '0'} sản phẩm',
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _price(Map<String, dynamic> product) {
    return Row(
      children: [
        Text(
          product['price'] ?? '',
          style: const TextStyle(
            color: Color(0xFF4F46E5),
            fontWeight: FontWeight.w900,
            fontSize: 26,
          ),
        ),
        const SizedBox(width: 10),
        if (product['oldPrice'] != null)
          Text(
            product['oldPrice'],
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 15,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF111827),
        fontWeight: FontWeight.w900,
        fontSize: 18,
      ),
    );
  }

  Widget _description() {
    return const Text(
      'Bộ đồ chơi chất lượng cao, giúp bé phát triển tư duy sáng tạo, khả năng lắp ráp và trí tưởng tượng. Sản phẩm phù hợp làm quà tặng cho trẻ em và người yêu thích mô hình.',
      style: TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 14,
        height: 1.5,
      ),
    );
  }

  Widget _quantitySelector() {
    return Row(
      children: [
        _qtyButton(Icons.remove, () {
          if (quantity > 1) {
            setState(() {
              quantity--;
            });
          }
        }),
        Container(
          width: 52,
          height: 38,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$quantity',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
        _qtyButton(Icons.add, () {
          setState(() {
            quantity++;
          });
        }),
      ],
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFEDE9FE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF4F46E5),
          size: 20,
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã thêm vào giỏ hàng')),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4F46E5),
                side: const BorderSide(color: Color(0xFF4F46E5)),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Thêm giỏ',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Mua ngay',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}