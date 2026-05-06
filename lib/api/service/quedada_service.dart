import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/quedada_model.dart';

class QuedadaService {
  static const String baseUrl = 'http://10.0.2.2:8081/quedadas';

  // Obtener todas las quedadas
  static Future<List<Quedada>> fetchTodas() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Quedada.fromJson(data)).toList();
    } else {
      throw Exception('Error al cargar quedadas');
    }
  }

  // Crear una quedada
  static Future<Quedada?> crearQuedada(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Quedada.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // Unirse a una quedada
  static Future<Quedada?> unirse(int quedadaId, Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$quedadaId/unirse'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload), // Enviamos el mapa que viene del Provider
    );
    if (response.statusCode == 200) {
      return Quedada.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // Desapuntarse de una quedada
  static Future<Quedada?> desapuntarse(int quedadaId, Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$quedadaId/desapuntarse'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200) {
      return Quedada.fromJson(jsonDecode(response.body));
    }
    return null;
  }
}