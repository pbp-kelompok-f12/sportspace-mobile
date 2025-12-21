class MatchEntry {
  final int id;
  final String mode; // "1v1" atau "2v2"
  final String createdByUsername;
  final int playerCount;
  final int maxPlayers;
  final List<String> playerUsernames;
  final String? tempTeammate;
  final bool canUserJoin;
  final bool isFull;

  // Properti tambahan untuk list page dan join
  final bool isUserCreator;
  final bool isUserRegistered;
  final String? venueName;
  final String? startTime;
  final String? endTime;

  MatchEntry({
    required this.id,
    required this.mode,
    required this.createdByUsername,
    required this.playerCount,
    required this.maxPlayers,
    required this.playerUsernames,
    this.tempTeammate,
    required this.canUserJoin,
    required this.isFull,
    required this.isUserCreator,
    required this.isUserRegistered,
    this.venueName,
    this.startTime,
    this.endTime,
  });

  String get modeDisplay => mode.toUpperCase();

  factory MatchEntry.fromJson(Map<String, dynamic> json) {
    return MatchEntry(
      id: json['id'],
      mode: json['mode'] ?? '',
      createdByUsername: json['created_by_username'] ?? 'Unknown',
      playerCount: json['player_count'] ?? 0,
      maxPlayers: json['max_players'] ?? (json['mode'] == '1v1' ? 2 : 4),
      playerUsernames: List<String>.from(json['players'] ?? []),
      tempTeammate: json['temp_teammate'],
      canUserJoin: json['can_user_join'] ?? false,
      isFull: json['is_full'] ?? false,
      isUserCreator: json['is_user_creator'] ?? false,
      isUserRegistered: json['is_user_registered'] ?? false,
      venueName: json['venue_name'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}
