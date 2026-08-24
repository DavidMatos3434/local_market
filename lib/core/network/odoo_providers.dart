import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'odoo_client.dart';
import '../../features/catalog/models/product.dart';
import '../../features/catalog/models/artisan.dart';

final odooClientProvider = Provider((ref) => OdooClient());

final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [ArtisanSchema, ProductSchema],
    directory: dir.path,
  );
});

final odooLocaleProvider = Provider<String>((ref) {
  final locale = PlatformDispatcher.instance.locale;
  return "${locale.languageCode}_${locale.countryCode ?? 'PT'}";
});

final artisansProvider = FutureProvider<List<Artisan>>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  final client = ref.watch(odooClientProvider);
  final lang = ref.watch(odooLocaleProvider);

  // 1. Tentar ler do Isar primeiro (offline-first)
  final localArtisans = await isar.artisans.where().findAll();

  try {
    // 2. Tentar atualizar do Odoo em background
    final rawArtisans = await client.fetchArtisans(langCode: lang);
    final artisans = rawArtisans.map((json) => Artisan.fromJson(json)).toList();

    // 3. Persistir no Isar (o ID vindo do Odoo garante que não há duplicados)
    await isar.writeTxn(() async {
      await isar.artisans.putAll(artisans);
    });
    
    return artisans;
  } catch (e) {
    print("⚠️ Falha ao sincronizar artesãos: $e. Usando dados locais.");
    if (localArtisans.isNotEmpty) return localArtisans;
    rethrow; // Se não houver dados locais e falhar a rede, propaga o erro
  }
});

final categoriesProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.watch(odooClientProvider);
  final lang = ref.watch(odooLocaleProvider);
  return client.fetchCategories(langCode: lang);
});

// Provider que devolve uma lista de objetos 'Product' tipados com Cache
final productsByArtisanProvider = FutureProvider.family<List<Product>, int>((ref, artisanId) async {
  final isar = await ref.watch(isarProvider.future);
  final client = ref.watch(odooClientProvider);
  final lang = ref.watch(odooLocaleProvider);
  
  // 1. Verificar cache local
  final localProducts = await isar.products.filter().artisanIdEqualTo(artisanId).findAll();

  try {
    // 2. Fetch do Odoo
    final rawProducts = await client.fetchProductsByArtisan(artisanId, langCode: lang);
    final products = rawProducts.map((json) => Product.fromJson(json, artisanId)).toList();

    // 3. Update cache
    await isar.writeTxn(() async {
      await isar.products.putAll(products);
    });
    
    return products;
  } catch (e) {
    print("⚠️ Falha ao sincronizar produtos: $e.");
    if (localProducts.isNotEmpty) return localProducts;
    return [];
  }
});
