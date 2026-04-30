import 'package:flutter/material.dart';

class AvatarPerfil extends StatelessWidget {
  final String? urlImagen;
  final double radio;

  const AvatarPerfil({
    super.key,
    this.urlImagen,
    this.radio = 20,
  });

  static const String serverUrl = "http://10.0.2.2:8081/uploads/";

  String _buildUrl(String? url) {
    if (url == null || url.isEmpty) {
      return "${serverUrl}person_default.png";
    }

    // Si ya es URL completa
    if (url.startsWith("http")) {
      return url;
    }

    // Si viene como /uploads/xxx o uploads/xxx
    if (url.contains("uploads/")) {
      return "http://10.0.2.2:8081/$url";
    }

    // Caso normal: solo nombre archivo
    return "$serverUrl$url";
  }

  @override
  Widget build(BuildContext context) {
    final imagenFinal = _buildUrl(urlImagen);

    return CircleAvatar(
      radius: radio,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: Image.network(
          imagenFinal,
          width: radio * 2,
          height: radio * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.person, size: radio, color: Colors.grey),
        ),
      ),
    );
  }
}