import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';
import '../models/artisan.dart';
import '../../../core/network/odoo_providers.dart';

import 'package:flutter_svg/flutter_svg.dart';

class ProductDetailScreen extends ConsumerWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  Widget _buildOdooImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return Container(
        width: double.infinity,
        height: 300,
        color: Colors.grey[200],
        child: const Icon(Icons.image, size: 100, color: Colors.grey),
      );
    }

    try {
      final bytes = base64Decode(base64String);
      final header = String.fromCharCodes(bytes.take(10));
      if (header.contains('<?xml') || header.contains('<svg')) {
        return SvgPicture.memory(bytes, width: double.infinity, height: 350, fit: BoxFit.contain);
      }
      return Image.memory(bytes, width: double.infinity, height: 350, fit: BoxFit.cover);
    } catch (e) {
      return const SizedBox(height: 300, child: Center(child: Icon(Icons.broken_image)));
    }
  }

  Future<void> _launchWhatsApp(String phone, String productName) async {
    final message = "Olá! Tenho interesse no artigo: $productName. Ainda está disponível?";
    final url = "https://wa.me/${phone.replaceAll(RegExp(r'[^0-9]'), '')}?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artisansAsync = ref.watch(artisansProvider);
    final artisan = artisansAsync.value?.firstWhere((a) => a.id == product.artisanId, 
      orElse: () => Artisan(id: 0, name: "Artesão Local", island: "Açores", geoGroup: "", category: ""));

    final displayPrice = product.price > 0 
        ? '${product.price.toStringAsFixed(2)} €' 
        : "Preço sob consulta";

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do Produto (Base64 do Odoo)
            _buildOdooImage(product.imageUrl),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category,
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayPrice,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF003F87)),
                  ),
                  const Divider(height: 40),
                  const Text(
                    "Descrição",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.description?.isNotEmpty == true 
                        ? product.description! 
                        : "Este artigo é uma peça artesanal única, produzida seguindo as tradições seculares dos Açores.",
                    style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildPurchaseBar(context, artisan),
    );
  }

  Widget _buildPurchaseBar(BuildContext context, Artisan? artisan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            if (artisan != null && artisan.phone != null && artisan.phone!.isNotEmpty) {
              _launchWhatsApp(artisan.phone!, product.name);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Contacto do artesão não disponível.")),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF003F87),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Interesse no Artigo (WhatsApp)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
