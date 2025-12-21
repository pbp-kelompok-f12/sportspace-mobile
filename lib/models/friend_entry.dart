class Friend {
  String username;
  String photoUrl;
  String bio;
  int id;

  Friend({
    required this.id,
    required this.username,
    required this.photoUrl,
    required this.bio,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json["id"] ?? 0,
      username: json["username"],
      // Handle jika photo_url null atau kosong
      photoUrl: json["photo_url"] ?? "",
      bio: json["bio"],
    );
  }
}

class Friends {
    List<Friend> friends;
    Friends({
        required this.friends,
    });
}



class FriendRequest {
  final int id;           // ID Request
  final Friend fromUser;  // Object User pengirim
  final String createdAt; // Tanggal

  FriendRequest({
    required this.id,
    required this.fromUser,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json["id"],
      // Pastikan key JSON sesuai dengan response Django "from_user"
      fromUser: Friend.fromJson(json["from_user"]),
      createdAt: json["created_at"] ?? "",
    );
  }
}
