import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'mascota_model.dart';

class MascotaService {
  // BASE URL SIN /mascotas
  static const String baseUrl = 'http://10.0.2.2:8081';

  // Actualizar descripción
  static Future<Mascota?> updateDescripcion(int mascotaId, String nuevaDesc) async {
    final url = Uri.parse('$baseUrl/mascotas/$mascotaId/descripcion');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"descripcion": nuevaDesc})
      );

      if (response.statusCode == 200) {
        // Retornamos el objeto que nos manda el backend
        return Mascota.fromJson(jsonDecode(response.body));
      }
      print("Error backend descripcion: ${response.body}");
      return null;
    } catch (e) {
      debugPrint("Error en updateDescripcion de MascotaService: $e");
      return null;
    }
  }

  static Future<bool> crearMascota(Map<String, dynamic> data) async {
    final url = Uri.parse(baseUrl);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data)
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Actualizar solo foto
  static Future<Mascota?> actualizarFotoMascota(
      int id,
      String fotoPerfilMascota,
      ) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/mascotas/$id/foto"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fotoPerfilMascota": fotoPerfilMascota,
        }),
      );

      if (response.statusCode == 200) {
        return Mascota.fromJson(jsonDecode(response.body));
      } else {
        print("Error backend: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error service mascota: $e");
      return null;
    }
  }

  static Future<bool> eliminarMascota(int id) async {
    final uri = Uri.parse("$baseUrl/mascotas/$id");

    final res = await http.delete(uri);

    return res.statusCode == 200 || res.statusCode == 204;
  }
}