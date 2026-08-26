import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:local_market/l10n/generated/app_localizations.dart';
import 'package:local_market/core/network/odoo_providers.dart';
import 'package:local_market/features/catalog/presentation/artisan_details_screen.dart';
import 'package:local_market/features/catalog/presentation/product_detail_screen.dart';
import 'package:local_market/features/catalog/models/artisan.dart';
import 'package:local_market/features/catalog/models/product.dart';

void main() {
  runApp(const ProviderScope(child: LocalMarketApp()));
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/artisan',
      builder: (context, state) {
        final artisan = state.extra as Artisan;
        return ArtisanDetailsScreen(artisan: artisan);
      },
    ),
    GoRoute(
      path: '/product',
      builder: (context, state) {
        final product = state.extra as Product;
        return ProductDetailScreen(product: product);
      },
    ),
  ],
);

class LocalMarketApp extends StatelessWidget {
  const LocalMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Local Market Açores',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003F87),
          primary: const Color(0xFF003F87),
          secondary: const Color(0xFFFFD700),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  String _toText(dynamic value, [String fallback = ""]) {
    if (value == null || value is bool) return fallback;
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<Widget> screens = [
      _buildHomeScreen(l10n),
      _buildCatalogScreen(l10n),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? l10n.appTitle : "Mercado Regional"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              ref.invalidate(artisansProvider);
              ref.invalidate(categoriesProvider);
              ref.invalidate(allProductsProvider);
            },
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF003F87),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Artesãos"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: "Produtos"),
        ],
      ),
    );
  }

  Widget _buildHomeScreen(AppLocalizations l10n) {
    final artisansAsync = ref.watch(artisansProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHero(l10n, artisansAsync.value?.length ?? 0),
          _buildSectionTitle(l10n.featuredArtisans),
          artisansAsync.when(
            data: (artisans) => _buildArtisansList(context, artisans),
            loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => Padding(padding: const EdgeInsets.all(16.0), child: Text(l10n.syncError)),
          ),
          _buildSectionTitle(l10n.categories),
          categoriesAsync.when(
            data: (cats) => _buildCategoriesGrid(cats),
            loading: () => const Padding(padding: EdgeInsets.all(20), child: LinearProgressIndicator()),
            error: (e, s) => const Padding(padding: EdgeInsets.all(16), child: Text("...")),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCatalogScreen(AppLocalizations l10n) {
    final productsAsync = ref.watch(allProductsProvider);

    return productsAsync.when(
      data: (products) => GridView.builder(
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
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                        ? Image.memory(base64Decode(p.imageUrl!), fit: BoxFit.cover, width: double.infinity)
                        : Container(color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('${p.price.toStringAsFixed(2)} €', style: const TextStyle(color: Color(0xFF003F87), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Erro ao carregar catálogo")),
    );
  }

  Widget _buildHero(AppLocalizations l10n, int artisanCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF003F87),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.welcomeMessage, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            artisanCount > 0 
                ? l10n.supportArtisans(artisanCount)
                : "A carregar artesãos...", 
            style: const TextStyle(color: Colors.white70, fontSize: 16)
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }

  Widget _buildArtisansList(BuildContext context, List<Artisan> artisans) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: artisans.length,
        itemBuilder: (context, index) {
          final a = artisans[index];
          final String? imageData = a.imageUrl;

          return GestureDetector(
            onTap: () => context.push('/artisan', extra: a), 
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 140,
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 70, height: 70,
                        child: (imageData != null && imageData.isNotEmpty)
                          ? Image.memory(base64Decode(imageData), fit: BoxFit.cover)
                          : Container(color: Colors.blueGrey[50], child: const Icon(Icons.person, color: Color(0xFF003F87))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(a.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    Text(a.island, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesGrid(List<dynamic> categories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 10, 
        mainAxisSpacing: 10, 
        childAspectRatio: 2.8
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF003F87).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          child: Text(_toText(cat['name']), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF003F87))),
        );
      },
    );
  }
}
