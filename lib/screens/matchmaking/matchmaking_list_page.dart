import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
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
  final String baseUrl = "http://10.0.2.2:8000";
  String _filter = "all"; // "all" atau "yours"

  Future<List<MatchEntry>> fetchMatches(CookieRequest request) async {
    final response = await request.get('$baseUrl/matchmaking/json/');
    List<MatchEntry> matches = response.map<MatchEntry>((e) => MatchEntry.fromJson(e)).toList();

    if (_filter == "yours") {
      matches = matches.where((m) => m.isUserCreator || m.isUserRegistered).toList();
    }
    return matches;
  }

  void _reloadFilter(String filter) {
    setState(() {
      _filter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    const Color darkBlue = Color(0xFF0D2C3E);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar putih
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black), // back arrow hitam
        title: const Text(
          "Matchmaking",
          style: TextStyle(
            color: Colors.black, // teks hitam
            // fontWeight dihapus supaya tidak bold
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Filter buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text("Semua Match"),
                      selected: _filter == "all",
                      onSelected: (_) => _reloadFilter("all"),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text("Match Anda"),
                      selected: _filter == "yours",
                      onSelected: (_) => _reloadFilter("yours"),
                    ),
                  ],
                ),
              ),
              // List matches
              Expanded(
                child: FutureBuilder<List<MatchEntry>>(
                  future: fetchMatches(request),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            "Belum ada matchmaking yang dibuat. Buat match untuk bertanding dengan orang lain!",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    final matches = snapshot.data!;

                    return RefreshIndicator(
                      onRefresh: () async => setState(() {}),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100), // agar FAB tidak tertutup
                        itemCount: matches.length,
                        itemBuilder: (context, index) {
                          final m = matches[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              title: Text("${m.modeDisplay} - ${m.venueName}"),
                              subtitle: Text(
                                "By ${m.createdByUsername} • ${m.playerCount}/${m.maxPlayers}\n"
                                "Jam: ${m.startTime} - ${m.endTime}",
                              ),
                              isThreeLine: true,
                              trailing: Icon(
                                m.isFull ? Icons.lock : Icons.lock_open,
                                color: m.isFull ? Colors.red : Colors.green,
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MatchDetailPage(matchId: m.id),
                                  ),
                                );
                                setState(() {});
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // FAB buttons
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  heroTag: "btn1v1",
                  label: const Text("Create 1v1 Match"),
                  icon: const Icon(Icons.person),
                  backgroundColor: darkBlue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Create1v1Page()),
                    ).then((_) => setState(() {}));
                  },
                ),
                const SizedBox(width: 16),
                FloatingActionButton.extended(
                  heroTag: "btn2v2",
                  label: const Text("Create 2v2 Match"),
                  icon: const Icon(Icons.group),
                  backgroundColor: darkBlue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Create2v2Page()),
                    ).then((_) => setState(() {}));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
