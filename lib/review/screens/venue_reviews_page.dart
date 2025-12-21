import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../services/review_api.dart';
import '../models/review_model.dart';
import '../widgets/venue_review_card.dart';

class VenueReviewsPage extends StatefulWidget {
  final int venueId;
  final String venueName;

  const VenueReviewsPage({
    super.key,
    required this.venueId,
    required this.venueName
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

  final Color _headerBlue = const Color(0xFF638ECB);
  final Color _titleOrange = const Color(0xFFE87C26);
  final Color _submitGreen = const Color(0xFF709F13);

  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";

  String _getProxiedUrl(String originalUrl) {
    if (originalUrl.isEmpty) return "";

    if (originalUrl.startsWith("http")) {
      return originalUrl;
    }

    String targetUrl = originalUrl;
    if (originalUrl.startsWith('/')) {
      targetUrl = "$baseUrl$originalUrl";
    }

    String encodedUrl = Uri.encodeComponent(targetUrl);
    return "$baseUrl/review/proxy-image/?url=$encodedUrl";
  }

  String _getStaticUrl(String path) {
    if (path.startsWith('/')) {
      return "$baseUrl$path";
    }
    return "$baseUrl/$path";
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
            scrollable: true,
            insetPadding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

            title: Text(
                "Review ${widget.venueName}",
                style: TextStyle(color: _titleOrange, fontWeight: FontWeight.bold, fontSize: 20)
            ),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Your Experience", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: commentCtrl,
                  maxLines: 4,
                  maxLength: 150,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    hintText: "How was the court? Tell us...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        activeColor: _submitGreen,
                        value: isAnonymous,
                        onChanged: (val) => setStateDialog(() => isAnonymous = val ?? false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text("Post as Anonymous", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),

            actionsAlignment: MainAxisAlignment.end,
            actionsPadding: const EdgeInsets.only(bottom: 20, right: 20),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _submitGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: isSubmittingDialog ? null : () async {
                  if (commentCtrl.text.trim().isEmpty) return;
                  setStateDialog(() => isSubmittingDialog = true);
                  try {
                    final res = await ReviewApi.createReview(request, widget.venueId, commentCtrl.text, isAnonymous);

                    if (res['status'] == 'success') {
                      if (context.mounted) Navigator.pop(context);

                      setState(() {
                        _futureReviews = ReviewApi.getVenueReviews(request, widget.venueId);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Review posted successfully!")));
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Failed")));
                        setStateDialog(() => isSubmittingDialog = false);
                      }
                    }
                  } catch (e) {
                    if (context.mounted) setStateDialog(() => isSubmittingDialog = false);
                  }
                },
                child: isSubmittingDialog
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Post", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    try {
      if (request.jsonData.isNotEmpty) {
        currentUsername = request.jsonData['username'] ?? "";
      }
    } catch (e) {
    }

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: _titleOrange),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Reviews for ${widget.venueName}",
          style: TextStyle(
            color: _titleOrange,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),

      body: FutureBuilder(
        future: _futureReviews,
        builder: (context, AsyncSnapshot<List<Review>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _headerBlue));
          }

          List<Review> reviews = List.from(snapshot.data ?? []);

          if (reviews.isEmpty) {
            return _buildEmptyState(request);
          }

          if (_selectedSort == 'newest') {
            reviews.sort((a, b) => b.reviewedAt.compareTo(a.reviewedAt));
          } else if (_selectedSort == 'oldest') {
            reviews.sort((a, b) => a.reviewedAt.compareTo(b.reviewedAt));
          }

          String? venueImageUrl = reviews.isNotEmpty ? reviews[0].venueImage : null;

          List<Widget> reviewRows = [];
          if (reviews.isNotEmpty) {
            for (int i = 0; i < reviews.length; i += 2) {
              final review1 = reviews[i];
              Review? review2;
              if (i + 1 < reviews.length) {
                review2 = reviews[i + 1];
              }

              reviewRows.add(
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: VenueReviewCard(review: review1)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: review2 != null
                              ? VenueReviewCard(review: review2)
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
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: (venueImageUrl != null && venueImageUrl.isNotEmpty)
                            ? Image.network(
                          _getProxiedUrl(venueImageUrl),
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                                child: CircularProgressIndicator(color: _headerBlue)
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(
                              _getStaticUrl("/static/img/no-photo-venue.png"),
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Center(
                                child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                              ),
                            );
                          },
                        )
                            : Image.network(
                          _getStaticUrl("/static/img/no-photo-venue.png"),
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Center(
                            child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildRatingSummary(reviews),

                    const SizedBox(height: 12),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSortChip('Terbaru', 'newest'),
                          const SizedBox(width: 8),
                          _buildSortChip('Terlama', 'oldest'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Column(children: reviewRows),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            floatingActionButton: (!hasUserReviewed(reviews, currentUsername))
                ? FloatingActionButton.extended(
              backgroundColor: _headerBlue,
              onPressed: () => _showAddReviewDialog(request),
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text("Write Review", style: TextStyle(color: Colors.white)),
            )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    bool isSelected = _selectedSort == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: _headerBlue,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? _headerBlue : Colors.grey.shade300,
        ),
      ),
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedSort = value;
          });
        }
      },
    );
  }

  Widget _buildRatingSummary(List<Review> reviews) {
    double totalRating = 0;
    for (var r in reviews) {
      totalRating += r.rating;
    }
    double avgRating = reviews.isNotEmpty ? (totalRating / reviews.length) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _headerBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < avgRating.round() ? Icons.star : Icons.star_border,
                            color: const Color(0xFFFFC107),
                            size: 16,
                          );
                        }),
                      ),
                      Text(
                        "dari ${reviews.length} ulasan",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool hasUserReviewed(List<Review> reviews, String username) {
    return reviews.any((r) => r.reviewerName == username);
  }

  Widget _buildEmptyState(CookieRequest request) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            Image.network(
              _getStaticUrl("/static/img/no-reviews1.png"),
              height: 120,
              errorBuilder: (ctx, err, stack) => const Icon(
                  Icons.rate_review,
                  size: 80,
                  color: Colors.grey
              ),
            ),
            const SizedBox(height: 20),

            const Text("Belum ada review", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              "Jadilah yang pertama mereview\n${widget.venueName}!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 40),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Your Comment", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emptyCtrl,
              maxLength: 150,
              maxLines: 5,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                hintText: "Write your review here...",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _emptyAnonymous,
                  onChanged: _isSubmitting ? null : (val) => setState(() => _emptyAnonymous = val ?? false),
                ),
                const Text("Post as Anonymous"),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _submitGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _isSubmitting ? null : () async { await _submitEmptyReview(request); },
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit First Review", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitEmptyReview(CookieRequest request) async {
    if (_emptyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi komentar dulu!")));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final res = await ReviewApi.createReview(request, widget.venueId, _emptyCtrl.text.trim(), _emptyAnonymous);
      if (res["status"] == "success") {
        setState(() {
          _futureReviews = ReviewApi.getVenueReviews(request, widget.venueId);
          _emptyCtrl.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Review berhasil ditambahkan!")));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res["error"] ?? "Gagal")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
