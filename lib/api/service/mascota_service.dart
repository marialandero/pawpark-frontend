import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/mascota_model.dart';

class MascotaService {

  static const String baseUrl = 'http://10.0.2.2:8081';

  // Subir imágenes y obtener el nombre del archivo
  static Future<String?> subirImagen(File imagen) async {
    final url = Uri.parse('$baseUrl/upload');
    try {
      final request = http.MultipartRequest("POST", url);
      request.files.add(
        await http.MultipartFile.fromPath("file", imagen.path),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        // Retorna solo el nombre del archivo (ej: imagen_123.jpg)
        return respStr.split("/").last;
      }
      return null;
    } catch (e) {
      debugPrint("Error en MascotaService.subirImagen: $e");
      return null;
    }
  }

  // UTILIDAD: Para formatear nombres de razas (BORDER_COLLIE -> Border Collie)
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
    final url = Uri.parse('$baseUrl/mascotas/$id/perfil'); // Cambiado a un endpoint de 'perfil' más genérico

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
    final url = Uri.parse('$baseUrl/mascotas');

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