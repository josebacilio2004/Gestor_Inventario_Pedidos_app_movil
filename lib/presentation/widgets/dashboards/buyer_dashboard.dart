import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestor_invetarios_pedidos_app/core/theme/app_theme.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/providers/buyer_nav_provider.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/providers/database_provider.dart';
import 'package:gestor_invetarios_pedidos_app/core/utils/numeric_utils.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/providers/mayorista_provider.dart';
import 'package:gestor_invetarios_pedidos_app/data/models/mayorista_stock.dart';
import 'package:gestor_invetarios_pedidos_app/data/models/venta_mayorista.dart';
import 'package:gestor_invetarios_pedidos_app/data/models/mayorista_cliente.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/screens/wholesale/create_wholesale_sale_screen.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/screens/billing/account_statement_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class BuyerDashboard extends ConsumerWidget {
  final Map<String, dynamic> profile;
  const BuyerDashboard({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSection = ref.watch(buyerNavProvider);

    switch (currentSection) {
      case BuyerSection.inventoryManager:
      case BuyerSection.dashboard:
        return _buildDashboardView(context, ref);
      case BuyerSection.orders:
        return _buildOrdersView(ref);
      case BuyerSection.invoicing:
        return _buildInvoicingView(context, ref);
      case BuyerSection.wholesaleSales:
        return _buildWholesaleSalesView(ref);
      default:
        return _buildDashboardView(context, ref);
    }
  }

  // ─── VISTA: DASHBOARD ───
  Widget _buildDashboardView(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildSectionHeader('🛒 PANEL DE CONTROL - COMPRADOR', 'Gestiona tus compras y devoluciones')),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => ref.read(buyerNavProvider.notifier).state = BuyerSection.wholesaleSales,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(0, 36)),
              child: const Text('IR A VENTAS MAYORISTAS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatsGrid(),
        const SizedBox(height: 32),
        const Text('ANÁLISIS DE FLUJO 📈', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, color: AppTheme.textGray)),
        const SizedBox(height: 16),
        _buildChartsRow(),
        const SizedBox(height: 32),
        const Text('📋 PEDIDOS A MI CARGO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
        const SizedBox(height: 16),
        _buildOrdersToChargeTable(ref),
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
      childAspectRatio: 1.8,
      children: [
        _statCard('CAPITAL GESTIONADO', 'S/ 17,432.00', AppTheme.accentOrange),
        _statCard('CAPITAL DEVUELTO', 'S/ 3,527.00', Colors.greenAccent),
        _statCard('PENDIENTE DEVOLVER', 'S/ 13,905.00', Colors.redAccent),
        _statCard('TOTAL PEDIDOS', '8', Colors.blueAccent),
        _statCard('GANANCIA GENERADA', 'S/ 300.00', Colors.tealAccent),
        _statCard('% DEVUELTO', '20.2%', AppTheme.accentOrange),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: AppTheme.textGray)),
          const SizedBox(height: 4),
          FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color))),
        ],
      ),
    );
  }

  Widget _buildChartsRow() {
    return SizedBox(height: 180, child: Row(children: [
      Expanded(child: _chartContainer('Flujo de Capital', _buildCapitalLineChart())),
      const SizedBox(width: 12),
      Expanded(child: _chartContainer('Desempeño Pedidos', _buildStatusPieChart())),
    ]));
  }

  Widget _chartContainer(String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppTheme.textGray)),
        const SizedBox(height: 12),
        Expanded(child: chart),
      ]),
    );
  }

  Widget _buildCapitalLineChart() => LineChart(LineChartData(gridData: const FlGridData(show: false), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false), lineBarsData: [LineChartBarData(spots: [const FlSpot(0, 1), const FlSpot(1, 4), const FlSpot(2, 2.5), const FlSpot(3, 5)], isCurved: true, color: AppTheme.accentOrange, barWidth: 2, belowBarData: BarAreaData(show: true, color: AppTheme.accentOrange.withOpacity(0.05)))]));
  Widget _buildStatusPieChart() => PieChart(PieChartData(sections: [PieChartSectionData(value: 80, color: Colors.greenAccent, radius: 4, showTitle: false), PieChartSectionData(value: 20, color: AppTheme.accentOrange, radius: 4, showTitle: false)], centerSpaceRadius: 25));

  Widget _buildOrdersToChargeTable(WidgetRef ref) {
    final ordersAsync = ref.watch(ordersFutureProvider);
    return ordersAsync.when(
      data: (orders) => _buildTableContainer([
        ['#', 'PRODUCTO', 'INV.', 'PEND.', 'GESTIÓN'],
        ...orders.map((o) => [
          o['id'].toString(), 
          o['items']?[0]?['tipo'] ?? 'N/A', 
          (o['comprador_nombre'] ?? '').toString().split(' ').last, 
          'S/ ${parseDoubleSafe(o['total_mano_obra']).toStringAsFixed(2)}', 
          o['estado'] == 'pendiente' ? '💵 PAGAR' : '✅ OK'
        ])
      ]),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }

  // ─── VISTA: MIS PEDIDOS ───
  Widget _buildOrdersView(WidgetRef ref) {
    final ordersAsync = ref.watch(ordersFutureProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildSectionHeader('📋 GESTIÓN DE PEDIDOS', 'Tus solicitudes sincronizadas con el operador'),
      _buildActionBtn(ref, '➕ NUEVO PEDIDO', () => _showAddOrderDialog(ref.context, ref)),
      const SizedBox(height: 16),
      ordersAsync.when(
        data: (orders) => _buildTableContainer([
          ['#', 'FECHA', 'PRODUCTO', 'ESTADO', 'MONTO'],
          ...orders.map((o) => [
            o['id'].toString(), 
            (o['created_at'] != null) ? DateTime.parse(o['created_at']).toString().split(' ')[0] : '-', 
            o['items']?[0]?['tipo'] ?? 'N/A', 
            (o['estado'] ?? 'pend').toString().toUpperCase(),
            'S/ ${parseDoubleSafe(o['total_mano_obra']).toStringAsFixed(2)}'
          ])
        ]),
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
      ),
    ]);
  }

  // ─── VISTA: FACTURACIONES (LÓGICA POR DISTRIBUIDOR) ───
  Widget _buildInvoicingView(BuildContext context, WidgetRef ref) {
    final selectedDistributor = ref.watch(selectedDistributorProvider);
    if (selectedDistributor == null) return _buildDistributorSelection(ref);
    return _buildDistributorDetail(ref, selectedDistributor);
  }

  Widget _buildDistributorSelection(WidgetRef ref) {
    final distributorsAsync = ref.watch(distributorsFutureProvider);
    
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildSectionHeader('📄 FACTURACIONES', 'Selecciona el distribuidor para ver sus saldos'),
      const SizedBox(height: 16),
      distributorsAsync.when(
        data: (distributors) => GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.8,
          children: distributors.map((d) => _distributorCard(
            ref, 
            d['nombre'] ?? d.toString(), 
            d['id'] ?? 0,
            Icons.business_outlined
          )).toList(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error: $e'),
      ),
    ]);
  }

  Widget _distributorCard(WidgetRef ref, String name, int id, IconData icon) {
    return InkWell(
      onTap: () {
        Navigator.push(
          ref.context,
          MaterialPageRoute(
            builder: (context) => AccountStatementScreen(
              compradorId: profile['id'],
              distribuidorId: id,
              distribuidorNombre: name,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: AppTheme.accentOrange, size: 28),
          const SizedBox(height: 12),
          Text(name, 
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900), 
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ]),
      ),
    );
  }

  Widget _buildDistributorDetail(WidgetRef ref, String distributor) {
    // Ya no se usa internamente, ahora navegamos a AccountStatementScreen
    return const SizedBox();
  }

  Widget _buildDeudaResumen(double debt, double paid) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.accentOrange.withOpacity(0.2))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _summaryItem('DEUDA TOTAL', 'S/ ${debt.toStringAsFixed(2)}', Colors.redAccent),
        Container(width: 1, height: 40, color: Colors.white10),
        _summaryItem('TOTAL ABONADO', 'S/ ${paid.toStringAsFixed(2)}', Colors.greenAccent),
      ]),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppTheme.textGray)),
      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
    ]);
  }

  // ─── VISTA: VENTAS MAYORISTAS ───
  Widget _buildWholesaleSalesView(WidgetRef ref) {
    final stockAsync = ref.watch(mayoristaStockProvider);
    final salesAsync = ref.watch(mayoristaVentasProvider);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSectionHeader('📦 VENTAS MAYORISTAS', 'Stock en tiempo real de picos y zapapicos'),
        const SizedBox(height: 16),
        stockAsync.when(
          data: (stock) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: stock.map((s) => _stockChip(
                '${s.tipo} ${s.marca}', 
                s.disponible.toString(),
                s.disponible <= 5 ? Colors.redAccent : Colors.greenAccent
              )).toList(),
            ),
          ),
          loading: () => const LinearProgressIndicator(color: AppTheme.accentOrange),
          error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('📋 HISTORIAL DE VENTAS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
            _buildActionBtn(ref, '➕ NUEVA VENTA', () => _showCreateSaleDialog(ref.context, ref)),
          ],
        ),
        const SizedBox(height: 16),
        salesAsync.when(
          data: (sales) => _buildTableContainer([
            ['#', 'CLIENTE', 'FECHA', 'TOTAL', 'ESTADO'],
            ...sales.map((s) => [
              s.id.toString(),
              s.clienteNombre ?? 'Anon',
              s.fechaVenta.toString().split(' ')[0],
              'S/ ${s.total.toStringAsFixed(2)}',
              s.estado.toUpperCase()
            ])
          ]),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
        ),
    ]);
  }

  Widget _stockChip(String label, String count, Color color) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: color.withOpacity(0.3))
      ),
      child: Column(children: [
        Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 4),
        Text(label, 
          style: const TextStyle(fontSize: 8, color: AppTheme.textGray, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ]),
    );
  }

  // ─── REUTILIZABLES ───
  Widget _buildSectionHeader(String title, String subtitle) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)), Text(subtitle, style: const TextStyle(fontSize: 10, color: AppTheme.textGray))]);
  
  Widget _buildActionBtn(WidgetRef ref, String label, VoidCallback onPressed) => ElevatedButton(
    onPressed: onPressed, 
    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentOrange, minimumSize: const Size(0, 40)), 
    child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900))
  );

  Widget _buildTableContainer(List<List<String>> data) => Container(width: double.infinity, decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)), child: Column(children: [
    Container(padding: const EdgeInsets.all(12), color: Colors.white.withOpacity(0.03), child: Row(children: data[0].map((h) => Expanded(child: Text(h, style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: AppTheme.textGray)))).toList())),
    ...data.skip(1).map((row) => Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white10))), child: Row(children: row.map((cell) => Expanded(child: Text(cell, style: TextStyle(fontSize: 9, color: (cell.contains('S/') && !cell.contains('0.00')) ? Colors.redAccent : (cell == 'VENCIDA' || cell == 'CANCELADO' ? Colors.redAccent : (cell == 'OK' || cell == 'COMPLETADO' || cell == '✅ OK' ? Colors.greenAccent : Colors.white70)), fontWeight: cell.contains('S/') ? FontWeight.w900 : FontWeight.normal)))).toList())))
  ]));

  // ─── DIÁLOGOS ───
  void _showAddOrderDialog(BuildContext context, WidgetRef ref) {
    final noteController = TextEditingController();
    num quantity = 100;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('NUEVO PEDIDO OPERATIVO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Se solicitará stock de la Tanda Activa.', style: TextStyle(color: AppTheme.textGray, fontSize: 10)),
            const SizedBox(height: 16),
            TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Notas / Observaciones')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              final api = ref.read(apiServiceProvider);
              // Lógica simplificada de pedido para demo
              await api.post('/pedidos-herramientas', data: {
                'operador_id': 1,
                'comprador_id': profile['id'],
                'notas': noteController.text,
                'items': [
                  {'tipo': 'Pico', 'marca': 'Tramontina', 'cantidad': quantity}
                ]
              });
              ref.refresh(ordersFutureProvider);
              Navigator.pop(context);
            },
            child: const Text('ENVIAR'),
          ),
        ],
      ),
    );
  }

  void _showCreateSaleDialog(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateWholesaleSaleScreen(compradorId: profile['id']),
      ),
    );
  }
}
