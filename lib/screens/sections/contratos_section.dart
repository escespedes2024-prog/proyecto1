import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/church_data_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../models/contrato.dart';
import '../../models/miembro.dart';

class ContratosSection extends StatefulWidget {
  const ContratosSection({super.key});

  @override
  State<ContratosSection> createState() => _ContratosSectionState();
}

class _ContratosSectionState extends State<ContratosSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ChurchDataProvider>().fetchContratos();
        context.read<ClienteProvider>().fetchMiembros();
      }
    });
  }

  void _showFormDialog({Contrato? contrato}) {
    final isEdit = contrato != null;
    final descripcionController = TextEditingController(text: contrato?.descripcion);
    final fechaInicioController = TextEditingController(
      text: contrato?.fechaInicio ?? DateTime.now().toIso8601String().substring(0, 10),
    );
    final fechaFinController = TextEditingController(text: contrato?.fechaFin);
    final montoController = TextEditingController(text: contrato?.monto?.toString() ?? '');
    String estado = contrato?.estado ?? 'activo';
    int? selectedMiembroId = contrato?.idMiembro;

    showDialog(
      context: context,
      builder: (ctx) {
        final miembros = context.read<ClienteProvider>().miembro;
        if (miembros.isEmpty) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1e1e2d),
            title: const Text('Error', style: TextStyle(color: Colors.white)),
            content: const Text('Primero debes registrar miembros para poder crear un contrato.', style: TextStyle(color: Colors.grey)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              )
            ],
          );
        }

        selectedMiembroId ??= miembros.first.id;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1e1e2d),
              title: Text(
                isEdit ? 'Editar Contrato' : 'Nuevo Contrato de Servicio',
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
                        labelText: 'Miembro contratado',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                      items: miembros.map((m) {
                        return DropdownMenuItem<int>(
                          value: m.id,
                          child: Text(m.nombre, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            selectedMiembroId = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descripcionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Descripción del Contrato',
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
                        labelText: 'Monto Mensual / Total',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(color: Color(0xFFd4af37)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: fechaInicioController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Fecha de Inicio (YYYY-MM-DD)',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: fechaFinController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Fecha de Fin (YYYY-MM-DD)',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                        DropdownMenuItem(value: 'finalizado', child: Text('Finalizado')),
                        DropdownMenuItem(value: 'cancelado', child: Text('Cancelado')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            estado = val;
                          });
                        }
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
                    final monto = double.tryParse(montoController.text.trim());
                    if (selectedMiembroId == null) return;

                    final newCont = Contrato(
                      id: contrato?.id,
                      idMiembro: selectedMiembroId!,
                      descripcion: descripcionController.text.trim().isEmpty ? null : descripcionController.text.trim(),
                      fechaInicio: fechaInicioController.text.trim(),
                      fechaFin: fechaFinController.text.trim().isEmpty ? null : fechaFinController.text.trim(),
                      monto: monto,
                      estado: estado,
                    );

                    final provider = context.read<ChurchDataProvider>();
                    bool ok;
                    if (isEdit) {
                      ok = await provider.updateContrato(newCont);
                    } else {
                      ok = await provider.createContrato(newCont);
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
          title: const Text('¿Eliminar contrato?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('¿Estás seguro de que deseas eliminar este contrato?', style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                final ok = await context.read<ChurchDataProvider>().deleteContrato(id);
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Contrato eliminado' : 'No se pudo eliminar el contrato'),
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
          await context.read<ChurchDataProvider>().fetchContratos();
          await context.read<ClienteProvider>().fetchMiembros();
        },
        child: dataProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFd4af37)),
                ),
              )
            : dataProvider.contratos.isEmpty
                ? Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: const [
                        Center(
                          child: Text(
                            'No hay contratos registrados.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dataProvider.contratos.length,
                    itemBuilder: (ctx, index) {
                      final c = dataProvider.contratos[index];
                      // Find member
                      final miembro = clienteProvider.miembro.firstWhere(
                        (mb) => mb.id == c.idMiembro,
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
                            child: const Icon(Icons.description_outlined),
                          ),
                          title: Text(
                            miembro.nombre,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (c.descripcion != null && c.descripcion!.isNotEmpty)
                                Text(c.descripcion!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              Text('Inicio: ${c.fechaInicio} ${c.fechaFin != null ? "- Fin: ${c.fechaFin}" : ""}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              if (c.monto != null)
                                Text('Monto: \$${c.monto}', style: const TextStyle(color: Color(0xFFd4af37), fontSize: 12, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text(
                                c.estado.toUpperCase(),
                                style: TextStyle(
                                  color: c.estado == 'activo' ? Colors.green : Colors.red,
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
                                onPressed: () => _showFormDialog(contrato: c),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () {
                                  if (c.id != null) {
                                    _confirmDelete(c.id!);
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
