import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab_dart/models/author.dart';
import 'package:lab_dart/models/book.dart';
import 'package:lab_dart/models/read_status.dart';
import 'package:lab_dart/services/book_api_service.dart';
import 'package:lab_dart/services/book_search.dart';
import 'package:test/test.dart';

void main() {
  final dune = Book(
    id: 1,
    title: 'Dune',
    author: Author(name: 'Frank Herbert'),
    year: 1965,
    status: ReadStatus.done,
  );
  final emma = Book(
    id: 2,
    title: 'Emma',
    author: Author(name: 'Jane Austen', country: 'UK'),
    year: 1815,
    status: ReadStatus.planned,
  );

  group('Book', () {
    test('toJson повертає правильну мапу', () {
      expect(dune.toJson(), {
        'id': 1,
        'title': 'Dune',
        'author': {'name': 'Frank Herbert', 'country': null},
        'year': 1965,
        'status': 'done',
      });
    });

    test('fromJson відновлює об\'єкт (туди й назад)', () {
      final restored = Book.fromJson(dune.toJson());
      expect(restored.title, equals('Dune'));
      expect(restored.author.name, equals('Frank Herbert'));
      expect(restored.status, ReadStatus.done);
      expect(restored.toJson(), dune.toJson());
    });

    test('некоректні дані кидають FormatException', () {
      expect(
        () => Book.fromJson({'id': 'abc'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('пошук і сортування', () {
    final books = [dune, emma];

    test('пошук за назвою та автором', () {
      expect(searchBooks(books, 'dun'), hasLength(1));
      expect(searchBooks(books, 'austen').first.title, 'Emma');
      expect(searchBooks(books, 'xyz'), isEmpty);
    });

    test('сортування за роком', () {
      expect(sortByYear(books).first.title, 'Emma');
    });
  });

  group('BookApiService', () {
    test('розбирає відповідь через MockClient', () async {
      final client = MockClient(
        (request) async => http.Response(
          '{"docs": [{"title": "Dune", "author_name": ["Frank Herbert"], '
          '"first_publish_year": 1965}]}',
          200,
        ),
      );
      final result = await BookApiService(client: client).search('dune');
      expect(result, hasLength(1));
      expect(result.first.author.name, 'Frank Herbert');
      expect(result.first.year, 1965);
    });

    test('статус 500 дає ApiException', () async {
      final client = MockClient((request) async => http.Response('', 500));
      expect(
        () => BookApiService(client: client).search('dune'),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
