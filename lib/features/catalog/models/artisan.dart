class Artisan {
  final String id;
  final String name;
  final String island;
  final String geoGroup;
  final String category; // Categoria principal (ex: Têxteis)
  final String? bio;
  final String? imageUrl;
  final List<String> subCategories;

  Artisan({
    required this.id,
    required this.name,
    required this.island,
    required this.geoGroup,
    required this.category,
    this.bio,
    this.imageUrl,
    this.subCategories = const [],
  });

  // Para quando convertermos o que vem do Odoo (JSON) para o Flutter
  factory Artisan.fromJson(Map<String, dynamic> json) {
    return Artisan(
      id: json['id'].toString(),
      name: json['name'],
      island: json['x_island'] ?? 'Desconhecida', // 'x_' é o padrão do Odoo para campos custom
      geoGroup: json['x_geo_group'] ?? '',
      category: json['x_main_category'] ?? '',
      bio: json['comment'],
      imageUrl: json['image_1920'],
    );
  }
}
