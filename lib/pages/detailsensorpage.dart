import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monitorairlaut/services/sensor_service.dart';
import '../../services/prediction_service.dart';
import '../../widgets/table_widget.dart';
import 'addcardpage.dart';
import '../../widgets/classification_chart.dart';
import '../../widgets/trend_chart.dart';
import '../../widgets/standard_table.dart';
import '../../widgets/value_cards.dart';

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

  String _getKeterangan(String pred, double ph, double turbidity) {
    if (pred != "Tercemar") return "Air laut dalam keadaan baik";

    final reasons = <String>[];
    if (ph <= 7 || ph >= 8.5) reasons.add("pH");
    if (turbidity >= 5) reasons.add("Turbidity");

    return reasons.isNotEmpty
        ? "Tercemar disebabkan tingkat ${reasons.join(', ')}."
        : "Tercemar namun penyebab tidak diketahui.";
  }

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
                IconButton(
                  icon: Icon(Icons.refresh,
                      color: const Color.fromARGB(255, 14, 13, 13)),
                  tooltip: 'Klasifikasi Ulang',
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Memproses Data...')),
                    );
                    try {
                      await classifyAllSensorDataByKey(widget.sensorkey);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Proses selesai')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal memproses data: $e')),
                      );
                    }
                  },
                ),
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
          final turbidity = (latest['turbidity'] ?? 0).toDouble();

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
                  future: getPredictionFromAPI(ph, turbidity),
                  builder: (context, snapshot) {
                    final result = snapshot.data;
                    final prediction =
                        (result == "1") ? "Tidak Tercemar" : "Tercemar";
                    final keterangan =
                        snapshot.connectionState == ConnectionState.done
                            ? _getKeterangan(prediction, ph, turbidity)
                            : "Memuat...";

                    return ValueCardsWidget(
                      latest: latest,
                      quality: snapshot.hasError ? "Error" : prediction,
                      note: keterangan,
                    );
                  },
                ),
                SizedBox(height: 16),
                Text("Table Standar Air Laut",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                StandardTableWidget(),
                SizedBox(height: 24),
                Text("Tren pH dan Turbidity pada 30 Data Terbaru",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                TrendChartWidget(entries: entries),
                SizedBox(height: 24),
                Text(
                    "Persebaran Kualitas Air Laut titik monitoring ${widget.nama}",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                ClassificationChartWidget(entries: entries),
                SizedBox(height: 24),
                Text("Data historis Air Laut titik monitoring ${widget.nama}",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                SensorTable(entries: currentPageEntries, startIndex: start),
                SizedBox(height: 5),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
