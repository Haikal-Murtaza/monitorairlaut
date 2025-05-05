import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:monitorairlaut/addcardpage.dart';
import 'package:monitorairlaut/detailsensorpage.dart';

class DataMonitoringPage extends StatefulWidget {
  @override
  _DataMonitoringPageState createState() => _DataMonitoringPageState();
}

class _DataMonitoringPageState extends State<DataMonitoringPage> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _allCards = [];
  List<DocumentSnapshot> _filteredCards = [];

  @override
  void initState() {
    super.initState();
    _fetchCards();
    _fetchSensorKeysFromRealtimeDatabase();
    _searchController.addListener(_onSearchChanged);
  }

  void _fetchCards() {
    FirebaseFirestore.instance
        .collection('cards')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _allCards = snapshot.docs;
        _filteredCards = snapshot.docs;
      });
    });
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCards = _allCards.where((doc) {
        final name = doc['nama'].toString().toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchSensorKeysFromRealtimeDatabase() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.get();
    if (snapshot.exists) {
      snapshot.children.map((child) => child.key ?? '').toList();
      setState(() {});
    }
  }

  Future<String> _getLatestSensorValue(String sensorKey) async {
    final ref = FirebaseDatabase.instance.ref(sensorKey);
    final snapshot = await ref.limitToLast(1).get();
    if (snapshot.exists && snapshot.children.isNotEmpty) {
      final last = snapshot.children.first.value;
      return last.toString();
    }
    return "Tidak ada data";
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCardPage(),
            ),
          );
        },
        tooltip: 'Tambah Card',
        child: Icon(Icons.add),
      ),
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
            child: _filteredCards.isEmpty
                ? Center(child: Text('Tidak ada data sensor'))
                : ListView.builder(
                    itemCount: _filteredCards.length,
                    itemBuilder: (context, index) {
                      final doc = _filteredCards[index];
                      final nama = doc['nama'];
                      final deskripsi = doc['deskripsi'];
                      final sensorKey = doc['sensorKey'];

                      return FutureBuilder<String>(
                        future: _getLatestSensorValue(sensorKey),
                        builder: (context, snapshot) {
                          final sensorValue =
                              snapshot.connectionState == ConnectionState.done
                                  ? snapshot.data
                                  : "Memuat...";
                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              title: Text(nama),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(deskripsi),
                                  Text("Data Sensor: $sensorValue"),
                                ],
                              ),
                              trailing: Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailSensorPage(nama: nama,sensorkey: sensorKey, deskripsi: deskripsi),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
