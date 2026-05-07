import 'package:flutter/material.dart';
import 'package:pawpark_frontend/utils/image_helper.dart';

class AvatarPerfil extends StatelessWidget {
  final String? urlImagen;
  final double radio;

  const AvatarPerfil({
    super.key,
    this.urlImagen,
    this.radio = 20,
  });

  @override
  Widget build(BuildContext context) {
    final imagenFinal = ImageHelper.user(urlImagen);

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