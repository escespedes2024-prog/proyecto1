class Miembro {
  final int? id;
  final String nombre;
  final String email;
  final String? telefono;
  final String? fNacimiento;
  final String estado;
  final String? direccion;
  final String? fechaIngreso;
  final String? sexo;

  Miembro({
    this.id,
    required this.nombre,
    required this.email,
    this.telefono,
    this.fNacimiento,
    this.estado = 'activo',
    this.direccion,
    this.fechaIngreso,
    this.sexo,
  });

  factory Miembro.fromJson(Map<String, dynamic> json) {
    return Miembro(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'],
      fNacimiento: json['f_nacimiento'],
      estado: json['estado'] ?? 'activo',
      direccion: json['direccion'],
      fechaIngreso: json['fecha_ingreso'],
      sexo: json['sexo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'f_nacimiento': fNacimiento,
      'estado': estado,
      'direccion': direccion,
      'fecha_ingreso': fechaIngreso,
      'sexo': sexo,
    };
  }
}
