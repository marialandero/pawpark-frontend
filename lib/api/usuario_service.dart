import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'mascota_model.dart';
import 'usuario_model.dart';

class UsuarioService {
  /// Usamos el puente de Google 10.0.2.2 que apunta a nuestro pc en lugar de
  /// localhost para que el emulador salga de su propio "localhost" y se conecte
  /// con nuestro pc.
  static const String baseUrl = "http://10.0.2.2:8081/usuarios";

  static Future<Usuario> fetchPerfil(String uid) async {
    final response = await http.get(Uri.parse("$baseUrl/firebase/$uid"));

    if (response.statusCode == 200) {
      return Usuario.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error al cargar el perfil");
    }
  }

  static Future<Usuario?> actualizarPerfil(String uid, Map<String, dynamic> datos) async {
    final url = Uri.parse("$baseUrl/firebase/$uid");

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos)
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Usuario.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<Usuario>> fetchTodos() async {
    final response = await http.get(Uri.parse("$baseUrl"));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Usuario.fromJson(e)).toList();
    } else {
      throw Exception("Error al cargar usuarios");
    }
  }

  static Future<List<Usuario>> buscarUsuarios(String query) async {
    final response = await http.get(
      Uri.parse("$baseUrl/buscar?query=$query"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => Usuario.fromJson(e)).toList();
    } else {
      throw Exception("Error buscando usuarios");
    }
  }

  static Future<String?> uploadFotoPerfil(String uid, File image) async {
    final uri = Uri.parse("$baseUrl/upload-foto/$uid");

    var request = http.MultipartRequest("POST", uri);

    request.files.add(
      await http.MultipartFile.fromPath("file", image.path),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final resp = await response.stream.bytesToString();
      return resp.replaceAll('"', '');
    }

    return null;
  }

  static Future<Mascota?> actualizarFotoMascota(
      int id,
      String foto,
      ) async {
    final response = await http.put(
      Uri.parse("http://10.0.2.2:8081/mascotas/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fotoPerfilMascota": foto,
      }),
    );

    if (response.statusCode == 200) {
      return Mascota.fromJson(jsonDecode(response.body));
    }

    return null;
  }
}