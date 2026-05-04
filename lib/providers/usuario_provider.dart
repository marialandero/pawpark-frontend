import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../api/mascota_model.dart';
import '../api/mascota_service.dart';
import '../api/post_model.dart';
import '../api/post_service.dart';
import '../api/usuario_model.dart';
import '../api/usuario_service.dart';

class UsuarioProvider with ChangeNotifier {
  Usuario? _usuario;
  bool _isLoading = false;

  Usuario? get usuario => _usuario;
  bool get isLoading => _isLoading;

  List<Usuario> _usuarios = [];
  List<Usuario> get usuarios => _usuarios;

  // Carga inicial (llamar al hacer Login)
  Future<void> cargarUsuario(String uid) async {
    _isLoading = true;
    _usuario = null; // Limpia antes de pedir el nuevo
    notifyListeners();
    try {
      debugPrint("Cargando datos para el UID: $uid");
      _usuario = await UsuarioService.fetchPerfil(uid);
    } catch (e) {
      debugPrint("Error Provider al cargar: $e");
      _usuario = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Usuario>> buscarUsuarios(String query) async {
    try {
      return await UsuarioService.buscarUsuarios(query);
    } catch (e) {
      debugPrint("Error buscando usuarios: $e");
      return [];
    }
  }

  // Limpia el rastro del usuario anterior
  void limpiarUsuario() {
    _usuario = null;
    _isLoading = false;
    notifyListeners();
  }

  // Para actualizar datos del perfil
  void actualizarDatosLocales(Usuario nuevoUsuario) {
    _usuario = nuevoUsuario;
    notifyListeners(); // Esto refresca TODAS las pantallas abiertas
  }

  // Para actualizar la descripción de una mascota
  Future<bool> actualizarDescripcionMascota(int mascotaId, String nuevaDesc) async {
    // Llamamos al service y esperamos el objeto completo
    final Mascota? mascotaActualizada = await MascotaService.updateDescripcion(mascotaId, nuevaDesc);

    if (mascotaActualizada != null && _usuario != null) {
      // Buscamos la posición de la mascota en la lista del usuario
      final index = _usuario!.mascotas.indexWhere((m) => m.id == mascotaId);

      if (index != -1) {
        // SUSTITUCIÓN: Reemplazamos la instancia vieja por la nueva.
        // Esto funciona aunque los atributos de Mascota sean 'final'.
        _usuario!.mascotas[index] = mascotaActualizada;

        notifyListeners(); // Redibuja el perfil de la mascota y la lista
        return true;
      }
    }
    return false;
  }

  Future<void> cargarUsuarios() async {
    _usuarios = await UsuarioService.fetchTodos(); // tendrás que crear esto
    notifyListeners();
  }

  // Actualizar foto mascota (backend + estado)
  Future<void> actualizarFotoMascota(
      int mascotaId,
      String nuevaFoto,
      ) async {
    try {
      final Mascota? mascotaActualizada =
      await MascotaService.actualizarFotoMascota(
        mascotaId,
        nuevaFoto,
      );

      if (mascotaActualizada == null) return;

      if (_usuario == null) return;

      final index = _usuario!.mascotas.indexWhere(
            (m) => m.id == mascotaId,
      );

      if (index == -1) return;

      // 🧠 reemplazo seguro del objeto
      _usuario!.mascotas[index] = mascotaActualizada;

      notifyListeners(); // 🔥 refresca UI global
    } catch (e) {
      print("Error provider actualizarFotoMascota: $e");
    }
  }

  Future<void> recargarUsuario() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final usuario = await UsuarioService.fetchPerfil(uid);

    _usuario = usuario;
    notifyListeners();
  }

  List<Post> _postsMascota = [];
  List<Post> get postsMascota => _postsMascota;

  Future<void> cargarPostsMascota(int mascotaId) async {
    try {
      _postsMascota = await PostService.fetchPostsByMascota(mascotaId);
      notifyListeners();
    } catch (e) {
      print("Error cargando posts mascota: $e");
    }
  }

  Future<void> eliminarMascota(int id) async {
    final ok = await MascotaService.eliminarMascota(id);

    if (ok && _usuario != null) {
      _usuario!.mascotas.removeWhere((m) => m.id == id);
      notifyListeners();
    }
  }
}