import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../api/model/usuario_model.dart';
import '../../api/service/usuario_service.dart';
import '../../widgets/bottom_bar.dart';

class MapasScreen extends StatefulWidget {
  const MapasScreen({super.key});

  @override
  State<MapasScreen> createState() => _MapasScreenState();
}

class _MapasScreenState extends State<MapasScreen> {
  late Future<Usuario> futureUsuario;
  bool estoyEnParque = false;
  List<String> perritosSeleccionados = [];

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    futureUsuario = UsuarioService.fetchPerfil(uid ?? "");
  }

  void _mostrarSeleccionPerritos(BuildContext context, Usuario user) {
    if (estoyEnParque) {
      setState(() {
        estoyEnParque = false;
        perritosSeleccionados.clear();
      });
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "¿Con quién estás en el parque?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  user.mascotas.isEmpty
                      ? const Text("No tienes mascotas registradas.")
                      : Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: user.mascotas.length,
                      itemBuilder: (context, index) {
                        final mascota = user.mascotas[index];
                        final estaSeleccionado = perritosSeleccionados.contains(mascota.nombre);

                        return CheckboxListTile(
                          title: Text(mascota.nombre),
                          value: estaSeleccionado,
                          secondary: CircleAvatar(
                            backgroundImage: mascota.fotoPerfilMascota.startsWith('assets/')
                                ? AssetImage(mascota.fotoPerfilMascota)
                                : NetworkImage(mascota.fotoPerfilMascota) as ImageProvider,
                          ),
                          onChanged: (bool? valor) {
                            setModalState(() {
                              if (valor == true) {
                                perritosSeleccionados.add(mascota.nombre);
                              } else {
                                perritosSeleccionados.remove(mascota.nombre);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: perritosSeleccionados.isEmpty
                        ? null
                        : () {
                      setState(() => estoyEnParque = true);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Confirmar"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pawBlue = Theme.of(context).colorScheme.primary;
    final parkRed = Theme.of(context).colorScheme.secondary;
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      bottomNavigationBar: BottomBar(currentIndex: 0),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () => showSignOutConfirmation(color),
              icon: Icon(Icons.logout, color: color.primary)
          )
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Usuario>(
          future: futureUsuario,
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Scaffold( // Usamos un Scaffold propio para que el error se vea bien
                backgroundColor: color.onPrimary,
                body: Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: color.error, size: 60),
                        SizedBox(height: 20),
                        Text(
                          "DETALLE DEL ERROR:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 10),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: color.onErrorContainer, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return Center(child: Text("No hay datos"));
            }

            final user = snapshot.data!;

            return Stack(
              children: [
                // Para el boceto uso un mapa falso como fondo
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.blueGrey[50], // Color de fondo si no hay imagen
                  child: Image.asset(
                    'assets/images/mapa_falso.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_outlined, size: 80, color: Colors.grey[400]),
                          Text("Cargando mapa interactivo...", style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  ),
                ),

                // Buscador
                SafeArea(
                  child: Padding(
                    padding:  EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Buscar parques...",
                              prefixIcon: Icon(Icons.search, color: pawBlue),
                              suffixIcon: Icon(Icons.filter_list, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                         SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () => _mostrarSeleccionPerritos(context, user),
                          icon: Icon(estoyEnParque ? Icons.waving_hand_outlined : Icons.waving_hand_outlined),
                          label: Text(estoyEnParque
                              ? "Ya me voy"
                              : "Estoy en el parque"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: estoyEnParque ? color.tertiary : parkRed,
                            foregroundColor: Colors.white,
                            elevation: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }


  void showSignOutConfirmation(ColorScheme color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceDim,
        title: Text("Cerrar sesión"),
        content: Text("¿Seguro que quieres salir?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCELAR", style: TextStyle(color: color.surfaceTint)),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // volvemos al login
              Navigator.pushNamed(context, "/login");
            },
            child: Text(
              "CERRAR SESIÓN",
              style: TextStyle(
                color: color.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
