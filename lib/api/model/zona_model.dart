class Zona {
  final String osmId;
  final String nombre;
  final double latitud;
  final double longitud;
  final String tipo;
  int perrosPresentes; // Esto viene de ZonaStatsDTO

  Zona({
    required this.osmId,
    required this.nombre,
    required this.latitud,
    required this.longitud,
    required this.tipo,
    this.perrosPresentes = 0,
  });

  // Para enviar al backend (ZonaRequest)
  Map<String, dynamic> toJson() => {
    'osmId': osmId,
    'nombre': nombre,
    'latitud': latitud,
    'longitud': longitud,
    'tipo': tipo,
  };

  // Para recibir del backend (ZonaStatsDTO)
  factory Zona.fromJson(Map<String, dynamic> json) {
    return Zona(
      osmId: json['osmId'],
      nombre: json['nombre'],
      latitud: json['latitud'],
      longitud: json['longitud'],
      tipo: json['tipo'] ?? 'park',
      perrosPresentes: json['perrosPresentes'] ?? 0,
    );
  }
}