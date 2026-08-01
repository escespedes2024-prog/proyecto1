import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/church_data_provider.dart';
import '../../models/ingreso.dart';
import '../../models/culto.dart';

class IngresosSection extends StatefulWidget {
  const IngresosSection({super.key});

  @override
  State<IngresosSection> createState() => _IngresosSectionState();
}

class _IngresosSectionState extends State<IngresosSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ChurchDataProvider>().fetchIngresos();
        context.read<ChurchDataProvider>().fetchCultos();
      }
    });
  }

  void _showFormDialog({Ingreso? ingreso}) {
    final isEdit = ingreso != null;
    final montoController = TextEditingController(text: ingreso?.montoTotal.toString() ?? '');
    final fechaController = TextEditingController(
      text: ingreso?.fecha ?? DateTime.now().toIso8601String().substring(0, 10),
    );
    final tipoController = TextEditingController(text: ingreso?.tipo ?? 'Ofrenda');
    String metodoPago = ingreso?.metodoPago ?? 'efectivo';
    int? selectedCultoId = ingreso?.idCulto;

    showDialog(
      context: context,
      builder: (ctx) {
        final cultos = context.read<ChurchDataProvider>().cultos;
        if (cultos.isEmpty) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1e1e2d),
            title: const Text('Error', style: TextStyle(color: Colors.white)),
            content: const Text('Primero debes registrar cultos para poder registrar un ingreso.', style: TextStyle(color: Colors.grey)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              )
            ],
          );
        }

        selectedCultoId ??= cultos.first.idCulto;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1e1e2d),
              title: Text(
                isEdit ? 'Editar Ingreso' : 'Registrar Ingreso / Ofrenda',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      dropdownColor: const Color(0xFF1e1e2d),
                      value: selectedCultoId,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Culto / Servicio',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                      items: cultos.map((c) {
                        return DropdownMenuItem<int>(
                          value: c.idCulto,
                          child: Text(c.nombre, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            selectedCultoId = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: montoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Monto Total Recaudado',
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
                      controller: tipoController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Ingreso (ej. Diezmo, Ofrenda)',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFd4af37))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF1e1e2d),
                      value: metodoPago,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Método de Pago',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'efectivo', child: Text('Efectivo')),
                        DropdownMenuItem(value: 'transferencia', child: Text('Transferencia')),
                        DropdownMenuItem(value: 'otro', child: Text('Otro')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            metodoPago = val;
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
                    if (monto == null || selectedCultoId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('El monto y el culto son obligatorios')),
                      );
                      return;
                    }

                    final newIng = Ingreso(
                      id: ingreso?.id,
                      idCulto: selectedCultoId!,
                      montoTotal: monto,
                      fecha: fechaController.text.trim(),
                      tipo: tipoController.text.trim().isEmpty ? null : tipoController.text.trim(),
                      metodoPago: metodoPago,
                    );

                    final provider = context.read<ChurchDataProvider>();
                    bool ok;
                    if (isEdit) {
                      ok = await provider.updateIngreso(newIng);
                    } else {
                      ok = await provider.createIngreso(newIng);
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
          title: const Text('¿Eliminar ingreso?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('¿Estás seguro de que deseas eliminar este registro de ingreso?', style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                final ok = await context.read<ChurchDataProvider>().deleteIngreso(id);
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Ingreso eliminado' : 'No se pudo eliminar el ingreso'),
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
          await context.read<ChurchDataProvider>().fetchIngresos();
          await context.read<ChurchDataProvider>().fetchCultos();
        },
        child: dataProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFd4af37)),
                ),
              )
            : dataProvider.ingresos.isEmpty
                ? Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: const [
                        Center(
                          child: Text(
                            'No hay ingresos registrados.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dataProvider.ingresos.length,
                    itemBuilder: (ctx, index) {
                      final i = dataProvider.ingresos[index];
                      // Find culto
                      final cul = dataProvider.cultos.firstWhere(
                        (c) => c.idCulto == i.idCulto,
                        orElse: () => Culto(nombre: 'Desconocido', diaSemana: '', hora: ''),
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
                            foregroundColor: Colors.greenAccent,
                            child: const Icon(Icons.trending_up),
                          ),
                          title: Text(
                            'Monto: \$${i.montoTotal}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Culto: ${cul.nombre}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              Text('Fecha: ${i.fecha} (${i.metodoPago?.toUpperCase()})', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              if (i.tipo != null && i.tipo!.isNotEmpty)
                                Text('Tipo: ${i.tipo!}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                onPressed: () => _showFormDialog(ingreso: i),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () {
                                  if (i.id != null) {
                                    _confirmDelete(i.id!);
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
