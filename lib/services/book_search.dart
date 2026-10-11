import '../models/book.dart';

List<Book> searchBooks(List<Book> books, String query) {
  final q = query.toLowerCase();
  return books
      .where(
        (b) =>
            b.title.toLowerCase().contains(q) ||
            b.author.name.toLowerCase().contains(q),
      )
      .toList();
}

List<Book> sortByYear(List<Book> books) =>
    [...books]..sort((a, b) => a.year.compareTo(b.year));

List<Book> sortByTitle(List<Book> books) =>
    [...books]..sort((a, b) => a.title.compareTo(b.title));
