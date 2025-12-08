import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'booking_detail.dart';
import 'my_bookings.dart';
import 'package:sportspace_app/screens/venue_form.dart';
import 'package:sportspace_app/screens/venue_list.dart';
import 'package:sportspace_app/models/lapangan.dart';
import 'package:sportspace_app/screens/matchmaking_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  // Konstanta untuk tab index
  static const int _tabHome = 0;
  static const int _tabBookings = 1;
  static const int _tabMatch = 2; // Index untuk tab 'Match'
  static const int _tabReviews = 3; // Index untuk tab 'Reviews'
  static const int _tabProfile = 4; // Index untuk tab 'Profile'

  // State untuk Search dan Filter
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = "";
  String? _selectedLocation;

  final List<String> _locations = const [
    'Jakarta Selatan',
    'Jakarta Pusat',
    'Jakarta Barat',
    'Jakarta Timur',
    'Jakarta Utara',
  ];

  // --- PERBAIKAN 1: IP Address ---
  // Gunakan 10.0.2.2 untuk Android Emulator
  // Ganti ke "http://10.0.2.2:8000" jika menggunakan Android Emulator
  final String baseUrl = "http://127.0.0.1:8000";

  late Future<List<Lapangan>> _lapanganFuture;

  @override
  void initState() {
    super.initState();
    // Inisialisasi Future di didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Panggil fetchLapangans di sini setelah context tersedia
    final request = context.read<CookieRequest>();
    _lapanganFuture = fetchLapangans(request);
  }

  Future<List<Lapangan>> fetchLapangans(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/home/api/lapangan/');
      List<Lapangan> listLapangan = [];
      if (response is List) {
        for (var d in response) {
          if (d != null && d is Map<String, dynamic>) {
            listLapangan.add(Lapangan.fromJson(d));
          }
        }
      }
      return listLapangan;
    } catch (e) {
      // Menangani error koneksi
      debugPrint("Error fetching lapangans: $e");
      // Melemparkan error agar FutureBuilder dapat menampilkannya
      throw Exception("Gagal memuat data lapangan: Pastikan server berjalan dan IP benar ($baseUrl).");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _performSearch() {
    setState(() {
      _searchKeyword = _searchController.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF0D2C3E);
    const Color bottomNavBlue = Color(0xFF90CAF9);

    // --- PERBAIKAN 2: Logika Navigasi ---
    Widget bodyContent;

    switch (_selectedIndex) {
      case _tabHome:
        // ISI HALAMAN HOME
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

            // Logic Recommended
            List<Lapangan> recommendedCourts = allCourtsRaw
                .where((l) => l.isFeatured)
                .toList();
            if (recommendedCourts.isEmpty && allCourtsRaw.isNotEmpty) {
              recommendedCourts = allCourtsRaw.take(5).toList();
            }

            // Logic Filter
            final filteredCourts = allCourtsRaw.where((court) {
              final nameMatches = court.nama.toLowerCase().contains(
                    _searchKeyword.toLowerCase(),
                  );
              final locationMatches = _selectedLocation == null ||
                  court.alamat.toLowerCase().contains(
                        _selectedLocation!.toLowerCase(),
                      );
              return nameMatches && locationMatches;
            }).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchSection(darkBlue),
                  const SizedBox(height: 20),
                  
                  // Recommended Section
                  if (recommendedCourts.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Recommended Courts",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
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
                            lapangan: recommendedCourts[index],
                          );
                        },
                      ),
                    ),
                  ],

                  // All Courts Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "All Courts",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const VenueListPage(isMyVenue: false),
                              ),
                            );
                          },
                          child: const Text("See All"),
                        ),
                      ],
                    ),
                  ),

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
        break;
      case _tabBookings:
        // ISI HALAMAN BOOKINGS
        bodyContent = const MyBookingsPage();
        break;
      case _tabMatch:
        // ISI HALAMAN MATCHMAKING
        bodyContent = const MatchmakingPage();
        break;
      case _tabReviews:
        // ISI HALAMAN REVIEWS
        bodyContent = const Center(child: Text("Halaman Reviews Coming Soon..."));
        break;
      case _tabProfile:
        // ISI HALAMAN PROFILE
        bodyContent = const Center(child: Text("Halaman Profile Coming Soon..."));
        break;
      default:
        bodyContent = const Center(child: Text("Halaman Tidak Ditemukan"));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/images/logosportspace.png'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VenueFormPage()),
          );
        },
        backgroundColor: const Color(0xFF7CB342),
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Venue',
      ),
      
      // Di sini kita panggil variabel bodyContent yang sudah di-set logic di atas
      body: bodyContent, 

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: bottomNavBlue,
          border: Border(
            top: BorderSide(color: Colors.black12, width: 0.5),
          ),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_tennis),
              label: 'Match', // Tab Matchmaking
            ),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Reviews'),
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
        Container(height: 100, width: double.infinity, color: darkBlue),
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
                onSubmitted: (_) => _performSearch(),
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
                      onPressed: _performSearch,
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

// --- PERBAIKAN 3: PROXY URL IP ---
// Pastikan ini juga menggunakan 10.0.2.2 jika menggunakan Android Emulator
String getProxyUrl(String originalUrl) {
  if (originalUrl.isEmpty) {
    return "https://via.placeholder.com/150";
  }
  
  String encodedUrl = Uri.encodeComponent(originalUrl);

  // Ganti ke "http://10.0.2.2:8000..." jika menggunakan Android Emulator
  return "http://127.0.0.1:8000/home/proxy-image/?url=$encodedUrl";
}

// --- WIDGET CARD: RECOMMENDED ---
class RecommendedCard extends StatelessWidget {
  final Lapangan lapangan;

  const RecommendedCard({super.key, required this.lapangan});

  @override
  Widget build(BuildContext context) {
    final String imageUrl = getProxyUrl(lapangan.thumbnail);

    return InkWell(
      onTap: () {
        // Navigasi ke detail lapangan jika diperlukan
      },
      child: Container(
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
                bottom: Radius.circular(20),
              ),
              child: Container(
                height: 120,
                width: double.infinity,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, _, __) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
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
    final String imageUrl = getProxyUrl(lapangan.thumbnail);

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
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (ctx, _, __) => Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
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
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF64B5F6),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
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
                              // Navigasi ke BookingDetailPage
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
                          child: const Text("Book", style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}