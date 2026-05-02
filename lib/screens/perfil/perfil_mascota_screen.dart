import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/mascota_model.dart';
import '../../providers/usuario_provider.dart';
import '../../utils/image_helper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class PerfilMascotaScreen extends StatefulWidget {
  const PerfilMascotaScreen({super.key});

  @override
  State<PerfilMascotaScreen> createState() => _PerfilMascotaScreenState();
}

class _PerfilMascotaScreenState extends State<PerfilMascotaScreen> {

  File? _imagenSeleccionada; // imagen elegida del dispositivo
  final ImagePicker _picker = ImagePicker();

  bool _postsCargados = false;

  Future<void> _seleccionarImagen(Mascota mascota) async {
    final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);

    if (imagen == null) return;

    setState(() {
      _imagenSeleccionada = File(imagen.path);
    });

    await _subirImagen(mascota);
  }

  Future<void> _subirImagen(Mascota mascota) async {
    final uri = Uri.parse("http://10.0.2.2:8081/upload");

    final request = http.MultipartRequest("POST", uri);

    request.files.add(
      await http.MultipartFile.fromPath("file", _imagenSeleccionada!.path),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();

      // Backend devuelve URL completa -> extraemos nombre archivo
      final fileName = respStr.split("/").last;

      // Se guarda en backend
      await context.read<UsuarioProvider>().actualizarFotoMascota(mascota.id!, fileName);

      // Recargar usuario COMPLETO
      await context.read<UsuarioProvider>().recargarUsuario();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Foto actualizada")),
      );
    }
  }

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
              child: Text("CANCELAR"),
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
                    SnackBar(content: Text("Descripción actualizada correctamente")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error al conectar con el servidor")),
                  );
                }
              },
              child: Text("GUARDAR"),
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_postsCargados) return;

    final mascotaArgs =
    ModalRoute.of(context)!.settings.arguments as Mascota;

    _postsCargados = true;

    Future.microtask(() {
      context.read<UsuarioProvider>()
          .cargarPostsMascota(mascotaArgs.id!);
    });

  }

  @override
  Widget build(BuildContext context) {

    final color = Theme.of(context).colorScheme;
    final pawBlue = color.primary;

    // Recuperamos la mascota (vieja) pasada por argumentos
    final mascotaArgs = ModalRoute.of(context)!.settings.arguments as Mascota;

    // Esta es la versión que reacciona a los cambios, la mascota nueva
    // Buscamos la mascota dentro del Provider para tener la versión actualizada
    final userProvider = context.read<UsuarioProvider>();
    final Mascota mascotaActual = userProvider.usuario?.mascotas.firstWhere(
            (m) => m.id == mascotaArgs.id,
        orElse: () => mascotaArgs
    ) ?? mascotaArgs;

    // Lógica para comprobar dueño
    final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    final bool esMiMascota = mascotaActual.duenoFirebaseUid == currentUserUid;
    final postsMascota = context.watch<UsuarioProvider>().postsMascota;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
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
                  tag: 'foto_${mascotaActual.id}', // Ya usamos la mascota nueva (la del provider)
                  child: Stack(
                  fit: StackFit.expand,
                  children: [

                    /// IMAGEN MASCOTA
                    Image.network(
                      ImageHelper.pet(mascotaActual.fotoPerfilMascota),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Image.network(
                          ImageHelper.pet(null),
                          fit: BoxFit.cover,
                        );
                      },
                    ),

                    /// overlay solo si es editable
                    if (esMiMascota)
                      Container(
                        //color: Colors.black.withOpacity(0.15),
                      ),

                    /// icono editar foto
                    if (esMiMascota)
                      Positioned(
                        bottom: 15,
                        right: 15,
                        child: GestureDetector(
                          onTap: () => _seleccionarImagen(mascotaActual),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: pawBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_a_photo_rounded,
                              color: color.onPrimary,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
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
                      Text(mascotaActual.nombre, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.1)),
                      SizedBox(height: 5),
                      Text(mascotaActual.raza.replaceAll('_', ' '), style: TextStyle(fontSize: 18, color: color.primary, fontWeight: FontWeight.w600,),),
                      SizedBox(height: 5),
                      Text("${mascotaActual.edad} años", style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500,),),
                      SizedBox(height: 25),
                      Text("Personalidad", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
                      SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: mascotaActual.comportamientos.map((tag) {
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
                          Text("Sobre ${mascotaActual.nombre}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          if (esMiMascota)
                            IconButton(
                                onPressed: () => _mostrarDialogoEdicion(context, mascotaActual),
                                icon: Icon(Icons.edit_note, color: pawBlue, size: 26)
                            )
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        mascotaActual.descripcion.isEmpty
                            ? "Este peludo aún no tiene descripción, ¡pero seguro que es un encanto!"
                            : mascotaActual.descripcion,
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

                      SizedBox(height: 10),

                      postsMascota.isEmpty
                          ? Text(
                        "Esta mascota aún no aparece en ningún post",
                        style: TextStyle(color: Colors.grey),
                      )
                          : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: postsMascota.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                        itemBuilder: (context, index) {
                          final post = postsMascota[index];

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              post.rutaImagen.startsWith("http")
                                  ? post.rutaImagen
                                  : "http://10.0.2.2:8081/uploads/${post.rutaImagen}",
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
