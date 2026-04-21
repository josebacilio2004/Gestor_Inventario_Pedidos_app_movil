import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';
import 'database_provider.dart';

final facturasCompradorProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, distribuidorId) async {
  final api = ref.watch(apiServiceProvider);
  // Obtenemos el compradorId desde el perfil actual o similar
  // Para este provider usaremos un parámetro fijo o el estado global
  // Pero mejor lo manejamos en el screen.
  return []; // Placeholder
});

// Usaremos una cadena "compradorId-distribuidorId" como clave para asegurar igualdad de valor
final buyerInvoicesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, key) async {
  final api = ref.watch(apiServiceProvider);
  final parts = key.split('-');
  final compradorId = int.parse(parts[0]);
  final distribuidorId = int.parse(parts[1]);
  return await api.getFacturasComprador(compradorId, distribuidorId: distribuidorId);
});
