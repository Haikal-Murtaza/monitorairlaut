import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monitorairlaut/pages/addcardpage.dart';
import 'package:monitorairlaut/widgets/card_search_field.dart';
import 'package:monitorairlaut/widgets/sensor_card_tile.dart';

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
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => AddCardPage())),
        tooltip: 'Tambah Card',
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          CardSearchField(controller: _searchController),
          Expanded(
            child: _filteredCards.isEmpty
                ? Center(child: Text('Tidak ada data sensor'))
                : ListView.builder(
                    itemCount: _filteredCards.length,
                    itemBuilder: (context, index) {
                      final doc = _filteredCards[index];
                      return SensorCardTile(
                        nama: doc['nama'],
                        deskripsi: doc['deskripsi'],
                        sensorKey: doc['sensorKey'],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
