import 'package:flutter/material.dart';
import 'package:pawpark_frontend/widgets/avatar_perfil.dart';
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

  /// 🔍 BUSCAR USUARIOS
  Future<void> buscarUsuarios(String query) async {
    if (query.isEmpty) return;

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
        title: Text("Busca en PawPark", style: TextStyle(fontWeight: FontWeight.bold)),
      ),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            /// 🔍 INPUT
            TextField(
              controller: controller,
              onChanged: buscarUsuarios,
              decoration: InputDecoration(
                hintText: "Buscar por nombre...",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            SizedBox(height: 20),

            /// RESULTADOS
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())

                  : resultados.isEmpty
                  ? Center(child: Text("Sin resultados"))

                  : ListView.builder(
                itemCount: resultados.length,
                itemBuilder: (context, index) {

                  final user = resultados[index];

                  return ListTile(
                    leading: AvatarPerfil(
                      urlImagen: user.fotoPerfil,
                      radio: 20,
                    ),

                    title: Text(user.nombre),

                    subtitle: Text(user.localidad),

                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/perfil",
                        arguments: user, // 🔥 AQUÍ ESTÁ LA CLAVE
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}