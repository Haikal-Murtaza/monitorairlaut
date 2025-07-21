import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> getPredictionFromAPI(double ph, double turbidity) async {
  final url = Uri.parse("https://naive-bayes-api.onrender.com/predict");

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'ph': ph, 'turbidity': turbidity}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['prediction'].toString();
  } else {
    return "Error";
  }
}
