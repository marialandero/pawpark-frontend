import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pawpark_frontend/api/model/post_model.dart';

class PostService {

  static const String baseUrl = "http://10.0.2.2:8081/posts";

  static Future<bool> crearPost(Map<String, dynamic> body) async {
    final uri = Uri.parse(baseUrl);
    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }


  static Future<List<Post>> fetchFeed(String usuarioUid) async {
    final uri = Uri.parse("$baseUrl/feed/$usuarioUid");
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List<dynamic> body = jsonDecode(res.body);
      // Transformamos cada elemento JSON en una instancia de la clase Post
      return body.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception("Error al cargar el feed");
    }
  }


  static Future<List<Post>> fetchPostsByMascota(int mascotaId, String usuarioUid) async {
    final uri = Uri.parse("$baseUrl/mascota/$mascotaId/$usuarioUid");
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception("Error al cargar posts de mascota");
    }
  }


  // TOGGLE LIKE
  static Future<bool> toggleLike(int postId, String usuarioUid) async {
    try {
      // Esta URL debe coincidir con @PostMapping("/{postId}/like/{usuarioUid}") en Java
      final response = await http.post(
        Uri.parse('$baseUrl/$postId/like/$usuarioUid'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }


  // ELIMINAR POST
  static Future<bool> eliminarPost(int postId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$postId'));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}