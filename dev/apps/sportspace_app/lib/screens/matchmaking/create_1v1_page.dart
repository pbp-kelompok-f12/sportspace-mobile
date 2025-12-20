import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class Create1v1Page extends StatefulWidget {
  const Create1v1Page({super.key});

  @override
  State<Create1v1Page> createState() => _Create1v1PageState();
}

class _Create1v1PageState extends State<Create1v1Page> {
  final String baseUrl = "http://10.0.2.2:8000";
  int? selectedBookingId;

  Future<List<Map<String, dynamic>>> fetchActiveBookings(CookieRequest request) async {
    final response = await request.get('$baseUrl/booking/api/my-bookings-json/?filter=active');
    List<dynamic> results = response['results'] ?? [];
    return results.cast<Map<String, dynamic>>();
  }

  void _create1v1Match(CookieRequest request) async {
    if (selectedBookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih booking lapangan terlebih dahulu")),
      );
      return;
    }

    final res = await request.post(
      '$baseUrl/matchmaking/create-1v1/',
      {"booking_id": selectedBookingId.toString()},
    );

    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("1v1 match berhasil dibuat!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    const Color darkBlue = Color(0xFF0D2C3E);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Match 1v1"),
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchActiveBookings(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(
              child: Text("Anda belum memiliki booking aktif untuk membuat match."),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "Pilih Booking Lapangan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      final isSelected = booking['id'] == selectedBookingId;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? darkBlue : Colors.blueGrey[50],
                            foregroundColor: isSelected ? Colors.white : Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedBookingId = booking['id'];
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking['venue']['name'] ?? "",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text("${booking['booking_date']} • ${booking['start_time']} - ${booking['end_time']}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  ),
                  onPressed: () => _create1v1Match(request),
                  child: const Text("Create 1v1"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
