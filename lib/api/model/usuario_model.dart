import 'package:pawpark_frontend/api/model/mascota_model.dart';

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
  final List<Usuario> siguiendo;
  final List<Usuario> seguidores;
  final List<Mascota> mascotasFavoritas;
  final int postsCount;

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
    this.siguiendo = const [],
    this.seguidores = const [],
    this.mascotasFavoritas = const [],
    this.postsCount = 0,
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
      siguiendo: (json['siguiendo'] as List?)?.map((i) => Usuario.fromSimpleJson(i)).toList() ?? [],
      seguidores: (json['seguidores'] as List?)?.map((i) => Usuario.fromSimpleJson(i)).toList() ?? [],
      mascotasFavoritas: (json['mascotasFavoritas'] as List?)?.map((i) => Mascota.fromJson(i)).toList() ?? [],
      postsCount: (json['postsCount'] as int?) ?? (json['posts'] as List?)?.length ?? 0,
    );
  }

  /// Constructor simplificado para romper la recursión en listas de seguidores/siguiendo
  factory Usuario.fromSimpleJson(Map<String, dynamic> json) {
    return Usuario(
      firebaseUid: json['firebaseUid']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      localidad: json['localidad']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      fotoPerfil: json['fotoPerfil']?.toString() ?? '',
      memberSince: json['memberSince']?.toString() ?? '',
      encountersCount: json['encountersCount'] ?? 0,
      mascotas: [], // No necesitamos cargar mascotas de los seguidores en esta vista
      siguiendo: [],
      seguidores: [],
      mascotasFavoritas: [],
    );
  }
}