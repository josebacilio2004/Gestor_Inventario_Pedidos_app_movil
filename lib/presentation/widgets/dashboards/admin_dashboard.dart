import 'package:flutter/material.dart';
import 'package:gestor_invetarios_pedidos_app/core/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboard extends StatelessWidget {
  final Map<String, dynamic> profile;
  const AdminDashboard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatsGrid(),
        const SizedBox(height: 32),
        const Text(
          'INTELIGENCIA DE NEGOCIO 📊',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, color: AppTheme.textGray),
        ),
        const SizedBox(height: 16),
        _buildChartsRow(),
        const SizedBox(height: 32),
        const Text(
          'ACCIONES DE CONTROL ⚙️',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, color: AppTheme.textGray),
        ),
        const SizedBox(height: 16),
        _buildActionButtons(context),
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
      childAspectRatio: 1.6,
      children: [
        _statCard('TOTAL PEDIDOS', '156', Icons.assignment_outlined, AppTheme.accentOrange),
        _statCard('PROD. ACTIVOS', '42', Icons.inventory_2_outlined, const Color(0xFF6366F1)),
        _statCard('GANANCIA REAL', 'S/ 12.4k', Icons.trending_up, const Color(0xFF10B981)),
        _statCard('MARGEN PROM.', '18%', Icons.pie_chart_outline, const Color(0xFF8B5CF6)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppTheme.textGray)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildChartsRow() {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(value: 65, color: const Color(0xFF10B981), radius: 6, showTitle: false),
                    PieChartSectionData(value: 35, color: const Color(0xFF3B82F6), radius: 6, showTitle: false),
                  ],
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: AppTheme.accentOrange, width: 8)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: const Color(0xFF10B981), width: 8)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 7, color: const Color(0xFF3B82F6), width: 8)]),
                  ],
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _primaryAction('CREAR NUEVO PEDIDO', Icons.add_circle_outline),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _secondaryAction('PRODUCTOS', Icons.inventory_2_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _secondaryAction('USUARIOS', Icons.people_outline)),
          ],
        ),
      ],
    );
  }

  Widget _primaryAction(String label, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.industrialGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _secondaryAction(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.textGray, size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, color: AppTheme.textGray)),
        ],
      ),
    );
  }
}
