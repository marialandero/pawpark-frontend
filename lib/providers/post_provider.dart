import 'dart:io';
import 'package:flutter/material.dart';
import '../api/model/post_model.dart';
import '../api/service/post_service.dart';

class PostProvider extends ChangeNotifier {

  // La lista solo aceptará objetos tipo Post
  List<Post> posts = [];
  bool isLoading = false;

  Future<void> cargarFeed() async {
    isLoading = true;
    notifyListeners();

    try {
      // Recibimos la lista ya mapeada desde el service
      posts = await PostService.fetchFeed();
    } catch (e) {
      debugPrint("Error feed: $e");
    }

    isLoading = false;
    notifyListeners();
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
        await cargarFeed();
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

  void toggleLikeLocal(Post post) {
    post.liked = !post.liked;
    post.liked ? post.likes++ : post.likes--;
    notifyListeners();
  }
}