import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/prediction_service.dart';
import '../../widgets/value_card_widget.dart';
import '../../widgets/table_widget.dart';
import 'addcardpage.dart';

class DetailSensorPage extends StatefulWidget {
  final String nama, sensorkey, deskripsi, cardid;

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
  final _dbRef = FirebaseDatabase.instance.ref();
  int currentPage = 0;
  final itemsPerPage = 5;

  Future<void> _deleteCard() async {
    try {
      await FirebaseFirestore.instance
          .collection('cards')
          .doc(widget.cardid)
          .delete();
      if (mounted) {
        Navigator.pop(context);
        _showMessage("Card berhasil dihapus");
      }
    } catch (e) {
      _showMessage("Gagal menghapus card: $e");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi Hapus"),
        content: Text("Apakah Anda yakin ingin menghapus card ini?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Batal")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Hapus")),
        ],
      ),
    );
    if (confirm == true) await _deleteCard();
  }

  Widget _buildValueCards(
      Map<dynamic, dynamic> latest, String quality, String note) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          ValueCard(label: "pH", value: latest['ph'].toString()),
          ValueCard(label: "TDS", value: latest['tds'].toString()),
          ValueCard(label: "Turbidity", value: latest['turbidity'].toString())
        ]),
        SizedBox(height: 16),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ValueCard(label: "Kualitas", value: quality)]),
        SizedBox(height: 16),
        SizedBox(
            width: double.infinity,
            child: ValueCard(label: "Keterangan", value: note))
      ],
    );
  }

  String _getKeterangan(String pred, double ph, double tds, double turbidity) {
    if (pred != "Tercemar") return "Air laut dalam keadaan baik";

    final reasons = <String>[];
    if (ph <= 7 || ph >= 8.5) reasons.add("pH");
    if (tds <= 18000 || tds >= 35000) reasons.add("TDS");
    if (turbidity <= 1 || turbidity >= 5) reasons.add("Turbidity");

    return reasons.isNotEmpty
        ? "Tercemar disebabkan tingkat ${reasons.join(', ')}."
        : "Tercemar namun penyebab tidak diketahui.";
  }

  Widget _buildStandardTable() {
    final data = {
      "pH": "7 - 8.5",
      "TDS": "18000 - 22000 ppm",
      "Turbidity": "0 - 5 NTU",
    };

    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[300]),
          children: [
            _tableCell("Parameter", isBold: true),
            _tableCell("Rentang Nilai (Aman)", isBold: true),
          ],
        ),
        ...data.entries.map((e) => TableRow(children: [
              _tableCell(e.key),
              _tableCell(e.value),
            ])),
      ],
    );
  }

  Widget _tableCell(String text, {bool isBold = false}) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text,
            style: isBold ? TextStyle(fontWeight: FontWeight.bold) : null),
      );

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nama),
        actions: currentUser != null
            ? [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => Navigator.push(
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
                  ),
                ),
                IconButton(icon: Icon(Icons.delete), onPressed: _confirmDelete),
              ]
            : [],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _dbRef.child(widget.sensorkey).onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.snapshot.exists) {
            return Center(child: Text('Data tidak ditemukan'));
          }

          final sensorData =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final entries = sensorData.entries.toList()
            ..sort((a, b) => b.key.toString().compareTo(a.key.toString()));
          final latest = entries.first.value as Map<dynamic, dynamic>;

          final start = currentPage * itemsPerPage;
          final end = (start + itemsPerPage).clamp(0, entries.length);
          final currentPageEntries = entries.sublist(start, end);

          final ph = (latest['ph'] ?? 0).toDouble();
          final tds = (latest['tds'] ?? 0).toDouble();
          final turbidity = (latest['turbidity'] ?? 0).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Deskripsi:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(widget.deskripsi, style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              FutureBuilder<String>(
                future: getPredictionFromAPI(ph, tds, turbidity),
                builder: (context, snapshot) {
                  final result = snapshot.data;
                  final prediction =
                      (result == "1") ? "Tidak Tercemar" : "Tercemar";
                  final keterangan =
                      snapshot.connectionState == ConnectionState.done
                          ? _getKeterangan(prediction, ph, tds, turbidity)
                          : "Memuat...";

                  return _buildValueCards(latest,
                      snapshot.hasError ? "Error" : prediction, keterangan);
                },
              ),
              SizedBox(height: 16),
              Text("Standar Air Laut Tidak Tercemar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildStandardTable(),
              SizedBox(height: 24),
              Text("Data pH, TDS, Turbidity Air Laut ${widget.nama}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              SensorTable(
                entries: currentPageEntries,
                startIndex: start,
              ),
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
                    onPressed: end < entries.length
                        ? () => setState(() => currentPage++)
                        : null,
                    child: Text("Selanjutnya"),
                  ),
                ],
              ),
            ]),
          );
        },
      ),
    );
  }
}
