import 'dart:convert';
import 'package:http/http.dart' as http;
import 'post_model.dart';

class PostService {
  static const String baseUrl = "http://10.0.2.2:8081/posts";

  /// 🔥 GET FEED
  static Future<List<Post>> fetchFeed() async {
    final response = await http.get(Uri.parse("$baseUrl/feed"));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception("Error al cargar el feed");
    }
  }

  /// 🔥 CREAR POST
  static Future<bool> crearPost(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}