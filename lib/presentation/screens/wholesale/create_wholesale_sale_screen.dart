import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/mayorista_provider.dart';
import '../../providers/database_provider.dart';
import '../../../core/utils/numeric_utils.dart';
import '../../../data/models/mayorista_stock.dart';
import '../../../data/models/mayorista_cliente.dart';

class CreateWholesaleSaleScreen extends ConsumerStatefulWidget {
  final int compradorId;
  const CreateWholesaleSaleScreen({super.key, required this.compradorId});

  @override
  ConsumerState<CreateWholesaleSaleScreen> createState() => _CreateWholesaleSaleScreenState();
}

class _CreateWholesaleSaleScreenState extends ConsumerState<CreateWholesaleSaleScreen> {
  MayoristaCliente? selectedCliente;
  final List<CartItem> cart = [];
  final notesController = TextEditingController();
  bool isSaving = false;

  void _addItem(MayoristaStock stock) {
    setState(() {
      final existing = cart.indexWhere((i) => i.tipo == stock.tipo && i.marca == stock.marca);
      if (existing != -1) {
        if (cart[existing].cantidad < stock.disponible) {
          cart[existing].cantidad++;
        }
      } else {
        cart.add(CartItem(
          tipo: stock.tipo,
          marca: stock.marca,
          cantidad: 1,
          precioUnitario: 85.0, // Precio base de ejemplo
          maxDisponible: stock.disponible,
        ));
      }
    });
  }

  double get total => cart.fold(0, (sum, item) => sum + (item.cantidad * item.precioUnitario));

  Future<void> _save() async {
    if (selectedCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un cliente')));
      return;
    }
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agrega al menos un producto')));
      return;
    }

    setState(() => isSaving = true);
    try {
      final api = ref.read(apiServiceProvider);
      await api.createMayoristaVenta({
        'comprador_id': widget.compradorId,
        'cliente_id': selectedCliente!.id,
        'total': total,
        'notas': notesController.text,
        'detalles': cart.map((i) => {
          'tipo': i.tipo,
          'marca': i.marca,
          'cantidad': i.cantidad,
          'precio_unitario': i.precioUnitario,
        }).toList(),
      });
      
      ref.refresh(mayoristaVentasProvider);
      ref.refresh(mayoristaStockProvider);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Venta registrada con éxito ✅')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(mayoristaClientesProvider);
    final stockAsync = ref.watch(mayoristaStockProvider);

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text('NUEVA VENTA MAYORISTA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CLIENTE ---
                  const Text('👤 CLIENTE MAYORISTA', style: TextStyle(color: AppTheme.textGray, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  clientesAsync.when(
                    data: (clientes) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<MayoristaCliente>(
                          value: selectedCliente,
                          hint: const Text('Seleccionar cliente...', style: TextStyle(color: Colors.white38, fontSize: 14)),
                          isExpanded: true,
                          dropdownColor: AppTheme.surfaceDark,
                          items: clientes.map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.nombre, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          )).toList(),
                          onChanged: (v) => setState(() => selectedCliente = v),
                        ),
                      ),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error al cargar clientes: $e'),
                  ),
                  const SizedBox(height: 32),

                  // --- PRODUCTOS DISPONIBLES ---
                  const Text('📦 PRODUCTOS EN STOCK', style: TextStyle(color: AppTheme.textGray, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  stockAsync.when(
                    data: (stocks) => Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: stocks.where((s) => s.disponible > 0).map((s) => InkWell(
                        onTap: () => _addItem(s),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceDark, 
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.accentOrange.withOpacity(0.2))
                          ),
                          child: Column(
                            children: [
                              Text('${s.tipo} ${s.marca}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              Text('${s.disponible} disp.', style: const TextStyle(fontSize: 9, color: AppTheme.accentOrange)),
                            ],
                          ),
                        ),
                      )).toList(),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 32),

                  // --- CARRITO ---
                  const Text('🛒 DETALLE DE VENTA', style: TextStyle(color: AppTheme.textGray, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  if (cart.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('El carrito está vacío', style: TextStyle(color: AppTheme.textGray)),
                    ))
                  else
                    ...cart.map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${item.tipo} ${item.marca}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('S/ ${item.precioUnitario.toStringAsFixed(2)} c/u', style: const TextStyle(fontSize: 10, color: AppTheme.textGray)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.white54),
                                onPressed: () => setState(() {
                                  if (item.cantidad > 1) item.cantidad--;
                                  else cart.remove(item);
                                }),
                              ),
                              Text('${item.cantidad}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: AppTheme.accentOrange),
                                onPressed: () => setState(() {
                                  if (item.cantidad < item.maxDisponible) item.cantidad++;
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Text('S/ ${(item.cantidad * item.precioUnitario).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.greenAccent)),
                        ],
                      ),
                    )),
                ],
              ),
            ),
          ),
          
          // --- FOOTER CON TOTAL ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)]
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL A COBRAR', style: TextStyle(color: AppTheme.textGray, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('S/ ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.greenAccent)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                      ),
                      child: isSaving 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('CONFIRMAR VENTA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartItem {
  final String tipo;
  final String marca;
  int cantidad;
  double precioUnitario;
  int maxDisponible;

  CartItem({
    required this.tipo,
    required this.marca,
    required this.cantidad,
    required this.precioUnitario,
    required this.maxDisponible,
  });
}
