import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:monitorairlaut/pages/addcardpage.dart';
import '../../services/prediction_service.dart';
import '../../widgets/value_card_widget.dart';
import '../../widgets/table_widget.dart';

class DetailSensorPage extends StatefulWidget {
  final String nama;
  final String sensorkey;
  final String deskripsi;
  final String cardid;

  const DetailSensorPage({
    required this.nama,
    required this.sensorkey,
    required this.deskripsi,
    required this.cardid,
  });

  @override
  State<DetailSensorPage> createState() => _DetailSensorPageState();
}

class _DetailSensorPageState extends State<DetailSensorPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  int currentPage = 0;
  final int itemsPerPage = 5;

  Future<void> deleteCard() async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('cards').doc(widget.cardid).delete();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Card berhasil dihapus")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus card: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek apakah user sudah login
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nama),
        actions: [
          if (currentUser != null) ...[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddCardPage(
                      isEdit: true,
                      sensorKey: widget.sensorkey,
                      nama: widget.nama,
                      deskripsi: widget.deskripsi,
                      cardid: widget.cardid,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Konfirmasi Hapus"),
                    content:
                        Text("Apakah Anda yakin ingin menghapus card ini?"),
                    actions: [
                      TextButton(
                        child: Text("Batal"),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton(
                        child: Text("Hapus"),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await deleteCard();
                }
              },
            ),
          ],
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _database.child(widget.sensorkey).onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.snapshot.exists) {
            return Center(child: Text('Data tidak ditemukan'));
          }

          Map<dynamic, dynamic> sensorData =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          final sortedEntries = sensorData.entries.toList()
            ..sort((a, b) => b.key.toString().compareTo(a.key.toString()));

          final latest = sortedEntries.first.value as Map<dynamic, dynamic>;

          final List<double> phList = [];
          final List<double> tdsList = [];
          final List<double> turbidityList = [];

          for (var entry in sortedEntries) {
            final value = entry.value as Map<dynamic, dynamic>;
            phList.add((value['ph'] ?? 0).toDouble());
            tdsList.add((value['tds'] ?? 0).toDouble());
            turbidityList.add((value['turbidity'] ?? 0).toDouble());
          }

          final start = currentPage * itemsPerPage;
          final end = (start + itemsPerPage > sortedEntries.length)
              ? sortedEntries.length
              : start + itemsPerPage;
          final currentPageEntries = sortedEntries.sublist(start, end);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deskripsi:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(widget.deskripsi, style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
                FutureBuilder<String>(
                  future: getPredictionFromAPI(
                    (latest['ph'] ?? 0).toDouble(),
                    (latest['tds'] ?? 0).toDouble(),
                    (latest['turbidity'] ?? 0).toDouble(),
                  ),
                  builder: (context, snapshot) {
                    String predictionResult = "Memuat...";
                    if (snapshot.connectionState == ConnectionState.done) {
                      predictionResult = snapshot.hasError
                          ? "Error"
                          : snapshot.data == "1"
                              ? "Tidak Tercemar"
                              : "Tercemar";
                    }

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ValueCard(
                                label: "pH", value: latest['ph'].toString()),
                            ValueCard(
                                label: "TDS", value: latest['tds'].toString()),
                            ValueCard(
                                label: "Turbidity",
                                value: latest['turbidity'].toString()),
                          ],
                        ),
                        SizedBox(height: 16),
                        ValueCard(label: "Kualitas", value: predictionResult),
                      ],
                    );
                  },
                ),
                SizedBox(height: 24),
                Text("Data pH, TDS, Turbidity Air Laut ${widget.nama}",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                SensorTable(entries: currentPageEntries),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: currentPage > 0
                          ? () => setState(() => currentPage--)
                          : null,
                      child: Text("Sebelumnya"),
                    ),
                    ElevatedButton(
                      onPressed: end < sortedEntries.length
                          ? () => setState(() => currentPage++)
                          : null,
                      child: Text("Selanjutnya"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
