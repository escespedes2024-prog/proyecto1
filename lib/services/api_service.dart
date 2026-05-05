import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = "http://localhost:8000/api";
  final _storage = const FlutterSecureStorage();
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  Future<Map<String, String>> _getHeaders() async {
    String? token = await getToken();
    return {
      'Content-type':'application/json',
      'accept' : 'application/json',
      if(token !=null) 'Authorization': 'bearer $token',
    };
  }
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async{
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
    );
  }
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return await http.get(url, headers: headers);
  }
  Future<void> saveToken(String Token) async {
    await _storage.write(key: 'auth_token', value: Token);
  }
  Future<void> deleteToken() async{
    await _storage.delete(key: 'auth_token');
  }
}