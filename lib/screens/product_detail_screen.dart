import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color darkBlue = Color(0xFF0B4DBA);
  static const Color primaryYellow = Color(0xFFFFD93D);
  static const Color bgColor = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF64748B);

  int quantity = 1;

  String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    )}đ';
  }

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

  void increaseQuantity() {
    if (widget.product.stock <= 0) return;

    setState(() {
      if (quantity < widget.product.stock) {
        quantity++;
      }
    });
  }

  void decreaseQuantity() {
    setState(() {
      if (quantity > 1) {
        quantity--;
      }
    });
  }

  Future<void> addToCart(ProductModel product) async {
    if (product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sản phẩm đã hết hàng")),
      );
      return;
    }

    final error = await CartService().addToCart(
      product: product,
      quantity: quantity,
    );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã thêm vào giỏ hàng")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Widget buildChip({
    required Widget child,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget buildQuantitySelector(ProductModel product) {
    return Row(
      children: [
        const Text(
          "Số lượng",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: quantity > 1 ? decreaseQuantity : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              Text(
                quantity.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
              IconButton(
                onPressed: quantity < product.stock ? increaseQuantity : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildRelatedProducts(ProductModel product) {
    return StreamBuilder<List<ProductModel>>(
      stream: ProductService().getRelatedProducts(
        category: product.category,
        currentProductId: product.id,
      ),
      builder: (context, snapshot) {
        final relatedProducts = snapshot.data ?? [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(
              child: CircularProgressIndicator(color: darkBlue),
            ),
          );
        }

        if (relatedProducts.isEmpty) {
          return const SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            const Text(
              "Gợi ý cùng loại",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: textDark,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 250,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: relatedProducts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final item = relatedProducts[index];
                  final bool hasDiscount =
                      item.oldPrice > 0 && item.oldPrice > item.price;

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: item),
                        ),
                      );
                    },
                    child: Container(
                      width: 158,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
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
                                    item.image,
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
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryYellow,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: const Text(
                                        'SALE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(11),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: textDark,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  formatPrice(item.price),
                                  style: const TextStyle(
                                    color: darkBlue,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 15,
                                      color: primaryYellow,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      item.rating.toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: textGrey,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      item.stock > 0
                                          ? 'Còn ${item.stock}'
                                          : 'Hết',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: item.stock > 0
                                            ? darkBlue
                                            : Colors.red,
                                        fontWeight: FontWeight.w700,
                                      ),
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
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final bool hasDiscount =
        product.oldPrice > 0 && product.oldPrice > product.price;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Chi tiết sản phẩm",
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: bgColor,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 24,
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: product.stock > 0 ? () => addToCart(product) : null,
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text("Thêm giỏ"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: darkBlue,
                    side: const BorderSide(color: darkBlue),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: product.stock > 0
                      ? () async {
                    final error = await CartService().addToCart(
                      product: product,
                      quantity: quantity,
                    );

                    if (!context.mounted) return;

                    if (error == null) {
                      Navigator.pushNamed(context, '/cart');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    }
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    product.stock > 0 ? "Mua ngay" : "Hết hàng",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        children: [
          Container(
            height: 340,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    product.image,
                    height: 340,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        height: 340,
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: textGrey,
                          size: 60,
                        ),
                      );
                    },
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: primaryYellow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'SALE',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viName(product.category),
                  style: const TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    buildChip(
                      backgroundColor: primaryYellow.withOpacity(0.18),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: primaryYellow,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    buildChip(
                      backgroundColor: product.stock > 0
                          ? primaryBlue.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      child: Text(
                        product.stock > 0
                            ? "Còn ${product.stock} sản phẩm"
                            : "Hết hàng",
                        style: TextStyle(
                          color: product.stock > 0 ? darkBlue : Colors.red,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatPrice(product.price),
                      style: const TextStyle(
                        fontSize: 28,
                        color: darkBlue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (hasDiscount)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          formatPrice(product.oldPrice),
                          style: const TextStyle(
                            color: textGrey,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 15,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 22),
                buildQuantitySelector(product),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Mô tả sản phẩm",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.65,
                    color: textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          buildRelatedProducts(product),
        ],
      ),
    );
  }
}