import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BuyerSection {
  inventoryManager,
  dashboard,
  orders,
  invoicing,
  wholesaleSales,
  myProducts,
}

final buyerNavProvider = StateProvider<BuyerSection>((ref) => BuyerSection.dashboard);

// Proveedor para rastrear el distribuidor seleccionado en el módulo de Facturaciones
final selectedDistributorProvider = StateProvider<String?>((ref) => null);
