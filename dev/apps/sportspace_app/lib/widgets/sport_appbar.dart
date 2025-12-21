import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SportAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isMainPage; // True = Halaman Tab Utama, False = Halaman Detail
  final List<Widget>? actions;

  // Palette Warna
  static const Color primaryNavy = Color(0xFF0D2C3E);
  static const Color softOrange = Color(0xFFFF9F45);
  static const Color softOrangeDark = Color(0xFFF97316);

  const SportAppBar({
    super.key,
    required this.title,
    this.isMainPage = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Buat background transparan karena kita pakai Container gradient di flexibleSpace
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false, // Rata kiri lebih modern untuk ada logo
      
      // --- BACKGROUND GRADIENT & SHADOW ---
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              softOrange,     // Mulai dari Orange
              primaryNavy,    // Berakhir di Navy
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),

      // --- LOGIKA TOMBOL KEMBALI ---
      automaticallyImplyLeading: !isMainPage,
      leading: isMainPage
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Kembali',
            ),

      // --- JUDUL DENGAN LOGO ---
      title: Row(
        mainAxisSize: MainAxisSize.min, // Agar row tidak memakan tempat kosong
        children: [
          // Logo Image
          Image.asset(
            'assets/image.png', // Pastikan path ini benar di pubspec.yaml
            height: 32,         // Ukuran logo disesuaikan agar rapi
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback jika gambar tidak ditemukan/error
              return const Icon(Icons.sports_tennis_rounded, color: Colors.white);
            },
          ),
          
          const SizedBox(width: 12), // Jarak antara logo dan teks
          
          // Teks Judul
          Flexible( // Mencegah overflow jika judul panjang
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700, // Lebih tebal (Bold)
                fontSize: 20,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),

      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}