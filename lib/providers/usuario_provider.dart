import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../api/model/mascota_model.dart';
import '../api/service/mascota_service.dart';
import '../api/model/post_model.dart';
import '../api/service/post_service.dart';
import '../api/model/usuario_model.dart';
import '../api/service/usuario_service.dart';

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


  Future<bool> actualizarDatosMascota(int mascotaId, String nuevaDesc, int nuevaEdad) async {
    // Aquí asumo que tu MascotaService.update tiene estos dos parámetros o que usas un Map
    // Si tu service solo acepta descripción, deberás añadir el campo edad allí también
    final Mascota? mascotaActualizada = await MascotaService.updateMascota(
        id: mascotaId,
        descripcion: nuevaDesc,
        edad: nuevaEdad
    );
    if (mascotaActualizada != null && _usuario != null) {
      final index = _usuario!.mascotas.indexWhere((m) => m.id == mascotaId);
      if (index != -1) {
        _usuario!.mascotas[index] = mascotaActualizada;
        notifyListeners();
        return true;
      }
    }
    return false;
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
      // reemplazo seguro del objeto
      _usuario!.mascotas[index] = mascotaActualizada;
      notifyListeners(); // refresca UI global
    } catch (e) {
      print("Error provider actualizarFotoMascota: $e");
    }
  }


  Future<void> recargarUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    // Forzamos la carga desde nuestro backend
    final usuarioDesdeJava = await UsuarioService.fetchPerfil(user.uid);

    if (usuarioDesdeJava != null) {
      _usuario = usuarioDesdeJava;
      if (user.displayName != usuarioDesdeJava.nickname) {
        await user.updateDisplayName(usuarioDesdeJava.nickname);
      }
      debugPrint("Nickname recuperado de DB: ${_usuario?.nickname}");
      notifyListeners();
    }
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


  Future<void> alternarSeguimiento(String targetUid) async {
    if (usuario == null) return;

    final exito = await UsuarioService.alternarSeguimiento(usuario!.firebaseUid, targetUid);

    if (exito) {
      // Refrescamos los datos del usuario para obtener las listas actualizadas
      await cargarUsuario(usuario!.firebaseUid);
      notifyListeners();
    }
  }


  Future<void> alternarMascotaFavorita(int mascotaId) async {
    if (usuario == null) return;

    final exito = await UsuarioService.alternarMascotaFavorita(usuario!.firebaseUid, mascotaId);

    if (exito) {
      await cargarUsuario(usuario!.firebaseUid);
      notifyListeners();
    }
  }
}