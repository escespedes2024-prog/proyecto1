import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/church_data_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../models/docente.dart';
import '../../models/miembro.dart';

class DocentesSection extends StatefulWidget {
  const DocentesSection({super.key});

  @override
  State<DocentesSection> createState() => _DocentesSectionState();
}

class _DocentesSectionState extends State<DocentesSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ChurchDataProvider>().fetchDocentes();
        context.read<ClienteProvider>().fetchMiembros();
      }
    });
  }

  void _showFormDialog({Docente? docente}) {
    final isEdit = docente != null;
    final especialidadController = TextEditingController(text: docente?.especialidad);
    final tituloController = TextEditingController(text: docente?.titulo);
    bool activo = docente?.activo ?? true;
    int? selectedMiembroId = docente?.idMiembro;

    showDialog(
      context: context,
      builder: (ctx) {
        final miembros = context.read<ClienteProvider>().miembro;
        if (miembros.isEmpty) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1e1e2d),
            title: const Text('Error', style: TextStyle(color: Colors.white)),
            content: const Text('Primero debes registrar miembros para poder asignar un docente.', style: TextStyle(color: Colors.grey)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              )
            ],
          );
        }

        // Set default selected member if null
        selectedMiembroId ??= miembros.first.id;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1e1e2d),
              title: Text(
                isEdit ? 'Editar Docente' : 'Nuevo Docente',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      dropdownColor: const Color(0xFF1e1e2d),
                      value: selectedMiembroId,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Miembro / Persona',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                      items: miembros.map((m) {
                        return DropdownMenuItem<int>(
                          value: m.id,
                          child: Text(m.nombre, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: isEdit
                          ? null // Cannot change the member linked to this teacher after creation
                          : (val) {
                              if (val != null) {
                                setStateDialog(() {
                                  selectedMiembroId = val;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: especialidadController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Especialidad',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: tituloController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Título / Grado Académico',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      activeColor: const Color(0xFFd4af37),
                      title: const Text('Docente Activo', style: TextStyle(color: Colors.white, fontSize: 14)),
                      value: activo,
                      onChanged: (val) {
                        setStateDialog(() {
                          activo = val;
                        });
                      },
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
                    if (selectedMiembroId == null) return;

                    final newDocente = Docente(
                      id: docente?.id,
                      idMiembro: selectedMiembroId!,
                      especialidad: especialidadController.text.trim(),
                      titulo: tituloController.text.trim(),
                      activo: activo,
                    );

                    final provider = context.read<ChurchDataProvider>();
                    bool ok;
                    if (isEdit) {
                      ok = await provider.updateDocente(newDocente);
                    } else {
                      ok = await provider.createDocente(newDocente);
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
          title: const Text('¿Eliminar docente?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('¿Estás seguro de que deseas eliminar este docente?', style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                final ok = await context.read<ChurchDataProvider>().deleteDocente(id);
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Docente eliminado' : 'No se pudo eliminar el docente'),
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
    final clienteProvider = context.watch<ClienteProvider>();

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
          await context.read<ChurchDataProvider>().fetchDocentes();
          await context.read<ClienteProvider>().fetchMiembros();
        },
        child: dataProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFd4af37)),
                ),
              )
            : dataProvider.docentes.isEmpty
                ? Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: const [
                        Center(
                          child: Text(
                            'No hay docentes registrados.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dataProvider.docentes.length,
                    itemBuilder: (ctx, index) {
                      final d = dataProvider.docentes[index];
                      // Find matching member name
                      final miembro = clienteProvider.miembro.firstWhere(
                        (m) => m.id == d.idMiembro,
                        orElse: () => Miembro(nombre: 'Desconocido', email: '', sexo: 'M'),
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
                            child: const Icon(Icons.school),
                          ),
                          title: Text(
                            miembro.nombre,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (d.titulo != null && d.titulo!.isNotEmpty)
                                Text('Título: ${d.titulo}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              if (d.especialidad != null && d.especialidad!.isNotEmpty)
                                Text('Especialidad: ${d.especialidad}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                d.activo ? 'ACTIVO' : 'INACTIVO',
                                style: TextStyle(
                                  color: d.activo ? Colors.green : Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                onPressed: () => _showFormDialog(docente: d),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () {
                                  if (d.id != null) {
                                    _confirmDelete(d.id!);
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
