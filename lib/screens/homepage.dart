import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORT WIDGETS ---
// import 'package:sportspace_app/widgets/sport_appbar.dart'; // HAPUS INI KARENA KITA BUAT LANGSUNG
import 'package:sportspace_app/widgets/navbar.dart';
import 'package:sportspace_app/widgets/smooth_indexed_stack.dart'; 

// --- IMPORT SCREENS & MODELS ---
import 'booking_detail.dart';
import 'my_bookings.dart';
import 'package:sportspace_app/screens/venue_form.dart';
import 'package:sportspace_app/screens/venue_list.dart';
import 'package:sportspace_app/models/lapangan.dart';
import 'package:sportspace_app/screens/profile/profile_page.dart';
import 'package:sportspace_app/screens/matchmaking/matchmaking_list_page.dart';
import 'package:sportspace_app/review/screens/my_reviews_page.dart';
import 'package:sportspace_app/review/screens/venue_reviews_page.dart';

const String kBaseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // --- Search & Filter State ---
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = "";
  String? _selectedLocation;
  final List<String> _locations = [
    'Jakarta Selatan', 'Jakarta Pusat', 'Jakarta Barat', 
    'Jakarta Timur', 'Jakarta Utara'
  ];

  late Future<List<Lapangan>> _lapanganFuture;

  // === COLOR PALETTE (Navy & Orange Theme) ===
  static const Color primaryNavy = Color(0xFF0D2C3E);
  static const Color softOrange = Color(0xFFFF9F45);
  static const Color backgroundWhite = Colors.white;
  static const Color textGrey = Color(0xFF64748B);
  static const Color lightGreyFill = Color(0xFFF1F5F9); 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = context.read<CookieRequest>();
    _lapanganFuture = fetchLapangans(request);
  }

  Future<List<Lapangan>> fetchLapangans(CookieRequest request) async {
    final response = await request.get('$kBaseUrl/home/api/lapangan/');
    List<Lapangan> listLapangan = [];
    for (var d in response) {
      if (d != null) listLapangan.add(Lapangan.fromJson(d));
    }
    return listLapangan;
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

  // ============================================================
  // 1. KONTEN TAB HOME (PUNYA SCAFFOLD SENDIRI)
  // ============================================================
  Widget _buildHomeTab() {
    return Scaffold(
      backgroundColor: backgroundWhite,
      
      // --- APP BAR MODERN (LANGSUNG DI SINI) ---
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparan karena pakai Gradient
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false, // Matikan tombol back otomatis
        
        // Background Gradient (Navy -> Orange)
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [softOrange, primaryNavy], 
            ),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
            ]
          ),
        ),

        // Judul & Logo
        title: Row(
          children: [
            // Logo Image (Pastikan asset ada, jika tidak pakai Icon fallback)
            Image.asset(
              'assets/images/logosportspace.png', // Ganti path sesuai asset Anda
              height: 32,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.sports_tennis, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              "SportSpace",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700, // Bold
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),

        // Aksi Kanan (Notifikasi)
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8), // Padding kanan
        ],
      ),
      // --- END APP BAR ---

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const VenueFormPage()));
        },
        backgroundColor: softOrange, 
        tooltip: 'Add Venue',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      
      body: _buildHomeBodyContent(),
    );
  }

  // ============================================================
  // 2. ISI KONTEN HOME (Search + List Lapangan)
  // ============================================================
  Widget _buildHomeBodyContent() {
    return FutureBuilder<List<Lapangan>>(
      future: _lapanganFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: softOrange));
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: GoogleFonts.poppins()));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Tidak ada data lapangan", style: GoogleFonts.poppins()));
        }

        final allCourtsRaw = snapshot.data!;
        List<Lapangan> recommendedCourts = allCourtsRaw.where((l) => l.isFeatured).toList();
        if (recommendedCourts.isEmpty && allCourtsRaw.isNotEmpty) {
          recommendedCourts = allCourtsRaw.take(5).toList();
        }

        final filteredCourts = allCourtsRaw.where((court) {
          final nameMatches = court.nama.toLowerCase().contains(_searchKeyword.toLowerCase());
          final locationMatches = _selectedLocation == null || court.alamat.toLowerCase().contains(_selectedLocation!.toLowerCase());
          return nameMatches && locationMatches;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchSection(),
              const SizedBox(height: 20),

              if (recommendedCourts.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("Recommended Courts", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 210, 
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 16, bottom: 10), 
                    itemCount: recommendedCourts.length,
                    itemBuilder: (context, index) {
                      return RecommendedCard(lapangan: recommendedCourts[index]);
                    },
                  ),
                ),
              ],

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("All Courts", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const VenueListPage(isMyVenue: false)));
                      },
                      child: Text("See All", style: GoogleFonts.poppins(color: softOrange, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              if (filteredCourts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("No courts found matching your search.", style: GoogleFonts.poppins(color: textGrey)),
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
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // 3. BUILD UTAMA (PARENT SCAFFOLD)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildHomeTab(), 
      LazyLoadPage(index: 1, currentIndex: _selectedIndex, child: const MyBookingsPage()),
      LazyLoadPage(index: 2, currentIndex: _selectedIndex, child: const MatchmakingListPage()),
      LazyLoadPage(index: 3, currentIndex: _selectedIndex, child: const MyReviewsPage()),
      LazyLoadPage(index: 4, currentIndex: _selectedIndex, child: const ProfilePage()),
    ];

    return Scaffold(
      backgroundColor: backgroundWhite,
      body: SmoothIndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: SportSpaceNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // ============================================================
  // 4. HELPER WIDGETS
  // ============================================================
  
  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Book Padel Courts\nNear You",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: primaryNavy,
              height: 1.2
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            style: GoogleFonts.poppins(color: primaryNavy),
            decoration: InputDecoration(
              hintText: "Search Courts..",
              hintStyle: GoogleFonts.poppins(color: textGrey),
              prefixIcon: const Icon(Icons.search, color: primaryNavy),
              filled: true,
              fillColor: lightGreyFill,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(16),
                 borderSide: const BorderSide(color: softOrange, width: 1.5)
              )
            ),
            onSubmitted: (_) => _performSearch(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: lightGreyFill,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text("Pilih Lokasi", style: GoogleFonts.poppins(color: textGrey)),
                      value: _selectedLocation,
                      icon: const Icon(Icons.keyboard_arrow_down, color: primaryNavy),
                      dropdownColor: Colors.white,
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text("Semua Lokasi", style: GoogleFonts.poppins(color: primaryNavy)),
                        ),
                        ..._locations.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: GoogleFonts.poppins(color: primaryNavy)),
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
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: Text(
                    "Search",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- HELPER FUNCTIONS & CLASSES ---

ImageProvider getImageProvider(String? url) {
  if (url == null || url.isEmpty || url == "null") {
    return const AssetImage("assets/images/logosportspace.png"); 
  }
  if (url.startsWith('http')) {
    String encodedUrl = Uri.encodeComponent(url);
    return NetworkImage("$kBaseUrl/home/proxy-image/?url=$encodedUrl");
  }
  return NetworkImage("$kBaseUrl$url");
}

class LazyLoadPage extends StatefulWidget {
  final Widget child;
  final int index;
  final int currentIndex;

  const LazyLoadPage({super.key, required this.child, required this.index, required this.currentIndex});

  @override
  State<LazyLoadPage> createState() => _LazyLoadPageState();
}

class _LazyLoadPageState extends State<LazyLoadPage> {
  bool _hasBeenLoaded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.currentIndex == widget.index) {
      _hasBeenLoaded = true;
    }
    return _hasBeenLoaded ? widget.child : const SizedBox();
  }
}

// === CARDS ===

class RecommendedCard extends StatelessWidget {
  final Lapangan lapangan;
  const RecommendedCard({super.key, required this.lapangan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: Image(
                image: getImageProvider(lapangan.thumbnail),
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) => Container(color: const Color(0xFFF1F5F9), child: const Icon(Icons.broken_image, color: Colors.grey)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lapangan.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(color: _HomePageState.primaryNavy, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  lapangan.alamat.split(',')[0],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(color: _HomePageState.textGrey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: _HomePageState.softOrange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "${lapangan.rating}",
                      style: GoogleFonts.poppins(color: _HomePageState.primaryNavy, fontSize: 12, fontWeight: FontWeight.bold),
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

class AllCourtCard extends StatelessWidget {
  final Lapangan lapangan;
  const AllCourtCard({super.key, required this.lapangan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image(
              image: getImageProvider(lapangan.thumbnail),
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (ctx, _, __) => Container(width: 90, height: 90, color: const Color(0xFFF1F5F9), child: const Icon(Icons.broken_image, color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lapangan.nama,
                  style: GoogleFonts.poppins(color: _HomePageState.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                Text(
                  lapangan.alamat.split(',')[0],
                  style: GoogleFonts.poppins(color: _HomePageState.textGrey, fontSize: 13),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: _HomePageState.softOrange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "${lapangan.rating}",
                      style: GoogleFonts.poppins(color: _HomePageState.textGrey, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => VenueReviewsPage(venueId: lapangan.pk, venueName: lapangan.nama)));
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _HomePageState.primaryNavy,
                            side: const BorderSide(color: _HomePageState.primaryNavy),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text("Review", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => BookingDetailPage(lapanganPk: lapangan.pk, nama: lapangan.nama, alamat: lapangan.alamat, imageUrl: lapangan.thumbnail)));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _HomePageState.softOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.zero,
                            elevation: 0,
                          ),
                          child: Text("Book", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
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