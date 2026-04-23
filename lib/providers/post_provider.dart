import 'package:flutter/material.dart';
import '../api/post_model.dart';
import '../api/post_service.dart';

class PostProvider extends ChangeNotifier {
  List<Post> _posts = [];
  bool isLoading = false;

  List<Post> get posts => _posts;

  /// 🔥 CARGAR FEED
  Future<void> cargarFeed() async {
    isLoading = true;
    notifyListeners();

    try {
      _posts = await PostService.fetchFeed();
    } catch (e) {
      debugPrint("Error cargando feed: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// ❤️ LIKE LOCAL (sin backend aún)
  void toggleLike(Post post) {
    post.liked = !post.liked;
    post.liked ? post.likes++ : post.likes--;

    notifyListeners();
  }

  /// ➕ CREAR POST
  Future<bool> crearPost({
    required String uid,
    required String imagenUrl,
    required String? descripcion,
    required List<int> mascotasIds,
  }) async {
    final payload = {
      "firebaseUidAutor": uid,
      "rutaImagen": imagenUrl,
      "descripcion": descripcion ?? "",
      "mascotasIds": mascotasIds,
    };

    isLoading = true;
    notifyListeners();

    try {
      final success = await PostService.crearPost(payload);

      if (success) {
        await cargarFeed(); // 🔥 refresca feed automáticamente
      }

      return success;
    } catch (e) {
      debugPrint("Error creando post: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}