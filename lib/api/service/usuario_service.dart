import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:pawpark_frontend/core/api_config.dart';
import '../model/mascota_model.dart';
import '../model/usuario_model.dart';

class UsuarioService {

  static const String baseUrlUsuarios = "${ApiConfig.baseUrl}/usuarios";

  static Future<Usuario> fetchPerfil(String uid) async {
    final response = await http.get(Uri.parse("$baseUrlUsuarios/firebase/$uid"));

    if (response.statusCode == 200) {
      return Usuario.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error al cargar el perfil");
    }
  }


  static Future<Usuario?> actualizarPerfil(String uid, Map<String, dynamic> datos) async {
    final url = Uri.parse("$baseUrlUsuarios/firebase/$uid");

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos)
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Usuario.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }


  static Future<List<Usuario>> fetchTodos() async {
    final response = await http.get(Uri.parse(baseUrlUsuarios));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Usuario.fromJson(e)).toList();
    } else {
      throw Exception("Error al cargar usuarios");
    }
  }


  static Future<List<Usuario>> buscarUsuarios(String query, String miUid) async {

    // Enviamos por parámetros la query y el UID del que busca
    final url = Uri.parse("$baseUrlUsuarios/buscar?query=$query&viewerUid=$miUid");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception("Error buscando usuarios");
    }
  }


  static Future<bool> alternarSeguimiento(String miUid, String targetUid) async {
    final url = Uri.parse('$baseUrlUsuarios/$miUid/seguir/$targetUid');
    final response = await http.post(url);
    return response.statusCode == 200;
  }


  static Future<bool> alternarMascotaFavorita(String miUid, int mascotaId) async {
    final url = Uri.parse('$baseUrlUsuarios/$miUid/favorito/$mascotaId');
    final response = await http.post(url);
    return response.statusCode == 200;
  }


  static Future<bool> registrarEnBackend(Map<String, dynamic> datosUsuario) async {
    final url = Uri.parse(baseUrlUsuarios);
    try{
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datosUsuario)
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Error de conexión en UsuarioService: $e");
      return false;
    }
  }


  // Dar de baja la cuenta completa usando el Firebase UID
  static Future<bool> darDeBajaCuenta(String uid) async {
    // Usamos la ruta donde está UsuarioController
    final url = Uri.parse("$baseUrlUsuarios/firebase/$uid");
    try {
      final response = await http.delete(url);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("Error al dar de baja la cuenta: $e");
      return false;
    }
  }
}