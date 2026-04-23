import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../api/usuario_model.dart';
import '../../providers/usuario_provider.dart';
import '../../widgets/bottom_bar.dart';
import '../../widgets/mascota_card.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  /// Ya no necesitamos la variable futureUsuario ni inicializar la descarga
  /// en un initState, ya que el AuthWrapper o el Provider se encargan de ello

  @override
  Widget build(BuildContext context) {

    // Intentamos capturar un usuario ajeno pasado por argumentos
    final usuarioAjeno = ModalRoute.of(context)?.settings.arguments as Usuario?;

    // Escuchamos al provider para nuestra sesión propia
    final userProvider = context.watch<UsuarioProvider>();

    /// SE DECIDE: Si hay un usuario ajeno en los argmentos, mostramos ese.
    /// Si no, al de la sesión propia.
    final user = usuarioAjeno ?? userProvider.usuario;

    // ¿Es mi propio perfil?
    final String? miUid = FirebaseAuth.instance.currentUser?.uid;
    // Es mi perfil si no viene nadie por argumentos o si el UID coincide con el mío
    final bool esMiPerfil = usuarioAjeno == null || user?.firebaseUid == miUid;

    final pawBlue = Theme.of(context).colorScheme.primary;
    final parkRed = Theme.of(context).colorScheme.secondary;
    final color = Theme.of(context).colorScheme;


    // Gestionamos los estados de carga y error (Solo si estamos intentando cargar nuestro propio perfil)
    if (userProvider.isLoading && usuarioAjeno == null) {
      return Scaffold(
          backgroundColor: color.onPrimary,
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () => showSignOutConfirmation(color),
                icon: Icon(Icons.logout, color: color.primary),
              ),
            ],
          ),
          body: Center(
              child: CircularProgressIndicator()
          )
      );
    }

    if (user == null) {
      return Scaffold(
        backgroundColor: color.onPrimary,
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () => showSignOutConfirmation(color),
              icon: Icon(Icons.logout, color: color.primary),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: color.error, size: 60),
              SizedBox(height: 20),
              Text("No se pudieron cargar los datos del perfil"),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      // Solo se muestra la barra inferior si es MI perfil
      bottomNavigationBar: esMiPerfil ? BottomBar(currentIndex: 3) : null,
      appBar: AppBar(
        // Si no es mi perfil, aparece automáticamente la flecha de volver
        automaticallyImplyLeading: !esMiPerfil,
        actions: [
          // Solo mostramos el logout si es mi propio perfil
          if (esMiPerfil)
          IconButton(
            onPressed: () => showSignOutConfirmation(color),
            icon: Icon(Icons.logout, color: color.primary),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header y avatar
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [pawBlue.withOpacity(0.9), parkRed.withOpacity(0.9)],
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(30),
                      ),
                    ),
                  ),

                  if (esMiPerfil)
                  Positioned(
                    top: 40,
                    right: 20,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Aquí ya no necesitamos capturar el 'result' ni hacer setState porque el provider trae la información
                        Navigator.pushNamed(context, "/editar-perfil");
                      },
                      icon: Icon(Icons.edit, size: 16),
                      label: Text("Editar perfil"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: color.onPrimary,
                        elevation: 0,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -60,
                    child: Container(
                      padding: EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.onPrimary,
                        border: Border.all(color: color.onPrimary, width: 4)
                      ),
                      child: ClipOval(
                        child: SizedBox(
                          width: 130,
                          height: 130,
                          child: (user.fotoPerfil != null && user.fotoPerfil.isNotEmpty)
                              ? (user.fotoPerfil.startsWith('assets/')
                                    ? Image.asset(user.fotoPerfil, fit: BoxFit.cover,)
                                    : Image.network(user.fotoPerfil, fit: BoxFit.cover))
                              : Image.asset('assets/images/person_default.png', fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 70),

              Text(user.nombre, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 17, color: color.outline),
                  Text(user.localidad, style: TextStyle(color: color.outline)),
                ],
              ),

              Text(
                "Miembro desde ${user.memberSince}",
                style: TextStyle(color: color.outline, fontSize: 13),
              ),

              if (user.descripcion.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: Text(
                    user.descripcion,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              SizedBox(height: 20),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.onPrimary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat(user.mascotas.length.toString(), "Mascotas", pawBlue),
                    _stat((user.amigos?.length ?? 0).toString(), "Amigos", parkRed),
                    _stat(user.encountersCount.toString(), "Encuentros", color.tertiary),
                  ],
                ),
              ),

              SizedBox(height: 25),

              // Header mascotas
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      esMiPerfil ? "Mis Mascotas" : "Mascotas de ${user.nombre}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (esMiPerfil)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, "/form-mascota");
                      },
                      icon: Icon(Icons.add, size: 18),
                      label: Text("Añadir"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pawBlue,
                        foregroundColor: color.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Lista de mascotas
              user.mascotas.isEmpty
                  ? Padding(padding: EdgeInsets.all(20.0), child: Text("¡Aún no hay mascotas registradas!"))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: user.mascotas.length,
                      itemBuilder: (context, index) {
                        return MascotaCard(mascota: user.mascotas[index],
                        // Activamos el corazón de favorito solo si NO es mi perfil);
                            mostrarFavorito: !esMiPerfil,
                        );
                      },
                    ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  void showSignOutConfirmation(ColorScheme color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceDim,
        title: Text("Cerrar sesión"),
        content: Text("¿Seguro que quieres salir?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCELAR", style: TextStyle(color: color.surfaceTint)),
          ),
          TextButton(
            onPressed: () async {
              // Cerramos sesión en Firebase
              await FirebaseAuth.instance.signOut();
              // Se limpia el Provider
              context.read<UsuarioProvider>().limpiarUsuario();
              // Volvemos al login
              Navigator.pushNamed(context, "/login");
            },
            child: Text(
              "CERRAR SESIÓN",
              style: TextStyle(color: color.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
