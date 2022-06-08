import 'dart:async';
// import 'dart:js';
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

  String get fullBook => '$name - $autor';

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

  BookDB({required this.dbName});

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

  Future<bool> create(String name, String autor, int year) async {
    final db = _db;
    if (db == null) {
      return false;
    }
    try {
      final id = await db.insert('BOOK', {
        'NAME': name,
        'AUTOR': autor,
        'YEAR': year,
      });
      final book = Book(
        id: id,
        name: name,
        autor: autor,
        year: year,
      );
      _books.add(book);
      _streamController.add(_books);
      return true;
    } catch (e) {
      print('Error in creating person = $e');
      return false;
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
      const create = '''CREATE TABLE IF NOT EXISTS BOOK (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        NAME STRING NOT NULL,
        AUTOR STRING NOT NULL,
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

  Stream<List<Book>> all() =>
      _streamController.stream.map((books) => books..sort());
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final BookDB _crudStorage;

  @override
  void initState() {
    _crudStorage = BookDB(dbName: 'db.sqlite');
    _crudStorage.open();
    super.initState();
  }

  @override
  void dispose() {
    _crudStorage.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioapp Beta'),
      ),
      body: StreamBuilder(
        stream: _crudStorage.all(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.waiting:
              if (snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final libro = snapshot.data as List<Book>;
              return Column(
                children: [
                  ComposerWidget(
                    onCompose: (name, autor, year) async {
                      await _crudStorage.create(name, autor, year);
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: libro.length,
                      itemBuilder: (context, index) {
                        final book = libro[index];
                        return ListTile(
                          title: Text(book.fullBook),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Autor:${book.autor}'),
                              Text('Año: ${book.year}'),
                              Text('ID: ${book.id}'),
                            ],
                          ),
                          trailing: TextButton(
                            onPressed: () async {
                              final shouldDelete =
                                  await showDeleteDialog(context);
                              print(shouldDelete);
                              if (shouldDelete) {}
                            },
                            child: const Icon(
                              Icons.disabled_by_default_rounded,
                              color: Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

Future<bool> showDeleteDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: const Text('¿Esta seguro de eliminar este libro?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Eliminar'),
          )
        ],
      );
    },
  ).then((value) {
    if (value is bool) {
      return value;
    } else {
      return false;
    }
  });
}

typedef OnCompose = void Function(String name, String autor, int year);

class ComposerWidget extends StatefulWidget {
  final OnCompose onCompose;
  const ComposerWidget({
    Key? key,
    required this.onCompose,
  }) : super(key: key);

  @override
  State<ComposerWidget> createState() => _ComposerWidgetState();
}

class _ComposerWidgetState extends State<ComposerWidget> {
  late final TextEditingController _nameController;
  late final TextEditingController _autorController;
  late final TextEditingController _yearController;

  @override
  void initState() {
    _nameController = TextEditingController();
    _autorController = TextEditingController();
    _yearController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _autorController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Ingrese el nombre',
            ),
          ),
          TextField(
            controller: _autorController,
            decoration: const InputDecoration(
              hintText: 'Ingrese el autor',
            ),
          ),
          TextField(
            controller: _yearController,
            decoration: const InputDecoration(
              hintText: 'Ingrese el año',
            ),
          ),
          TextButton(
            onPressed: () {
              final name = _nameController.text;
              final autor = _autorController.text;
              final year = int.parse(_yearController.text);
              widget.onCompose(name, autor, year);
              _nameController.text = '';
              _autorController.text = '';
              _yearController.text = '';
            },
            child: const Text(
              'Añadir',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
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
