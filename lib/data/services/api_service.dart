import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://gestor-inventario-pedidos.onrender.com/api',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    validateStatus: (status) => status! < 500,
  ));

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          debugPrint('⚠️ Error retrieving auth token: $e');
        }
        debugPrint('🌐 API Request: [${options.method}] ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('✅ API Response: [${response.statusCode}] ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint('❌ API Error: [${e.response?.statusCode}] ${e.message}');
        return handler.next(e);
      },
    ));
  }

  // Métodos Base
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) => 
    _dio.get(path, queryParameters: queryParameters);
    
  Future<Response> post(String path, {dynamic data}) => _dio.post(path, data: data);
  Future<Response> put(String path, {dynamic data}) => _dio.put(path, data: data);
  Future<Response> delete(String path) => _dio.delete(path);

  // --- AUTH ---
  Future<Map<String, dynamic>> login(String role, String identifier, String password) async {
    String endpoint;
    final r = role.toLowerCase();
    
    // El backend tiene rutas separadas por rol para login
    if (r == 'admin') {
      endpoint = '/admin/login';
    } else if (r == 'inversionista' || r == 'inversionistas') {
      endpoint = '/inversionistas/login';
    } else if (r == 'comprador' || r == 'compradores') {
      endpoint = '/compradores/login';
    } else if (r == 'operador' || r == 'operadores') {
      endpoint = '/operadores/login';
    } else {
      endpoint = '/$role/login'; 
    }

    final response = await post(endpoint, data: {
      'usuario': identifier,
      'password': password,
    });
    
    if (response.statusCode == 200) {
      final data = response.data;
      
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      } else if (data is String) {
        debugPrint('⚠️ Server returned String instead of Map. Attempting jsonDecode...');
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map) {
            return Map<String, dynamic>.from(decoded);
          }
        } catch (e) {
          debugPrint('❌ Failed to decode response string: $e');
        }
      }
      
      // Fallback: Si el servidor solo devuelve el nombre de usuario como String
      // Construimos un objeto mínimo para evitar el TypeError
      if (data is String && data.isNotEmpty) {
        return {
          'id': 0,
          'usuario': data,
          'nombre': data,
          'rol': r,
        };
      }
      
      throw Exception('Formato de respuesta inválido: ${data.runtimeType}');
    } else {
      final errorData = response.data;
      String message = 'Error de autenticación';
      if (errorData is Map) {
        message = errorData['message'] ?? errorData['error'] ?? message;
      }
      throw Exception(message);
    }
  }





  // --- PRODUCTOS ---
  Future<List<Map<String, dynamic>>> getProductos() async {
    final response = await get('/productos');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> createProducto(Map<String, dynamic> data) async {
    final response = await post('/productos', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> updateProducto(int id, Map<String, dynamic> data) async {
    final response = await put('/productos/$id', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> deleteProducto(int id) async {
    final response = await delete('/productos/$id');
    return response.data;
  }

  // --- DISTRIBUIDORES ---
  Future<List<Map<String, dynamic>>> getDistribuidores() async {
    final response = await get('/distribuidores');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> createDistribuidor(Map<String, dynamic> data) async {
    final response = await post('/distribuidores', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> updateDistribuidor(int id, Map<String, dynamic> data) async {
    final response = await put('/distribuidores/$id', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> deleteDistribuidor(int id) async {
    final response = await delete('/distribuidores/$id');
    return response.data;
  }

  // --- PEDIDOS (COMPRAS / INVERSIONES) ---
  Future<List<Map<String, dynamic>>> getPedidos() async {
    final response = await get('/pedidos');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> createPedido(Map<String, dynamic> data) async {
    final response = await post('/pedidos', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> updatePedido(int id, Map<String, dynamic> data) async {
    final response = await put('/pedidos/$id', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> deletePedido(int id) async {
    final response = await delete('/pedidos/$id');
    return response.data;
  }

  // --- TANDAS ---
  Future<List<Map<String, dynamic>>> getTandas() async {
    final response = await get('/tandas');
    return List<Map<String, dynamic>>.from(response.data);
  }

  // --- COMPRADORES ---
  Future<List<Map<String, dynamic>>> getCompradores() async {
    final response = await get('/compradores');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> updateComprador(int id, Map<String, dynamic> data) async {
    final response = await put('/compradores/$id', data: data);
    return response.data;
  }

  // --- FACTURAS Y ABONOS (COMPRADORES) ---
  Future<List<Map<String, dynamic>>> getFacturasComprador(int compradorId, {int? distribuidorId}) async {
    final Map<String, dynamic> query = {'comprador_id': compradorId};
    if (distribuidorId != null) query['distribuidor_id'] = distribuidorId;
    
    final response = await get('/facturas-comprador', queryParameters: query);
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> createAbono(int facturaId, Map<String, dynamic> data) async {
    final response = await post('/facturas-comprador/$facturaId/abonos', data: data);
    return response.data;
  }

  Future<List<Map<String, dynamic>>> getAbonosFactura(int facturaId) async {
    final response = await get('/facturas-comprador/$facturaId/abonos');
    return List<Map<String, dynamic>>.from(response.data);
  }

  // --- MAYORISTAS ---
  Future<List<Map<String, dynamic>>> getMayoristasClientes() async {
    final response = await get('/mayoristas/clientes');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> createMayoristaCliente(Map<String, dynamic> data) async {
    final response = await post('/mayoristas/clientes', data: data);
    return response.data;
  }

  Future<List<Map<String, dynamic>>> getMayoristaStock() async {
    final response = await get('/mayoristas/stock');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getMayoristaVentas() async {
    final response = await get('/mayoristas/ventas');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> createMayoristaVenta(Map<String, dynamic> data) async {
    final response = await post('/mayoristas/ventas', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> createStockManual(Map<String, dynamic> data) async {
    final response = await post('/mayoristas/stock-manual', data: data);
    return response.data;
  }

  // --- INVERSIONISTAS ---
  Future<List<Map<String, dynamic>>> getInversionistas() async {
    final response = await get('/inversionistas');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> updateInversionista(int id, Map<String, dynamic> data) async {
    final response = await put('/inversionistas/$id', data: data);
    return response.data;
  }
}
