class AppConfig {
  static const String odooIp = String.fromEnvironment('ODOO_IP', defaultValue: 'localhost');
  static const String odooUser = String.fromEnvironment('ODOO_USER', defaultValue: 'thermoenergetics@gmail.com');
  static const String odooPass = String.fromEnvironment('ODOO_PASS', defaultValue: 'admin');
  static const String odooDb = 'local_market_artisans';
}
