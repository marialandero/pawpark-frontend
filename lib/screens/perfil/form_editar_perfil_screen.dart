import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../providers/usuario_provider.dart';
import '../../api/usuario_model.dart';
import '../../api/usuario_service.dart';

class FormEditarPerfilScreen extends StatefulWidget {
  const FormEditarPerfilScreen({super.key});

  @override
  State<FormEditarPerfilScreen> createState() => _FormEditarPerfilScreenState();
}

class _FormEditarPerfilScreenState extends State<FormEditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();

  String? fotoActual; // Variable para no perder la imagen
  late TextEditingController nombreController;
  late TextEditingController ubicacionController;
  late TextEditingController emailController;
  late TextEditingController bioController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos los controladores (vacíos al principio)
    nombreController = TextEditingController();
    ubicacionController = TextEditingController();
    emailController = TextEditingController();
    bioController = TextEditingController();

    // Escuchamos al Provider una sola vez para llenar los campos inmediatamente
    //Se ordena a Dlutter que se ejecute este código una vez se dibuje la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UsuarioProvider>().usuario;
      if (user != null) {
        nombreController.text = user.nombre;
        ubicacionController.text = user.localidad;
        emailController.text = user.email;
        bioController.text = user.descripcion;
        fotoActual = user.fotoPerfil;
      }
    });
  }

  @override
  void dispose() {
    nombreController.dispose();
    ubicacionController.dispose();
    emailController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pawBlue = Theme.of(context).colorScheme.primary;
    final parkRed = Theme.of(context).colorScheme.secondary;
    final color = Theme.of(context).colorScheme;

    // Obtenemos el usuario del Provider (usamos watch para reaccionar si cambia)
    final user = context.watch<UsuarioProvider>().usuario;

    // Si el usuario existe y el campo nombre está vacío (evita que se borre lo que el usuario escribe)
    // rellenamos los controladores.
    if (user != null && nombreController.text.isEmpty && !isSaving) {
      nombreController.text = user.nombre;
      ubicacionController.text = user.localidad;
      emailController.text = user.email;
      bioController.text = user.descripcion;
      fotoActual = user.fotoPerfil;
    }

    return Scaffold(
      backgroundColor: color.onPrimary,
      appBar: AppBar(
        backgroundColor: color.onPrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Editar perfil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : actualizarPerfil,
              icon: Icon(Icons.save, size: 18),
              label: Text("Guardar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: pawBlue,
                foregroundColor: color.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// Sección para la foto de perfil, TENGO QUE AÑADIR LA
              /// FUNCIONALIDAD DE SUBIR FOTO
              buildCard(
                title: "Foto de perfil",
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage(
                            'assets/images/person_default.png',
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: pawBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_a_photo_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Toca el ícono de la cámara para cambiar tu foto de perfil",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Card para la sección de la información personal
              buildCard(
                title: "Información personal",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildInputLabel("Nombre"),
                    buildTextField(nombreController),
                    SizedBox(height: 15),
                    buildInputLabel("Ubicación"),
                    buildTextField(ubicacionController),
                    SizedBox(height: 15),
                    buildInputLabel("Email"),
                    buildTextField(emailController, enabled: false),
                    // El email es fijo
                    SizedBox(height: 15),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Card para la sección de biografía
              buildCard(
                title: "Sobre ti",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildInputLabel("Biografía"),
                    buildTextField(
                      bioController,
                      maxLines: 4,
                      hint: "Cuéntanos algo sobre ti...",
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Botones para cancelar o guardar cambios
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSaving ? null : actualizarPerfil,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pawBlue,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Guardar cambios",
                        style: TextStyle(color: color.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widgets de apoyo para la UI

  Widget buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceDim,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget buildInputLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget buildTextField(
    TextEditingController controller, {
    int maxLines = 1,
    String? hint,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? Colors.blueGrey[700] : Colors.grey[500],
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        filled: true,
        fillColor: enabled ? Colors.grey[100] : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      ),
    );
  }

  Future<void> actualizarPerfil() async {
    if (nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("El nombre es obligatorio")));
      return;
    }

    setState(() => isSaving = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;

    // Creamos el mapa de datos primero
    final datosAEnviar = {
      'nombre': nombreController.text.trim(),
      'localidad': ubicacionController.text.trim(),
      'descripcion': bioController.text.trim(),
      'fotoPerfil': fotoActual ?? 'assets/images/person_default.png',
      'email': emailController.text.trim(),
      'nickname': emailController.text.split('@')[0],
      'encountersCount': 0,
      // Tienen que existir estos campos en Usuario.java
    };

    try {
      // Enviamos los datos
      final usuarioActualizado = await UsuarioService.actualizarPerfil(uid!, datosAEnviar);

      // Usamos la variable local con la respuesta del backend y volvemos a la pantalla de perfil enviando 'true' para refrescar datos
      if (usuarioActualizado != null && mounted) {
        context.read<UsuarioProvider>().actualizarDatosLocales(usuarioActualizado);
        Navigator.pop(context); // Ya no pasamos parámetros al pop
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("¡Perfil actualizado!")));
        } else {
        // Error del servidor (ej: 400 o 500)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar")),
        );
      }
    } catch (e) {
      // Error de red (servidor apagado o IP incorrecta)
      print("Error de conexión: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo conectar con el servidor")),
      );
    } finally {
      /// Si el usuario sigue viendo la pantalla (está mounted), se actualiza el Provider cuando llegye la respuesta del servidor,
      /// pero si el usuario ya no está viendo la pantalla, no hacemos nada con la UI para evitar errores
      if (mounted) setState(() => isSaving = false);
    }
  }
}
