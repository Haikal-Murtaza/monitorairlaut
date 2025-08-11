import 'package:flutter/material.dart';

class SensorTable extends StatefulWidget {
  final List<MapEntry<dynamic, dynamic>> entries;

  const SensorTable({
    required this.entries,
    Key? key,
  }) : super(key: key);

  @override
  State<SensorTable> createState() => _SensorTableState();
}

class _SensorTableState extends State<SensorTable> {
  int currentPage = 0;
  final int itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    final start = currentPage * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, widget.entries.length);
    final currentPageEntries = widget.entries.sublist(start, end);
    final totalPages = (widget.entries.length / itemsPerPage).ceil();

    return Column(
      children: [
        Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: const {
            0: FixedColumnWidth(50),
            1: FixedColumnWidth(90),
            2: FixedColumnWidth(70),
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
                _headerCell("Turbidity"),
                _headerCell("Kualitas"),
              ],
            ),
            for (int i = 0; i < currentPageEntries.length; i++)
              TableRow(children: [
                _cell((start + i + 1).toString()),
                _cell(_formatTimestamp(currentPageEntries[i].key.toString())),
                _cell(currentPageEntries[i].value['ph'].toString()),
                _cell(currentPageEntries[i].value['turbidity'].toString()),
                _cell(
                    currentPageEntries[i].value['prediction_label'].toString()),
              ]),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed:
                  currentPage > 0 ? () => setState(() => currentPage--) : null,
              child: const Text("Sebelumnya"),
            ),
            Text(
              'Halaman ${currentPage + 1}/$totalPages',
              style: const TextStyle(fontSize: 14),
            ),
            ElevatedButton(
              onPressed: end < widget.entries.length
                  ? () => setState(() => currentPage++)
                  : null,
              child: const Text("Selanjutnya"),
            ),
          ],
        ),
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
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );

  Widget _cell(String text) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text, textAlign: TextAlign.center),
      );
}
