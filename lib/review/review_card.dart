import 'package:flutter/material.dart';
import '../../review/review_model.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReviewCard({super.key, required this.review, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: review.reviewerImage.isNotEmpty
              ? NetworkImage(review.reviewerImage)
              : null,
          child: review.reviewerImage.isEmpty ? const Icon(Icons.person) : null,
        ),
        title: Text(review.venueName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(review.comment),
            const SizedBox(height: 4),
            Text("${review.rating} ★"),
          ],
        ),
        trailing: onEdit != null
            ? PopupMenuButton(
          onSelected: (value) {
            if (value == "edit") onEdit!();
            if (value == "delete") onDelete!();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: "edit", child: Text("Edit")),
            const PopupMenuItem(value: "delete", child: Text("Delete")),
          ],
        )
            : null,
      ),
    );
  }
}