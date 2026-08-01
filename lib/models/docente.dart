class Docente {
  final int? id;
  final int idMiembro;
  final String? especialidad;
  final String? titulo;
  final bool activo;

  Docente({
    this.id,
    required this.idMiembro,
    this.especialidad,
    this.titulo,
    this.activo = true,
  });

  factory Docente.fromJson(Map<String, dynamic> json) {
    return Docente(
      id: json['id'],
      idMiembro: json['id_miembro'] ?? 0,
      especialidad: json['especialidad'],
      titulo: json['titulo'],
      activo: json['activo'] == true || json['activo'] == 1 || json['activo'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'id_miembro': idMiembro,
      'especialidad': especialidad,
      'titulo': titulo,
      'activo': activo ? 1 : 0,
    };
  }
}
