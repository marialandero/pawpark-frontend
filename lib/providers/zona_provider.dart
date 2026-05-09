import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../api/model/zona_model.dart';
import '../api/service/mapa_service.dart';

class ZonaProvider with ChangeNotifier {
  List<Zona> _zonas = [];
  String? _idZonaDondeEstoy;
  int _cantidadPerritosActuales = 0;
  bool _cargando = false;

  List<Zona> get zonas => _zonas;
  String? get idZonaDondeEstoy => _idZonaDondeEstoy;
  bool get cargando => _cargando;

  Future<void> cargarZonas(double lat, double lng, String uidActual) async {
    _cargando = true;
    notifyListeners();

    try {
      // Traemos las zonas de OSM
      var osmZonas = await MapaService.buscarZonasEnOSM(lat, lng);

      // Sincronizamos con el Backend (MySQL)
      // El backend ahora debería devolver info de quién está en cada zona
      var zonasConDatos = await MapaService.sincronizarConBackend(osmZonas, uidActual);

      // ORDEN DE PRIORIDADES
      zonasConDatos.sort((a, b) {
        // Usuarios seguidos con mascotas favoritas
        if (a.tieneSeguidosFavoritos && !b.tieneSeguidosFavoritos) return -1;
        if (!a.tieneSeguidosFavoritos && b.tieneSeguidosFavoritos) return 1;

        // Usuarios seguidos
        if (a.tieneSeguidos && !b.tieneSeguidos) return -1;
        if (!a.tieneSeguidos && b.tieneSeguidos) return 1;

        // Resto de usuarios (zonas con perritos vs zonas vacías)
        if (a.perrosPresentes > 0 && b.perrosPresentes == 0) return -1;
        if (a.perrosPresentes == 0 && b.perrosPresentes > 0) return 1;

        // Por cercanía de la zona (Si todo lo anterior es igual)
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

  // CONEXIÓN CON BACKEND
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

      if (exito) {
        // Una vez que el servidor confirma el éxito, refrescamos todas las zonas.
        // Esto limpia los duplicados visuales y aplica el nuevo orden de prioridad.
        await cargarZonas(zona.latitud, zona.longitud, uid);
        return true;
      } else {
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
    } catch (e) {
      // ROLLBACK si hay error de red
      debugPrint("Error en hacerCheckIn: $e");
      _idZonaDondeEstoy = oldId;
      _cantidadPerritosActuales = oldCantidad;
      notifyListeners();
      return false;
    }
  }

  Future<void> notificarSalida(String uid) async {
    if (_idZonaDondeEstoy == null) return;

    // Guardamos los datos por si hay que hacer rollback (marcha atrás)
    String idAnterior = _idZonaDondeEstoy!;
    int cantidadAnterior = _cantidadPerritosActuales;

    // Actualización optimista: Limpiamos la UI al momento
    _modificarContadorLocal(idAnterior, -cantidadAnterior);
    _idZonaDondeEstoy = null;
    _cantidadPerritosActuales = 0; // Resetear contador de mi estancia
    notifyListeners();

    try {
      // Avisamos al backend
      bool exito = await MapaService.notificarSalida(uid);

      if (exito) {
        // Opcional: Podrías volver a pedir la posición actual y llamar a cargarZonas
        // pero con la actualización optimista suele ser suficiente si el servidor responde OK.
        debugPrint("Salida confirmada por el servidor.");
      } else {
        // ROLLBACK: Si el servidor falla, devolvemos al usuario a la zona
        _idZonaDondeEstoy = idAnterior;
        _cantidadPerritosActuales = cantidadAnterior;
        _modificarContadorLocal(idAnterior, cantidadAnterior);
        notifyListeners();
      }
    } catch (e) {
      // Error de red: Rollback también
      _idZonaDondeEstoy = idAnterior;
      _cantidadPerritosActuales = cantidadAnterior;
      _modificarContadorLocal(idAnterior, cantidadAnterior);
      notifyListeners();
      debugPrint("Error al notificar salida: $e");
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