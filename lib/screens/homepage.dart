import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../review/screens/venue_reviews_page.dart';
import '../review/screens/my_reviews_page.dart';
import 'booking_detail.dart';
import 'my_bookings.dart';

// --- 1. MODEL DATA ---
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const int _tabHome = 0;
  static const int _tabBookings = 1;
  static const int _tabMyReviews = 3;
  
  // State untuk Search dan Filter
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = "";
  String? _selectedLocation; // Null artinya "Pilih Lokasi" (Semua)

  final List<String> _locations = [
    'Jakarta Selatan',
    'Jakarta Pusat',
    'Jakarta Barat',
    'Jakarta Timur',
    'Jakarta Utara'
  ];

  // Base URL aplikasi web SportSpace (deployment PBP)
  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";

  // Cache data agar tidak reload terus saat ketik search
  late Future<List<Lapangan>> _lapanganFuture;

  @override
  void initState() {
    super.initState();
    // Kita panggil fetch di awal, nanti bisa di refresh jika perlu
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = context.read<CookieRequest>();
    _lapanganFuture = fetchLapangans(request);
  }

  // --- LOGIC FETCH DATA ---
  Future<List<Lapangan>> fetchLapangans(CookieRequest request) async {
    final response = await request.get('$baseUrl/home/api/lapangan/');
    List<Lapangan> listLapangan = [];
    for (var d in response) {
      if (d != null) {
        listLapangan.add(Lapangan.fromJson(d));
      }
    }
    return listLapangan;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fungsi untuk melakukan pencarian (dipanggil saat tombol Search ditekan)
  void _performSearch() {
    setState(() {
      _searchKeyword = _searchController.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Warna Desain
    final Color darkBlue = const Color(0xFF0D2C3E);
    final Color bottomNavBlue = const Color(0xFF90CAF9);

    Widget bodyContent;
    if (_selectedIndex == _tabHome) {
      bodyContent = FutureBuilder<List<Lapangan>>(
        future: _lapanganFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada data lapangan"));
          }

          final allCourtsRaw = snapshot.data!;

          // 1. Logic Recommended (Fallback ke 5 item pertama jika tidak ada yang featured)
          List<Lapangan> recommendedCourts =
              allCourtsRaw.where((l) => l.isFeatured).toList();
          if (recommendedCourts.isEmpty && allCourtsRaw.isNotEmpty) {
            recommendedCourts = allCourtsRaw.take(5).toList();
          }

          // 2. Logic Filter "All Courts" berdasarkan Search & Lokasi
          final filteredCourts = allCourtsRaw.where((court) {
            final nameMatches =
                court.nama.toLowerCase().contains(_searchKeyword.toLowerCase());
            final locationMatches = _selectedLocation == null ||
                court.alamat
                    .toLowerCase()
                    .contains(_selectedLocation!.toLowerCase());
            return nameMatches && locationMatches;
          }).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SEARCH SECTION (Sekarang Stateful)
                _buildSearchSection(darkBlue),

                const SizedBox(height: 20),

                // RECOMMENDED SECTION
                // Hanya muncul jika data recommended ada
                if (recommendedCourts.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Recommended Courts",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D2C3E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 16),
                      itemCount: recommendedCourts.length,
                      itemBuilder: (context, index) {
                        return RecommendedCard(
                            lapangan: recommendedCourts[index]);
                      },
                    ),
                  ),
                ],

                // ALL COURTS SECTION (Hasil Filter)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    "All Courts",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D2C3E),
                    ),
                  ),
                ),

                // Tampilkan pesan jika hasil pencarian kosong
                if (filteredCourts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "No courts found matching your search.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredCourts.length,
                    itemBuilder: (context, index) {
                      return AllCourtCard(lapangan: filteredCourts[index]);
                    },
                  ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      );
    } else if (_selectedIndex == _tabBookings) {
      bodyContent = const MyBookingsPage();
    } else if (_selectedIndex == _tabMyReviews) {
      bodyContent = const MyReviewsPage();
    }
    else {
      bodyContent = const Center(
        child: Text("Coming soon..."),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0), // Padding agar logo tidak terlalu mepet
          child: CircleAvatar(
            backgroundColor: Colors.white, // Warna background jika logo transparan
            // Ganti 'assets/images/logo_sportspace.png' dengan path/nama file logo Anda
            backgroundImage: const AssetImage('assets/images/logosportspace.png'),
          ),
        ),
        title: const Text(
          "SportSpace",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: bodyContent,
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bottomNavBlue,
          border: const Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: BottomNavigationBar(
          backgroundColor: bottomNavBlue,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          showUnselectedLabels: true,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Bookings'),
            BottomNavigationBarItem(icon: Icon(Icons.sports_tennis), label: 'Match'),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'My Reviews'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  // WIDGET SEARCH SECTION
  Widget _buildSearchSection(Color darkBlue) {
    return Stack(
      children: [
        Container(
          height: 100,
          width: double.infinity,
          color: darkBlue,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Book Padel Courts Near You",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              // Search Input dengan Controller
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search Courts..",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _performSearch(), // Search saat enter ditekan
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text("Pilih Lokasi"),
                          value: _selectedLocation,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          // Menambahkan opsi "Pilih Lokasi" untuk reset filter
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text("Pilih Lokasi"),
                            ),
                            ..._locations.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: const TextStyle(fontSize: 14)),
                              );
                            }),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedLocation = newValue;
                              // Jika ingin langsung search saat ganti lokasi, uncomment baris bawah:
                              // _performSearch(); 
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: _performSearch, // Panggil fungsi search
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C9DFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Search", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- WIDGET CARD: RECOMMENDED ---
class RecommendedCard extends StatelessWidget {
  final Lapangan lapangan;

  const RecommendedCard({super.key, required this.lapangan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(20)),
            child: Container(
              height: 120,
              width: double.infinity,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.network(
                lapangan.thumbnail.isNotEmpty
                    ? lapangan.thumbnail
                    : "https://via.placeholder.com/150",
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) => Container(
                  color: Colors.grey,
                  child: const Icon(Icons.broken_image, color: Colors.white),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lapangan.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFF9800),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lapangan.alamat.split(',')[0],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET CARD: ALL COURTS ---
class AllCourtCard extends StatelessWidget {
  final Lapangan lapangan;

  const AllCourtCard({super.key, required this.lapangan});

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
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Navigate to review page if available
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VenueReviewsPage(
                                  venueId: lapangan.pk,
                                  venueName: lapangan.nama,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF64B5F6),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Review",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingDetailPage(
                                  lapanganPk: lapangan.pk,
                                  nama: lapangan.nama,
                                  alamat: lapangan.alamat,
                                  imageUrl: lapangan.thumbnail,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7CB342),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Book",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
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