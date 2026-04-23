import 'package:flutter/material.dart';

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
        if (index == currentIndex) return;

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
            Navigator.pushReplacementNamed(context, "/perfil");
            break;
        }
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.map), label: "Mapa"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Feed"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Quedadas"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
      ],
    );
  }
}