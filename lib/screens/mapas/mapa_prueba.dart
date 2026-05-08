import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // Importante añadir
import '../../api/model/zona_model.dart';
import '../../api/service/mapa_service.dart';

class MapaPrueba extends StatefulWidget {
  const MapaPrueba({super.key});

  @override
  State<MapaPrueba> createState() => _MapaPruebaState();
}

class _MapaPruebaState extends State<MapaPrueba> {
  // Posición inicial por defecto (Isla Cristina) por si falla el GPS
  LatLng centroActual = const LatLng(37.2014, -7.3218);
  List<Zona> zonasCercanas = [];
  bool cargando = true;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _cargarMapa();
  }

  /// 1. Obtener ubicación y sincronizar con el Backend
  void _cargarMapa() async {
    try {
      Position pos = await _determinarPosicion();

      setState(() {
        centroActual = LatLng(pos.latitude, pos.longitude);
      });

      // Mover la cámara a la ubicación del usuario
      _mapController.move(centroActual, 14.5);

      // 1. Buscamos en OpenStreetMap (Parques y Plazas)
      var osmZonas = await MapaService.buscarZonasEnOSM(pos.latitude, pos.longitude);

      // 2. Sincronizamos con tu Backend Java para ver cuántos perros hay
      var zonasConStats = await MapaService.sincronizarConBackend(osmZonas);

      setState(() {
        zonasCercanas = zonasConStats;
        cargando = false;
      });
    } catch (e) {
      print("Error cargando el mapa: $e");
      setState(() => cargando = false);
    }
  }

  /// Función para gestionar permisos de GPS
  Future<Position> _determinarPosicion() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('GPS desactivado');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Permiso denegado');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                /// 🗺️ SECCIÓN DEL MAPA
                Expanded(
                  flex: 3,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: centroActual,
                      initialZoom: 14.5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.pawpark.app',
                      ),
        
                      /// 📍 MARCADORES DINÁMICOS
                      MarkerLayer(
                        markers: [
                          // Marcador de la posición del usuario
                          Marker(
                            point: centroActual,
                            child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                          ),
                          // Marcadores de Parques y Plazas
                          ...zonasCercanas.map((zona) => Marker(
                            point: LatLng(zona.latitud, zona.longitud),
                            child: GestureDetector(
                              onTap: () => _mostrarDetallesZona(zona),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    zona.tipo == 'park' ? Icons.nature_outlined : Icons.account_balance_rounded,
                                    color: Colors.green.shade700,
                                    size: 40,
                                  ),
                                  if (zona.perrosPresentes > 0)
                                    Positioned(
                                      right: 0, top: 0,
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.red,
                                        child: Text(
                                          zona.perrosPresentes.toString(),
                                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ),
                          )).toList(),
                        ],
                      ),
                    ],
                  ),
                ),
        
                /// 📋 LISTA INFERIOR (RESUMEN)
                Expanded(
                  flex: 2,
                  child: cargando
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: zonasCercanas.length,
                    itemBuilder: (context, index) {
                      final zona = zonasCercanas[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(zona.tipo == 'park' ? Icons.park : Icons.location_city),
                          title: Text(zona.nombre),
                          subtitle: Text("${zona.perrosPresentes} perritos presentes"),
                          onTap: () => _mostrarDetallesZona(zona),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
        
            // Botón flotante para refrescar la zona actual
            Positioned(
              right: 20,
              top: 40,
              child: FloatingActionButton.small(
                onPressed: _cargarMapa,
                child: const Icon(Icons.refresh),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _mostrarDetallesZona(Zona zona) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => _buildBottomSheetContent(zona),
    );
  }

  // Aquí integrarías el contenido del BottomSheet que ya tenías
  Widget _buildBottomSheetContent(Zona zona) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(zona.nombre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("Hay ${zona.perrosPresentes} mascotas aquí ahora mismo"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Aquí llamarías a MapaService.hacerCheckIn(...)
              Navigator.pop(context);
            },
            child: const Text("Hacer Check-in"),
          )
        ],
      ),
    );
  }
}