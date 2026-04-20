import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestor_invetarios_pedidos_app/data/services/auth_service.dart';
import 'package:gestor_invetarios_pedidos_app/data/models/usuario.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Cambiamos de StreamProvider a StateProvider o NotifierProvider para el estado de la sesión
final authStateProvider = StateProvider<Usuario?>((ref) => null);

// Proveedor para intentar el autologin al arrancar
final autoLoginProvider = FutureProvider<Usuario?>((ref) async {
  final service = ref.watch(authServiceProvider);
  final user = await service.tryAutoLogin();
  if (user != null) {
    ref.read(authStateProvider.notifier).state = user;
  }
  return user;
});
