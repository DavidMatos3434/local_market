// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Mercado Local Açores';

  @override
  String get welcomeMessage => 'Bem-vindo ao Mercado dos Açores';

  @override
  String supportArtisans(int count) {
    return 'Apoie os nossos $count artesãos locais';
  }

  @override
  String get exploreIslands => 'Explorar por Ilha';

  @override
  String get categories => 'Categorias';

  @override
  String get syncError => 'Erro ao ligar ao Odoo. Verifique o túnel adb.';

  @override
  String get noArtisans => 'Nenhum artesão encontrado no Odoo.';
}
