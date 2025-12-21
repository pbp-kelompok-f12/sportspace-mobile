class UserData {
  final int id;
  final String username;
  final String email;
  final String role;
  final String phone;
  final String address;
  final bool isActive; // Untuk status aktif/nonaktif

  UserData({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.phone,
    required this.address,
    required this.isActive,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      username: json['username']?.toString() ?? "Unknown",
      email: json['email']?.toString() ?? "-",
      role: json['role']?.toString() ?? "customer",
      phone: json['phone']?.toString() ?? "-",
      address: json['address']?.toString() ?? "-",
      isActive: json['is_active'] ?? true, 
    );
  }
}