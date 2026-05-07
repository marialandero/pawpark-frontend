import 'package:flutter/material.dart';
import 'package:pawpark_frontend/providers/usuario_provider.dart';
import 'package:provider/provider.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;

  const BottomBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      onTap: (index) {
        if (index == currentIndex) {
          if (index == 3) {
            context.read<UsuarioProvider>().recargarUsuario();
          }
          return;
        }

          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, "/map");
              break;
            case 1:
              Navigator.pushReplacementNamed(context, "/feed");
              break;
            case 2:
              Navigator.pushReplacementNamed(context, "/quedadas");
              break;
            case 3:
            // LLAMADA CLAVE: Antes de navegar, pedimos al provider que refresque los datos
            // Esto asegura que cuando cargue la pantalla de Perfil, el contador de posts ya sea el nuevo
              context.read<UsuarioProvider>().recargarUsuario();
              Navigator.pushReplacementNamed(context, "/perfil");
              break;
          }
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.map), label: "Mapa"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Muro"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Quedadas"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
      ],
    );
  }
}