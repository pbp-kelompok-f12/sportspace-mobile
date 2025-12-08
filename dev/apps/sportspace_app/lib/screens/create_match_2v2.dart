import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:sportspace_app/widgets/snack_bar.dart';

class CreateMatch2v2Page extends StatefulWidget {
  const CreateMatch2v2Page({super.key});

  @override
  State<CreateMatch2v2Page> createState() => _CreateMatch2v2PageState();
}

class _CreateMatch2v2PageState extends State<CreateMatch2v2Page> {
  final _formKey = GlobalKey<FormState>();
  String _teammateName = '';
  bool _isLoading = false;

  // URL API Matchmaking
  final String createUrl = "http://10.0.2.2:8000/matchmaking/create-2v2/";

  Future<void> _createMatch(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await request.postJson(
        createUrl,
        jsonEncode({'teammate': _teammateName}),
      );

      // *** PERBAIKAN use_build_context_synchronously ***
      if (!context.mounted) return; 

      setState(() => _isLoading = false);

      if (response['status'] == 'success') {
        SnackBarController.showSnackBar(
          context,
          response['message'] ?? 'Match 2v2 berhasil dibuat!',
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
        title: const Text('Buat Match 2 vs 2'),
        backgroundColor: const Color(0xFF002B4F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mode: 2 vs 2 (Empat Pemain)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Anda dan teman non-user Anda (Teammate) mengisi dua slot. Dua slot lain (Lawan) akan diisi dari daftar Matchmaking.',
              ),
              const SizedBox(height: 30),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nama Teman (Teammate)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Masukkan nama teman Anda',
                ),
                onSaved: (value) {
                  _teammateName = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama teman tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton.icon(
                  onPressed: () => _createMatch(request),
                  icon: const Icon(Icons.group_add),
                  label: const Text('Buat Match 2 vs 2 Sekarang'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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