import 'package:pawpark_frontend/api/mascota_model.dart';

class Usuario {
  final String firebaseUid;
  final String nombre;
  final String email;
  final String nickname;
  final String descripcion;
  final String localidad;
  final String fotoPerfil;
  final String memberSince;
  final int encountersCount;
  final List<Mascota> mascotas;
  final List<dynamic> amigos;

  Usuario({
    required this.firebaseUid,
    required this.nombre,
    required this.email,
    required this.nickname,
    required this.descripcion,
    required this.localidad,
    required this.fotoPerfil,
    required this.memberSince,
    required this.encountersCount,
    required this.mascotas,
    required this.amigos
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      firebaseUid: json['firebaseUid'] ?? '',
      nombre: json['nombre'] ?? '',
        email: json['email'] ?? '',
      nickname: json['nickname'] ?? '',
      localidad: json['localidad'] ?? '',
        descripcion: json['descripcion'] ?? '',
        fotoPerfil: json['fotoPerfil'] ?? '',
      memberSince: json['memberSince'] ?? '2026',
      encountersCount: json['encountersCount'] ?? 0,
      mascotas: (json['mascotas'] as List?)
            ?.map((m) => Mascota.fromJson(m))
            .toList() ?? [],
        amigos: (json['amigos'] as List?) ?? []
    );
  }
}