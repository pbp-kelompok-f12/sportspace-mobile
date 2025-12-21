class Lapangan {
  final int pk;
  final String nama;
  final String alamat;
  final double rating;
  final String thumbnail;
  final bool isFeatured;

  Lapangan({
    required this.pk,
    required this.nama,
    required this.alamat,
    required this.rating,
    required this.thumbnail,
    required this.isFeatured,
  });

  factory Lapangan.fromJson(Map<String, dynamic> json) {
    final fields = json['fields'];
    return Lapangan(
      pk: json['pk'],
      nama: fields['nama'] ?? "Tanpa Nama",
      alamat: fields['alamat'] ?? "Alamat tidak tersedia",
      rating: fields['rating'] != null
          ? (fields['rating'] as num).toDouble()
          : 0.0,
      thumbnail: fields['thumbnail_url'] ?? "",
      isFeatured: fields['is_featured'] ?? false,
    );
  }
}