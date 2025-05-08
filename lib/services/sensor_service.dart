import 'package:firebase_database/firebase_database.dart';

class SensorService {
  static Future<String> getLatestSensorValue(String sensorKey) async {
    final ref = FirebaseDatabase.instance.ref(sensorKey);
    final snapshot = await ref.limitToLast(1).get();
    if (snapshot.exists && snapshot.children.isNotEmpty) {
      final last = snapshot.children.first.value;
      return last.toString();
    }
    return "Tidak ada data";
  }
}
