import 'author.dart';
import 'read_status.dart';
import 'storable.dart';

class Book implements Storable {
  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.year,
    required this.status,
  });

  final int id;
  final String title;
  final Author author;
  final int year;
  final ReadStatus status;

  factory Book.fromJson(Map<String, dynamic> json) {
    if (json case {
      'id': final int id,
      'title': final String title,
      'author': final Map<String, dynamic> author,
      'year': final int year,
      'status': final String status,
    }) {
      return Book(
        id: id,
        title: title,
        author: Author.fromJson(author),
        year: year,
        status: ReadStatus.values.firstWhere(
          (s) => s.name == status,
          orElse: () => throw const FormatException('Невідомий статус'),
        ),
      );
    }
    throw const FormatException('Некоректні дані книги');
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author.toJson(),
    'year': year,
    'status': status.name,
  };

  @override
  String toString() =>
      '#$id "$title" — ${author.name}, $year [${status.label}]';
}
