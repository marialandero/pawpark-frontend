import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pawpark_frontend/core/api_config.dart';
import '../model/quedada_model.dart';

class QuedadaService {
  static const String baseUrlQuedadas = '${ApiConfig.baseUrl}/quedadas';

  // Obtener todas las quedadas
  static Future<List<Quedada>> fetchTodas() async {
    final response = await http.get(Uri.parse(baseUrlQuedadas));
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
      Uri.parse(baseUrlQuedadas),
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
      Uri.parse('$baseUrlQuedadas/$quedadaId/unirse'),
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
      Uri.parse('$baseUrlQuedadas/$quedadaId/desapuntarse'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200) {
      return Quedada.fromJson(jsonDecode(response.body));
    }
    return null;
  }
}