class Post {
  final int id;
  final String rutaImagen;
  final String? descripcion;
  final DateTime fechaCreacion;

  final String autorNombre;
  final String autorUid;

  final List<String> mascotasNombres;

  /// 🔥 UI state (solo frontend)
  int likes;
  bool liked;

  Post({
    required this.id,
    required this.rutaImagen,
    this.descripcion,
    required this.fechaCreacion,
    required this.autorNombre,
    required this.autorUid,
    required this.mascotasNombres,
    this.likes = 0,
    this.liked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      rutaImagen: json['rutaImagen'],
      descripcion: json['descripcion'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      autorNombre: json['autorNombre'],
      autorUid: json['autorUid'],
      mascotasNombres: List<String>.from(json['mascotasNombres'] ?? []),

      /// 🔥 de momento mockeamos likes (hasta que lo tengas en backend)
      likes: 0,
      liked: false,
    );
  }
}