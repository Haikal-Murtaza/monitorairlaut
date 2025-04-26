import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:monitorairlaut/detailsensorpage.dart';

class DataMonitoringPage extends StatefulWidget {
  @override
  _DataMonitoringPageState createState() => _DataMonitoringPageState();
}

class _DataMonitoringPageState extends State<DataMonitoringPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController _searchController = TextEditingController();
  List<String> _allSensorKeys = [];
  List<String> _filteredSensorKeys = [];

  @override
  void initState() {
    super.initState();
    _listenSensorKeys();
    _searchController.addListener(_onSearchChanged);
  }

  void _listenSensorKeys() {
    _database.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot;
      if (data.exists) {
        List<String> keys = [];
        for (var child in data.children) {
          keys.add(child.key ?? 'Unknown');
        }
        setState(() {
          _allSensorKeys = keys;
          _filteredSensorKeys = keys;
        });
      } else {
        setState(() {
          _allSensorKeys = [];
          _filteredSensorKeys = [];
        });
      }
    });
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSensorKeys = _allSensorKeys
          .where((key) => key.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Monitoring Data")),
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
            ),
          ),
          Expanded(
            child: _filteredSensorKeys.isEmpty
                ? Center(child: Text('Tidak ada data sensor'))
                : ListView.builder(
                    itemCount: _filteredSensorKeys.length,
                    itemBuilder: (context, index) {
                      final sensorName = _filteredSensorKeys[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Icon(Icons.location_on),
                          title: Text(sensorName),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailSensorPage(sensorKey: sensorName),
                              ),
                            );
                          },
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
