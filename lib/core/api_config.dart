
// Clase para centralizar la url de la API
class ApiConfig {
  /// URL del backend local.
  /// Usamos el puente de Google 10.0.2.2 que apunta a nuestro pc en lugar de
  /// localhost para que el emulador salga de su propio "localhost" y se conecte
  /// con nuestro pc.
  // static const String baseUrl = "http://10.0.2.2:8081";

  /// URL del backend en Railway.
  static const String baseUrl = "https://pawpark-backend-production.up.railway.app";

  // URL para vista desde Swagger -> https://pawpark-backend-production.up.railway.app/swagger-ui/index.html
}