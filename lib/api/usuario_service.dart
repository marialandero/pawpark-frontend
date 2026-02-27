import 'dart:convert';
import 'package:http/http.dart' as http;
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
}