class Ingreso {
  final int? id;
  final int idCulto;
  final double montoTotal;
  final String fecha;
  final String? tipo;
  final String? metodoPago;

  Ingreso({
    this.id,
    required this.idCulto,
    required this.montoTotal,
    required this.fecha,
    this.tipo,
    this.metodoPago = 'efectivo',
  });

  factory Ingreso.fromJson(Map<String, dynamic> json) {
    return Ingreso(
      id: json['id'],
      idCulto: json['id_culto'] ?? 0,
      montoTotal: double.tryParse(json['monto_total']?.toString() ?? '0') ?? 0.0,
      fecha: json['fecha'] ?? '',
      tipo: json['tipo'],
      metodoPago: json['metodo_pago'] ?? 'efectivo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'id_culto': idCulto,
      'monto_total': montoTotal,
      'fecha': fecha,
      'tipo': tipo,
      'metodo_pago': metodoPago,
    };
  }
}
