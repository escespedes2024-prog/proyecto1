import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier{

  final ApiService _apiservice= ApiService();
  bool _isAuthenticated = false;
  Map <String, dynamic>? _user;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;

  bool hasRole(String roleName) {
    if (_user == null || _user!['roles'] == null) return false;
    try {
      final rolesList = _user!['roles'] as List;
      return rolesList.any((r) => r['nombre'] == roleName);
    } catch (e) {
      return false;
    }
  }

  bool get isAdmin => hasRole('Administrador');

  Future <bool> login (String email,String password)async{
    _error= null;
    notifyListeners();

    try{
      final response = await _apiservice.post('/login',{
        'email': email,
        'password': password,
        'device_name': 'mobile_app',
      });
      final data = json.decode(response.body);
      if(response.statusCode == 200 && data['token'] != null){
        await _apiservice.saveToken(data['token']);
        _user = data['user'];
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }else{
        _error = data ['message']?? 'Error al iniciar sesion';
        _isAuthenticated = false;
        notifyListeners();
        return false;
      }
    }catch(e){
      _error = 'Error de conexion: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try{
      await _apiservice.post('/logout',{});
    }catch (e){
    }
    await _apiservice.deleteToken();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
  //checkAuthStatus es un procedimiento que nos ayudara a
  Future <void> checkAuthStatus() async{
    String? token = await _apiservice.getToken();
    if(token!= null){
      try{
        final response = await _apiservice.get('/user');
        if(response.statusCode==200){
          _user = jsonDecode(response.body);
          _isAuthenticated = true;
        }else {
          await _apiservice.deleteToken();
          _isAuthenticated = false;
        }
      }catch(e){
        _isAuthenticated = false;
      }
    }else{
      _isAuthenticated = false;
    }
    notifyListeners();
  }
}