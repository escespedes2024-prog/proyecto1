class Contrato {
  final int? id;
  final int idMiembro;
  final String? descripcion;
  final String fechaInicio;
  final String? fechaFin;
  final double? monto;
  final String estado;

  Contrato({
    this.id,
    required this.idMiembro,
    this.descripcion,
    required this.fechaInicio,
    this.fechaFin,
    this.monto,
    this.estado = 'activo',
  });

  factory Contrato.fromJson(Map<String, dynamic> json) {
    return Contrato(
      id: json['id'],
      idMiembro: json['id_miembro'] ?? 0,
      descripcion: json['descripcion'],
      fechaInicio: json['fecha_inicio'] ?? '',
      fechaFin: json['fecha_fin'],
      monto: double.tryParse(json['monto']?.toString() ?? ''),
      estado: json['estado'] ?? 'activo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'id_miembro': idMiembro,
      'descripcion': descripcion,
      'fecha_inicio': fechaInicio,
      'fecha_fin': fechaFin,
      'monto': monto,
      'estado': estado,
    };
  }
}
