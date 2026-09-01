class Artisan {
  final int id;
  final String name;
  final String island;
  final String geoGroup;
  final String category;
  final String? bio;
  final String? imageUrl;
  final String? phone;
  final List<String> subCategories;

  Artisan({
    required this.id,
    required this.name,
    required this.island,
    required this.geoGroup,
    required this.category,
    this.bio,
    this.imageUrl,
    this.phone,
    this.subCategories = const [],
  });

  factory Artisan.fromJson(Map<String, dynamic> json) {
    // Função auxiliar para lidar com o 'false' do Odoo em campos de texto
    String _parseString(dynamic value) {
      if (value == null || value is bool) return "";
      return value.toString();
    }

    return Artisan(
      id: json['id'],
      name: _parseString(json['name']),
      island: _parseString(json['x_island'] ?? 'Desconhecida'),
      geoGroup: _parseString(json['x_geo_group']),
      category: _parseString(json['x_main_category']),
      bio: json['comment'] is String ? json['comment'] : null,
      imageUrl: json['image_1920'] is String ? json['image_1920'] : null,
      phone: _parseString(json['phone'] ?? json['mobile']),
    );
  }
}
