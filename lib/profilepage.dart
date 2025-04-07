import 'package:flutter/material.dart';
import 'package:monitorairlaut/main.dart';

class ProfilePage extends StatelessWidget {
  final String userName = "Nama Pengguna";
  final String userImage = "https://via.placeholder.com/100";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: "Profil"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 50, backgroundImage: NetworkImage(userImage)),
            SizedBox(height: 16),
            Text(userName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}