import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../services/review_api.dart';
import '../models/review_model.dart';
import '../widgets/my_review_card.dart';

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  final Color _headerBlue = const Color(0xFF638ECB);
  final Color _titleOrange = const Color(0xFFE87C26);
  final Color _submitGreen = const Color(0xFF709F13);

  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";

  String _getProxiedUrl(String originalUrl) {
    if (originalUrl.isEmpty) return "";
    if (originalUrl.startsWith("http")) return originalUrl;

    String targetUrl = originalUrl;
    if (!targetUrl.startsWith('/')) targetUrl = "/$targetUrl";

    String finalTarget = "$baseUrl$targetUrl";
    String encodedUrl = Uri.encodeComponent(finalTarget);

    return "$baseUrl/review/proxy-image/?url=$encodedUrl";
  }

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
      debugPrint("Error fetching data: $e");
      setState(() => _isLoading = false);
    }
  }

  void _applySorting() {
    setState(() {
      if (_selectedSort == 'created_newest') {
        _myReviews.sort((a, b) => b.id.compareTo(a.id));
      } else if (_selectedSort == 'date_updated') {
        _myReviews.sort((a, b) => b.reviewedAt.compareTo(a.reviewedAt));
      } else if (_selectedSort == 'date_oldest') {
        _myReviews.sort((a, b) => a.reviewedAt.compareTo(b.reviewedAt));
      }
    });
  }

  Widget _buildPersonalStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.rate_review, "${_myReviews.length}", "Total Reviews"),
          Container(width: 1, height: 40, color: Colors.blue.shade200),
          _buildStatItem(Icons.history, _validFirstReviewDate, "First Review"),
          Container(width: 1, height: 40, color: Colors.blue.shade200),
          _buildStatItem(Icons.update, _validLatestUpdateDate, "Latest Update"),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: _headerBlue, size: 24),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: _headerBlue, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
      ],
    );
  }

  Widget _buildSortChip(String label, String value) {
    bool isSelected = _selectedSort == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedColor: _headerBlue,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? _headerBlue : Colors.grey.shade300)),
      onSelected: (bool selected) { if (selected) { setState(() { _selectedSort = value; }); _applySorting(); } },
    );
  }

  void _showAddDialog(CookieRequest request) {
    int? selectedVenueId;
    final commentCtrl = TextEditingController();
    bool isAnonymous = false;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            scrollable: true,
            insetPadding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text("Write a Review", style: TextStyle(color: _titleOrange, fontWeight: FontWeight.bold, fontSize: 20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Select Court", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  menuMaxHeight: 250,
                  borderRadius: BorderRadius.circular(12),
                  hint: const Text("Choose a venue..."),
                  value: selectedVenueId,
                  items: _venueOptions.map((v) => DropdownMenuItem(value: v.id, child: Text(v.name, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (val) => setStateDialog(() => selectedVenueId = val),
                  decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 16),
                const Text("Your Experience", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: commentCtrl, maxLines: 4, maxLength: 150,
                  decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade100, hintText: "Tell us what you think...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                ),
                Row(
                  children: [
                    Checkbox(activeColor: _submitGreen, value: isAnonymous, onChanged: (val) => setStateDialog(() => isAnonymous = val ?? false)),
                    const Text("Post as Anonymous", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _submitGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                onPressed: isSubmitting ? null : () async {
                  if (selectedVenueId == null || commentCtrl.text.isEmpty) return;
                  setStateDialog(() => isSubmitting = true);
                  try {
                    final res = await ReviewApi.createReview(request, selectedVenueId!, commentCtrl.text, isAnonymous);
                    if (res['status'] == 'success') { if (context.mounted) Navigator.pop(context); _fetchData(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Review posted!"))); }
                  } catch (e) { /* Error */ }
                },
                child: isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Post", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditDialog(CookieRequest request, Review review) {
    final editCtrl = TextEditingController(text: review.comment);
    bool isAnonymous = review.isAnonymous;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Review", style: TextStyle(color: _headerBlue, fontWeight: FontWeight.bold)),
        content: TextField(controller: editCtrl, maxLines: 3, maxLength: 150, decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _headerBlue),
            onPressed: () async { Navigator.pop(context); await ReviewApi.updateReview(request, review.id, editCtrl.text, isAnonymous); _fetchData(); },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(CookieRequest request, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Review?"), content: const Text("Are you sure? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async { Navigator.pop(context); await ReviewApi.deleteReview(request, id); _fetchData(); },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    List<Widget> reviewRows = [];
    if (_myReviews.isNotEmpty) {
      for (int i = 0; i < _myReviews.length; i += 2) {
        // ITEM KIRI
        final review1 = _myReviews[i];
        String url1 = "";
        if (review1.venueImage != null && review1.venueImage!.isNotEmpty) {
          url1 = _getProxiedUrl(review1.venueImage!);
        }

        Review? review2;
        String url2 = "";
        if (i + 1 < _myReviews.length) {
          review2 = _myReviews[i + 1];
          if (review2.venueImage != null && review2.venueImage!.isNotEmpty) {
            url2 = _getProxiedUrl(review2.venueImage!);
          }
        }

        reviewRows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: MyReviewCard(
                      review: review1,
                      imageUrl: url1,
                      onEdit: () => _showEditDialog(request, review1),
                      onDelete: () => _showDeleteDialog(request, review1.id),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: review2 != null
                        ? MyReviewCard(
                      review: review2,
                      imageUrl: url2,
                      onEdit: () => _showEditDialog(request, review2!),
                      onDelete: () => _showDeleteDialog(request, review2!.id),
                    )
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: false,
        iconTheme: IconThemeData(color: _titleOrange),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
        title: Text("My Reviews", style: TextStyle(color: _titleOrange, fontWeight: FontWeight.w800, fontSize: 18)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1.0), child: Container(color: Colors.grey.shade200, height: 1.0)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _headerBlue))
          : RefreshIndicator(
        onRefresh: _fetchData, color: _submitGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPersonalStats(),
                if (_myReviews.isNotEmpty) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSortChip('Terbaru', 'created_newest'), const SizedBox(width: 8),
                        _buildSortChip('Terlama', 'date_oldest'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_myReviews.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text("No Reviews Yet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                else
                  Column(children: reviewRows), // Render Row List
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _headerBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Write Review", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showAddDialog(request),
      ),
    );
  }
}