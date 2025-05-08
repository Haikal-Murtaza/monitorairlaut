import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:monitorairlaut/pages/addcardpage.dart';
import 'package:monitorairlaut/pages/loginpage.dart';
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
  User? _currentUser;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _fetchCards();
    _searchController.addListener(_onSearchChanged);
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
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

  void _handleAuthAction() {
    if (_currentUser == null) {
      showDialog(
        context: context,
        builder: (context) => LoginDialog(),
      );
    } else {
      FirebaseAuth.instance.signOut();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          "Monitoring Data",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: _handleAuthAction,
              child: Text(
                _currentUser == null ? 'Login' : 'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _currentUser != null
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddCardPage()),
              ),
              tooltip: 'Tambah Card',
              backgroundColor: Colors.green,
              child: Icon(Icons.add),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CardSearchField(controller: _searchController),
            Expanded(
              child: _filteredCards.isEmpty
                  ? Center(child: Text('Tidak ada data sensor'))
                  : ListView.builder(
                      itemCount: _filteredCards.length,
                      itemBuilder: (context, index) {
                        final doc = _filteredCards[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: SensorCardTile(
                            nama: doc['nama'],
                            deskripsi: doc['deskripsi'],
                            sensorKey: doc['sensorKey'],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
