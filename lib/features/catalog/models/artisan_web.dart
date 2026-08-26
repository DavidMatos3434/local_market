// Versão simplificada para Web (sem Isar)
class Artisan {
  final int id;
  final String name;
  final String island;
  final String geoGroup;
  final String category;
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

  factory Artisan.fromJson(Map<String, dynamic> json) {
    return Artisan(
      id: json['id'],
      name: json['name'],
      island: json['x_island'] ?? 'Desconhecida',
      geoGroup: json['x_geo_group'] ?? '',
      category: json['x_main_category'] ?? '',
      bio: (json['comment'] is String) ? json['comment'] : null,
      imageUrl: (json['image_1920'] is String) ? json['image_1920'] : null,
    );
  }
}
