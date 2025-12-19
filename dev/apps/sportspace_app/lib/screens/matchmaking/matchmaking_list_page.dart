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

  Future<List<MatchEntry>> fetchMatches(CookieRequest request) async {
    final response = await request.get('$baseUrl/matchmaking/json/');
    return response.map<MatchEntry>((e) => MatchEntry.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(title: const Text("Matchmaking")),
      body: FutureBuilder(
        future: fetchMatches(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada match."));
          }

          final matches = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final m = matches[index];
                return Card(
                  child: ListTile(
                    title: Text(m.modeDisplay),
                    subtitle: Text(
                      "By ${m.createdByUsername} • ${m.playerCount}/${m.maxPlayers}",
                    ),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            label: const Text("1v1"),
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Create1v1Page()),
              ).then((_) => setState(() {}));
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            label: const Text("2v2"),
            icon: const Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Create2v2Page()),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
    );
  }
}
