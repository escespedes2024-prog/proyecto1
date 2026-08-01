class Egreso {
  final int? id;
  final int? idMinisterio;
  final int? idContrato;
  final String tipoEgreso;
  final String? descripcion;
  final double monto;
  final String fecha;
  final String responsable;
  final String? comprobante;

  Egreso({
    this.id,
    this.idMinisterio,
    this.idContrato,
    required this.tipoEgreso,
    this.descripcion,
    required this.monto,
    required this.fecha,
    required this.responsable,
    this.comprobante,
  });

  factory Egreso.fromJson(Map<String, dynamic> json) {
    return Egreso(
      id: json['id'],
      idMinisterio: json['id_ministerio'],
      idContrato: json['id_contrato'],
      tipoEgreso: json['tipo_egreso'] ?? '',
      descripcion: json['descripcion'],
      monto: double.tryParse(json['monto']?.toString() ?? '0') ?? 0.0,
      fecha: json['fecha'] ?? '',
      responsable: json['responsable'] ?? '',
      comprobante: json['comprobante'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'id_ministerio': idMinisterio,
      'id_contrato': idContrato,
      'tipo_egreso': tipoEgreso,
      'descripcion': descripcion,
      'monto': monto,
      'fecha': fecha,
      'responsable': responsable,
      'comprobante': comprobante,
    };
  }
}
