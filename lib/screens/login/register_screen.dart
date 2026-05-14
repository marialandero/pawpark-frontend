import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:pawpark_frontend/api/service/usuario_service.dart';
import 'package:pawpark_frontend/providers/usuario_provider.dart';
import 'package:provider/provider.dart';
import '../../api/service/ubicacion_service.dart' as UbicacionService;

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
  double? latitudSeleccionada;
  double? longitudSeleccionada;
  bool isLoading = false;
  String errorMessage = '';
  bool _aceptaTerminos = false;

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
                    "assets/images/pawpark_draw.png",
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
                          // Desplegable para detectar la localidad
                          Autocomplete<Map<String, dynamic>>(
                            displayStringForOption: (option) => option['display_name']!,
                            optionsBuilder: (TextEditingValue textEditingValue) async {
                              print("Escribiendo: ${textEditingValue.text}"); // Si esto sale en consola, el widget está bien
                              if (textEditingValue.text.length < 3) return const Iterable.empty();
                              final resultados = await UbicacionService.buscarCiudad(textEditingValue.text);
                              print("Resultados encontrados: ${resultados.length}"); // Si sale 0, es la API o el filtro
                              return resultados;

                            },
                            onSelected: (Map<String, dynamic> selection) {
                              setState(() {
                                locationController.text = selection['display_name'];
                                latitudSeleccionada = selection['lat'];
                                longitudSeleccionada = selection['lon'];
                              });
                            },
                            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                              // Sincronizamos el texto escrito con nuestro locationController principal
                              // para que la función register() pueda leerlo después.
                              if (locationController.text.isNotEmpty && controller.text.isEmpty) {
                                controller.text = locationController.text;
                              }
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  labelText: "Localidad",
                                  prefixIcon: Icon(Icons.location_on_outlined, color: pawBlue),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  helperText: "Si no aparece en la lista, escríbela a mano",
                                ),
                                onChanged: (value) {
                                  // Cada vez que el usuario escribe, actualizamos el controlador principal.
                                  // Si escribe a mano, latitud y longitud seguirán siendo null,
                                  // pero el String de la localidad se guardará correctamente.
                                  locationController.text = value;

                                  // Opcional: Si empieza a escribir de nuevo tras haber seleccionado algo,
                                  // reseteamos las coordenadas para que no se guarden coordenadas de otra ciudad.
                                  latitudSeleccionada = null;
                                  longitudSeleccionada = null;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) return "Campo obligatorio";
                                  return null;
                                },
                              );
                            },
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

                          SizedBox(height: 10),
                          Row(
                            children: [
                              Checkbox(
                                value: _aceptaTerminos,
                                activeColor: pawBlue,
                                onChanged: (value) {
                                  setState(() {
                                    _aceptaTerminos = value!;
                                  });
                                },
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _mostrarTerminos(context),
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Acepto los ",
                                      style: TextStyle(color: color.onSurface, fontSize: 13),
                                      children: [
                                        TextSpan(
                                          text: "Términos y Condiciones",
                                          style: TextStyle(
                                            color: pawBlue,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
        
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pawBlue,
                                foregroundColor: color.onPrimary,
                                disabledBackgroundColor: Colors.grey[300],
                                disabledForegroundColor: Colors.grey[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: isLoading ? 0 : 3,
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

  void _mostrarTerminos(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Términos y Condiciones"),
          content: SingleChildScrollView(
            child: Text(
              """
              Términos y Condiciones de Uso - PawPark
              
1. Aceptación de los Términos
Al crear una cuenta en PawPark, el usuario acepta los presentes términos. Esta aplicación tiene como objetivo facilitar el encuentro entre dueños de perros y la gestión de zonas caninas.

2. Naturaleza del Servicio
PawPark es una red social basada en la ubicación. Al utilizar la función de "Check-in", el usuario consiente que su presencia y la de su mascota sean visibles para otros usuarios de la plataforma en la zona seleccionada.

3. Responsabilidad del Usuario
El usuario es el único responsable de la veracidad de los datos de su mascota.

PawPark no se hace responsable de los incidentes, daños o altercados que puedan ocurrir durante las "Quedadas" o encuentros físicos. Se recomienda mantener siempre la supervisión de los animales según la normativa local vigente.

Queda prohibida la publicación de contenido ofensivo, violento o que fomente el maltrato animal.

4. Privacidad y Datos
Los datos de perfil (nombre, foto de mascota, biografía) son públicos para mejorar la experiencia social. PawPark utiliza Firebase para la autenticación segura, asegurando que las contraseñas no sean accesibles por los administradores del sistema.

5. Uso de OpenStreetMap
PawPark utiliza datos de OpenStreetMap para la geolocalización de parques. El usuario acepta que la precisión de las zonas depende de servicios externos.

6. Baja del Servicio
El usuario puede eliminar su cuenta en cualquier momento. Al hacerlo, sus datos personales, mascotas y registros de presencia (Check-ins) serán eliminados permanentemente de nuestra base de datos.
              """,
              textAlign: TextAlign.justify,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("CERRAR"),
            ),
          ],
        );
      },
    );
  }

  void register() async {
    if (!_aceptaTerminos) {
      setState(() {
        errorMessage = "Debes aceptar los términos y condiciones para registrarte";
      });
      return; // Esto detiene el registro aquí mismo
    }
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
        await userCredential.user!.updateDisplayName(nicknameController.text.trim());
        String localidadFinal = locationController.text.trim();
        final datosParaBackend = {
          'firebaseUid': userCredential.user!.uid,
          'nombre': nameController.text.trim(),
          'nickname': nicknameController.text.trim(),
          'localidad': localidadFinal,
          'latitudPref': latitudSeleccionada,
          'longitudPref': longitudSeleccionada,
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
