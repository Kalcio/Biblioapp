import 'package:flutter/material.dart';

class Book implements Comparable {
  final int id;
  final String name;
  final String autor;
  final int year;

  const Book({
    required this.id,
    required this.name,
    required this.autor,
    required this.year,
  });

  @override
  int compareTo(covariant Book other) => other.id.compareTo(other.id);

  @override
  bool operator ==(covariant Book other) => id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Book, id = $id, name: $name, autor: $autor, year: $year';
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioapp Beta'),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    ),
  );
}
