import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
class SkeletonSearch extends StatelessWidget {
  const SkeletonSearch({super.key});

  @override
  Widget build(BuildContext context) {
    // Detectamos si el sistema está en modo oscuro
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // CONFIGURACIÓN DE COLORES ADAPTATIVOS
    // En modo oscuro usamos grises muy profundos para no deslumbrar
    final Color baseColor = isDarkMode
        ? Colors.grey[850]!
        : Colors.grey[300]!;

    final Color highlightColor = isDarkMode
        ? Colors.grey[700]!
        : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: Duration(milliseconds: 1500), // Velocidad del brillo
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // 1. Círculo del Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
            ),
            SizedBox(width: 16),

            // 2. Columna con las líneas de texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Línea del Nombre (más ancha)
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 8),

                  // Línea del Nickname/Localidad (más corta)
                  Container(
                    width: 150,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}