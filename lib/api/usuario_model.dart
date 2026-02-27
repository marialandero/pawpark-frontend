class Usuario {
  final String nombre;
  final String nickname;
  final String localidad;
  final String fotoPerfil;
  final String memberSince;
  final int encountersCount;
  final List<dynamic> mascotas;

  Usuario({
    required this.nombre,
    required this.nickname,
    required this.localidad,
    required this.fotoPerfil,
    required this.memberSince,
    required this.encountersCount,
    required this.mascotas,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nombre: json['nombre'] ?? '',
      nickname: json['nickname'] ?? '',
      localidad: json['localidad'] ?? '',
      fotoPerfil: json['fotoPerfil'] ?? 'https://via.placeholder.com/150',
      memberSince: json['memberSince'] ?? '2026',
      encountersCount: json['encountersCount'] ?? 0,
      mascotas: json['mascotas'] ?? [],
    );
  }
}