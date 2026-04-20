import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';
import '../../data/models/mayorista_stock.dart';
import '../../data/models/venta_mayorista.dart';
import '../../data/models/mayorista_cliente.dart';
import 'database_provider.dart';

final mayoristaStockProvider = FutureProvider<List<MayoristaStock>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final data = await api.getMayoristaStock();
  return data.map((e) => MayoristaStock.fromJson(e)).toList();
});

final mayoristaVentasProvider = FutureProvider<List<VentaMayorista>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final data = await api.getMayoristaVentas();
  return data.map((e) => VentaMayorista.fromJson(e)).toList();
});

final mayoristaClientesProvider = FutureProvider<List<MayoristaCliente>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final data = await api.getMayoristasClientes();
  return data.map((e) => MayoristaCliente.fromJson(e)).toList();
});
