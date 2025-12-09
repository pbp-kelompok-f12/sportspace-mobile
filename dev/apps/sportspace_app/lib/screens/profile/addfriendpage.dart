import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // Untuk jsonEncode

import 'package:sportspace_app/models/friend_entry.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  // === COLOR PALETTE ===
  final Color primaryNavy = const Color(0xFF0F172A);
  final Color primaryBlue = const Color(0xFF3B82F6);
  final Color accentOrange = const Color(0xFFF97316);
  final Color bgColor = const Color(0xFFF8FAFC);
  final Color textDark = const Color(0xFF1E293B);
  final Color textGrey = const Color(0xFF64748B);

  // === CONTROLLERS & STATE ===
  final TextEditingController _searchController = TextEditingController();
  
  // State: Search
  bool _isSearching = false;
  String? _searchMessage;
  Friend? _foundUser; 
  String _searchStatus = ""; // "friend", "pending", "found", "self"

  // State: Suggestions
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoadingSuggestions = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      _fetchSuggestions(request);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // === HELPER: GET PROFILE IMAGE ===
  ImageProvider getProfileImage(String? photoUrl) {
    if (photoUrl != null &&
        photoUrl.isNotEmpty &&
        !photoUrl.contains("/static/")) {
      return NetworkImage(photoUrl);
    }
    return const AssetImage("assets/images/defaultprofile.png");
  }

  // ==========================================
  // LOGIC 1: FETCH SUGGESTIONS
  // ==========================================
  Future<void> _fetchSuggestions(CookieRequest request) async {
    setState(() => _isLoadingSuggestions = true);
    try {
      final response = await request.get('https://sean-marcello-sportspace.pbp.cs.ui.ac.id/accounts/friends/suggestions/');
      if (response['suggestions'] != null) {
        setState(() {
          _suggestions = List<Map<String, dynamic>>.from(response['suggestions']);
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSuggestions = false);
    }
  }

  // ==========================================
  // LOGIC 2: CARI USER
  // ==========================================
  Future<void> _searchUser(CookieRequest request) async {
    final username = _searchController.text.trim();
    if (username.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchMessage = null;
      _foundUser = null;
    });

    try {
      final response = await request.post(
        "https://sean-marcello-sportspace.pbp.cs.ui.ac.id/accounts/friends/send/",
        jsonEncode({
          "username": username,
          "search_only": true, 
        }),
      );

      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          _foundUser = Friend.fromJson(response); 
          _searchStatus = response['status'];
        });
      } else {
        setState(() => _searchMessage = response['message'] ?? "User tidak ditemukan.");
      }
    } catch (e) {
      setState(() => _searchMessage = "Gagal terhubung ke server.");
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  // ==========================================
  // LOGIC 3: KIRIM REQUEST (DIPERBARUI)
  // ==========================================
  Future<void> _sendRequest(String username, CookieRequest request) async {
    try {
      final response = await request.post(
        "https://sean-marcello-sportspace.pbp.cs.ui.ac.id/accounts/friends/send/",
        jsonEncode({"username": username}),
      );

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Permintaan dikirim ke $username"), 
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // === UPDATE LOGIC: SINKRONISASI ===
        setState(() {
          // 1. Update status di HASIL PENCARIAN (jika user yang dicari sama)
          if (_foundUser != null && _foundUser!.username == username) {
            _searchStatus = "pending";
          }

          // 2. Update status di LIST SUGGESTION (cari index berdasarkan username)
          int indexInList = _suggestions.indexWhere((user) => user['username'] == username);
          if (indexInList != -1) {
            _suggestions[indexInList]['status_local'] = 'pending';
          }
        });
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Gagal."), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan koneksi.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Tambahkan Teman", 
          style: GoogleFonts.poppins(color: primaryNavy, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryNavy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === SEARCH BAR SECTION ===
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.search, color: textGrey.withOpacity(0.6)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Cari username...",
                          hintStyle: GoogleFonts.inter(color: textGrey.withOpacity(0.5)),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _searchUser(request),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _searchUser(request),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryNavy,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // === HASIL PENCARIAN (SEARCH RESULT) ===
              if (_isSearching)
                 Center(child: CircularProgressIndicator(color: accentOrange))
              else if (_searchMessage != null)
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: textGrey.withOpacity(0.3)),
                      const SizedBox(height: 8),
                      Text(_searchMessage!, style: GoogleFonts.inter(color: Colors.red)),
                    ],
                  ),
                )
              else if (_foundUser != null)
                _buildSearchResultCard(request),

              const SizedBox(height: 30),
              
              // === HEADER SUGGESTIONS ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Saran Teman", 
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: primaryNavy)
                  ),
                  TextButton.icon(
                    onPressed: () => _fetchSuggestions(request),
                    icon: Icon(Icons.refresh_rounded, size: 16, color: accentOrange),
                    label: Text("Muat Ulang", 
                      style: GoogleFonts.inter(color: accentOrange, fontWeight: FontWeight.w600, fontSize: 13)
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),

              // === LIST SUGGESTIONS (VERTIKAL) ===
              if (_isLoadingSuggestions)
                 const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else if (_suggestions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200)
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.group_off_outlined, size: 40, color: textGrey.withOpacity(0.4)),
                      const SizedBox(height: 8),
                      Text("Tidak ada saran saat ini.", style: GoogleFonts.inter(color: textGrey)),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true, 
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _suggestions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = _suggestions[index];
                    return _buildSuggestionListTile(user, index, request);
                  },
                ),
                
               const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // === WIDGET 1: HASIL PENCARIAN (CARD BESAR) ===
  Widget _buildSearchResultCard(CookieRequest request) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryNavy.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0C2D57).withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: bgColor,
                  backgroundImage: getProfileImage(_foundUser!.photoUrl),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_foundUser!.username, 
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _foundUser!.bio.isNotEmpty ? _foundUser!.bio : "Pengguna SportSpace",
                      style: GoogleFonts.inter(fontSize: 13, color: textGrey),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActionButton(_searchStatus, _foundUser!.username, request, isFullWidth: true),
        ],
      ),
    );
  }

  // === WIDGET 2: SUGGESTION ITEM (LIST TILE VERTIKAL) ===
  Widget _buildSuggestionListTile(Map<String, dynamic> user, int index, CookieRequest request) {
    String status = user['status_local'] ?? 'found'; // Status lokal

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Foto
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image(
              image: getProfileImage(user['photo_url']?.toString()),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(width: 50, height: 50, color: Colors.grey.shade200, child: const Icon(Icons.person)),
            ),
          ),
          const SizedBox(width: 14),
          
          // Nama & Bio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['username'], 
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: textDark, fontSize: 15)
                ),
                Text(
                  user['bio'] ?? "Saran Teman",
                  style: GoogleFonts.inter(fontSize: 12, color: textGrey),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Tombol Aksi (Kecil di kanan)
          status == 'pending'
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text("Pending", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textGrey)),
              )
            : ElevatedButton(
                // KITA TIDAK PERLU PARAMETER index/isSuggestion lagi karena logic sudah digabung
                onPressed: () => _sendRequest(user['username'], request),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange.withOpacity(0.1),
                  foregroundColor: accentOrange,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_add_alt_1_rounded, size: 16),
                    const SizedBox(width: 6),
                    Text("Add", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  // === HELPER: ACTION BUTTON BUILDER ===
  Widget _buildActionButton(String status, String username, CookieRequest request, {bool isFullWidth = false}) {
    Widget buttonContent;
    Color btnColor;
    Color txtColor;
    VoidCallback? onPressed;

    if (status == "friend") {
      buttonContent = const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, size: 18), SizedBox(width: 8), Text("Sudah Berteman")]);
      btnColor = Colors.green.withOpacity(0.1);
      txtColor = Colors.green;
      onPressed = null;
    } else if (status == "pending") {
      buttonContent = const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.hourglass_empty, size: 18), SizedBox(width: 8), Text("Menunggu Konfirmasi")]);
      btnColor = Colors.grey.shade100;
      txtColor = Colors.grey;
      onPressed = null;
    } else if (status == "self") {
      buttonContent = const Text("Ini Profil Kamu");
      btnColor = primaryBlue.withOpacity(0.1);
      txtColor = primaryBlue;
      onPressed = null;
    } else {
      buttonContent = const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.person_add, size: 18), SizedBox(width: 8), Text("Kirim Permintaan")]);
      btnColor = accentOrange;
      txtColor = Colors.white;
      onPressed = () => _sendRequest(username, request);
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          foregroundColor: txtColor,
          disabledBackgroundColor: btnColor,
          disabledForegroundColor: txtColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        child: buttonContent,
      ),
    );
  }
}