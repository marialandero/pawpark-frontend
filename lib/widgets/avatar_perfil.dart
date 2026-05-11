import 'package:flutter/material.dart';
import 'package:pawpark_frontend/utils/image_helper.dart';
import 'package:shimmer/shimmer.dart';

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
    // Obtenemos la ruta (puede ser el asset local o la URL de Firebase)
    final ruta = ImageHelper.user(urlImagen);
    final bool esAsset = ImageHelper.isAsset(ruta);

    return CircleAvatar(
      radius: radio,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: esAsset
            ? Image.asset( // <--- Si es asset, usamos motor local
          ruta,
          width: radio * 2,
          height: radio * 2,
          fit: BoxFit.cover,
        )
              : Image.network(
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Shimmer.fromColors(
              baseColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850]! : Colors.grey[300]!,
              highlightColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[100]!,
              child: CircleAvatar(radius: radio, backgroundColor: Colors.white),
            );
          },
          ruta,
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