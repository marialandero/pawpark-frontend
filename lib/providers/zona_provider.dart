import 'package:flutter/material.dart';
import '../api/model/zona_model.dart';
import '../api/service/mapa_service.dart';

class ZonaProvider with ChangeNotifier {
  List<Zona> _zonas = [];
  String? _idZonaDondeEstoy;
  int _cantidadPerritosActuales = 0; // Guardamos cuántos llevamos para restar luego
  bool _cargando = false;

  List<Zona> get zonas => _zonas;
  String? get idZonaDondeEstoy => _idZonaDondeEstoy;
  bool get cargando => _cargando;

  Future<void> cargarZonas(double lat, double lng) async {
    _cargando = true;
    notifyListeners();
    try {
      var osmZonas = await MapaService.buscarZonasEnOSM(lat, lng);
      _zonas = await MapaService.sincronizarConBackend(osmZonas);
      // Ordenar por cercanía si fuera necesario aquí
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // Lógica principal de Check-in y Traslado
  void hacerCheckIn(String uid, List<String> perritosIds, Zona nuevaZona) {
    // 1. Si ya estábamos en un sitio, restamos nuestros perros de allí
    if (_idZonaDondeEstoy != null) {
      _modificarContadorLocal(_idZonaDondeEstoy!, -_cantidadPerritosActuales);
    }

    // 2. Actualizamos a la nueva zona
    _idZonaDondeEstoy = nuevaZona.osmId;
    _cantidadPerritosActuales = perritosIds.length;

    // 3. Sumamos a la nueva zona
    _modificarContadorLocal(nuevaZona.osmId, _cantidadPerritosActuales);

    notifyListeners();
    // Aquí llamarías a tu API: MapaService.hacerCheckIn(...)
  }

  void notificarSalida(String uid) {
    if (_idZonaDondeEstoy != null) {
      _modificarContadorLocal(_idZonaDondeEstoy!, -_cantidadPerritosActuales);
      _idZonaDondeEstoy = null;
      _cantidadPerritosActuales = 0;
      notifyListeners();
      // MapaService.notificarSalida(uid);
    }
  }

  // Función auxiliar para no repetir código
  void _modificarContadorLocal(String osmId, int cantidad) {
    final index = _zonas.indexWhere((z) => z.osmId == osmId);
    if (index != -1) {
      _zonas[index].perrosPresentes += cantidad;
      if (_zonas[index].perrosPresentes < 0) _zonas[index].perrosPresentes = 0;
    }
  }
}