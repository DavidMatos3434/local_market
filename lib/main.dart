import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Gerado automaticamente
import 'core/constants/market_data.dart';
import 'core/network/odoo_providers.dart';

void main() {
  runApp(
    const ProviderScope(
      child: LocalMarketApp(),
    ),
  );
}

class LocalMarketApp extends StatelessWidget {
  const LocalMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Market Açores',
      debugShowCheckedModeBanner: false,
      
      // CONFIGURAÇÃO MULTILINGUAL
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'PT'), // Português
        Locale('en', 'US'), // Inglês
      ],

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003F87),
          primary: const Color(0xFF003F87),
          secondary: const Color(0xFFFFD700),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _toText(dynamic value, [String fallback = ""]) {
    if (value == null || value is bool) return fallback;
    return value.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artisansAsync = ref.watch(artisansProvider);
    // Atalho para as traduções
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => ref.refresh(artisansProvider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(context, l10n),
            _buildSectionTitle(context, l10n.exploreIslands),
            
            artisansAsync.when(
              data: (artisans) => _buildArtisansList(artisans, l10n),
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(30.0),
                child: CircularProgressIndicator(),
              )),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(l10n.syncError),
              ),
            ),

            _buildSectionTitle(context, l10n.categories),
            _buildCategoriesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, AppLocalizations l10n) {
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
          Text(l10n.welcomeMessage, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.supportArtisans(78), style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }

  Widget _buildArtisansList(List<dynamic> artisans, AppLocalizations l10n) {
    if (artisans.isEmpty) return Padding(padding: const EdgeInsets.all(16.0), child: Text(l10n.noArtisans));
    
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: artisans.length,
        itemBuilder: (context, index) {
          final a = artisans[index];
          final name = _toText(a['name'], '...');
          final island = _toText(a['x_island'], 'Açores');

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 130,
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(backgroundColor: Color(0xFFFFD700), child: Icon(Icons.person, color: Color(0xFF003F87))),
                  const SizedBox(height: 10),
                  Text(name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text(island, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = MarketData.categories.keys.toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 10, 
        mainAxisSpacing: 10, 
        childAspectRatio: 2.5
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: Text(categories[index], style: const TextStyle(fontSize: 11)),
      ),
    );
  }
}
