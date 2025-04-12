import 'package:flutter/material.dart';
import 'package:monitorairlaut/main.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: "Monitoring App"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Deskripsi",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                      "Aplikasi ini bertujuan untuk memantau titik-titik penting secara real-time."),
                  SizedBox(height: 16),
                  Text("Tentang Kami",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                      "Monitoring App dikembangkan untuk keperluan pengawasan dan dokumentasi."),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
