import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class SellerEditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> product;

  const SellerEditProductScreen({
    super.key,
    required this.productId,
    required this.product,
  });

  @override
  State<SellerEditProductScreen> createState() =>
      _SellerEditProductScreenState();
}

class _SellerEditProductScreenState extends State<SellerEditProductScreen> {
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

    final p = widget.product;

    nameController.text = p['name'] ?? '';
    selectedCategory = p['category'] ?? 'LEGO';
    priceController.text = ((p['price'] as num?)?.toInt() ?? 0).toString();
    oldPriceController.text =
        ((p['oldPrice'] as num?)?.toInt() ?? 0).toString();
    stockController.text = ((p['stock'] as num?)?.toInt() ?? 0).toString();
    imageController.text = p['image'] ?? '';
    descriptionController.text = p['description'] ?? '';
    isFeatured = p['isFeatured'] ?? false;

    imageController.addListener(() {
      if (mounted) setState(() {});
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

  Future<void> updateProduct() async {
    final name = nameController.text.trim();
    final image = imageController.text.trim();
    final description = descriptionController.text.trim();
    final price = int.tryParse(priceController.text.trim()) ?? 0;
    final oldPrice = int.tryParse(oldPriceController.text.trim()) ?? 0;
    final stock = int.tryParse(stockController.text.trim()) ?? 0;

    if (name.isEmpty || image.isEmpty || priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ thông tin"),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Giá bán phải lớn hơn 0"),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    if (stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tồn kho không hợp lệ"),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
        'name': name,
        'category': selectedCategory,
        'price': price,
        'oldPrice': oldPrice,
        'stock': stock,
        'image': image,
        'description': description,
        'isFeatured': isFeatured,
        'updatedAt': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cập nhật sản phẩm thành công"),
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

  Widget input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? type,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 15),
        prefixIcon: Icon(icon, color: AppColors.textGrey, size: 22),
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

        setState(() {
          selectedCategory = value;
        });
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
              "Cập nhật\nsản phẩm",
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
              Icons.edit_note_rounded,
              color: AppColors.secondary,
              size: 36,
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
          child: Icon(icon, color: AppColors.primary, size: 20),
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
          child: Text(
            "Chưa có ảnh xem trước",
            style: TextStyle(
              color: AppColors.textGrey,
              fontWeight: FontWeight.w600,
            ),
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
        onPressed: isLoading ? null : updateProduct,
        icon: isLoading ? const SizedBox() : const Icon(Icons.save_outlined, color: Colors.white),
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
          "Lưu thay đổi",
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
          "Sửa sản phẩm",
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
              input(
                controller: nameController,
                label: "Tên sản phẩm",
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 16),
              buildCategoryDropdown(),
              const SizedBox(height: 16),
              input(
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
              input(
                controller: priceController,
                label: "Giá bán",
                icon: Icons.payments_outlined,
                type: TextInputType.number,
              ),
              const SizedBox(height: 16),
              input(
                controller: oldPriceController,
                label: "Giá cũ",
                icon: Icons.local_offer_outlined,
                type: TextInputType.number,
              ),
              const SizedBox(height: 16),
              input(
                controller: stockController,
                label: "Tồn kho",
                icon: Icons.warehouse_outlined,
                type: TextInputType.number,
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
              input(
                controller: imageController,
                label: "Link ảnh",
                icon: Icons.link_rounded,
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