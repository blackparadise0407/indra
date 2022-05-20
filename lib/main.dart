import 'package:flutter/material.dart';
import 'package:indra/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  final String title = "Indra";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.deepPurple.shade300,
      ),
      home: const HomeScreen(),
    );
  }
}
