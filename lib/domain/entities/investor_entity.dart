class InvestorEntity {
  final String id;
  final String nombre;
  final String? contacto;
  final String? telefono;
  final String? email;
  final String? notas;
  final bool activo;
  final double totalInvertido;
  final double totalRetornado;

  InvestorEntity({
    required this.id,
    required this.nombre,
    this.contacto,
    this.telefono,
    this.email,
    this.notas,
    this.activo = true,
    this.totalInvertido = 0.0,
    this.totalRetornado = 0.0,
  });

  double get saldoPendiente => totalInvertido - totalRetornado;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'contacto': contacto,
    'telefono': telefono,
    'email': email,
    'notas': notas,
    'activo': activo,
    'totalInvertido': totalInvertido,
    'totalRetornado': totalRetornado,
  };

  factory InvestorEntity.fromJson(Map<String, dynamic> json) => InvestorEntity(
    id: json['id'].toString(),
    nombre: json['nombre'],
    contacto: json['contacto'],
    telefono: json['telefono'],
    email: json['email'],
    notas: json['notas'],
    activo: json['activo'] ?? true,
    totalInvertido: (json['total_invertido'] ?? 0.0).toDouble(),
    totalRetornado: (json['total_retornado'] ?? 0.0).toDouble(),
  );
}
