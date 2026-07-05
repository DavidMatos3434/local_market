// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Azores Local Market';

  @override
  String get welcomeMessage => 'Welcome to the Azores Market';

  @override
  String supportArtisans(int count) {
    return 'Support our $count local artisans';
  }

  @override
  String get exploreIslands => 'Explore by Island';

  @override
  String get categories => 'Categories';

  @override
  String get syncError => 'Error connecting to Odoo. Check adb tunnel.';

  @override
  String get noArtisans => 'No artisans found in Odoo.';
}
