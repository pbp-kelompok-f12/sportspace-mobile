class MatchEntry {
  final int id;
  final String modeDisplay;
  final String createdByUsername;
  final int playerCount;
  final int maxPlayers;
  final bool isFull;
  final bool isUserRegistered;
  final bool isUserCreator;
  final bool canUserJoin;
  final List<String> playerUsernames;
  final String? tempTeammate;

  MatchEntry({
    required this.id,
    required this.modeDisplay,
    required this.createdByUsername,
    required this.playerCount,
    required this.maxPlayers,
    required this.isFull,
    required this.isUserRegistered,
    required this.isUserCreator,
    required this.canUserJoin,
    required this.playerUsernames,
    this.tempTeammate,
  });

  factory MatchEntry.fromJson(Map<String, dynamic> json) {
    return MatchEntry(
      id: json['id'],
      modeDisplay: json['mode_display'],
      createdByUsername: json['created_by_username'],
      playerCount: json['player_count'],
      maxPlayers: json['max_players'],
      isFull: json['is_full'],
      isUserRegistered: json['is_user_registered'],
      isUserCreator: json['is_user_creator'],
      canUserJoin: json['can_user_join'],
      playerUsernames: List<String>.from(json['player_usernames']),
      tempTeammate: json['temp_teammate'],
    );
  }
}
