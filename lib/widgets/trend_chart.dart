import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TrendChartWidget extends StatelessWidget {
  final List<MapEntry<dynamic, dynamic>> entries;

  const TrendChartWidget({required this.entries, super.key});

  @override
  Widget build(BuildContext context) {
    final phSpots = <FlSpot>[];
    final turbiditySpots = <FlSpot>[];
    final dateLabels = <String>[];

    final displayEntries = entries.take(30).toList().reversed.toList();

    for (int i = 0; i < displayEntries.length; i++) {
      final entry = displayEntries[i];
      final data = entry.value as Map<dynamic, dynamic>;

      final dateParts = entry.key.toString().split('_')[0].split('-');
      final timeParts = entry.key.toString().split('_')[1].split('-');
      final label =
          '${dateParts[2]}/${dateParts[1]} ${timeParts[0]}:${timeParts[1]}';

      dateLabels.add(label);
      phSpots.add(FlSpot(i.toDouble(), (data['ph'] ?? 0).toDouble()));
      turbiditySpots
          .add(FlSpot(i.toDouble(), (data['turbidity'] ?? 0).toDouble()));
    }

    if (displayEntries.isEmpty) {
      return Container(
        height: 250,
        alignment: Alignment.center,
        child: Text('Tidak ada data yang cukup untuk ditampilkan'),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < dateLabels.length) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            dateLabels[value.toInt()],
                            style: TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              minX: 0,
              maxX: displayEntries.length > 1
                  ? (displayEntries.length - 1).toDouble()
                  : 1,
              minY: 0,
              maxY: 14,
              lineBarsData: [
                LineChartBarData(
                  spots: phSpots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  belowBarData: BarAreaData(show: false),
                  dotData: FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: turbiditySpots,
                  isCurved: true,
                  color: Colors.orange,
                  barWidth: 3,
                  belowBarData: BarAreaData(show: false),
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.blue, 'pH'),
            SizedBox(width: 16),
            _buildLegendItem(Colors.orange, 'Turbidity'),
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
