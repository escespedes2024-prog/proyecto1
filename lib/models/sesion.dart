class Sesion {
  final int? id;
  final int idCurso;
  final String fecha;
  final String? hora;
  final String? tema;
  final String? observacion;

  Sesion({
    this.id,
    required this.idCurso,
    required this.fecha,
    this.hora,
    this.tema,
    this.observacion,
  });

  factory Sesion.fromJson(Map<String, dynamic> json) {
    return Sesion(
      id: json['id'],
      idCurso: json['id_curso'] ?? 0,
      fecha: json['fecha'] ?? '',
      hora: json['hora'],
      tema: json['tema'],
      observacion: json['observacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'id_curso': idCurso,
      'fecha': fecha,
      'hora': hora,
      'tema': tema,
      'observacion': observacion,
    };
  }
}
