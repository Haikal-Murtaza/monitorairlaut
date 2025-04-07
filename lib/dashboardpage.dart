import 'package:flutter/material.dart';
import 'package:monitorairlaut/main.dart';
import 'dart:async';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<String> carouselImages = [
    'https://via.placeholder.com/400x200',
    'https://via.placeholder.com/400x200/888',
    'https://via.placeholder.com/400x200/444',
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _carouselTimer = Timer.periodic(Duration(seconds: 3), (_) {
      if (_pageController.hasClients) {
        _currentPage++;
        if (_currentPage >= carouselImages.length) {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: "Monitoring App"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: carouselImages.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    carouselImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Deskripsi",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                      "Aplikasi ini bertujuan untuk memantau titik-titik penting secara real-time."),
                  SizedBox(height: 16),
                  Text("Tentang Kami",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
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
