import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// Import halaman admin
import 'package:sportspace_app/screens/auth/login.dart'; 
import 'package:sportspace_app/screens/admin/manage_users_page.dart';
import 'package:sportspace_app/screens/admin/manage_fields_page.dart';
import 'package:sportspace_app/screens/admin/manage_bookings_page.dart';

import 'package:google_fonts/google_fonts.dart';

class DashboardAdminPage extends StatelessWidget {
  const DashboardAdminPage({super.key});

  // --- PALETTE WARNA ---
  final Color primaryNavy = const Color(0xFF0C2D57);
  final Color secondaryNavy = const Color(0xFF164275); // Navy lebih terang untuk gradasi
  final Color accentOrange = const Color(0xFFF97316);
  final Color bgLight = const Color(0xFFF1F5F9); 

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: bgLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. ANIMATED HEADER (Slide Down)
            _buildAnimatedHeader(context, request),

            const SizedBox(height: 24),

            // 2. ANIMATED MENU LIST (Slide Up)
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutQuart,
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - value)), // Efek naik dari bawah (50px)
                  child: Opacity(
                    opacity: value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Main Menu",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryNavy,
                              
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Kartu 1: Lapangan
                          _buildMenuCard(
                            context,
                            title: "Kelola Lapangan",
                            subtitle: "Tambah, edit, atau hapus venue",
                            icon: Icons.stadium_rounded,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ManageFieldsPage()),
                            ),
                          ),
                          
                          const SizedBox(height: 16), 

                          // Kartu 2: Pengguna
                          _buildMenuCard(
                            context,
                            title: "Manajemen Pengguna",
                            subtitle: "Atur role akun & data user",
                            icon: Icons.people_alt_rounded,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ManageUsersPage()),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Kartu 3: Booking
                          _buildMenuCard(
                            context,
                            title: "Data Booking",
                            subtitle: "Lihat daftar reservasi masuk",
                            icon: Icons.calendar_month_rounded,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ManageBookingsPage()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HEADER MODERN ---
  Widget _buildAnimatedHeader(BuildContext context, CookieRequest request) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutExpo,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              height: 240, // Sedikit lebih tinggi untuk proporsi modern
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryNavy, secondaryNavy],
                  stops: const [0.2, 1.0],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryNavy.withOpacity(0.3),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Dekorasi Abstrak (Modern Shapes)
                  Positioned(
                    top: -60,
                    right: -40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentOrange.withOpacity(0.08),
                      ),
                    ),
                  ),

                  // Konten
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.admin_panel_settings_rounded, 
                                          color: accentOrange, size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          "ADMINISTRATOR",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Dashboard",
                                    style: GoogleFonts.poppins( // Judul besar pakai Poppins
                                      color: Colors.white,
                                      fontSize: 32, 
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Selamat datang kembali, Admin!",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Tombol Logout Modern (Glass style)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _handleLogout(context, request),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2), 
                                        width: 1
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.logout_rounded, 
                                      color: Color.fromARGB(255, 255, 255, 255), 
                                      size: 24
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  // --- WIDGET KARTU MENU ---
  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      shadowColor: primaryNavy.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border(
              left: BorderSide(color: accentOrange, width: 5),
            ),
          ),
          child: Stack(
            children: [
              // Watermark Icon
              Positioned(
                right: -15,
                bottom: -15,
                child: Opacity(
                  opacity: 0.05,
                  child: Icon(icon, size: 120, color: primaryNavy),
                ),
              ),

              // Konten Utama
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accentOrange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: accentOrange, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LOGIC LOGOUT ---
  Future<void> _handleLogout(BuildContext context, CookieRequest request) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Logout", style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold)),
        content: const Text("Keluar dari sistem admin?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final response = await request.logout(
                "https://sean-marcello-sportspace.pbp.cs.ui.ac.id/accounts/logout-flutter/"
              );
              if (context.mounted && response['status']) {
                 Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}