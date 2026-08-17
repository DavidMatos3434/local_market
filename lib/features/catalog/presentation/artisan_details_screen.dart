import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_market/core/network/odoo_providers.dart';
import 'package:local_market/l10n/generated/app_localizations.dart'; // Import Absolute
import 'package:local_market/features/catalog/models/product.dart';

class ArtisanDetailsScreen extends ConsumerWidget {
  final Map<String, dynamic> artisan;

  const ArtisanDetailsScreen({super.key, required this.artisan});

  String _safe(dynamic value, [String fallback = ""]) {
    if (value == null || value is bool) return fallback;
    return value.toString();
  }

  Widget _getOdooImage(String? imageData) {
    if (imageData != null && imageData.isNotEmpty) {
      try {
        return Image.memory(base64Decode(imageData), fit: BoxFit.cover);
      } catch (e) {
        return const Icon(Icons.broken_image);
      }
    }
    return Container(color: Colors.grey[100], child: const Icon(Icons.image, color: Colors.grey));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsByArtisanProvider(artisan['id']));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(_safe(artisan['name'], 'Perfil'))),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF003F87).withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: SizedBox(
                      width: 100, 
                      height: 100, 
                      child: _getOdooImage(_safe(artisan['image_1920']))
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_safe(artisan['name']), textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_safe(artisan['x_island'], 'Açores'), style: const TextStyle(color: Color(0xFF003F87), fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
            ),
            
            // BIOGRAFIA / DESCRIÇÃO DO ARTESÃO
            if (_safe(artisan['comment']).isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: Color(0xFF003F87)),
                          SizedBox(width: 8),
                          Text("Sobre o Artesão", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _safe(artisan['comment']),
                        style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(l10n.products, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            productsAsync.when(
              data: (products) => _buildProductsGrid(context, products),
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Erro ao carregar catálogo: $err'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid(BuildContext context, List<Product> products) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40.0), 
        child: Center(child: Text("Ainda sem artigos no catálogo.", textAlign: TextAlign.center))
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 12, 
        mainAxisSpacing: 12, 
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return GestureDetector(
          onTap: () => context.push('/product', extra: p),
          child: Card(
            elevation: 2,
            shadowColor: Colors.black26,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      SizedBox(width: double.infinity, child: _getOdooImage(p.imageUrl)),
                      Positioned(
                        top: 8, right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                          child: Text(p.category, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF003F87))),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.2)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${p.price.toStringAsFixed(2)} €', style: const TextStyle(color: Color(0xFF003F87), fontWeight: FontWeight.w900, fontSize: 15)),
                          const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF003F87)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
