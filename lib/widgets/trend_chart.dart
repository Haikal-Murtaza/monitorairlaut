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

    final firstLabel = dateLabels.isNotEmpty ? dateLabels.first : '';
    final lastLabel = dateLabels.length > 1 ? dateLabels.last : '';
    final middleLabel =
        dateLabels.length > 2 ? dateLabels[dateLabels.length ~/ 2] : '';

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
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
                        if (value.toInt() == 0) {
                          return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(firstLabel,
                                  style: TextStyle(fontSize: 10)));
                        }
                        if (value.toInt() == displayEntries.length - 1) {
                          return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(lastLabel,
                                  style: TextStyle(fontSize: 10)));
                        }
                        if (middleLabel.isNotEmpty &&
                            value.toInt() == displayEntries.length ~/ 2) {
                          return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(middleLabel,
                                  style: TextStyle(fontSize: 10)));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
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
