import 'package:flutter/material.dart';

class FriendRequestsPage extends StatelessWidget {
  final List<String> requests = ["aryo", "kevin", "vania"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Permintaan Pertemanan")),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final username = requests[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage("assets/images/defaultprofile.png"),
            ),
            title: Text(username),
            trailing: Wrap(
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    // accept friend
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    // reject friend
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
