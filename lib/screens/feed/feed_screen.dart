import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../widgets/bottom_bar.dart';
import '../../providers/post_provider.dart';
import '../../providers/usuario_provider.dart';
import '../../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {

  @override
  void initState() {
    super.initState();
    // Usamos addPostFrameCallback que es más seguro que microtask para contextos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<UsuarioProvider>().usuario?.firebaseUid;
      if (uid != null) {
        context.read<PostProvider>().cargarFeed(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final user = context.watch<UsuarioProvider>().usuario;

    final postProvider = context.watch<PostProvider>();
    final posts = postProvider.posts;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Hace que la barra de estado sea transparente
          statusBarIconBrightness: Brightness.dark, // Iconos oscuros (para fondo claro)
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "/search");
              },
              icon: Icon(Icons.search, color: color.primary)
          ),
          IconButton(
              onPressed: () => showSignOutConfirmation(color),
              icon: Icon(Icons.logout, color: color.primary,)
          )
        ],
      ),
      bottomNavigationBar: BottomBar(currentIndex: 1),
      floatingActionButton: FloatingActionButton(
        backgroundColor: color.secondary,
        onPressed: () {
          Navigator.pushNamed(context, "/crear-post");
        },
        child: Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Explora tu comunidad",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color.primary,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    "Descubre momentos con mascotas",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            /// FEED
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final uid = context.read<UsuarioProvider>().usuario?.firebaseUid;
                  if (uid != null) {
                    await context.read<PostProvider>().cargarFeed(uid);
                  }
                },

                child: postProvider.isLoading
                    ? Center(child: CircularProgressIndicator())

                    : posts.isEmpty
                    ? Center(
                  child: Text("No hay posts todavía."),
                )

                    : ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];

                    print("FOTO AUTOR: ${post.autorFotoPerfil}"); // 👈 AQUÍ

                    return PostCard(
                      key: ValueKey(post.id),
                      post: post,
                      color: color,
                      user: user,
                      onLike: () {
                        context.read<PostProvider>().toggleLike(post.id, user!.firebaseUid);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSignOutConfirmation(ColorScheme color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cerrar sesión"),
        content: Text("¿Seguro que quieres salir?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCELAR", style: TextStyle(color: color.primary)),
          ),
          TextButton(
            onPressed: () async {
              // Cerramos sesión en Firebase
              await FirebaseAuth.instance.signOut();
              // Se limpia el Provider
              context.read<UsuarioProvider>().limpiarUsuario();
              // Volvemos al login
              Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
            },
            child: Text(
              "CERRAR SESIÓN",
              style: TextStyle(color: color.error),
            ),
          ),
        ],
      ),
    );
  }
}