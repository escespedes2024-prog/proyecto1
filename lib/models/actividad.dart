class Actividad {
  final int? id;
  final int idMinisterio;
  final String nombre;
  final String fecha;
  final String? lugar;
  final String estado;
  final String? descripcion;

  Actividad({
    this.id,
    required this.idMinisterio,
    required this.nombre,
    required this.fecha,
    this.lugar,
    this.estado = 'planificada',
    this.descripcion,
  });

  factory Actividad.fromJson(Map<String, dynamic> json) {
    return Actividad(
      id: json['id'],
      idMinisterio: json['id_ministerio'] ?? 0,
      nombre: json['nombre'] ?? '',
      fecha: json['fecha'] ?? '',
      lugar: json['lugar'],
      estado: json['estado'] ?? 'planificada',
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'id_ministerio': idMinisterio,
      'nombre': nombre,
      'fecha': fecha,
      'lugar': lugar,
      'estado': estado,
      'descripcion': descripcion,
    };
  }
}
