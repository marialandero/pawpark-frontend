import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:pawpark_frontend/core/api_config.dart';
import 'dart:convert';
import '../model/mascota_model.dart';

class MascotaService {

  static const String baseUrlMascotas = '${ApiConfig.baseUrl}/mascotas';

  // Para formatear nombres de razas (BORDER_COLLIE -> Border Collie)
  static String formatearRaza(String texto) {
    if (texto.isEmpty) return "";
    return texto.replaceAll('_', ' ').toLowerCase().split(' ').map((word) {
      return word.isEmpty ? "" : word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  static Future<Mascota?> updateMascota({
    required int id,
    required String descripcion,
    required int edad
  }) async {
    final url = Uri.parse('$baseUrlMascotas/$id/perfil');
    try {
      final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "descripcion": descripcion,
            "edad": edad
          })
      );
      if (response.statusCode == 200) {
        return Mascota.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint("Error en updateMascota: $e");
      return null;
    }
  }

  static Future<bool> crearMascota(Map<String, dynamic> data) async {
    // Añadimos /mascotas a la URL
    final url = Uri.parse(baseUrlMascotas);

    print("🚀 Petición POST a: $url");
    print("📦 Payload JSON: ${jsonEncode(data)}");

    try {
      final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data)
      );
      // DEBUG para ver qué dice el servidor si falla
      if (response.statusCode != 200 && response.statusCode != 201) {
        print("Error detectado: ${response.statusCode} - ${response.body}");
      }

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error de conexión: $e");
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
        Uri.parse("$baseUrlMascotas/$id/foto"),
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


  // Borrar una mascota específica por su ID
  static Future<bool> eliminarMascota(int mascotaId) async {
    // Apuntamos a la ruta /mascotas que es donde está MascotaController
    final url = Uri.parse("$baseUrlMascotas/$mascotaId");
    try {
      final response = await http.delete(url);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("Error al eliminar mascota: $e");
      return false;
    }
  }
}