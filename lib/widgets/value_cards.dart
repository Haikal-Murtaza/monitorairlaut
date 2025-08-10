import 'package:flutter/material.dart';
import '../../widgets/value_card_widget.dart';

class ValueCardsWidget extends StatelessWidget {
  final Map<dynamic, dynamic> latest;
  final String quality;
  final String note;

  const ValueCardsWidget({
    required this.latest,
    required this.quality,
    required this.note,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ValueCard(label: "pH", value: latest['ph'].toString()),
            ValueCard(
                label: "Turbidity", value: latest['turbidity'].toString()),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ValueCard(label: "Kualitas", value: quality)],
        ),
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ValueCard(label: "Keterangan", value: note),
        ),
      ],
    );
  }
}
