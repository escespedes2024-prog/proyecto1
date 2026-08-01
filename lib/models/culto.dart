class Culto {
  final int? idCulto;
  final String nombre;
  final String diaSemana;
  final String hora;
  final String? descripcion;

  Culto({
    this.idCulto,
    required this.nombre,
    required this.diaSemana,
    required this.hora,
    this.descripcion,
  });

  factory Culto.fromJson(Map<String, dynamic> json) {
    return Culto(
      idCulto: json['id_culto'],
      nombre: json['nombre'] ?? '',
      diaSemana: json['dia_semana'] ?? '',
      hora: json['hora'] ?? '',
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idCulto != null) 'id_culto': idCulto,
      'nombre': nombre,
      'dia_semana': diaSemana,
      'hora': hora,
      'descripcion': descripcion,
    };
  }
}
