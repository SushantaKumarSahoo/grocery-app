class Product {
  final String id;
  final String shopId;
  final String? categoryId;
  final String categoryName;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String unit;
  final double minOrderQty;
  final double stock;
  final String packaging;
  final String status;

  const Product({
    required this.id,
    required this.shopId,
    this.categoryId,
    required this.categoryName,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.unit,
    required this.minOrderQty,
    required this.stock,
    required this.packaging,
    required this.status,
  });

  List<String> get packagingOptions => packaging
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  bool get inStock => stock > 0 && status == 'active';

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      shopId: map['shop_id'] as String? ?? '',
      categoryId: map['category_id'] as String?,
      categoryName: (map['category_name'] as String?)?.trim() ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'KG',
      minOrderQty: (map['min_order_qty'] as num?)?.toDouble() ?? 1,
      stock: (map['stock'] as num?)?.toDouble() ?? 0,
      packaging: map['packaging'] as String? ?? '',
      status: map['status'] as String? ?? 'active',
    );
  }
}
