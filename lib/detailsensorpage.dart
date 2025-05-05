import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DetailSensorPage extends StatelessWidget {
  final String nama;
  final String sensorkey;
  final String deskripsi;

  DetailSensorPage({
    required this.nama,
    required this.sensorkey,
    required this.deskripsi,
  });

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(nama)),
      body: StreamBuilder<DatabaseEvent>(
        stream: _database.child(sensorkey).onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.snapshot.exists) {
            return Center(child: Text('Data tidak ditemukan'));
          } else {
            Map<dynamic, dynamic> sensorData =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

            final sortedEntries = sensorData.entries.toList()
              ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));

            final List<double> phList = [];
            final List<double> tdsList = [];
            final List<double> turbidityList = [];

            sortedEntries.forEach((entry) {
              final value = entry.value as Map<dynamic, dynamic>;
              phList.add((value['ph'] ?? 0).toDouble());
              tdsList.add((value['tds'] ?? 0).toDouble());
              turbidityList.add((value['turbidity'] ?? 0).toDouble());
            });

            final latest = sortedEntries.last.value as Map<dynamic, dynamic>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deskripsi
                  Text('Deskripsi:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(deskripsi, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 16),

                  // 3 Card kecil
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildValueCard("pH", latest['ph'].toString()),
                      _buildValueCard("TDS", latest['tds'].toString()),
                      _buildValueCard(
                          "Turbidity", latest['turbidity'].toString()),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Tabel Data
                  Table(
                    border: TableBorder.all(),
                    columnWidths: {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                    },
                    children: [
                      // Header
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey[300]),
                        children: [
                          _buildTableHeader('Timestamp'),
                          _buildTableHeader('pH'),
                          _buildTableHeader('TDS'),
                          _buildTableHeader('Turbidity'),
                        ],
                      ),
                      // Data Rows
                      ...sortedEntries.map((entry) {
                        final timestamp = entry.key.toString();
                        final value = entry.value as Map<dynamic, dynamic>;
                        final ph = value['ph'] ?? '-';
                        final tds = value['tds'] ?? '-';
                        final turbidity = value['turbidity'] ?? '-';

                        return TableRow(
                          children: [
                            _buildTableCell(timestamp),
                            _buildTableCell(ph.toString()),
                            _buildTableCell(tds.toString()),
                            _buildTableCell(turbidity.toString()),
                          ],
                        );
                      }).toList(),
                    ],
                  ),

                  SizedBox(height: 24),
                  Text("Grafik pH",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                      height: 200, child: _buildLineChart(phList, Colors.blue)),

                  SizedBox(height: 16),
                  Text("Grafik TDS",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                      height: 200,
                      child: _buildLineChart(tdsList, Colors.green)),

                  SizedBox(height: 16),
                  Text("Grafik Turbidity",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                      height: 200,
                      child: _buildLineChart(turbidityList, Colors.orange)),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Widget untuk card nilai terbaru
  Widget _buildValueCard(String label, String value) {
    return Card(
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(12),
        width: 100,
        child: Column(
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // Widget untuk grafik
  Widget _buildLineChart(List<double> values, Color color) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              values.length,
              (index) => FlSpot(index.toDouble(), values[index]),
            ),
            isCurved: true,
            color: color,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: false),
      ),
    );
  }

  // Helper untuk cell tabel
  Widget _buildTableHeader(String text) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(text),
    );
  }
}
