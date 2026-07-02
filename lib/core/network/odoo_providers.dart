import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'odoo_client.dart';
import '../../features/catalog/models/product.dart';

final odooClientProvider = Provider((ref) => OdooClient());

final odooLocaleProvider = Provider<String>((ref) {
  final locale = PlatformDispatcher.instance.locale;
  return "${locale.languageCode}_${locale.countryCode ?? 'PT'}";
});

final artisansProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.watch(odooClientProvider);
  final lang = ref.watch(odooLocaleProvider);
  return client.fetchArtisans(langCode: lang);
});

final categoriesProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.watch(odooClientProvider);
  final lang = ref.watch(odooLocaleProvider);
  return client.fetchCategories(langCode: lang);
});

// Provider que devolve uma lista de objetos 'Product' tipados
final productsByArtisanProvider = FutureProvider.family<List<Product>, int>((ref, artisanId) async {
  final client = ref.watch(odooClientProvider);
  final lang = ref.watch(odooLocaleProvider);
  
  final rawProducts = await client.fetchProductsByArtisan(artisanId, langCode: lang);
  return rawProducts.map((json) => Product.fromJson(json)).toList();
});
