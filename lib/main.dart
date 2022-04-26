import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sattus_firebase_tutorial/main/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Pioneers',
      home: MainScreen(),
    );
  }
}
