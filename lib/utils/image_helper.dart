class ImageHelper {
  static const String baseUrl = "http://10.0.2.2:8081/uploads/";

  /// 👤 IMAGEN DE USUARIO
  static String user(String? path) {
    if (path == null || path.isEmpty) {
      return "${baseUrl}person_default.png";
    }

    if (path.startsWith("http")) return path;

    return "$baseUrl$path";
  }

  /// 🐶 IMAGEN DE MASCOTA
  static String pet(String? path) {
    if (path == null || path.isEmpty) {
      return "${baseUrl}dog_default.png";
    }

    if (path.startsWith("http")) return path;

    return "$baseUrl$path";
  }
}