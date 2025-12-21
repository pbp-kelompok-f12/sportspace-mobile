// File: models/match_entry.dart

class MatchEntry {
  final int id;
  final String mode; // "1v1" atau "2v2"
  final String modeDisplay; // "1 VS 1"
  final String createdByUsername;
  final String? venueName;
  final String? startTime;
  final String? endTime;
  
  final int playerCount;
  final int maxPlayers;
  final bool isFull;
  
  // Logic fields
  final List<String> playerUsernames;
  final String? tempTeammate;
  final bool isUserRegistered;
  final bool isUserCreator;
  final bool canUserJoin;

  MatchEntry({
    required this.id,
    required this.mode,
    required this.modeDisplay,
    required this.createdByUsername,
    this.venueName,
    this.startTime,
    this.endTime,
    required this.playerCount,
    required this.maxPlayers,
    required this.isFull,
    required this.playerUsernames,
    this.tempTeammate,
    required this.isUserRegistered,
    required this.isUserCreator,
    required this.canUserJoin,
  });

  factory MatchEntry.fromJson(Map<String, dynamic> json) {
    return MatchEntry(
      id: json['id'],
      mode: json['mode'] ?? '',
      modeDisplay: json['mode_display'] ?? (json['mode'] ?? '').toUpperCase(),
      
      // === BAGIAN PENTING ===
      // Pastikan key ini sama persis dengan di Serializer
      createdByUsername: json['created_by_username'] ?? 'Unknown', 
      venueName: json['venue_name'], // Bisa null
      startTime: json['start_time'], // Bisa null (format "14:30")
      endTime: json['end_time'],     // Bisa null (format "16:00")
      // ======================

      playerCount: json['player_count'] ?? 0,
      maxPlayers: json['max_players'] ?? 0,
      isFull: json['is_full'] ?? false,
      
      playerUsernames: List<String>.from(json['player_usernames'] ?? []),
      tempTeammate: json['temp_teammate'],
      
      isUserRegistered: json['is_user_registered'] ?? false,
      isUserCreator: json['is_user_creator'] ?? false,
      canUserJoin: json['can_user_join'] ?? false,
    );
  }
}