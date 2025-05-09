import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:monitorairlaut/pages/datamonitoringpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDXloYnsHwp4Id7gFWZ1ClDk_XGt5WIYH0",
      projectId: "monitorairlaut",
      storageBucket: "monitorairlaut.appspot.com",
      messagingSenderId: "661878093654",
      appId: "1:661878093654:android:4f7339cea1bd56afe048f7",
      databaseURL:
          "https://monitorairlaut-default-rtdb.asia-southeast1.firebasedatabase.app",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitoring App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DataMonitoringPage(),
    );
  }
}
