import 'package:flutter/material.dart';
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

  late Future<Map<String, dynamic>> _slotsFuture;
  String _selectedDate = "";

  @override
  void initState() {
    super.initState();
    // default date will be provided by API when first loaded
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = context.read<CookieRequest>();
    _slotsFuture = _fetchSlots(request, null);
  }

  Future<Map<String, dynamic>> _fetchSlots(
    CookieRequest request,
    String? date,
  ) async {
    // We rely on backend home -> booking sync to map lapangan pk to venue id.
    // For mobile, we call booking API directly with venue UUID embedded in lapangan
    // pk mapping endpoint. To keep this simple here, we assume lapangan pk was
    // already synced and is equal to booking venue UUID string on backend side.
    // So we first call a small helper endpoint from web that returns venue id.
    final venueResponse = await request.get(
      "$baseUrl/home/api/lapangan-to-venue/${widget.lapanganPk}/",
    );
    final venueId = venueResponse["venue_id"] as String;

    final query = date != null ? "?date=$date" : "";
    final response = await request.get(
      "$baseUrl/booking/api/venue-time-slots/$venueId/$query",
    );

    _selectedDate = response["selected_date"] as String;
    return response as Map<String, dynamic>;
  }

  void _reloadForDate(String date) {
    final request = context.read<CookieRequest>();
    setState(() {
      _slotsFuture = _fetchSlots(request, date);
    });
  }

  Future<void> _showBookingDialog(
    CookieRequest request,
    Map<String, dynamic> slot,
  ) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Konfirmasi Booking"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(widget.alamat),
                const SizedBox(height: 8),
                Text(
                  "$_selectedDate • ${slot["display"]}",
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Nama Lengkap",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: "Nomor Telepon",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("Konfirmasi"),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final snackBarController = ScaffoldMessenger.of(context);

    try {
      final venueResponse = await request.get(
        "$baseUrl/home/api/lapangan-to-venue/${widget.lapanganPk}/",
      );
      final venueId = venueResponse["venue_id"] as String;

      final createResponse = await request.postJson(
        "$baseUrl/booking/api/create-booking/",
        {
          "venue_id": venueId,
          "booking_date": _selectedDate,
          "start_time": slot["start_time"],
          "end_time": slot["end_time"],
          "customer_name": nameController.text,
          "customer_email": emailController.text,
          "customer_phone": phoneController.text,
        },
      );

      if (createResponse["success"] == true) {
        snackBarController
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(createResponse["message"] ?? "Booking Created!")),
          );
        // reload slots
        _reloadForDate(_selectedDate);
      } else {
        snackBarController
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(createResponse["message"] ?? "Gagal membuat booking"),
            ),
          );
      }
    } catch (e) {
      snackBarController
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    final Color darkBlue = const Color(0xFF0D2C3E);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: const Text(
          "Book Lapangan",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _slotsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Tidak ada data"));
          }

          final data = snapshot.data!;
          final List<dynamic> slots = data["time_slots"] ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                // Court info
                SizedBox(
                  height: 220,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.imageUrl.isNotEmpty
                            ? widget.imageUrl
                            : "https://via.placeholder.com/400x220",
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, _, __) => Container(
                          color: Colors.grey,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black87,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.nama,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.alamat,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pilih Waktu",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D2C3E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tanggal: $_selectedDate",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 3,
                        ),
                        itemCount: slots.length,
                        itemBuilder: (context, index) {
                          final slot = slots[index] as Map<String, dynamic>;
                          final bool isUnavailable =
                              (slot["is_unavailable"] as bool?) ?? false;
                          final bool isPast = (slot["is_past"] as bool?) ?? false;
                          final bool isBooked = (slot["is_booked"] as bool?) ?? false;

                          Color bgColor;
                          String statusText;
                          Color statusColor;

                          if (isPast) {
                            bgColor = Colors.grey.shade300;
                            statusText = "Melewati Waktu";
                            statusColor = Colors.red.shade400;
                          } else if (isBooked) {
                            bgColor = Colors.grey.shade200;
                            statusText = "Tidak Tersedia";
                            statusColor = Colors.grey.shade700;
                          } else {
                            bgColor = Colors.green.shade50;
                            statusText = "Tersedia";
                            statusColor = Colors.green.shade600;
                          }

                          return InkWell(
                            onTap: isUnavailable
                                ? null
                                : () => _showBookingDialog(request, slot),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isUnavailable
                                      ? Colors.grey.shade400
                                      : Colors.green.shade200,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    slot["display"] ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


