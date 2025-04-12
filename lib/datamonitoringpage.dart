import 'package:flutter/material.dart';
import 'package:monitorairlaut/main.dart';

class DataMonitoringPage extends StatelessWidget {
  final List<String> dataPoints = ["Titik 1", "Titik 2", "Titik 3", "Titik 4"];
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: "Monitoring Data"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Titik Monitoring',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                // logika filter bisa ditambahkan
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dataPoints.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text(dataPoints[index]),
                    subtitle: Text("Status: Aktif"),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
