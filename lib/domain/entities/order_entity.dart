enum OrderStatus { pendiente, en_proceso, completado, cancelado }

class OrderEntity {
  final String id;
  final DateTime fechaPedido;
  final String productoId;
  final String distribuidorId;
  final String? inversionistaId;
  final String? compradorId;
  final int cantidad;
  final double capitalInvertido;
  final double capitalDevuelto;
  final double gananciaEsperada;
  final double gananciaReal;
  final OrderStatus estado;
  final String notas;

  OrderEntity({
    required this.id,
    required this.fechaPedido,
    required this.productoId,
    required this.distribuidorId,
    this.inversionistaId,
    this.compradorId,
    required this.cantidad,
    required this.capitalInvertido,
    required this.capitalDevuelto,
    required this.gananciaEsperada,
    required this.gananciaReal,
    required this.estado,
    required this.notas,
  });

  double get capitalPendiente => capitalInvertido - capitalDevuelto;

  Map<String, dynamic> toJson() => {
    'id': id,
    'fechaPedido': fechaPedido.toIso8601String(),
    'productoId': productoId,
    'distribuidorId': distribuidorId,
    'inversionistaId': inversionistaId,
    'compradorId': compradorId,
    'cantidad': cantidad,
    'capitalInvertido': capitalInvertido,
    'capitalDevuelto': capitalDevuelto,
    'gananciaEsperada': gananciaEsperada,
    'gananciaReal': gananciaReal,
    'estado': estado.name,
    'notas': notas,
  };

  factory OrderEntity.fromJson(Map<String, dynamic> json) => OrderEntity(
    id: json['id'],
    fechaPedido: DateTime.parse(json['fechaPedido']),
    productoId: json['productoId'],
    distribuidorId: json['distribuidorId'],
    inversionistaId: json['inversionistaId'],
    compradorId: json['compradorId'],
    cantidad: json['cantidad'],
    capitalInvertido: (json['capitalInvertido'] as num).toDouble(),
    capitalDevuelto: (json['capitalDevuelto'] as num).toDouble(),
    gananciaEsperada: (json['gananciaEsperada'] as num).toDouble(),
    gananciaReal: (json['gananciaReal'] as num).toDouble(),
    estado: OrderStatus.values.byName(json['estado']),
    notas: json['notas'] ?? '',
  );
}
