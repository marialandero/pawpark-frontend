import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../api/model/usuario_model.dart';
import '../../api/model/zona_model.dart';
import '../../api/service/usuario_service.dart';
import '../../api/service/mapa_service.dart';
import '../../widgets/bottom_bar.dart';
import '../../providers/zona_provider.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  late Future<Usuario> futureUsuario;
  final MapController _mapController = MapController();
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  LatLng centroActual = const LatLng(37.2014, -7.3218);
  List<String> perritosSeleccionados = [];
  Zona? zonaSeleccionadaEnMapa;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    futureUsuario = UsuarioService.fetchPerfil(uid ?? "");

    // Carga inicial con un pequeño delay para estabilidad del GPS
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Position pos = await _determinarPosicion();
      if (mounted) {
        setState(() => centroActual = LatLng(pos.latitude, pos.longitude));
        _mapController.move(centroActual, 16.0);
        await Future.delayed(const Duration(milliseconds: 500));
        // 1. Obtenemos el UID del usuario logueado (necesario para el orden de prioridad social)
        final String uidActual = FirebaseAuth.instance.currentUser?.uid ?? "";
        context.read<ZonaProvider>().cargarZonas(pos.latitude, pos.longitude, uidActual);
      }
    });
  }

  IconData _getIconoPorTipo(String tipo) {
    switch (tipo) {
      case 'parque': return Icons.park;
      case 'plaza': return Icons.account_balance;
      case 'playa': return Icons.beach_access;
      default: return Icons.nature_people;
    }
  }

  Future<Position> _determinarPosicion() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition();
  }

  // --- LÓGICA DE NAVEGACIÓN ENTRE ZONAS ---
  void _gestionarAccionVoy(Zona zona, Usuario user, ZonaProvider provider) {
    if (provider.idZonaDondeEstoy != null && provider.idZonaDondeEstoy != zona.osmId) {
      // Si ya estoy en un sitio y pulso en OTRO diferente
      _mostrarDialogoCambioZona(zona, user, provider);
    } else if (provider.idZonaDondeEstoy == zona.osmId) {
      // Si pulso en el sitio donde ya estoy
      _confirmarSalida(user.firebaseUid, provider);
    } else {
      // Si no estoy en ningún sitio
      _mostrarSeleccionPerritos(zona, user, provider);
    }
  }

  void _mostrarDialogoCambioZona(Zona nuevaZona, Usuario user, ZonaProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Cambiar de zona?"),
        content: Text("Ya estás en un parque. Si confirmas ir a ${nuevaZona.nombre}, se restarán tus perritos de la zona anterior automáticamente."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                _mostrarSeleccionPerritos(nuevaZona, user, provider);
              },
              child: const Text("SÍ, CAMBIAR")
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final zonaProvider = context.watch<ZonaProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
              ? Brightness.light : Brightness.dark,
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _cargarDatos,
            icon: CircleAvatar(
                backgroundColor: color.surface.withOpacity(0.8),
                child: Icon(Icons.refresh, color: color.primary)
            ),
          ),
          IconButton(
            onPressed: () => showSignOutConfirmation(color),
            icon: CircleAvatar(
                backgroundColor: color.surface.withOpacity(0.8),
                child: Icon(Icons.logout, color: color.primary)
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      bottomNavigationBar: BottomBar(currentIndex: 0),
      body: FutureBuilder<Usuario>(
        future: futureUsuario,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final user = snapshot.data!;

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: centroActual,
                  initialZoom: 16.0,
                  onTap: (_, __) => setState(() => zonaSeleccionadaEnMapa = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.pawpark.app',
                    tileBuilder: Theme.of(context).brightness == Brightness.dark
                        ? (context, tileWidget, tile) => ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        -1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0,
                      ]),
                      child: tileWidget,
                    ) : null,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: centroActual,
                        width: 40, height: 40,
                        child: Icon(Icons.my_location, color: color.primary, size: 30),
                      ),
                      ...zonaProvider.zonas.map((zona) => Marker(
                        point: LatLng(zona.latitud, zona.longitud),
                        width: 45, height: 45,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => zonaSeleccionadaEnMapa = zona);
                            _sheetController.animateTo(0.12, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                          },
                          child: Icon(
                            _getIconoPorTipo(zona.tipo),
                            // AZUL si es mi zona activa, VERDE si hay otros perros, ROJO si está vacío
                            color: zonaProvider.idZonaDondeEstoy == zona.osmId
                                ? color.primary
                                : (zona.perrosPresentes > 0 ? Colors.green : color.secondary),
                            size: 35,
                          ),
                        ),
                      )).toList(),
                    ],
                  ),
                ],
              ),

              if (zonaSeleccionadaEnMapa != null)
                Positioned(
                  top: 100, left: 20, right: 20,
                  child: _buildCardCheckInMapa(color, user, zonaProvider),
                ),

              _buildDraggableSheet(color, user, zonaProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDraggableSheet(ColorScheme color, Usuario user, ZonaProvider provider) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.4,
      minChildSize: 0.15,
      maxChildSize: 0.65,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: color.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: color.onSurfaceVariant.withOpacity(0.4), borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 12),
                Text("Zonas cercanas", style: TextStyle(color: color.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                provider.cargando
                    ? const Padding(padding: EdgeInsets.only(top: 50), child: Center(child: CircularProgressIndicator()))
                    : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: provider.zonas.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => Divider(color: color.outlineVariant),
                  itemBuilder: (context, index) {
                    final zona = provider.zonas[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: color.secondary.withOpacity(0.1),
                        child: Icon(_getIconoPorTipo(zona.tipo), color: color.secondary),
                      ),
                      title: Text(zona.nombre, style: TextStyle(color: color.onSurface, fontWeight: FontWeight.bold)),
                      subtitle: Text("${zona.perrosPresentes} perritos ahora"),
                      trailing: _buildBotonAccion(zona, user, provider),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBotonAccion(Zona zona, Usuario user, ZonaProvider provider) {
    bool estoyAqui = provider.idZonaDondeEstoy == zona.osmId;
    return ElevatedButton(
      onPressed: () => _gestionarAccionVoy(zona, user, provider),
      style: ElevatedButton.styleFrom(
        backgroundColor: estoyAqui ? Colors.red[700] : Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(estoyAqui ? "YA ME VOY" : "¡VOY!"),
    );
  }

  Widget _buildCardCheckInMapa(ColorScheme color, Usuario user, ZonaProvider provider) {
    return Card(
      color: color.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(_getIconoPorTipo(zonaSeleccionadaEnMapa!.tipo), color: color.secondary),
        title: Text(zonaSeleccionadaEnMapa!.nombre, style: TextStyle(color: color.onSurface, fontWeight: FontWeight.bold)),
        subtitle: Text("${zonaSeleccionadaEnMapa!.perrosPresentes} perritos ahora"),
        trailing: _buildBotonAccion(zonaSeleccionadaEnMapa!, user, provider),
      ),
    );
  }

  void _mostrarSeleccionPerritos(Zona zona, Usuario user, ZonaProvider provider) {
    final color =Theme.of(context).colorScheme;

    setState(() => perritosSeleccionados.clear());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Check-in en ${zona.nombre}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  if (user.mascotas.isEmpty) const Text("No tienes perritos registrados."),
                  ...user.mascotas.map((mascota) => CheckboxListTile(
                    title: Text(mascota.nombre),
                    secondary: const Icon(Icons.pets),
                    value: perritosSeleccionados.contains(mascota.id.toString()),
                    onChanged: (bool? value) {
                      setModalState(() {
                        if (value!) perritosSeleccionados.add(mascota.id.toString());
                        else perritosSeleccionados.remove(mascota.id.toString());
                      });
                    },
                  )).toList(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: perritosSeleccionados.isEmpty ? null : () async {
                        Navigator.pop(context);
                        bool exito = await provider.hacerCheckIn(user.firebaseUid, perritosSeleccionados, zona);
                        if (mounted) {
                          if (exito) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: const Text("¡Check-in confirmado! Disfrutad."), backgroundColor: color.tertiary)
                            );
                            setState(() => zonaSeleccionadaEnMapa = null);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error al conectar con el servidor. Inténtalo de nuevo."), backgroundColor: color.error)
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(15)),
                      child: Text("CONFIRMAR Y ENTRAR"),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmarSalida(String uid, ZonaProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("¿Te vas ya?"),
        content: Text("Se notificará que has dejado la zona."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("CANCELAR")),
          TextButton(
            onPressed: () async {
              provider.notificarSalida(uid);
              Navigator.pop(context);
              setState(() => zonaSeleccionadaEnMapa = null);
            },
            child: Text("SÍ, ME VOY", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void showSignOutConfirmation(ColorScheme color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cerrar sesión"),
        content: Text("¿Seguro que quieres salir?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
            },
            child: Text("SALIR", style: TextStyle(color: color.error)),
          ),
        ],
      ),
    );
  }
}