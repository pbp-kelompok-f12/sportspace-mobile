import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportspace_app/models/match_entry.dart';

class MatchDetailPage extends StatefulWidget {
  final int matchId;

  const MatchDetailPage({super.key, required this.matchId});

  @override
  State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  final String baseUrl = "http://10.0.2.2:8000"; 
  late Future<MatchEntry> _matchDetailFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reloadDetail();
  }

  void _reloadDetail() {
    final request = context.read<CookieRequest>();
    setState(() {
      _matchDetailFuture = fetchMatchDetail(request);
    });
  }

  Future<MatchEntry> fetchMatchDetail(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/matchmaking/json/${widget.matchId}/');
      
      if (response is Map<String, dynamic>) {
        return MatchEntry.fromJson(response);
      }
      return Future.error("Format data Match tidak valid.");
    } catch (e) {
      return Future.error("Gagal memuat detail Match: ${e.toString()}"); 
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF002B4F);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Match"),
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<MatchEntry>(
        future: _matchDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Data Match tidak ditemukan"));
          }

          final match = snapshot.data!;
          final statusColor = match.isFull ? Colors.red.shade600 : Colors.green.shade600;

          return RefreshIndicator(
            onRefresh: () async {
              _reloadDetail();
              await _matchDetailFuture;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.modeDisplay,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        "Dibuat oleh",
                        match.createdByUsername,
                        Icons.person,
                      ),
                      _buildInfoRow(
                        "Status",
                        match.isFull ? "Match Sudah Penuh" : "Tersedia",
                        match.isFull ? Icons.block : Icons.check_circle,
                        valueColor: statusColor,
                      ),
                      _buildInfoRow(
                        "Kapasitas",
                        "${match.playerCount}/${match.maxPlayers} Pemain",
                        Icons.group,
                        valueColor: statusColor,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Pemain Terdaftar:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Daftar Pemain
                      ...match.playerUsernames.map((username) => Padding(
                            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                            child: Text("• $username", style: const TextStyle(fontSize: 15)),
                          )),
                      // Nama Teman (jika ada)
                      if (match.tempTeammate != null && match.tempTeammate!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                          child: Text("• ${match.tempTeammate} (Teman)", style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic)),
                        ),
                      
                      const SizedBox(height: 24),
                      Center(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, true), 
                          child: const Text("Kembali ke Daftar Match"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFFFF9800)),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}