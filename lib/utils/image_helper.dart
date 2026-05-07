class ImageHelper {
  // URLs de imágenes por defecto
  static const String defaultUser = "https://firebasestorage.googleapis.com/v0/b/pawpark-26b38.firebasestorage.app/o/person_default.png?alt=media&token=55bf0c34-547e-4517-bb11-cd202572caa7";
  static const String defaultPet = "https://firebasestorage.googleapis.com/v0/b/pawpark-26b38.firebasestorage.app/o/dog_default.png?alt=media&token=61f37e02-5c11-4456-ae75-2af2132c1813";

  static String getFoto(String? path, {bool isUser = true}) {
    // Si no hay path, devolvemos una imagen por defecto
    if (path == null || path.isEmpty) {
      return isUser ? defaultUser : defaultPet;
    }
    // Si el path ya es una URL (Firebase), la devolvemos tal cual
    if (path.startsWith("http")) {
      return path;
    }
    // Caso de transición: si aún tengo nombres de archivos viejos
    // Útil mientras limpio la base de datos local
    return "http://10.0.2.2:8081/uploads/$path";
  }

  // Estos métodos llaman automáticamente a getFoto para que no tener que cambiar nada en los otros archivos
  static String user(String? path) => getFoto(path, isUser: true);
  static String pet(String? path) => getFoto(path, isUser: false);
}