import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/match_entry.dart';
import 'match_detail_page.dart';
import 'create_1v1_page.dart';
import 'create_2v2_page.dart';

class MatchmakingListPage extends StatefulWidget {
  const MatchmakingListPage({super.key});

  @override
  State<MatchmakingListPage> createState() => _MatchmakingListPageState();
}

class _MatchmakingListPageState extends State<MatchmakingListPage> {
  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";
  String _filter = "all";

  // Palette Warna (Premium Design)
  static const Color primaryNavy = Color(0xFF0D2C3E);
  static const Color softOrange = Color(0xFFFF9F45);
  static const Color softOrangeDark = Color(0xFFF97316);
  static const Color backgroundGrey = Color(0xFFF8FAFC);

  Future<List<MatchEntry>> fetchMatches(CookieRequest request) async {
    final response = await request.get('$baseUrl/matchmaking/json/');
    List<MatchEntry> matches =
        response.map<MatchEntry>((e) => MatchEntry.fromJson(e)).toList();

    if (_filter == "yours") {
      matches = matches
          .where((m) => m.isUserCreator || m.isUserRegistered)
          .toList();
    }
    return matches;
  }

  Future<void> _handleJoin(CookieRequest request, int matchId) async {
    final response = await request.post("$baseUrl/matchmaking/join-flutter/$matchId/", {});
    
    if (response['status'] == 'success') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil join match!"), backgroundColor: Colors.green),
        );
      }
      setState(() {});
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Gagal join"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleDelete(CookieRequest request, int matchId) async {
    final response = await request.post("$baseUrl/matchmaking/delete-flutter/$matchId/", {});
    
    if (response['status'] == 'success') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Match berhasil dihapus."), backgroundColor: Colors.green),
        );
      }
      setState(() {});
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Gagal menghapus"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _reloadFilter(String filter) {
    setState(() => _filter = filter);
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: Column(
        children: [
          // HEADER GRADIENT
          Container(
            padding: const EdgeInsets.only(bottom: 24, top: 60, left: 20, right: 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [softOrange, softOrangeDark],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
              ],
            ),
            child: Column(
              children: [
                Text(
                  "Matchmaking",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Temukan lawan tandingmu!",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // FILTER & ACTION BUTTONS
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFilterChip("Semua Match", "all"),
                    const SizedBox(width: 12),
                    _buildFilterChip("Match Anda", "yours"),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        label: "Create 1v1",
                        icon: Icons.person,
                        color: primaryNavy,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const Create1v1Page()))
                              .then((_) => setState(() {}));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        label: "Create 2v2",
                        icon: Icons.group,
                        color: primaryNavy,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const Create2v2Page()))
                              .then((_) => setState(() {}));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // LIST MATCH
          Expanded(
            child: FutureBuilder<List<MatchEntry>>(
              future: fetchMatches(request),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sports_tennis_rounded, size: 80, color: Colors.black12),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada match tersedia.",
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final matches = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 40, top: 8, left: 16, right: 16),
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      return _buildMatchCard(context, request, matches[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      labelStyle: GoogleFonts.poppins(
        color: selected ? Colors.white : primaryNavy,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      selected: selected,
      selectedColor: primaryNavy,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: primaryNavy.withOpacity(0.2)),
      ),
      onSelected: (_) => _reloadFilter(value),
    );
  }

  Widget _buildActionButton(BuildContext context, {required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: color.withOpacity(0.4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, CookieRequest request, MatchEntry m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // HEADER CARD (NAVY)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: primaryNavy,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  m.modeDisplay,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                // STATUS DENGAN IKON GEMBOK & WARNA
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: m.isFull 
                        ? Colors.red.withOpacity(0.2) 
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: m.isFull ? Colors.red.shade400 : Colors.green.shade400,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        m.isFull ? Icons.lock_rounded : Icons.lock_open_rounded,
                        size: 14,
                        color: m.isFull ? Colors.red.shade100 : Colors.green.shade100,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        m.isFull ? "FULL" : "OPEN",
                        style: GoogleFonts.poppins(
                          fontSize: 10, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          // BODY CARD
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Dibuat Oleh", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.account_circle, size: 18, color: primaryNavy),
                              const SizedBox(width: 6),
                              Text(
                                m.createdByUsername,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Pemain", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: backgroundGrey,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300)
                          ),
                          child: Text(
                            "${m.playerCount}/${m.maxPlayers}",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryNavy),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (m.isUserRegistered)
                      Chip(
                        label: Text("Terdaftar", style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                        backgroundColor: Colors.green,
                        avatar: const Icon(Icons.check, color: Colors.white, size: 16),
                      )
                    else if (m.canUserJoin && !m.isUserCreator)
                      _buildSmallActionBtn(
                        label: "Join",
                        color: Colors.green[600]!,
                        icon: Icons.add_circle_outline,
                        onTap: () => _handleJoin(request, m.id),
                      ),
                    _buildSmallActionBtn(
                      label: "Detail",
                      color: Colors.blue[600]!,
                      icon: Icons.info_outline,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => MatchDetailPage(matchId: m.id),
                        ));
                      },
                    ),
                    if (m.isUserCreator)
                      _buildSmallActionBtn(
                        label: "Hapus",
                        color: Colors.red[600]!,
                        icon: Icons.delete_outline,
                        onTap: () => _handleDelete(request, m.id),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallActionBtn({required String label, required Color color, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5))
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}