import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportspace_app/models/user_model.dart'; 

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  // --- KONFIGURASI ---
  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";

  // --- PALETTE WARNA ---
  final Color primaryNavy = const Color(0xFF0C2D57);
  final Color accentOrange = const Color(0xFFF97316);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textDark = const Color(0xFF1E293B);
  final Color textGrey = const Color(0xFF64748B);
  final Color statusGreen = const Color(0xFF10B981); 
  final Color statusRed = const Color(0xFFEF4444);   

  // --- STATE ---
  bool _isLoading = true; // Hanya true saat pertama kali buka halaman
  List<UserData> _users = [];
  
  // Filter & Paging
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = "";
  String _selectedRole = "all"; 
  String _selectedStatus = "all"; 
  String _sortOption = "asc"; 

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _jumpPageController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _jumpPageController.text = "1";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUsers(); // Initial Load
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _jumpPageController.dispose();
    super.dispose();
  }

  String _validateData(String? value) {
    if (value == null || value.trim().isEmpty || value.toLowerCase() == 'null') {
      return "-";
    }
    return value;
  }

  // --- FETCH DATA (OPTIMIZED) ---
  // Parameter isRefresh: Jika true, jangan set _isLoading jadi true (biar layar ga kedip/putih)
  Future<void> _fetchUsers({int page = 1, bool isRefresh = false}) async {
    final request = context.read<CookieRequest>();
    
    setState(() {
      _currentPage = page;
      // OPTIMISASI: Hanya tampilkan loading penuh jika bukan refresh & bukan ganti halaman
      if (!isRefresh && _users.isEmpty) {
        _isLoading = true;
      }
    });

    try {
      String url = '$baseUrl/dashboard-admin/users/data/?page=$page&role=$_selectedRole&status=$_selectedStatus&search=$_searchQuery';
      final response = await request.get(url);

      if (mounted) {
        setState(() {
          _users = (response['users'] as List).map((d) => UserData.fromJson(d)).toList();
          _totalPages = response['total_pages'];
          
          _jumpPageController.text = "$_currentPage";

          if (_sortOption == 'asc') {
            _users.sort((a, b) => a.username.toLowerCase().compareTo(b.username.toLowerCase()));
          } else {
            _users.sort((a, b) => b.username.toLowerCase().compareTo(a.username.toLowerCase()));
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi khusus untuk Pull-to-Refresh (Wajib return Future)
  Future<void> _onRefresh() async {
    // Reset ke halaman 1 saat di-refresh tarik
    await _fetchUsers(page: 1, isRefresh: true);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _searchQuery = query;
      _fetchUsers(page: 1); 
    });
  }

  // --- ACTIONS (Toggle, Add) ---
  Future<void> _toggleUserStatus(int id, bool isActive) async {
    final request = context.read<CookieRequest>();
    bool willActivate = !isActive;
    
    // Tampilan Modal Konfirmasi
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (willActivate ? statusGreen : statusRed).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                willActivate ? Icons.check_circle_outline_rounded : Icons.block_rounded, 
                size: 48, 
                color: willActivate ? statusGreen : statusRed
              ),
            ),
            const SizedBox(height: 20),
            Text("Konfirmasi Status", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: primaryNavy)),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 14, color: textGrey, height: 1.5),
                children: [
                  const TextSpan(text: "Apakah Anda yakin ingin "),
                  TextSpan(text: willActivate ? "mengaktifkan" : "menonaktifkan", style: TextStyle(fontWeight: FontWeight.bold, color: textDark)),
                  const TextSpan(text: " pengguna ini?\nStatus akan berubah menjadi "),
                  TextSpan(text: willActivate ? "AKTIF" : "NONAKTIF", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: willActivate ? statusGreen : statusRed)),
                  const TextSpan(text: "."),
                ]
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx, false), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text("Batal", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textGrey)))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: willActivate ? statusGreen : statusRed, padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text("Ya, Ubah", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)))),
            ],
          )
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      final response = await request.post('$baseUrl/dashboard-admin/users/status/$id/', {});
      if (response['status'] == 'success') {
        // Refresh 'silent' agar user tidak kaget
        _fetchUsers(page: _currentPage, isRefresh: true);
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Status berhasil diubah"), backgroundColor: willActivate ? statusGreen : statusRed));
      }
    } catch (e) {
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mengubah status")));
    }
  }

  void _showAddUserDialog() {
    // ... (Kode Modal Tambah User sama persis dengan sebelumnya)
    // Gunakan kode modal bagus yang terakhir saya berikan
    final formKey = GlobalKey<FormState>();
    final request = context.read<CookieRequest>();
    String username = "", password = "", email = "", phone = "", address = "", role = "customer";
    bool obscurePassword = true;

    showDialog(
      context: context, barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateModal) {
          return Dialog(
            backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("Tambah Pengguna", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: primaryNavy)),
                  InkWell(onTap: () => Navigator.pop(context), borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: const Icon(Icons.close, size: 20, color: Colors.grey))),
                ]),
                const SizedBox(height: 24),
                Flexible(child: SingleChildScrollView(child: Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildLabel("Username", isRequired: true),
                  _buildTextField(hint: "cth: user123", icon: Icons.person_outline_rounded, onChanged: (v) => username = v, validator: (v) => v!.isEmpty ? "Wajib diisi" : null),
                  const SizedBox(height: 16),
                  _buildLabel("Password", isRequired: true),
                  _buildTextField(hint: "Minimal 6 karakter", icon: Icons.lock_outline_rounded, isPassword: true, obscureText: obscurePassword, onTogglePassword: () => setStateModal(() => obscurePassword = !obscurePassword), onChanged: (v) => password = v, validator: (v) => v!.isEmpty ? "Wajib diisi" : null),
                  const SizedBox(height: 16),
                  _buildLabel("Email"),
                  _buildTextField(hint: "nama@email.com", icon: Icons.email_outlined, inputType: TextInputType.emailAddress, onChanged: (v) => email = v),
                  const SizedBox(height: 16),
                  _buildLabel("Role", isRequired: true),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: role, isExpanded: true, icon: Icon(Icons.keyboard_arrow_down_rounded, color: textGrey), style: GoogleFonts.inter(fontSize: 14, color: textDark), items: const [DropdownMenuItem(value: "customer", child: Text("Customer")), DropdownMenuItem(value: "venue_owner", child: Text("Venue Owner"))], onChanged: (v) => setStateModal(() => role = v!)))),
                  const SizedBox(height: 16),
                  _buildLabel("Telepon"), _buildTextField(hint: "0812...", icon: Icons.phone_outlined, inputType: TextInputType.phone, onChanged: (v) => phone = v),
                  const SizedBox(height: 16),
                  _buildLabel("Alamat"), _buildTextField(hint: "Alamat lengkap...", icon: Icons.location_on_outlined, maxLines: 2, onChanged: (v) => address = v),
                ])))),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text("Batal", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textGrey)))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      FocusScope.of(context).unfocus();
                      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
                      try {
                        final payload = jsonEncode({'username': username, 'password': password, 'email': email, 'role': role, 'phone': phone, 'address': address});
                        final response = await request.postJson('$baseUrl/dashboard-admin/users/add/', payload);
                        if (context.mounted) Navigator.pop(context); // Tutup loading
                        if (response['status'] == 'success') {
                          if (context.mounted) Navigator.pop(context); // Tutup modal form
                          _fetchUsers(page: 1, isRefresh: true); // Refresh list
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User berhasil dibuat!"), backgroundColor: statusGreen));
                        }
                      } catch (e) {
                        if (context.mounted && Navigator.canPop(context)) Navigator.pop(context);
                      }
                    }
                  }, style: ElevatedButton.styleFrom(backgroundColor: primaryNavy, padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text("Simpan Data", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white))))
                ])
              ]),
            ),
          );
        });
      }
    );
  }

  // --- MODAL FILTERS ---
  void _showRoleFilterModal() {
    final Map<String, String> roles = {'all': 'Semua Role', 'customer': 'Customer', 'venue_owner': 'Venue Owner'};
    _buildGenericModal("Filter Role", roles, _selectedRole, (key) { setState(() { _selectedRole = key; _fetchUsers(page: 1); }); });
  }

  void _showStatusFilterModal() {
    final Map<String, String> statuses = {'all': 'Semua Status', 'active': 'Aktif', 'inactive': 'Nonaktif'};
    _buildGenericModal("Filter Status", statuses, _selectedStatus, (key) { setState(() { _selectedStatus = key; _fetchUsers(page: 1); }); });
  }

  void _showSortOptionsModal() {
    final Map<String, String> options = {'asc': 'Nama (A-Z)', 'desc': 'Nama (Z-A)'};
    _buildGenericModal("Urutkan Berdasarkan", options, _sortOption, (key) { setState(() { _sortOption = key; _fetchUsers(page: _currentPage); }); });
  }

  void _buildGenericModal(String title, Map<String, String> items, String currentVal, Function(String) onSelect) {
    showModalBottomSheet(context: context, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (ctx) => Container(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)), const SizedBox(height: 16), ...items.entries.map((entry) => ListTile(contentPadding: EdgeInsets.zero, title: Text(entry.value, style: GoogleFonts.inter(color: currentVal == entry.key ? accentOrange : textDark, fontWeight: currentVal == entry.key ? FontWeight.bold : FontWeight.normal)), trailing: currentVal == entry.key ? Icon(Icons.check_circle, color: accentOrange) : null, onTap: () { onSelect(entry.key); Navigator.pop(ctx); }))])));
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryNavy), onPressed: () => Navigator.pop(context)),
        title: Text("Manajemen User", style: GoogleFonts.poppins(color: primaryNavy, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      
      body: Column(
        children: [
          // 1. TOP SECTION
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(hintText: "Cari User...", hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400), prefixIcon: Icon(Icons.search_rounded, color: accentOrange), filled: true, fillColor: bgLight, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: _showAddUserDialog, borderRadius: BorderRadius.circular(12),
                      child: Container(height: 48, width: 48, decoration: BoxDecoration(color: primaryNavy, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: primaryNavy.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]), child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 24)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(flex: 3, child: InkWell(onTap: _showRoleFilterModal, child: _buildFilterBox(icon: Icons.supervised_user_circle_rounded, text: _selectedRole == 'all' ? "Role" : _selectedRole[0].toUpperCase() + _selectedRole.substring(1), isActive: _selectedRole != "all", isDropdown: true))),
                    const SizedBox(width: 8),
                    Expanded(flex: 3, child: InkWell(onTap: _showStatusFilterModal, child: _buildFilterBox(icon: Icons.toggle_on_rounded, text: _selectedStatus == 'all' ? "Status" : (_selectedStatus == 'active' ? "Aktif" : "Nonaktif"), isActive: _selectedStatus != "all", isDropdown: true))),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: InkWell(onTap: _showSortOptionsModal, child: _buildFilterBox(icon: Icons.sort_rounded, text: "Urutkan", isActive: _sortOption != "asc", isDropdown: true))),
                  ],
                ),
              ],
            ),
          ),

          // 2. LIST DATA (REFRESH INDICATOR)
          Expanded(
            child: _isLoading && _users.isEmpty // Cek isEmpty agar saat refresh data lama masih tampil
                ? Center(child: CircularProgressIndicator(color: accentOrange))
                : _users.isEmpty
                    ? Center(child: Text("Tidak ada data", style: GoogleFonts.inter(color: textGrey)))
                    // DISINI IMPLEMENTASI PULL-TO-REFRESH
                    : RefreshIndicator(
                        onRefresh: _onRefresh, // Panggil fungsi refresh
                        color: accentOrange,
                        backgroundColor: Colors.white,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(), // Wajib agar bisa ditarik walau item sedikit
                          padding: const EdgeInsets.all(20),
                          itemCount: _users.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _buildUserCard(_users[index], request);
                          },
                        ),
                      ),
          ),

          // 3. PAGINATION (Sticky)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(color: bgLight, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Hal $_currentPage / $_totalPages", style: GoogleFonts.inter(fontSize: 12, color: textGrey)),
                  const Spacer(),
                  InkWell(
                    onTap: (!_isLoading && _currentPage > 1) ? () => _fetchUsers(page: _currentPage - 1) : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), child: Icon(Icons.chevron_left_rounded, color: (!_isLoading && _currentPage > 1) ? primaryNavy : Colors.grey.shade300)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 50, height: 40,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                    child: Center(
                      child: TextField(
                        controller: _jumpPageController, textAlign: TextAlign.center, keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: primaryNavy),
                        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true),
                        onSubmitted: (val) {
                          if (_isLoading) return;
                          int? p = int.tryParse(val);
                          if (p != null && p >= 1 && p <= _totalPages) {
                            _fetchUsers(page: p);
                          } else {
                            _jumpPageController.text = "$_currentPage"; 
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: (!_isLoading && _currentPage < _totalPages) ? () => _fetchUsers(page: _currentPage + 1) : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), child: Icon(Icons.chevron_right_rounded, color: (!_isLoading && _currentPage < _totalPages) ? primaryNavy : Colors.grey.shade300)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---
  Widget _buildFilterBox({required IconData icon, required String text, required bool isActive, required bool isDropdown}) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12), decoration: BoxDecoration(color: isActive ? accentOrange.withOpacity(0.1) : Colors.transparent, border: Border.all(color: isActive ? accentOrange : Colors.grey.shade300), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: isActive ? accentOrange : textGrey), const SizedBox(width: 4), Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11, color: isActive ? accentOrange : textDark, fontWeight: isActive ? FontWeight.bold : FontWeight.normal))), if (isDropdown) ...[const SizedBox(width: 2), Icon(Icons.arrow_drop_down, size: 16, color: textGrey)]]));
  }

  Widget _buildUserCard(UserData user, CookieRequest request) {
    Color themeColor = accentOrange; 
    return Opacity(
      opacity: user.isActive ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: primaryNavy.withOpacity(0.04), offset: const Offset(0, 4), blurRadius: 12)]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(children: [
              Container(width: 4, color: themeColor),
              Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user.username, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: primaryNavy), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Wrap(spacing: 6, children: [_badge(user.role.toUpperCase(), themeColor), _badge(user.isActive ? "AKTIF" : "NONAKTIF", user.isActive ? statusGreen : statusRed, isStatus: true)])
                  ])),
                  InkWell(
                    onTap: () => _toggleUserStatus(user.id, user.isActive), borderRadius: BorderRadius.circular(8),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: user.isActive ? statusRed.withOpacity(0.1) : statusGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: user.isActive ? statusRed.withOpacity(0.2) : statusGreen.withOpacity(0.2))), child: Text(user.isActive ? "Nonaktifkan" : "Aktifkan", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: user.isActive ? statusRed : statusGreen))),
                  ),
                ]),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
                _simpleRow(Icons.email_outlined, _validateData(user.email)), const SizedBox(height: 3), _simpleRow(Icons.phone_outlined, _validateData(user.phone)), const SizedBox(height: 3), _simpleRow(Icons.location_on_outlined, _validateData(user.address)),
              ]))),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color, {bool isStatus = false}) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: isStatus ? Border.all(color: color.withOpacity(0.3), width: 1) : null), child: Text(text, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color)));
  }

  Widget _simpleRow(IconData icon, String text) {
    return Row(children: [Icon(icon, size: 14, color: textGrey), const SizedBox(width: 6), Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 13, color: textDark), overflow: TextOverflow.ellipsis))]);
  }

  // --- WIDGET HELPER FORM ---
  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: RichText(text: TextSpan(text: text, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textDark), children: [if (isRequired) const TextSpan(text: " *", style: TextStyle(color: Colors.red))])));
  }

  Widget _buildTextField({required String hint, required IconData icon, required Function(String) onChanged, String? Function(String?)? validator, bool isPassword = false, bool obscureText = false, VoidCallback? onTogglePassword, TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(obscureText: isPassword ? obscureText : false, keyboardType: inputType, maxLines: maxLines, onChanged: onChanged, validator: validator, style: GoogleFonts.inter(color: textDark), decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14), filled: true, fillColor: bgLight, prefixIcon: Icon(icon, color: textGrey, size: 20), suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: textGrey), onPressed: onTogglePassword) : null, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentOrange, width: 1.5)), errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade300, width: 1)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)));
  }
}