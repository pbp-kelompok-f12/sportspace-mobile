import 'package:flutter/material.dart';
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
  final String baseUrl = "http://10.0.2.2:8000";
  late Future<MatchEntry> futureMatch;

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
    const Color darkBlue = Color(0xFF0D2C3E);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Match"),
        backgroundColor: darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<MatchEntry>(
        future: futureMatch,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Data match tidak tersedia"));
          }

          final m = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.modeDisplay,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text("Lapangan: ${m.createdByUsername}"),
                const SizedBox(height: 4),
                Text("Pemain: ${m.playerCount}/${m.maxPlayers}"),
                const SizedBox(height: 12),
                const Text(
                  "Daftar Pemain:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...m.playerUsernames.map((username) => Text("- $username")),
                if (m.tempTeammate != null)
                  Text("- ${m.tempTeammate} (Teman)"),
                const Spacer(),
                if (m.canUserJoin && !m.isFull)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: joinMatch,
                      child: const Text("Join Match"),
                    ),
                  ),
                if (!m.canUserJoin || m.isFull)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text("Tidak Bisa Join"),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
