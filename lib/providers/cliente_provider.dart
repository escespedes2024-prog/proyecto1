import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/miembro.dart';
import '../services/api_service.dart';

class ClienteProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Miembro> _miembro =[];
  bool _isLoading = false;

  List<Miembro> get miembro => _miembro;
  bool get isLoading => _isLoading;

  Future<void> fetchMiembros() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/miembros');
      if (response.statusCode == 200){
        List<dynamic> data = jsonDecode(response.body);
        _miembro  = data.map((item) => Miembro.fromJson(item)).toList();
      }
    }catch(e){
      debugPrint('Error fetchMiembros: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createMiembro(Miembro miembro) async {
    try{
      final response = await _apiService.post('/miembros', miembro.toJson());
      if(response.statusCode == 201){
        await fetchMiembros();
        return true;
      }
    }catch(e){
      debugPrint('Error createMiembro: $e');
    }
    return false;
  }

  Future<bool> updateMiembro(Miembro miembro) async {
    try {
      final response = await _apiService.post('/miembros/${miembro.id}?_method=PUT', miembro.toJson());
      if(response.statusCode == 200){
        await fetchMiembros();
        return true;
      }
    }catch (e){
      debugPrint('Error updateMiembro: $e');
    }
    return false;
  }
  Future<bool> deleteMiembro(int id) async {
    try {
      final response = await _apiService.post('/miembros/$id?_method=DELETE', {});
      if(response.statusCode == 200){
        _miembro.removeWhere((c) => c.id == id);
        notifyListeners();
        return true;
      }
    }catch (e) {
      debugPrint('Error deleteMiembro: $e');
    }
    return false;
  }
}