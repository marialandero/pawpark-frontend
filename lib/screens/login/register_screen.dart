import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'package:pawpark_frontend/api/service/usuario_service.dart';
import 'package:pawpark_frontend/providers/usuario_provider.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nicknameController = TextEditingController();
  final locationController = TextEditingController();
  final nameController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    // Variables para manejar colores
    final pawBlue = Theme.of(context).colorScheme.primary;
    final parkRed = Theme.of(context).colorScheme.secondary;
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/pawpark_logo.png",
                    height: 250,
                    fit: BoxFit.contain,
                  ),
        
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: color.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: pawBlue.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            "¡Únete a la manada!",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: pawBlue,
                            ),
                          ),
                          SizedBox(height: 20),
        
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: "Nombre completo",
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: pawBlue,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? "Campo obligatorio"
                                : null,
                          ),
                          SizedBox(height: 15),
        
                          TextFormField(
                            controller: nicknameController,
                            decoration: InputDecoration(
                              labelText: "Nickname (ej: @tobi_fan)",
                              prefixIcon: Icon(
                                Icons.alternate_email,
                                color: pawBlue,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? "Campo obligatorio"
                                : null,
                          ),
                          SizedBox(height: 15),
        
                          TextFormField(
                            controller: locationController,
                            decoration: InputDecoration(
                              labelText: "Localidad",
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: pawBlue,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? "Campo obligatorio"
                                : null,
                          ),
                          SizedBox(height: 15),
        
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: "Correo electrónico",
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: pawBlue,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Campo obligatorio.";
                              }
                              if (!EmailValidator.validate(value)) {
                                return "Introduce un email válido.";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
        
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Contraseña",
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: parkRed,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 6)
                                return "La contraseña debe tener al menos 6 caracteres";
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
        
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Confirmar contraseña",
                              prefixIcon: Icon(Icons.lock_reset, color: parkRed),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Debes confirmar tu contraseña";
                              }
                              if (value != passwordController.text) {
                                return "Las contraseñas no coinciden";
                              }
                              return null;
                            },
                          ),
        
                          if (errorMessage.isNotEmpty) ...[
                            SizedBox(height: 15),
                            Text(
                              errorMessage,
                              style: TextStyle(
                                color: color.error,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
        
                          SizedBox(height: 25),
        
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pawBlue,
                                foregroundColor: color.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              // Si está cargando, deshabilitamos el botón (onPressed: null)
                              onPressed: isLoading ? null : () {
                                if (_formKey.currentState!.validate()) {
                                  register();
                                }
                              },
                              child: Text(
                                "CREAR CUENTA",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
        
                          SizedBox(height: 15),
        
                          // Para volver al login
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: RichText(
                              text: TextSpan(
                                text: "¿Ya tienes cuenta? ",
                                style: TextStyle(color: color.outline),
                                children: [
                                  TextSpan(
                                    text: "Inicia sesión",
                                    style: TextStyle(
                                      color: parkRed,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void register() async {
    setState(() {
      errorMessage = '';
      isLoading = true; // Bloqueamos la interfaz
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      if (userCredential.user != null) {
        final datosParaBackend = {
          'firebaseUid': userCredential.user!.uid,
          'nombre': nameController.text.trim(),
          'nickname': nicknameController.text.trim(),
          'localidad': locationController.text.trim(),
          'email': emailController.text.trim(),
          'fotoPerfil': null,
          'memberSince': DateTime.now().year.toString(),
          'encountersCount': 0,
        };

        // Sincronización con Java (MySQL)
        final exitoBackend = await UsuarioService.registrarEnBackend(
          datosParaBackend,
        );

        if (exitoBackend && mounted) {
          final userProvider = Provider.of<UsuarioProvider>(context, listen: false);
          await userProvider.cargarUsuario(userCredential.user!.uid);
          if (mounted) Navigator.pushNamedAndRemoveUntil(context, "/perfil", (route) => false);
        } else {
          setState(() {
            errorMessage = "Cuenta creada en Firebase, pero hubo un error con el servidor de PawPark";
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "Error en Firebase";
      });
    } catch (e) {
      setState(() {
        errorMessage = "Ocurrió un error inesperado";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Liberamos el botón
        });
      }
    }
  }
}
