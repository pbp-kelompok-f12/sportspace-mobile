import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class Create1v1Page extends StatelessWidget {
  const Create1v1Page({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Match 1v1")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Create 1v1"),
          onPressed: () async {
            await request.post(
              'http://10.0.2.2:8000/matchmaking/create-1v1/',
              {},
            );
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
