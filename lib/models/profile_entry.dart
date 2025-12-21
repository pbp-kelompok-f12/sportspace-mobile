// To parse this JSON data, do
//
//     final profileEntry = profileEntryFromJson(jsonString);

import 'dart:convert';

ProfileEntry profileEntryFromJson(String str) => ProfileEntry.fromJson(json.decode(str));

String profileEntryToJson(ProfileEntry data) => json.encode(data.toJson());

class ProfileEntry {
    String username;
    String role;
    bool success;
    String message;
    dynamic email;
    String phone;
    String address;
    String photoUrl;
    String bio;
    int totalBooking;
    int avgRating;
    String joinedDate;

    ProfileEntry({
        required this.username,
        required this.role,
        required this.success,
        required this.message,
        required this.email,
        required this.phone,
        required this.address,
        required this.photoUrl,
        required this.bio,
        required this.totalBooking,
        required this.avgRating,
        required this.joinedDate,
    });

    factory ProfileEntry.fromJson(Map<String, dynamic> json) => ProfileEntry(
        username: json["username"] ?? "User",
        role: json["role"] ?? "Customer",
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        email: json["email"] != null ? json["email"].toString() : "-",

        phone: json["phone"] ?? "-",
        address: json["address"] ?? "-",
        photoUrl: json["photo_url"] ?? "",
        bio: json["bio"] ?? "",          

        totalBooking: json["total_booking"] ?? 0,
        avgRating: json["avg_rating"] ?? 0,
        joinedDate: json["joined_date"] ?? "-",
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "role": role,
        "success": success,
        "message": message,
        "email": email,
        "phone": phone,
        "address": address,
        "photo_url": photoUrl,
        "bio": bio,
        "total_booking": totalBooking,
        "avg_rating": avgRating,
        "joined_date": joinedDate,
    };
}
