class Seguimiento {
  final int? id;
  final int idActividad;
  final String fechaRegistro;
  final String estado;
  final String? observacion;
  final String? responsable;
  final double porcentajeAvance;

  Seguimiento({
    this.id,
    required this.idActividad,
    required this.fechaRegistro,
    required this.estado,
    this.observacion,
    this.responsable,
    this.porcentajeAvance = 0.0,
  });

  factory Seguimiento.fromJson(Map<String, dynamic> json) {
    return Seguimiento(
      id: json['id'],
      idActividad: json['id_actividad'] ?? 0,
      fechaRegistro: json['fecha_registro'] ?? '',
      estado: json['estado'] ?? '',
      observacion: json['observacion'],
      responsable: json['responsable'],
      porcentajeAvance: double.tryParse(json['porcentaje_avance']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'id_actividad': idActividad,
      'fecha_registro': fechaRegistro,
      'estado': estado,
      'observacion': observacion,
      'responsable': responsable,
      'porcentaje_avance': porcentajeAvance,
    };
  }
}
