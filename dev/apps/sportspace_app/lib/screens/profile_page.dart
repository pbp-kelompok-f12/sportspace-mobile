import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// GANTI IMPORT INI SESUAI STRUKTUR PROJECT ANDA
import 'package:sportspace_app/models/profile_entry.dart';
import 'package:sportspace_app/screens/login.dart';
import 'package:sportspace_app/screens/friendspage.dart';

// ==========================
// 1. STATEFUL WIDGET UTAMA
// ==========================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // URL SERVER UTAMA ANDA
  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";

  late Future<ProfileEntry> _profileFuture;

  // Palet Warna Original (Biru)
  final Color primaryBlue = const Color(0xFF0D47A1);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color lightOrange = const Color(0xFFFFF3E0);

  // Palet Warna Header Baru (Oranye)
  final Color orangePrimary = const Color(0xFFFF6F00);

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _profileFuture = fetchProfile(request);
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

  // ==========================
  // MODAL EDIT PROFILE
  // ==========================
  void _openEditModal(
    BuildContext context,
    CookieRequest request,
    ProfileEntry data,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return EditProfileDialog(
          request: request,
          data: data,
          baseUrl: baseUrl,
          onSaveSuccess: () {
            refreshProfile();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Profil berhasil diperbarui!"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context, CookieRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text(
                'Ya, Keluar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.pop(context);
                final response = await request.logout(
                  "$baseUrl/accounts/logout-flutter/",
                );
                if (context.mounted) {
                  if (response['status']) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return BaseBackground(
      // Tetap menggunakan Background Padel Original
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<ProfileEntry>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              final ProfileEntry data = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 60,
                ),
                child: Center(
                  child: Container(
                    // Container Putih Utama (Card)
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 20,
                          spreadRadius: 5,
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ],
                    ),
                    // ClipRRect agar header oranye mengikuti sudut rounded card
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Column(
                            children: [
                              _buildHeaderSection(
                                context,
                                request,
                                data,
                              ), // BAGIAN ORANYE DISINI
                              _buildBodySection(
                                context,
                                request,
                                data,
                              ), // BAGIAN DATA ORIGINAL
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  // ==========================
  // HEADER BARU (ORANYE GEOMETRIS)
  // ==========================
  Widget _buildHeaderSection(
    BuildContext context,
    CookieRequest request,
    ProfileEntry data,
  ) {
    return SizedBox(
      height: 200, // Tinggi area header
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Background Oranye Geometris
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160, // Background hanya mengisi separuh atas
            child: _buildGeometricBackground(),
          ),

          // 3. Foto Profil dengan Border Putih Tebal
          Positioned(
            bottom: 0,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 5,
                    ), // Border Putih Tebal
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _getProfileImage(data.photoUrl),
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                // Tombol Edit Kecil
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: InkWell(
                    onTap: () => _openEditModal(context, request, data),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: orangePrimary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Background Geometris
  Widget _buildGeometricBackground() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [orangePrimary, Colors.orange.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -40,
          right: -40,
          child: Transform.rotate(
            angle: -0.5,
            child: Container(
              width: 500,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: SizedBox(
            width: 300,
            height: 130,
            child: CustomPaint(painter: DiagonalShapePainter()),
          ),
        ),
      ],
    );
  }

  // ==========================
  // BODY SECTION (STYLE ORIGINAL / BIRU)
  // ==========================
  Widget _buildBodySection(
    BuildContext context,
    CookieRequest request,
    ProfileEntry data,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: Column(
        children: [
          Text(
            data.username,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryBlue, // Tetap Biru sesuai original
            ),
          ),
          Text(
            data.role,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.bio,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              children: [
                _infoRow("Email", data.email ?? "-"),
                _infoRow("No Telepon", data.phone),
                _infoRow("Alamat", data.address),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFFDBDBDB), thickness: 1),
          const SizedBox(height: 16),

          // STATISTIK (Tetap Biru Original)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem("Total Booking", data.totalBooking.toString()),
                _buildVerticalDivider(),
                _buildStatItem(
                  "Rating",
                  data.avgRating == 0 ? "-" : data.avgRating.toString(),
                ),
                _buildVerticalDivider(),
                _buildStatItem("Bergabung", (data.joinedDate)),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // MENU (Tetap Style Original)
          Column(
            children: [
              _buildMenuItem(
                context,
                icon: Icons.person_outline,
                text: "Edit Profile",
                iconBgColor: lightBlue,
                iconColor: primaryBlue,
                onTap: () => _openEditModal(context, request, data),
              ),
              const SizedBox(height: 12),
              _buildMenuItem(
                context,
                icon: Icons.people_outline,
                text: "Teman",
                iconBgColor: lightBlue,
                iconColor: primaryBlue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FriendsPage()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildMenuItem(
                context,
                icon: Icons.logout_rounded,
                text: "Log Out",
                isLogout: true,
                iconBgColor: lightOrange,
                iconColor: Colors.red,
                onTap: () => _showLogoutConfirmation(context, request),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================
  // WIDGET HELPER
  // ==========================
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color iconBgColor,
    required Color iconColor,
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade100),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isLogout ? Colors.red[400] : const Color(0xFF2C3E50),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const Text(" : ", style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================
// BACKGROUND UTAMA (ORIGINAL / PADEL)
// ==========================
class BaseBackground extends StatelessWidget {
  final Widget child;
  const BaseBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: Image.asset(
            "assets/images/padelbackground.jpg",
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: Colors.grey),
          ),
        ),
        IgnorePointer(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(0, 43, 79, 0.7),
                  Color.fromRGBO(0, 105, 192, 0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

// ==========================
// PAINTER UNTUK HEADER ORANYE
// ==========================
class DiagonalShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================
// CLASS MODAL EDIT PROFILE
// ==========================
class EditProfileDialog extends StatefulWidget {
  final CookieRequest request;
  final ProfileEntry data;
  final String baseUrl;
  final VoidCallback onSaveSuccess;

  const EditProfileDialog({
    super.key,
    required this.request,
    required this.data,
    required this.baseUrl,
    required this.onSaveSuccess,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _photoUrlController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.data.email ?? "");
    _phoneController = TextEditingController(text: widget.data.phone);
    _addressController = TextEditingController(text: widget.data.address);
    _photoUrlController = TextEditingController(text: widget.data.photoUrl);
    _bioController = TextEditingController(text: widget.data.bio);
    _photoUrlController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _photoUrlController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final response = await widget.request.postJson(
      "${widget.baseUrl}/accounts/edit-profile-flutter/",
      jsonEncode(<String, String>{
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'photo_url': _photoUrlController.text,
        'bio': _bioController.text,
      }),
    );
    setState(() => _isLoading = false);
    if (mounted) {
      if (response['status'] == true) {
        Navigator.pop(context);
        widget.onSaveSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Gagal update profile."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _photoUrlController.text.isNotEmpty
                              ? NetworkImage(_photoUrlController.text)
                              : const AssetImage(
                                      "assets/images/defaultprofile.png",
                                    )
                                    as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildFancyField(
                        _photoUrlController,
                        "URL Foto Profil",
                        Icons.link,
                        hint: "https://...",
                      ),
                      _buildFancyField(
                        _emailController,
                        "Email",
                        Icons.email_outlined,
                        type: TextInputType.emailAddress,
                      ),
                      _buildFancyField(
                        _phoneController,
                        "Nomor Telepon",
                        Icons.phone_android_rounded,
                        type: TextInputType.phone,
                      ),
                      _buildFancyField(
                        _addressController,
                        "Alamat",
                        Icons.location_on_outlined,
                      ),
                      _buildFancyField(
                        _bioController,
                        "Bio",
                        Icons.person_outline,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Simpan Perubahan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFancyField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        validator: (v) => v!.isEmpty ? '$label tidak boleh kosong' : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
          filled: true,
          fillColor: Colors.grey[50],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
          ),
        ),
      ),
    );
  }
}
