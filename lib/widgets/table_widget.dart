import 'package:flutter/material.dart';

class SensorTable extends StatelessWidget {
  final List<MapEntry<dynamic, dynamic>> entries;

  const SensorTable({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(),
      columnWidths: {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[300]),
          children: [
            _buildHeader('Timestamp'),
            _buildHeader('pH'),
            _buildHeader('TDS'),
            _buildHeader('Turbidity'),
          ],
        ),
        ...entries.map((entry) {
          final timestamp = entry.key.toString();
          final value = entry.value as Map<dynamic, dynamic>;
          return TableRow(children: [
            _buildCell(timestamp),
            _buildCell((value['ph'] ?? '-').toString()),
            _buildCell((value['tds'] ?? '-').toString()),
            _buildCell((value['turbidity'] ?? '-').toString()),
          ]);
        }),
      ],
    );
  }

  Widget _buildHeader(String text) => Padding(
        padding: EdgeInsets.all(8),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _buildCell(String text) => Padding(
        padding: EdgeInsets.all(8),
        child: Text(text),
      );
}
