class Zona {
  final String osmId;
  final String nombre;
  final double latitud;
  final double longitud;
  final String tipo;
  int perrosPresentes; // Esto viene de ZonaStatsDTO
  bool tieneSeguidos;
  bool tieneSeguidosFavoritos;
  List<UsuarioPresente> usuarios;

  Zona({
    required this.osmId,
    required this.nombre,
    required this.latitud,
    required this.longitud,
    required this.tipo,
    this.perrosPresentes = 0,
    this.tieneSeguidos = false,
    this.tieneSeguidosFavoritos = false,
    this.usuarios = const [],
  });


  // Para recibir del backend (ZonaStatsDTO)
  factory Zona.fromJson(Map<String, dynamic> json) {
    return Zona(
      osmId: json['osmId'],
      nombre: json['nombre'],
      latitud: json['latitud'],
      longitud: json['longitud'],
      tipo: json['tipo'] ?? 'park',
      perrosPresentes: json['perrosPresentes'] ?? 0,
      tieneSeguidos: json['tieneSeguidos'] ?? false,
      tieneSeguidosFavoritos: json['tieneSeguidosFavoritos'] ?? false,
      usuarios: (json['usuarios'] as List? ?? [])
          .map((u) => UsuarioPresente.fromJson(u))
          .toList(),
    );
  }


  // Para enviar al backend (ZonaRequest)
  Map<String, dynamic> toJson() => {
    'osmId': osmId,
    'nombre': nombre,
    'latitud': latitud,
    'longitud': longitud,
    'tipo': tipo,
    'perrosPresentes': perrosPresentes,
    'tieneSeguidos': tieneSeguidos,
    'tieneSeguidosFavoritos': tieneSeguidosFavoritos,
  };
}


// Nueva clase para los datos que vienen en UsuarioPresenteDTO de Java
class UsuarioPresente {
  final String nombre;
  final String fotoPerfil;
  final String uid;
  final List<String> mascotas;

  UsuarioPresente({
    required this.nombre,
    required this.fotoPerfil,
    required this.uid,
    required this.mascotas,
  });

  factory UsuarioPresente.fromJson(Map<String, dynamic> json) {
    return UsuarioPresente(
      // 'usuario' es el nombre que pusiste en el DTO de Java
      nombre: json['usuario'] ?? 'Anónimo',
      fotoPerfil: json['fotoPerfil'] ?? '',
      uid: json['firebaseUid'] ?? '',
      mascotas: List<String>.from(json['mascotas'] ?? []),
    );
  }
}