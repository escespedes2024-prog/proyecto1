import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/church_data_provider.dart';
import '../../models/egreso.dart';
import '../../models/ministerio.dart';

class EgresosSection extends StatefulWidget {
  const EgresosSection({super.key});

  @override
  State<EgresosSection> createState() => _EgresosSectionState();
}

class _EgresosSectionState extends State<EgresosSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ChurchDataProvider>().fetchEgresos();
        context.read<ChurchDataProvider>().fetchMinisterios();
        context.read<ChurchDataProvider>().fetchContratos();
      }
    });
  }

  void _showFormDialog({Egreso? egreso}) {
    final isEdit = egreso != null;
    final tipoEgresoController = TextEditingController(text: egreso?.tipoEgreso ?? 'Servicio');
    final descripcionController = TextEditingController(text: egreso?.descripcion);
    final montoController = TextEditingController(text: egreso?.monto.toString() ?? '');
    final fechaController = TextEditingController(
      text: egreso?.fecha ?? DateTime.now().toIso8601String().substring(0, 10),
    );
    final responsableController = TextEditingController(text: egreso?.responsable);
    final comprobanteController = TextEditingController(text: egreso?.comprobante);
    int? selectedMinisterioId = egreso?.idMinisterio;
    int? selectedContratoId = egreso?.idContrato;

    showDialog(
      context: context,
      builder: (ctx) {
        final ministerios = context.read<ChurchDataProvider>().ministerios;
        final contratos = context.read<ChurchDataProvider>().contratos;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1e1e2d),
              title: Text(
                isEdit ? 'Editar Egreso' : 'Registrar Egreso / Gasto',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tipoEgresoController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Egreso',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: montoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Monto del Gasto',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(color: Color(0xFFd4af37)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: fechaController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Fecha (YYYY-MM-DD)',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: responsableController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Responsable del Gasto',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int?>(
                      dropdownColor: const Color(0xFF1e1e2d),
                      value: selectedMinisterioId,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Ministerio Asociado (Opcional)',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Ninguno', style: TextStyle(color: Colors.grey)),
                        ),
                        ...ministerios.map((m) {
                          return DropdownMenuItem<int?>(
                            value: m.id,
                            child: Text(m.nombre, style: const TextStyle(color: Colors.white)),
                          );
                        })
                      ],
                      onChanged: (val) {
                        setStateDialog(() {
                          selectedMinisterioId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int?>(
                      dropdownColor: const Color(0xFF1e1e2d),
                      value: selectedContratoId,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Contrato Asociado (Opcional)',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Ninguno', style: TextStyle(color: Colors.grey)),
                        ),
                        ...contratos.map((c) {
                          return DropdownMenuItem<int?>(
                            value: c.id,
                            child: Text('Contrato #${c.id} - \$${c.monto}', style: const TextStyle(color: Colors.white)),
                          );
                        })
                      ],
                      onChanged: (val) {
                        setStateDialog(() {
                          selectedContratoId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descripcionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Descripción / Justificación',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: comprobanteController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Nº Comprobante / Recibo',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFd4af37),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    final monto = double.tryParse(montoController.text.trim());
                    if (monto == null || tipoEgresoController.text.trim().isEmpty || responsableController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('El tipo, monto y responsable son obligatorios')),
                      );
                      return;
                    }

                    final newEg = Egreso(
                      id: egreso?.id,
                      idMinisterio: selectedMinisterioId,
                      idContrato: selectedContratoId,
                      tipoEgreso: tipoEgresoController.text.trim(),
                      descripcion: descripcionController.text.trim().isEmpty ? null : descripcionController.text.trim(),
                      monto: monto,
                      fecha: fechaController.text.trim(),
                      responsable: responsableController.text.trim(),
                      comprobante: comprobanteController.text.trim().isEmpty ? null : comprobanteController.text.trim(),
                    );

                    final provider = context.read<ChurchDataProvider>();
                    bool ok;
                    if (isEdit) {
                      ok = await provider.updateEgreso(newEg);
                    } else {
                      ok = await provider.createEgreso(newEg);
                    }

                    if (mounted) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? 'Operación exitosa' : 'Ocurrió un error en el servidor'),
                          backgroundColor: ok ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(isEdit ? 'GUARDAR' : 'REGISTRAR'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1e1e2d),
          title: const Text('¿Eliminar egreso?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('¿Estás seguro de que deseas eliminar este registro de egreso?', style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                final ok = await context.read<ChurchDataProvider>().deleteEgreso(id);
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Egreso eliminado' : 'No se pudo eliminar el egreso'),
                      backgroundColor: ok ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('ELIMINAR'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<ChurchDataProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFd4af37),
        foregroundColor: Colors.black,
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<ChurchDataProvider>().fetchEgresos();
          await context.read<ChurchDataProvider>().fetchMinisterios();
          await context.read<ChurchDataProvider>().fetchContratos();
        },
        child: dataProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFd4af37)),
                ),
              )
            : dataProvider.egresos.isEmpty
                ? Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: const [
                        Center(
                          child: Text(
                            'No hay egresos registrados.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dataProvider.egresos.length,
                    itemBuilder: (ctx, index) {
                      final eg = dataProvider.egresos[index];
                      // Find ministry
                      Ministerio? min;
                      if (eg.idMinisterio != null) {
                        try {
                          min = dataProvider.ministerios.firstWhere((m) => m.id == eg.idMinisterio);
                        } catch (_) {
                          min = null;
                        }
                      }

                      return Card(
                        color: const Color(0xFF1e1e2d),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFF2b2b40)),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF2b2b40),
                            foregroundColor: Colors.redAccent,
                            child: const Icon(Icons.trending_down),
                          ),
                          title: Text(
                            'Monto: \$${eg.monto}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tipo: ${eg.tipoEgreso}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              Text('Responsable: ${eg.responsable}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              Text('Fecha: ${eg.fecha}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              if (min != null)
                                Text('Ministerio: ${min.nombre}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              if (eg.comprobante != null)
                                Text('Comprobante: Nº ${eg.comprobante}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              if (eg.descripcion != null && eg.descripcion!.isNotEmpty)
                                Text(eg.descripcion!, style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                onPressed: () => _showFormDialog(egreso: eg),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () {
                                  if (eg.id != null) {
                                    _confirmDelete(eg.id!);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
