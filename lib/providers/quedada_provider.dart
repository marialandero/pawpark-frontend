import 'package:flutter/material.dart';
import '../api/model/quedada_model.dart';
import '../api/service/quedada_service.dart';

class QuedadaProvider with ChangeNotifier {
  Quedada? _quedadaSeleccionada;
  List<Quedada> _listaQuedadas = [];
  bool _isLoading = false;

  Quedada? get quedada => _quedadaSeleccionada;
  List<Quedada> get listaQuedadas => _listaQuedadas;
  bool get isLoading => _isLoading;

  Future<void> cargarTodasLasQuedadas() async {
    _isLoading = true;
    notifyListeners();
    try {
      _listaQuedadas = await QuedadaService.fetchTodas();
    } catch (e) {
      debugPrint("Error al cargar quedadas: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void seleccionarQuedada(Quedada q) {
    _quedadaSeleccionada = q;
    notifyListeners();
  }

  Future<void> unirse(int quedadaId, List<int> mascotasIds, String uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      final payload = {"usuarioUid": uid, "mascotasIds": mascotasIds};
      final actualizada = await QuedadaService.unirse(quedadaId, payload);
      if (actualizada != null) {
        _quedadaSeleccionada = actualizada;
        // Sincronizamos la lista global para que QuedadasScreen se actualice sola
        int index = _listaQuedadas.indexWhere((q) => q.id == actualizada.id);
        if (index != -1) _listaQuedadas[index] = actualizada;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> desapuntarse(int quedadaId, String uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      final payload = {"usuarioUid": uid};
      final actualizada = await QuedadaService.desapuntarse(quedadaId, payload);
      if (actualizada != null) {
        _quedadaSeleccionada = actualizada;
        // Sincronizamos la lista global
        int index = _listaQuedadas.indexWhere((q) => q.id == actualizada.id);
        if (index != -1) _listaQuedadas[index] = actualizada;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}