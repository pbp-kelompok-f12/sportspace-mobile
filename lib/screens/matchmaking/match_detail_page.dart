import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../../models/match_entry.dart';

class MatchDetailPage extends StatefulWidget {
  final int matchId;
  const MatchDetailPage({super.key, required this.matchId});

  @override
  State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";
  late Future<MatchEntry> futureMatch;

  // === DESIGN PALETTE ===
  static const Color primaryNavy = Color(0xFF0D2C3E);
  static const Color softOrange = Color(0xFFFF9F45);
  static const Color softOrangeDark = Color(0xFFF97316);
  static const Color backgroundGrey = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGrey = Color(0xFF64748B);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    futureMatch = fetchMatch();
  }

  Future<MatchEntry> fetchMatch() async {
    final request = context.read<CookieRequest>();
    final res = await request.get('$baseUrl/matchmaking/json/${widget.matchId}/');
    return MatchEntry.fromJson(res);
  }

  Future<void> joinMatch() async {
    final request = context.read<CookieRequest>();
    await request.post(
      '$baseUrl/matchmaking/join/${widget.matchId}/',
      {},
    );
    setState(() => futureMatch = fetchMatch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryNavy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Detail Match",
          style: GoogleFonts.poppins(
            color: primaryNavy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: FutureBuilder<MatchEntry>(
        future: futureMatch,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: softOrangeDark));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}", style: GoogleFonts.poppins(color: Colors.red)),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: Text("Data match tidak tersedia", style: GoogleFonts.poppins(color: textGrey)),
            );
          }

          final m = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER CARD ---
                      _buildMainCard(m),
                      
                      const SizedBox(height: 24),

                      // --- PLAYER LIST SECTION ---
                      Row(
                        children: [
                          const Icon(Icons.people_alt_rounded, color: primaryNavy, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Daftar Pemain",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryNavy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // List of players
                      ...m.playerUsernames.map((username) => _buildPlayerTile(username, false)),
                      
                      if (m.tempTeammate != null)
                        _buildPlayerTile(m.tempTeammate!, true),
                    ],
                  ),
                ),
              ),

              // --- BOTTOM ACTION BUTTON ---
              _buildBottomAction(m),
            ],
          );
        },
      ),
    );
  }

  // === WIDGET COMPONENTS ===

  Widget _buildMainCard(MatchEntry m) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                m.modeDisplay,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: primaryNavy,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: softOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${m.playerCount}/${m.maxPlayers}",
                  style: GoogleFonts.poppins(
                    color: softOrangeDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          _buildInfoItem(Icons.location_on_outlined, "Lokasi Lapangan", m.createdByUsername),
          const SizedBox(height: 16),
          _buildInfoItem(Icons.verified_user_outlined, "Dibuat Oleh", m.createdByUsername),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: softOrangeDark, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 11, color: textGrey)),
            Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: textDark)),
          ],
        )
      ],
    );
  }

  Widget _buildPlayerTile(String username, bool isGuest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: primaryNavy.withOpacity(0.1),
            child: const Icon(Icons.person, size: 16, color: primaryNavy),
          ),
          const SizedBox(width: 12),
          Text(
            username,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: textDark),
          ),
          if (isGuest) ...[
            const Spacer(),
            Text(
              "Teman",
              style: GoogleFonts.poppins(fontSize: 11, color: textGrey, fontStyle: FontStyle.italic),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildBottomAction(MatchEntry m) {
    bool canJoin = m.canUserJoin && !m.isFull;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: canJoin ? joinMatch : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: softOrangeDark,
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text(
            canJoin ? "Join Match Sekarang" : (m.isFull ? "Match Penuh" : "Sudah Bergabung"),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}