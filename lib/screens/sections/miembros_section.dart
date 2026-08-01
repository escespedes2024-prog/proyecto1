import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cliente_provider.dart';
import '../../models/miembro.dart';

class MiembrosSection extends StatefulWidget {
  const MiembrosSection({super.key});

  @override
  State<MiembrosSection> createState() => _MiembrosSectionState();
}

class _MiembrosSectionState extends State<MiembrosSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ClienteProvider>().fetchMiembros();
      }
    });
  }

  void _showFormDialog({Miembro? miembro}) {
    final isEdit = miembro != null;
    final nombreController = TextEditingController(text: miembro?.nombre);
    final emailController = TextEditingController(text: miembro?.email);
    final telefonoController = TextEditingController(text: miembro?.telefono);
    final fNacimientoController = TextEditingController(text: miembro?.fNacimiento);
    final direccionController = TextEditingController(text: miembro?.direccion);
    final fechaIngresoController = TextEditingController(
      text: miembro?.fechaIngreso ?? DateTime.now().toIso8601String().substring(0, 10),
    );
    String estado = miembro?.estado ?? 'activo';
    String? sexo = miembro?.sexo ?? 'M';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1e1e2d),
              title: Text(
                isEdit ? 'Editar Miembro' : 'Nuevo Miembro',
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
                        labelText: 'Nombre Completo',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Correo Electrónico',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    TextField(
                      controller: telefonoController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    TextField(
                      controller: fNacimientoController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Fecha Nacimiento (YYYY-MM-DD)',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF1e1e2d),
                      value: estado,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'activo', child: Text('Activo')),
                        DropdownMenuItem(value: 'inactivo', child: Text('Inactivo')),
                        DropdownMenuItem(value: 'visita', child: Text('Visita')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            estado = val;
                          });
                        }
                      },
                    ),
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF1e1e2d),
                      value: sexo,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Sexo',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'M', child: Text('Masculino')),
                        DropdownMenuItem(value: 'F', child: Text('Femenino')),
                        DropdownMenuItem(value: 'otro', child: Text('Otro')),
                      ],
                      onChanged: (val) {
                        setStateDialog(() {
                          sexo = val;
                        });
                      },
                    ),
                    TextField(
                      controller: direccionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    TextField(
                      controller: fechaIngresoController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Fecha Ingreso (YYYY-MM-DD)',
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
                    if (nombreController.text.trim().isEmpty || emailController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nombre y correo son obligatorios')),
                      );
                      return;
                    }

                    final newMiembro = Miembro(
                      id: miembro?.id,
                      nombre: nombreController.text.trim(),
                      email: emailController.text.trim(),
                      telefono: telefonoController.text.isEmpty ? null : telefonoController.text.trim(),
                      fNacimiento: fNacimientoController.text.isEmpty ? null : fNacimientoController.text.trim(),
                      estado: estado,
                      direccion: direccionController.text.isEmpty ? null : direccionController.text.trim(),
                      fechaIngreso: fechaIngresoController.text.isEmpty ? null : fechaIngresoController.text.trim(),
                      sexo: sexo,
                    );

                    final provider = context.read<ClienteProvider>();
                    bool ok;
                    if (isEdit) {
                      ok = await provider.updateMiembro(newMiembro);
                    } else {
                      ok = await provider.createMiembro(newMiembro);
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
          title: const Text('¿Eliminar miembro?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('¿Estás seguro de que deseas eliminar este miembro?', style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                final ok = await context.read<ClienteProvider>().deleteMiembro(id);
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Miembro eliminado' : 'No se pudo eliminar el miembro'),
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
        onRefresh: () => context.read<ClienteProvider>().fetchMiembros(),
        child: clienteProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFd4af37)),
                ),
              )
            : clienteProvider.miembro.isEmpty
                ? Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: const [
                        Center(
                          child: Text(
                            'No hay miembros registrados.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: clienteProvider.miembro.length,
                    itemBuilder: (ctx, index) {
                      final m = clienteProvider.miembro[index];
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
                            child: Text(
                              m.nombre.isNotEmpty ? m.nombre[0].toUpperCase() : 'M',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            m.nombre,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              if (m.telefono != null)
                                Text('Tel: ${m.telefono}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              Text('Estado: ${m.estado}', style: TextStyle(
                                color: m.estado == 'activo' ? Colors.green : Colors.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.bold
                              )),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                onPressed: () => _showFormDialog(miembro: m),
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
