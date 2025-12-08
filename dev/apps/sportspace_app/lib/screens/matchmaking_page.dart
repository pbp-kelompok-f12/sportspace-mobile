import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
// Asumsikan MatchEntry, CreateMatch1v1Page, CreateMatch2v2Page, dan MatchDetailPage sudah di-import
import 'package:sportspace_app/models/match_entry.dart';
import 'package:sportspace_app/screens/create_match_1v1.dart';
import 'package:sportspace_app/screens/create_match_2v2.dart';
import 'package:sportspace_app/screens/match_detail_page.dart';
import 'dart:convert';

class MatchmakingPage extends StatefulWidget {
  const MatchmakingPage({super.key});

  @override
  State<MatchmakingPage> createState() => _MatchmakingPageState();
}

class _MatchmakingPageState extends State<MatchmakingPage> {
  // Ganti ke IP yang sesuai (10.0.2.2 untuk Android Emulator)
  final String baseUrl = "http://10.0.2.2:8000";
  late Future<List<MatchEntry>> _matchesFuture;
  bool _isActionLoading = false; // Status loading untuk tombol aksi (Join/Delete)

  @override
  void initState() {
    super.initState();
    // Memuat data pertama kali di initState
    // _reloadMatches() akan dipanggil di didChangeDependencies atau langsung di initState
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return; // Tambahkan safety check
    _reloadMatches();
  }

  Future<List<MatchEntry>> _fetchMatches(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/matchmaking/json/');
      
      List<MatchEntry> listMatches = [];
      if (response is List) {
        for (var d in response) {
          if (d != null) {
            // Pastikan Anda telah mengimpor dan membuat model MatchEntry
            listMatches.add(MatchEntry.fromJson(d as Map<String, dynamic>));
          }
        }
      }
      return listMatches;
    } catch (e) {
      // Menangani error koneksi saat mengambil data
      // Biarkan FutureBuilder menangani error ini, kita hanya melempar kembali
      throw Exception("Gagal memuat data match: Pastikan server berjalan dan IP benar ($baseUrl). Error: $e");
    }
  }

  void _reloadMatches() {
    final request = context.read<CookieRequest>();
    setState(() {
      _matchesFuture = _fetchMatches(request);
    });
  }

  Future<void> _performAction(
    CookieRequest request,
    MatchEntry match,
    String action, 
  ) async {
    if (_isActionLoading) return; // Cegah klik ganda

    setState(() {
      _isActionLoading = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    String endpoint;

    if (action == 'join') {
      endpoint = '$baseUrl/matchmaking/join/${match.id}/';
    } else if (action == 'delete') {
      endpoint = '$baseUrl/matchmaking/delete/${match.id}/';
    } else {
      setState(() { _isActionLoading = false; });
      return;
    }

    try {
      final response = await request.postJson(
        endpoint,
        // body kosong karena ID sudah ada di URL
        jsonEncode({}), 
      );

      if (response != null && response['status'] == 'success') {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(response['message'] ?? "Aksi berhasil!")));
        _reloadMatches(); 
      } else {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Gagal melakukan aksi."),
              backgroundColor: Colors.red,
            ),
          );
      }
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("Terjadi kesalahan koneksi: $e")));
    } finally {
      setState(() {
        _isActionLoading = false;
      });
    }
  }
  
  void _navigateToCreateForm(Widget page) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    // Muat ulang daftar match jika kembali dengan hasil true (berarti sukses membuat match)
    if (result == true) {
      _reloadMatches();
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    const Color orange = Color(0xFFf97316);
    const Color darkBlue = Color(0xFF002B4F);

    return Column(
      children: [
        // Header
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            children: [
              Icon(Icons.people_outline, color: orange),
              SizedBox(width: 8),
              Text(
                "Find Your Teammates or Opponents",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
            ],
          ),
        ),

        // Tombol Create Match
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person),
                  label: const Text("Create 1 vs 1"),
                  onPressed: () => _navigateToCreateForm(const CreateMatch1v1Page()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    foregroundColor: orange,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.people),
                  label: const Text("Create 2 vs 2"),
                  onPressed: () => _navigateToCreateForm(const CreateMatch2v2Page()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: darkBlue,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Daftar Match
        Expanded(
          child: FutureBuilder<List<MatchEntry>>(
            future: _matchesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  // Menampilkan pesan error dari throw di _fetchMatches
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              final matches = snapshot.data ?? [];

              if (matches.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => _fetchMatches(request),
                  child: ListView(
                    children: const [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50.0),
                          child: Text(
                            "Belum ada match yang tersedia. Buat match Anda!",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => _fetchMatches(request),
                child: ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    
                    return MatchCard(
                      match: match,
                      // Pass status loading ke MatchCard
                      isActionLoading: _isActionLoading, 
                      onJoin: () => _performAction(request, match, 'join'),
                      onDelete: () => _performAction(request, match, 'delete'),
                      onDetail: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchDetailPage(matchId: match.id),
                          ),
                        ).then((result) {
                          // Muat ulang jika kembali dari detail page (misalnya setelah join/delete dari sana)
                          if (result == true) _reloadMatches(); 
                        }); 
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Widget Kartu Match
class MatchCard extends StatelessWidget {
  final MatchEntry match;
  final VoidCallback onJoin;
  final VoidCallback onDelete;
  final VoidCallback onDetail;
  final bool isActionLoading; // Terima status loading

  const MatchCard({
    super.key,
    required this.match,
    required this.onJoin,
    required this.onDelete,
    required this.onDetail,
    required this.isActionLoading, // Wajib diisi
  });

  @override
  Widget build(BuildContext context) {
    Color getStatusColor() {
      if (match.isFull) return Colors.red;
      return Colors.green;
    }

    // Tentukan apakah tombol aksi harus di-disable
    final bool isButtonDisabled = isActionLoading;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onDetail,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Mode & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    match.modeDisplay,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002B4F),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: getStatusColor(),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      match.isFull ? "Penuh" : "Tersedia",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const Divider(height: 12),
              
              // Detail Match
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "Dibuat oleh: ${match.createdByUsername}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.group, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "Pemain: ${match.playerCount}/${match.maxPlayers}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              
              // Aksi Button
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (match.isUserCreator)
                    ElevatedButton(
                      // Disable tombol jika sedang loading
                      onPressed: isButtonDisabled ? null : onDelete, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isButtonDisabled ? Colors.grey : Colors.red,
                      ),
                      child: isButtonDisabled 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                          : const Text("Hapus Match", style: TextStyle(color: Colors.white)),
                    )
                  else if (match.isUserRegistered)
                    const Chip(
                      label: Text("Anda Terdaftar", style: TextStyle(fontSize: 12, color: Colors.white)),
                      backgroundColor: Colors.lightBlue,
                      padding: EdgeInsets.zero,
                    )
                  else if (match.canUserJoin)
                    ElevatedButton.icon(
                      icon: isButtonDisabled
                          ? const SizedBox.shrink() // Hilangkan ikon jika loading
                          : const Icon(Icons.add, size: 16),
                      label: isButtonDisabled
                          ? const SizedBox(
                              width: 16, 
                              height: 16, 
                              child: CircularProgressIndicator(
                                strokeWidth: 2, 
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                              )
                            )
                          : const Text("Gabung"),
                      // Disable tombol jika sedang loading
                      onPressed: isButtonDisabled ? null : onJoin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isButtonDisabled ? Colors.grey : getStatusColor(),
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    const Text(
                      "Match Penuh",
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}