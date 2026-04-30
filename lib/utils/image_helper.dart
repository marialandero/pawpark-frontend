String getImageUrl(String? path) {
  const baseUrl = "http://10.0.2.2:8081/uploads/";

  if (path == null || path.isEmpty) {
    return "${baseUrl}person_default.png";
  }

  if (path.startsWith("http")) {
    return path;
  }

  return baseUrl + path;
}