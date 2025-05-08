import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../services/prediction_service.dart';
import '../../widgets/line_chart_widget.dart';
import '../../widgets/value_card_widget.dart';
import '../../widgets/table_widget.dart';

class DetailSensorPage extends StatefulWidget {
  final String nama;
  final String sensorkey;
  final String deskripsi;

  DetailSensorPage({
    required this.nama,
    required this.sensorkey,
    required this.deskripsi,
  });

  @override
  State<DetailSensorPage> createState() => _DetailSensorPageState();
}

class _DetailSensorPageState extends State<DetailSensorPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  int currentPage = 0;
  final int itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.nama)),
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
                              ? "Layak"
                              : "Tidak Layak";
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
                        ValueCard(label: "Prediksi", value: predictionResult),
                      ],
                    );
                  },
                ),
                SizedBox(height: 24),
                Text("Tabel Data",
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
                SizedBox(height: 24),
                Text("Grafik pH",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                    height: 200,
                    child: LineChartWidget(values: phList, color: Colors.blue)),
                SizedBox(height: 16),
                Text("Grafik TDS",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                    height: 200,
                    child:
                        LineChartWidget(values: tdsList, color: Colors.green)),
                SizedBox(height: 16),
                Text("Grafik Turbidity",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                    height: 200,
                    child: LineChartWidget(
                        values: turbidityList, color: Colors.orange)),
              ],
            ),
          );
        },
      ),
    );
  }
}
