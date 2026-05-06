import 'usuario_model.dart';
import 'mascota_model.dart';

class Quedada {
  final int? id;
  final String titulo;
  final String descripcion;
  final DateTime fechaHora;
  final String lugarNombre;
  final Usuario? creador;
  final List<Usuario> usuariosAsistentes;
  final List<Mascota> perrosAsistentes;

  Quedada({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaHora,
    required this.lugarNombre,
    this.creador,
    this.usuariosAsistentes = const [],
    this.perrosAsistentes = const [],
  });

  factory Quedada.fromJson(Map<String, dynamic> json) {
    return Quedada(
      id: json['id'],
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fechaHora: DateTime.parse(json['fechaHora']),
      lugarNombre: json['lugarNombre'] ?? '',
      creador: json['creador'] != null ? Usuario.fromJson(json['creador']) : null,
      usuariosAsistentes: json['usuariosAsistentes'] != null
          ? (json['usuariosAsistentes'] as List).map((i) => Usuario.fromJson(i)).toList()
          : [],
      perrosAsistentes: json['perrosAsistentes'] != null
          ? (json['perrosAsistentes'] as List).map((i) => Mascota.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'descripcion': descripcion,
    'fechaHora': fechaHora.toIso8601String(),
    'lugarNombre': lugarNombre,
  };
}