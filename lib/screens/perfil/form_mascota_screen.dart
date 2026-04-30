import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:pawpark_frontend/api/mascota_service.dart';
import 'package:provider/provider.dart';
import '../../providers/usuario_provider.dart';

class FormMascotaScreen extends StatefulWidget {
  const FormMascotaScreen({super.key});

  @override
  State<FormMascotaScreen> createState() => _FormMascotaScreenState();
}

class _FormMascotaScreenState extends State<FormMascotaScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final edadController = TextEditingController();
  List<String> selectedTags = []; // Lista para almacenar varios comportamientos

  String? _razaSeleccionadaParaBackend;
  String comportamiento = "SOCIABLE"; // Valor por defecto
  bool isSaving = false;

  final List<String> _comportamientos = [
    "SOCIABLE", "TRANQUILO", "REACTIVO", "JUGUETON", "ENERGETICO", "CARIÑOSO", "AVENTURERO",
    "MIEDOSO", "NERVIOSO", "INQUIETO", "OBEDIENTE", "GRUÑON", "SUMISO", "DOMINANTE", "GLOTON"
  ];

  final List<String> _todasLasRazas = [
    "AMERICAN_STAFFORDSHIRE_TERRIER", "BODEGUERO_ANDALUZ", "BULL_TERRIER",
    "STAFFORDSHIRE_BULL_TERRIER", "JACK_RUSSELL_TERRIER", "YORKSHIRE_TERRIER",
    "PITBULL_TERRIER", "PASTOR_ALEMAN", "PASTOR_BELGA_MALINOIS",
    "PASTOR_AUSTRALIANO", "BORDER_COLLIE", "ROTTWEILER", "DOBERMAN", "BOXER",
    "CANICHE", "GALGO", "PODENCO", "BEAGLE", "COCKER_SPANIEL", "SETTER_IRLANDES",
    "BRETON", "CANE_CORSO", "GOLDEN_RETRIEVER", "LABRADOR_RETRIEVER",
    "MASTIN_ESPANOL", "DOGO_ALEMAN", "DOGO_ARGENTINO", "SAN_BERNARDO",
    "AKITA_INU", "BICHON_MALTES", "BULLDOG_FRANCES", "BULLDOG_INGLES",
    "CHIHUAHUA", "PUG_CARLINO", "SHIBA_INU", "POMERANIA", "SHIH_TZU",
    "PERRO_DE_AGUA", "MESTIZO", "OTRA_RAZA"
  ];

  @override
  void dispose() {
    // Liberamos memoria de los controladores al cerrar la pantalla
    nameController.dispose();
    edadController.dispose();
    super.dispose();
  }

  String _formatearTextoLegible(String text) {
    if (text.isEmpty) return "";
    return text.replaceAll('_', ' ').toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return "";
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  // Lógica de colores por comportamiento (para que coincida con las cards)
  Color _obtenerColorComportamiento(String tag) {
    switch (tag) {
      case 'SOCIABLE': return Color(0xff61b17a);
      case 'TRANQUILO': return Color(0xff6197b7);
      case 'REACTIVO': return Color(0xffb2173a);
      case 'JUGUETON': return Color(0xffbb1dc5);
      case 'ENERGETICO': return Color(0xffdcb75c);
      case 'CARIÑOSO': return Color(0xfff27070);
      case 'AVENTURERO': return Color(0xff239a86);
      case 'MIEDOSO': return Color(0xc88fa6f1);
      case 'NERVIOSO': return Color(0xc8d68ff1);
      case 'INQUIETO': return Color(0xffeb985d);
      case 'OBEDIENTE': return Color(0xff3f51b5);
      case 'GRUÑON': return Color(0xff8d6e63);
      case 'SUMISO': return Color(0xff8ec280);
      case 'DOMINANTE': return Color(0xe7b6407f);
      case 'GLOTON': return Color(0xffbe921c);
      default: return Colors.grey;
    }
  }

  Future<void> _guardarMascota() async {
    if (selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecciona al menos un comportamiento")),
      );
      return;
    }
    setState(() => isSaving = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;

    final data = {
      'nombre': nameController.text.trim(),
      'raza': _razaSeleccionadaParaBackend,
      'edad': int.tryParse(edadController.text.trim()) ?? 0,
      'comportamientos': selectedTags,
      'fotoPerfilMascota': null,
      'duenoFirebaseUid': uid,
    };

    try {
      // Usamos el MascotaService
      final success = await MascotaService.crearMascota(data);

      if (success || mounted) {
        // Pedimos al Provider que refresque TODO el perfil del usuario
        // Esto traerá la nueva mascota y actualizará el contador en la UI
        await context.read<UsuarioProvider>().cargarUsuario(uid ?? "");
        // Volvemos atrás y PerfilScreen se redibujará sola al detectar el cambio en el Provider
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("¡Mascota añadida con éxito!")),
        );
      } else {
        // Si hay error (ej: 400), el GlobalExceptionHandler del backend enviará el detalle
        print("Error del servidor");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar")),
        );
      }
    } catch (e) {
      print("Error de conexión: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo conectar con el servidor")),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pawBlue = Theme.of(context).colorScheme.primary;
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Nueva mascota", style: TextStyle(fontWeight: FontWeight.bold))
      ),
      body: SingleChildScrollView( // Mejor que ListView para controlar los espacios
        padding: EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Cuéntanos sobre tu peludo",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: pawBlue)),
              SizedBox(height: 25),

              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Nombre de la mascota",
                  prefixIcon: Icon(Icons.pets),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                ),
                validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
              ),
              SizedBox(height: 20),

              // Sección de raza
              Autocomplete<String>(
                displayStringForOption: (option) => _formatearTextoLegible(option),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  // Si el campo está vacío, mostramos TODAS las razas (así funciona como desplegable)
                  if (textEditingValue.text.isEmpty) {
                    return _todasLasRazas;
                  }
                  // Si hay texto, filtramos normalmente
                  return _todasLasRazas.where((String option) {
                    return option.contains(textEditingValue.text.toUpperCase().replaceAll(' ', '_'));
                  });
                },
                onSelected: (String selection) {
                  setState(() => _razaSeleccionadaParaBackend = selection);
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: "Raza de la mascota",
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.arrow_drop_down),
                        onPressed: () {
                          // Al pulsar la flecha, pedimos el foco para que se abra la lista
                          focusNode.requestFocus();
                          // Opcional: Si quisiera ver todo al pulsar, podría limpiar el texto con:
                          // controller.clear();
                        },
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    validator: (v) => (_razaSeleccionadaParaBackend == null)
                        ? "Selecciona una raza de la lista" : null,
                  );
                },
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: edadController,
                decoration: InputDecoration(
                  labelText: "Edad",
                  prefixIcon: Icon(Icons.cake),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
              ),
              SizedBox(height: 25),

              // Sección de comportamiento
              Text("¿Cómo es su personalidad?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
              SizedBox(height: 15),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _comportamientos.map((tag) {
                  final isSelected = selectedTags.contains(tag); // Comprueba si está en la lista
                  final tagColor = _obtenerColorComportamiento(tag);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedTags.remove(tag); // Si ya estaba, lo quita
                        } else {
                          selectedTags.add(tag);    // Si no estaba, lo añade
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? tagColor : Colors.grey[200],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        _formatearTextoLegible(tag),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 40),

              // Bótón de guardar
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isSaving ? null : () {
                    if (_formKey.currentState!.validate()) _guardarMascota();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pawBlue,
                    foregroundColor: color.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: isSaving
                      ? CircularProgressIndicator(color: color.onPrimary)
                      : Text("GUARDAR EN LA MANADA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}