import 'package:flutter_riverpod/flutter_riverpod.dart';

enum InvestorSection {
  inventoryManager,
  dashboard,
  products,
  distributors,
  orders,
  buyers,
}

final investorNavProvider = StateProvider<InvestorSection>((ref) => InvestorSection.dashboard);
