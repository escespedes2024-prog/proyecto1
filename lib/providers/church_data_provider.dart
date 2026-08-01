import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/ministerio.dart';
import '../models/docente.dart';
import '../models/actividad.dart';
import '../models/seguimiento.dart';
import '../models/curso.dart';
import '../models/sesion.dart';
import '../models/culto.dart';
import '../models/ingreso.dart';
import '../models/contrato.dart';
import '../models/egreso.dart';

class ChurchDataProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Ministerio> _ministerios = [];
  List<Docente> _docentes = [];
  List<Actividad> _actividades = [];
  List<Seguimiento> _seguimientos = [];
  List<Curso> _cursos = [];
  List<Sesion> _sesiones = [];
  List<Culto> _cultos = [];
  List<Ingreso> _ingresos = [];
  List<Contrato> _contratos = [];
  List<Egreso> _egresos = [];

  List<Ministerio> get ministerios => _ministerios;
  List<Docente> get docentes => _docentes;
  List<Actividad> get actividades => _actividades;
  List<Seguimiento> get seguimientos => _seguimientos;
  List<Curso> get cursos => _cursos;
  List<Sesion> get sesiones => _sesiones;
  List<Culto> get cultos => _cultos;
  List<Ingreso> get ingresos => _ingresos;
  List<Contrato> get contratos => _contratos;
  List<Egreso> get egresos => _egresos;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  // ── MINISTERIOS ───────────────────────────────────────────
  Future<void> fetchMinisterios() async {
    _setLoading(true);
    try {
      final res = await _apiService.get('/ministerios');
      if (res.statusCode == 200) {
        List<dynamic> data = jsonDecode(res.body);
        _ministerios = data.map((x) => Ministerio.fromJson(x)).toList();
      }
    } catch (e) {
      debugPrint('Error fetchMinisterios: $e');
    }
    _setLoading(false);
  }

  Future<bool> createMinisterio(Ministerio m) async {
    try {
      final res = await _apiService.post('/ministerios', m.toJson());
      if (res.statusCode == 201) {
        await fetchMinisterios();
        return true;
      }
    } catch (e) {
      debugPrint('Error createMinisterio: $e');
    }
    return false;
  }

  Future<bool> updateMinisterio(Ministerio m) async {
    try {
      final res = await _apiService.post('/ministerios/${m.id}?_method=PUT', m.toJson());
      if (res.statusCode == 200) {
        await fetchMinisterios();
        return true;
      }
    } catch (e) {
      debugPrint('Error updateMinisterio: $e');
    }
    return false;
  }

  Future<bool> deleteMinisterio(int id) async {
    try {
      final res = await _apiService.post('/ministerios/$id?_method=DELETE', {});
      if (res.statusCode == 200) {
        _ministerios.removeWhere((x) => x.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleteMinisterio: $e');
    }
    return false;
  }

  // ── DOCENTES ──────────────────────────────────────────────
  Future<void> fetchDocentes() async {
    _setLoading(true);
    try {
      final res = await _apiService.get('/docentes');
      if (res.statusCode == 200) {
        List<dynamic> data = jsonDecode(res.body);
        _docentes = data.map((x) => Docente.fromJson(x)).toList();
      }
    } catch (e) {
      debugPrint('Error fetchDocentes: $e');
    }
    _setLoading(false);
  }

  Future<bool> createDocente(Docente d) async {
    try {
      final res = await _apiService.post('/docentes', d.toJson());
      if (res.statusCode == 201) {
        await fetchDocentes();
        return true;
      }
    } catch (e) {
      debugPrint('Error createDocente: $e');
    }
    return false;
  }

  Future<bool> updateDocente(Docente d) async {
    try {
      final res = await _apiService.post('/docentes/${d.id}?_method=PUT', d.toJson());
      if (res.statusCode == 200) {
        await fetchDocentes();
        return true;
      }
    } catch (e) {
      debugPrint('Error updateDocente: $e');
    }
    return false;
  }

  Future<bool> deleteDocente(int id) async {
    try {
      final res = await _apiService.post('/docentes/$id?_method=DELETE', {});
      if (res.statusCode == 200) {
        _docentes.removeWhere((x) => x.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleteDocente: $e');
    }
    return false;
  }

  // ── ACTIVIDADES ───────────────────────────────────────────
  Future<void> fetchActividades() async {
    _setLoading(true);
    try {
      final res = await _apiService.get('/actividades');
      if (res.statusCode == 200) {
        List<dynamic> data = jsonDecode(res.body);
        _actividades = data.map((x) => Actividad.fromJson(x)).toList();
      }
    } catch (e) {
      debugPrint('Error fetchActividades: $e');
    }
    _setLoading(false);
  }

  Future<bool> createActividad(Actividad a) async {
    try {
      final res = await _apiService.post('/actividades', a.toJson());
      if (res.statusCode == 201) {
        await fetchActividades();
        return true;
      }
    } catch (e) {
      debugPrint('Error createActividad: $e');
    }
    return false;
  }

  Future<bool> updateActividad(Actividad a) async {
    try {
      final res = await _apiService.post('/actividades/${a.id}?_method=PUT', a.toJson());
      if (res.statusCode == 200) {
        await fetchActividades();
        return true;
      }
    } catch (e) {
      debugPrint('Error updateActividad: $e');
    }
    return false;
  }

  Future<bool> deleteActividad(int id) async {
    try {
      final res = await _apiService.post('/actividades/$id?_method=DELETE', {});
      if (res.statusCode == 200) {
        _actividades.removeWhere((x) => x.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleteActividad: $e');
    }
    return false;
  }

  // ── SEGUIMIENTOS ──────────────────────────────────────────
  Future<void> fetchSeguimientos() async {
    _setLoading(true);
    try {
      final res = await _apiService.get('/seguimientos');
      if (res.statusCode == 200) {
        List<dynamic> data = jsonDecode(res.body);
        _seguimientos = data.map((x) => Seguimiento.fromJson(x)).toList();
      }
    } catch (e) {
      debugPrint('Error fetchSeguimientos: $e');
    }
    _setLoading(false);
  }

  Future<bool> createSeguimiento(Seguimiento s) async {
    try {
      final res = await _apiService.post('/seguimientos', s.toJson());
      if (res.statusCode == 201) {
        await fetchSeguimientos();
        return true;
      }
    } catch (e) {
      debugPrint('Error createSeguimiento: $e');
    }
    return false;
  }

  Future<bool> updateSeguimiento(Seguimiento s) async {
    try {
      final res = await _apiService.post('/seguimientos/${s.id}?_method=PUT', s.toJson());
      if (res.statusCode == 200) {
        await fetchSeguimientos();
        return true;
      }
    } catch (e) {
      debugPrint('Error updateSeguimiento: $e');
    }
    return false;
  }

  Future<bool> deleteSeguimiento(int id) async {
    try {
      final res = await _apiService.post('/seguimientos/$id?_method=DELETE', {});
      if (res.statusCode == 200) {
        _seguimientos.removeWhere((x) => x.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleteSeguimiento: $e');
    }
    return false;
  }

  // ── CURSOS ────────────────────────────────────────────────
  Future<void> fetchCursos() async {
    _setLoading(true);
    try {
      final res = await _apiService.get('/cursos');
      if (res.statusCode == 200) {
        List<dynamic> data = jsonDecode(res.body);
        _cursos = data.map((x) => Curso.fromJson(x)).toList();
      }
    } catch (e) {
      debugPrint('Error fetchCursos: $e');
    }
    _setLoading(false);
  }

  Future<bool> createCurso(Curso c) async {
    try {
      final res = await _apiService.post('/cursos', c.toJson());
      if (res.statusCode == 201) {
        await fetchCursos();
        return true;
      }
    } catch (e) {
      debugPrint('Error createCurso: $e');
    }
    return false;
  }

  Future<bool> updateCurso(Curso c) async {
    try {
      final res = await _apiService.post('/cursos/${c.id}?_method=PUT', c.toJson());
      if (res.statusCode == 200) {
        await fetchCursos();
        return true;
      }
    } catch (e) {
      debugPrint('Error updateCurso: $e');
    }
    return false;
  }

  Future<bool> deleteCurso(int id) async {
    try {
      final res = await _apiService.post('/cursos/$id?_method=DELETE', {});
      if (res.statusCode == 200) {
        _cursos.removeWhere((x) => x.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleteCurso: $e');
    }
    return false;
  }

  // ── SESIONES ──────────────────────────────────────────────
  Future<void> fetchSesiones() async {
    _setLoading(true);
    try {
      final res = await _apiService.get('/sesiones');
      if (res.statusCode == 200) {
        List<dynamic> data = jsonDecode(res.body);
        _sesiones = data.map((x) => Sesion.fromJson(x)).toList();
      }
    } catch (e) {
      debugPrint('Error fetchSesiones: $e');
    }
    _setLoading(false);
  }

  Future<bool> createSesion(Sesion s) async {
    try {
      final res = await _apiService.post('/sesiones', s.toJson());
      if (res.statusCode == 201) {
        await fetchSesiones();
        return true;
      }
    } catch (e) {
      debugPrint('Error createSesion: $e');
    }
    return false;
  }

  Future<bool> updateSesion(Sesion s) async {
    try {
      final res = await _apiService.post('/sesiones/${s.id}?_method=PUT', s.toJson());
      if (res.statusCode == 200) {
        await fetchSesiones();
        return true;
      }
    } catch (e) {
      debugPrint('Error updateSesion: $e');
    }
    return false;
  }

  Future<bool> deleteSesion(int id) async {
    try {
      final res = await _apiService.post('/sesiones/$id?_method=DELETE', {});
      if (res.statusCode == 200) {
        _sesiones.removeWhere((x) => x.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleteSesion: $e');
    }
    return false;
  }

  // ── CULTOS ────────────────────────────────────────────────
  Future<void> fetchCultos() async {
    _setLoading(true);
    try {
      final res = await _apiService.get('/cultos');
      if (res.statusCode == 200) {
        List<dynamic> data = jsonDecode(res.body);
        _cultos = data.map((x) => Culto.fromJson(x)).toList();
      }
    } catch (e) {
      debugPrint('Error fetchCultos: $e');
    }
    _setLoading(false);
  }

  Future<bool> createCulto(Culto c) async {
    try {
      final res = await _apiService.post('/cultos', c.toJson());
      if (res.statusCode == 201) {
        await fetchCultos();
        return true;
      }
    } catch (e) {
      debugPrint('Error createCulto: $e');
    }
    return false;
  }

  Future<bool> updateCulto(Culto c) async {
    try {
      final res = await _apiService.post('/cultos/${c.idCulto}?_method=PUT', c.toJson());
      if (res.statusCode == 200) {
        await fetchCultos();
        return true;
      }
    } catch (e) {
      debugPrint('Error updateCulto: $e');
    }
    return false;
  }

  Future<bool> deleteCulto(int id) async {
    try {
      final res = await _apiService.post('/cultos/$id?_method=DELETE', {});
      if (res.statusCode == 200) {
        _cultos.removeWhere((x) => x.idCulto == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleteCulto: $e');
    }
    return false;
  }

  // ── INGRESOS ──────────────────────────────────────────────
  Future<void> fetchIngresos() async {
    _setLoading(true);
    try {
      final res = await _apiService.get('/ingresos');
      if (res.statusCode == 200) {
        List<dynamic> data = jsonDecode(res.body);
        _ingresos = data.map((x) => Ingreso.fromJson(x)).toList();
      }
    } catch (e) {
      debugPrint('Error fetchIngresos: $e');
    }
    _setLoading(false);
  }

  Future<bool> createIngreso(Ingreso i) async {
    try {
      final res = await _apiService.post('/ingresos', i.toJson());
      if (res.statusCode == 201) {
        await fetchIngresos();
        return true;
      }
    } catch (e) {
      debugPrint('Error createIngreso: $e');
    }
    return false;
  }

  Future<bool> updateIngreso(Ingreso i) async {
    try {
      final res = await _apiService.post('/ingresos/${i.id}?_method=PUT', i.toJson());
      if (res.statusCode == 200) {
        await fetchIngresos();
        return true;
      }
    } catch (e) {
      debugPrint('Error updateIngreso: $e');
    }
    return false;
  }

  Future<bool> deleteIngreso(int id) async {
    try {
      final res = await _apiService.post('/ingresos/$id?_method=DELETE', {});
      if (res.statusCode == 200) {
        _ingresos.removeWhere((x) => x.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleteIngreso: $e');
    }
    return false;
  }

  // ── CONTRATOS ─────────────────────────────────────────────
  Future<void> fetchContratos() async {
    _setLoading(true);
    try {
      final res = await _apiService.get('/contratos');
      if (res.statusCode == 200) {
        List<dynamic> data = jsonDecode(res.body);
        _contratos = data.map((x) => Contrato.fromJson(x)).toList();
      }
    } catch (e) {
      debugPrint('Error fetchContratos: $e');
    }
    _setLoading(false);
  }

  Future<bool> createContrato(Contrato c) async {
    try {
      final res = await _apiService.post('/contratos', c.toJson());
      if (res.statusCode == 201) {
        await fetchContratos();
        return true;
      }
    } catch (e) {
      debugPrint('Error createContrato: $e');
    }
    return false;
  }

  Future<bool> updateContrato(Contrato c) async {
    try {
      final res = await _apiService.post('/contratos/${c.id}?_method=PUT', c.toJson());
      if (res.statusCode == 200) {
        await fetchContratos();
        return true;
      }
    } catch (e) {
      debugPrint('Error updateContrato: $e');
    }
    return false;
  }

  Future<bool> deleteContrato(int id) async {
    try {
      final res = await _apiService.post('/contratos/$id?_method=DELETE', {});
      if (res.statusCode == 200) {
        _contratos.removeWhere((x) => x.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleteContrato: $e');
    }
    return false;
  }

  // ── EGRESOS ───────────────────────────────────────────────
  Future<void> fetchEgresos() async {
    _setLoading(true);
    try {
      final res = await _apiService.get('/egresos');
      if (res.statusCode == 200) {
        List<dynamic> data = jsonDecode(res.body);
        _egresos = data.map((x) => Egreso.fromJson(x)).toList();
      }
    } catch (e) {
      debugPrint('Error fetchEgresos: $e');
    }
    _setLoading(false);
  }

  Future<bool> createEgreso(Egreso eg) async {
    try {
      final res = await _apiService.post('/egresos', eg.toJson());
      if (res.statusCode == 201) {
        await fetchEgresos();
        return true;
      }
    } catch (e) {
      debugPrint('Error createEgreso: $e');
    }
    return false;
  }

  Future<bool> updateEgreso(Egreso eg) async {
    try {
      final res = await _apiService.post('/egresos/${eg.id}?_method=PUT', eg.toJson());
      if (res.statusCode == 200) {
        await fetchEgresos();
        return true;
      }
    } catch (e) {
      debugPrint('Error updateEgreso: $e');
    }
    return false;
  }

  Future<bool> deleteEgreso(int id) async {
    try {
      final res = await _apiService.post('/egresos/$id?_method=DELETE', {});
      if (res.statusCode == 200) {
        _egresos.removeWhere((x) => x.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleteEgreso: $e');
    }
    return false;
  }
}
