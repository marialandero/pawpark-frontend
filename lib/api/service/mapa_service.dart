import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../model/zona_model.dart';

class MapaService {
  // Usamos 10.0.2.2 para que el emulador Android vea el servidor Java de nuestro PC
  static const String baseUrl = "http://10.0.2.2:8081/mapa";

  static Future<List<Zona>> buscarZonasEnOSM(double lat, double lng) async {

    debugPrint("Llamando a Overpass para: $lat, $lng"); // CHIVATO 1

    // Buscamos parques, jardines y plazas en un radio de 3km
    final query = '''
    [out:json][timeout:25];
    (
      node["leisure"~"park|dog_park"](around:3000, $lat, $lng);
      way["leisure"~"park|dog_park"](around:3000, $lat, $lng);
      node["place"~"square|plaza"](around:3000, $lat, $lng);
      way["place"~"square|plaza"](around:3000, $lat, $lng);
      node["natural"="beach"](around:3000, $lat, $lng);
      way["natural"="beach"](around:3000, $lat, $lng); 
    );
    out center;
    ''';

    try {
      final response = await http.post(
        Uri.parse('https://overpass.kumi.systems/api/interpreter'),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "User-Agent": "PawParkApp/1.0"
        },
        body: {'data': query},
      ).timeout(Duration(seconds: 30)); // Añadimos timeout

      debugPrint("Respuesta de Overpass recibida. Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Usamos utf8.decode para que los nombres con tildes se lean bien
        final data = json.decode(utf8.decode(response.bodyBytes));
        List<Zona> zonasDetectadas = [];

        var elements = data['elements'] as List;
        debugPrint("Elementos encontrados en el JSON: ${elements.length}");

        // ... dentro del bucle for al procesar los elementos ...
        for (var element in elements) {
          final tags = element['tags'] ?? {};
          String? nombreDelMapa = tags['name'];
          // Si no tiene nombre, saltamos al siguiente elemento del bucle
          if (nombreDelMapa == null || nombreDelMapa.isEmpty) {
            continue;
          }
          String leisure = tags['leisure'] ?? '';
          String place = tags['place'] ?? '';
          String natural = tags['natural'] ?? '';


          // Lógica de clasificación de tipos: busca en etiquetas inglesas y decide si es parque o plaza
          String tipoFinal;
          if (natural == 'beach') {
            tipoFinal = 'playa';
          } else if (place.contains('square') || place.contains('plaza')) {
            tipoFinal = 'plaza';
          } else if (leisure == 'park' || leisure == 'dog_park') {
            tipoFinal = 'parque';
          } else {
            tipoFinal = 'recreativa';
          }

          // Lógica de nombres genéricos si no tienen nombre en el mapa
          String nombreAMostrar = nombreDelMapa ?? (
              tipoFinal == 'playa' ? "Playa" :
              tipoFinal == 'parque' ? "Parque" :
              tipoFinal == 'plaza' ? "Plaza" : "Zona recreativa"
          );

          zonasDetectadas.add(Zona(
            // Combinamos tipo e ID para que sea único en MySQL
            osmId: "${element['type']}/${element['id']}",
            nombre: nombreAMostrar,
            // Convertimos a double para evitar errores de tipo
            latitud: (element['lat'] ?? element['center']?['lat'] ?? 0.0).toDouble(),
            longitud: (element['lon'] ?? element['center']?['lon'] ?? 0.0).toDouble(),
            tipo: tipoFinal,
          ));
        }
        return zonasDetectadas;
      } else {
        debugPrint("Error del servidor: ${response.body}"); // CHIVATO 4
      }
    } catch (e) {
      debugPrint("Error CRÍTICO en buscarZonasEnOSM: $e"); // CHIVATO 5
    }
    return []; // Si hay error, devolvemos lista vacía para que no explote la app
  }

  // 2. SINCRONIZAR CON BACKEND
  static Future<List<Zona>> sincronizarConBackend(List<Zona> zonas) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sincronizar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(zonas.map((z) => z.toJson()).toList()),
      ).timeout(Duration(seconds: 5)); // No esperamos más de 5s a Java

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((z) => Zona.fromJson(z)).toList();
      }
    } catch (e) {
      debugPrint("Backend Java no dispoble: $e");
    }
    // Si falla el servidor Java, devolvemos las zonas de OSM pero con 0 perritos
    return zonas;
  }

  // HACER CHECK-IN
  static Future<bool> hacerCheckIn(String uid, List<String> mascotasIds, String osmId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/checkin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': uid,
          'mascotasIds': mascotasIds,
          'osmId': osmId,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // NOTIFICAR SALIDA MANUAL
  static Future<bool> notificarSalida(String uid) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/salida/$uid'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error al notificar salida: $e");
      return false;
    }
  }
}