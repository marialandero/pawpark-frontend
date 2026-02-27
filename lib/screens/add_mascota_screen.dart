import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AddMascotaScreen extends StatefulWidget {
  const AddMascotaScreen({super.key});

  @override
  State<AddMascotaScreen> createState() => _AddMascotaScreenState();
}

class _AddMascotaScreenState extends State<AddMascotaScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final razaController = TextEditingController();
  final edadController = TextEditingController();
  String comportamiento = "SOCIABLE";

  bool isSaving = false;

  Future<void> _guardarMascota() async {
    setState(() => isSaving = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // IMPORTANTE: Asegúrate de que este endpoint exista en tu Java
    final url = Uri.parse('http://10.0.2.2:8081/mascotas');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nameController.text.trim(),
          'raza': razaController.text.trim(),
          'edad': int.parse(edadController.text.trim()),
          'comportamiento': comportamiento,
          'foto': 'https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg',
          'firebaseUidDueno': uid, // Vinculamos con el usuario logueado
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.pop(context, true);
        print("Error backend: ${response.body}");
      }
    } catch (e) {
      print("Error red: $e");
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pawBlue = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text("Nueva Mascota"), backgroundColor: pawBlue, foregroundColor: Colors.white),
      body: Padding(
        padding: EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Cuéntanos sobre tu peludo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: pawBlue)),
              SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Nombre de la mascota", prefixIcon: Icon(Icons.pets)),
                validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: razaController,
                decoration: InputDecoration(labelText: "Raza", prefixIcon: Icon(Icons.category)),
                validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: edadController,
                decoration: InputDecoration(labelText: "Edad", prefixIcon: Icon(Icons.cake)),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: comportamiento,
                decoration: InputDecoration(labelText: "Comportamiento", prefixIcon: Icon(Icons.mood)),
                items: ["SOCIABLE", "TRANQUILO", "REACTIVO", "JUGUETON", "ENERGETICO", "CARIÑOSO", "AVENTURERO"].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (newValue) => setState(() => comportamiento = newValue!),
              ),
              SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isSaving ? null : () {
                    if (_formKey.currentState!.validate()) _guardarMascota();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: pawBlue, foregroundColor: Colors.white),
                  child: isSaving
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("GUARDAR EN LA MANADA", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}