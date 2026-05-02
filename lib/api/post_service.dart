import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pawpark_frontend/api/post_model.dart';

class PostService {

  static const String baseUrl = "http://10.0.2.2:8081/posts";

  /// 📤 UPLOAD IMAGEN
  // En post_service.dart
  static Future<String> uploadImage(File image) async {

    final uri = Uri.parse("$baseUrl/upload");
    final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

    // Añadimos un tiempo límite de 30 segundos
    final streamedResponse = await request.send().timeout(Duration(seconds: 30));

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body; // backend devuelve string (nombre del archivo o url)
    } else {
      throw Exception("Error al subir imagen: ${response.statusCode}");
    }
  }

  /// ➕ CREAR POST
  static Future<bool> crearPost(Map<String, dynamic> body) async {

    final uri = Uri.parse(baseUrl);

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return res.statusCode == 200 || res.statusCode == 201;
  }

  /// 📥 FEED
  static Future<List<Post>> fetchFeed() async {

    final uri = Uri.parse("$baseUrl/feed");

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final List<dynamic> body = jsonDecode(res.body);
      // Transformamos cada elemento JSON en una instancia de la clase Post
      return body.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception("Error al cargar el feed");
    }
  }

  static Future<List<Post>> fetchPostsByMascota(int mascotaId) async {
    final uri = Uri.parse("$baseUrl/mascota/$mascotaId");

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);

      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception("Error al cargar posts de mascota");
    }
  }
}