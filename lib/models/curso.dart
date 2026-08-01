class Curso {
  final int? id;
  final String nombre;
  final String fInicio;
  final String? fFin;
  final int? cupoMax;
  final bool tienePago;
  final double? montoInscripcion;

  Curso({
    this.id,
    required this.nombre,
    required this.fInicio,
    this.fFin,
    this.cupoMax,
    this.tienePago = false,
    this.montoInscripcion,
  });

  factory Curso.fromJson(Map<String, dynamic> json) {
    return Curso(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      fInicio: json['f_inicio'] ?? '',
      fFin: json['f_fin'],
      cupoMax: json['cupo_max'],
      tienePago: json['tiene_pago'] == true || json['tiene_pago'] == 1 || json['tiene_pago'] == '1',
      montoInscripcion: double.tryParse(json['monto_inscripcion']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'f_inicio': fInicio,
      'f_fin': fFin,
      'cupo_max': cupoMax,
      'tiene_pago': tienePago ? 1 : 0,
      'monto_inscripcion': montoInscripcion,
    };
  }
}
