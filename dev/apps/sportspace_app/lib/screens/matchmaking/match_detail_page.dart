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
  late Future<MatchEntry> future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    future = fetch();
  }

  Future<MatchEntry> fetch() async {
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
    setState(() => future = fetch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Match")),
      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final m = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.modeDisplay, style: const TextStyle(fontSize: 22)),
                Text("Creator: ${m.createdByUsername}"),
                Text("Pemain: ${m.playerCount}/${m.maxPlayers}"),
                const SizedBox(height: 10),
                const Text("Daftar Pemain:"),
                ...m.playerUsernames.map((e) => Text("- $e")),
                if (m.tempTeammate != null)
                  Text("- ${m.tempTeammate} (Teman)"),
                const Spacer(),
                if (m.canUserJoin)
                  ElevatedButton(
                    onPressed: joinMatch,
                    child: const Text("Join Match"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
