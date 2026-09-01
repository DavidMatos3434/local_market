import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:local_market/core/offline/catalog_cache.dart';
import 'package:local_market/features/catalog/models/artisan.dart';
import 'package:local_market/features/catalog/models/product.dart';

void main() {
  late Directory temporaryDirectory;
  late OfflineCatalogCache cache;

  setUp(() async {
    temporaryDirectory =
        await Directory.systemTemp.createTemp('local_market_cache_test_');
    cache = OfflineCatalogCache.forDirectory(temporaryDirectory);
  });

  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
  });

  test('persists artisans for an offline fallback', () async {
    final artisan = Artisan(
      id: 42,
      name: 'Maria Silva',
      island: 'Terceira',
      geoGroup: 'Central',
      category: 'Cerâmica',
      bio: 'Peças feitas à mão',
    );

    await cache.saveArtisans([artisan]);

    expect(await cache.readArtisans(), [
      isA<Artisan>()
          .having((item) => item.id, 'id', 42)
          .having((item) => item.name, 'name', 'Maria Silva')
          .having((item) => item.island, 'island', 'Terceira'),
    ]);
  });

  test('persists products without losing the artisan relation', () async {
    final product = Product(
      id: 7,
      artisanId: 42,
      name: 'Taça azul',
      category: 'Cerâmica',
      price: 24.5,
      description: 'Pintada à mão',
    );

    await cache.saveProducts([product]);

    expect(await cache.readProducts(), [
      isA<Product>()
          .having((item) => item.id, 'id', 7)
          .having((item) => item.artisanId, 'artisanId', 42)
          .having((item) => item.price, 'price', 24.5),
    ]);
  });

  test('returns an empty collection when there is no local cache', () async {
    expect(await cache.readArtisans(), isEmpty);
    expect(await cache.readProducts(), isEmpty);
  });
}
