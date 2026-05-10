import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/service/usuario_service.dart';
import '../../providers/usuario_provider.dart';
import '../../utils/image_helper.dart';
import '../../widgets/avatar_perfil.dart';

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos al provider para tener la lista de mascotas actualizada
    final userProvider = context.watch<UsuarioProvider>();
    final user = userProvider.usuario;
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Ajustes y Privacidad", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Gestionar mis mascotas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Lista de mascotas con opción de borrar
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: user.mascotas.length,
              itemBuilder: (context, index) {
                final mascota = user.mascotas[index];
                return Card(
                  child: ListTile(
                    // En lugar de CircleAvatar con backgroundImage, usamos tu widget
                    leading: AvatarPerfil(
                      urlImagen: mascota.fotoPerfilMascota,
                      // O mascota.foto, según tu modelo
                      radio: 25,
                    ),
                    title: Text(mascota.nombre),
                    subtitle: Text(mascota.raza),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () =>
                          _confirmarBorradoMascota(
                              context, mascota, userProvider),
                    ),
                  ),
                );
              }
            ),

            SizedBox(height: 40),
            Divider(),
            SizedBox(height: 20),
            Text(
              "Zona de peligro",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 15),

            // Botón para dar de baja la cuenta
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _confirmarBajaCuenta(context, user.firebaseUid),
                icon: Icon(Icons.person_remove),
                label: Text("DAR DE BAJA MI CUENTA"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondaryFixed,
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LÓGICA DE DIÁLOGOS Y ACCIONES
  void _confirmarBorradoMascota(BuildContext context, dynamic mascota, UsuarioProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("¿Eliminar mascota?"),
        content: Text("¿Estás seguro de que quieres eliminar a ${mascota.nombre}? Esta acción no se puede deshacer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("CANCELAR")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Cerramos el diálogo primero
              // Llamamos al servicio
              bool exito = await UsuarioService.eliminarMascota(mascota.id);
              if (exito) {
                // Refrescamos y avisamos
                await provider.recargarUsuario();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${mascota.nombre} ha sido eliminado."),
                    ),
                  );
                }
              } else {
                // Avisamos al usuario de que algo ha ido mal
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("No se pudo eliminar la mascota. Inténtalo de nuevo más tarde."),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
            child: Text("ELIMINAR", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmarBajaCuenta(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("¡Atención!"),
        content: Text("¿Seguro que quieres borrar tu cuenta? Perderás todos tus datos, mascotas y seguidores de forma permanente."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("CANCELAR")),
          TextButton(
            onPressed: () async {
              // Borramos dela base de datos MySQL a través del Service
              bool exito = await UsuarioService.darDeBajaCuenta(uid);
              if (exito) {
                try {
                  // Limpiamos el Provider de usuario inmediatamente
                  // Esto vacía la variable 'usuario' en memoria para que no haya datos fantasma
                  context.read<UsuarioProvider>().limpiarUsuario();

                  // Borramos el usuario de Firebase Auth
                  // Si esto falla (porque el login es antiguo), saltará al catch
                  await FirebaseAuth.instance.currentUser?.delete();

                  // Salida total al Login
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
                  }
                } catch (e) {
                  // Si Firebase da error (ej: requiere login reciente), al menos cerramos sesión
                  debugPrint("Error al eliminar de Firebase: $e");
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
                  }
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error al eliminar los datos del servidor")),
                  );
                }
              }
            },
            child: Text("BORRAR TODO", style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}