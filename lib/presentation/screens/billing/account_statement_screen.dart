import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/billing_provider.dart';
import '../../providers/database_provider.dart';
import '../../../core/utils/numeric_utils.dart';

class AccountStatementScreen extends ConsumerStatefulWidget {
  final int compradorId;
  final int distribuidorId;
  final String distribuidorNombre;

  const AccountStatementScreen({
    super.key,
    required this.compradorId,
    required this.distribuidorId,
    required this.distribuidorNombre,
  });

  @override
  ConsumerState<AccountStatementScreen> createState() => _AccountStatementScreenState();
}

class _AccountStatementScreenState extends ConsumerState<AccountStatementScreen> {
  final Set<int> selectedInvoices = {};
  
  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(buyerInvoicesProvider({
      'compradorId': widget.compradorId,
      'distribuidorId': widget.distribuidorId,
    }));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('ESTADO: ${widget.distribuidorNombre}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        backgroundColor: Colors.transparent,
      ),
      body: invoicesAsync.when(
        data: (invoices) => _buildContent(invoices),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: selectedInvoices.isNotEmpty 
        ? FloatingActionButton.extended(
            onPressed: () => _showAbonoDialog(invoicesAsync.asData!.value),
            backgroundColor: AppTheme.accentOrange,
            icon: const Icon(Icons.payments_outlined),
            label: const Text('ABONAR SELECCIONADAS', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        : null,
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> invoices) {
    double totalDebt = invoices.fold(0, (sum, f) => sum + parseDoubleSafe(f['saldo_pendiente']));
    double totalPaid = invoices.fold(0, (sum, f) => sum + parseDoubleSafe(f['total_abonado']));

    return Column(
      children: [
        _buildSummaryHeader(totalDebt, totalPaid),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final f = invoices[index];
              final isSelected = selectedInvoices.contains(f['id']);
              final pend = parseDoubleSafe(f['saldo_pendiente']);
              final isDone = pend < 0.1;
              final dias = parseIntSafe(f['dias_vencido']);

              return Container(
                margin: const EdgeInsets.bottom(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppTheme.accentOrange : (dias > 0 && !isDone ? Colors.redAccent.withOpacity(0.5) : Colors.white10)
                  )
                ),
                child: ListTile(
                  onTap: isDone ? null : () {
                    setState(() {
                      if (isSelected) selectedInvoices.remove(f['id']);
                      else selectedInvoices.add(f['id']);
                    });
                  },
                  leading: isDone 
                    ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                    : Checkbox(
                        value: isSelected, 
                        onChanged: (v) {
                          setState(() {
                            if (v!) selectedInvoices.add(f['id']);
                            else selectedInvoices.remove(f['id']);
                          });
                        },
                        activeColor: AppTheme.accentOrange,
                      ),
                  title: Row(
                    children: [
                      Text(f['numero'] ?? 'INV-?', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 8),
                      _statusBadge(dias, isDone),
                    ],
                  ),
                  subtitle: Text('Vence: ${f['fecha_vencim']?.toString().split('T')[0]}', style: const TextStyle(fontSize: 10, color: AppTheme.textGray)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('S/ ${pend.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w900, color: isDone ? Colors.greenAccent : (dias > 0 ? Colors.redAccent : Colors.white))),
                      if (!isDone) Text('Total: S/ ${parseDoubleSafe(f['monto_total']).toStringAsFixed(2)}', style: const TextStyle(fontSize: 8, color: AppTheme.textGray)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(int dias, bool isDone) {
    if (isDone) return _badge('PAGADA', Colors.greenAccent);
    if (dias > 0) return _badge('+$dias DÍAS', Colors.redAccent);
    if (dias >= -5) return _badge('PRONTO', Colors.orangeAccent);
    return _badge('OK', Colors.blueAccent);
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(label, style: TextStyle(color: color, fontSize: 7, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSummaryHeader(double debt, double paid) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('DEUDA TOTAL', 'S/ ${debt.toStringAsFixed(2)}', Colors.redAccent),
          _summaryItem('PAGADO', 'S/ ${paid.toStringAsFixed(2)}', Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textGray, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
      ],
    );
  }

  void _showAbonoDialog(List<Map<String, dynamic>> allInvoices) {
    final selectedIdxs = allInvoices.where((f) => selectedInvoices.contains(f['id'])).toList();
    final totalPendiente = selectedIdxs.fold(0.0, (sum, f) => sum + parseDoubleSafe(f['saldo_pendiente']));
    
    final montoController = TextEditingController(text: totalPendiente.toStringAsFixed(2));
    final descController = TextEditingController(text: 'Abono desde App Móvil');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('REGISTRAR ABONO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Se abonará a ${selectedIdxs.length} factura(s) seleccionada(s).', style: const TextStyle(color: AppTheme.textGray, fontSize: 10)),
            const SizedBox(height: 16),
            TextField(
              controller: montoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Monto a abonar (S/)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descripción / Nota'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              final monto = double.tryParse(montoController.text) ?? 0;
              if (monto <= 0) return;

              final api = ref.read(apiServiceProvider);
              // Lógica de distribución proporcional
              double resto = monto;
              for (var f in selectedIdxs) {
                if (resto <= 0) break;
                double pend = parseDoubleSafe(f['saldo_pendiente']);
                double prop = pend / totalPendiente;
                double abonoFact = (monto * prop).clamp(0, pend);
                
                await api.createAbono(f['id'], {
                  'monto': abonoFact,
                  'descripcion': descController.text,
                  'fecha': DateTime.now().toIso8601String().split('T')[0],
                });
                resto -= abonoFact;
              }

              ref.refresh(buyerInvoicesProvider({
                'compradorId': widget.compradorId,
                'distribuidorId': widget.distribuidorId,
              }));
              
              if (mounted) {
                Navigator.pop(context);
                setState(() => selectedInvoices.clear());
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abono registrado correctamente ✅')));
              }
            },
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );
  }
}
