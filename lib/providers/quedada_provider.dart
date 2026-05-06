import 'package:flutter/material.dart';
import '../api/model/quedada_model.dart';
import '../api/service/quedada_service.dart';

class QuedadaProvider with ChangeNotifier {
  Quedada? _quedadaSeleccionada;
  bool _isLoading = false;

  Quedada? get quedada => _quedadaSeleccionada;
  bool get isLoading => _isLoading;

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
      if (actualizada != null) _quedadaSeleccionada = actualizada;
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
      if (actualizada != null) _quedadaSeleccionada = actualizada;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}