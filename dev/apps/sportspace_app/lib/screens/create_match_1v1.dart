import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:sportspace_app/widgets/snack_bar.dart';

class CreateMatch1v1Page extends StatefulWidget {
  const CreateMatch1v1Page({super.key});

  @override
  State<CreateMatch1v1Page> createState() => _CreateMatch1v1PageState();
}

class _CreateMatch1v1PageState extends State<CreateMatch1v1Page> {
  bool _isLoading = false;
  
  // URL API Matchmaking (Pastikan ini sesuai dengan urls.py Anda)
  final String createUrl = "http://10.0.2.2:8000/matchmaking/create-1v1/";

  Future<void> _createMatch(CookieRequest request) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // POST request tanpa body karena mode dan creator diambil di server
      final response = await request.post(createUrl, {});

      // *** PERBAIKAN use_build_context_synchronously ***
      if (!context.mounted) return;

      setState(() => _isLoading = false);

      if (response['status'] == 'success') {
        SnackBarController.showSnackBar(
          context,
          response['message'] ?? 'Match 1v1 berhasil dibuat!',
          Colors.green,
        );
        // Kembali ke halaman sebelumnya dan kirim sinyal refresh
        if (context.mounted) {
            Navigator.pop(context, true); 
        }
      } else {
        SnackBarController.showSnackBar(
          context,
          response['message'] ?? 'Gagal membuat match.',
          Colors.red,
        );
      }
    } catch (e) {
      if (context.mounted) setState(() => _isLoading = false);
      SnackBarController.showSnackBar(
        context,
        'Terjadi kesalahan koneksi.',
        Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Match 1 vs 1'),
        backgroundColor: const Color(0xFF002B4F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mode: 1 vs 1 (Dua Pemain)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Anda akan menjadi pencipta match ini dan otomatis terdaftar sebagai pemain pertama. Pemain kedua akan bergabung dari daftar Matchmaking.',
            ),
            const SizedBox(height: 30),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                onPressed: () => _createMatch(request),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Buat Match 1 vs 1 Sekarang'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}