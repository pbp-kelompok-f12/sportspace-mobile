import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class Create2v2Page extends StatefulWidget {
  const Create2v2Page({super.key});

  @override
  State<Create2v2Page> createState() => _Create2v2PageState();
}

class _Create2v2PageState extends State<Create2v2Page> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();

    return Scaffold(
      appBar: AppBar(title: const Text("Buat Match 2v2")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Nama Teman"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Create 2v2"),
              onPressed: () async {
                await request.post(
                  'http://10.0.2.2:8000/matchmaking/create-2v2/',
                  {"teammate": controller.text},
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
