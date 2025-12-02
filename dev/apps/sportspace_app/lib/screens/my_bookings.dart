import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";
  late Future<List<dynamic>> _bookingsFuture;
  String _filter = "all";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = context.read<CookieRequest>();
    _bookingsFuture = _fetchBookings(request, _filter);
  }

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

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Edit Booking"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final updateResponse = await request.postJson(
        "$baseUrl/booking/api/update-booking/${booking["id"]}/",
        {
          "customer_name": nameController.text,
          "customer_email": emailController.text,
          "customer_phone": phoneController.text,
        },
      );
      if (updateResponse["success"] == true) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(updateResponse["message"] ?? "Booking Updated!")),
          );
        _reload(_filter);
      } else {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(updateResponse["message"] ?? "Gagal mengubah booking"),
            ),
          );
      }
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
    }
  }

  Future<void> _deleteBooking(
    CookieRequest request,
    Map<String, dynamic> booking,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Hapus Booking"),
          content: const Text(
            "Apakah Anda yakin ingin menghapus booking ini? Tindakan ini tidak dapat dibatalkan.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final deleteResponse = await request.postJson(
        "$baseUrl/booking/api/delete-booking-post/${booking["id"]}/",
        {},
      );
      if (deleteResponse["success"] == true) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(deleteResponse["message"] ?? "Booking Deleted!")),
          );
        _reload(_filter);
      } else {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(deleteResponse["message"] ?? "Gagal menghapus booking"),
            ),
          );
      }
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookingan Saya"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final bookings = snapshot.data ?? [];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text("Semua"),
                      selected: _filter == "all",
                      onSelected: (_) => _reload("all"),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("Active"),
                      selected: _filter == "active",
                      onSelected: (_) => _reload("active"),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("Past"),
                      selected: _filter == "past",
                      onSelected: (_) => _reload("past"),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: bookings.isEmpty
                    ? const Center(
                        child: Text("Belum ada booking. Mulai booking lapangan!"),
                      )
                    : ListView.builder(
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index] as Map<String, dynamic>;
                          final venue = booking["venue"] as Map<String, dynamic>;
                          final bool isPast = booking["is_past"] ?? false;
                          final String status = booking["status"] ?? "";

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          venue["name"] ?? "",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isPast
                                              ? Colors.grey
                                              : Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          status,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    venue["location"] ?? "",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        booking["booking_date"] ?? "",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(
                                        Icons.schedule,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${booking["start_time"]} - ${booking["end_time"]}",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Atas Nama: ${booking["customer_name"]}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (!isPast) ...[
                                        TextButton(
                                          onPressed: () =>
                                              _editBooking(request, booking),
                                          child: const Text("Edit"),
                                        ),
                                        const SizedBox(width: 4),
                                        TextButton(
                                          onPressed: () =>
                                              _deleteBooking(request, booking),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text("Hapus"),
                                        ),
                                      ] else
                                        const Text(
                                          "Completed",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}


