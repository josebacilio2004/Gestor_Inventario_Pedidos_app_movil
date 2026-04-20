import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestor_invetarios_pedidos_app/core/theme/app_theme.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/providers/investor_nav_provider.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/providers/database_provider.dart';
import 'package:gestor_invetarios_pedidos_app/core/utils/numeric_utils.dart';
import 'package:fl_chart/fl_chart.dart';

class InvestorDashboard extends ConsumerWidget {
  final Map<String, dynamic> profile;
  const InvestorDashboard({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSection = ref.watch(investorNavProvider);

    switch (currentSection) {
      case InvestorSection.inventoryManager:
      case InvestorSection.dashboard:
        return _buildDashboardView(ref);
      case InvestorSection.products:
        return _buildProductsView(ref);
      case InvestorSection.distributors:
        return _buildDistributorsView(ref);
      case InvestorSection.orders:
        return _buildOrdersView(ref);
      case InvestorSection.buyers:
        return _buildBuyersView(ref);
      default:
        return _buildDashboardView(ref);
    }
  }

  // ─── VISTA: DASHBOARD / GESTOR DE INVENTARIO ───
  Widget _buildDashboardView(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatsGrid(),
        const SizedBox(height: 32),
        const Text(
          'ANÁLISIS DE RENDIMIENTO 📊',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, color: AppTheme.textGray),
        ),
        const SizedBox(height: 16),
        _buildChartsRow(),
        const SizedBox(height: 32),
        const Text(
          '📋 DETALLE DE MIS INVERSIONES',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildInvestmentTable(ref),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard('CAPITAL TOTAL INVERTIDO', 'S/ 17,432.00', AppTheme.accentOrange),
        _statCard('CAPITAL DEVUELTO', 'S/ 3,527.00', Colors.greenAccent),
        _statCard('CAPITAL PENDIENTE', 'S/ 13,905.00', Colors.redAccent),
        _statCard('TOTAL PEDIDOS', '8', Colors.blueAccent),
        _statCard('GANANCIA REAL', 'S/ 1,410.00', Colors.orangeAccent),
        _statCard('GANANCIA DEVUELTA', 'S/ 300.00', Colors.tealAccent),
        _statCard('GANANCIA PENDIENTE', 'S/ 1,110.00', Colors.amberAccent),
        _statCard('% DEVOLUCIÓN', '20.2%', AppTheme.accentOrange),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: AppTheme.textGray, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildChartsRow() {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(child: _chartContainer('Distribución de Capital', _buildPieChart())),
          const SizedBox(width: 12),
          Expanded(child: _chartContainer('Rendimiento Ganancias', _buildBarChart())),
        ],
      ),
    );
  }

  Widget _chartContainer(String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(fit: BoxFit.scaleDown, child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppTheme.textGray))),
          const SizedBox(height: 12),
          Expanded(child: chart),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 20.2, color: AppTheme.accentOrange, radius: 5, showTitle: false),
          PieChartSectionData(value: 79.8, color: Colors.white10, radius: 5, showTitle: false),
        ],
        centerSpaceRadius: 30,
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 300, color: AppTheme.accentOrange, width: 8)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 1110, color: Colors.white10, width: 8)]),
        ],
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
      ),
    );
  }

  Widget _buildInvestmentTable(WidgetRef ref) {
    return _buildTableContainer([
      ['#', 'FECHA', 'PRODUCTO', 'CAPITAL', 'ESTADO'],
      ['20', '8 abr', 'Pico Titan', 'S/ 3,825', 'PEND'],
      ['18', '17 mar', 'Zapapico Titan', 'S/ 1,080', 'PEND'],
      ['17', '14 mar', 'Pico Vector', 'S/ 3,060', 'PEND'],
      ['15', '10 mar', 'Zapapico Titan', 'S/ 1,440', 'PEND'],
      ['11', '4 mar', 'Pico Vector', 'S/ 2,116', 'OK'],
    ]);
  }

  // ─── VISTA: PRODUCTOS ───
  Widget _buildProductsView(WidgetRef ref) {
    final productsAsync = ref.watch(productsFutureProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('📦 GESTIÓN DE PRODUCTOS', 'Administra tu catálogo de productos de ferretería'),
        _buildActionBtn(ref, '➕ NUEVO PRODUCTO', () => _showAddProductDialog(ref.context, ref)),
        const SizedBox(height: 16),
        productsAsync.when(
          data: (products) => _buildTableContainer([
            ['ID', 'NOMBRE', 'TIPO', 'PRECIO'],
            ...products.map((p) => [
              p.id.toString(),
              p.nombre,
              p.tipoProducto,
              'S/ ${parseDoubleSafe(p.precioReferencia).toStringAsFixed(2)}',
            ]),
          ]),
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentOrange)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.redAccent))),
        ),
      ],
    );
  }

  // ─── VISTA: DISTRIBUIDORES ───
  Widget _buildDistributorsView(WidgetRef ref) {
    final distributorsAsync = ref.watch(distributorsFutureProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🏭 GESTIÓN DE DISTRIBUIDORES', 'Administra tu red de proveedores'),
        _buildActionBtn(ref, '➕ NUEVO DISTRIBUIDOR', () => _showAddDistributorDialog(ref.context, ref)),
        const SizedBox(height: 16),
        distributorsAsync.when(
          data: (distributors) => _buildTableContainer([
            ['ID', 'NOMBRE', 'CONTACTO', 'TELÉFONO'],
            ...distributors.map((d) => [
              d['id'].toString(),
              d['nombre'] ?? '',
              d['contacto'] ?? '',
              d['telefono'] ?? '',
            ]),
          ]),
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentOrange)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.redAccent))),
        ),
      ],
    );
  }

  // ─── VISTA: PEDIDOS ───
  Widget _buildOrdersView(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('📋 GESTIÓN DE PEDIDOS', 'Registra y monitorea tus pedidos'),
        _buildActionBtn(ref, '➕ NUEVO PEDIDO', () {}),
        const SizedBox(height: 16),
        _buildTableContainer([
          ['#', 'FECHA', 'PRODUCTO', 'CANT', 'ESTADO'],
          ['20', '8 abr', 'Pico Titan', '300', 'PEND'],
          ['18', '17 mar', 'Zapapico Titan', '120', 'PEND'],
          ['17', '14 mar', 'Pico Vector', '240', 'PEND'],
        ]),
      ],
    );
  }

  // ─── VISTA: COMPRADORES ───
  Widget _buildBuyersView(WidgetRef ref) {
    final buyersAsync = ref.watch(buyersFutureProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🛒 GESTIÓN DE COMPRADORES', 'Compradores que gestionan las inversiones'),
        _buildActionBtn(ref, '➕ NUEVO COMPRADOR', () {}),
        const SizedBox(height: 16),
        buyersAsync.when(
          data: (buyers) => _buildTableContainer([
            ['ID', 'NOMBRE', 'CAPITAL', 'DEVUELTO'],
            ...buyers.map((b) => [
              b['id'].toString(),
              b['nombre'] ?? '',
              'S/ ${parseDoubleSafe(b['capital_total_gestionado']).toStringAsFixed(2)}',
              'S/ ${parseDoubleSafe(b['capital_devuelto']).toStringAsFixed(2)}',
            ]),
          ]),
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentOrange)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.redAccent))),
        ),
      ],
    );
  }

  // ─── COMPONENTES REUTILIZABLES ───
  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textGray)),
        ],
      ),
    );
  }

  Widget _buildActionBtn(WidgetRef ref, String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentOrange,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(0, 40),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildTableContainer(List<List<String>> data) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: data[0].map((h) => Expanded(
                child: Text(h, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppTheme.textGray)),
              )).toList(),
            ),
          ),
          // Body
          ...data.skip(1).map((row) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white10))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: row.map((cell) => Expanded(
                child: Text(
                  cell, 
                  style: TextStyle(
                    fontSize: 9, 
                    fontWeight: cell == 'PEND' || cell == 'OK' || cell == 'completado' ? FontWeight.w900 : FontWeight.bold,
                    color: cell == 'PEND' || cell == 'pendiente' ? AppTheme.accentOrange : (cell == 'OK' || cell == 'completado' ? Colors.greenAccent : Colors.white),
                  ),
                ),
              )).toList(),
            ),
          )).toList(),
        ],
      ),
    );
  }

  // ─── DIÁLOGOS DE REGISTRO ───
  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('NUEVO PRODUCTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: typeController, decoration: const InputDecoration(labelText: 'Tipo (Pico/Zapapico)')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Precio Ref.'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              final api = ref.read(apiServiceProvider);
              await api.createProducto({
                'nombre': nameController.text,
                'tipo_producto': typeController.text,
                'precio_referencia': double.tryParse(priceController.text) ?? 0.0,
              });
              ref.refresh(productsFutureProvider);
              Navigator.pop(context);
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  void _showAddDistributorDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('NUEVO DISTRIBUIDOR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Razón Social')),
            TextField(controller: contactController, decoration: const InputDecoration(labelText: 'Contacto')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Teléfono')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              final api = ref.read(apiServiceProvider);
              await api.createDistribuidor({
                'nombre': nameController.text,
                'contacto': contactController.text,
                'telefono': phoneController.text,
              });
              ref.refresh(distributorsFutureProvider);
              Navigator.pop(context);
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }
}
