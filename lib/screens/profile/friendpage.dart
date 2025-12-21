import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// === IMPORT MODEL ===
// Pastikan path ini sesuai dengan struktur folder Anda
import 'package:sportspace_app/models/friend_entry.dart';
// import 'package:sportspace_app/models/friend_request.dart'; // Uncommented
import 'package:sportspace_app/screens/profile/addfriendpage.dart';
import 'package:sportspace_app/screens/profile/chatpage.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  // === COLOR PALETTE ===
  final Color primaryNavy = const Color(0xFF0F172A);
  final Color primaryBlue = const Color(0xFF3B82F6);
  final Color accentOrange = const Color(0xFFF97316);
  final Color bgColor = const Color(0xFFF8FAFC);
  final Color surfaceColor = Colors.white;
  final Color textDark = const Color(0xFF1E293B);
  final Color textGrey = const Color(0xFF64748B);
  final Color dangerRed = const Color(0xFFEF4444);

  // === STATE VARIABLES ===
  TextEditingController searchController = TextEditingController();

  List<Friend> _allFriends = [];
  List<Friend> _filteredFriends = [];
  bool _isLoadingFriends = true;

  List<FriendRequest> _friendRequests = [];
  bool _isLoadingRequests = true;

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final request = context.read<CookieRequest>();
      _refreshData(request);
      _isInit = false;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // === REFRESH DATA ===
  void _refreshData(CookieRequest request) {
    if (mounted) {
      _fetchRequests(request);
      _fetchFriendsManual(request);
    }
  }

  // === FETCH REQUESTS ===
  Future<void> _fetchRequests(CookieRequest request) async {
    if (mounted) setState(() => _isLoadingRequests = true);

    try {
      final response = await request.get(
          'https://sean-marcello-sportspace.pbp.cs.ui.ac.id/accounts/friend-requests/');

      if (!mounted) return;

      // SAFETY: Gunakan list kosong jika 'requests' null
      List<dynamic> listJson = response['requests'] ?? []; 
      setState(() {
        _friendRequests =
            listJson.map((d) => FriendRequest.fromJson(d)).toList();
        _isLoadingRequests = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _friendRequests = [];
        _isLoadingRequests = false;
      });
      print("Error fetching requests: $e");
    }
  }

  // === FETCH FRIENDS ===
  Future<void> _fetchFriendsManual(CookieRequest request) async {
    if (mounted) setState(() => _isLoadingFriends = true);

    try {
      final response = await request.get(
          'https://sean-marcello-sportspace.pbp.cs.ui.ac.id/accounts/friends/');

      if (!mounted) return;

      // SAFETY: Gunakan list kosong jika 'friends' null
      List<dynamic> listJson = response['friends'] ?? [];
      List<Friend> data = listJson.map((d) => Friend.fromJson(d)).toList();

      setState(() {
        _allFriends = data;
        _filteredFriends = data;
        _isLoadingFriends = false;
      });
      // Jalankan filter ulang jika ada text di search bar
      if (searchController.text.isNotEmpty) {
        _runFilter(searchController.text);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _allFriends = [];
        _filteredFriends = [];
        _isLoadingFriends = false;
      });
      print("Error fetching friends: $e");
    }
  }

  void _runFilter(String keyword) {
    List<Friend> results = [];
    if (keyword.isEmpty) {
      results = _allFriends;
    } else {
      results = _allFriends
          .where((user) =>
              user.username.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _filteredFriends = results;
    });
  }

  // === LOGIC: UNFRIEND ===
  Future<void> _handleUnfriend(Friend friend) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Hapus Teman?",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Yakin ingin menghapus ${friend.username}?",
            style: GoogleFonts.inter(color: textGrey)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: dangerRed, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final request = context.read<CookieRequest>();
      try {
        final response = await request.post(
          "https://sean-marcello-sportspace.pbp.cs.ui.ac.id/accounts/unfriend/",
          {"username": friend.username},
        );

        if (!mounted) return;

        if (response['success'] == true) {
          _fetchFriendsManual(request);
          _showSnack("Berhasil menghapus teman.", const Color(0xFF10B981));
        } else {
           _showSnack("Gagal menghapus teman.", dangerRed);
        }
      } catch (e) {
        if (mounted) _showSnack("Gagal terhubung ke server.", dangerRed);
      }
    }
  }

  // === LOGIC: RESPOND REQUEST ===
  Future<bool> _respondRequest(
      FriendRequest req, bool isAccept, CookieRequest request) async {
    final action = isAccept ? "accept" : "reject";
    try {
      final response = await request.post(
        "https://sean-marcello-sportspace.pbp.cs.ui.ac.id/accounts/handle-friend-request/",
        {
          "action": action,
          "from_user_id": req.fromUser.id.toString(),
        },
      );

      if (!mounted) return false;

      if (response['success'] == true) {
        _fetchFriendsManual(request);
        _fetchRequests(request);
        return true;
      } else {
        _showSnack(response['message'] ?? "Gagal.", dangerRed);
        return false;
      }
    } catch (e) {
      if (mounted) _showSnack("Gagal terhubung.", dangerRed);
      return false;
    }
  }

  // === SHOW MODAL ===
  void _showRequestsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Permintaan Pertemanan",
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryNavy)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: dangerRed,
                              borderRadius: BorderRadius.circular(12)),
                          child: Text("${_friendRequests.length}",
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: _friendRequests.isEmpty
                        ? Center(
                            child: Text("Tidak ada permintaan baru.",
                                style: GoogleFonts.inter(color: textGrey)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _friendRequests.length,
                            itemBuilder: (context, index) {
                              final req = _friendRequests[index];
                              return _buildRequestCard(req, (isAccept) async {
                                final request = context.read<CookieRequest>();
                                bool success = await _respondRequest(
                                    req, isAccept, request);

                                if (success) {
                                  setModalState(() {
                                    _friendRequests.removeAt(index);
                                  });
                                  if (_friendRequests.isEmpty &&
                                      context.mounted) Navigator.pop(context);
                                }
                              });
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSnack(String msg, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // 1. APP BAR
          SliverAppBar(
            expandedHeight: 100.0,
            pinned: true,
            backgroundColor: surfaceColor,
            elevation: 0,
            leadingWidth: 50,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: primaryNavy, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
              expandedTitleScale: 1.5,
              title: Text("Daftar Teman",
                  style: GoogleFonts.poppins(
                      color: primaryNavy,
                      fontWeight: FontWeight.w700,
                      fontSize: 20)),
            ),
          ),

          // 2. SEARCH BAR & ADD BUTTON
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) => _runFilter(value),
                        decoration: InputDecoration(
                          hintText: "Cari teman...",
                          hintStyle: GoogleFonts.inter(
                              color: textGrey.withOpacity(0.5)),
                          prefixIcon: Icon(Icons.search,
                              color: textGrey.withOpacity(0.5)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // TOMBOL ADD FRIEND (Pengganti FAB, Aman dari Hero Error)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => const AddFriendPage()))
                          .then((_) => _refreshData(request));
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [accentOrange, const Color(0xFFFB923C)]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: accentOrange.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: const Icon(Icons.person_add_alt_1_rounded,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. REQUEST NOTIFICATION BANNER
          if (!_isLoadingRequests && _friendRequests.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: InkWell(
                  onTap: () => _showRequestsModal(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accentOrange.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                            color: accentOrange.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: accentOrange.withOpacity(0.1),
                              shape: BoxShape.circle),
                          child: Icon(Icons.notifications_active_rounded,
                              color: accentOrange, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Permintaan Pertemanan",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: textDark)),
                              Text(
                                  "Kamu memiliki ${_friendRequests.length} permintaan baru",
                                  style: GoogleFonts.inter(
                                      fontSize: 12, color: textGrey)),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 16, color: textGrey),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 4. TITLE "All Friends"
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Text("Teman Saya",
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryNavy)),
                  const SizedBox(width: 6),
                  if (!_isLoadingFriends)
                    Text("(${_allFriends.length})",
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textGrey)),
                ],
              ),
            ),
          ),

          // 5. FRIENDS LIST
          if (_isLoadingFriends)
            const SliverToBoxAdapter(
                child: Center(
                    child: Padding(
                        padding: EdgeInsets.all(30),
                        child: CircularProgressIndicator())))
          else if (_filteredFriends.isEmpty)
            SliverToBoxAdapter(
                child: _buildEmptyState(
                    message: searchController.text.isNotEmpty
                        ? "Tidak ditemukan"
                        : "Belum ada teman"))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildModernFriendCard(_filteredFriends[index]),
                childCount: _filteredFriends.length,
              ),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  // === HELPER UI ===

  Widget _buildRequestCard(FriendRequest req, Function(bool) onRespond) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: bgColor,
                backgroundImage: (req.fromUser.photoUrl.isNotEmpty)
                    ? NetworkImage(req.fromUser.photoUrl)
                    : const AssetImage("assets/images/defaultprofile.png")
                        as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req.fromUser.username,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700, color: textDark)),
                    Text(
                        req.fromUser.bio.isNotEmpty
                            ? req.fromUser.bio
                            : "Ingin berteman!",
                        style: GoogleFonts.inter(
                            color: textGrey, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => onRespond(true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryNavy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10)),
                  child: const Text("Confirm"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onRespond(false),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: textDark,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10)),
                  child: const Text("Reject"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildModernFriendCard(Friend friend) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          // Navigasi ke Chat dengan animasi Hero (Opsional)
          GestureDetector(
             onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ChatPage(friend: friend))),
             child: CircleAvatar(
              radius: 26,
              backgroundImage: (friend.photoUrl.isNotEmpty &&
                      !friend.photoUrl.contains("/static/"))
                  ? NetworkImage(friend.photoUrl)
                  : const AssetImage("assets/images/defaultprofile.png")
                      as ImageProvider,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(friend.username,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, color: textDark)),
                Text(
                    friend.bio.isNotEmpty ? friend.bio : "Teman SportSpace",
                    style: GoogleFonts.inter(color: textGrey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.chat_bubble_outline_rounded, color: primaryBlue),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (c) => ChatPage(friend: friend))),
          ),
          IconButton(
            icon: Icon(Icons.person_remove_rounded, color: dangerRed),
            onPressed: () => _handleUnfriend(friend),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState({required String message}) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.people_outline_rounded,
                size: 60, color: textGrey.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(message,
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textGrey)),
          ],
        ),
      ),
    );
  }
}