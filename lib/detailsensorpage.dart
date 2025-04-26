import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DetailSensorPage extends StatelessWidget {
  final String sensorKey;

  DetailSensorPage({required this.sensorKey});

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail $sensorKey")),
      body: StreamBuilder<DatabaseEvent>(
        stream: _database.child(sensorKey).onValue,
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

            return ListView(
              padding: EdgeInsets.all(16),
              children: sensorData.entries.map((entry) {
                return Card(
                  child: ListTile(
                    title: Text('${entry.key}'),
                    subtitle: Text('${entry.value}'),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
