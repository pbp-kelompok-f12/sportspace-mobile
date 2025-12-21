import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Fungsi reusable untuk menampilkan Error Dialog
void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Terjadi Kesalahan", // Judul standar error
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            // color: Colors.redAccent, // Opsional: Beri warna merah jika ingin menekankan error
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message, // Pesan error dinamis sesuai parameter
          style: GoogleFonts.inter(
            color: Colors.grey[700], // Menggunakan warna abu-abu gelap (mirip textGrey)
          ),
        ),
        actions: [
          // Tombol OK untuk menutup dialog
          TextButton(
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                color: Colors.redAccent, // Warna merah agar senada dengan tema error/alert
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}