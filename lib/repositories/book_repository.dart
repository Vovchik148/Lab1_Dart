import 'dart:convert';
import 'dart:io';

import '../models/book.dart';

class BookRepository {
  BookRepository(this.path);

  final String path;

  Future<List<Book>> load() async {
    final file = File(path);
    if (!await file.exists()) return [];
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Очікувався список книг');
    }
    return decoded
        .map((e) => Book.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<Book> books) async {
    const encoder = JsonEncoder.withIndent('  ');
    await File(path).writeAsString(encoder.convert(books));
  }
}
