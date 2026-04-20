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

// Usaremos un StateProvider para determinar qué facturas mostrar
final buyerInvoicesProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, int>>((ref, params) async {
  final api = ref.watch(apiServiceProvider);
  return await api.getFacturasComprador(params['compradorId']!, distribuidorId: params['distribuidorId']);
});
