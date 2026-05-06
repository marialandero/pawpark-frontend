class Post {
  final int id;
  final String rutaImagen;
  final String descripcion;
  final String autorNombre;
  final String autorUid;
  final List<String> mascotasNombres;
  final String? autorFotoPerfil;

  bool liked;
  int likes;

  Post({
    required this.id,
    required this.rutaImagen,
    required this.descripcion,
    required this.autorNombre,
    required this.autorUid,
    required this.mascotasNombres,
    this.liked = false,
    this.likes = 0,
    this.autorFotoPerfil,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"],
      rutaImagen: json["rutaImagen"] ?? "",
      descripcion: json["descripcion"] ?? "",
      autorNombre: json["autorNombre"] ?? "",
      autorUid: json["autorUid"] ?? "",
      autorFotoPerfil: json["autorFotoPerfil"],
      mascotasNombres: List<String>.from(json["mascotasNombres"] ?? []),

    );
  }
}