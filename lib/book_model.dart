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
