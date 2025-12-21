class Review {
  final int id;
  final String venueName;
  final String venueImage;
  final String reviewerName;
  final String reviewerImage;
  final double rating;
  final String comment;
  final bool isAnonymous;
  final String reviewedAt;

  Review({
    required this.id,
    required this.venueName,
    required this.venueImage,
    required this.reviewerName,
    required this.reviewerImage,
    required this.rating,
    required this.comment,
    required this.isAnonymous,
    required this.reviewedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      venueName: json['venue_name'] ?? "Unknown Court",
      venueImage: json['venue_image'] ?? "",
      reviewerName: json['reviewer_name'] ?? "Anonymous",
      reviewerImage: json['reviewer_image'] ?? "",
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? "",
      isAnonymous: json['is_anonymous'] ?? false,
      reviewedAt: json['reviewed_at'] ?? "",
    );
  }
}

class VenueOption {
  final int id;
  final String name;

  VenueOption({required this.id, required this.name});

  factory VenueOption.fromJson(Map<String, dynamic> json) {
    return VenueOption(
      id: json['id'],
      name: json['name'],
    );
  }
}