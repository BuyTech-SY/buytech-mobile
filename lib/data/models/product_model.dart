class ProductModel {
  final int id;
  final String name;
  final String? sku;
  final String? customProductId;
  final double price;
  final String? category;
  final String? image;

  ProductModel({
    required this.id,
    required this.name,
    this.sku,
    this.customProductId,
    required this.price,
    this.category,
    this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String?,
      customProductId: json['custom_product_id'] as String?,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      category: json['category'] as String?,
      image: json['image'] as String?,
    );
  }
}
