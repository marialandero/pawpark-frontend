import 'package:flutter/material.dart';
import 'package:pawpark_frontend/api/service/usuario_service.dart';
import 'package:pawpark_frontend/providers/post_provider.dart';
import 'package:provider/provider.dart';
import '../api/model/post_model.dart';
import 'avatar_perfil.dart';
import '../utils/image_helper.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final ColorScheme color;
  final dynamic user;
  final VoidCallback onLike;

  const PostCard({
    super.key,
    required this.post,
    required this.color,
    required this.user,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // HEADER (Nombre + @Nickname)
          InkWell(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            onTap: () => _navegarAlPerfil(context), // Navega toda la cabecera
            child: Padding(
                padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  AvatarPerfil(
                    urlImagen: ImageHelper.user(post.autorFotoPerfil), // Usamos la URL de la foto del autor del post
                    radio: 22, // Ajustamos el tamaño para la cabecera
                  ),
                  SizedBox(width: 12),
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
    RichText(
    text: TextSpan(
    style: DefaultTextStyle.of(context).style,
    children: [
    TextSpan(
    text: post.autorNombre,
    style: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16
    )
    ),
    TextSpan(
    text: " @${post.autorNickname}",
    style: TextStyle(
    color: Colors.grey[600],
    fontSize: 14,
    fontWeight: FontWeight.w400
    )
    )
    ]
    )
    ),
    SizedBox(height: 2),
    Text(
    post.mascotasNombres.isEmpty
    ? "🐾"
        : "con ${post.mascotasNombres.join(', ')}",
    style: TextStyle(
    fontWeight: FontWeight.w500,
    color: Colors.blueGrey[600],
    ),
    )
    ],
                      )
                  ),
                ],
              ),
            ),


            ),
          // Imagen
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              ImageHelper.pet(post.rutaImagen),
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: Icon(Icons.image_not_supported),
              ),
            ),
          ),

          // Likes persistentes
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.read<PostProvider>().toggleLike(post.id, user!.firebaseUid);
                      },
                      icon: Icon(
                        post.liked ? Icons.favorite : Icons.favorite_border,
                        color: post.liked ? color.secondary : Colors.grey,
                      ),
                    ),
                    Text(
                      "${post.likes} personas",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (user?.firebaseUid == post.autorUid)
                  IconButton(
                    onPressed: () => _mostrarDialogoBorrar(context),
                    icon: Icon(Icons.delete_sweep_outlined),
                    color: Colors.grey,
                    iconSize: 26,
                  )
              ],
            ),
          ),

          // Descripción
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              post.descripcion,
              style: TextStyle(
                fontSize: 15,
                color: Colors.blueGrey[600],
                height: 1.4,
              ),
            ),
          ),

          SizedBox(height: 15),
        ],
      ),
    );
  }

  // Método para la navegación
  void _navegarAlPerfil(BuildContext context) async {
    if (user?.firebaseUid == post.autorUid) {
      Navigator.pushNamed(context, "/perfil");
    } else {
      final usuarioAjeno = await UsuarioService.fetchPerfil(post.autorUid);
      if (context.mounted) {
        Navigator.pushNamed(
          context,
          "/perfil",
          arguments: usuarioAjeno,
        );
      }
    }
  }

  // DIÁLOGO DE CONFIRMACIÓN PARA BORRAR
  void _mostrarDialogoBorrar(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceDim,
        title: Text("¿Eliminar publicación?"),
        content: Text(
            "Esta acción no se puede deshacer y la foto desaparecerá de las galerías de las mascotas etiquetadas."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("CANCELAR", style: TextStyle(color: color.surfaceTint)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Cerramos el diálogo
              final success = await context.read<PostProvider>().eliminarPost(post.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Post eliminado correctamente")),
                );
              }
            },
            child: Text("ELIMINAR",style: TextStyle(color: color.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}