import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/review_model.dart';

class ReviewApi {
  static const String baseUrl = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";

  static Future<List<Review>> getVenueReviews(CookieRequest request, int venueId) async {
    final response = await request.get('$baseUrl/review/api/venue/$venueId/');
    List<Review> list = [];
    for (var d in response) {
      if (d != null) list.add(Review.fromJson(d));
    }
    return list;
  }

  static Future<List<Review>> getMyReviews(CookieRequest request) async {
    final response = await request.get('$baseUrl/review/api/my-reviews/');
    List<Review> list = [];
    for (var d in response) {
      if (d != null) list.add(Review.fromJson(d));
    }
    return list;
  }

  static Future<List<VenueOption>> getUnreviewedVenues(CookieRequest request) async {
    final response = await request.get('$baseUrl/review/api/unreviewed-venues/');
    List<VenueOption> list = [];
    for (var d in response) {
      if (d != null) list.add(VenueOption.fromJson(d));
    }
    return list;
  }

  static Future<Map<String, dynamic>> createReview(
      CookieRequest request, int venueId, String comment, bool anonymous) async {
    final response = await request.post(
      '$baseUrl/review/api/create/',
      jsonEncode({
        'lapangan_id': venueId,
        'comment': comment,
        'anonymous': anonymous,
      }),
    );
    return response;
  }

  static Future<Map<String, dynamic>> updateReview(
      CookieRequest request, int reviewId, String comment, bool anonymous) async {
    final response = await request.post(
      '$baseUrl/review/api/update/$reviewId/',
      jsonEncode({
        'comment': comment,
        'anonymous': anonymous,
      }),
    );
    return response;
  }

  static Future<Map<String, dynamic>> deleteReview(
      CookieRequest request, int reviewId) async {
    final response = await request.post(
      '$baseUrl/review/api/delete/$reviewId/',
      {},
    );
    return response;
  }
}