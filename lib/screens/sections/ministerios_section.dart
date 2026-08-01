import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/church_data_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../models/ministerio.dart';
import '../../models/miembro.dart';

class MinisteriosSection extends StatefulWidget {
  const MinisteriosSection({super.key});

  @override
  State<MinisteriosSection> createState() => _MinisteriosSectionState();
}

class _MinisteriosSectionState extends State<MinisteriosSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ChurchDataProvider>().fetchMinisterios();
        context.read<ClienteProvider>().fetchMiembros();
      }
    });
  }

  void _showFormDialog({Ministerio? ministerio}) {
    final isEdit = ministerio != null;
    final nombreController = TextEditingController(text: ministerio?.nombre);
    final descripcionController = TextEditingController(text: ministerio?.descripcion);
    int? selectedLiderId = ministerio?.idLider;

    showDialog(
      context: context,
      builder: (ctx) {
        final miembros = context.read<ClienteProvider>().miembro;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1e1e2d),
              title: Text(
                isEdit ? 'Editar Ministerio' : 'Nuevo Ministerio',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Ministerio',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descripcionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int?>(
                      dropdownColor: const Color(0xFF1e1e2d),
                      value: selectedLiderId,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Líder del Ministerio',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Sin Líder Asignado', style: TextStyle(color: Colors.grey)),
                        ),
                        ...miembros.map((m) {
                          return DropdownMenuItem<int?>(
                            value: m.id,
                            child: Text(m.nombre, style: const TextStyle(color: Colors.white)),
                          );
                        })
                      ],
                      onChanged: (val) {
                        setStateDialog(() {
                          selectedLiderId = val;
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
                    if (nombreController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('El nombre del ministerio es obligatorio')),
                      );
                      return;
                    }

                    final newMin = Ministerio(
                      id: ministerio?.id,
                      nombre: nombreController.text.trim(),
                      descripcion: descripcionController.text.trim().isEmpty ? null : descripcionController.text.trim(),
                      idLider: selectedLiderId,
                    );

                    final provider = context.read<ChurchDataProvider>();
                    bool ok;
                    if (isEdit) {
                      ok = await provider.updateMinisterio(newMin);
                    } else {
                      ok = await provider.createMinisterio(newMin);
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
          title: const Text('¿Eliminar ministerio?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('¿Estás seguro de que deseas eliminar este ministerio?', style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                final ok = await context.read<ChurchDataProvider>().deleteMinisterio(id);
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Ministerio eliminado' : 'No se pudo eliminar el ministerio'),
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
          await context.read<ChurchDataProvider>().fetchMinisterios();
          await context.read<ClienteProvider>().fetchMiembros();
        },
        child: dataProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFd4af37)),
                ),
              )
            : dataProvider.ministerios.isEmpty
                ? Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: const [
                        Center(
                          child: Text(
                            'No hay ministerios registrados.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dataProvider.ministerios.length,
                    itemBuilder: (ctx, index) {
                      final m = dataProvider.ministerios[index];
                      // Find leader member
                      final lider = m.idLider != null
                          ? clienteProvider.miembro.firstWhere(
                              (mb) => mb.id == m.idLider,
                              orElse: () => Miembro(nombre: 'Desconocido', email: '', sexo: 'M'),
                            )
                          : null;

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
                            child: const Icon(Icons.group_work_outlined),
                          ),
                          title: Text(
                            m.nombre,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (m.descripcion != null && m.descripcion!.isNotEmpty)
                                Text(m.descripcion!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                'Líder: ${lider?.nombre ?? "Sin asignar"}',
                                style: const TextStyle(color: Color(0xFFd4af37), fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                onPressed: () => _showFormDialog(ministerio: m),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () {
                                  if (m.id != null) {
                                    _confirmDelete(m.id!);
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
