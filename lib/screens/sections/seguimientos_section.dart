import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/church_data_provider.dart';
import '../../models/seguimiento.dart';
import '../../models/actividad.dart';

class SeguimientosSection extends StatefulWidget {
  const SeguimientosSection({super.key});

  @override
  State<SeguimientosSection> createState() => _SeguimientosSectionState();
}

class _SeguimientosSectionState extends State<SeguimientosSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ChurchDataProvider>().fetchSeguimientos();
        context.read<ChurchDataProvider>().fetchActividades();
      }
    });
  }

  void _showFormDialog({Seguimiento? seguimiento}) {
    final isEdit = seguimiento != null;
    final fechaRegistroController = TextEditingController(
      text: seguimiento?.fechaRegistro ?? DateTime.now().toIso8601String().substring(0, 10),
    );
    final estadoController = TextEditingController(text: seguimiento?.estado ?? 'Planificada');
    final observacionController = TextEditingController(text: seguimiento?.observacion);
    final responsableController = TextEditingController(text: seguimiento?.responsable);
    double porcentajeAvance = seguimiento?.porcentajeAvance ?? 0.0;
    int? selectedActividadId = seguimiento?.idActividad;

    showDialog(
      context: context,
      builder: (ctx) {
        final actividades = context.read<ChurchDataProvider>().actividades;
        if (actividades.isEmpty) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1e1e2d),
            title: const Text('Error', style: TextStyle(color: Colors.white)),
            content: const Text('Primero debes registrar actividades para poder realizar un seguimiento.', style: TextStyle(color: Colors.grey)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              )
            ],
          );
        }

        selectedActividadId ??= actividades.first.id;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1e1e2d),
              title: Text(
                isEdit ? 'Editar Seguimiento' : 'Nuevo Seguimiento',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      dropdownColor: const Color(0xFF1e1e2d),
                      value: selectedActividadId,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Actividad',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                      items: actividades.map((a) {
                        return DropdownMenuItem<int>(
                          value: a.id,
                          child: Text(a.nombre, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            selectedActividadId = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: fechaRegistroController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Fecha de Registro (YYYY-MM-DD)',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: estadoController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Estado del Avance',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: responsableController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Responsable',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Porcentaje de Avance: ${porcentajeAvance.toInt()}%',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    Slider(
                      value: porcentajeAvance,
                      min: 0,
                      max: 100,
                      activeColor: const Color(0xFFd4af37),
                      inactiveColor: Colors.grey,
                      onChanged: (val) {
                        setStateDialog(() {
                          porcentajeAvance = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: observacionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Observación',
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
                    if (selectedActividadId == null || estadoController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Actividad y estado son obligatorios')),
                      );
                      return;
                    }

                    final newSeg = Seguimiento(
                      id: seguimiento?.id,
                      idActividad: selectedActividadId!,
                      fechaRegistro: fechaRegistroController.text.trim(),
                      estado: estadoController.text.trim(),
                      observacion: observacionController.text.trim().isEmpty ? null : observacionController.text.trim(),
                      responsable: responsableController.text.trim().isEmpty ? null : responsableController.text.trim(),
                      porcentajeAvance: porcentajeAvance,
                    );

                    final provider = context.read<ChurchDataProvider>();
                    bool ok;
                    if (isEdit) {
                      ok = await provider.updateSeguimiento(newSeg);
                    } else {
                      ok = await provider.createSeguimiento(newSeg);
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
                  child: Text(isEdit ? 'GUARDAR' : 'CREAR'),
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
          title: const Text('¿Eliminar seguimiento?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('¿Estás seguro de que deseas eliminar este seguimiento?', style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                final ok = await context.read<ChurchDataProvider>().deleteSeguimiento(id);
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Seguimiento eliminado' : 'No se pudo eliminar el seguimiento'),
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
          await context.read<ChurchDataProvider>().fetchSeguimientos();
          await context.read<ChurchDataProvider>().fetchActividades();
        },
        child: dataProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFd4af37)),
                ),
              )
            : dataProvider.seguimientos.isEmpty
                ? Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: const [
                        Center(
                          child: Text(
                            'No hay seguimientos registrados.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dataProvider.seguimientos.length,
                    itemBuilder: (ctx, index) {
                      final seg = dataProvider.seguimientos[index];
                      // Find activity
                      final act = dataProvider.actividades.firstWhere(
                        (a) => a.id == seg.idActividad,
                        orElse: () => Actividad(idMinisterio: 0, nombre: 'Desconocida', fecha: ''),
                      );

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
                            foregroundColor: const Color(0xFFd4af37),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: seg.porcentajeAvance / 100,
                                  strokeWidth: 3,
                                  backgroundColor: Colors.transparent,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFd4af37)),
                                ),
                                Text(
                                  '${seg.porcentajeAvance.toInt()}%',
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          title: Text(
                            act.nombre,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fecha: ${seg.fechaRegistro}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              Text('Avance: ${seg.estado}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              if (seg.responsable != null)
                                Text('Responsable: ${seg.responsable}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              if (seg.observacion != null)
                                Text('Obs: ${seg.observacion}', style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                onPressed: () => _showFormDialog(seguimiento: seg),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () {
                                  if (seg.id != null) {
                                    _confirmDelete(seg.id!);
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
