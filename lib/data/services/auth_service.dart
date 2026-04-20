import 'package:flutter/foundation.dart';
import 'package:gestor_invetarios_pedidos_app/data/services/api_service.dart';
import 'package:gestor_invetarios_pedidos_app/data/models/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  Usuario? _currentUser;

  Usuario? get currentUser => _currentUser;

  // Stream simplificado para mantener compatibilidad con Riverpod si es necesario
  // En un sistema REST, el estado se maneja via Notifier usualmente
  
  Future<Usuario?> signIn(String identifier, String password, String apiRole, {String? originalRole}) async {
    try {
      final userData = await _apiService.login(apiRole, identifier, password);
      
      final String userRole = originalRole ?? (userData['rol'] ?? apiRole);

      _currentUser = Usuario.fromJson({
        ...userData,
        'rol': userRole,
      });

      // Guardar sesión básica (en producción se guardaría un JWT)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _currentUser!.id.toString());
      await prefs.setString('user_name', _currentUser!.nombre);
      await prefs.setString('user_role', userRole);

      return _currentUser;
    } catch (e) {
      debugPrint('❌ Auth Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
  }

  Future<Usuario?> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');
    if (id == null) return null;

    _currentUser = Usuario(
      id: int.parse(id),
      nombre: prefs.getString('user_name') ?? '',
      usuario: '', // No crítico para el cache
      rol: prefs.getString('user_role') ?? 'usuario',
    );
    return _currentUser;
  }
}
