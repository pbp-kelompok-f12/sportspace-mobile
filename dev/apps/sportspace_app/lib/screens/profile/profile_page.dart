import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";
  late Future<ProfileEntry> _profileFuture;

  // === PALET WARNA (Sesuai MatchmakingListPage) ===
  static const Color primaryNavy = Color(0xFF0D2C3E);
  static const Color softOrange = Color(0xFFFF9F45);
  static const Color softOrangeDark = Color(0xFFF97316);
  static const Color backgroundGrey = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGrey = Color(0xFF64748B);

  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _profileFuture = fetchProfile(request);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
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

  void _showLogoutConfirmation(BuildContext parentContext, CookieRequest request) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Logout",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: primaryNavy)),
          content: Text("Apakah Anda yakin ingin keluar?",
              style: GoogleFonts.poppins(color: textGrey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Batal",
                  style: GoogleFonts.poppins(color: textGrey, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                final response =
                    await request.logout("$baseUrl/accounts/logout-flutter/");
                if (!parentContext.mounted) return;
                if (response['status'] == true) {
                  Navigator.pushAndRemoveUntil(
                    parentContext,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              child: Text("Keluar",
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _openEditModal(
      BuildContext context, CookieRequest request, ProfileEntry data) {
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
              content: Text("Profil berhasil diperbarui!",
                  style: GoogleFonts.poppins()),
              backgroundColor: primaryNavy,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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
      backgroundColor: backgroundGrey, // Menggunakan background grey yang sama
      body: FutureBuilder<ProfileEntry>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: softOrangeDark));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text("Gagal memuat profil",
                    style: GoogleFonts.poppins(color: Colors.red)));
          }
          if (snapshot.hasData) {
            final data = snapshot.data!;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildModernHeader(data, context, request),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        SlideFadeTransition(
                          controller: _entranceController,
                          delay: 0.1,
                          child: Column(
                            children: [
                              Text(
                                data.username,
                                style: GoogleFonts.poppins(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: primaryNavy,
                                    letterSpacing: 0.5),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 6, bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: softOrange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: softOrange.withOpacity(0.5)),
                                ),
                                child: Text(
                                  data.role.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: softOrangeDark,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  data.bio.isEmpty
                                      ? "Belum ada bio."
                                      : data.bio,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: textGrey,
                                      height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SlideFadeTransition(
                          controller: _entranceController,
                          delay: 0.2,
                          child: _buildStatCard(data),
                        ),
                        const SizedBox(height: 24),
                        SlideFadeTransition(
                          controller: _entranceController,
                          delay: 0.3,
                          child: _buildPersonalInfoCard(data),
                        ),
                        const SizedBox(height: 24),
                        SlideFadeTransition(
                          controller: _entranceController,
                          delay: 0.4,
                          child: _buildMenuOptions(context, request, data),
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

  Widget _buildModernHeader(
      ProfileEntry data, BuildContext context, CookieRequest request) {
    return SizedBox(
      height: 280,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // ORANGE GRADIENT HEADER (Sama seperti MatchmakingListPage)
          Container(
            height: 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [softOrange, softOrangeDark],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Text(
                    "My Profile",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
          // PROFILE IMAGE
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
                            color: primaryNavy.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10))
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
                          color: primaryNavy, // Navy Icon
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3)),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 18),
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

  Widget _buildStatCard(ProfileEntry data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: primaryNavy.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Expanded(
              child: _buildStatItem("Booking", data.totalBooking.toString(),
                  Icons.calendar_month_rounded, softOrangeDark)),
          _buildDivider(),
          Expanded(
              child: _buildStatItem(
                  "Rating",
                  data.avgRating == 0 ? "-" : data.avgRating.toString(),
                  Icons.star_rounded,
                  softOrangeDark)), // Menggunakan Orange agar konsisten
          _buildDivider(),
          Expanded(
              child: _buildStatItem(
                  "Joined", data.joinedDate, Icons.verified_user_rounded, primaryNavy)),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      Container(height: 40, width: 1, color: Colors.grey.shade200);

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryNavy)),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 12, color: textGrey)),
      ],
    );
  }

  Widget _buildPersonalInfoCard(ProfileEntry data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: primaryNavy.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Personal Info",
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: primaryNavy)),
          const SizedBox(height: 20),
          _buildInfoTile(Icons.email_outlined, "Email", data.email ?? "-"),
          _buildInfoTile(Icons.phone_outlined, "Phone", data.phone),
          _buildInfoTile(Icons.location_on_outlined, "Address", data.address),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: softOrange.withOpacity(0.1), // Background Orange tipis
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: softOrangeDark, size: 22), // Icon Orange
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(fontSize: 12, color: textGrey)),
                const SizedBox(height: 2),
                Text(value.isEmpty ? "-" : value,
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions(
      BuildContext context, CookieRequest request, ProfileEntry data) {
    return Column(
      children: [
        _buildMenuButton(context,
            title: "Edit Profile",
            icon: Icons.edit_outlined,
            color: primaryNavy, // Icon Navy
            onTap: () => _openEditModal(context, request, data)),
        const SizedBox(height: 12),
        _buildMenuButton(context,
            title: "Friends",
            icon: Icons.people_outline_rounded,
            color: primaryNavy, // Icon Navy
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (c) => const FriendPage()))),
        const SizedBox(height: 12),
        _buildMenuButton(context,
            title: "Log Out",
            icon: Icons.logout_rounded,
            color: Colors.red.shade400,
            onTap: () => _showLogoutConfirmation(context, request),
            isDestructive: true),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap,
      bool isDestructive = false}) {
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
                offset: const Offset(0, 4))
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? Colors.red.shade400 : primaryNavy)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade300, size: 16),
          ],
        ),
      ),
    );
  }
}

// ANIMATION HELPERS (Tetap Sama)
class SlideFadeTransition extends StatelessWidget {
  final AnimationController controller;
  final Widget child;
  final double delay;

  const SlideFadeTransition(
      {super.key,
      required this.controller,
      required this.child,
      this.delay = 0});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final curve = CurvedAnimation(
            parent: controller,
            curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0),
                curve: Curves.easeOutQuart));
        return Opacity(
            opacity: curve.value,
            child: Transform.translate(
                offset: Offset(0, 50 * (1 - curve.value)), child: child));
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
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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