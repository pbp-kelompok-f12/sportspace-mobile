import 'package:flutter/material.dart';
import 'review_api.dart';

class AddReviewPage extends StatefulWidget {
  final int venueId;
  final String cookie;

  const AddReviewPage({super.key, required this.venueId, required this.cookie});

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final ctrl = TextEditingController();
  bool anonymous = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Review")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(labelText: "Comment"),
            ),
            Row(
              children: [
                Checkbox(
                  value: anonymous,
                  onChanged: (v) => setState(() => anonymous = v!),
                ),
                const Text("Post as Anonymous"),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                await ReviewApi.createReview(
                  widget.cookie,
                  widget.venueId,
                  ctrl.text,
                  anonymous,
                );
                Navigator.pop(context);
              },
              child: const Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}