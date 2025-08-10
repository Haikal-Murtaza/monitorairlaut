import 'package:flutter/material.dart';

class StandardTableWidget extends StatelessWidget {
  final data = {
    "pH": "7 - 8.5",
    "Turbidity": "0 - 5 NTU",
  };

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[300]),
          children: [
            _tableCell("Parameter", isBold: true),
            _tableCell("Rentang Nilai", isBold: true),
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
}
