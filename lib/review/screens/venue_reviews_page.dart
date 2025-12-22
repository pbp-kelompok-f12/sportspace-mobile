import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../services/review_api.dart';
import '../models/review_model.dart';
import '../widgets/venue_review_card.dart';

class VenueReviewsPage extends StatefulWidget {
  final int venueId;
  final String venueName;
  final String venueImageUrl; 

  const VenueReviewsPage({
    super.key,
    required this.venueId,
    required this.venueName,
    required this.venueImageUrl, 
  });

  @override
  State<VenueReviewsPage> createState() => _VenueReviewsPageState();
}

class _VenueReviewsPageState extends State<VenueReviewsPage> {
  Future<List<Review>>? _futureReviews;
  final TextEditingController _emptyCtrl = TextEditingController();
  bool _emptyAnonymous = false;
  bool _isSubmitting = false;
  String _selectedSort = 'newest';

  static const Color primaryNavy = Color(0xFF0D2C3E);
  static const Color softOrange = Color(0xFFFF9F45);
  static const Color softOrangeDark = Color(0xFFF97316);
  static const Color backgroundGrey = Color(0xFFF8FAFC);
  static const Color textGrey = Color(0xFF64748B);

  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";

  ImageProvider _getVenueImage(String? url) {
    if (url == null || url.isEmpty || url == "null") {
      return const AssetImage("assets/images/imagenotavail.png");
    }
    if (url.startsWith('http')) {
      String encodedUrl = Uri.encodeComponent(url);
      return NetworkImage("$baseUrl/review/proxy-image/?url=$encodedUrl");
    }
    return NetworkImage("$baseUrl$url");
  }

  void _showAddReviewDialog(CookieRequest request) {
    final commentCtrl = TextEditingController();
    bool isAnonymous = false;
    bool isSubmittingDialog = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              "Review ${widget.venueName}",
              style: GoogleFonts.poppins(color: primaryNavy, fontWeight: FontWeight.bold, fontSize: 18)
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your Experience", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: textGrey)),
                const SizedBox(height: 8),
                TextField(
                  controller: commentCtrl,
                  maxLines: 4,
                  maxLength: 150,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: backgroundGrey,
                    hintText: "How was the court? Tell us...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      activeColor: softOrangeDark,
                      value: isAnonymous,
                      onChanged: (val) => setStateDialog(() => isAnonymous = val ?? false),
                    ),
                    Text("Post as Anonymous", style: GoogleFonts.poppins(fontSize: 13, color: primaryNavy)),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: GoogleFonts.poppins(color: textGrey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: isSubmittingDialog ? null : () async {
                  if (commentCtrl.text.trim().isEmpty) return;
                  setStateDialog(() => isSubmittingDialog = true);
                  try {
                    final res = await ReviewApi.createReview(request, widget.venueId, commentCtrl.text, isAnonymous);
                    if (res['status'] == 'success') {
                      if (context.mounted) Navigator.pop(context);
                      setState(() { _futureReviews = ReviewApi.getVenueReviews(request, widget.venueId); });
                    }
                  } catch (e) {}
                },
                child: isSubmittingDialog 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text("Post", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    _futureReviews ??= ReviewApi.getVenueReviews(request, widget.venueId);

    String currentUsername = "";
    try { if (request.jsonData.isNotEmpty) currentUsername = request.jsonData['username'] ?? ""; } catch (e) {}

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: FutureBuilder<List<Review>>(
        future: _futureReviews,
        builder: (context, snapshot) {
          final reviews = snapshot.data ?? [];
          
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. GAMBAR VENUE (HEADER)
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                elevation: 0,
                backgroundColor: primaryNavy,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Image(
                    image: _getVenueImage(widget.venueImageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      "assets/images/imagenotavail.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // 2. INFORMASI VENUE (NAMA & RATING) - PASTI DI BAWAH GAMBAR
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.venueName,
                        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: primaryNavy),
                      ),
                      const SizedBox(height: 12),
                      _buildRatingSummary(reviews),
                    ],
                  ),
                ),
              ),

              // 3. SORT CHIPS
              if (reviews.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Row(
                      children: [
                        _buildSortChip('Terbaru', 'newest'),
                        const SizedBox(width: 8),
                        _buildSortChip('Terlama', 'oldest'),
                      ],
                    ),
                  ),
                ),

              // 4. REVIEW LIST ATAU EMPTY STATE
              snapshot.connectionState == ConnectionState.waiting
                ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: softOrangeDark)))
                : reviews.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyStateContent(request))
                    : _buildReviewGrid(reviews),
            ],
          );
        },
      ),
      floatingActionButton: FutureBuilder<List<Review>>(
        future: _futureReviews,
        builder: (context, snapshot) {
          final reviews = snapshot.data ?? [];
          if (hasUserReviewed(reviews, currentUsername)) return const SizedBox();
          return FloatingActionButton.extended(
            heroTag: "fab_venue_review_unique",
            backgroundColor: primaryNavy,
            onPressed: () => _showAddReviewDialog(request),
            icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
            label: Text("Write Review", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          );
        },
      ),
    );
  }

  Widget _buildReviewGrid(List<Review> reviews) {
    List<Review> sortedReviews = List.from(reviews);
    if (_selectedSort == 'newest') {
      sortedReviews.sort((a, b) => b.reviewedAt.compareTo(a.reviewedAt));
    } else {
      sortedReviews.sort((a, b) => a.reviewedAt.compareTo(b.reviewedAt));
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 190, 
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => VenueReviewCard(review: sortedReviews[index]),
          childCount: sortedReviews.length,
        ),
      ),
    );
  }

  Widget _buildRatingSummary(List<Review> reviews) {
    double avgRating = reviews.isNotEmpty 
        ? (reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length) 
        : 0.0;
    return Row(
      children: [
        Text(avgRating.toStringAsFixed(1), style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: primaryNavy)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: List.generate(5, (index) => Icon(index < avgRating.round() ? Icons.star_rounded : Icons.star_outline_rounded, color: const Color(0xFFFFC107), size: 18))),
            Text("${reviews.length} ulasan", style: GoogleFonts.poppins(color: textGrey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildSortChip(String label, String value) {
    bool isSelected = _selectedSort == value;
    return ChoiceChip(
      label: Text(label, style: GoogleFonts.poppins(color: isSelected ? Colors.white : primaryNavy, fontSize: 12)),
      selected: isSelected,
      selectedColor: softOrangeDark,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300)),
      onSelected: (bool selected) { if (selected) setState(() => _selectedSort = value); },
    );
  }

  bool hasUserReviewed(List<Review> reviews, String username) {
    if (username.isEmpty) return false;
    return reviews.any((r) => r.reviewerName == username);
  }

  Widget _buildEmptyStateContent(CookieRequest request) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text("Belum ada review", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: primaryNavy)),
          Text("Jadilah yang pertama mereview venue ini!", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: textGrey)),
          const SizedBox(height: 32),
          _buildFirstReviewInput(request),
        ],
      ),
    );
  }

  Widget _buildFirstReviewInput(CookieRequest request) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your Comment", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryNavy)),
          const SizedBox(height: 12),
          TextField(
            controller: _emptyCtrl,
            maxLength: 150, maxLines: 3,
            decoration: InputDecoration(hintText: "Write review...", filled: true, fillColor: backgroundGrey, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
          ),
          Row(
            children: [
              Checkbox(activeColor: softOrangeDark, value: _emptyAnonymous, onChanged: (val) => setState(() => _emptyAnonymous = val ?? false)),
              Text("Post as Anonymous", style: GoogleFonts.poppins(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: softOrangeDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: _isSubmitting ? null : () async {
                if (_emptyCtrl.text.trim().isEmpty) return;
                setState(() => _isSubmitting = true);
                await ReviewApi.createReview(request, widget.venueId, _emptyCtrl.text, _emptyAnonymous);
                setState(() { _futureReviews = ReviewApi.getVenueReviews(request, widget.venueId); _isSubmitting = false; });
              },
              child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : Text("Submit Review", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}