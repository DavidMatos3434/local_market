class Product {
  final int id;
  final int artisanId;
  final String name;
  final String category;
  final double price;
  final String? imageUrl;
  final String? description;

  Product({
    required this.id,
    required this.artisanId,
    required this.name,
    required this.category,
    required this.price,
    this.imageUrl,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json, int artisanId) {
    String _parseString(dynamic value) {
      if (value == null || value is bool) return "";
      return value.toString();
    }

    return Product(
      id: json['id'],
      artisanId: artisanId,
      name: _parseString(json['name']),
      category: (json['categ_id'] is List) ? _parseString(json['categ_id'][1]) : '',
      price: (json['list_price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: (json['image_1920'] is String) ? json['image_1920'] : null,
      description: _parseString(json['description_sale']),
    );
  }
}
