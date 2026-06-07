import 'package:flutter/material.dart';
import 'screens/pairing_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp Pairing',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PairingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}