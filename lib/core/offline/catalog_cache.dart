import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../features/catalog/models/artisan.dart';
import '../../features/catalog/models/product.dart';

/// Persists the last successful catalog response for offline use.
///
/// Separate files let artisans and products refresh in parallel without
/// overwriting one another.
class OfflineCatalogCache {
  const OfflineCatalogCache._(this._directory);

  final Directory? _directory;

  factory OfflineCatalogCache.disabled() => const OfflineCatalogCache._(null);

  factory OfflineCatalogCache.forDirectory(Directory directory) =>
      OfflineCatalogCache._(directory);

  static Future<OfflineCatalogCache> open() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDirectory = Directory(
        '${directory.path}${Platform.pathSeparator}catalog_cache',
      );
      await cacheDirectory.create(recursive: true);
      return OfflineCatalogCache._(cacheDirectory);
    } catch (_) {
      // The catalogue remains usable online if local storage is unavailable.
      return OfflineCatalogCache.disabled();
    }
  }

  Future<void> saveArtisans(List<Artisan> artisans) => _write(
        'artisans.json',
        artisans
            .map(
              (artisan) => {
                'id': artisan.id,
                'name': artisan.name,
                'x_island': artisan.island,
                'x_geo_group': artisan.geoGroup,
                'x_main_category': artisan.category,
                'comment': artisan.bio,
                'image_1920': artisan.imageUrl,
              },
            )
            .toList(),
      );

  Future<List<Artisan>> readArtisans() async {
    final records = await _read('artisans.json');
    return records.map(Artisan.fromJson).toList();
  }

  Future<void> saveProducts(List<Product> products) => _write(
        'products.json',
        products
            .map(
              (product) => {
                'id': product.id,
                'artisan_id': product.artisanId,
                'name': product.name,
                'categ_id': [0, product.category],
                'list_price': product.price,
                'image_1920': product.imageUrl,
                'description_sale': product.description,
              },
            )
            .toList(),
      );

  Future<List<Product>> readProducts() async {
    final records = await _read('products.json');
    return records
        .map(
          (record) => Product.fromJson(
            record,
            (record['artisan_id'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList();
  }

  Future<void> _write(String filename, List<Map<String, dynamic>> records) async {
    final directory = _directory;
    if (directory == null || records.isEmpty) return;
    await File('${directory.path}${Platform.pathSeparator}$filename')
        .writeAsString(jsonEncode(records), flush: true);
  }

  Future<List<Map<String, dynamic>>> _read(String filename) async {
    final directory = _directory;
    if (directory == null) return const [];

    try {
      final file = File('${directory.path}${Platform.pathSeparator}$filename');
      if (!await file.exists()) return const [];
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } on FileSystemException catch (_) {
      return const [];
    } on FormatException catch (_) {
      return const [];
    }
  }
}
