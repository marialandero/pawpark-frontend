import 'package:flutter/material.dart';

class Mascota {
  final int? id;
  final String nombre;
  final int edad;
  final String descripcion;
  final String fotoPerfilMascota;
  final String raza;
  final List<String> comportamientos;
  final String duenoFirebaseUid;

  Mascota({
    this.id,
    required this.nombre,
    required this.edad,
    required this.descripcion,
    required this.fotoPerfilMascota,
    required this.raza,
    required this.comportamientos,
    required this.duenoFirebaseUid
  });

  // Mapeo desde el JSON del Backend (Spring Boot)
  factory Mascota.fromJson(Map<String, dynamic> json) {
    return Mascota(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      edad: json['edad'] ?? 0,
      descripcion: json['descripcion'] ?? '',
      fotoPerfilMascota: json['fotoPerfilMascota'] ?? '',
      raza: json['raza'] ?? 'MESTIZO',
      comportamientos: List<String>.from(json['comportamientos'] ?? []),
      duenoFirebaseUid: json['duenoFirebaseUid'] ?? '',
    );
  }

  // Método de utilidad para obtener el color del tag
  static Color obtenerColorTag(String tag) {
    switch (tag.toUpperCase()) {
      case 'SOCIABLE': return Color(0xff61b17a);
      case 'TRANQUILO': return Color(0xff6197b7);
      case 'REACTIVO': return Color(0xffb2173a);
      case 'JUGUETON': return Color(0xffbb1dc5);
      case 'ENERGETICO': return Color(0xffebb55d);
      case 'CARIÑOSO': return Color(0xfff270a2);
      case 'AVENTURERO': return Color(0xff239a86);
      case 'MIEDOSO': return Color(0xc88fa6f1);
      case 'NERVIOSO': return Color(0xc8d68ff1);
      case 'INQUIETO': return Color(0xffeb985d);
      case 'OBEDIENTE': return Color(0xff3f51b5);
      case 'GRUÑON': return Color(0xff8d6e63);
      case 'SUMISO': return Color(0xff8ec280);
      case 'DOMINANTE': return Color(0xe7b6407f);
      case 'GLOTON': return Color(0xffbe921c);
      default: return Colors.grey;
    }
  }
  // Mantenemos este para definir el color principal de la Card basado en el primer tag
  Color get colorPrincipal {
    if (comportamientos.isEmpty) return Colors.grey;
    return obtenerColorTag(comportamientos.first);
  }
}