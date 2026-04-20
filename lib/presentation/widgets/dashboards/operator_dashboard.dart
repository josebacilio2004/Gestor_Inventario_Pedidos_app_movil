import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestor_invetarios_pedidos_app/core/theme/app_theme.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/providers/database_provider.dart';
import 'package:gestor_invetarios_pedidos_app/data/models/tanda.dart';
import 'package:gestor_invetarios_pedidos_app/data/models/producto.dart';
import 'package:gestor_invetarios_pedidos_app/core/utils/numeric_utils.dart';
import 'package:intl/intl.dart';

class OperatorDashboard extends ConsumerStatefulWidget {
  final Map<String, dynamic> profile;
  const OperatorDashboard({super.key, required this.profile});

  @override
  ConsumerState<OperatorDashboard> createState() => _OperatorDashboardState();
}

class _OperatorDashboardState extends ConsumerState<OperatorDashboard> {
  final _noteController = TextEditingController();
  final _stockController = TextEditingController();
  String? _selectedComprador;
  String? _selectedToolType = 'Pico';
  String? _selectedToolBrand = 'Tramontina';
  final _moController = TextEditingController();
  final _orderQtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tandasAsync = ref.watch(tandasFutureProvider);
    final notesAsync = ref.watch(notesFutureProvider);
    final ordersAsync = ref.watch(ordersFutureProvider);
    final productsAsync = ref.watch(productsFutureProvider);
    final buyersAsync = ref.watch(buyersFutureProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            _buildStatsSummary(ordersAsync),
            const SizedBox(height: 32),
            
            const Text('📈 RENDIMIENTO OPERATIVO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, color: AppTheme.textGray)),
            const SizedBox(height: 16),
            _buildChartsRow(maxWidth),
            const SizedBox(height: 32),

            _buildSectionTitle('📌 NOTAS DE LA TANDA', showAdd: true, onAdd: _showAddNoteDialog),
            const SizedBox(height: 12),
            notesAsync.when(
              data: (notes) => notes.isEmpty 
                  ? _emptyState('Sin notas en esta tanda') 
                  : SizedBox(height: 120, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: notes.length, itemBuilder: (c, i) => _stickyNote(notes[i]))),
              loading: () => const SizedBox(height: 40, child: LinearProgressIndicator(color: AppTheme.accentOrange, backgroundColor: Colors.white10)),
              error: (e, _) => Text('Error al cargar notas: $e'),
            ),
            const SizedBox(height: 32),

            _buildSectionTitle('🏭 GESTIÓN DE TANDAS', showAdd: true, onAdd: _handleCreateTanda),
            const SizedBox(height: 16),
            tandasAsync.when(
              data: (tandas) => Column(children: tandas.map((t) => _tandaCard(t)).toList()),
              loading: () => const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: LinearProgressIndicator()),
              error: (e, _) => Text('Error al cargar tandas: $e'),
            ),
            const SizedBox(height: 32),

            _buildSectionTitle('📦 INVENTARIO DE LA TANDA'),
            const SizedBox(height: 12),
            _buildInventoryControl(productsAsync),
            const SizedBox(height: 32),

            _buildSectionTitle('➕ NUEVO PEDIDO DE HERRAMIENTAS'),
            const SizedBox(height: 16),
            _buildNewOrderForm(buyersAsync),
            const SizedBox(height: 32),

            _buildSectionTitle('📋 PEDIDOS RECIENTES'),
            const SizedBox(height: 16),
            _buildOrdersList(ordersAsync),
          ],
        );
      }
    );
  }

  // --- LOGICA DE ACCIONES ---

  Future<void> _handleCreateTanda() async {
    final api = ref.read(apiServiceProvider);
    final name = 'Tanda ${DateFormat('d MMMM').format(DateTime.now())}';
    try {
      await api.post('/tandas', data: {
        'nombre': name,
        'operador_id': widget.profile['id'],
      });
      ref.refresh(tandasFutureProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tanda "$name" creada exitosamente.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al crear tanda: $e')));
    }
  }

  Future<void> _handleSaveOrder() async {
    if (_selectedComprador == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione un comprador')));
      return;
    }

    final api = ref.read(apiServiceProvider);
    final qty = int.tryParse(_orderQtyController.text) ?? 0;
    
    try {
      await api.post('/pedidos-herramientas', data: {
        'operador_id': widget.profile['id'],
        'comprador_id': int.parse(_selectedComprador!),
        'items': [
          {
            'tipo': _selectedToolType,
            'marca': _selectedToolBrand,
            'cantidad': qty,
          }
        ],
        'notas': 'Pedido registrado desde APP móvil',
      });
      
      ref.refresh(ordersFutureProvider);
      ref.refresh(productsFutureProvider); // Refrescar stock
      
      _orderQtyController.clear();
      _moController.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido guardado correctamente.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar pedido: $e')));
    }
  }

  // --- COMPONENTES UI ---

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('👋 Hola, ${widget.profile['nombre'] ?? 'Operador'}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
        const Text('Panel de gestión de pedidos de herramientas', style: TextStyle(color: AppTheme.textGray, fontSize: 13)),
      ],
    );
  }

  Widget _buildStatsSummary(AsyncValue<List<Map<String, dynamic>>> ordersAsync) {
    return ordersAsync.when(
      data: (orders) {
        final pending = orders.where((o) => o['estado'] == 'pendiente').length;
        final processing = orders.where((o) => o['estado'] == 'en_proceso').length;
        final completed = orders.where((o) => o['estado'] == 'completado').length;
        
        return Row(
          children: [
            _statBox(pending.toString(), 'Pendientes', const Color(0xFFFBBF24)),
            const SizedBox(width: 8),
            _statBox(processing.toString(), 'En Proceso', const Color(0xFF3B82F6)),
            const SizedBox(width: 8),
            _statBox(completed.toString(), 'Completados', const Color(0xFF10B981)),
          ],
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _statBox(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.1))),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: color.withOpacity(0.8), letterSpacing: 1)),
        ]),
      ),
    );
  }

  Widget _buildChartsRow(double maxWidth) {
    return SizedBox(
      height: 140, 
      width: maxWidth,
      child: Row(children: [
        Expanded(child: _chartPlaceholder('TENDENCIA PROD.')),
        const SizedBox(width: 12),
        Expanded(child: _chartPlaceholder('EFICIENCIA DESPACHO')),
      ]),
    );
  }

  Widget _chartPlaceholder(String title) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppTheme.textGray)),
        const Spacer(),
        const Center(child: Icon(Icons.bar_chart, color: Colors.white10, size: 32)),
        const Spacer(),
      ]),
    );
  }

  Widget _buildSectionTitle(String title, {bool showAdd = false, VoidCallback? onAdd}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5, color: AppTheme.textGray)),
        if (showAdd) IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle_outline, color: AppTheme.accentOrange, size: 20)),
      ],
    );
  }

  Widget _stickyNote(Map<String, dynamic> note) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7), 
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(2, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(note['contenido'] ?? '', style: const TextStyle(color: Color(0xFF92400E), fontSize: 11, fontWeight: FontWeight.bold), maxLines: 4, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          const Text('🟢', style: TextStyle(fontSize: 8)),
        ],
      ),
    );
  }

  Widget _tandaCard(Tanda tanda) {
    final bool isActive = tanda.estado == 'activa';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? Colors.green.withOpacity(0.3) : Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(isActive ? '🟢' : '⚫', style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
              Expanded(child: Text(tanda.nombre, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white), overflow: TextOverflow.ellipsis)),
              if (isActive) ElevatedButton(
                onPressed: () async {
                   final api = ref.read(apiServiceProvider);
                   await api.put('/tandas/${tanda.id}', data: {'estado': 'cerrada'});
                   ref.refresh(tandasFutureProvider);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.1), foregroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 12), minimumSize: const Size(0, 30)),
                child: const Text('CERRAR', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(isActive ? 'Activa' : 'Cerrada', style: const TextStyle(color: AppTheme.textGray, fontSize: 10)),
          const Divider(color: Colors.white10, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _tandaStat('${tanda.picos?.toInt() ?? 0} picos', 'stock'),
              _tandaStat('${tanda.zapapicos?.toInt() ?? 0} zapas', 'stock'),
              _tandaStat('Neon DB', 'Fuente'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tandaStat(String value, String label, {bool isColor = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: isColor ? Colors.redAccent : Colors.white)),
      Text(label, style: const TextStyle(fontSize: 8, color: AppTheme.textGray)),
    ]);
  }

  Widget _buildInventoryControl(AsyncValue<List<Producto>> productsAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          Row(children: [
            Expanded(child: _inventoryItem('Picos Catalogo', productsAsync, 'Pico')),
            const SizedBox(width: 12),
            Expanded(child: _inventoryItem('Zapapicos Catalogo', productsAsync, 'Zapapico')),
          ]),
          const SizedBox(height: 20),
          const Text('El stock se gestiona mediante tandas en el backend.', style: TextStyle(color: AppTheme.textGray, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _inventoryItem(String label, AsyncValue<List<Producto>> productsAsync, String type) {
    return productsAsync.when(
      data: (prods) {
        final totalCount = prods.where((p) => p.tipoProducto == type).length;
        return Column(children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.textGray)),
          const SizedBox(height: 8),
          Text('$totalCount tipos', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.greenAccent)),
        ]);
      },
      loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _buildNewOrderForm(AsyncValue<List<Map<String, dynamic>>> buyersAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.accentOrange.withOpacity(0.2))),
      child: Column(
        children: [
          buyersAsync.when(
            data: (buyers) => DropdownButtonFormField<String>(
              value: _selectedComprador,
              items: buyers.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['nombre'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.white)))).toList(),
              onChanged: (v) => setState(() => _selectedComprador = v),
              decoration: const InputDecoration(labelText: 'COMPRADOR'),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Error al cargar compradores'),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _smallDropdown('TIPO', ['Pico', 'Zapapico'], (v) => setState(() => _selectedToolType = v))),
            const SizedBox(width: 12),
            Expanded(child: _smallDropdown('MARCA', ['Tramontina', 'Bellota'], (v) => setState(() => _selectedToolBrand = v))),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _orderQtyController, decoration: const InputDecoration(labelText: 'CANTIDAD'), style: const TextStyle(fontSize: 12), keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSaveOrder,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentOrange, minimumSize: const Size(0, 48)),
              child: const Text('💾 GUARDAR PEDIDO', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallDropdown(String label, List<String> options, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      onChanged: onChanged,
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 10, color: Colors.white)))).toList(),
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildOrdersList(AsyncValue<List<Map<String, dynamic>>> ordersAsync) {
    return ordersAsync.when(
      data: (orders) => Column(children: orders.take(5).map((o) => _orderListItem(o)).toList()),
      loading: () => const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _orderListItem(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          Icon(order['estado'] == 'pendiente' ? Icons.timer_outlined : Icons.check_circle, color: order['estado'] == 'pendiente' ? AppTheme.accentOrange : Colors.greenAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(order['comprador_nombre'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
            Text('${order['items']?[0]?['tipo'] ?? ''} x${order['items']?[0]?['cantidad'] ?? ''}', style: const TextStyle(color: AppTheme.textGray, fontSize: 9)),
          ])),
          Text('S/ ${parseDoubleSafe(order['total_mano_obra']).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.accentOrange, fontSize: 11)),
        ],
      ),
    );
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('NUEVA NOTA', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        content: TextField(controller: _noteController, decoration: const InputDecoration(hintText: 'Ej: Hoy agregué 120 picos...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(onPressed: () async {
            final api = ref.read(apiServiceProvider);
            await api.post('/tanda-notas', data: {
              'contenido': _noteController.text,
              'color': '#FEF3C7',
            });
            _noteController.clear();
            ref.refresh(notesFutureProvider);
            Navigator.pop(context);
          }, child: const Text('GUARDAR')),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Center(child: Text(msg, style: const TextStyle(color: AppTheme.textGray, fontSize: 10)));
  }
}
