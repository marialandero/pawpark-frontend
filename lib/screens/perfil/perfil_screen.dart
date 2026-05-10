import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../api/model/usuario_model.dart';
import '../../api/service/usuario_service.dart';
import '../../providers/usuario_provider.dart';
import '../../widgets/bottom_bar.dart';
import '../../widgets/mascota_card.dart';
import '../../utils/image_helper.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {

  Usuario? usuarioAjeno; // Variable que sí podemos reasignar
  bool inicializado = false;


  /// Método para refrescar los datos dependiendo de quién es el perfil
  Future<void> _refrescarDatos(bool esMiPerfil, String uid) async {
    if (esMiPerfil) {
      // Si es mi perfil, refrescamos el Provider global
      await context.read<UsuarioProvider>().recargarUsuario();
    } else {
      // Si es perfil ajeno, actualizamos solo el estado local de esta pantalla
      final nuevoUser = await UsuarioService.fetchPerfil(uid);
      if (mounted) {
        setState(() {
          usuarioAjeno = nuevoUser;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    if (!inicializado) {
      // Solo la inicializamos la primera vez que entramos
      // Intentamos capturar un usuario ajeno pasado por argumentos
        usuarioAjeno = ModalRoute.of(context)?.settings.arguments as Usuario?;
        inicializado = true;
    }

    // Escuchamos al provider para nuestra sesión propia
    final userProvider = context.watch<UsuarioProvider>();
    final String? miUid = FirebaseAuth.instance.currentUser?.uid;

    final bool esMiPerfil = usuarioAjeno == null || usuarioAjeno?.firebaseUid == miUid;
    final user = esMiPerfil ? userProvider.usuario : usuarioAjeno;

    // COMPROBACIÓN DE SEGUIMIENTO:
    // Verificamos si el UID del perfil que vemos está en la lista 'siguiendo' de nuestro provider
    final bool loSigo =
        userProvider.usuario?.siguiendo.any(
          (u) => u.firebaseUid == user?.firebaseUid,
        ) ?? false;

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
        body: Center(child: CircularProgressIndicator()),
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
        scrolledUnderElevation: 0,
        // Si no es mi perfil, aparece automáticamente la flecha de volver
        automaticallyImplyLeading: !esMiPerfil,
        leading: esMiPerfil
        ? IconButton(
            onPressed: () => Navigator.pushNamed(context, "/ajustes"),
            icon: Icon(Icons.menu, color: pawBlue)
        )
        : null,
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
                        colors: [
                          pawBlue.withOpacity(0.9),
                          parkRed.withOpacity(0.9),
                        ],
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
                          // Añadimos el refresco al volver de editar
                          Navigator.pushNamed(context, "/editar-perfil")
                              .then((_) => _refrescarDatos(true, user.firebaseUid));
                        },
                        icon: Icon(Icons.edit, size: 16),
                        label: Text("Editar perfil"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: color.onPrimary,
                          elevation: 0,
                        ),
                      ),
                    )
                  else
                    // BOTÓN PARA SEGUIR A UN PERFIL AJENO
                    Positioned(
                      top: 40,
                      right: 20,
                      child: loSigo
                          ? TextButton.icon(
                              onPressed: () async {
                                await userProvider.alternarSeguimiento(user.firebaseUid);
                                // Refresco unificado
                                await _refrescarDatos(false, user.firebaseUid);
                              },
                              icon: Icon(
                                Icons.check,
                                color: color.onPrimary,
                                size: 20,
                              ),
                              label: Text(
                                "Siguiendo",
                                style: TextStyle(
                                  color: color.onPrimary,
                                  fontSize: 16,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () async {
                                // Cambiamos el estado en el servidor (nosotros empezamos a seguirle)
                                await userProvider.alternarSeguimiento(user.firebaseUid);
                                // Pedimos los datos frescos de este usuario específico
                                await _refrescarDatos(false, user.firebaseUid);
                              },
                              icon: Icon(Icons.person_add, size: 18),
                              label: Text("Seguir", style: TextStyle(fontSize: 16),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color.primary.withOpacity(0.3),
                                foregroundColor: color.onPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)
                                ),
                                side: BorderSide(color: color.onPrimary.withOpacity(0.4), width: 1)
                              ),
                            ),
                    ),

                  // Avatar
                  Positioned(
                    bottom: -60,
                    child: GestureDetector(
                      onTap: () => _verImagenAmpliada(context, ImageHelper.user(user.fotoPerfil)),
                      child: Container(
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.surfaceContainerLowest,
                          border: Border.all(color: color.surfaceContainerLowest, width: 4),
                        ),
                        child: ClipOval(
                          child: SizedBox(
                            width: 130,
                            height: 130,
                            child: Image.network(
                              ImageHelper.user(user.fotoPerfil),
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                                return Shimmer.fromColors(
                                  baseColor: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
                                  highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
                                  child: Container(color: Colors.white), // El Shimmer llena el círculo
                                );
                              },
                              errorBuilder: (_, __, ___) => Image.network(
                                ImageHelper.user(null),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 70),

              Text(
                user.nombre,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                "@${user.nickname}",
                style: TextStyle(color: color.outline),
              ),

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
                  color: color.surfaceContainerLowest,
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
                    _stat((user.seguidores?.length ?? 0).toString(), "Seguidores", parkRed),
                    _stat(user.postsCount.toString(), "Posts", color.tertiary),
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
                      esMiPerfil
                          ? "Mis Mascotas"
                          : "Mascotas de ${user.nombre}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (esMiPerfil)
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, "/form-mascota")
                          .then((_) => _refrescarDatos(true, user.firebaseUid));
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
                  ? Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("¡Aún no hay mascotas registradas!"),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: user.mascotas.length,
                      itemBuilder: (context, index) {
                        final mascota = user.mascotas[index];
                        final bool esFavorita =
                            userProvider.usuario?.mascotasFavoritas.any(
                              (m) => m.id == mascota.id,
                            ) ??
                            false;
                        return MascotaCard(
                          mascota: mascota,
                          mostrarFavorito: !esMiPerfil,
                          esFavorito: esFavorita,
                          onTapFavorito: () =>
                              userProvider.alternarMascotaFavorita(mascota.id!),
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
        title: Text("Cerrar sesión"),
        content: Text("¿Seguro que quieres salir?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCELAR", style: TextStyle(color: color.primary)),
          ),
          TextButton(
            onPressed: () async {
              // Cerramos sesión en Firebase
              await FirebaseAuth.instance.signOut();
              // Se limpia el Provider
              context.read<UsuarioProvider>().limpiarUsuario();
              // Volvemos al login
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/login",
                (route) => false,
              );
            },
            child: Text(
              "CERRAR SESIÓN",
              style: TextStyle(color: color.secondary),
            ),
          ),
        ],
      ),
    );
  }

  void _verImagenAmpliada(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                clipBehavior: Clip.none,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.network(
                    ImageHelper.user(null),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
