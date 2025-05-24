import 'package:flutter/material.dart';
import 'package:monitorairlaut/pages/detailsensorpage.dart';
import 'package:monitorairlaut/services/sensor_service.dart';

class SensorCardTile extends StatelessWidget {
  final String nama;
  final String deskripsi;
  final String sensorKey;
  final String cardid;

  const SensorCardTile({
    required this.nama,
    required this.sensorKey,
    required this.deskripsi,
    required this.cardid,
  });
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: SensorService.getLatestSensorValue(sensorKey),
      builder: (context, snapshot) {
        final sensorValue = snapshot.connectionState == ConnectionState.done
            ? snapshot.data ?? "Tidak ada data"
            : "Memuat...";
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(nama),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(deskripsi),
                Text("Data Sensor: $sensorValue"),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailSensorPage(
                    nama: nama,
                    sensorkey: sensorKey,
                    deskripsi: deskripsi,
                    cardid: cardid,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
