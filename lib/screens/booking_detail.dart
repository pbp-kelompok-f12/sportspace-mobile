import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class BookingDetailPage extends StatefulWidget {
  final int lapanganPk;
  final String nama;
  final String alamat;
  final String imageUrl;

  const BookingDetailPage({
    super.key,
    required this.lapanganPk,
    required this.nama,
    required this.alamat,
    required this.imageUrl,
  });

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";

  // === PREMIUM PALETTE ===
  static const Color primaryNavy = Color(0xFF0D2C3E);
  static const Color softOrange = Color(0xFFFF9F45);
  static const Color softOrangeDark = Color(0xFFF97316);
  static const Color backgroundGrey = Color(0xFFF8FAFC);
  static const Color textGrey = Color(0xFF64748B);

  late Future<Map<String, dynamic>> _slotsFuture;
  String _selectedDate = "";
  final DateTime today = DateTime.now();
  late List<DateTime> next7Days;

  @override
  void initState() {
    super.initState();
    next7Days = List.generate(7, (i) => today.add(Duration(days: i)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = context.read<CookieRequest>();
    _slotsFuture = _fetchSlots(request, null);
  }

  // --- IMAGE HELPER DENGAN FALLBACK ---
  ImageProvider _getVenueImage(String? url) {
    if (url == null || url.isEmpty || url == "null") {
      return const AssetImage("assets/images/imagenotavail.png");
    }
    if (url.startsWith('http')) {
      String encodedUrl = Uri.encodeComponent(url);
      return NetworkImage("$baseUrl/home/proxy-image/?url=$encodedUrl");
    }
    return NetworkImage("$baseUrl$url");
  }

  // --- LOGIKA ASLI (TIDAK BERUBAH) ---
  Future<Map<String, dynamic>> _fetchSlots(CookieRequest request, String? date) async {
    final venueResponse = await request.get("$baseUrl/home/api/lapangan-to-venue/${widget.lapanganPk}/");
    final venueId = venueResponse["venue_id"] as String;
    final query = date != null ? "?date=$date" : "";
    final response = await request.get("$baseUrl/booking/api/venue-time-slots/$venueId/$query");
    
    if (mounted) {
      setState(() {
        _selectedDate = response["selected_date"] as String;
      });
    }
    return response as Map<String, dynamic>;
  }

  void _reloadForDate(String date) {
    final request = context.read<CookieRequest>();
    setState(() {
      _selectedDate = date;
      _slotsFuture = _fetchSlots(request, date);
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. PREMIUM HORIZONTAL HEADER (GAMBAR MEMANJANG)
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            elevation: 0,
            stretch: true,
            backgroundColor: primaryNavy,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.3),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: _getVenueImage(widget.imageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      "assets/images/imagenotavail.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [Colors.black45, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. VENUE INFORMATION CARD (DI BAWAH GAMBAR)
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.nama,
                          style: GoogleFonts.poppins(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold, 
                            color: primaryNavy
                          ),
                        ),
                      ),
                      const Icon(Icons.verified, color: Colors.blue, size: 24),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: softOrangeDark, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.alamat,
                          style: GoogleFonts.poppins(fontSize: 13, color: textGrey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. DATE PICKER SECTION
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pilih Tanggal",
                    style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildHorizontalDatePicker(),
                ],
              ),
            ),
          ),

          // 4. TIME SLOTS SECTION (RELOAD HANYA BAGIAN INI)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 100),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Waktu Tersedia",
                    style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _slotsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: CircularProgressIndicator(color: softOrangeDark),
                          ),
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return const Center(child: Text("Jadwal tidak tersedia"));
                      }

                      final List<dynamic> slots = snapshot.data!["time_slots"] ?? [];
                      return _buildTimeGrid(slots, request);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalDatePicker() {
    return SizedBox(
      height: 85,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: next7Days.length,
        itemBuilder: (context, index) {
          final day = next7Days[index];
          final String dateStr = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
          final bool isSelected = dateStr == _selectedDate;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => _reloadForDate(dateStr),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 65,
                decoration: BoxDecoration(
                  gradient: isSelected ? const LinearGradient(colors: [softOrange, softOrangeDark]) : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ['Min','Sen','Sel','Rab','Kam','Jum','Sab'][day.weekday % 7],
                      style: GoogleFonts.poppins(fontSize: 12, color: isSelected ? Colors.white : textGrey, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      day.day.toString(),
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : primaryNavy),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeGrid(List<dynamic> slots, CookieRequest request) {
    if (slots.isEmpty) return const Center(child: Text("Tidak ada slot tersedia hari ini"));
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.3,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index] as Map<String, dynamic>;
        final bool isUnavailable = (slot["is_unavailable"] as bool?) ?? false;

        return InkWell(
          onTap: isUnavailable ? null : () => _showBookingDialog(request, slot),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: isUnavailable ? Colors.grey.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: !isUnavailable ? softOrange.withOpacity(0.2) : Colors.transparent),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slot["display"] ?? "",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, color: isUnavailable ? Colors.grey : primaryNavy, fontSize: 15
                  ),
                ),
                Text(
                  isUnavailable ? "Tutup" : "Tersedia",
                  style: GoogleFonts.poppins(fontSize: 10, color: isUnavailable ? Colors.grey : Colors.green, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showBookingDialog(CookieRequest request, Map<String, dynamic> slot) async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    // VARIABEL 'confirm' DISINI SUDAH DISAMAKAN
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Konfirmasi Booking", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: backgroundGrey, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: softOrangeDark),
                    const SizedBox(width: 10),
                    Expanded(child: Text("$_selectedDate • ${slot["display"]}", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildField(nameCtrl, "Nama Lengkap", Icons.person_outline),
              const SizedBox(height: 12),
              _buildField(emailCtrl, "Email", Icons.email_outlined),
              const SizedBox(height: 12),
              _buildField(phoneCtrl, "Nomor Telepon", Icons.phone_outlined),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Konfirmasi", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final snackBarController = ScaffoldMessenger.of(context);
    try {
      final venueResponse = await request.get("$baseUrl/home/api/lapangan-to-venue/${widget.lapanganPk}/");
      final venueId = venueResponse["venue_id"] as String;

      final createResponse = await request.postJson(
        "$baseUrl/booking/api/create-booking/",
        jsonEncode({
          "venue_id": venueId,
          "booking_date": _selectedDate,
          "start_time": slot["start_time"],
          "end_time": slot["end_time"],
          "customer_name": nameCtrl.text,
          "customer_email": emailCtrl.text,
          "customer_phone": phoneCtrl.text,
        }),
      );

      if (createResponse["success"] == true) {
        snackBarController.showSnackBar(SnackBar(content: Text(createResponse["message"] ?? "Booking Berhasil!"), backgroundColor: Colors.green));
        _reloadForDate(_selectedDate);
      } else {
        snackBarController.showSnackBar(SnackBar(content: Text(createResponse["message"] ?? "Gagal"), backgroundColor: Colors.red));
      }
    } catch (e) {
      snackBarController.showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20, color: primaryNavy),
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 13),
        filled: true,
        fillColor: backgroundGrey,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}