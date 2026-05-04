import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaPrueba extends StatefulWidget {
  const MapaPrueba({super.key});

  @override
  State<MapaPrueba> createState() => _MapaPruebaState();
}

class _MapaPruebaState extends State<MapaPrueba> {
  // Coordenadas aproximadas de Isla Cristina
  final LatLng islaCristina = const LatLng(37.2014, -7.3218);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          /// 🗺️ SECCIÓN DEL MAPA (Ocupa el 60% de la pantalla)
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: islaCristina,
                    initialZoom: 14.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.pawpark.app',
                    ),
                    // Aquí irían los marcadores de los parques
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: const LatLng(37.2025, -7.3195), // Ejemplo: Parque Central
                          width: 40,
                          height: 40,
                          child: Icon(Icons.location_on, color: color.secondary, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
                // Botón flotante para centrar mi ubicación
                Positioned(
                  right: 15,
                  bottom: 15,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: () {},
                    child: const Icon(Icons.my_location),
                  ),
                )
              ],
            ),
          ),

          /// 📋 SECCIÓN "ZONAS CERCANAS"
          Expanded(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Text(
                      "Zonas cercanas en Isla Cristina",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: 3, // Ejemplo: Parque Central, Plaza de las Flores, etc.
                      itemBuilder: (context, index) {
                        return _buildZonaCard(color);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZonaCard(ColorScheme color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.primary.withOpacity(0.1),
          child: Icon(Icons.park, color: color.primary),
        ),
        title: const Text("Parque Central"),
        subtitle: const Text("3 perritos presentes ahora mismo"),
        trailing: ElevatedButton(
          onPressed: () => _showCheckInDialog(),
          style: ElevatedButton.styleFrom(backgroundColor: color.secondary),
          child: const Text("Check-in", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  // Diálogo para elegir con qué mascota haces check-in
  void _showCheckInDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("¿Con quién estás en el parque?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              // Aquí usarías el UsuarioProvider para listar tus mascotas[cite: 9]
              ListTile(
                leading: const CircleAvatar(child: Text("🐶")),
                title: const Text("Toby"),
                onTap: () {
                  // Lógica para enviar el check-in al backend
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}