import 'dart:io';
import 'package:flutter/material.dart';
import '../api/model/post_model.dart';
import '../api/service/post_service.dart';

class PostProvider extends ChangeNotifier {

  // La lista solo aceptará objetos tipo Post
  List<Post> posts = [];
  bool isLoading = false;
  int? _postIdSeleccionado;

  int? get postIdSeleccionado => _postIdSeleccionado;
  set postIdSeleccionado(int? id) {
    _postIdSeleccionado = id;
    // No hace falta notifyListeners porque esto es solo un almacén de datos temporal
  }


  Future<void> cargarFeed(String usuarioUid) async {
    print("Cargando feed para UID: $usuarioUid");
    isLoading = true;
    notifyListeners();

    try {
      // Recibimos la lista ya mapeada desde el service
      final nuevosPosts = await PostService.fetchFeed(usuarioUid);
      posts = nuevosPosts;
      print("Posts recibidos: ${posts.length}");
    } catch (e) {
      debugPrint("Error feed: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> crearPost({
    required String rutaImagen,
    required String uid,
    required String descripcion,
    required List<int> mascotasIds,
  }) async {

    isLoading = true;
    notifyListeners();

    try {

      final success = await PostService.crearPost({
        "firebaseUidAutor": uid,
        "rutaImagen": rutaImagen,
        "descripcion": descripcion,
        "mascotasIds": mascotasIds,
      });

      if (success) {
        // ESPERA DE SEGURIDAD: 500ms son imperceptibles para el usuario
        // pero vitales para que MySQL termine su trabajo.
        await Future.delayed(const Duration(milliseconds: 500));
        await cargarFeed(uid);
      }

      return success;

    } catch (e) {
      debugPrint("Error en Provider: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ❤️ NUEVO MÉTODO: Toggle Like con persistencia en Backend
  Future<void> toggleLike(int postId, String usuarioUid) async {
    // 1. Buscamos el post en la lista local
    final index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = posts[index];

    // 2. ACTUALIZACIÓN OPTIMISTA: Cambiamos la UI antes de la respuesta del servidor
    // para que la app se sienta rápida (sin lag en el corazón)
    post.liked = !post.liked;
    post.liked ? post.likes++ : post.likes--;
    notifyListeners();

    try {
      // 3. Petición real al servidor
      final success = await PostService.toggleLike(postId, usuarioUid);

      if (!success) {
        // Si el servidor responde error, revertimos el cambio local
        _revertirLike(post);
      }
    } catch (e) {
      debugPrint("Error al sincronizar like: $e");
      _revertirLike(post);
    }
  }

  // Método privado para revertir en caso de error de red
  void _revertirLike(Post post) {
    post.liked = !post.liked;
    post.liked ? post.likes++ : post.likes--;
    notifyListeners();
  }

  /// 🗑️ PRÓXIMO PASO: Eliminar Post (Para tu lista de tareas)
  Future<bool> eliminarPost(int postId) async {
    try {
      final success = await PostService.eliminarPost(postId);
      if (success) {
        posts.removeWhere((p) => p.id == postId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}