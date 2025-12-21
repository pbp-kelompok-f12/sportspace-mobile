import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// ==========================================
// 1. MODEL FIELD (SAFE PARSING)
// ==========================================
class FieldModel {
  final int id;
  final String nama;
  final String alamat;
  final double rating;
  final String thumbnail;
  final bool isFeatured;

  FieldModel({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.rating,
    required this.thumbnail,
    required this.isFeatured,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    // 1. Handle Thumbnail (Cegah null string)
    String safeThumbnail = "";
    if (json['thumbnail_url'] != null) {
      safeThumbnail = json['thumbnail_url'].toString();
      if (safeThumbnail == "null") safeThumbnail = ""; 
    }

    // 2. Handle Rating (Cegah tipe data crash)
    double safeRating = 0.0;
    if (json['rating'] != null) {
      if (json['rating'] is int) {
        safeRating = (json['rating'] as int).toDouble();
      } else if (json['rating'] is double) {
        safeRating = json['rating'];
      } else if (json['rating'] is String) {
        safeRating = double.tryParse(json['rating']) ?? 0.0;
      }
    }

    return FieldModel(
      id: json['id'] ?? 0,
      nama: json['nama']?.toString() ?? "Tanpa Nama",
      alamat: json['alamat']?.toString() ?? "-",
      rating: safeRating,
      thumbnail: safeThumbnail, 
      isFeatured: json['is_featured'] ?? false,
    );
  }
}

// ==========================================
// 2. PAGE
// ==========================================
class ManageFieldsPage extends StatefulWidget {
  const ManageFieldsPage({super.key});

  @override
  State<ManageFieldsPage> createState() => _ManageFieldsPageState();
}

class _ManageFieldsPageState extends State<ManageFieldsPage> {
  // --- KONFIGURASI ---
  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";

  // --- WARNA ---
  final Color primaryNavy = const Color(0xFF0C2D57);
  final Color accentOrange = const Color(0xFFF97316);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textDark = const Color(0xFF1E293B);
  final Color textGrey = const Color(0xFF64748B);

  // --- STATE ---
  bool _isLoading = true;
  List<FieldModel> _allFields = [];      
  List<FieldModel> _filteredFields = []; 

  String _searchQuery = "";
  String _sortOption = "name_asc"; 

  int _currentPage = 1;
  final int _itemsPerPage = 10;
  final TextEditingController _jumpPageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _jumpPageController.text = "1";
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchFields());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _jumpPageController.dispose();
    super.dispose();
  }

  // --- IMAGE PROVIDER LOGIC (PROXY) ---
  ImageProvider _getImageProvider(String? url) {
    // 1. Jika URL Kosong -> Pakai Default Asset
    if (url == null || url.isEmpty || url == "null") {
      return const AssetImage("assets/images/defaultprofile.png");
    }
    
    // 2. Jika URL Eksternal (http) -> Lewatkan Proxy Django
    if (url.startsWith('http')) {
      String encodedUrl = Uri.encodeComponent(url);
      // Pastikan view 'proxy_image' sudah ada di urls.py Django Anda
      return NetworkImage("$baseUrl/home/proxy-image/?url=$encodedUrl");
    }
    
    // 3. Jika URL Lokal/Relative -> Langsung ke Django Static/Media
    return NetworkImage("$baseUrl$url");
  }

  // --- FETCH DATA ---
  Future<void> _fetchFields({bool isRefresh = false}) async {
    final request = context.read<CookieRequest>();
    if (!isRefresh) setState(() => _isLoading = true);

    try {
      final response = await request.get('$baseUrl/dashboard-admin/lapangan/data/');
      List<dynamic> listData = response['lapangan']; 
      
      List<FieldModel> parsedData = listData.map((d) => FieldModel.fromJson(d)).toList();

      if (mounted) {
        setState(() {
          _allFields = parsedData;
          _applyFilters(); 
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    await _fetchFields(isRefresh: true);
  }

  // --- FILTER & SORT ---
  void _applyFilters() {
    List<FieldModel> temp = List.from(_allFields);

    if (_searchQuery.isNotEmpty) {
      temp = temp.where((f) => 
        f.nama.toLowerCase().contains(_searchQuery.toLowerCase()) || 
        f.alamat.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    switch (_sortOption) {
      case 'name_asc': temp.sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase())); break;
      case 'name_desc': temp.sort((a, b) => b.nama.toLowerCase().compareTo(a.nama.toLowerCase())); break;
      case 'rating_desc': temp.sort((a, b) => b.rating.compareTo(a.rating)); break;
      case 'rating_asc': temp.sort((a, b) => a.rating.compareTo(b.rating)); break;
    }

    setState(() {
      _filteredFields = temp;
      _currentPage = 1; 
      _jumpPageController.text = "1";
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      setState(() {
        _searchQuery = query;
        _applyFilters();
      });
    });
  }

  // --- CRUD ACTIONS ---
  Future<void> _deleteField(int id) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post('$baseUrl/dashboard-admin/lapangan/delete/$id/', {'_method': 'DELETE'});
      if (response['success'] == true) {
        setState(() {
          _allFields.removeWhere((f) => f.id == id);
          _applyFilters();
        });
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lapangan berhasil dihapus")));
      }
    } catch (e) {
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menghapus lapangan")));
    }
  }

  void _showDeleteConfirm(int id) {
  // Cari data lapangan berdasarkan ID untuk menampilkan namanya di modal (opsional tapi bagus untuk UX)
  final fieldData = _allFields.firstWhere((f) => f.id == id, 
      orElse: () => FieldModel(id: 0, nama: "Lapangan", alamat: "", rating: 0, thumbnail: "", isFeatured: false));

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Ikon Visual (Peringatan Aset)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.report_problem_rounded,
              size: 44,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 20),

          // 2. Judul
          Text(
            "Hapus Lapangan?",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: const Color(0xFF0C2D57), // primaryNavy
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // 3. Pesan Konfirmasi dengan Nama Lapangan
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
              children: [
                const TextSpan(text: "Anda akan menghapus "),
                TextSpan(
                  text: fieldData.nama,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const TextSpan(text: ".\n\nSeluruh data terkait lapangan ini akan "),
                const TextSpan(
                  text: "hilang secara permanen",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const TextSpan(text: " dari sistem."),
              ],
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      actions: [
        Row(
          children: [
            // Tombol Batal
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  "Batal",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Tombol Konfirmasi Hapus
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _deleteField(id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  "Hapus Aset",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  void _showFieldForm({FieldModel? field}) {
    final isEdit = field != null;
    final formKey = GlobalKey<FormState>();
    final request = context.read<CookieRequest>();

    String nama = field?.nama ?? "";
    String alamat = field?.alamat ?? "";
    String rating = field?.rating.toString() ?? "0.0";
    String thumbnail = field?.thumbnail ?? "";
    bool isFeatured = field?.isFeatured ?? false;

    showDialog(
      context: context, barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(isEdit ? "Edit Lapangan" : "Tambah Lapangan", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)),
                  InkWell(onTap: () => Navigator.pop(context), borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: const Icon(Icons.close, size: 18, color: Colors.grey))),
                ]),
                const SizedBox(height: 20),
                Flexible(child: SingleChildScrollView(child: Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildLabel("Nama Lapangan", isRequired: true),
                  _buildTextField(initial: nama, hint: "cth: Lapangan A", icon: Icons.sports_tennis_rounded, onChanged: (v) => nama = v, validator: (v) => v!.isEmpty ? "Wajib diisi" : null),
                  const SizedBox(height: 12),
                  _buildLabel("Alamat", isRequired: true),
                  _buildTextField(initial: alamat, hint: "cth: Jl. Margonda", icon: Icons.location_on_outlined, maxLines: 2, onChanged: (v) => alamat = v, validator: (v) => v!.isEmpty ? "Wajib diisi" : null),
                  const SizedBox(height: 12),
                  _buildLabel("Rating (0.0 - 5.0)"),
                  _buildTextField(initial: rating, hint: "0.0", icon: Icons.star_border_rounded, inputType: const TextInputType.numberWithOptions(decimal: true), onChanged: (v) => rating = v),
                  const SizedBox(height: 12),
                  _buildLabel("Thumbnail URL"),
                  _buildTextField(initial: thumbnail, hint: "https://...", icon: Icons.image_outlined, maxLines: 2, onChanged: (v) => thumbnail = v),
                  const SizedBox(height: 12),
                  Row(children: [
                      SizedBox(height: 24, width: 24, child: Checkbox(value: isFeatured, activeColor: accentOrange, onChanged: (val) => setModalState(() => isFeatured = val ?? false))),
                      const SizedBox(width: 8),
                      Text("Tampilkan di Featured?", style: GoogleFonts.inter(fontSize: 14, color: textDark)),
                  ])
                ])))),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: Text("Batal", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textGrey)))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      FocusScope.of(context).unfocus();
                      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
                      try {
                        final payload = jsonEncode({'nama': nama, 'alamat': alamat, 'rating': double.tryParse(rating) ?? 0.0, 'thumbnail_url': thumbnail, 'is_featured': isFeatured});
                        final url = isEdit ? '$baseUrl/dashboard-admin/lapangan/update/${field.id}/' : '$baseUrl/dashboard-admin/lapangan/add/';
                        final response = await request.postJson(url, payload);
                        if(context.mounted) Navigator.pop(context); 
                        if (response['success'] == true) {
                          if(context.mounted) Navigator.pop(context); 
                          _fetchFields(isRefresh: true); 
                          if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil disimpan"), backgroundColor: Colors.green));
                        }
                      } catch (e) {
                         if(context.mounted && Navigator.canPop(context)) Navigator.pop(context);
                      }
                    }
                  }, style: ElevatedButton.styleFrom(backgroundColor: primaryNavy, padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: Text("Simpan", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white))))
                ])
              ]),
            ),
          );
        });
      },
    );
  }

  void _showSortOptions() {
    final Map<String, String> options = {'name_asc': 'Nama (A-Z)', 'name_desc': 'Nama (Z-A)', 'rating_desc': 'Rating Tertinggi', 'rating_asc': 'Rating Terendah'};
    showModalBottomSheet(context: context, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (ctx) => Container(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Urutkan Lapangan", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)), const SizedBox(height: 16), ...options.entries.map((entry) => ListTile(contentPadding: EdgeInsets.zero, title: Text(entry.value, style: GoogleFonts.inter(color: _sortOption == entry.key ? accentOrange : textDark, fontWeight: _sortOption == entry.key ? FontWeight.bold : FontWeight.normal)), trailing: _sortOption == entry.key ? Icon(Icons.check_circle, color: accentOrange) : null, onTap: () { setState(() { _sortOption = entry.key; _applyFilters(); }); Navigator.pop(ctx); }))])));
  }

  List<FieldModel> get _paginatedData {
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (endIndex > _filteredFields.length) endIndex = _filteredFields.length;
    if (startIndex >= _filteredFields.length) return [];
    return _filteredFields.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    final paginatedData = _paginatedData;
    final totalPages = (_filteredFields.isEmpty) ? 1 : (_filteredFields.length / _itemsPerPage).ceil();

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryNavy), onPressed: () => Navigator.pop(context)),
        title: Text("Kelola Lapangan", style: GoogleFonts.poppins(color: primaryNavy, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(children: [
        // 1. TOP SECTION
        Container(
          padding: const EdgeInsets.all(20), color: Colors.white,
          child: Column(children: [
            Row(children: [
              Expanded(child: TextField(controller: _searchController, onChanged: _onSearchChanged, decoration: InputDecoration(hintText: "Cari Lapangan...", prefixIcon: Icon(Icons.search_rounded, color: accentOrange), filled: true, fillColor: bgLight, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
              const SizedBox(width: 10),
              InkWell(onTap: () => _showFieldForm(), borderRadius: BorderRadius.circular(12), child: Container(height: 48, width: 48, decoration: BoxDecoration(color: primaryNavy, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: primaryNavy.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]), child: const Icon(Icons.add_rounded, color: Colors.white, size: 28))),
            ]),
            const SizedBox(height: 12),
            InkWell(onTap: _showSortOptions, child: _buildFilterBox(icon: Icons.sort_rounded, text: "Urutkan", isActive: _sortOption != "name_asc")),
          ]),
        ),

        // 2. LIST DATA
        Expanded(
          child: _isLoading && _allFields.isEmpty
              ? Center(child: CircularProgressIndicator(color: accentOrange))
              : _filteredFields.isEmpty
                  ? Center(child: Text("Tidak ada data lapangan", style: GoogleFonts.inter(color: textGrey)))
                  : RefreshIndicator(
                      onRefresh: _onRefresh, color: accentOrange, backgroundColor: Colors.white,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(20),
                        itemCount: paginatedData.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) => _buildFieldCard(paginatedData[index]),
                      ),
                    ),
        ),

        // 3. PAGINATION
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(color: bgLight, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
          child: SafeArea(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("Hal $_currentPage / $totalPages", style: GoogleFonts.inter(fontSize: 12, color: textGrey)),
            const Spacer(),
            InkWell(onTap: _currentPage > 1 ? () { setState(() { _currentPage--; _jumpPageController.text = "$_currentPage"; }); } : null, borderRadius: BorderRadius.circular(8), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), child: Icon(Icons.chevron_left_rounded, color: _currentPage > 1 ? primaryNavy : Colors.grey.shade300))),
            const SizedBox(width: 8),
            Container(width: 50, height: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), child: Center(child: TextField(controller: _jumpPageController, textAlign: TextAlign.center, keyboardType: TextInputType.number, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: primaryNavy), decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true), onSubmitted: (val) { int? p = int.tryParse(val); if (p != null && p >= 1 && p <= totalPages) { setState(() => _currentPage = p); } else { _jumpPageController.text = "$_currentPage"; } }))),
            const SizedBox(width: 8),
            InkWell(onTap: _currentPage < totalPages ? () { setState(() { _currentPage++; _jumpPageController.text = "$_currentPage"; }); } : null, borderRadius: BorderRadius.circular(8), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), child: Icon(Icons.chevron_right_rounded, color: _currentPage < totalPages ? primaryNavy : Colors.grey.shade300))),
          ])),
        ),
      ]),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildFieldCard(FieldModel field) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: primaryNavy.withOpacity(0.04), offset: const Offset(0, 4), blurRadius: 12)]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(children: [
            
            // --- IMAGE ---
            Container(
              width: 100, constraints: const BoxConstraints(minHeight: 100),
              decoration: BoxDecoration(color: Colors.grey.shade100),
              child: Image(
                // Gunakan Helper _getImageProvider di sini
                image: _getImageProvider(field.thumbnail),
                fit: BoxFit.cover,
                // Loading Spinner
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Center(child: CircularProgressIndicator(color: accentOrange, strokeWidth: 2));
                },
                // Error Fallback: Menampilkan Icon Broken
                errorBuilder: (ctx, error, stackTrace) {
                  return Center(child: Icon(Icons.broken_image_rounded, color: textGrey));
                },
              ),
            ),

            // --- INFO ---
            Expanded(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text(field.nama, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: primaryNavy), maxLines: 2, overflow: TextOverflow.ellipsis)),
                Row(children: [
                   InkWell(onTap: () => _showFieldForm(field: field), child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)), child: Icon(Icons.edit_rounded, color: Colors.blue.shade600, size: 16))),
                   const SizedBox(width: 6),
                   InkWell(onTap: () => _showDeleteConfirm(field.id), child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)), child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 16))),
                ])
              ]),
              const SizedBox(height: 4),
              Row(children: [Icon(Icons.location_on, size: 12, color: textGrey), const SizedBox(width: 4), Expanded(child: Text(field.alamat, style: GoogleFonts.inter(fontSize: 12, color: textGrey), maxLines: 1, overflow: TextOverflow.ellipsis))]),
              const Spacer(), const Divider(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [Icon(Icons.star_rounded, size: 16, color: Colors.amber), const SizedBox(width: 4), Text(field.rating.toString(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: textDark))]),
                if (field.isFeatured) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.amber.withOpacity(0.5))), child: Row(children: [Icon(Icons.verified, size: 10, color: Colors.amber[700]), const SizedBox(width: 4), Text("Featured", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber[800]))])),
              ]),
            ]))),
          ]),
        ),
      ),
    );
  }

  Widget _buildFilterBox({required IconData icon, required String text, bool isActive = false}) {
    return Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), decoration: BoxDecoration(color: isActive ? accentOrange.withOpacity(0.1) : Colors.transparent, border: Border.all(color: isActive ? accentOrange : Colors.grey.shade300), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: isActive ? accentOrange : textGrey), const SizedBox(width: 8), Text(text, style: GoogleFonts.inter(fontSize: 13, color: isActive ? accentOrange : textDark, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)), const SizedBox(width: 4), Icon(Icons.arrow_drop_down, size: 16, color: textGrey)]));
  }
  
  Widget _buildLabel(String text, {bool isRequired = false}) => Padding(padding: const EdgeInsets.only(bottom: 6), child: RichText(text: TextSpan(text: text, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textDark), children: [if (isRequired) const TextSpan(text: " *", style: TextStyle(color: Colors.red))])));
  
  Widget _buildTextField({String initial = "", required String hint, required IconData icon, required Function(String) onChanged, String? Function(String?)? validator, TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(initialValue: initial, keyboardType: inputType, maxLines: maxLines, onChanged: onChanged, validator: validator, style: GoogleFonts.inter(color: textDark), decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14), filled: true, fillColor: bgLight, prefixIcon: Icon(icon, color: textGrey, size: 20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentOrange, width: 1.5)), errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade300, width: 1)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)));
  }
}