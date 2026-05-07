import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sube una imagen a Firebase y devuelve la URL de descarga.
  static Future<String?> subirImageAFirebase({
    required XFile imagen,
    required String carpeta // 'usuarios' o 'mascotas'
  }) async {
    try {
      // Creamos un nombre único para evitar que se pisen fotos
      String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = _storage.ref().child(carpeta).child(fileName);

      // Subida física
      await ref.putFile(File(imagen.path));

      // Retornamos la URL que guardaremos en el Backend
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error al subir a Firebase: $e");
      return null;
    }
  }
}
