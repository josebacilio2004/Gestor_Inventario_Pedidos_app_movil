class ProductEntity {
  final String id;
  final String nombre;
  final String descripcion;
  final String tipoProducto;
  final double precioReferencia;
  final String? imagenUrl;
  final String? distribuidorId;
  final String? distribuidorNombre;

  ProductEntity({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.tipoProducto,
    required this.precioReferencia,
    this.imagenUrl,
    this.distribuidorId,
    this.distribuidorNombre,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'tipoProducto': tipoProducto,
    'precioReferencia': precioReferencia,
    'imagenUrl': imagenUrl,
    'distribuidorId': distribuidorId,
    'distribuidorNombre': distribuidorNombre,
  };

  factory ProductEntity.fromJson(Map<String, dynamic> json) => ProductEntity(
    id: json['id'],
    nombre: json['nombre'],
    descripcion: json['descripcion'] ?? '',
    tipoProducto: json['tipo_producto'] ?? json['tipoProducto'] ?? '',
    precioReferencia: (json['precio_referencia'] ?? json['precioReferencia'] as num).toDouble(),
    imagenUrl: json['imagen_url'] ?? json['imagenUrl'],
    distribuidorId: json['distribuidor_id']?.toString() ?? json['distribuidorId'],
    distribuidorNombre: json['distribuidor_nombre'],
  );
}
