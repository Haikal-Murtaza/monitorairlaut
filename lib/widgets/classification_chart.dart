import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ClassificationChartWidget extends StatelessWidget {
  final List<MapEntry<dynamic, dynamic>> entries;

  const ClassificationChartWidget({required this.entries, super.key});

  @override
  Widget build(BuildContext context) {
    int tercemarCount = 0;
    int tidakTercemarCount = 0;

    for (var entry in entries) {
      final data = entry.value as Map<dynamic, dynamic>;
      if (data['klasifikasi'] != null) {
        if (data['klasifikasi'] == '0') {
          tercemarCount++;
        } else if (data['klasifikasi'] == '1') {
          tidakTercemarCount++;
        }
      }
    }

    final total = tercemarCount + tidakTercemarCount;
    if (total == 0) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text('Tidak ada data klasifikasi'),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: tidakTercemarCount.toDouble(),
                  color: Colors.green,
                  title:
                      '${((tidakTercemarCount / total) * 100).toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: tercemarCount.toDouble(),
                  color: Colors.red,
                  title:
                      '${((tercemarCount / total) * 100).toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              startDegreeOffset: 180,
            ),
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.green, 'Tidak Tercemar'),
            SizedBox(width: 16),
            _buildLegendItem(Colors.red, 'Tercemar'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
