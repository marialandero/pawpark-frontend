import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pawpark_frontend/api/post_model.dart';

class PostService {

  static const String baseUrl = "http://10.0.2.2:8081/posts";

  /// 📤 UPLOAD IMAGEN
  // En post_service.dart
  static Future<String> uploadImage(File image) async {
    final request = http.MultipartRequest('POST', Uri.parse("$baseUrl/upload"))
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    // Añadimos un tiempo límite de 30 segundos
    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body; // El nombre del archivo
    } else {
      throw Exception("Error al subir imagen: ${response.statusCode}");
    }
  }

  /// ➕ CREAR POST
  static Future<bool> crearPost(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return res.statusCode == 200 || res.statusCode == 201;
  }

  /// 📥 FEED
  static Future<List<Post>> fetchFeed() async {
    final res = await http.get(Uri.parse("$baseUrl/feed"));
    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      // Transformamos cada elemento JSON en una instancia de la clase Post
      return body.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception("Error al cargar el feed");
    }
  }
}