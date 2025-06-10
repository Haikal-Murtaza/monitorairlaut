import 'package:flutter/material.dart';

class SensorTable extends StatelessWidget {
  final List<MapEntry<dynamic, dynamic>> entries;
  final int startIndex;

  const SensorTable({
    required this.entries,
    required this.startIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FixedColumnWidth(50),
        1: FixedColumnWidth(90),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
        4: FlexColumnWidth(),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[300]),
          children: [
            _headerCell("No"),
            _headerCell("Tanggal"),
            _headerCell("pH"),
            _headerCell("TDS"),
            _headerCell("Turbidity"),
          ],
        ),
        for (int i = 0; i < entries.length; i++)
          TableRow(children: [
            _cell((startIndex + i + 1).toString()),
            _cell(_formatTimestamp(entries[i].key.toString())),
            _cell(entries[i].value['ph'].toString()),
            _cell(entries[i].value['tds'].toString()),
            _cell(entries[i].value['turbidity'].toString()),
          ]),
      ],
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final parts = timestamp.split('_');
      if (parts.length != 2) return timestamp;

      final datePart = parts[0];
      final timePart = parts[1];

      final dateFormatted = datePart.split('-').reversed.join('-');
      final timeFormatted = timePart.replaceAll('-', ':');

      return '$dateFormatted\n$timeFormatted';
    } catch (e) {
      return timestamp;
    }
  }

  Widget _headerCell(String text) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ));

  Widget _cell(String text) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text, textAlign: TextAlign.center),
      );
}
