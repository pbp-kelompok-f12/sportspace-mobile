import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart'; // IMPORT GOOGLE FONTS
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sportspace_app/models/profile_entry.dart';


class EditProfileSheet extends StatefulWidget {
  final CookieRequest request;
  final ProfileEntry data;
  final String baseUrl;
  final VoidCallback onSaveSuccess;

  const EditProfileSheet({
    super.key,
    required this.request,
    required this.data,
    required this.baseUrl,
    required this.onSaveSuccess,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
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

    // === FITUR PREVIEW URL ===
    // Listener ini akan me-rebuild widget setiap kali teks URL berubah
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

    try {
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

      if (mounted) {
        setState(() => _isLoading = false);
        if (response['status'] == true) {
          Navigator.pop(context);
          widget.onSaveSuccess();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Gagal menyimpan"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Terjadi kesalahan jaringan"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fungsi Helper untuk Image Preview
    ImageProvider getPreviewImage() {
      if (_photoUrlController.text.isEmpty) {
        return const AssetImage("assets/images/defaultprofile.png");
      }
      try {
        return NetworkImage(_photoUrlController.text);
      } catch (e) {
        return const AssetImage("assets/images/defaultprofile.png");
      }
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.9, // Sedikit lebih tinggi
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            "Edit Profile",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // === PREVIEW FOTO PROFIL ===
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey.shade100,
                              backgroundImage: getPreviewImage(),
                              onBackgroundImageError: (exception, stackTrace) {
                                // Fallback jika URL rusak/error handled automatically by NetworkImage usually,
                                // tapi user tetap melihat default jika invalid.
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input Fields
                    _buildCleanInput(
                      "URL Foto",
                      Icons.link,
                      _photoUrlController,
                      hint: "https://example.com/foto.jpg",
                    ),
                    _buildCleanInput(
                      "Email",
                      Icons.email_outlined,
                      _emailController,
                    ),
                    _buildCleanInput(
                      "Phone",
                      Icons.phone_android_rounded,
                      _phoneController,
                      type: TextInputType.phone,
                    ),
                    _buildCleanInput(
                      "Address",
                      Icons.location_on_outlined,
                      _addressController,
                    ),
                    _buildCleanInput(
                      "Bio",
                      Icons.person_outline,
                      _bioController,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 20), // Extra space di bawah
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "Simpan Perubahan",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanInput(
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: type,
            maxLines: maxLines,
            style: GoogleFonts.inter(),
            decoration: InputDecoration(
              hintText: hint ?? "Masukkan $label",
              hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
              prefixIcon: Icon(icon, color: Colors.grey.shade500),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF3B82F6),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
