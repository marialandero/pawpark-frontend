import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/bottom_bar.dart';
import '../../providers/usuario_provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {

  /// 🔥 MOCK (luego vendrá de PostProvider)
  final List<Map<String, dynamic>> posts = [
    {
      "usuarioUid": "1",
      "usuarioNombre": "María Landero",
      "imagen": "https://images.unsplash.com/photo-1548199973-03cce0bbc87b",
      "descripcion": "Primer paseo en la playa 🐾",
      "mascotas": ["Thorin", "Coby"],
      "likes": 12,
      "liked": false,
    },
    {
      "usuarioUid": "2",
      "usuarioNombre": "Carlos López",
      "imagen": "https://images.unsplash.com/photo-1518717758536-85ae29035b6d",
      "descripcion": "Domingo de parque 🌳",
      "mascotas": ["Rocky"],
      "likes": 5,
      "liked": true,
    }
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   Future.microtask(() {
  //     context.read<PostProvider>().cargarFeed();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final user = context.watch<UsuarioProvider>().usuario;

    return Scaffold(
      bottomNavigationBar: BottomBar(currentIndex: 1),

      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: color.primary),
            onPressed: () {
              Navigator.pushNamed(context, "/search");
            },
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: color.secondary,
        onPressed: () {
          Navigator.pushNamed(context, "/crear-post");
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Explora tu comunidad",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color.primary,
                    ),
                  ),
                ],
              )
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // TODO: recargar posts desde el backend
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                            contentPadding: const EdgeInsets.all(15),

                            leading: CircleAvatar(
                              backgroundColor: color.primary.withOpacity(0.1),
                              child: Icon(Icons.person, color: color.primary),
                            ),

                            title: GestureDetector(
                              onTap: () {
                                /// 🔥 MISMA LÓGICA QUE TU PERFIL
                                if (user?.firebaseUid == post["usuarioUid"]) {
                                  Navigator.pushNamed(context, "/perfil");
                                } else {
                                  Navigator.pushNamed(
                                    context,
                                    "/perfil-publico",
                                    arguments: post["usuarioUid"],
                                  );
                                }
                              },
                              child: Text(
                                post["usuarioNombre"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Didact Gothic',
                                ),
                              ),
                            ),

                            subtitle: Wrap(
                              children: [
                                const Text("con "),
                                ..._buildMascotas(post["mascotas"], context),
                              ],
                            ),
                          ),

                          /// 🖼️ IMAGEN
                          Center(
                            child: SizedBox(
                              width: 350,
                              child: AspectRatio(
                                aspectRatio: 1, // 👈 CUADRADO
                                child: ClipRRect(
                                  child: Image.network(
                                    post["imagen"],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          /// ❤️ ACCIONES
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      post["liked"] = !post["liked"];
                                      post["liked"]
                                          ? post["likes"]++
                                          : post["likes"]--;
                                    });
                                  },
                                  icon: Icon(
                                    post["liked"] ? Icons.favorite : Icons.favorite_border,
                                    color: post["liked"] ? color.secondary : Colors.grey,
                                  ),
                                ),
                                Text(
                                  "${post["likes"]}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),

                          /// 📝 DESCRIPCIÓN
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            child: Text(
                              post["descripcion"],
                              style: TextStyle(
                                color: Colors.blueGrey[600],
                                height: 1.4,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        )


      ),
    );
  }

  /// 🐶 Mascotas clicables
  List<Widget> _buildMascotas(List mascotas, BuildContext context) {
    return mascotas.map<Widget>((m) {
      return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, "/perfil-mascota");
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Text(
            "$m ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    }).toList();
  }
}