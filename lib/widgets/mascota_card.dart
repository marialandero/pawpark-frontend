import 'package:flutter/material.dart';
import '../api/mascota_model.dart';
import '../utils/image_helper.dart';

class MascotaCard extends StatefulWidget {
  final Mascota mascota;
  final bool mostrarFavorito;

  const MascotaCard({super.key, required this.mascota, this.mostrarFavorito = false});

  @override
  State<MascotaCard> createState() => _MascotaCardState();
}

class _MascotaCardState extends State<MascotaCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final pawBlue = Theme.of(context).colorScheme.primary;
    final parkRed = Theme.of(context).colorScheme.secondary;
    final color = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.onPrimary,
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
                          child: Image.network(
                            ImageHelper.pet(widget.mascota.fotoPerfilMascota),
                            width: 95,
                            height: 95,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Image.network(
                                ImageHelper.pet(null),
                                width: 95,
                                height: 95,
                              );
                            },
                          )
                        ),
                      ),

                      // CORAZÓN DE FAVORITO (Sólo si es un perfil ajeno, no en el propio)
                      if (widget.mostrarFavorito)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isFavorite = !isFavorite; // Cambia de true a false y viceversa
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Color(0xffd51339), size: 18),
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