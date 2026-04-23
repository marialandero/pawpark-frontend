import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/mascota_model.dart';
import '../../providers/usuario_provider.dart';

class PerfilMascotaScreen extends StatelessWidget {
  const PerfilMascotaScreen({super.key});

  void _mostrarDialogoEdicion(BuildContext context, Mascota mascota) {
    final TextEditingController descController = TextEditingController(text: mascota.descripcion);
    final color = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Sobre ${mascota.nombre}"),
          content: TextField(
            controller: descController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Escribe algo sobre tu mascota...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCELAR"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color.primary,
                foregroundColor: color.onPrimary,
              ),
              onPressed: () async {
                final exito = await context.read<UsuarioProvider>().actualizarDescripcionMascota(
                    mascota.id!,
                    descController.text.trim()
                );

                if (exito) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Descripción actualizada correctamente")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error al conectar con el servidor")),
                  );
                }
              },
              child: const Text("GUARDAR"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final color = Theme.of(context).colorScheme;
    final pawBlue = color.primary;

    // Recuperamos la mascota (vieja) pasada por argumentos
    final mascotaArgs = ModalRoute.of(context)!.settings.arguments as Mascota;

    // Esta es la versión que reacciona a los cambios, la mascota nueva
    // Buscamos la mascota dentro del Provider para tener la versión actualizada
    final userProvider = context.watch<UsuarioProvider>();
    final mascota = userProvider.usuario?.mascotas.firstWhere(
            (m) => m.id == mascotaArgs.id,
        orElse: () => mascotaArgs
    ) ?? mascotaArgs;

    // Lógica para comprobar dueño
    final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    final bool esMiMascota = mascotaArgs.duenoFirebaseUid == currentUserUid;

    print("Mi UID de Firebase: $currentUserUid");
    print("UID del dueño de la mascota: ${mascotaArgs.duenoFirebaseUid}");
    print("¿Es mi mascota?: $esMiMascota");

    return Scaffold(
      body: CustomScrollView(
        // physics: BouncingScrollPhysics(),
        slivers: [
          // Cabecera con la foto
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            stretch: true,
            // Hace que la foto se estire si tiras hacia abajo
            flexibleSpace: FlexibleSpaceBar(
              background: Hero( // Para una animación suave
                tag: 'foto_${mascota.id}', // Ya usamos la mascota nueva (la del provider)
                child: mascotaArgs.fotoPerfilMascota.startsWith('assets/')
                    ? Image.asset(mascotaArgs.fotoPerfilMascota, fit: BoxFit.cover)
                    : Image.network(mascotaArgs.fotoPerfilMascota, fit: BoxFit.cover),
              ),
            ),
          ),

          // Contenido del perfil
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mascota.nombre, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.1)),
                    SizedBox(height: 5),
                    Text(mascota.raza.replaceAll('_', ' '), style: TextStyle(fontSize: 18, color: color.primary, fontWeight: FontWeight.w600,),),
                    SizedBox(height: 5),
                    Text("${mascota.edad} años", style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500,),),
                    SizedBox(height: 25),
                    Text("Personalidad", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
                    SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: mascota.comportamientos.map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Mascota.obtenerColorTag(
                              tag,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Mascota.obtenerColorTag(tag),
                            ),
                          ),
                          child: Text(
                            tag[0].toUpperCase() +
                                tag.substring(1).toLowerCase(),
                            style: TextStyle(
                              color: Mascota.obtenerColorTag(tag),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 25),

                    // Descripción
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Sobre ${mascota.nombre}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        if (esMiMascota)
                          IconButton(
                              onPressed: () => _mostrarDialogoEdicion(context, mascota),
                              icon: Icon(Icons.edit_note, color: pawBlue, size: 26)
                          )
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      mascota.descripcion.isEmpty
                          ? "Este peludo aún no tiene descripción, ¡pero seguro que es encantador!"
                          : mascota.descripcion,
                      style: TextStyle(fontSize: 15, height: 1.5, color: Colors.blueGrey[600], fontStyle: FontStyle.italic),
                    ),

                    SizedBox(height: 30),

                    // Espacio para la futura Galería (Posts)
                    Divider(),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.photo_library_outlined, color: Colors.grey),
                        SizedBox(width: 10),
                        Text(
                          "Galería de fotos",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 100),
                    // Espacio extra abajo
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
