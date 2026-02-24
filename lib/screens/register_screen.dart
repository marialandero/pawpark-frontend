import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';

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
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    // Colores basados en el logo de PawPark
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
                SizedBox(height: 25),

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
                            if (!EmailValidator.validate(value)) {
                              return "Introduce un email válido.";
                            }
                            return null;
                          }
                        ),
                        SizedBox(height: 15),

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
                            if (value == null || value.length < 6) return "La contraseña debe tener al menos 6 caracteres";
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
                              return "Debes confirmar tu contraseña.";
                            }
                            if (value != passwordController.text) {
                              return "Las contraseñas no coinciden.";
                            }
                            return null;
                          },
                        ),

                        if (errorMessage.isNotEmpty) ...[
                          SizedBox(height: 15),
                          Text(
                            errorMessage,
                            style: TextStyle(color: color.error, fontWeight: FontWeight.bold),
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
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                register();
                              }
                            },
                            child: Text(
                              "CREAR CUENTA",
                              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
    );
  }

  void register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (mounted) Navigator.pushNamed(context, "/welcome");
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          errorMessage = "El correo ya está registrado";
        } else {
          errorMessage = "Error al crear la cuenta";
        }
      });
    }
  }
}