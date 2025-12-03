import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../review/review_model.dart';

class ReviewApi {
  static const String base = "https://sean-marcello-sportspace.pbp.cs.ui.ac.id";

  // GET my reviews
  static Future<List<Review>> getMyReviews(String cookie) async {
    final res = await http.get(
      Uri.parse("$base/review/api/user/"),
      headers: {"Cookie": cookie},
    );

    if (res.statusCode != 200) throw Exception("Failed to load reviews");

    final List jsonList = json.decode(res.body);
    return jsonList.map((e) => Review.fromJson(e)).toList();
  }

  // GET reviews of venue
  static Future<List<Review>> getVenueReviews(String cookie, int id) async {
    final res = await http.get(
      Uri.parse("$base/review/api/venue/$id/"),
      headers: {"Cookie": cookie},
    );

    if (res.statusCode != 200) throw Exception("Failed to load venue reviews");

    final List jsonList = json.decode(res.body);
    return jsonList.map((e) => Review.fromJson(e)).toList();
  }

  // POST create review
  static Future<bool> createReview(
      String cookie, int lapangan, String comment, bool anonymous) async {
    final res = await http.post(
      Uri.parse("$base/review/api/create/"),
      headers: {
        "Cookie": cookie,
        "Content-Type": "application/json",
      },
      body: json.encode({
        "lapangan_id": lapangan,
        "comment": comment,
        "anonymous": anonymous,
      }),
    );

    return res.statusCode == 201;
  }

  // PUT update review
  static Future<bool> updateReview(
      String cookie, int id, String comment, bool anonymous) async {
    final res = await http.put(
      Uri.parse("$base/review/api/update/$id/"),
      headers: {
        "Cookie": cookie,
        "Content-Type": "application/json",
      },
      body: json.encode({
        "comment": comment,
        "anonymous": anonymous,
      }),
    );

    return res.statusCode == 200;
  }

  // DELETE review
  static Future<bool> deleteReview(String cookie, int id) async {
    final res = await http.delete(
      Uri.parse("$base/review/api/delete/$id/"),
      headers: {"Cookie": cookie},
    );

    return res.statusCode == 200;
  }
}
