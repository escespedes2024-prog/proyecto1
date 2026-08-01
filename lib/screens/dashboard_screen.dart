import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cliente_provider.dart';
import '../providers/church_data_provider.dart';
import 'sections/miembros_section.dart';
import 'sections/docentes_section.dart';
import 'sections/ministerios_section.dart';
import 'sections/actividades_section.dart';
import 'sections/seguimientos_section.dart';
import 'sections/cursos_section.dart';
import 'sections/sesiones_section.dart';
import 'sections/cultos_section.dart';
import 'sections/ingresos_section.dart';
import 'sections/contratos_section.dart';
import 'sections/egresos_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _currentSection = 'dashboard';

  @override
  void initState() {
    super.initState();
    // Pre-cargar datos del servidor
    Future.microtask(() {
      if (mounted) {
        context.read<ClienteProvider>().fetchMiembros();
        final dp = context.read<ChurchDataProvider>();
        dp.fetchCursos();
        dp.fetchSesiones();
        dp.fetchMinisterios();
        dp.fetchCultos();
        dp.fetchIngresos();
        dp.fetchEgresos();
        dp.fetchDocentes();
        dp.fetchActividades();
        dp.fetchSeguimientos();
        dp.fetchContratos();
      }
    });
  }

  Widget _buildBody() {
    switch (_currentSection) {
      case 'miembros':
        return const MiembrosSection();
      case 'docentes':
        return const DocentesSection();
      case 'ministerios':
        return const MinisteriosSection();
      case 'actividades':
        return const ActividadesSection();
      case 'seguimientos':
        return const SeguimientosSection();
      case 'cursos':
        return const CursosSection();
      case 'sesiones':
        return const SesionesSection();
      case 'cultos':
        return const CultosSection();
      case 'ingresos':
        return const IngresosSection();
      case 'contratos':
        return const ContratosSection();
      case 'egresos':
        return const EgresosSection();
      case 'dashboard':
      default:
        return _buildStatsDashboard();
    }
  }

  String _getSectionTitle() {
    switch (_currentSection) {
      case 'miembros':
        return 'Administración de Miembros';
      case 'docentes':
        return 'Registro de Docentes';
      case 'ministerios':
        return 'Ministerios de la Iglesia';
      case 'actividades':
        return 'Actividades Programadas';
      case 'seguimientos':
        return 'Avances de Actividades';
      case 'cursos':
        return 'Cursos Académicos';
      case 'sesiones':
        return 'Sesiones de Clase';
      case 'cultos':
        return 'Cultos y Servicios';
      case 'ingresos':
        return 'Ingresos y Ofrendas';
      case 'contratos':
        return 'Contratos de Servicio';
      case 'egresos':
        return 'Egresos y Gastos';
      case 'dashboard':
      default:
        return 'Panel Principal';
    }
  }

  Widget _buildStatsDashboard() {
    final cp = context.watch<ClienteProvider>();
    final dp = context.watch<ChurchDataProvider>();

    final totalMiembros = cp.miembro.length;
    final activosMiembros = cp.miembro.where((m) => m.estado == 'activo').length;
    final totalCursos = dp.cursos.length;
    final totalSesiones = dp.sesiones.length;
    final totalMin = dp.ministerios.length;
    final totalCultos = dp.cultos.length;
    final totalIngresos = dp.ingresos.fold<double>(0, (sum, i) => sum + i.montoTotal);
    final totalEgresos = dp.egresos.fold<double>(0, (sum, e) => sum + e.monto);
    final balance = totalIngresos - totalEgresos;

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ClienteProvider>().fetchMiembros();
        final dp = context.read<ChurchDataProvider>();
        await dp.fetchCursos();
        await dp.fetchSesiones();
        await dp.fetchMinisterios();
        await dp.fetchCultos();
        await dp.fetchIngresos();
        await dp.fetchEgresos();
        await dp.fetchDocentes();
        await dp.fetchActividades();
        await dp.fetchSeguimientos();
        await dp.fetchContratos();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          const Text(
            'Resumen Eclesiástico',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard('Miembros', '$totalMiembros', '$activosMiembros activos', Icons.people, Colors.blue),
              _buildStatCard('Cursos', '$totalCursos', '$totalSesiones clases', Icons.book, Colors.orange),
              _buildStatCard('Ministerios', '$totalMin', '$totalCultos cultos', Icons.group_work, Colors.purple),
              _buildStatCard('Balance', '\$${balance.toStringAsFixed(0)}', '\$${totalIngresos.toStringAsFixed(0)} Ing.', Icons.account_balance_wallet, balance >= 0 ? Colors.green : Colors.red),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: const Color(0xFF1e1e2d),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF2b2b40)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estadísticas Financieras',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildFinanceRow('Ingresos Totales', '\$${totalIngresos.toStringAsFixed(2)}', Colors.green),
                  const Divider(color: Color(0xFF2b2b40), height: 24),
                  _buildFinanceRow('Egresos Totales', '\$${totalEgresos.toStringAsFixed(2)}', Colors.redAccent),
                  const Divider(color: Color(0xFF2b2b40), height: 24),
                  _buildFinanceRow('Superávit/Déficit', '\$${balance.toStringAsFixed(2)}', balance >= 0 ? Colors.greenAccent : Colors.redAccent, isBold: true),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFinanceRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String sub, IconData icon, Color color) {
    return Card(
      color: const Color(0xFF1e1e2d),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2b2b40)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
            Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    // Verificación de roles (para concordar con el sidebar de Laravel)
    final isAdmin = authProvider.isAdmin;
    final isSecretario = authProvider.hasRole('Secretario');
    final isTesorero = authProvider.hasRole('Tesorero');

    final hasNoRoles = user == null || user['roles'] == null || (user['roles'] as List).isEmpty;

    final canAccessPersonas = isAdmin || isSecretario || hasNoRoles;
    final canAccessOrg = isAdmin || isSecretario || hasNoRoles;
    final canAccessFinanzas = isAdmin || isTesorero || hasNoRoles;

    return Scaffold(
      backgroundColor: const Color(0xFF151521),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e1e2d),
        foregroundColor: Colors.white,
        elevation: 4,
        title: Text(_getSectionTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1e1e2d),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF151521)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Color(0xFF2b2b40),
                child: Icon(Icons.church, color: Color(0xFFd4af37), size: 36),
              ),
              accountName: Text(user != null ? user['name'] : 'Usuario'),
              accountEmail: Text(user != null ? user['email'] : 'iglesia@email.com'),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.dashboard, color: Colors.grey),
                    title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
                    selected: _currentSection == 'dashboard',
                    selectedTileColor: const Color(0xFF2b2b40),
                    onTap: () {
                      setState(() {
                        _currentSection = 'dashboard';
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(color: Color(0xFF2b2b40)),
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
                    child: Text(
                      'PARAMETRIZACIÓN',
                      style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  // PERSONAS SECTION
                  if (canAccessPersonas) ...[
                    ListTile(
                      leading: const Icon(Icons.people, color: Colors.blueAccent),
                      title: const Text('Miembros', style: TextStyle(color: Colors.white)),
                      selected: _currentSection == 'miembros',
                      selectedTileColor: const Color(0xFF2b2b40),
                      onTap: () {
                        setState(() {
                          _currentSection = 'miembros';
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                  ListTile(
                    leading: const Icon(Icons.school, color: Colors.blueAccent),
                    title: const Text('Docentes', style: TextStyle(color: Colors.white)),
                    selected: _currentSection == 'docentes',
                    selectedTileColor: const Color(0xFF2b2b40),
                    onTap: () {
                      setState(() {
                        _currentSection = 'docentes';
                      });
                      Navigator.pop(context);
                    },
                  ),

                  // ORGANIZACIÓN SECTION
                  if (canAccessOrg) ...[
                    ListTile(
                      leading: const Icon(Icons.group_work, color: Colors.purpleAccent),
                      title: const Text('Ministerios', style: TextStyle(color: Colors.white)),
                      selected: _currentSection == 'ministerios',
                      selectedTileColor: const Color(0xFF2b2b40),
                      onTap: () {
                        setState(() {
                          _currentSection = 'ministerios';
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.event, color: Colors.purpleAccent),
                      title: const Text('Actividades', style: TextStyle(color: Colors.white)),
                      selected: _currentSection == 'actividades',
                      selectedTileColor: const Color(0xFF2b2b40),
                      onTap: () {
                        setState(() {
                          _currentSection = 'actividades';
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.assignment, color: Colors.purpleAccent),
                      title: const Text('Seguimientos', style: TextStyle(color: Colors.white)),
                      selected: _currentSection == 'seguimientos',
                      selectedTileColor: const Color(0xFF2b2b40),
                      onTap: () {
                        setState(() {
                          _currentSection = 'seguimientos';
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],

                  // ACADÉMICO SECTION
                  ListTile(
                    leading: const Icon(Icons.book, color: Colors.orangeAccent),
                    title: const Text('Cursos', style: TextStyle(color: Colors.white)),
                    selected: _currentSection == 'cursos',
                    selectedTileColor: const Color(0xFF2b2b40),
                    onTap: () {
                      setState(() {
                        _currentSection = 'cursos';
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_view_day, color: Colors.orangeAccent),
                    title: const Text('Sesiones', style: TextStyle(color: Colors.white)),
                    selected: _currentSection == 'sesiones',
                    selectedTileColor: const Color(0xFF2b2b40),
                    onTap: () {
                      setState(() {
                        _currentSection = 'sesiones';
                      });
                      Navigator.pop(context);
                    },
                  ),

                  // FINANZAS SECTION
                  if (canAccessFinanzas) ...[
                    ListTile(
                      leading: const Icon(Icons.favorite_border, color: Colors.greenAccent),
                      title: const Text('Cultos', style: TextStyle(color: Colors.white)),
                      selected: _currentSection == 'cultos',
                      selectedTileColor: const Color(0xFF2b2b40),
                      onTap: () {
                        setState(() {
                          _currentSection = 'cultos';
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.attach_money, color: Colors.greenAccent),
                      title: const Text('Ingresos', style: TextStyle(color: Colors.white)),
                      selected: _currentSection == 'ingresos',
                      selectedTileColor: const Color(0xFF2b2b40),
                      onTap: () {
                        setState(() {
                          _currentSection = 'ingresos';
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.description, color: Colors.greenAccent),
                      title: const Text('Contratos', style: TextStyle(color: Colors.white)),
                      selected: _currentSection == 'contratos',
                      selectedTileColor: const Color(0xFF2b2b40),
                      onTap: () {
                        setState(() {
                          _currentSection = 'contratos';
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.money_off, color: Colors.greenAccent),
                      title: const Text('Egresos', style: TextStyle(color: Colors.white)),
                      selected: _currentSection == 'egresos',
                      selectedTileColor: const Color(0xFF2b2b40),
                      onTap: () {
                        setState(() {
                          _currentSection = 'egresos';
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }
}
