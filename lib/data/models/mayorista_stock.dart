import '../../core/utils/numeric_utils.dart';

class MayoristaStock {
  final String tipo;
  final String marca;
  final int producido;
  final int ingresado;
  final int vendido;
  final int disponible;

  MayoristaStock({
    required this.tipo,
    required this.marca,
    required this.producido,
    required this.ingresado,
    required this.vendido,
    required this.disponible,
  });

  factory MayoristaStock.fromJson(Map<String, dynamic> json) {
    return MayoristaStock(
      tipo: json['tipo'] ?? '',
      marca: json['marca'] ?? '',
      producido: parseIntSafe(json['producido']),
      ingresado: parseIntSafe(json['ingresado']),
      vendido: parseIntSafe(json['vendido']),
      disponible: parseIntSafe(json['disponible']),
    );
  }
}
