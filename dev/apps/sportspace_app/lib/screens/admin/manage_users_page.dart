import 'package:flutter/material.dart';

// --- 1. MODEL & DUMMY DATA ---

class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final String phone;
  final String address;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.phone,
    required this.address,
  });
}

// Dummy Data
List<User> dummyUsers = [
  User(
    id: 1,
    username: "budi_santoso",
    email: "budi@example.com",
    role: "customer",
    phone: "081234567890",
    address: "Jl. Sudirman No. 1, Jakarta",
  ),
  User(
    id: 2,
    username: "admin_sport",
    email: "admin@sportspace.id",
    role: "admin",
    phone: "081987654321",
    address: "Kantor Pusat SportSpace",
  ),
  User(
    id: 3,
    username: "arena_futsal",
    email: "owner@arena.com",
    role: "venue_owner",
    phone: "081345678901",
    address: "Jl. Kemang Raya No. 10",
  ),
  User(
    id: 4,
    username: "siti_aminah",
    email: "siti@gmail.com",
    role: "customer",
    phone: "085678901234",
    address: "Jl. Melati No. 5, Bandung",
  ),
  User(
    id: 5,
    username: "super_admin",
    email: "root@system.com",
    role: "admin",
    phone: "-",
    address: "Server Room 1",
  ),
];

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  // Warna Utama dari HTML
  final Color primaryNavy = const Color(0xFF0C2D57);
  final Color bgLight = const Color(0xFFF8FAFC);

  // State untuk Filter & Sort
  String selectedRole = 'All';
  String selectedSort = 'A-Z';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Kelola Pengguna",
          style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryNavy),
            onPressed: () {
              // Logic refresh data nanti
            },
          )
        ],
      ),
      body: Column(
        children: [
          // --- HEADER SECTION ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                Text(
                  "Lihat, tambah, ubah, dan hapus pengguna sistem.",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Row Filter & Sort
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Filter Role
                      _buildDropdown(
                        label: "Role",
                        value: selectedRole,
                        items: ['All', 'Customer', 'Venue Owner', 'Admin'],
                        onChanged: (val) => setState(() => selectedRole = val!),
                      ),
                      const SizedBox(width: 10),
                      // Sort Order
                      _buildDropdown(
                        label: "Sort",
                        value: selectedSort,
                        items: ['A-Z', 'Z-A'],
                        onChanged: (val) => setState(() => selectedSort = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Tombol Tambah & Counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total: ${dummyUsers.length}",
                      style: TextStyle(
                        color: primaryNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showUserForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Tambah"),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- LIST DATA ---
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: dummyUsers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = dummyUsers[index];
                return _buildUserCard(user);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget Dropdown Custom
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Text("$label: ", style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w500)),
          DropdownButton<String>(
            value: value,
            underline: Container(), // Hilangkan garis bawah default
            icon: Icon(Icons.arrow_drop_down, color: primaryNavy),
            style: const TextStyle(color: Colors.black),
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Widget Kartu User (Pengganti Row Tabel)
  Widget _buildUserCard(User user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card: Username & Role Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  user.username,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryNavy,
                  ),
                ),
                _buildRoleBadge(user.role),
              ],
            ),
            const Divider(height: 24),
            
            // Info Detail
            _buildInfoRow(Icons.email_outlined, user.email),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone_outlined, user.phone),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on_outlined, user.address),

            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showUserForm(context, user: user),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit"),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue[700]),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    // Logic Hapus
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Hapus ${user.username}")),
                    );
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text("Hapus"),
                  style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Helper Badge Role
  Widget _buildRoleBadge(String role) {
    Color bgColor;
    Color textColor;

    switch (role.toLowerCase()) {
      case 'admin':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      case 'venue_owner':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      default: // customer
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.toUpperCase().replaceAll('_', ' '),
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper Info Row
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // --- MODAL FORM (ADD/EDIT) ---
  void _showUserForm(BuildContext context, {User? user}) {
    final bool isEdit = user != null;
    final TextEditingController usernameController = TextEditingController(text: user?.username ?? '');
    final TextEditingController emailController = TextEditingController(text: user?.email ?? '');
    final TextEditingController phoneController = TextEditingController(text: user?.phone ?? '');
    final TextEditingController addressController = TextEditingController(text: user?.address ?? '');
    String roleValue = user?.role ?? 'customer';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Agar dropdown dalam dialog bisa berubah state-nya
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                isEdit ? "Edit Pengguna" : "Tambah Pengguna",
                style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField("Username", usernameController),
                      const SizedBox(height: 12),
                      _buildTextField("Email", emailController, inputType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      
                      // Dropdown Role di Form
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Role", style: TextStyle(color: primaryNavy, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: roleValue,
                                isExpanded: true,
                                items: ['customer', 'venue_owner', 'admin'].map((String val) {
                                  return DropdownMenuItem(
                                    value: val,
                                    child: Text(val.toUpperCase().replaceAll('_', ' ')),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() => roleValue = val!);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      _buildTextField("Telepon", phoneController, inputType: TextInputType.phone),
                      const SizedBox(height: 12),
                      _buildTextField("Alamat", addressController, maxLines: 3),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Logic Simpan
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryNavy),
                  child: const Text("Simpan", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? inputType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: primaryNavy, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: inputType,
          maxLines: maxLines,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryNavy)),
          ),
        ),
      ],
    );
  }
}