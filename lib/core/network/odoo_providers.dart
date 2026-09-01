import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'odoo_client.dart';
import '../../features/catalog/models/product.dart';
import '../../features/catalog/models/artisan.dart';

import '../services/tts_service.dart';

final odooClientProvider = Provider((ref) => OdooClient());

final ttsProvider = Provider((ref) => TtsService());

final odooLocaleProvider = Provider<String>((ref) {
  final locale = PlatformDispatcher.instance.locale;
  return "${locale.languageCode}_${locale.countryCode ?? 'PT'}";
});

final artisansProvider = FutureProvider<List<Artisan>>((ref) async {
  final client = ref.watch(odooClientProvider);
  final lang = ref.watch(odooLocaleProvider);
  final rawArtisans = await client.fetchArtisans(langCode: lang);
  return rawArtisans.map((json) => Artisan.fromJson(json)).toList();
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
  final lang = ref.watch(odooLocaleProvider);
  final rawProducts = await client.fetchAllProducts(langCode: lang);
  return rawProducts.map((json) {
    final compId = (json['company_id'] is List) ? json['company_id'][0] : 0;
    return Product.fromJson(json, compId);
  }).toList();
});
