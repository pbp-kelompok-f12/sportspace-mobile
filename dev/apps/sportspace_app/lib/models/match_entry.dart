// lib/models/match_entry.dart

class MatchEntry {
    final int id;
    final String modeDisplay;
    final String createdByUsername;
    final int playerCount;
    final int maxPlayers;
    final List<String> playerUsernames;
    final bool isFull;
    
    // Status User-specific dari Django
    final bool isUserRegistered;
    final bool isUserCreator;
    final bool canUserJoin;

    // Untuk 2v2 (null jika 1v1 atau tidak ada)
    final String? tempTeammate;

    MatchEntry({
        required this.id,
        required this.modeDisplay,
        required this.createdByUsername,
        required this.playerCount,
        required this.maxPlayers,
        required this.playerUsernames,
        required this.isFull,
        required this.isUserRegistered,
        required this.isUserCreator,
        required this.canUserJoin,
        this.tempTeammate,
    });

    factory MatchEntry.fromJson(Map<String, dynamic> json) {
      List<String> players = [];
      if (json['player_usernames'] is List) {
        players = List<String>.from(json['player_usernames']);
      }

      return MatchEntry(
        id: json['id'] ?? 0,
        modeDisplay: json['mode_display'] ?? 'N/A',
        createdByUsername: json['created_by_username'] ?? 'Anonymous',
        playerCount: json['player_count'] ?? 0,
        maxPlayers: json['max_players'] ?? 0,
        playerUsernames: players,
        isFull: json['is_full'] ?? false,
        isUserRegistered: json['is_user_registered'] ?? false,
        isUserCreator: json['is_user_creator'] ?? false,
        canUserJoin: json['can_user_join'] ?? false,
        tempTeammate: json['temp_teammate'], // Nullable
      );
    }
}