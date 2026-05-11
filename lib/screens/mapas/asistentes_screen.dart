import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/zona_provider.dart';
import '../../providers/usuario_provider.dart';
import '../../api/service/usuario_service.dart';
import '../../widgets/avatar_perfil.dart';

class AsistentesScreen extends StatelessWidget {
  const AsistentesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Recuperamos el ID de la zona enviado por argumentos
    final String osmId = ModalRoute.of(context)!.settings.arguments as String;
    final color = Theme.of(context).colorScheme;

    // Obtenemos nuestro propio usuario para la lógica de navegación
    final miUsuario = context.read<UsuarioProvider>().usuario;

    return Scaffold(
      appBar: AppBar(
        title: Text("¿Quién está?",style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      // Usamos Consumer para que si alguien entra/sale del parque, la lista se refresque sola
      body: Consumer<ZonaProvider>(
        builder: (context, provider, child) {
          final zona = provider.obtenerZonaPorId(osmId);

          if (zona == null) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildHeader(zona, color),
              Divider(height: 1),

              // Lista de usuarios presentes
              Expanded(
                child: zona.usuarios.isEmpty
                    ? _buildListaVacia(color)
                    : ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  itemCount: zona.usuarios.length,
                  separatorBuilder: (_, __) => Divider(height: 1, indent: 70),
                  itemBuilder: (context, index) {
                    final usuarioPresente = zona.usuarios[index];

                    return ListTile(
                      leading: AvatarPerfil(
                        urlImagen: usuarioPresente.fotoPerfil,
                        radio: 25,
                      ),
                      title: Text(
                        usuarioPresente.nombre,
                        style:  TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "con ${usuarioPresente.mascotas.join(', ')}",
                      ),
                      trailing:  Icon(Icons.chevron_right, size: 20),
                      onTap: () async {
                        if (miUsuario?.firebaseUid == usuarioPresente.uid) {
                          // Es mi perfil: vamos a la ruta de perfil propio (uso Provider)
                          Navigator.pushNamed(context, "/perfil");
                        } else {
                          // Es perfil ajeno: buscamos datos y pasamos por argumentos
                          try {
                            final usuarioAjeno = await UsuarioService.fetchPerfil(usuarioPresente.uid);
                            if (context.mounted) {
                              Navigator.pushNamed(
                                context,
                                "/perfil",
                                arguments: usuarioAjeno,
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error al cargar el perfil"))
                              );
                            }
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(zona, ColorScheme color) {

    return Container(
      padding: EdgeInsets.all(20),
      color: color.primaryContainer.withOpacity(0.1),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.primary.withOpacity(0.1),
            child: Icon(_getIconoPorTipo(zona.tipo), color: color.primary),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zona.nombre,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${zona.perrosPresentes} ${zona.perrosPresentes == 1 ? 'perrito presente ahora' : 'perritos presentes ahora'}",
                  style: TextStyle(color: zona.perrosPresentes > 0 ? color.tertiary : color.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaVacia(ColorScheme color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 60, color: color.outlineVariant),
          SizedBox(height: 16),
          Text(
            "¡Vaya! Parece que no hay nadie.",
            style: TextStyle(color: color.outline),
          ),
        ],
      ),
    );
  }

  IconData _getIconoPorTipo(String tipo) {
    switch (tipo) {
      case 'parque': return Icons.park;
      case 'plaza': return Icons.account_balance;
      case 'playa': return Icons.beach_access;
      default: return Icons.nature_people;
    }
  }
}