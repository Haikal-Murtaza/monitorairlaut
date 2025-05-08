import 'package:flutter/material.dart';

class CardSearchField extends StatelessWidget {
  final TextEditingController controller;

  const CardSearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Cari Titik Monitoring',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
