import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pawpark_frontend/api/model/usuario_model.dart';
import 'package:pawpark_frontend/api/service/usuario_service.dart';
import 'package:pawpark_frontend/widgets/avatar_perfil.dart';
import '../../providers/usuario_provider.dart';
import '../../utils/image_helper.dart';

class SeguidoresScreen extends StatelessWidget {
  const SeguidoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // La pantalla recoge lo que le enviamos por el Navigator
    final seguidores = ModalRoute.of(context)!.settings.arguments as List<Usuario>? ?? [];

    final miUsuario = context.read<UsuarioProvider>().usuario;
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Seguidores",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: seguidores.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 40, color: Colors.grey[400]),
            SizedBox(height: 10),
            Text(
              "No hay seguidores aún",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: seguidores.length,
        itemBuilder: (context, index) {
          final seguidor = seguidores[index];
          final String userUid = seguidor.firebaseUid;

          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: AvatarPerfil(
              urlImagen: ImageHelper.user(seguidor.fotoPerfil),
              radio: 22,
            ),
            title: Text(
              seguidor.nombre,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("@${seguidor.nickname}"),
            onTap: () async {
              if (miUsuario?.firebaseUid == userUid) {
                Navigator.pushNamed(context, "/perfil");
              } else {
                final usuarioAjeno = await UsuarioService.fetchPerfil(userUid);
                if (context.mounted) {
                  Navigator.pushNamed(
                    context,
                    "/perfil",
                    arguments: usuarioAjeno,
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}