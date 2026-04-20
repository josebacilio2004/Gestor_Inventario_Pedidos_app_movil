import '../../core/utils/numeric_utils.dart';

class VentaMayorista {
  final int id;
  final int compradorId;
  final int clienteId;
  final String? clienteNombre;
  final double total;
  final String? notas;
  final String estado;
  final DateTime fechaVenta;
  final List<DetalleVentaMayorista> detalles;

  VentaMayorista({
    required this.id,
    required this.compradorId,
    required this.clienteId,
    this.clienteNombre,
    required this.total,
    this.notas,
    required this.estado,
    required this.fechaVenta,
    required this.detalles,
  });

  factory VentaMayorista.fromJson(Map<String, dynamic> json) {
    var list = json['detalles'] as List? ?? [];
    List<DetalleVentaMayorista> detailsList = list.map((i) => DetalleVentaMayorista.fromJson(i)).toList();

    return VentaMayorista(
      id: json['id'] ?? 0,
      compradorId: json['comprador_id'] ?? 0,
      clienteId: json['cliente_id'] ?? 0,
      clienteNombre: json['cliente_nombre'],
      total: parseDoubleSafe(json['total']),
      notas: json['notas'],
      estado: json['estado'] ?? 'completada',
      fechaVenta: json['fecha_venta'] != null 
          ? DateTime.parse(json['fecha_venta']) 
          : DateTime.now(),
      detalles: detailsList,
    );
  }
}

class DetalleVentaMayorista {
  final int id;
  final int ventaId;
  final String tipo;
  final String marca;
  final int cantidad;
  final double precioUnitario;

  DetalleVentaMayorista({
    required this.id,
    required this.ventaId,
    required this.tipo,
    required this.marca,
    required this.cantidad,
    required this.precioUnitario,
  });

  factory DetalleVentaMayorista.fromJson(Map<String, dynamic> json) {
    return DetalleVentaMayorista(
      id: json['id'] ?? 0,
      ventaId: json['venta_id'] ?? 0,
      tipo: json['tipo'] ?? '',
      marca: json['marca'] ?? '',
      cantidad: parseIntSafe(json['cantidad']),
      precioUnitario: parseDoubleSafe(json['precio_unitario']),
    );
  }
}
