import 'package:flutter/material.dart';
import 'review_api.dart';
import 'review_model.dart';
import 'review_card.dart';

class MyReviewsPage extends StatefulWidget {
  final String cookie;

  const MyReviewsPage({super.key, required this.cookie});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  List<Review> reviews = [];
  bool loading = true;

  void loadData() async {
    reviews = await ReviewApi.getMyReviews(widget.cookie);
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text("My Reviews")),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: reviews.length,
        itemBuilder: (context, i) {
          return ReviewCard(
            review: reviews[i],
            onEdit: () async {
              await ReviewApi.updateReview(
                widget.cookie,
                reviews[i].id,
                reviews[i].comment + " (edited)",
                reviews[i].isAnonymous,
              );
              loadData();
            },
            onDelete: () async {
              await ReviewApi.deleteReview(widget.cookie, reviews[i].id);
              loadData();
            },
          );
        },
      ),
    );
  }
}