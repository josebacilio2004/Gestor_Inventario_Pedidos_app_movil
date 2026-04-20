import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://gestor-inventario-pedidos.onrender.com/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        debugPrint('🌐 API Request: [${options.method}] ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('✅ API Response: [${response.statusCode}] ${response.statusMessage}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint('❌ API Error: [${e.response?.statusCode}] ${e.message}');
        return handler.next(e);
      },
    ));
  }

  // --- GENERIC METHODS ---
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }

  // --- AUTH METHODS ---
  Future<Map<String, dynamic>> login(String role, String usuario, String password) async {
    // El backend tiene rutas separadas por rol para login
    final String path = '/$role/login';
    final response = await post(path, data: {
      'usuario': usuario,
      'password': password,
    });
    return response.data;
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

  // --- DISTRIBUIDORES ---
  Future<List<Map<String, dynamic>>> getDistribuidores() async {
    final response = await get('/distribuidores');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> createDistribuidor(Map<String, dynamic> data) async {
    final response = await post('/distribuidores', data: data);
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
}
