import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imagenSeleccionada = File(picked.path);
      });
    }
  }

  Future<void> publicarPost() async {
    final user = context.read<UsuarioProvider>().usuario;
    final postProvider = context.read<PostProvider>();

    if (imagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona una imagen")),
      );
      return;
    }

    final success = await postProvider.crearPost(
      imagen: imagenSeleccionada!,
      uid: user!.firebaseUid,
      descripcion: descripcionController.text,
      mascotasIds: mascotasSeleccionadas
          .where((m) => m.id != null)
          .map((m) => m.id!)
          .toList(),
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Post publicado!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    final user = context.watch<UsuarioProvider>().usuario;
    final postProvider = context.watch<PostProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo post"),
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
                  
              /// 🐶 MASCOTAS
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
              /// 🚀 BOTÓN
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: postProvider.isLoading
                      ? null
                      : publicarPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: postProvider.isLoading
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