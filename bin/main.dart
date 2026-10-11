import 'dart:io';

import 'package:lab_dart/models/author.dart';
import 'package:lab_dart/models/book.dart';
import 'package:lab_dart/models/read_status.dart';
import 'package:lab_dart/repositories/book_repository.dart';
import 'package:lab_dart/services/book_api_service.dart';
import 'package:lab_dart/services/book_search.dart';

String? ask(String text) {
  stdout.write(text);
  return stdin.readLineSync();
}

void printBooks(List<Book> books) {
  if (books.isEmpty) {
    print('Список порожній.');
    return;
  }
  for (final b in books) {
    print(b);
  }
}

int nextId(List<Book> books) =>
    books.fold(0, (max, b) => b.id > max ? b.id : max) + 1;

ReadStatus? askStatus() {
  for (final s in ReadStatus.values) {
    print('  ${s.index + 1}. ${s.name}');
  }
  final n = int.tryParse(ask('Статус: ') ?? '');
  if (n == null || n < 1 || n > ReadStatus.values.length) return null;
  return ReadStatus.values[n - 1];
}

Future<void> addBook(List<Book> books, BookRepository repo) async {
  final title = (ask('Назва: ') ?? '').trim();
  final authorName = (ask('Автор: ') ?? '').trim();
  final year = int.tryParse(ask('Рік: ') ?? '');
  final status = askStatus();
  if (title.isEmpty || authorName.isEmpty || year == null || status == null) {
    print('Некоректні дані, книгу не додано.');
    return;
  }
  books.add(
    Book(
      id: nextId(books),
      title: title,
      author: Author(name: authorName),
      year: year,
      status: status,
    ),
  );
  await repo.save(books);
  print('Додано.');
}

Future<void> deleteBook(List<Book> books, BookRepository repo) async {
  final id = int.tryParse(ask('ID для видалення: ') ?? '');
  if (id == null) {
    print('Потрібно ввести число.');
    return;
  }
  final before = books.length;
  books.removeWhere((b) => b.id == id);
  if (books.length == before) {
    print('Книги з таким ID немає.');
    return;
  }
  await repo.save(books);
  print('Видалено.');
}

Future<void> importFromApi(
  List<Book> books,
  BookRepository repo,
  BookApiService api,
) async {
  final query = (ask('Пошуковий запит: ') ?? '').trim();
  if (query.isEmpty) return;
  try {
    final found = await api.search(query);
    if (found.isEmpty) {
      print('Нічого не знайдено.');
      return;
    }
    for (var i = 0; i < found.length; i++) {
      final b = found[i];
      print('${i + 1}. "${b.title}" — ${b.author.name}, ${b.year}');
    }
    final n = int.tryParse(
      ask('Номер книги для додавання (0 — скасувати): ') ?? '',
    );
    if (n == null || n < 1 || n > found.length) return;
    final picked = found[n - 1];
    books.add(
      Book(
        id: nextId(books),
        title: picked.title,
        author: picked.author,
        year: picked.year,
        status: ReadStatus.planned,
      ),
    );
    await repo.save(books);
    print('Додано до бібліотеки.');
  } on ApiException catch (e) {
    print('Не вдалося отримати дані: ${e.message}');
  }
}

void printMenu() {
  print('''
\n=== Домашня бібліотека ===
1. Показати список
2. Додати книгу
3. Видалити книгу
4. Пошук
5. Сортувати за роком
6. Сортувати за назвою
7. Імпорт з Open Library
0. Вихід''');
}

Future<void> main() async {
  final repo = BookRepository('data.json');
  final api = BookApiService();
  var books = <Book>[];

  try {
    books = await repo.load();
  } on FormatException catch (e) {
    print('Файл data.json пошкоджено (${e.message}). Починаємо з порожнього.');
  }

  while (true) {
    printMenu();
    final choice = ask('Оберіть пункт: ');
    if (choice == null) break; // кінець вводу
    switch (choice.trim()) {
      case '1':
        printBooks(books);
      case '2':
        await addBook(books, repo);
      case '3':
        await deleteBook(books, repo);
      case '4':
        printBooks(searchBooks(books, ask('Що шукати: ') ?? ''));
      case '5':
        printBooks(sortByYear(books));
      case '6':
        printBooks(sortByTitle(books));
      case '7':
        await importFromApi(books, repo, api);
      case '0':
        api.close();
        return;
      default:
        print('Невідомий пункт меню.');
    }
  }
  api.close();
}
