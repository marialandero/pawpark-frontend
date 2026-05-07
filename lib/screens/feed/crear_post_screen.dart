import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawpark_frontend/api/service/storage_service.dart';
import 'package:provider/provider.dart';

import '../../providers/post_provider.dart';
import '../../providers/usuario_provider.dart';
import '../../api/model/mascota_model.dart';

class CrearPostScreen extends StatefulWidget {
  const CrearPostScreen({super.key});

  @override
  State<CrearPostScreen> createState() => _CrearPostScreenState();
}

class _CrearPostScreenState extends State<CrearPostScreen> {

  final TextEditingController descripcionController = TextEditingController();
  File? imagenSeleccionada;
  final picker = ImagePicker();
  List<Mascota> mascotasSeleccionadas = [];
  bool _enviando = false;

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imagenSeleccionada = File(picked.path);
      });
    }
  }

  Future<void> publicarPost() async {
    // Si ya estamos enviando, salimos para evitar duplicados
    if (_enviando) return;
    final user = context.read<UsuarioProvider>().usuario;
    final postProvider = context.read<PostProvider>();

    if (imagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona una imagen")),
      );
      return;
    }
    setState(() => _enviando = true); // Para que el botón muestre el loading
    try{
      // Sube la imagen a Firebase
      // Usamos la carpeta 'posts' para organizar el storage
      final String? urlImagen = await StorageService.subirImageAFirebase(
          imagen: XFile(imagenSeleccionada!.path),
          carpeta: 'posts'
      );

      if (urlImagen == null) {
        throw Exception("No se pudo subir la imagen a Firebase");
      }
      // Llamamos al Provider
      final success = await postProvider.crearPost(
          rutaImagen: urlImagen,
          uid: user!.firebaseUid,
          descripcion: descripcionController.text,
          mascotasIds: mascotasSeleccionadas.where((m) => m.id != null).map((m) => m.id!).toList()
      );
      if (success && mounted) {
        // Antes de cerrar la pantalla, obligamos al Provider a traer la lista nueva del Backend
        await postProvider.cargarFeed(user.firebaseUid);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("¡Post publicado!")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Manejo de errores durante la subido o creación
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al publicar: $e"))
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    final user = context.watch<UsuarioProvider>().usuario;
    final postProvider = context.watch<PostProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Nuevo post",
        style: TextStyle(fontWeight: FontWeight.bold),),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
                  
              /// 🖼️ IMAGEN
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: imagenSeleccionada == null
                      ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 40),
                      SizedBox(height: 10),
                      Text("Selecciona una imagen"),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      imagenSeleccionada!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
                  
              const SizedBox(height: 20),
                  
              /// 📝 DESCRIPCIÓN
              TextField(
                controller: descripcionController,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: "Escribe algo sobre el momento...",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
                  
              const SizedBox(height: 20),
                  
              // Mascotas
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Etiquetar mascotas",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color.primary,
                  ),
                ),
              ),
                  
              const SizedBox(height: 10),
                  
              Wrap(
                spacing: 8,
                children: user?.mascotas.map<Widget>((m) {
                  final selected = mascotasSeleccionadas.contains(m);
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          mascotasSeleccionadas.remove(m);
                        } else {
                          mascotasSeleccionadas.add(m);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.primary
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        m.nombre,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList() ??
                    [],
              ),
                SizedBox(height: 30),
              // Botón
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (_enviando || postProvider.isLoading)
                      ? null
                      : publicarPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.primary,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: (_enviando || postProvider.isLoading)
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "PUBLICAR",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}