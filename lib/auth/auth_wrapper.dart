import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart';

import '../providers/usuario_provider.dart';
import '../screens/login/login_screen.dart';
import '../screens/perfil/perfil_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null){
      // Disparamos la carga solo si el usuario existe y no se ha cargado ya
      // Usamos microtask para no interrumpir el ciclo de construcción de Flutter

      // Si intentamos usar 'context' en una pantalla que ya no existe, la app lanzaría un error
      Future.microtask(() {
        if (context.mounted) { // mounted asegura que el usuario no haya cerrado la pantalla mientras esperábamos al servidor
          // Si intentamos usar 'context' en una pantalla que ya no existe, la app lanzaría un error
          context.read<UsuarioProvider>().cargarUsuario(user.uid);
        }
      });
      return PerfilScreen();
    }
    else{
      return LoginScreen();
    }
  }
}
