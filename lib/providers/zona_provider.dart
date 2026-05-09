import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../api/model/zona_model.dart';
import '../api/service/mapa_service.dart';

class ZonaProvider with ChangeNotifier {
  List<Zona> _zonas = [];
  String? _idZonaDondeEstoy;
  int _cantidadPerritosActuales = 0;
  bool _cargando = false;

  // Getters
  List<Zona> get zonas => _zonas;
  String? get idZonaDondeEstoy => _idZonaDondeEstoy;
  bool get cargando => _cargando;

  Future<void> cargarZonas(double lat, double lng, String uidActual) async {
    _cargando = true;
    notifyListeners();

    try {
      // 1. Traemos las zonas de OSM
      var osmZonas = await MapaService.buscarZonasEnOSM(lat, lng);

      // 2. Sincronizamos con el Backend (MySQL)
      // El backend ahora debería devolver info de quién está en cada zona
      var zonasConDatos = await MapaService.sincronizarConBackend(osmZonas);

      // 3. APLICAR PRIORIDADES DE ORDENACIÓN
      zonasConDatos.sort((a, b) {
        // REGLA 1: Usuarios seguidos con mascotas favoritas (Suponiendo que el backend envía este flag)
        if (a.tieneSeguidosFavoritos && !b.tieneSeguidosFavoritos) return -1;
        if (!a.tieneSeguidosFavoritos && b.tieneSeguidosFavoritos) return 1;

        // REGLA 2: Usuarios seguidos
        if (a.tieneSeguidos && !b.tieneSeguidos) return -1;
        if (!a.tieneSeguidos && b.tieneSeguidos) return 1;

        // REGLA 3: Resto de usuarios (Zonas con gente vs Zonas vacías)
        if (a.perrosPresentes > 0 && b.perrosPresentes == 0) return -1;
        if (a.perrosPresentes == 0 && b.perrosPresentes > 0) return 1;

        // REGLA 4: Cercanía de la zona (Si todo lo anterior es igual)
        double distA = Geolocator.distanceBetween(lat, lng, a.latitud, a.longitud);
        double distB = Geolocator.distanceBetween(lat, lng, b.latitud, b.longitud);
        return distA.compareTo(distB);
      });

      _zonas = zonasConDatos;
    } catch (e) {
      debugPrint("Error en Provider: $e");
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // --- CONEXIÓN REAL CON BACKEND ---
  Future<bool> hacerCheckIn(String uid, List<String> mascotasId, Zona zona) async {
    String? oldId = _idZonaDondeEstoy;
    int oldCantidad = _cantidadPerritosActuales;

    // Actualización optimista
    if (_idZonaDondeEstoy != null) {
      _modificarContadorLocal(_idZonaDondeEstoy!, -_cantidadPerritosActuales);
    }
    _idZonaDondeEstoy = zona.osmId;
    _cantidadPerritosActuales = mascotasId.length;
    _modificarContadorLocal(zona.osmId, _cantidadPerritosActuales);
    notifyListeners();

    try {
      // El nombre del parámetro aquí debe ser consistente con lo que espera el service
      bool exito = await MapaService.hacerCheckIn(uid, mascotasId, zona.osmId);

      if (!exito) {
        // ROLLBACK si falla el servidor
        _idZonaDondeEstoy = oldId;
        _cantidadPerritosActuales = oldCantidad;
        _modificarContadorLocal(zona.osmId, -mascotasId.length);
        if (_idZonaDondeEstoy != null) {
          _modificarContadorLocal(_idZonaDondeEstoy!, _cantidadPerritosActuales);
        }
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      // ROLLBACK si hay error de red
      return false;
    }
  }

  Future<void> notificarSalida(String uid) async {
    if (_idZonaDondeEstoy == null) return;

    String idABorrar = _idZonaDondeEstoy!;
    int cantidadARestar = _cantidadPerritosActuales;

    // Actualización optimista
    _modificarContadorLocal(idABorrar, -cantidadARestar);
    _idZonaDondeEstoy = null;
    notifyListeners();

    // Backend
    bool exito = await MapaService.notificarSalida(uid);
    if (!exito) {
      _idZonaDondeEstoy = idABorrar;
      _modificarContadorLocal(idABorrar, cantidadARestar);
      notifyListeners();
    }
  }

  void _modificarContadorLocal(String osmId, int cantidad) {
    final index = _zonas.indexWhere((z) => z.osmId == osmId);
    if (index != -1) {
      _zonas[index].perrosPresentes += cantidad;
      if (_zonas[index].perrosPresentes < 0) _zonas[index].perrosPresentes = 0;
    }
  }
}