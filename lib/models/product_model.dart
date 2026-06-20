class ProductModel {
  final String id;
  final String name;
  final String category;
  final int price;
  final int oldPrice;
  final double rating;
  final String image;
  final String description;
  final int stock;
  final bool isFeatured;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.oldPrice,
    required this.rating,
    required this.image,
    required this.description,
    required this.stock,
    required this.isFeatured,
  });

  factory ProductModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toInt(),
      oldPrice: (data['oldPrice'] ?? 0).toInt(),
      rating: (data['rating'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      stock: (data['stock'] ?? 0).toInt(),
      isFeatured: data['isFeatured'] ?? false,
    );
  }
}