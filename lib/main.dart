import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import './views/HomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Pharm Aware app',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
