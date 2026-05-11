import 'package:flutter/material.dart';
import 'package:pawpark_frontend/widgets/avatar_perfil.dart';
import 'package:pawpark_frontend/widgets/skeleton_search.dart';
import 'package:provider/provider.dart';
import '../../api/model/usuario_model.dart';
import '../../providers/usuario_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController controller = TextEditingController();

  List<Usuario> resultados = [];
  bool isLoading = false;

  Future<void> buscarUsuarios(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        resultados = [];
        isLoading = false;
      });
      return;
    }
    setState(() => isLoading = true);
    try {
      final users = await context.read<UsuarioProvider>().buscarUsuarios(query);
      setState(() {
        resultados = users;
      });
    } catch (e) {
      debugPrint("Error búsqueda: $e");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "¿A quién buscas?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: color.primary.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                onChanged: buscarUsuarios,
                decoration: InputDecoration(
                  hintText: "Usuarios o mascotas...",
                  prefixIcon: Icon(Icons.search),
                  // Botón para limpiar la X
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            controller.clear();
                            buscarUsuarios("");
                          },
                          icon: Icon(Icons.clear),
                        )
                      : null,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: color.primary,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) => SkeletonSearch()
              )
                  : resultados.isEmpty
                  ? Center(
                      child: Text(
                        controller.text.isEmpty
                            ? "Encuentra nuevos amigos 🐾"
                            : "No hemos encontrado nada.",
                      ),
                    )
                  : ListView.builder(
                      itemCount: resultados.length,
                      itemBuilder: (context, index) {
                        final user = resultados[index];
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 5),
                          leading: AvatarPerfil(
                            urlImagen: user.fotoPerfil,
                            radio: 25,
                          ),
                          title: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                TextSpan(
                                  text: user.nombre,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (user.mascotas.isNotEmpty)
                                  TextSpan(
                                    text:
                                        " (${user.mascotas.map((m) => m.nombre).join(', ')})",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          subtitle: Text(
                            "@${user.nickname} • ${user.localidad}",
                            style: TextStyle(color: Colors.grey[600]),
                          ),

                          onTap: () {
                            final miUsuario = context
                                .read<UsuarioProvider>()
                                .usuario;
                            if (miUsuario?.firebaseUid == user.firebaseUid) {
                              Navigator.pushNamed(context, "/perfil");
                              return; // Salimos para no ejecutar el código de abajo
                            }
                            Navigator.pushNamed(
                              context,
                              "/perfil",
                              arguments: user,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
