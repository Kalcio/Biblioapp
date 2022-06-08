import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

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

  Book.fromRow(Map<String, Object?> row)
      : id = row['ID'] as int,
        name = row['NAME'] as String,
        autor = row['AUTOR'] as String,
        year = row['YEAR'] as int;

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

class BookDB {
  final String dbName;
  Database? _db;
  List<Book> _books = [];
  final _streamController = StreamController<List<Book>>.broadcast();

  BookDB(this.dbName);

  Future<List<Book>> _fetchBook() async {
    final db = _db;
    if (db == null) {
      return [];
    }
    try {
      final read = await db.query('BOOK',
          distinct: true,
          columns: [
            'ID',
            'NAME',
            'AUTOR',
            'YEAR',
          ],
          orderBy: 'ID');

      final book = read.map((row) => Book.fromRow(row)).toList();
      return book;
    } catch (e) {
      print('Error fetching book = $e');
      return [];
    }
  }

  Future<bool> close() async {
    final db = _db;
    if (db == null) {
      return false;
    }
    await db.close();
    return true;
  }

  Future<bool> open() async {
    if (_db != null) {
      return true;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$dbName';

    try {
      final db = await openDatabase(path);
      _db = db;

      //Create table
      const create = '''CREATE TABLE IF NOT EXIST BOOK(
        ID INTEGER PRIMARY KEY AUTOINCREMENT
        NAME STRING NOT NULL
        AUTOR STRING NOT NULL
        YEAR INT NOT NULL
      )''';

      await db.execute(create);

      _books = await _fetchBook();
      _streamController.add(_books);
      return true;
    } catch (e) {
      print('Error = $e');
      return false;
    }
  }
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
