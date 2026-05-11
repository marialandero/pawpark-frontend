class ImageHelper {
  // Rutas lcales de las imágenes por defecto
  static const String assetDefaultUser = "assets/images/person_default.png";
  static const String assetDefaultPet = "assets/images/dog_default.png";
  // URLs que vienen del backend
  static const String firebaseDefaultUser = "https://firebasestorage.googleapis.com/v0/b/pawpark-26b38.firebasestorage.app/o/person_default.png?alt=media&token=55bf0c34-547e-4517-bb11-cd202572caa7";
  static const String firebaseDefaultPet = "https://firebasestorage.googleapis.com/v0/b/pawpark-26b38.firebasestorage.app/o/dog_default.png?alt=media&token=61f37e02-5c11-4456-ae75-2af2132c1813";

  static String getFoto(String? path, {bool isUser = true}) {
    // Si no hay path, devolvemos una imagen por defecto y la intentamos pillar primero de los assets
    // para no malgastar espacio de firebase
    if (path == null || path.isEmpty || path == firebaseDefaultUser || path == firebaseDefaultPet) {
      return isUser ? assetDefaultUser : assetDefaultPet;
    }
    // Si es una URL de una foto subida por el usuario
    return path;
  }

  // Estos métodos llaman automáticamente a getFoto para que no tener que cambiar nada en los otros archivos
  static String user(String? path) => getFoto(path, isUser: true);
  static String pet(String? path) => getFoto(path, isUser: false);
  static bool isAsset(String path) => path.startsWith("assets/");
}