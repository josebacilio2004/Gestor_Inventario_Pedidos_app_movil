import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestor_invetarios_pedidos_app/core/theme/app_theme.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/providers/database_provider.dart';

class InvestorListScreen extends ConsumerWidget {
  const InvestorListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investorsAsync = ref.watch(investorsStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text('INVERSIONISTAS ALY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: investorsAsync.when(
        data: (investors) => _buildInvestorList(investors),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentOrange)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.accentOrange,
        child: const Icon(Icons.person_add_alt_1, color: Colors.white),
      ),
    );
  }

  Widget _buildInvestorList(List<Map<String, dynamic>> investors) {
    if (investors.isEmpty) {
      return const Center(child: Text('No hay inversionistas registrados.', style: TextStyle(color: AppTheme.textGray)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(investors),
          const SizedBox(height: 32),
          const Text('DETALLE POR INVERSIONISTA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textGray, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          ...investors.map((i) => _investorCard(
            i['nombre'] ?? 'Desconocido',
            'S/ ${i['inversion_total'] ?? '0'}',
            'S/ ${i['retorno_total'] ?? '0'}',
            i['estado'] == 'ACTIVO',
          )),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<Map<String, dynamic>> investors) {
    double total = 0;
    for (var i in investors) {
      total += double.tryParse((i['inversion_total'] ?? '0').toString().replaceAll(',', '')) ?? 0;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.industrialGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CAPITAL TOTAL GESTIONADO', style: TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Text('S/ $total', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
            ],
          ),
          const Icon(Icons.account_balance_rounded, color: Colors.white38, size: 40),
        ],
      ),
    );
  }

  Widget _investorCard(String name, String invested, String returned, bool active) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: active ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  active ? 'ACTIVO' : 'INACTIVO',
                  style: TextStyle(color: active ? Colors.green : Colors.red, fontSize: 8, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stat(invested, 'INVERTIDO'),
              _stat(returned, 'RETORNADO'),
              _stat('15%', 'RENDIM.', color: AppTheme.accentOrange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 8, color: AppTheme.textGray, fontWeight: FontWeight.w900, letterSpacing: 1)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color ?? Colors.white)),
      ],
    );
  }
}
