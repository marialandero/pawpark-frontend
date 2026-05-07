import 'package:flutter/material.dart';
import 'package:pawpark_frontend/api/service/usuario_service.dart';
import 'package:pawpark_frontend/widgets/avatar_perfil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/quedada_provider.dart';
import '../../providers/usuario_provider.dart';

class DetalleQuedadaScreen extends StatelessWidget {
  const DetalleQuedadaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final qProvider = context.watch<QuedadaProvider>();
    final userProvider = context.watch<UsuarioProvider>();
    final q = qProvider.quedada;
    final user = userProvider.usuario;
    final color = Theme.of(context).colorScheme;

    if (q == null || user == null) return Scaffold(body: Center(child: CircularProgressIndicator()));

    final bool yaApuntado = q.usuariosAsistentes.any((u) => u.firebaseUid == user.firebaseUid);

    return Scaffold(
      appBar: AppBar(title: Text("Detalle del plan", style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.titulo, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color.primary)),
            SizedBox(height: 10),
            _infoRow(Icons.calendar_month, DateFormat('EEEE, d MMMM • HH:mm', 'es').format(q.fechaHora)),
            _infoRow(Icons.location_on, q.lugarNombre),
            Divider(height: 40),
            Text("Sobre esta quedada",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Didact Gothic')),
            SizedBox(height: 10),
            Text(
              q.descripcion != null && q.descripcion!.isNotEmpty
                  ? q.descripcion!
                  : "Sin descripción adicional.",
              style: TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic, // <--- Aquí la cursiva
                color: Colors.blueGrey[600],
                height: 1.4,
              ),
            ),
            SizedBox(height: 30),
            Text("Asistentes confirmados", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            _buildListaAsistentes(context, q, user),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: qProvider.isLoading ? null : () => _handlePress(context, yaApuntado, user, q.id!, qProvider),
          style: ElevatedButton.styleFrom(
              backgroundColor: yaApuntado ? color.secondary : color.primary,
              minimumSize: Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
          ),
          child: qProvider.isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text(yaApuntado ? "DESAPUNTARME" : "¡ME APUNTO!", style: TextStyle(color: color.onPrimary, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(text)]);

  Widget _buildListaAsistentes(BuildContext context, dynamic q, dynamic currentUser) {
    return Column(
      children: q.usuariosAsistentes.map<Widget>((u) {
        // Obtenemos los nombres de los perros de este usuario que están en la quedada
        final perros = q.perrosAsistentes.where((p) => p.duenoFirebaseUid == u.firebaseUid).map((p) => p.nombre).join(", ");
        return ListTile(
          onTap: () async {
            if (currentUser.firebaseUid == u.firebaseUid) {
              Navigator.pushNamed(context, "/perfil");
            } else {
              final usuarioAjeno = await UsuarioService.fetchPerfil(u.firebaseUid);
              if (context.mounted) {
                Navigator.pushNamed(
                  context,
                  "/perfil",
                  arguments: usuarioAjeno
                );
              }
            }
          },
          leading: AvatarPerfil(
            urlImagen: u.fotoPerfil,
            radio: 20,
          ),
          title: Text(u.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(perros.isNotEmpty ? "Viene con: $perros" : "Viene solo/a"),
        );
      }).toList(),
    );
  }

  void _handlePress(BuildContext context, bool yaApuntado, dynamic user, int qId, QuedadaProvider p) {
    if (yaApuntado) {
      p.desapuntarse(qId, user.firebaseUid);
    } else {
      _showDogSelector(context, user, qId, p);
    }
  }

  void _showDogSelector(BuildContext context, dynamic user, int qId, QuedadaProvider p) {
    List<int> selected = [];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("¿Quién te acompaña?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...user.mascotas.map<Widget>((m) => CheckboxListTile(
                title: Text(m.nombre),
                value: selected.contains(m.id),
                onChanged: (val) => setState(() => val! ? selected.add(m.id) : selected.remove(m.id)),
              )).toList(),
              ElevatedButton(onPressed: selected.isEmpty ? null : () { p.unirse(qId, selected, user.firebaseUid); Navigator.pop(ctx); }, child: const Text("CONFIRMAR"))
            ],
          ),
        ),
      ),
    );
  }
}