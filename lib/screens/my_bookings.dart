import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  // === COLOR PALETTE (Design System) ===
  static const Color primaryNavy = Color(0xFF0D2C3E);
  static const Color softOrange = Color(0xFFFF9F45);
  static const Color softOrangeDark = Color(0xFFF97316);
  static const Color backgroundGrey = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGrey = Color(0xFF64748B);

  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";
  late Future<List<dynamic>> _bookingsFuture;
  String _filter = "all";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = context.read<CookieRequest>();
    _bookingsFuture = _fetchBookings(request, _filter);
  }

  // --- LOGIKA API (TIDAK DIUBAH) ---
  Future<List<dynamic>> _fetchBookings(
    CookieRequest request,
    String filter,
  ) async {
    final response = await request.get(
      "$baseUrl/booking/api/my-bookings-json/?filter=$filter",
    );
    return response["results"] as List<dynamic>;
  }

  void _reload(String filter) {
    final request = context.read<CookieRequest>();
    setState(() {
      _filter = filter;
      _bookingsFuture = _fetchBookings(request, filter);
    });
  }

  Future<void> _editBooking(
    CookieRequest request,
    Map<String, dynamic> booking,
  ) async {
    final nameController =
        TextEditingController(text: booking["customer_name"] ?? "");
    final emailController =
        TextEditingController(text: booking["customer_email"] ?? "");
    final phoneController =
        TextEditingController(text: booking["customer_phone"] ?? "");

    // Update Design Dialog agar selaras
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Edit Booking",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: primaryNavy)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, "Nama Lengkap", Icons.person),
                const SizedBox(height: 12),
                _buildTextField(emailController, "Email", Icons.email),
                const SizedBox(height: 12),
                _buildTextField(phoneController, "Nomor Telepon", Icons.phone),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text("Batal", style: GoogleFonts.inter(color: textGrey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryNavy,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context); // Pindahkan messenger ke sini

    try {
      final updateResponse = await request.postJson(
        "$baseUrl/booking/api/update-booking/${booking["id"]}/",
        jsonEncode({
          "customer_name": nameController.text,
          "customer_email": emailController.text,
          "customer_phone": phoneController.text,
        }),
      );
      if (updateResponse["success"] == true) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(updateResponse["message"] ?? "Booking Updated!"),
              backgroundColor: primaryNavy, // Warna Navy
            ),
          );
        _reload(_filter);
      } else {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(updateResponse["message"] ?? "Gagal mengubah booking"),
              backgroundColor: Colors.red,
            ),
          );
      }
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e"), backgroundColor: Colors.red),
        );
    }
  }

  Future<void> _deleteBooking(
    CookieRequest request,
    Map<String, dynamic> booking,
  ) async {
    // Update Design Dialog Confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Hapus Booking",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: primaryNavy)),
          content: Text(
            "Apakah Anda yakin ingin menghapus booking ini? Tindakan ini tidak dapat dibatalkan.",
            style: GoogleFonts.inter(color: textDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text("Batal", style: GoogleFonts.inter(color: textGrey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text("Hapus", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context); // Pindahkan messenger

    try {
      final deleteResponse = await request.postJson(
        "$baseUrl/booking/api/delete-booking-post/${booking["id"]}/",
        jsonEncode({}),
      );
      if (deleteResponse["success"] == true) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(deleteResponse["message"] ?? "Booking Deleted!"),
              backgroundColor: primaryNavy,
            ),
          );
        _reload(_filter);
      } else {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(deleteResponse["message"] ?? "Gagal menghapus booking"),
              backgroundColor: Colors.red,
            ),
          );
      }
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e"), backgroundColor: Colors.red),
        );
    }
  }
  // --- END LOGIKA API ---

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: backgroundGrey, // Background Abu-abu terang
      body: Column(
        children: [
          // 1. HEADER GRADIENT (Orange)
          Container(
            padding: const EdgeInsets.only(bottom: 24, top: 60, left: 20, right: 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [softOrange, softOrangeDark],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
              ],
            ),
            child: Column(
              children: [
                Text(
                  "Bookingan Saya",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Kelola jadwal bermainmu disini",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // 2. FILTER & LIST
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _bookingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: softOrange));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.red)));
                }

                final bookings = snapshot.data ?? [];

                return Column(
                  children: [
                    // Filter Chips
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildFilterChip("Semua", "all"),
                            const SizedBox(width: 8),
                            _buildFilterChip("Active", "active"),
                            const SizedBox(width: 8),
                            _buildFilterChip("Past", "past"),
                          ],
                        ),
                      ),
                    ),

                    // List Bookings
                    Expanded(
                      child: bookings.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  Text("Belum ada booking.", style: GoogleFonts.poppins(color: textGrey, fontSize: 16)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(top: 0, bottom: 20, left: 16, right: 16),
                              itemCount: bookings.length,
                              itemBuilder: (context, index) {
                                final booking = bookings[index] as Map<String, dynamic>;
                                return _buildModernBookingCard(request, booking);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS PENDUKUNG DESAIN ---

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      labelStyle: GoogleFonts.poppins(
        color: isSelected ? Colors.white : primaryNavy,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      selected: isSelected,
      selectedColor: primaryNavy,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? primaryNavy : primaryNavy.withOpacity(0.1)),
      ),
      onSelected: (_) => _reload(value),
    );
  }

  Widget _buildModernBookingCard(CookieRequest request, Map<String, dynamic> booking) {
    final venue = booking["venue"] as Map<String, dynamic>;
    final bool isPast = booking["is_past"] ?? false;
    final String status = booking["status"] ?? "";

    Color statusColor;
    if (isPast) {
      statusColor = Colors.grey;
    } else if (status.toLowerCase() == 'confirmed' || status.toLowerCase() == 'paid') {
      statusColor = Colors.green;
    } else {
      statusColor = softOrange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryNavy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.sports_tennis_rounded, color: primaryNavy, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue["name"] ?? "",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 12, color: textGrey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              venue["location"] ?? "",
                              style: GoogleFonts.inter(fontSize: 12, color: textGrey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    isPast ? "Selesai" : status,
                    style: GoogleFonts.poppins(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.calendar_today_rounded, "Tanggal", booking["booking_date"] ?? ""),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.access_time_rounded, "Waktu", "${booking["start_time"]} - ${booking["end_time"]}"),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.person_outline_rounded, "Pemesan", booking["customer_name"] ?? ""),
              ],
            ),
          ),
          // Actions Buttons (Hanya jika belum selesai/past)
          if (!isPast)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _editBooking(request, booking),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryNavy,
                        side: const BorderSide(color: primaryNavy),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text("Edit Info", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _deleteBooking(request, booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text("Batalkan", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: textGrey),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: textGrey)),
        ),
        const Text(": ", style: TextStyle(color: Colors.grey)),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textDark),
          ),
        ),
      ],
    );
  }

  // Helper untuk TextField di Dialog
  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryNavy),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryNavy)),
      ),
    );
  }
}