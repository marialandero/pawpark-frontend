import 'dart:io';
import 'package:flutter/material.dart';
import '../api/model/post_model.dart';
import '../api/service/post_service.dart';

class PostProvider extends ChangeNotifier {

  // LISTAS INDEPENDIENTES PARA CADA PESTAÑA
  List<Post> postsGlobales = [];
  List<Post> postsSeguidos = [];
  List<Post> misPosts = [];
  bool isLoading = false;
  int? _postIdSeleccionado;

  int? get postIdSeleccionado => _postIdSeleccionado;
  set postIdSeleccionado(int? id) {
    _postIdSeleccionado = id;
    // No hace falta notifyListeners porque esto es solo un almacén de datos temporal
  }


  // CARGAR TODOS LOS FEEDS (Llamada al iniciar la pantalla o hacer pull-to-refresh)
  Future<void> cargarTodoElFeed(String usuarioUid) async {
    isLoading = true;
    notifyListeners();
    try {
      // Lanzamos las tres peticiones en paralelo para que sea más rápido
      final resultados = await Future.wait([
        PostService.fetchFeed(usuarioUid),
        PostService.fetchPostsSeguidos(usuarioUid),
        PostService.fetchPostsByUsuario(usuarioUid, usuarioUid),
      ]);
      postsGlobales = resultados[0];
      postsSeguidos = resultados[1];
      misPosts = resultados[2];
      print("Feeds cargados correctamente");
    } catch (e) {
      debugPrint("Error cargando feeds: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  // TOGGLE LIKE: Maneja la actualización optimista en las 3 listas
  Future<void> toggleLike(int postId, String usuarioUid) async {
    // Buscamos el post en las 3 listas (ya que puede aparecer en varias)
    // y aplicamos el like en todas las listas donde aparezca el post
    _gestionarLikeLocal(postsGlobales, postId);
    _gestionarLikeLocal(postsSeguidos, postId);
    _gestionarLikeLocal(misPosts, postId);
    notifyListeners();
    try {
      final success = await PostService.toggleLike(postId, usuarioUid); // Petición al servidor
      if (!success) {
        // Si falla el servidor, revertimos el cambio en las 3 listas
        _gestionarLikeLocal(postsGlobales, postId, esReversion: true);
        _gestionarLikeLocal(postsSeguidos, postId, esReversion: true);
        _gestionarLikeLocal(misPosts, postId, esReversion: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error sincronizando like: $e");
      // Si hay error de red, también revertimos
      _gestionarLikeLocal(postsGlobales, postId, esReversion: true);
      _gestionarLikeLocal(postsSeguidos, postId, esReversion: true);
      _gestionarLikeLocal(misPosts, postId, esReversion: true);
      notifyListeners();
    }
  }


  // MÉTODO AUXILIAR PARA NO REPETIR LÓGICA DE LIKES
  // Simplemente busca el post en la lista que le pases y alterna su estado de like
  // MÉTODO AUXILIAR: Acepta 'esReversion' para que no te dé error de compilación
  void _gestionarLikeLocal(List<Post> lista, int postId, {bool esReversion = false}) {
    final index = lista.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = lista[index];
      // El operador "!" siempre invierte el estado actual, sea reversión o no.
      post.liked = !post.liked;
      post.liked ? post.likes++ : post.likes--;
    }
  }


  Future<bool> crearPost({required String rutaImagen, required String uid, required String descripcion, required List<int> mascotasIds}) async {
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
        await cargarTodoElFeed(uid);
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


  Future<bool> eliminarPost(int postId) async {
    try {
      final success = await PostService.eliminarPost(postId);
      if (success) {
        // Si se elimina, lo quitamos de cualquier lista donde esté
        postsGlobales.removeWhere((p) => p.id == postId);
        postsSeguidos.removeWhere((p) => p.id == postId);
        misPosts.removeWhere((p) => p.id == postId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint("Error al eliminar: $e");
      return false;
    }
  }
}