import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/usuario_provider.dart';
import '../../api/quedada_service.dart';

class FormQuedadaScreen extends StatefulWidget {
  const FormQuedadaScreen({super.key});

  @override
  State<FormQuedadaScreen> createState() => _FormQuedadaScreenState();
}

class _FormQuedadaScreenState extends State<FormQuedadaScreen> {
  // El GlobalKey nos permite validar todos los campos del formulario a la vez
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar el texto escrito por el usuario
  final _tituloController = TextEditingController();
  final _descController = TextEditingController();
  final _lugarController = TextEditingController();

  // Variables de estado para la fecha y la hora (por defecto: mañana a las 18:00)
  DateTime _fecha = DateTime.now().add(Duration(days: 1));
  TimeOfDay _hora = TimeOfDay(hour: 18, minute: 0);

  // Para mostrar un circulito de carga mientras el backend responde
  bool _isLoading = false;

  // Muestra el calendario nativo del móvil
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now(), // No permitimos quedadas en el pasado
      lastDate: DateTime.now().add(Duration(days: 90)), // Máximo 3 meses vista
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  // Muestra el reloj nativo del móvil
  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _hora);
    if (picked != null) setState(() => _hora = picked);
  }

  // MÉTODO PARA ENVIAR LOS DATOS A JAVA
  Future<void> _submit() async {
    // Validamos que los campos obligatorios estén rellenos
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Combinamos el objeto DateTime de la fecha con el TimeOfDay de la hora
    final fechaFinal = DateTime(
        _fecha.year, _fecha.month, _fecha.day, _hora.hour, _hora.minute
    );

    // Obtenemos el UID del creador desde el Provider (sin esperas)
    final userProvider = Provider.of<UsuarioProvider>(context, listen: false);
    final uid = userProvider.usuario?.firebaseUid;

    // Preparamos el "paquete" (JSON) para enviar a Spring Boot
    final payload = {
      "creadorUid": uid,
      "titulo": _tituloController.text,
      "descripcion": _descController.text,
      "lugarNombre": _lugarController.text,
      "fechaHora": fechaFinal.toIso8601String(), // Formato ISO que entiende LocalDateTime.parse()
    };

    try {
      // Llamamos al servicio de la API
      final success = await QuedadaService.crearQuedada(payload);

      if (success != null && mounted) {
        // Si hay éxito, cerramos la pantalla y devolvemos 'true' para que la lista se refresque
        Navigator.pop(context, true);
      }
    } catch (e) {
      // Si el backend da error (ej: servidor apagado), mostramos aviso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al conectar con el servidor: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Nueva quedada", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Organiza un encuentro",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color.primary)),
              SizedBox(height: 25),

              TextFormField(
                controller: _tituloController,
                decoration: _inputDeco("Nombre de la quedada", Icons.auto_awesome),
                validator: (v) => v!.isEmpty ? "El título es obligatorio" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _lugarController,
                decoration: _inputDeco("¿Dónde nos vemos?", Icons.location_on),
                validator: (v) => v!.isEmpty ? "El lugar es obligatorio" : null,
              ),
              SizedBox(height: 20),

              // Fila con los selectores de Fecha y Hora
              Row(
                children: [
                  Expanded(
                    child: _dateTimeTile(
                        label: "Día",
                        value: DateFormat('dd/MM/yyyy').format(_fecha),
                        icon: Icons.calendar_month,
                        onTap: _pickDate
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: _dateTimeTile(
                        label: "Hora",
                        value: _hora.format(context),
                        icon: Icons.schedule,
                        onTap: _pickTime
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Campo descripción multilínea
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: _inputDeco("Detalles adicionales...", Icons.notes),
              ),

              SizedBox(height: 40),

              // Botón de enviar
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: color.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  child: Text("PUBLICAR",
                      style: TextStyle(color: color.onPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Estilo reutilizable para los campos de texto
  InputDecoration _inputDeco(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
  );

  // Widget personalizado para los botones de Fecha/Hora
  Widget _dateTimeTile({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[600]!),
            borderRadius: BorderRadius.circular(15)
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 12)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.blueGrey),
                SizedBox(width: 8),
                Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}