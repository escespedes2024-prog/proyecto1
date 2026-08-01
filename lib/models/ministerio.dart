class Ministerio {
  final int? id;
  final String nombre;
  final String? descripcion;
  final int? idLider;

  Ministerio({
    this.id,
    required this.nombre,
    this.descripcion,
    this.idLider,
  });

  factory Ministerio.fromJson(Map<String, dynamic> json) {
    return Ministerio(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      idLider: json['id_lider'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'id_lider': idLider,
    };
  }
}
