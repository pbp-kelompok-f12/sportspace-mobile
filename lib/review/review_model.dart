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
  final int views;

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
    required this.views,
  });

  factory Review.fromJson(Map json) {
    return Review(
      id: json['id'],
      venueName: json['venue_name'],
      venueImage: json['venue_image'],
      reviewerName: json['reviewer_name'],
      reviewerImage: json['reviewer_image'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      isAnonymous: json['is_anonymous'],
      reviewedAt: json['reviewed_at'],
      views: json['views'],
    );
  }
}