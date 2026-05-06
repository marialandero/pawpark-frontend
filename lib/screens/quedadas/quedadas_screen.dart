import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../api/model/quedada_model.dart';
import '../../api/service/quedada_service.dart';
import '../../api/model/usuario_model.dart';
import '../../api/service/usuario_service.dart';
import '../../providers/usuario_provider.dart';
import '../../providers/quedada_provider.dart'; // <-- AÑADIDO: Importamos el buzón de datos
import '../../widgets/bottom_bar.dart';
import 'package:intl/intl.dart';

class QuedadasScreen extends StatefulWidget {
  const QuedadasScreen({super.key});

  @override
  State<QuedadasScreen> createState() => _QuedadasScreenState();
}

class _QuedadasScreenState extends State<QuedadasScreen> {
  late Future<List<Quedada>> _futureQuedadas;

  @override
  void initState() {
    super.initState();
    _cargarQuedadas();
  }

  void _cargarQuedadas() {
    setState(() {
      _futureQuedadas = QuedadaService.fetchTodas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UsuarioProvider>();
    final user = userProvider.usuario;

    final color = Theme.of(context).colorScheme;
    final pawBlue = color.primary;
    final parkRed = color.secondary;

    if (user == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      bottomNavigationBar: BottomBar(currentIndex: 2),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _showSignOutConfirmation(color),
            icon: Icon(Icons.logout, color: pawBlue),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, "/form-quedada");
          if (result == true) {
            _cargarQuedadas();
          }
        },
        backgroundColor: parkRed,
        icon: Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: Text(
          "Crear quedada",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _cargarQuedadas(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("¡Hola, ${user.nombre}!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: pawBlue)),
                Text("¿Listos para un paseo hoy?", style: TextStyle(fontSize: 16, color: Colors.grey)),

                SizedBox(height: 30),

                FutureBuilder<List<Quedada>>(
                  future: _futureQuedadas,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return _buildErrorWidget(color, snapshot.error.toString());
                    }

                    final todas = snapshot.data ?? [];

                    final misCitas = todas.where((q) =>
                    q.creador?.firebaseUid == user.firebaseUid ||
                        q.usuariosAsistentes.any((u) => u.firebaseUid == user.firebaseUid)
                    ).toList();

                    final explorar = todas.where((q) => !misCitas.contains(q)).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tus citas", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        _buildMisQuedadasList(misCitas, color.onPrimaryFixedVariant),

                        SizedBox(height: 30),

                        Text("Quedadas cerca de ti", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 15),

                        if (explorar.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: Text("No hay quedadas nuevas por ahora.")),
                          )
                        else
                          ...explorar.map((q) => Padding(
                            padding: EdgeInsets.only(bottom: 15),
                            child: _buildExplorarCard(context, quedada: q, color: Colors.orange.shade700),
                          )),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMisQuedadasList(List<Quedada> quedadas, Color color) {
    if (quedadas.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        child: Center(child: Text("Aún no tienes planes próximos.")),
      );
    }
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quedadas.length,
        itemBuilder: (context, index) {
          final q = quedadas[index];
          // AÑADIDO: InkWell para que las citas también lleven al detalle
          return InkWell(
            onTap: () {
              context.read<QuedadaProvider>().seleccionarQuedada(q);
              Navigator.pushNamed(context, "/detalle-quedada");
            },
            child: _buildMiniCard(q, color),
          );
        },
      ),
    );
  }

  Widget _buildMiniCard(Quedada q, Color color) {
    final dia = DateFormat('EEEE, d', 'es').format(q.fechaHora);
    final hora = DateFormat.Hm().format(q.fechaHora);

    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dia.toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
          Text(hora, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Spacer(),
          Text(q.lugarNombre, style: TextStyle(color: Colors.white, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildExplorarCard(BuildContext context, {required Quedada quedada, required Color color}) {
    final hora = DateFormat.Hm().format(quedada.fechaHora);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(15),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(Icons.pets, color: color),
            ),
            title: Text(quedada.titulo, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Didact Gothic', color: Colors.orange.shade700)),
            subtitle: Text("${quedada.lugarNombre} • ${quedada.perrosAsistentes.length} perros"),
            trailing: Text(hora, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Organizador: ${quedada.creador?.nombre ?? 'Usuario'}", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ElevatedButton(
                  onPressed: () {
                    // MODIFICADO: Ahora cargamos los datos en el Provider antes de navegar
                    context.read<QuedadaProvider>().seleccionarQuedada(quedada);
                    Navigator.pushNamed(context, "/detalle-quedada");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.withOpacity(0.1),
                    foregroundColor: color,
                    elevation: 0,
                    shape: StadiumBorder(),
                  ),
                  child: Text("Ver más"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ColorScheme color, String error) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 40),
          SizedBox(height: 10),
          Text("Error al cargar: $error", textAlign: TextAlign.center),
          TextButton(onPressed: _cargarQuedadas, child: Text("REINTENTAR")),
        ],
      ),
    );
  }

  void _showSignOutConfirmation(ColorScheme color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cerrar sesión"),
        content: Text("¿Seguro que quieres salir?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
            },
            child: Text("CERRAR SESIÓN", style: TextStyle(color: color.error)),
          ),
        ],
      ),
    );
  }
}