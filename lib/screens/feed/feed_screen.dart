import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../api/model/post_model.dart';
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
        context.read<PostProvider>().cargarTodoElFeed(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final user = context.watch<UsuarioProvider>().usuario;
    final postProvider = context.watch<PostProvider>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            "Explora tu comunidad",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: color.primary,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () => Navigator.pushNamed(context, "/search"),
                icon: Icon(Icons.search, color: color.primary)
            ),
            IconButton(
                onPressed: () => showSignOutConfirmation(color),
                icon: Icon(Icons.logout, color: color.primary,)
            )
          ],
          bottom: TabBar(
            indicatorColor: color.primary,
            labelColor: color.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(
              fontSize: 18,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            tabs: [
              Tab(text: "Para ti"),
              Tab(text: "Seguidos"),
              Tab(text: "Míos"),
            ],
          ),
        ),
        bottomNavigationBar: BottomBar(currentIndex: 1),
        floatingActionButton: FloatingActionButton(
          backgroundColor: color.secondary,
          onPressed: () => Navigator.pushNamed(context, "/crear-post"),
          child: Icon(Icons.add, color: Colors.white),
        ),

        body: TabBarView(
          children: [
            _buildListado(postProvider.postsGlobales, postProvider, user, color, "No hay posts todavía."),
            _buildListado(postProvider.postsSeguidos, postProvider, user, color, "Sigue a alguien para ver sus momentos."),
            _buildListado(postProvider.misPosts, postProvider, user, color, "Aún no has publicado nada."),
          ],
        )
      ),
    );
  }

  // Método reutilizable para no repetir el código del Feed 3 veces
  Widget _buildListado(List<Post> lista, PostProvider provider, dynamic user, ColorScheme color, String mensajeVacio) {
    return RefreshIndicator(
      onRefresh: () async {
        if (user?.firebaseUid != null) {
          await provider.cargarTodoElFeed(user.firebaseUid);
        }
      },
      child: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : lista.isEmpty
          ? ListView( // Usamos ListView en lugar de Center para que el scroll sea posible y el RefreshIndicator funcione
        physics: AlwaysScrollableScrollPhysics(), // ESTO ES CLAVE: permite arrastrar aunque esté vacío
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4, // Centramos visualmente el mensaje
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(mensajeVacio, textAlign: TextAlign.center),
              ),
            ),
          ),
        ],
      )
          : ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        itemCount: lista.length,
        itemBuilder: (context, index) {
          final post = lista[index];
          return PostCard(
            key: ValueKey(post.id),
            post: post,
            color: color,
            user: user,
            onLike: () {
              provider.toggleLike(post.id, user!.firebaseUid);
            },
          );
        },
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
              style: TextStyle(color: color.secondary),
            ),
          ),
        ],
      ),
    );
  }
}