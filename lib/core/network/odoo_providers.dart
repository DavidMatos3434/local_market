import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/catalog/models/artisan.dart';
import '../../features/catalog/models/product.dart';
import '../offline/catalog_cache.dart';
import 'odoo_client.dart';

final odooClientProvider = Provider((ref) => OdooClient());
final offlineCatalogCacheProvider = Provider<OfflineCatalogCache>(
  (ref) => OfflineCatalogCache.disabled(),
);

final odooLocaleProvider = Provider<String>((ref) {
  final locale = PlatformDispatcher.instance.locale;
  return "${locale.languageCode}_${locale.countryCode ?? 'PT'}";
});

final artisansProvider = FutureProvider<List<Artisan>>((ref) async {
  final client = ref.watch(odooClientProvider);
  final cache = ref.watch(offlineCatalogCacheProvider);
  final lang = ref.watch(odooLocaleProvider);
  final rawArtisans = await client.fetchArtisans(langCode: lang);
  final artisans = rawArtisans.map((json) => Artisan.fromJson(json)).toList();
  if (artisans.isNotEmpty) {
    await cache.saveArtisans(artisans);
    return artisans;
  }
  return cache.readArtisans();
});

final categoriesProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.watch(odooClientProvider);
  final lang = ref.watch(odooLocaleProvider);
  return client.fetchCategories(langCode: lang);
});

final productsByArtisanProvider = FutureProvider.family<List<Product>, int>((ref, artisanId) async {
  final client = ref.watch(odooClientProvider);
  final lang = ref.watch(odooLocaleProvider);
  final rawProducts = await client.fetchProductsByArtisan(artisanId, langCode: lang);
  return rawProducts.map((json) => Product.fromJson(json, artisanId)).toList();
});

final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  final client = ref.watch(odooClientProvider);
  final cache = ref.watch(offlineCatalogCacheProvider);
  final lang = ref.watch(odooLocaleProvider);
  final rawProducts = await client.fetchAllProducts(langCode: lang);
  final products = rawProducts.map((json) {
    final compId = (json['company_id'] is List) ? json['company_id'][0] : 0;
    return Product.fromJson(json, compId);
  }).toList();
  if (products.isNotEmpty) {
    await cache.saveProducts(products);
    return products;
  }
  return cache.readProducts();
});
