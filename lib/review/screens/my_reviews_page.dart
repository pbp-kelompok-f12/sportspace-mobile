import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/review_api.dart';
import '../models/review_model.dart';
import '../widgets/my_review_card.dart';

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  static const Color primaryNavy = Color(0xFF0D2C3E);
  static const Color softOrange = Color(0xFFFF9F45);
  static const Color softOrangeDark = Color(0xFFF97316);
  static const Color backgroundGrey = Color(0xFFF8FAFC);

  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";

  List<Review> _myReviews = [];
  List<VenueOption> _venueOptions = [];
  bool _isLoading = true;

  String _validFirstReviewDate = "-";
  String _validLatestUpdateDate = "-";
  String _selectedSort = 'created_newest';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Future<void> _fetchData() async {
    final request = context.read<CookieRequest>();
    setState(() => _isLoading = true);
    try {
      final reviews = await ReviewApi.getMyReviews(request);
      final venues = await ReviewApi.getUnreviewedVenues(request);

      String firstDate = "-";
      String lastDate = "-";
      if (reviews.isNotEmpty) {
        List<Review> sortedByDate = List.from(reviews);
        sortedByDate.sort((a, b) => a.reviewedAt.compareTo(b.reviewedAt));
        firstDate = sortedByDate.first.reviewedAt;
        lastDate = sortedByDate.last.reviewedAt;
      }

      setState(() {
        _myReviews = reviews;
        _venueOptions = venues;
        _validFirstReviewDate = firstDate;
        _validLatestUpdateDate = lastDate;
        _isLoading = false;
      });
      _applySorting();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applySorting() {
    setState(() {
      if (_selectedSort == 'created_newest') {
        _myReviews.sort((a, b) => b.id.compareTo(a.id));
      } else if (_selectedSort == 'date_oldest') {
        _myReviews.sort((a, b) => a.reviewedAt.compareTo(b.reviewedAt));
      }
    });
  }

  // --- PERBAIKAN LOGIKA IMAGE URL ---
  String _getVenueImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return ""; 
    }
    // Jika eksternal (http), gunakan proxy endpoint /home/proxy-image/
    if (url.startsWith('http')) {
      String encodedUrl = Uri.encodeComponent(url);
      return "$baseUrl/home/proxy-image/?url=$encodedUrl";
    }
    // Jika internal (path relative), tambahkan baseUrl
    String cleanUrl = url.startsWith('/') ? url : "/$url";
    return "$baseUrl$cleanUrl";
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: softOrange))
          : RefreshIndicator(
              onRefresh: _fetchData,
              color: softOrange,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  // HEADER GRADIENT
                  Container(
                    padding: const EdgeInsets.only(bottom: 30, top: 60, left: 20, right: 20),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [softOrange, softOrangeDark],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "My Reviews",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Berbagi pengalaman bermainmu di SportSpace",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // KONTEN UTAMA
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatCard(),
                        
                        // Filter Row
                        Row(
                          children: [
                            _buildSortChip('Terbaru', 'created_newest'),
                            const SizedBox(width: 8),
                            _buildSortChip('Terlama', 'date_oldest'),
                          ],
                        ),
                        const SizedBox(height: 20),

                        if (_myReviews.isEmpty)
                          _buildEmptyState()
                        else
                          _buildReviewGrid(request),
                        
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(request),
        backgroundColor: primaryNavy,
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
        label: Text(
          "Tulis Review",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildStatCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.rate_review_rounded, "${_myReviews.length}", "Total"),
          _buildStatDivider(),
          _buildStatItem(Icons.calendar_today_rounded, _validFirstReviewDate, "Pertama"),
          _buildStatDivider(),
          _buildStatItem(Icons.history_rounded, _validLatestUpdateDate, "Terbaru"),
        ],
      ),
    );
  }

  Widget _buildStatDivider() => Container(width: 1, height: 30, color: Colors.grey.shade100);

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: softOrange, size: 20),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: primaryNavy)),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _selectedSort == value;
    return ChoiceChip(
      label: Text(label),
      labelStyle: GoogleFonts.poppins(
        color: isSelected ? Colors.white : primaryNavy,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      selected: isSelected,
      selectedColor: primaryNavy,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? primaryNavy : primaryNavy.withOpacity(0.1)),
      ),
      onSelected: (_) {
        setState(() => _selectedSort = value);
        _applySorting();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("Belum ada review", style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildReviewGrid(CookieRequest request) {
    List<Widget> rows = [];
    for (int i = 0; i < _myReviews.length; i += 2) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildReviewCardItem(request, _myReviews[i])),
                const SizedBox(width: 16),
                Expanded(
                  child: i + 1 < _myReviews.length 
                    ? _buildReviewCardItem(request, _myReviews[i + 1]) 
                    : const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildReviewCardItem(CookieRequest request, Review review) {
    // PEMANGGILAN FUNGSI BARU DI SINI
    String url = _getVenueImageUrl(review.venueImage);
    
    return MyReviewCard(
      review: review,
      imageUrl: url,
      onEdit: () => _showEditDialog(request, review),
      onDelete: () => _showDeleteDialog(request, review.id),
    );
  }

  // --- Logic Dialog Add/Edit/Delete (Tetap Sama) ---
  void _showAddDialog(CookieRequest request) {
    int? selectedVenueId;
    final commentCtrl = TextEditingController();
    bool isAnonymous = false;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Beri Review", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryNavy)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pilih Lapangan", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(15),
                  decoration: InputDecoration(
                    filled: true, fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  hint: const Text("Pilih venue..."),
                  value: selectedVenueId,
                  items: _venueOptions.map((v) => DropdownMenuItem(value: v.id, child: Text(v.name))).toList(),
                  onChanged: (val) => setStateDialog(() => selectedVenueId = val),
                ),
                const SizedBox(height: 16),
                Text("Komentar", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: commentCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Bagaimana lapangannya?",
                    filled: true, fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isAnonymous,
                      activeColor: primaryNavy,
                      onChanged: (v) => setStateDialog(() => isAnonymous = v ?? false),
                    ),
                    Text("Anonim", style: GoogleFonts.poppins(fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: isSubmitting ? null : () async {
                if (selectedVenueId == null || commentCtrl.text.isEmpty) return;
                setStateDialog(() => isSubmitting = true);
                final res = await ReviewApi.createReview(request, selectedVenueId!, commentCtrl.text, isAnonymous);
                if (res['status'] == 'success') {
                  if (context.mounted) Navigator.pop(context);
                  _fetchData();
                }
              },
              child: const Text("Kirim", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  void _showEditDialog(CookieRequest request, Review review) {
    final editCtrl = TextEditingController(text: review.comment);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Edit Review", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: editCtrl, maxLines: 3,
          decoration: InputDecoration(
            filled: true, fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              Navigator.pop(context);
              await ReviewApi.updateReview(request, review.id, editCtrl.text, review.isAnonymous);
              _fetchData();
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(CookieRequest request, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Review?"),
        content: const Text("Review ini akan dihapus secara permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await ReviewApi.deleteReview(request, id);
              _fetchData();
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}