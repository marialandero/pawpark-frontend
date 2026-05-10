import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pawpark_frontend/api/service/post_service.dart';
import 'package:pawpark_frontend/api/service/usuario_service.dart';
import 'package:pawpark_frontend/widgets/avatar_perfil.dart';
import '../../providers/post_provider.dart';
import '../../providers/usuario_provider.dart';
import '../../utils/image_helper.dart';

class LikersScreen extends StatelessWidget {
  const LikersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos watch para que si el ID cambia por algún motivo, la pantalla reaccione
    final postId = context.watch<PostProvider>().postIdSeleccionado;
    // Obtenemos nuestro propio usuario para comparar UIDs
    final miUsuario = context.read<UsuarioProvider>().usuario;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Personas a las que les gusta",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: postId == null
          ? Center(child: Text("Error: No se ha seleccionado ningún post"))
          : FutureBuilder<List<dynamic>>(
        future: PostService.fetchLikers(postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Error en snapshot: ${snapshot.error}");
            return Center(child: Text("Error al cargar los likes"));
          }

          final likers = snapshot.data ?? [];

          if (likers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 40, color: Colors.grey[400]),
                  SizedBox(height: 10),
                  Text(
                    "No hay likes aún",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: likers.length,
            itemBuilder: (context, index) {
              final licker = likers[index];
              final String userUid = licker['firebaseUid'];

              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: AvatarPerfil(
                  urlImagen: ImageHelper.user(licker['fotoPerfil']),
                  radio: 22,
                ),
                title: Text(
                  licker['nombre'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("@${licker['nickname']}"),
                onTap: () async {
                  // NAVEGACIÓN DIFERENCIADA
                  if (miUsuario?.firebaseUid == userUid) {
                    // Si soy yo mismo
                    Navigator.pushNamed(context, "/perfil");
                  } else {
                    // Si es un usuario ajeno
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
          );
        },
      ),
    );
  }
}