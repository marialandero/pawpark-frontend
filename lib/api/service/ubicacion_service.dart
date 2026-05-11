import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> buscarCiudad(String query) async {
  if (query.length < 3) return [];
  // Usamos Nominatim que es una API gratuita de OpenStreetMap para buscar ciudades en el mundo
  final url = Uri.parse(
    "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&addressdetails=1&featuretype=settlement",
  );

  try {
    final response = await http.get(
      url,
      headers: {'User-Agent': 'PawParkApp/1.0 (contacto@tuemail.com)',
          'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);

      return data.map((item) {
        final address = item['address'] ?? {};

        // Intentamos sacar el nombre del municipio/ciudad
        // Nominatim usa distintas llaves dependiendo del tamaño del sitio
        String city = address['city'] ??
            address['town'] ??
            address['village'] ??
            address['municipality'] ??
            item['display_name'].toString().split(',')[0];

        // Intentamos sacar la provincia o estado
        String province = address['province'] ??
            address['state'] ??
            address['region'] ??
            "";

        // Formateamos: "Lepe, Huelva" o solo "Lepe" si no hay provincia
        String shortName = province.isNotEmpty
            ? "$city, $province"
            : city;

        return {
          'display_name': shortName, // Ahora es corto
          'lat': double.parse(item['lat']),
          'lon': double.parse(item['lon']),
        };
      }).toList();
    }
  } catch (e) {
    debugPrint("Error en búsqueda: $e");
  }
  return [];
}
