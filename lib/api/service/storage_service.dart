import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Método privado para comprimir la imagen
  static Future<File?> _comprimirImagen(File file) async {
    // Buscamos una carpeta temporal en el móvil
    final tempDir = await getTemporaryDirectory();
    // Creamos una ruta para el nuevo archivo comprimido
    final targetPath = p.join(
        tempDir.path,
        "comp_${DateTime.now().millisecondsSinceEpoch}.jpg"
    );

    // Ejecutamos la compresión
    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,    // 70% es el punto bueno entre peso y calidad
      minWidth: 1024, // No necesitamos fotos de 4000px para un avatar
      minHeight: 1024,
    );
    return result != null ? File(result.path) : null;
  }

  /// Sube una imagen a Firebase (ahora optimizada)
  static Future<String?> subirImageAFirebase({
    required XFile imagen,
    required String carpeta, // 'usuarios' o 'mascotas'
  }) async {
    File? archivoAsubir;
    File? imagenComprimida;

    try {
      final fileOriginal = File(imagen.path);
      // Intentamos comprimir
      imagenComprimida = await _comprimirImagen(fileOriginal);
      // Si la compresión funcionó, usamos esa. Si no, la original.
      archivoAsubir = imagenComprimida ?? fileOriginal;

      print("-----------------------------------------");
      print("📸 PESO ORIGINAL: ${(fileOriginal.lengthSync() / 1024).toStringAsFixed(2)} KB");

      if (imagenComprimida != null) {
        print("🗜️ PESO COMPRIMIDO: ${(imagenComprimida.lengthSync() / 1024).toStringAsFixed(2)} KB");
        double ahorro = (1 - (imagenComprimida.lengthSync() / fileOriginal.lengthSync())) * 100;
        print("✨ AHORRO: ${ahorro.toStringAsFixed(1)}%");
      }
      print("-----------------------------------------");

      // Creamos la referencia en Firebase
      String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = _storage.ref().child(carpeta).child(fileName);
      // Subida física del archivo (pequeño)
      await ref.putFile(archivoAsubir);
      // Retornamos la URL de descarga
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Error al subir a Firebase: $e");
      return null;
    } finally {
      // IMPORTANTE: Borramos el archivo temporal comprimido para liberar espacio en el móvil
      if (imagenComprimida != null && await imagenComprimida.exists()) {
        await imagenComprimida.delete();
      }
    }
  }
}