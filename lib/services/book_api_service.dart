import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/author.dart';
import '../models/book.dart';
import '../models/read_status.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => 'ApiException: $message';
}

class BookApiService {
  BookApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Book>> search(String query) async {
    final uri = Uri.https('openlibrary.org', '/search.json', {
      'q': query,
      'limit': '10',
    });
    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw ApiException('Помилка сервера: ${response.statusCode}');
      }
      final data = jsonDecode(response.body);
      if (data case {'docs': final List docs}) {
        return docs.map((e) => _fromDoc(e as Map<String, dynamic>)).toList();
      }
      throw ApiException('У відповіді немає поля docs');
    } on SocketException {
      throw ApiException('Немає з\'єднання з інтернетом');
    } on FormatException {
      throw ApiException('Сервер повернув некоректний JSON');
    }
  }

  Book _fromDoc(Map<String, dynamic> doc) {
    final authors = doc['author_name'] as List?;
    return Book(
      id: 0,
      title: doc['title'] as String? ?? 'Без назви',
      author: Author(name: authors?.firstOrNull as String? ?? 'Невідомий'),
      year: doc['first_publish_year'] as int? ?? 0,
      status: ReadStatus.planned,
    );
  }

  void close() => _client.close();
}
