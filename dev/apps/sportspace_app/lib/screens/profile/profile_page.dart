import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // IMPORT GOOGLE FONTS
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportspace_app/widgets/editprofilesheet.dart';

import 'package:sportspace_app/models/profile_entry.dart';
import 'package:sportspace_app/screens/auth/login.dart';
import 'package:sportspace_app/screens/profile/friendpage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  // URL SERVER
  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";
  late Future<ProfileEntry> _profileFuture;

  // === PALET WARNA MODERN ===
  final Color primaryNavy = const Color(0xFF0F172A); // Slate 900
  final Color primaryBlue = const Color(0xFF3B82F6); // Blue 500
  final Color accentOrange = const Color(0xFFF97316); // Orange 500
  final Color bgLight = const Color(0xFFF1F5F9); // Slate 100
  final Color textDark = const Color(0xFF1E293B); // Slate 800
  final Color textGrey = const Color(0xFF64748B); // Slate 500

  // Animation Controllers
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _profileFuture = fetchProfile(request);

    // Setup Entrance Animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    // Jalankan animasi setelah build pertama
    Timer(
      const Duration(milliseconds: 100),
      () => _entranceController.forward(),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void refreshProfile() {
    final request = context.read<CookieRequest>();
    setState(() {
      _profileFuture = fetchProfile(request);
    });
  }

  Future<ProfileEntry> fetchProfile(CookieRequest request) async {
    final response = await request.get('$baseUrl/accounts/profile/json/');
    return ProfileEntry.fromJson(response);
  }

  ImageProvider _getProfileImage(String? url) {
    if (url == null || url.isEmpty) {
      return const AssetImage("assets/images/defaultprofile.png");
    }
    if (url.startsWith('http')) {
      String encodedUrl = Uri.encodeComponent(url);
      return NetworkImage("$baseUrl/home/proxy-image/?url=$encodedUrl");
    }
    return NetworkImage("$baseUrl$url");
  }

  // LOGOUT LOGIC
  void _showLogoutConfirmation(BuildContext context, CookieRequest request) {
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
            "Logout",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Apakah Anda yakin ingin keluar?",
            style: GoogleFonts.inter(color: textGrey),
          ),
          actions: [
            TextButton(
              child: Text(
                'Batal',
                style: GoogleFonts.inter(
                  color: textGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Keluar',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                final response = await request.logout(
                  "$baseUrl/accounts/logout-flutter/",
                );
                if (context.mounted && response['status']) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // MODAL EDIT PROFILE
  void _openEditModal(
    BuildContext context,
    CookieRequest request,
    ProfileEntry data,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileSheet(
        request: request,
        data: data,
        baseUrl: baseUrl,
        onSaveSuccess: () {
          refreshProfile();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Profil berhasil diperbarui!",
                style: GoogleFonts.inter(),
              ),
              backgroundColor: const Color(0xFF10B981), // Emerald Green
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: bgLight,
      body: FutureBuilder<ProfileEntry>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryBlue));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Gagal memuat profil",
                style: GoogleFonts.inter(color: Colors.red),
              ),
            );
          }
          if (snapshot.hasData) {
            final data = snapshot.data!;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildModernHeader(data, context, request),

                  // Content Body dengan Animasi Slide Up
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ), // Space untuk foto profil yang overlap
                        // 1. INFO UTAMA (Nama & Bio)
                        SlideFadeTransition(
                          controller: _entranceController,
                          delay: 0.1,
                          child: Column(
                            children: [
                              Text(
                                data.username,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: primaryNavy,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 4,
                                  bottom: 8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  data.role.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: primaryBlue,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              Text(
                                data.bio.isEmpty ? "Belum ada bio." : data.bio,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: textGrey,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 2. STATISTIK CARD
                        SlideFadeTransition(
                          controller: _entranceController,
                          delay: 0.2,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              // mainAxisAlignment tidak terlalu berpengaruh jika pakai Expanded,
                              // tapi bisa dihapus atau biarkan default.
                              children: [
                                // Item 1: Booking
                                Expanded(
                                  child: _buildStatItem(
                                    "Booking",
                                    data.totalBooking.toString(),
                                    Icons.calendar_today_rounded,
                                    Colors.orange,
                                  ),
                                ),

                                // Divider 1 (Lebar tetap)
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.grey.shade200,
                                ),

                                // Item 2: Rating
                                Expanded(
                                  child: _buildStatItem(
                                    "Rating",
                                    data.avgRating == 0 ? "-": data.avgRating.toString(),
                                    Icons.star_rounded,
                                    Colors.amber,
                                  ),
                                ),

                                // Divider 2 (Lebar tetap)
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.grey.shade200,
                                ),

                                // Item 3: Joined
                                Expanded(
                                  child: _buildStatItem(
                                    "Joined",
                                    data.joinedDate, // Pastikan format tanggal sudah string pendek agar rapi
                                    Icons.verified_user_rounded,
                                    primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 3. DETAIL INFO (Email, Phone, etc)
                        SlideFadeTransition(
                          controller: _entranceController,
                          delay: 0.3,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Personal Info",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: primaryNavy,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildInfoTile(
                                  Icons.email_outlined,
                                  "Email",
                                  data.email ?? "-",
                                ),
                                _buildInfoTile(
                                  Icons.phone_outlined,
                                  "Phone",
                                  data.phone,
                                ),
                                _buildInfoTile(
                                  Icons.location_on_outlined,
                                  "Address",
                                  data.address,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 4. MENU OPTIONS
                        SlideFadeTransition(
                          controller: _entranceController,
                          delay: 0.4,
                          child: Column(
                            children: [
                              _buildMenuButton(
                                context,
                                title: "Edit Profile",
                                icon: Icons.edit_outlined,
                                color: primaryBlue,
                                onTap: () =>
                                    _openEditModal(context, request, data),
                              ),
                              const SizedBox(height: 12),
                              _buildMenuButton(
                                context,
                                title: "Friends",
                                icon: Icons.people_outline_rounded,
                                color: primaryBlue, // Purple
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) => const FriendPage(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildMenuButton(
                                context,
                                title: "Log Out",
                                icon: Icons.logout_rounded,
                                color: Colors.redAccent,
                                onTap: () =>
                                    _showLogoutConfirmation(context, request),
                                isDestructive: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildModernHeader(
    ProfileEntry data,
    BuildContext context,
    CookieRequest request,
  ) {
    return SizedBox(
      height: 280,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Background Gradient
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryNavy, const Color(0xFF1E293B)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Stack(
              children: [
                // Decorative Circle
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: accentOrange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Title
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Text(
                    "My Profile",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Profile Image
          Positioned(
            bottom: 0,
            child: BounceButton(
              onTap: () => _openEditModal(context, request, data),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _getProfileImage(data.photoUrl),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentOrange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: textGrey)),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: textGrey, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 12, color: textGrey),
                ),
                Text(
                  value.isEmpty ? "-" : value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return BounceButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.redAccent : textDark,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey.shade300,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================
// ANIMATION HELPERS
// ==========================
class SlideFadeTransition extends StatelessWidget {
  final AnimationController controller;
  final Widget child;
  final double delay; // 0.0 to 1.0 based on duration relative

  const SlideFadeTransition({
    super.key,
    required this.controller,
    required this.child,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final start = delay;
        final end = (delay + 0.4).clamp(0.0, 1.0);

        final curve = CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOutQuart),
        );

        return Opacity(
          opacity: curve.value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - curve.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class BounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const BounceButton({super.key, required this.child, required this.onTap});
  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
