import 'package:firebase_database/firebase_database.dart';
import 'prediction_service.dart';

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

Future<void> classifyAllSensorDataByKey(String sensorKey) async {
  try {
    final sensorRef = FirebaseDatabase.instance.ref(sensorKey);
    final sensorSnapshot = await sensorRef.get();

    if (sensorSnapshot.exists) {
      // Iterasi melalui semua timestamp di bawah sensorKey
      for (final timestampEntry in sensorSnapshot.children) {
        final timestampKey = timestampEntry.key ?? '';
        final rawData = timestampEntry.value;

        if (rawData is! Map) continue;

        final data = Map<String, dynamic>.from(rawData);
        final ph = data['ph'];
        final turbidity = data['turbidity'];
        final klasifikasi = data['klasifikasi'];

        // Skip jika data tidak lengkap atau sudah diklasifikasi
        if (ph == null || turbidity == null || klasifikasi != null) continue;

        // Dapatkan prediksi dari API (0 atau 1)
        final prediction = await getPredictionFromAPI(
          double.parse(ph.toString()),
          double.parse(turbidity.toString()),
        );

        // Simpan prediksi ke database
        if (prediction == "0" || prediction == "1") {
          await sensorRef.child(timestampKey).update({
            'klasifikasi': prediction,
            'prediction_label':
                prediction == "1" ? "Tidak Tercemar" : "Tercemar"
          });
          print('Data $timestampKey telah diklasifikasi: $prediction');
        }
      }
    }
  } catch (e) {
    print("Error classifying data for sensor $sensorKey: $e");
    rethrow;
  }
}
