import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'odoo_client.dart';

// Provider do Cliente Odoo
final odooClientProvider = Provider((ref) => OdooClient());

// Provider que deteta o idioma do telemóvel e formata para o Odoo (ex: pt_PT)
final odooLocaleProvider = Provider<String>((ref) {
  final locale = PlatformDispatcher.instance.locale;
  final String languageCode = locale.languageCode; // ex: pt
  final String? countryCode = locale.countryCode; // ex: PT
  
  if (countryCode != null) {
    return "${languageCode}_$countryCode"; // Retorna pt_PT
  }
  return languageCode == 'en' ? 'en_US' : 'pt_PT';
});

// Provider que busca os artesãos enviando o idioma correto
final artisansProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.watch(odooClientProvider);
  final lang = ref.watch(odooLocaleProvider);
  
  print("LocalMarket: A solicitar dados no idioma $lang");
  return client.fetchArtisans(langCode: lang);
});
