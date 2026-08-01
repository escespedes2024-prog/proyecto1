import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/church_data_provider.dart';
import '../../models/sesion.dart';
import '../../models/curso.dart';

class SesionesSection extends StatefulWidget {
  const SesionesSection({super.key});

  @override
  State<SesionesSection> createState() => _SesionesSectionState();
}

class _SesionesSectionState extends State<SesionesSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ChurchDataProvider>().fetchSesiones();
        context.read<ChurchDataProvider>().fetchCursos();
      }
    });
  }

  void _showFormDialog({Sesion? sesion}) {
    final isEdit = sesion != null;
    final fechaController = TextEditingController(
      text: sesion?.fecha ?? DateTime.now().toIso8601String().substring(0, 10),
    );
    final horaController = TextEditingController(text: sesion?.hora ?? '19:00:00');
    final temaController = TextEditingController(text: sesion?.tema);
    final observacionController = TextEditingController(text: sesion?.observacion);
    int? selectedCursoId = sesion?.idCurso;

    showDialog(
      context: context,
      builder: (ctx) {
        final cursos = context.read<ChurchDataProvider>().cursos;
        if (cursos.isEmpty) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1e1e2d),
            title: const Text('Error', style: TextStyle(color: Colors.white)),
            content: const Text('Primero debes registrar cursos para poder programar una sesión.', style: TextStyle(color: Colors.grey)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              )
            ],
          );
        }

        selectedCursoId ??= cursos.first.id;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1e1e2d),
              title: Text(
                isEdit ? 'Editar Sesión' : 'Nueva Sesión',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      dropdownColor: const Color(0xFF1e1e2d),
                      value: selectedCursoId,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Curso Académico',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                      items: cursos.map((c) {
                        return DropdownMenuItem<int>(
                          value: c.id,
                          child: Text(c.nombre, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            selectedCursoId = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: temaController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Tema de la Sesión',
                        labelStyle: TextStyle(color: Colors.grey),
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
                      controller: horaController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Hora (HH:MM:SS)',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: observacionController,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Observaciones / Tarea',
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
                    if (temaController.text.trim().isEmpty || selectedCursoId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('El tema y el curso son obligatorios')),
                      );
                      return;
                    }

                    final newSesion = Sesion(
                      id: sesion?.id,
                      idCurso: selectedCursoId!,
                      fecha: fechaController.text.trim(),
                      hora: horaController.text.trim().isEmpty ? null : horaController.text.trim(),
                      tema: temaController.text.trim(),
                      observacion: observacionController.text.trim().isEmpty ? null : observacionController.text.trim(),
                    );

                    final provider = context.read<ChurchDataProvider>();
                    bool ok;
                    if (isEdit) {
                      ok = await provider.updateSesion(newSesion);
                    } else {
                      ok = await provider.createSesion(newSesion);
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
          title: const Text('¿Eliminar sesión?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('¿Estás seguro de que deseas eliminar esta sesión?', style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                final ok = await context.read<ChurchDataProvider>().deleteSesion(id);
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Sesión eliminada' : 'No se pudo eliminar la sesión'),
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
          await context.read<ChurchDataProvider>().fetchSesiones();
          await context.read<ChurchDataProvider>().fetchCursos();
        },
        child: dataProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFd4af37)),
                ),
              )
            : dataProvider.sesiones.isEmpty
                ? Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: const [
                        Center(
                          child: Text(
                            'No hay sesiones registradas.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dataProvider.sesiones.length,
                    itemBuilder: (ctx, index) {
                      final s = dataProvider.sesiones[index];
                      // Find course
                      final cur = dataProvider.cursos.firstWhere(
                        (c) => c.id == s.idCurso,
                        orElse: () => Curso(nombre: 'Desconocido', fInicio: ''),
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
                            child: const Icon(Icons.class_outlined),
                          ),
                          title: Text(
                            s.tema ?? 'Sesión sin tema',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Curso: ${cur.nombre}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              Text('Fecha: ${s.fecha} a las ${s.hora ?? ""}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              if (s.observacion != null && s.observacion!.isNotEmpty)
                                Text('Obs: ${s.observacion!}', style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                onPressed: () => _showFormDialog(sesion: s),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () {
                                  if (s.id != null) {
                                    _confirmDelete(s.id!);
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
