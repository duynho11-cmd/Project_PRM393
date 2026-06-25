import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SellerAddProductScreen extends StatefulWidget {
  const SellerAddProductScreen({super.key});

  @override
  State<SellerAddProductScreen> createState() =>
      _SellerAddProductScreenState();
}

class _SellerAddProductScreenState extends State<SellerAddProductScreen> {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color darkBlue = Color(0xFF0B4DBA);
  static const Color primaryYellow = Color(0xFFFFD93D);
  static const Color bgColor = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF64748B);

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
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    if (!image.startsWith('http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Link hình ảnh phải bắt đầu bằng http hoặc https")),
      );
      return;
    }

    final price = int.tryParse(priceText) ?? 0;
    final oldPrice = int.tryParse(oldPriceText) ?? 0;
    final stock = int.tryParse(stockText) ?? 0;

    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Giá bán phải lớn hơn 0")),
      );
      return;
    }

    if (oldPrice > 0 && oldPrice < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Giá cũ phải lớn hơn hoặc bằng giá bán")),
      );
      return;
    }

    if (stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Số lượng tồn kho không hợp lệ")),
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
        const SnackBar(content: Text("Thêm sản phẩm thành công")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
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
        prefixIcon: Icon(
          icon,
          color: textGrey,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(
            color: primaryBlue,
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
        prefixIcon: const Icon(
          Icons.category_outlined,
          color: textGrey,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(
            color: primaryBlue,
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
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Thêm sản phẩm\nvào cửa hàng",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
          ),
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.add_business_rounded,
              color: primaryYellow,
              size: 40,
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
            color: primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: darkBlue,
            size: 21,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: textDark,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget buildFormCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget buildFeaturedSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isFeatured
            ? primaryBlue.withOpacity(0.08)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isFeatured
              ? primaryBlue.withOpacity(0.4)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: isFeatured,
        activeColor: darkBlue,
        title: const Text(
          "Sản phẩm nổi bật",
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: const Text(
          "Hiển thị sản phẩm ở trang chủ",
          style: TextStyle(
            color: textGrey,
            fontSize: 13,
          ),
        ),
        secondary: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: primaryYellow.withOpacity(0.25),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.star_rounded,
            color: primaryYellow,
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
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                color: textGrey,
                size: 40,
              ),
              SizedBox(height: 8),
              Text(
                "Xem trước ảnh sản phẩm",
                style: TextStyle(
                  color: textGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
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
              child: CircularProgressIndicator(color: darkBlue),
            ),
          );
        },
        errorBuilder: (_, __, ___) {
          return Container(
            height: 170,
            color: const Color(0xFFF1F5F9),
            child: const Center(
              child: Text(
                "Không tải được ảnh",
                style: TextStyle(
                  color: Colors.red,
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
    return SizedBox(
      height: 58,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : addProduct,
        icon: isLoading ? const SizedBox() : const Icon(Icons.add_rounded),
        label: isLoading
            ? const SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.6,
          ),
        )
            : const Text(
          "Thêm sản phẩm",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: darkBlue.withOpacity(0.65),
          elevation: 0,
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
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Thêm sản phẩm",
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
              const SizedBox(height: 14),
              buildCategoryDropdown(),
              const SizedBox(height: 14),
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
              const SizedBox(height: 14),
              buildInput(
                controller: oldPriceController,
                label: "Giá cũ (VNĐ) - có thể để trống",
                icon: Icons.local_offer_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
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
              const SizedBox(height: 14),
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