import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sportspace_app/models/booking_model.dart';

class ManageBookingsPage extends StatefulWidget {
  const ManageBookingsPage({super.key});

  @override
  State<ManageBookingsPage> createState() => _ManageBookingsPageState();
}

class _ManageBookingsPageState extends State<ManageBookingsPage> {
  // --- KONFIGURASI URL (UPDATED) ---
  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";

  // --- PALETTE WARNA ---
  final Color primaryNavy = const Color(0xFF0C2D57);
  final Color accentOrange = const Color(0xFFF97316);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textDark = const Color(0xFF1E293B);
  final Color textGrey = const Color(0xFF64748B);

  // --- STATE DATA ---
  bool _isLoading = true;
  List<Booking> _allBookings = [];
  List<Booking> _filteredBookings = [];
  List<String> _venueList = ['Semua Venue'];

  // --- STATE FILTER & SORT ---
  String _searchUserQuery = "";
  String _selectedVenue = "Semua Venue";
  DateTime? _selectedDate;
  
  // Opsi Sort
  String _sortOption = "default"; 
  // Values: default, date_asc, date_desc, id_asc, id_desc, venue_asc, venue_desc, user_asc, user_desc

  // --- STATE PAGINATION ---
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _fetchBookings(request);
  }

  // --- FETCH DATA ---
  Future<void> _fetchBookings(CookieRequest request) async {
    setState(() => _isLoading = true);
    try {
      // URL UPDATED: dashboard-admin
      final response = await request.get('$baseUrl/dashboard-admin/bookings/data/');
      List<dynamic> listData = response['bookings'];
      
      List<Booking> parsedData = listData.map((d) => Booking.fromJson(d)).toList();

      Set<String> venues = parsedData.map((b) => b.venueName).toSet();
      
      if (mounted) {
        setState(() {
          _allBookings = parsedData;
          _venueList = ['Semua Venue', ...venues];
          _searchUserQuery = ""; 
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- FILTER & SORT LOGIC (UPDATED) ---
  void _applyFilters() {
    List<Booking> temp = List.from(_allBookings);

    // 1. Filter Username
    if (_searchUserQuery.isNotEmpty) {
      temp = temp.where((b) {
        final username = b.username;
        return username.toLowerCase().contains(_searchUserQuery.toLowerCase());
      }).toList();
    }

    // 2. Filter Venue
    if (_selectedVenue != "Semua Venue") {
      temp = temp.where((b) => b.venueName == _selectedVenue).toList();
    }

    // 3. Filter Date
    if (_selectedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      temp = temp.where((b) => b.bookingDate == formattedDate).toList();
    }

// 4. Sorting
    switch (_sortOption) {
      case 'date_asc': 
        temp.sort((a, b) => a.bookingDate.compareTo(b.bookingDate)); break;
      case 'date_desc': 
        temp.sort((a, b) => b.bookingDate.compareTo(a.bookingDate)); break;
      
      // LOGIC ID ALPHANUMERIC
      // compareTo otomatis mengurutkan angka dulu, baru huruf kapital, baru huruf kecil
      case 'id_asc':
        temp.sort((a, b) => a.id.compareTo(b.id)); break;
      case 'id_desc':
        temp.sort((a, b) => b.id.compareTo(a.id)); break;

      case 'venue_asc':
        temp.sort((a, b) => a.venueName.toLowerCase().compareTo(b.venueName.toLowerCase())); break;
      case 'venue_desc':
        temp.sort((a, b) => b.venueName.toLowerCase().compareTo(a.venueName.toLowerCase())); break;

      case 'user_asc':
        temp.sort((a, b) => a.username.toLowerCase().compareTo(b.username.toLowerCase())); break;
      case 'user_desc':
        temp.sort((a, b) => b.username.toLowerCase().compareTo(a.username.toLowerCase())); break;
      
      case 'default':
      default:
        break;
    }
    setState(() {
      _filteredBookings = temp;
      _currentPage = 1; // Reset ke halaman 1
    });
  }

  // --- PAGINATION SLICING ---
  List<Booking> get _paginatedData {
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (endIndex > _filteredBookings.length) endIndex = _filteredBookings.length;
    if (startIndex >= _filteredBookings.length) return [];
    return _filteredBookings.sublist(startIndex, endIndex);
  }

  // --- DELETE LOGIC ---
  Future<void> _deleteBooking(String id, CookieRequest request) async {
    try {
      // URL UPDATED: dashboard-admin
      final response = await request.post('$baseUrl/dashboard-admin/bookings/delete/$id/', {'_method': 'DELETE'});
      if (response['success'] == true) {
        setState(() {
          _allBookings.removeWhere((b) => b.id == id);
          _applyFilters();
        });
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil dihapus")));
      }
    } catch (e) { /* Handle Error */ }
  }

  // --- MODAL VENUE ---
  void _showVenueFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        String modalSearchQuery = "";
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            List<String> filteredVenues = _venueList.where((venue) => 
              venue.toLowerCase().contains(modalSearchQuery.toLowerCase())
            ).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Pilih Venue", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (val) => setModalState(() => modalSearchQuery = val),
                    decoration: InputDecoration(
                      hintText: "Cari nama venue...",
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredVenues.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final venueName = filteredVenues[index];
                        final isSelected = venueName == _selectedVenue;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(venueName, style: GoogleFonts.inter(color: isSelected ? accentOrange : textDark, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          trailing: isSelected ? Icon(Icons.check_circle, color: accentOrange) : null,
                          onTap: () {
                            setState(() {
                              _selectedVenue = venueName;
                              _applyFilters();
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

// --- MODAL SORTING (FIXED OVERFLOW & LABEL) ---
  void _showSortOptions() {
    final Map<String, String> options = {
      'default': 'Default',
      'date_asc': 'Tanggal (Terdekat)',
      'date_desc': 'Tanggal (Terjauh)',
      // Ubah label agar tidak membingungkan
      'id_asc': 'ID (0-Z)', 
      'id_desc': 'ID (Z-0)',
      'venue_asc': 'Nama Venue (A-Z)',
      'venue_desc': 'Nama Venue (Z-A)',
      'user_asc': 'Nama User (A-Z)',
      'user_desc': 'Nama User (Z-A)',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Penting agar tidak overflow
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // Batasi tinggi modal max 70% layar agar rapi
        return DraggableScrollableSheet(
          initialChildSize: 0.5, // Muncul setengah layar
          minChildSize: 0.3,
          maxChildSize: 0.75, // Bisa ditarik sampai 75%
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Header (Garis kecil buat ditarik)
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  "Urutkan Berdasarkan",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryNavy
                  ),
                ),
                const SizedBox(height: 10),

                // List Options (Scrollable)
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      String key = options.keys.elementAt(index);
                      String label = options.values.elementAt(index);
                      bool isSelected = _sortOption == key;

                      return ListTile(
                        title: Text(
                          label,
                          style: GoogleFonts.inter(
                            color: isSelected ? accentOrange : textDark,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal
                          ),
                        ),
                        trailing: isSelected 
                            ? Icon(Icons.check_circle_rounded, color: accentOrange) 
                            : null,
                        onTap: () {
                          setState(() {
                            _sortOption = key;
                            _applyFilters();
                          });
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final paginatedData = _paginatedData;
    final totalPages = (_filteredBookings.length / _itemsPerPage).ceil();

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Kelola Booking", style: GoogleFonts.poppins(color: primaryNavy, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      // PENTING: Jangan bungkus Column ini dengan SingleChildScrollView
      // agar Expanded bekerja dan Pagination menempel di bawah.
      body: Column(
        children: [
          // === 1. TOP SECTION (SEARCH & FILTERS) ===
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                // Search User
                TextField(
                  onChanged: (val) {
                    _searchUserQuery = val;
                    _applyFilters();
                  },
                  decoration: InputDecoration(
                    hintText: "Cari User...",
                    prefixIcon: Icon(Icons.search_rounded, color: accentOrange),
                    filled: true,
                    fillColor: bgLight,
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Row Filter: Venue, Date, Sort
                Row(
                  children: [
                    // A. Tombol Filter Venue (Modal)
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: _showVenueFilterModal,
                        child: _buildFilterBox(
                          icon: Icons.stadium_rounded,
                          text: _selectedVenue,
                          isActive: _selectedVenue != "Semua Venue",
                          isDropdown: true
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // B. Tombol Date Picker
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030)
                          );
                          if(picked != null) {
                            setState(() { _selectedDate = picked; _applyFilters(); });
                          } else if (_selectedDate != null) {
                            setState(() { _selectedDate = null; _applyFilters(); });
                          }
                        },
                        child: _buildFilterBox(
                          icon: Icons.calendar_today_rounded,
                          text: _selectedDate == null ? "Tanggal" : DateFormat('dd/MM').format(_selectedDate!),
                          isActive: _selectedDate != null,
                          isDropdown: false
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // C. Tombol Sorting (New)
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: _showSortOptions,
                        child: _buildFilterBox(
                          icon: Icons.sort_rounded,
                          text: "Urutkan", // Text statis agar rapi, atau bisa _sortOption
                          isActive: _sortOption != "default",
                          isDropdown: true
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // === 2. LIST DATA (SCROLLABLE) ===
          // Expanded membuat list mengambil sisa ruang, mendorong pagination ke bawah.
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: accentOrange))
                : _filteredBookings.isEmpty
                    ? Center(child: Text("Tidak ada data", style: GoogleFonts.inter(color: textGrey)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: paginatedData.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildBookingCard(paginatedData[index], request);
                        },
                      ),
          ),

          // === 3. PAGINATION (FIXED BOTTOM) ===
          // Berada di luar Expanded, sehingga selalu visible di bawah layar
          if (!_isLoading && totalPages > 0)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: bgLight, // Warna background menyatu dengan body
                // border: Border(top: BorderSide(color: Colors.grey.shade300)), // Opsional: Garis pemisah
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalPages, (index) {
                      final pageNum = index + 1;
                      final isActive = pageNum == _currentPage;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentPage = pageNum;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isActive ? primaryNavy : Colors.transparent,
                            border: Border.all(color: isActive ? primaryNavy : Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              "$pageNum",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.white : textDark,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  
  // Widget kotak filter kecil (biar kode lebih rapi)
  Widget _buildFilterBox({required IconData icon, required String text, required bool isActive, required bool isDropdown}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? accentOrange.withOpacity(0.1) : Colors.transparent,
        border: Border.all(color: isActive ? accentOrange : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: isActive ? accentOrange : textGrey),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isActive ? accentOrange : textDark,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ),
          if (isDropdown) ...[
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 16, color: textGrey),
          ]
        ],
      ),
    );
  }

  // Widget Kartu Booking
  Widget _buildBookingCard(Booking booking, CookieRequest request) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: primaryNavy.withOpacity(0.04), offset: const Offset(0, 4), blurRadius: 12)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 4, color: accentOrange),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: ID Booking
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "ID: ${booking.id}", 
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: primaryNavy),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          InkWell(
                            onTap: () => _showDeleteConfirm(booking.id, request),
                            child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20),
                          )
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.stadium_rounded, size: 14, color: accentOrange),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              booking.venueName,
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textGrey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _simpleRow(Icons.person, booking.username),
                                const SizedBox(height: 4),
                                _simpleRow(Icons.calendar_today, booking.bookingDate),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _simpleRow(Icons.access_time, "${booking.startTime} - ${booking.endTime}"),
                                const SizedBox(height: 4),
                                _simpleRow(Icons.phone, booking.customerPhone),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _simpleRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: textGrey),
        const SizedBox(width: 4),
        Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 12, color: textDark), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  void _showDeleteConfirm(String id, CookieRequest request) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Booking?"),
        content: const Text("Tindakan ini permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); _deleteBooking(id, request); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}