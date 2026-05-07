import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:pawpark_frontend/providers/usuario_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

    final pawBlue = Theme.of(context).colorScheme.primary;
    final parkRed = Theme.of(context).colorScheme.secondary;
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: Center(
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
                Text(
                  "Donde tus mascotas conectan",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color.outline,
                    // fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 30),

                // Contenedor del formulario
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
                      )
                    ],
                    border: Border.all(
                      color: pawBlue.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          "¡Hola de nuevo!",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: pawBlue,
                          ),
                        ),
                        SizedBox(height: 20),

                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Correo electrónico",
                            prefixIcon: Icon(Icons.email_outlined, color: pawBlue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Campo obligatorio.";
                            }
                            // el paquete EmailValidator comprueba automáticamente si el email es válido
                            if (!EmailValidator.validate(value)) {
                              return "Introduce un email válido.";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),

                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            prefixIcon: Icon(Icons.lock_outline, color: parkRed),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Campo obligatorio.";
                            }
                            return null;
                          },
                        ),

                        if (errorMessage.isNotEmpty) ...[
                          SizedBox(height: 15),
                          Text(
                            errorMessage,
                            style: TextStyle(color: color.error, fontWeight: FontWeight.bold),
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
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                login();
                              }
                            },
                            child: isLoading
                            ? CircularProgressIndicator(color: color.onPrimary)
                            : Text(
                              "INICIAR SESIÓN",
                              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                            ),
                          ),
                        ),

                        SizedBox(height: 15),

                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, "/register"),
                          child: RichText(
                            text: TextSpan(
                              text: "¿No tienes cuenta? ",
                              style: TextStyle(color: color.outline),
                              children: [
                                TextSpan(
                                  text: "Regístrate",
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
    );
  }

  void login() async {
    try {
      // Autenticamos con Firebase
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (userCredential.user != null && mounted) {
        // Cargamos los datos del backend en el Provider
        // IMPORTANTE: Aquí es donde la app conecta con MySQL/Java
        await context.read<UsuarioProvider>().cargarUsuario(userCredential.user!.uid);
        // Navegamos limpiando el historial para que no se pueda pulsar el botón de volver atrás
        if (mounted) Navigator.pushNamedAndRemoveUntil(context, "/perfil", (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found' || e.code == 'wrong-password'){
          errorMessage = "Correo o contraseña incorrectos";
        } else {
          errorMessage = "Error al iniciar sesión";
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error de conexión con el servidor";
      });
    } finally {
      if (mounted) setState(() => isLoading = false); // Terminamos de cargar pase lo que pase
    }
  }
}