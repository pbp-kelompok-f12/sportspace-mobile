import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
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
  String _detailJalan = ""; // Mengganti _alamat menjadi detail jalan
  String? _selectedCity;    // Tambahan: Untuk menyimpan wilayah pilihan
  String _thumbnail = "";
  String _notes = "";
  bool _isFeatured = false;

  // Daftar Lokasi (Harus SAMA PERSIS dengan yang ada di Homepage agar filter bekerja)
  final List<String> _locations = [
    'Jakarta Selatan',
    'Jakarta Pusat',
    'Jakarta Barat',
    'Jakarta Timur',
    'Jakarta Utara',
  ];

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
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
                    hintText: "Contoh: Padel Senayan",
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

                // 2.A. Dropdown Wilayah (PENTING untuk Filter Homepage)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Wilayah / Kota",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  value: _selectedCity,
                  hint: const Text("Pilih Wilayah"),
                  items: _locations.map((String location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCity = newValue;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Pilih wilayah terlebih dahulu!";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // 2.B. Detail Alamat (Jalan, No, RT/RW)
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Jl. Jendral Sudirman No. 1",
                    labelText: "Detail Alamat Jalan",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  maxLines: 2,
                  onChanged: (String? value) {
                    setState(() {
                      _detailJalan = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Detail alamat tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // 3. Thumbnail URL
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "https://example.com/image.jpg",
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

                // 4. Notes
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Fasilitas: Parkir luas, kantin, dll.",
                    labelText: "Notes (Opsional)",
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
                    const Text("Jadikan Lapangan Unggulan"),
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
                        // LOGIKA PENGGABUNGAN ALAMAT
                        // Format: "Jl. Bla Bla, Jakarta Selatan"
                        // Ini memastikan filter "contains('Jakarta Selatan')" di homepage bernilai TRUE.
                        String finalAddress = "$_detailJalan, $_selectedCity";

                        // GENERATE ID (Randomize sesuai permintaan)
                        String generatedPlaceId = "user-${DateTime.now().millisecondsSinceEpoch}";

                        // Kirim ke Backend (endpoint deployment)
                        final response = await request.postJson(
                          "https://sean-marcello-sportspace.pbp.cs.ui.ac.id/api/lapangan/create-flutter/", 
                          jsonEncode({
                            "place_id": generatedPlaceId, 
                            "nama": _nama,
                            "alamat": finalAddress, // Alamat yang sudah digabung
                            "thumbnail_url": _thumbnail,
                            "notes": _notes,
                            "is_featured": _isFeatured,
                            "rating": 0.0, // Default rating
                            "total_review": 0,
                          }),
                        );

                        if (context.mounted) {
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Lapangan berhasil disimpan!"),
                            ));
                            // Kembali ke homepage dan refresh data
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