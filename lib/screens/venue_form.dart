import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sportspace_app/screens/homepage.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class VenueFormPage extends StatefulWidget {
  const VenueFormPage({super.key});

  @override
  State<VenueFormPage> createState() => _VenueFormPageState();
}

class _VenueFormPageState extends State<VenueFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Variabel Form
  String _nama = "";
  String _detailJalan = "";
  String? _selectedCity;
  String _thumbnail = "";
  String _notes = "";
  bool _isFeatured = false;

  // Palette Warna (Konsisten dengan HomePage)
  static const Color primaryNavy = Color(0xFF0D2C3E);
  static const Color softOrange = Color(0xFFFF9F45);
  static const Color lightGreyFill = Color(0xFFF1F5F9);

  final List<String> _locations = [
    'Jakarta Selatan',
    'Jakarta Pusat',
    'Jakarta Barat',
    'Jakarta Timur',
    'Jakarta Utara',
  ];

  // Helper untuk styling dekorasi input
  InputDecoration _buildInputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: primaryNavy),
      filled: true,
      fillColor: lightGreyFill,
      labelStyle: GoogleFonts.poppins(color: primaryNavy),
      hintStyle: GoogleFonts.poppins(color: Colors.grey),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: softOrange, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Add New Venue',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Menggunakan Gradient yang sama dengan HomePage
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [softOrange, primaryNavy],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Venue Information",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryNavy,
                  ),
                ),
                const SizedBox(height: 20),

                // 1. Nama Lapangan
                TextFormField(
                  decoration: _buildInputDecoration(
                      "Venue Name", "e.g., Padel Senayan", Icons.sports_tennis),
                  onChanged: (value) => setState(() => _nama = value),
                  validator: (value) =>
                      value!.isEmpty ? "Name cannot be empty" : null,
                ),
                const SizedBox(height: 16.0),

                // 2. Dropdown Wilayah
                DropdownButtonFormField<String>(
                  decoration: _buildInputDecoration(
                      "City / Region", "Select Region", Icons.location_city),
                  value: _selectedCity,
                  items: _locations.map((String location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location, style: GoogleFonts.poppins()),
                    );
                  }).toList(),
                  onChanged: (newValue) =>
                      setState(() => _selectedCity = newValue),
                  validator: (value) =>
                      value == null ? "Please select a region" : null,
                ),
                const SizedBox(height: 16.0),

                // 3. Detail Alamat
                TextFormField(
                  decoration: _buildInputDecoration(
                      "Street Address", "Jl. Sudirman No. 1", Icons.map),
                  maxLines: 2,
                  onChanged: (value) => setState(() => _detailJalan = value),
                  validator: (value) =>
                      value!.isEmpty ? "Address cannot be empty" : null,
                ),
                const SizedBox(height: 16.0),

                // 4. Thumbnail URL
                TextFormField(
                  decoration: _buildInputDecoration(
                      "Image URL", "https://image-link.jpg", Icons.image),
                  onChanged: (value) => setState(() => _thumbnail = value),
                  validator: (value) =>
                      value!.isEmpty ? "Image URL cannot be empty" : null,
                ),
                const SizedBox(height: 16.0),

                // 5. Notes
                TextFormField(
                  decoration: _buildInputDecoration(
                      "Notes (Optional)", "Facilities, parkir, etc.", Icons.note_add),
                  onChanged: (value) => setState(() => _notes = value),
                ),
                const SizedBox(height: 20.0),

                // 6. Checkbox Modern
                Container(
                  decoration: BoxDecoration(
                    color: lightGreyFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      "Set as Featured Venue",
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: primaryNavy),
                    ),
                    value: _isFeatured,
                    activeColor: primaryNavy,
                    onChanged: (value) =>
                        setState(() => _isFeatured = value!),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                const SizedBox(height: 32.0),

                // Tombol Save Modern
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        String finalAddress = "$_detailJalan, $_selectedCity";
                        String generatedPlaceId =
                            "user-${DateTime.now().millisecondsSinceEpoch}";

                        final response = await request.postJson(
                          "https://sean-marcello-sportspace.pbp.cs.ui.ac.id/api/lapangan/create-flutter/",
                          jsonEncode({
                            "place_id": generatedPlaceId,
                            "nama": _nama,
                            "alamat": finalAddress,
                            "thumbnail_url": _thumbnail,
                            "notes": _notes,
                            "is_featured": _isFeatured,
                            "rating": 0.0,
                            "total_review": 0,
                          }),
                        );

                        if (context.mounted) {
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Venue saved successfully!")),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomePage()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: ${response['message']}")),
                            );
                          }
                        }
                      }
                    },
                    child: Text(
                      "Save Venue",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}