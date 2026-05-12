import 'dart:async';
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
import '../../widgets/bottom_bar.dart';
import '../../providers/zona_provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  Usuario? usuarioLogueado;
  final MapController _mapController = MapController();
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  // Ubicación predeterminada: Isla Cristina
  LatLng centroActual = LatLng(37.2014, -7.3218);
  List<String> perritosSeleccionados = [];
  Zona? zonaSeleccionadaEnMapa;
  Timer? _timerRefresco; // Controlador de tiempo

  @override
  void initState() {
    super.initState();
    _cargarDatos(); // Lanzamos la carga de datos y GPS inmediatamente al entrar
    // INICIAMOS EL AUTO-REFRESCO cada 30 segundos
    _timerRefresco = Timer.periodic(const Duration(seconds: 30), (timer) {
      _refrescarZonasSilencioso();
    });
  }

  @override
  void dispose() {
    // Importante ancelar el timer cuando salgas de la pantalla para que
    // la app no vaya lenta ni gaste batería de más
    _timerRefresco?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // Método para refrescar solo las zonas sin mover la cámara ni mostrar loadings pesados
  Future<void> _refrescarZonasSilencioso() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !mounted) return;

    // Solo llamamos al provider para que sincronice con Java
    // Usamos las coordenadas actuales donde esté el mapa o el usuario
    context.read<ZonaProvider>().cargarZonas(
        centroActual.latitude,
        centroActual.longitude,
        uid
    );
  }

  Future<void> _cargarDatos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // LANZAMOS LAS DOS COSAS A LA VEZ (Sin el await delante)
    final futurePerfil = UsuarioService.fetchPerfil(uid);
    final futureGPS = _determinarPosicion();

    try {
      // Esperamos el perfil primero para poder dibujar la pantalla
      final user = await futurePerfil;
      if (mounted) setState(() => usuarioLogueado = user);

      // En cuanto tenemos el perfil, lanzamos una carga de zonas "por defecto" (Isla Cristina)
      // para que aparezcan pins YA, mientras el GPS sigue pensando.
      context.read<ZonaProvider>().cargarZonas(centroActual.latitude, centroActual.longitude, user.firebaseUid);

      // Ahora esperamos al GPS (que ya lleva un rato buscando en segundo plano)
      Position pos = await futureGPS;
      if (mounted) {
        LatLng ubicacionReal = LatLng(pos.latitude, pos.longitude);
        setState(() => centroActual = ubicacionReal);
        _mapController.move(ubicacionReal, 16.0);

        // Actualizamos zonas a la posición real
        context.read<ZonaProvider>().cargarZonas(pos.latitude, pos.longitude, user.firebaseUid);
      }
    } catch (e) {
      debugPrint("Error o GPS lento: $e");
    }
  }

  IconData _getIconoPorTipo(String tipo) {
    switch (tipo) {
      case 'parque': return Symbols.nature;
      case 'plaza': return Symbols.deck;
      case 'playa': return Symbols.beach_access;
      default: return Symbols.sound_detection_dog_barking;
    }
  }

  Future<Position> _determinarPosicion() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Servicio desactivado');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Permiso denegado');
    }

    if (permission == LocationPermission.deniedForever) return Future.error('Permisos bloqueados');

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 5), // No esperamos más de 5 seg
    );
  }

  // LÓGICA DE NAVEGACIÓN ENTRE ZONAS
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
        title: Text("¿Cambiar de zona?"),
        content: Text("Ya estás en un parque. Si confirmas ir a ${nuevaZona.nombre}, se irán tus perritos de la zona anterior automáticamente."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("CANCELAR")),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                _mostrarSeleccionPerritos(nuevaZona, user, provider);
              },
              child: Text("SÍ, CAMBIAR")
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
          SizedBox(width: 10),
        ],
      ),
      bottomNavigationBar: BottomBar(currentIndex: 0),
      body: usuarioLogueado == null
      ? Center(child: CircularProgressIndicator())
      : Stack(
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
                      colorFilter: ColorFilter.matrix([
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
                            _sheetController.animateTo(0.12, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                          },
                          child: Icon(
                            _getIconoPorTipo(zona.tipo),
                            fill: 1,
                            weight: 700,
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
                  child: _buildCardCheckInMapa(color, usuarioLogueado!, zonaProvider),
                ),

              _buildDraggableSheet(color, usuarioLogueado!, zonaProvider),
            ],
          )
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: color.onSurfaceVariant.withOpacity(0.4), borderRadius: BorderRadius.circular(10))),
                SizedBox(height: 12),
                Text("Zonas cercanas", style: TextStyle(color: color.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),

                provider.cargando
                    ? Padding(padding: EdgeInsets.only(top: 50), child: Center(child: CircularProgressIndicator()))
                    : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: provider.zonas.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => Divider(color: color.outlineVariant),
                  itemBuilder: (context, index) {
                    final zona = provider.zonas[index];
                    return ListTile(
                      onTap: () {
                        Navigator.pushNamed(
                            context,
                            "/asistentes",
                          arguments: zona.osmId
                        );
                      },
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: color.secondary.withOpacity(0.1),
                        child: Icon(
                          _getIconoPorTipo(zona.tipo),
                          color: color.secondary,
                          fill: 1,
                          weight: 600,
                          size: 22,
                        ),
                      ),
                      title: Text(zona.nombre, style: TextStyle(color: color.onSurface, fontWeight: FontWeight.bold)),
                      subtitle: Text("${zona.perrosPresentes} ${zona.perrosPresentes == 1 ? 'perrito ahora' : 'perritos ahora'}"),
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
        leading: Icon(
          _getIconoPorTipo(zonaSeleccionadaEnMapa!.tipo),
          color: color.secondary,
          fill: 1,
          weight: 600,
          size: 28,
        ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Estoy en ${zona.nombre}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  if (user.mascotas.isEmpty) Text("No tienes perritos registrados."),
                  ...user.mascotas.map((mascota) => CheckboxListTile(
                    title: Text(mascota.nombre),
                    secondary: Icon(Icons.pets),
                    value: perritosSeleccionados.contains(mascota.id.toString()),
                    onChanged: (bool? value) {
                      setModalState(() {
                        if (value!) perritosSeleccionados.add(mascota.id.toString());
                        else perritosSeleccionados.remove(mascota.id.toString());
                      });
                    },
                  )).toList(),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: perritosSeleccionados.isEmpty ? null : () async {
                        Navigator.pop(context);
                        bool exito = await provider.hacerCheckIn(user.firebaseUid, perritosSeleccionados, zona);
                        if (mounted) {
                          if (exito) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("¡Check-in confirmado! Disfrutad."), backgroundColor: color.tertiary)
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text("CANCELAR")),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
            },
            child: Text("SALIR", style: TextStyle(color: color.secondary)),
          ),
        ],
      ),
    );
  }
}