import 'package:flutter/material.dart';

class FriendsPage extends StatelessWidget {
  final List<Map<String, String>> friends = [
    {"username": "gung17", "image": "assets/images/defaultprofile.png"},
    {"username": "jojo", "image": "assets/images/defaultprofile.png"},
    {"username": "mika", "image": "assets/images/defaultprofile.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Teman Saya")),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(friend["image"]!),
            ),
            title: Text(friend["username"]!),

            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  icon: Icon(Icons.chat_bubble_outline),
                  onPressed: () {
                    // buka chat
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: () {
                    // unfriend
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
