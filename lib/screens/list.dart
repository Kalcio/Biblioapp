import 'dart:async';
// import 'dart:js';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'crud.dart';
import 'package:biblioapp/book_model.dart';

class ListBook {
  final String dbName;
  Database? _db;
  List<Book> _books = [];
  final _streamController = StreamController<List<Book>>.broadcast();

  ListBook({required this.dbName});

  //Read
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
}

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late final BookDB _list;

  @override
  void initState() {
    _list = BookDB(dbName: 'db.sqlite');
    _list.open();
    super.initState();
  }

  @override
  void dispose() {
    _list.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioapp Beta'),
      ),
    );
  }
}
