import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../api/usuario_model.dart';
import '../api/usuario_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late Future<Usuario> futureUsuario;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    futureUsuario = UsuarioService.fetchPerfil(uid ?? "");
  }

  @override
  Widget build(BuildContext context) {
    final pawBlue = Theme.of(context).colorScheme.primary;
    final parkRed = Theme.of(context).colorScheme.secondary;
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: pawBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, "/login");
            },
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder<Usuario>(
        future: futureUsuario,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Error: ${snapshot.error}"),
                IconButton(onPressed: () async{
                 await FirebaseAuth.instance.signOut();
                 Navigator.pushNamed(context, "/login");
                },
                    icon: Icon(Icons.sign_language_outlined))
              ],
            ));
          }

          final user = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(user, pawBlue),
                SizedBox(height: 60),
                _buildStats(user, pawBlue, parkRed, color),
                _buildMascotasSection(user, pawBlue, parkRed, color)
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Usuario user, Color pawBlue) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: pawBlue,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
        Positioned(
          bottom: -50,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 55,
              backgroundImage: NetworkImage(user.fotoPerfil),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(Usuario user, Color pawBlue, Color parkRed, ColorScheme color) {
    return Column(
      children: [
        Text(user.nombre, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.grey),
            Text(user.localidad, style: TextStyle(color: Colors.grey)),
          ],
        ),
        Text("Miembro desde ${user.memberSince}", style: TextStyle(color: Colors.grey, fontSize: 12)),
        SizedBox(height: 20),
        // Fila de estadísticas (Mascotas, Amigos, Encuentros)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _statItem(user.mascotas.length.toString(), "Mascotas", pawBlue),
            _statItem("24", "Amigos", parkRed), // Dato estático para el MVP
            _statItem(user.encountersCount.toString(), "Encuentros", color.tertiary ),
          ],
        ),
      ],
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildMascotasSection(Usuario user, Color pawBlue, Color parkRed, ColorScheme color) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Mis Mascotas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  print("Botón presionado, navegando a /add-mascota...");
                  // Navegamos y esperamos a que la mascota se guarde y la pantalla se cierre
                  final mascotaGuardada = await Navigator.pushNamed(context, "/add-mascota");

                  // Si al volver el el valor es true, refrescamos los datos del servidor
                  if (mascotaGuardada == true) {
                    print("Mascota guardada, refrescando...");
                    setState(() {
                      _cargarDatos();
                    });
                  }
                },
                icon: Icon(Icons.add, size: 18),
                label: Text("Añadir"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.secondary,
                  foregroundColor: color.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          ListView.builder(
            shrinkWrap: true, // Importante para que funcione dentro de un Column
            physics: NeverScrollableScrollPhysics(), // El scroll lo maneja el SingleChildScrollView
            itemCount: user.mascotas.length,
            itemBuilder: (context, index) {
              final mascota = user.mascotas[index];
              return _mascotaCard(mascota);
            },
          ),
        ],
      ),
    );
  }

  Widget _mascotaCard(dynamic mascota) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            mascota['foto'],
            width: 60, height: 60, fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.pets),
          ),
        ),
        title: Text(mascota['nombre'], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${mascota['raza']} • ${mascota['edad']} años"),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: obtenerColorPorComportamiento(mascota['comportamiento']),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            mascota['comportamiento'],
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      ),
    );
  }

  Color obtenerColorPorComportamiento(String nombreComportamiento) {
    if (nombreComportamiento == 'SOCIABLE') {
      return Color(0xff42ad60);
    }
    if (nombreComportamiento == 'AGRESIVO') {
      return Color(0xffb2173a);
    }
    if (nombreComportamiento == 'JUGUETON') {
      return Color(0xffbb1dc5);
    }

    if (nombreComportamiento == 'TRANQUILO') {
      return Color(0xff2783ce);
    }
    return Colors.grey;
  }
}