import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'mascota_model.dart';

class MascotaService {
  static const String baseUrl = 'http://10.0.2.2:8081/mascotas';

  static Future<Mascota?> updateDescripcion(int mascotaId, String nuevaDesc) async {
    final url = Uri.parse('http://10.0.2.2:8081/mascotas/$mascotaId/descripcion');
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
      return null;
    } catch (e) {
      debugPrint("Error en MascotaService: $e");
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
}