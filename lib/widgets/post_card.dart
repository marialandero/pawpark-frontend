import 'package:flutter/material.dart';
import 'package:pawpark_frontend/api/usuario_service.dart';
import '../api/post_model.dart';
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

          /// 👤 HEADER
          ListTile(
            contentPadding: EdgeInsets.all(15),

            leading: AvatarPerfil(
              urlImagen: ImageHelper.user(post.autorFotoPerfil), // Usamos la URL de la foto del autor del post
              radio: 22, // Ajustamos el tamaño para la cabecera
            ),

            title: GestureDetector(
              onTap: () async {
                // Si el UID del autor es el mismo que el del usuario logueado
                if (user?.firebaseUid == post.autorUid) {
                  Navigator.pushNamed(context, "/perfil");
                  return;
                } 
                final usuarioAjeno = await UsuarioService.fetchPerfil(post.autorUid);
                  // Si es un perfil ajeno, navegamos a la misma pantalla "/perfil"
                  // pero pasando el UID o el objeto autor para que PerfilScreen lo gestione
                  Navigator.pushNamed(
                    context,
                    "/perfil",
                    arguments: usuarioAjeno,
                  );
                
              },
              child: Text(
                post.autorNombre,
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),

            subtitle: post.mascotasNombres.isEmpty
                ? Text("🐾")
                : Text(
              "con ${post.mascotasNombres.join(', ')}",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey[700],
              ),
            ),
          ),

          /// 🖼️ IMAGEN
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

          /// ❤️ LIKE
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: onLike,
                  icon: Icon(
                    post.liked ? Icons.favorite : Icons.favorite_border,
                    color: post.liked ? color.secondary : Colors.grey,
                  ),
                ),

                Text(
                  "${post.likes}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          /// 📝 DESCRIPCIÓN
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              post.descripcion,
              style: TextStyle(
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
}