import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportspace_app/screens/homepage.dart'; // Import ini PENTING untuk ambil class Lapangan
import 'package:sportspace_app/models/lapangan.dart';

class VenueListPage extends StatefulWidget {
  final bool isMyVenue; // Pembeda halaman "Semua" atau "Punya Saya"

  const VenueListPage({super.key, this.isMyVenue = false});

  @override
  State<VenueListPage> createState() => _VenueListPageState();
}

class _VenueListPageState extends State<VenueListPage> {
  
  // --- LOGIC FETCH DATA ---
  Future<List<Lapangan>> fetchLapangans(CookieRequest request) async {
    // URL Endpoint Django
    
    String url = 'https://sean-marcello-sportspace.pbp.cs.ui.ac.id/home/api/lapangan/';

    // Jika nanti Anda punya endpoint khusus "Lapangan Saya", bisa pakai logika ini:
    // if (widget.isMyVenue) {
    //   url = 'http://10.0.2.2:8000/home/api/my-lapangan/';
    // }

    final response = await request.get(url);

    List<Lapangan> listLapangan = [];
    for (var d in response) {
      if (d != null) {
        listLapangan.add(Lapangan.fromJson(d));
      }
    }
    
    // (Opsional) Filter Manual di sisi Flutter jika belum ada endpoint 'my-lapangan'
    // if (widget.isMyVenue) {
    //    return listLapangan.where((l) => l.addedBy == request.jsonData['user_id']).toList();
    // }

    return listLapangan;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final Color darkBlue = const Color(0xFF0D2C3E);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isMyVenue ? 'My Venues' : 'All Venues',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder(
        future: fetchLapangans(request),
        builder: (context, AsyncSnapshot<List<Lapangan>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_tennis, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada data lapangan.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) {
                // Kita gunakan widget Card yang sama dengan Homepage
                return VenueListCard(lapangan: snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }
}

// --- WIDGET KARTU (Versi Mandiri untuk List Page) ---
class VenueListCard extends StatelessWidget {
  final Lapangan lapangan;

  const VenueListCard({super.key, required this.lapangan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Kiri
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              lapangan.thumbnail.isNotEmpty
                  ? lapangan.thumbnail
                  : "https://via.placeholder.com/150",
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (ctx, _, __) => Container(
                width: 100,
                height: 100,
                color: Colors.grey,
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info Kanan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lapangan.nama,
                  style: const TextStyle(
                    color: Color(0xFFFF9800),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  lapangan.alamat.split(',')[0],
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Rating: ${lapangan.rating}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 8),
                // Tombol Aksi
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            // Aksi Review
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF64B5F6),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 0,
                          ),
                          child: const Text("Review", style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            // Aksi Book
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7CB342),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            elevation: 0,
                          ),
                          child: const Text("Book", style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}