import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
// Ganti 'sportspace_app' sesuai nama folder project Anda jika berbeda
import 'package:sportspace_app/screens/homepage.dart'; 


class VenueFormPage extends StatefulWidget {
  const VenueFormPage({super.key});

  @override
  State<VenueFormPage> createState() => _VenueFormPageState();
}

class _VenueFormPageState extends State<VenueFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Variabel Form
  String _nama = "";
  String _alamat = "";
  String _thumbnail = "";
  String _notes = ""; // Tambahan sesuai model Django
  bool _isFeatured = false;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    // Warna tema
    final Color darkBlue = const Color(0xFF0D2C3E);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Venue',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Nama Lapangan
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Nama Lapangan",
                    labelText: "Nama Lapangan",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _nama = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Nama tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // 2. Alamat
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Alamat Lengkap",
                    labelText: "Alamat",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  maxLines: 3,
                  onChanged: (String? value) {
                    setState(() {
                      _alamat = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Alamat tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // 3. Thumbnail URL
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "URL Gambar (Thumbnail)",
                    labelText: "Thumbnail URL",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _thumbnail = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "URL Gambar tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // 4. Notes (Opsional, tapi ada di model)
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Catatan Tambahan (Opsional)",
                    labelText: "Notes",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _notes = value!;
                    });
                  },
                ),
                const SizedBox(height: 16.0),

                // 5. Is Featured Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _isFeatured,
                      activeColor: darkBlue,
                      onChanged: (bool? value) {
                        setState(() {
                          _isFeatured = value!;
                        });
                      },
                    ),
                    const Text("Jadikan Lapangan Unggulan (Featured)"),
                  ],
                ),
                const SizedBox(height: 24.0),

                // Tombol Save
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40.0,
                        vertical: 16.0,
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // GENERATE PLACE_ID MANUAL
                        // Karena di Django wajib ada place_id, kita buat unik menggunakan timestamp
                        String generatedPlaceId = "manual-${DateTime.now().millisecondsSinceEpoch}";

                        // Kirim ke Backend
                        // PENTING: Ganti URL sesuai environment (Localhost/Emulator)
                        // Android Emulator: http://10.0.2.2:8000/
                        // Browser/iOS Simulator: http://127.0.0.1:8000/
                        final response = await request.postJson(
                          "http://127.0.0.1:8000/api/lapangan/create-flutter/", 
                          jsonEncode({
                            "place_id": generatedPlaceId, // Wajib dikirim
                            "nama": _nama,
                            "alamat": _alamat,
                            "thumbnail_url": _thumbnail,
                            "notes": _notes,
                            "is_featured": _isFeatured,
                            // Kirim default value untuk rating agar tidak error/null di database
                            "rating": 0.0, 
                            "total_review": 0,
                          }),
                        );

                        if (context.mounted) {
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Lapangan berhasil disimpan!"),
                            ));
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomePage()),
                            );
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                              content: Text("Gagal: ${response['message']}"),
                            ));
                          }
                        }
                      }
                    },
                    child: const Text(
                      "Save Venue",
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}