import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../api/model/mascota_model.dart';
import '../utils/image_helper.dart';

class MascotaCard extends StatefulWidget {
  final Mascota mascota;
  final bool mostrarFavorito;
  final bool esFavorito;
  final VoidCallback onTapFavorito;

  const MascotaCard({
    super.key,
    required this.mascota,
    this.mostrarFavorito = false,
    this.esFavorito = false, // Este dato viene del Provider en PerfilScreen
    required this.onTapFavorito, // Esta función se ejecuta en el Provider
  });

  @override
  State<MascotaCard> createState() => _MascotaCardState();
}

class _MascotaCardState extends State<MascotaCard> {

  @override
  Widget build(BuildContext context) {
    final pawBlue = Theme.of(context).colorScheme.primary;
    final parkRed = Theme.of(context).colorScheme.secondary;
    final color = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: InkWell( // Detecta el toque y da feedback visual
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Navegamos al detalle pasando el objeto mascota como argumento
          Navigator.pushNamed(
            context,
            '/perfil-mascota',
            arguments: widget.mascota,
          );
        },
        child: Column(
          children: [
            // Parte superior (info e imagen)
            Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen real con corazón (en realidad la lógica del corazón solo es necesaria en el Feed)
                  Stack(
                    children: [
                      Hero(
                        tag: 'foto_${widget.mascota.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Builder(builder: (context) {
                            final String ruta = ImageHelper.pet(widget.mascota.fotoPerfilMascota);
                            if (ImageHelper.isAsset(ruta)) {
                              return Image.asset(ruta, width: 95, height: 95, fit: BoxFit.cover);
                            } else {
                              return Image.network(
                                ruta,
                                width: 95,
                                height: 95,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Shimmer.fromColors(
                                      baseColor: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
                                      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
                                      child: Container(width: 95, height: 95, color: Colors.white)
                                  );
                                },
                                errorBuilder: (_, __, ___) => Image.asset(ImageHelper.assetDefaultPet, width: 95, height: 95),
                              );
                            }
                          }),
                        ),
                      ),

                      // CORAZÓN DE FAVORITO SINCRONIZADO CON EL PROVIDER
                      if (widget.mostrarFavorito)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: widget.onTapFavorito,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Icon(
                                widget.esFavorito ? Icons.star : Icons.star_border, color: Colors.amber, size: 18
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 15),
        
                  // Textos dinámicos formateados
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.mascota.nombre,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color.onSurface)),
                            Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                          ],
                        ),
                        // Formateo de RAZA (EJ: PASTOR_ALEMAN -> Pastor Aleman)
                        Text(
                          widget.mascota.raza
                              .replaceAll('_', ' ')
                              .split(' ')
                              .where((word) => word.isNotEmpty)
                              .map((word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
                              .join(' '),
                          style: TextStyle(color: color.outline, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 12, color: color.outline),
                            SizedBox(width: 5),
                            Text("${widget.mascota.edad} años", style: TextStyle(color: color.outline, fontSize: 13)),
                          ],
                        ),
                        SizedBox(height: 10),
        
                        // Tag del comportamiento
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: widget.mascota.comportamientos.map((tag) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Mascota.obtenerColorTag(tag),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                // Formateamos cada tag individualmente
                                tag[0].toUpperCase() + tag.substring(1).toLowerCase(),
                                style: TextStyle(color: color.onPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        
            // // Barra inferior (estadísticas)
            // Container(
            //   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            //   decoration: BoxDecoration(
            //     color: color.onPrimary,
            //     borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            //     border: Border(top: BorderSide(color: Colors.grey[200]!)),
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceAround,
            //     children: [
            //       Row(
            //         children: [
            //           Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF2D3142)),
            //           SizedBox(width: 5),
            //           Text("Últimos parques", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            //         ],
            //       ),
            //       Container(width: 1, height: 15, color: Colors.grey[300]),
            //       Row(
            //         children: [
            //           Icon(Icons.favorite_border, size: 14, color: Color(0xFF2D3142)),
            //           SizedBox(width: 5),
            //           Text("Amigos (0)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}