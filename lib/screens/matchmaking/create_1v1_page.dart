import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class Create1v1Page extends StatefulWidget {
  const Create1v1Page({super.key});

  @override
  State<Create1v1Page> createState() => _Create1v1PageState();
}

class _Create1v1PageState extends State<Create1v1Page> {
  // Pastikan URL ini sesuai dengan environment Anda
  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";
  
  bool _isLoading = false;

  // Warna Palette
  static const Color primaryNavy = Color(0xFF0D2C3E);

  Future<void> _handleCreateMatch(CookieRequest request) async {
    setState(() {
      _isLoading = true;
    });

    // Kita kirim JSON kosong (atau null) karena Lokasi & Jam dihapus.
    // Backend akan otomatis set venue_name, start_time, dll menjadi None/Null.
    final response = await request.postJson(
      '$baseUrl/matchmaking/create-1v1/',
      jsonEncode(<String, dynamic>{
        // Tidak ada data lokasi/jam yang dikirim
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (context.mounted) {
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Match 1v1 berhasil dibuat!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke list page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Terjadi kesalahan"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Buat Match 1v1",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Visual
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryNavy.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: primaryNavy,
                ),
              ),
              const SizedBox(height: 24),
              
              // Judul & Deskripsi
              Text(
                "Match 1 vs 1",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryNavy,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Tekan tombol di bawah untuk membuat room match baru. Pemain lain dapat melihat dan bergabung ke match Anda.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Tombol Action
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _handleCreateMatch(request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          "Buat Match Sekarang",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}