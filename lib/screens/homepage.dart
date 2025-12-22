import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORT WIDGETS ---
import 'package:sportspace_app/widgets/navbar.dart';
import 'package:sportspace_app/widgets/smooth_indexed_stack.dart'; 

// --- IMPORT SCREENS & MODELS ---
import 'booking_detail.dart';
import 'my_bookings.dart';
import 'package:sportspace_app/screens/venue_form.dart';
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
  int _currentPage = 1;
  final int _itemsPerPage = 20;

  final TextEditingController _searchController = TextEditingController();
  late TextEditingController _pageJumpController;
  
  String _searchKeyword = "";
  String? _selectedLocation;
  final List<String> _locations = [
    'Jakarta Selatan', 'Jakarta Pusat', 'Jakarta Barat', 
    'Jakarta Timur', 'Jakarta Utara'
  ];

  late Future<List<Lapangan>> _lapanganFuture;

  static const Color primaryNavy = Color(0xFF0D2C3E);
  static const Color softOrange = Color(0xFFFF9F45);
  static const Color backgroundWhite = Colors.white;
  static const Color textGrey = Color(0xFF64748B);
  static const Color lightGreyFill = Color(0xFFF1F5F9); 

  @override
  void initState() {
    super.initState();
    _pageJumpController = TextEditingController(text: _currentPage.toString());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = context.read<CookieRequest>();
    _lapanganFuture = fetchLapangans(request);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageJumpController.dispose();
    super.dispose();
  }

  Future<List<Lapangan>> fetchLapangans(CookieRequest request) async {
    final response = await request.get('$kBaseUrl/home/api/lapangan/');
    List<Lapangan> listLapangan = [];
    for (var d in response) {
      if (d != null) listLapangan.add(Lapangan.fromJson(d));
    }
    return listLapangan;
  }

  void _updatePage(int newPage) {
    setState(() {
      _currentPage = newPage;
      _pageJumpController.text = newPage.toString();
    });
  }

  void _performSearch() {
    setState(() {
      _searchKeyword = _searchController.text.trim();
      _currentPage = 1;
      _pageJumpController.text = "1";
    });
  }

  Widget _buildHomeTab() {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [softOrange, primaryNavy], 
            ),
          ),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                'assets/images/image.png',
                height: 32, width: 32, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.sports_tennis, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text("SportSpace", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_home_add_venue",
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VenueFormPage())),
        backgroundColor: softOrange, 
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildHomeBodyContent(),
    );
  }

  Widget _buildHomeBodyContent() {
    return FutureBuilder<List<Lapangan>>(
      future: _lapanganFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: softOrange));
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final allCourtsRaw = snapshot.data ?? [];
        
        // Static Recommendations (Not filtered)
        List<Lapangan> recommendedCourts = allCourtsRaw.where((l) => l.isFeatured).toList();
        if (recommendedCourts.isEmpty && allCourtsRaw.isNotEmpty) {
          recommendedCourts = allCourtsRaw.take(5).toList();
        }

        // Search & Location Filter Logic for All Venues
        final filteredCourts = allCourtsRaw.where((court) {
          final nameMatches = court.nama.toLowerCase().contains(_searchKeyword.toLowerCase());
          final locationMatches = _selectedLocation == null || court.alamat.toLowerCase().contains(_selectedLocation!.toLowerCase());
          return nameMatches && locationMatches;
        }).toList();

        int totalPages = (filteredCourts.length / _itemsPerPage).ceil();
        if (totalPages == 0) totalPages = 1;
        final startIndex = (_currentPage - 1) * _itemsPerPage;
        final paginatedCourts = filteredCourts.skip(startIndex).take(_itemsPerPage).toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildBanner(),
              const SizedBox(height: 24),

              // 1. RECOMMENDATIONS (Scroll Horizontal)
              if (recommendedCourts.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("Top Recommendations", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 240, 
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 16),
                    itemCount: recommendedCourts.length,
                    itemBuilder: (context, index) => RecommendedCard(lapangan: recommendedCourts[index]),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 2. DISCOVER & SEARCH SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("Discover All Venues", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)),
              ),
              const SizedBox(height: 12),
              _buildSearchSection(),
              const SizedBox(height: 24),

              // 3. ALL COURTS LIST
              if (paginatedCourts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text("No venues found.")),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(children: paginatedCourts.map((l) => AllCourtCard(lapangan: l)).toList()),
                ),
                _buildDynamicPaginator(totalPages),
              ],
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.white, 
      child: Image.asset("assets/images/banner.png", fit: BoxFit.contain, alignment: Alignment.center),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: lightGreyFill, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search venue name...",
              prefixIcon: const Icon(Icons.search, color: primaryNavy),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text("Pilih Lokasi", style: GoogleFonts.poppins(color: textGrey)),
                      value: _selectedLocation,
                      icon: const Icon(Icons.keyboard_arrow_down, color: primaryNavy),
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
                          _currentPage = 1;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryNavy,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Icon(Icons.search, color: Colors.white),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDynamicPaginator(int totalPages) {
  if (totalPages <= 1) return const SizedBox.shrink();
  List<Widget> pageButtons = [];
  
  // Tombol Panah Kiri (Icons.chevron_left)
  pageButtons.add(_buildNavButton(
    Icons.chevron_left, 
    _currentPage > 1 ? () => _updatePage(_currentPage - 1) : null
  ));
  
  if (totalPages <= 5) {
    for (int i = 1; i <= totalPages; i++) pageButtons.add(_buildPageSquare(i));
  } else {
    if (_currentPage <= 3) {
      for (int i = 1; i <= 4; i++) pageButtons.add(_buildPageSquare(i));
      pageButtons.add(_buildPageSquare(totalPages, isEllipsis: true));
    } else if (_currentPage >= totalPages - 2) {
      pageButtons.add(_buildPageSquare(1, isEllipsis: true));
      for (int i = totalPages - 3; i <= totalPages; i++) pageButtons.add(_buildPageSquare(i));
    } else {
      pageButtons.add(_buildPageSquare(1, isEllipsis: true));
      pageButtons.add(_buildPageSquare(_currentPage - 1));
      pageButtons.add(_buildPageSquare(_currentPage));
      pageButtons.add(_buildPageSquare(_currentPage + 1));
      pageButtons.add(_buildPageSquare(totalPages, isEllipsis: true));
    }
  }

  // Tombol Panah Kanan (Icons.chevron_right)
  pageButtons.add(_buildNavButton(
    Icons.chevron_right, 
    _currentPage < totalPages ? () => _updatePage(_currentPage + 1) : null
  ));

  return Column(
    children: [
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: pageButtons),
      // ... (sisanya tetap sama)
    ],
  );
}
  Widget _buildPageSquare(int pageNum, {bool isEllipsis = false}) {
    bool isSel = _currentPage == pageNum && !isEllipsis;
    return GestureDetector(
      onTap: () => _updatePage(pageNum),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 38, height: 38,
        decoration: BoxDecoration(color: isSel ? softOrange : Colors.transparent, borderRadius: BorderRadius.circular(10), border: Border.all(color: isSel ? softOrange : lightGreyFill)),
        alignment: Alignment.center,
        child: Text(isEllipsis && _currentPage != pageNum ? "..." : "$pageNum", style: TextStyle(color: isSel ? Colors.white : primaryNavy, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback? onTap) {
  return IconButton(
    onPressed: onTap,
    icon: Icon(
      icon,
      size: 24, // Ukuran icon yang standar
      color: onTap == null ? Colors.grey[300] : primaryNavy,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      body: SmoothIndexedStack(index: _selectedIndex, children: [
        _buildHomeTab(), 
        LazyLoadPage(index: 1, currentIndex: _selectedIndex, child: const MyBookingsPage()),
        LazyLoadPage(index: 2, currentIndex: _selectedIndex, child: const MatchmakingListPage()),
        LazyLoadPage(index: 3, currentIndex: _selectedIndex, child: const MyReviewsPage()),
        LazyLoadPage(index: 4, currentIndex: _selectedIndex, child: const ProfilePage()),
      ]),
      bottomNavigationBar: SportSpaceNavBar(selectedIndex: _selectedIndex, onItemTapped: (i) => setState(() => _selectedIndex = i)),
    );
  }
}

class RecommendedCard extends StatelessWidget {
  final Lapangan lapangan;
  const RecommendedCard({super.key, required this.lapangan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170, 
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
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: SizedBox(
              height: 90,
              width: double.infinity,
              child: Image(
                image: getImageProvider(lapangan.thumbnail),
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) => Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lapangan.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: _HomePageState.primaryNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                // --- ICON LOCATION + ALAMAT ---
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color.fromARGB(255, 34, 34, 34), size: 12),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        lapangan.alamat.split(',')[0],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: _HomePageState.textGrey,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: _HomePageState.softOrange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "${lapangan.rating}",
                      style: GoogleFonts.poppins(
                        color: _HomePageState.primaryNavy,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => VenueReviewsPage(venueId: lapangan.pk, venueName: lapangan.nama, venueImageUrl: lapangan.thumbnail,)));
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _HomePageState.primaryNavy,
                            side: const BorderSide(color: _HomePageState.primaryNavy),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            "Review", 
                            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => BookingDetailPage(lapanganPk: lapangan.pk, nama: lapangan.nama, alamat: lapangan.alamat, imageUrl: lapangan.thumbnail)));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _HomePageState.softOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.zero,
                            elevation: 0,
                          ),
                          child: Text(
                            "Book", 
                            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image(
              image: getImageProvider(lapangan.thumbnail),
              width: 90, height: 90, fit: BoxFit.cover,
              errorBuilder: (ctx, _, __) => Container(width: 90, height: 90, color: const Color(0xFFF1F5F9), child: const Icon(Icons.broken_image, color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lapangan.nama, style: GoogleFonts.poppins(color: _HomePageState.primaryNavy, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                // --- ICON LOCATION + ALAMAT ---
                Row(
                  children: [
                    const Icon(Icons.location_on, color: _HomePageState.textGrey, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        lapangan.alamat.split(',')[0], 
                        style: GoogleFonts.poppins(color: _HomePageState.textGrey, fontSize: 13), 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: _HomePageState.softOrange, size: 14),
                    const SizedBox(width: 4),
                    Text("${lapangan.rating}", style: GoogleFonts.poppins(color: _HomePageState.textGrey, fontSize: 12, fontWeight: FontWeight.w600)),
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) => VenueReviewsPage(venueId: lapangan.pk, venueName: lapangan.nama, venueImageUrl: lapangan.thumbnail)));
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

// --- HELPER CLASSES ---

ImageProvider getImageProvider(String? url) {
  if (url == null || url.isEmpty || url == "null") {
    // Memberikan placeholder transparan agar errorBuilder yang bekerja
    return const NetworkImage("about:blank"); 
  }
  
  if (url.startsWith('http')) {
    final encodedUrl = Uri.encodeComponent(url);
    return NetworkImage("$kBaseUrl/home/proxy-image/?url=$encodedUrl");
  }
  
  return NetworkImage("$kBaseUrl$url");
}

class LazyLoadPage extends StatefulWidget {
  final Widget child; final int index; final int currentIndex;
  const LazyLoadPage({super.key, required this.child, required this.index, required this.currentIndex});
  @override State<LazyLoadPage> createState() => _LazyLoadPageState();
}

class _LazyLoadPageState extends State<LazyLoadPage> {
  bool _loaded = false;
  @override Widget build(BuildContext context) {
    if (widget.currentIndex == widget.index) _loaded = true;
    return _loaded ? widget.child : const SizedBox();
  }
}