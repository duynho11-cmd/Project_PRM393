import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class SellerAddProductScreen extends StatefulWidget {
  const SellerAddProductScreen({super.key});

  @override
  State<SellerAddProductScreen> createState() =>
      _SellerAddProductScreenState();
}

class _SellerAddProductScreenState extends State<SellerAddProductScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final oldPriceController = TextEditingController();
  final stockController = TextEditingController();
  final imageController = TextEditingController();
  final descriptionController = TextEditingController();

  String selectedCategory = 'LEGO';

  final List<String> categories = [
    'LEGO',
    'Teddy Bears',
    'Educational',
    'RC Toys',
    'Outdoor',
  ];

  bool isFeatured = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    imageController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  String viCategory(String category) {
    switch (category) {
      case 'Teddy Bears':
        return 'Gấu bông';
      case 'Educational':
        return 'Giáo dục';
      case 'RC Toys':
        return 'Xe điều khiển';
      case 'Outdoor':
        return 'Ngoài trời';
      case 'LEGO':
        return 'LEGO';
      default:
        return category;
    }
  }

  Future<void> addProduct() async {
    final name = nameController.text.trim();
    final image = imageController.text.trim();
    final description = descriptionController.text.trim();
    final priceText = priceController.text.trim();
    final oldPriceText = oldPriceController.text.trim();
    final stockText = stockController.text.trim();

    if (name.isEmpty || priceText.isEmpty || stockText.isEmpty || image.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ thông tin"),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    if (!image.startsWith('http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Link hình ảnh phải bắt đầu bằng http hoặc https"),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    final price = int.tryParse(priceText) ?? 0;
    final oldPrice = int.tryParse(oldPriceText) ?? 0;
    final stock = int.tryParse(stockText) ?? 0;

    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Giá bán phải lớn hơn 0"),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    if (oldPrice > 0 && oldPrice < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Giá cũ phải lớn hơn hoặc bằng giá bán"),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    if (stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Số lượng tồn kho không hợp lệ"),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': name,
        'category': selectedCategory,
        'price': price,
        'oldPrice': oldPrice,
        'stock': stock,
        'image': image,
        'description': description,
        'rating': 5.0,
        'isFeatured': isFeatured,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thêm sản phẩm thành công"),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: $e"),
          backgroundColor: AppColors.accentRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textInputAction:
      maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 15),
        prefixIcon: Icon(
          icon,
          color: AppColors.textGrey,
          size: 22,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      decoration: InputDecoration(
        labelText: "Danh mục",
        labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 15),
        prefixIcon: const Icon(
          Icons.category_outlined,
          color: AppColors.textGrey,
          size: 22,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(viCategory(category)),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() => selectedCategory = value);
      },
    );
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: AppColors.primaryGradient,
        boxShadow: AppColors.premiumShadow(
          color: AppColors.primary.withOpacity(0.2),
          blur: 24,
          offset: const Offset(0, 10),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Thêm sản phẩm\nvào cửa hàng",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                height: 1.3,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.add_business_rounded,
              color: AppColors.secondary,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle({
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget buildFormCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.premiumShadow(),
      ),
      child: Column(children: children),
    );
  }

  Widget buildFeaturedSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isFeatured
            ? AppColors.primary.withOpacity(0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFeatured
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.border,
        ),
        boxShadow: AppColors.premiumShadow(),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: isFeatured,
        activeColor: AppColors.primary,
        title: const Text(
          "Sản phẩm nổi bật",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 15.5,
          ),
        ),
        subtitle: const Text(
          "Hiển thị sản phẩm ở trang chủ",
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: 12.5,
          ),
        ),
        secondary: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.star_rounded,
            color: AppColors.secondary,
          ),
        ),
        onChanged: (value) {
          setState(() => isFeatured = value);
        },
      ),
    );
  }

  Widget buildImagePreview() {
    final url = imageController.text.trim();

    if (url.isEmpty) {
      return Container(
        height: 170,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                color: AppColors.textLight,
                size: 38,
              ),
              SizedBox(height: 8),
              Text(
                "Xem trước ảnh sản phẩm",
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        url,
        height: 190,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Container(
            height: 190,
            color: const Color(0xFFF1F5F9),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        },
        errorBuilder: (_, __, ___) {
          return Container(
            height: 170,
            color: const Color(0xFFF8FAFC),
            child: const Center(
              child: Text(
                "Không tải được ảnh",
                style: TextStyle(
                  color: AppColors.accentRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.primaryGradient,
        boxShadow: AppColors.premiumShadow(
          color: AppColors.primary.withOpacity(0.25),
          blur: 16,
          offset: const Offset(0, 6),
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : addProduct,
        icon: isLoading ? const SizedBox() : const Icon(Icons.add_rounded, color: Colors.white),
        label: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : const Text(
          "Thêm sản phẩm",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    oldPriceController.dispose();
    stockController.dispose();
    imageController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Thêm sản phẩm",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          buildHeader(),
          const SizedBox(height: 24),

          buildSectionTitle(
            title: "Thông tin cơ bản",
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: 14),

          buildFormCard(
            children: [
              buildInput(
                controller: nameController,
                label: "Tên sản phẩm",
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 16),
              buildCategoryDropdown(),
              const SizedBox(height: 16),
              buildInput(
                controller: descriptionController,
                label: "Mô tả sản phẩm",
                icon: Icons.description_outlined,
                maxLines: 4,
              ),
            ],
          ),

          const SizedBox(height: 24),

          buildSectionTitle(
            title: "Giá và kho hàng",
            icon: Icons.sell_outlined,
          ),
          const SizedBox(height: 14),

          buildFormCard(
            children: [
              buildInput(
                controller: priceController,
                label: "Giá bán (VNĐ)",
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              buildInput(
                controller: oldPriceController,
                label: "Giá cũ (VNĐ) - có thể để trống",
                icon: Icons.local_offer_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              buildInput(
                controller: stockController,
                label: "Số lượng tồn kho",
                icon: Icons.warehouse_outlined,
                keyboardType: TextInputType.number,
              ),
            ],
          ),

          const SizedBox(height: 24),

          buildSectionTitle(
            title: "Hình ảnh",
            icon: Icons.image_outlined,
          ),
          const SizedBox(height: 14),

          buildFormCard(
            children: [
              buildInput(
                controller: imageController,
                label: "Link hình ảnh",
                icon: Icons.link_rounded,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              buildImagePreview(),
            ],
          ),

          const SizedBox(height: 24),
          buildFeaturedSwitch(),

          const SizedBox(height: 24),
          buildSubmitButton(),
        ],
      ),
    );
  }
}