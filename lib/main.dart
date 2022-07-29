import 'dart:async';
// import 'dart:js';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/crud.dart';
import 'widgets/menu.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const appTitle = 'BiblioAPP';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: appTitle,
      home: CrudPage(),
    );
  }
}
