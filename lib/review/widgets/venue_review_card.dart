import 'package:flutter/material.dart';
import '../models/review_model.dart';

class VenueReviewCard extends StatelessWidget {
  final Review review;
  final String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";

  const VenueReviewCard({super.key, required this.review});

  String _getProxiedUrl(String originalUrl) {
    if (originalUrl.isEmpty) return "";
    String targetUrl = originalUrl;
    if (originalUrl.startsWith('/')) {
      targetUrl = "$baseUrl$originalUrl";
    }
    String encodedUrl = Uri.encodeComponent(targetUrl);
    return "$baseUrl/review/proxy-image/?url=$encodedUrl";
  }

  String _timeAgo(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      final date2 = DateTime.now();
      final difference = date2.difference(date);

      if (difference.inDays > 7) {
        return dateString;
      } else if ((difference.inDays / 7).floor() >= 1) {
        return '1 minggu lalu';
      } else if (difference.inDays >= 2) {
        return '${difference.inDays} hari lalu';
      } else if (difference.inDays >= 1) {
        return 'Kemarin';
      } else if (difference.inHours >= 1) {
        return '${difference.inHours} jam lalu';
      } else if (difference.inMinutes >= 1) {
        return '${difference.inMinutes} menit lalu';
      } else {
        return 'Baru saja';
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    String avatarUrl = review.reviewerImage;
    bool hasAvatar = avatarUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: Colors.grey.shade400,
                child: hasAvatar
                    ? ClipOval(
                  child: Image.network(
                    _getProxiedUrl(avatarUrl),
                    fit: BoxFit.cover,
                    width: 34,
                    height: 34,
                    errorBuilder: (c, e, s) => const Icon(Icons.person, size: 16, color: Colors.white),
                  ),
                )
                    : const Icon(Icons.person, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      _timeAgo(review.reviewedAt),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(
                  5,
                      (index) => Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFC107),
                    size: 14,
                  )),
              const SizedBox(width: 4),
              Text("${review.rating}/5.0",
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              review.comment,
              style: const TextStyle(fontSize: 12),
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}