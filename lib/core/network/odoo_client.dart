import 'package:dio/dio.dart';
import '../config/app_config.dart';

class OdooClient {
  static const String serverIp = AppConfig.odooIp; 
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://$serverIp:8069', 
    contentType: 'application/json',
    connectTimeout: const Duration(seconds: 15),
  ));

  int? _uid;
  final String _db = AppConfig.odooDb;
  final String _user = AppConfig.odooUser;
  final String _pass = AppConfig.odooPass;

  Future<bool> authenticate() async {
    try {
      print("🌐 Tentando autenticar em http://$serverIp:8069...");
      final response = await _dio.post('/jsonrpc', data: {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {"service": "common", "method": "login", "args": [_db, _user, _pass]},
        "id": 1
      });
      
      if (response.data['error'] != null) {
        print("❌ Erro Odoo: ${response.data['error']}");
        return false;
      }
      
      _uid = response.data['result'];
      print("✅ Autenticado com UID: $_uid");
      return _uid != null;
    } catch (e) {
      print("⚠️ Falha na autenticação: $e");
      return false;
    }
  }

  Future<List<dynamic>> fetchArtisans({String langCode = 'pt_PT'}) async {
    try {
      if (_uid == null) {
        final authOk = await authenticate();
        if (!authOk) return [];
      }
      
      print("📦 Procurando artesãos...");
      final response = await _dio.post('/jsonrpc', data: {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "service": "object",
          "method": "execute_kw",
          "args": [
            _db, _uid, _pass,
            'res.partner', 'search_read',
            [[['x_is_artisan', '=', true]]],
            {
              'fields': ['id', 'name', 'x_island', 'x_geo_group', 'x_main_category', 'comment', 'image_1920'],
              'context': {'lang': langCode},
              'limit': 100
            }
          ]
        },
        "id": 2
      });
      return response.data['result'] ?? [];
    } catch (e) {
      print("⚠️ Erro ao procurar artesãos: $e");
      return [];
    }
  }

  Future<List<dynamic>> fetchCategories({String langCode = 'pt_PT'}) async {
    try {
      if (_uid == null) {
        final authOk = await authenticate();
        if (!authOk) return [];
      }
      
      print("📂 Procurando categorias...");
      final response = await _dio.post('/jsonrpc', data: {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "service": "object",
          "method": "execute_kw",
          "args": [
            _db, _uid, _pass,
            'product.category', 'search_read',
            [[['parent_id', '=', false]]], 
            {'fields': ['name'], 'context': {'lang': langCode}}
          ]
        },
        "id": 4
      });
      return response.data['result'] ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> fetchProductsByArtisan(int artisanId, {String langCode = 'pt_PT'}) async {
    try {
      if (_uid == null) await authenticate();
      final response = await _dio.post('/jsonrpc', data: {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "service": "object",
          "method": "execute_kw",
          "args": [
            _db, _uid, _pass,
            'product.template', 'search_read',
            [[['company_id.partner_id', '=', artisanId]]], 
            {
              'fields': ['id', 'name', 'list_price', 'categ_id', 'image_1920', 'description_sale', 'company_id'],
              'context': {'lang': langCode}
            }
          ]
        },
        "id": 3
      });
      return response.data['result'] ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> fetchAllProducts({String langCode = 'pt_PT'}) async {
    try {
      if (_uid == null) await authenticate();
      final response = await _dio.post('/jsonrpc', data: {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "service": "object",
          "method": "execute_kw",
          "args": [
            _db, _uid, _pass,
            'product.template', 'search_read',
            [[['sale_ok', '=', true]]], 
            {
              'fields': ['id', 'name', 'list_price', 'categ_id', 'image_1920', 'description_sale', 'company_id'],
              'context': {'lang': langCode},
              'limit': 80
            }
          ]
        },
        "id": 5
      });
      return response.data['result'] ?? [];
    } catch (e) {
      return [];
    }
  }
}
