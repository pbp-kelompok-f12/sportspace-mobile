import 'package:flutter/material.dart';
import 'package:sportspace_app/models/lapangan.dart'; // Pastikan import model benar

class VenueCard extends StatelessWidget {
  final Lapangan venue;
  final VoidCallback? onTap;

  const VenueCard({
    super.key, 
    required this.venue, 
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    // Warna tema
    final Color darkBlue = const Color(0xFF0D2C3E);
    
    // URL Proxy untuk Android Emulator
    // Jika venue.thumbnail kosong, jangan panggil proxy
    String imageUrl = "";
    if (venue.thumbnail.isNotEmpty) {
      // Encode URL gambar asli agar karakter spesial tidak merusak link
      String encodedUrl = Uri.encodeComponent(venue.thumbnail);
      // Gunakan 10.0.2.2 untuk Android Emulator mengakses localhost Django
      imageUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id/home/proxy-image/?url=$encodedUrl";
      
      // Catatan: Jika url proxy di urls.py Anda tidak ada prefix 'home/', 
      // hapus '/home' di link di atas. Sesuaikan dengan urls.py Django Anda.
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Gambar Thumbnail via Proxy
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: SizedBox(
                  width: double.infinity,
                  height: 150, 
                  child: Image.network(
                    imageUrl, // Menggunakan URL Proxy
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Debugging print
                      print("Gagal muat proxy: $imageUrl");
                      print("Error: $error");
                      
                      return Container(
                        color: Colors.grey[300],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.broken_image, color: Colors.grey),
                            Text("No Image", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // 2. Informasi Text
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama & Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            venue.nama,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkBlue,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (venue.rating > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  "${venue.rating}",
                                  style: const TextStyle(
                                    color: Colors.white, 
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Alamat
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            venue.alamat,
                            style: TextStyle(color: Colors.grey[700], fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Badge "Featured"
                    if (venue.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF2196F3)),
                        ),
                        child: const Text(
                          "Featured Court",
                          style: TextStyle(
                            color: Color(0xFF2196F3),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}