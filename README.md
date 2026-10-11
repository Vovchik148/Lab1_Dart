# Домашня бібліотека книг (Dart)

Консольний застосунок для обліку домашньої бібліотеки. Дані зберігаються
у локальному файлі `data.json`, а нові книги можна імпортувати з відкритого API.

## Можливості

- перегляд, додавання, редагування та видалення книг
- пошук (за назвою та автором) і сортування (за роком і назвою)
- статуси книг: у планах, читаю, прочитано
- імпорт книг з Open Library
- збереження та відновлення даних між запусками

## Запуск

Потрібен [Dart SDK](https://dart.dev/get-dart).

```bash
dart pub get
dart run bin/main.dart
```

Тести:

```bash
dart test
```

> Термінал має працювати в UTF-8 (Git Bash, термінал VS Code).
> У `cmd.exe` спершу виконайте `chcp 65001`.

## Використане API

Open Library Search API, без ключа та реєстрації:

```
https://openlibrary.org/search.json?q=dart&limit=10
```

Параметри: `q` — пошуковий запит, `limit` — кількість результатів.
З відповіді використовуються `title`, `author_name`
та `first_publish_year`.

## Структура проєкту

```
bin/main.dart                     # консольне меню
lib/models/                       # моделі Book, Author, enum ReadStatus
lib/services/book_api_service.dart  # запити до API
lib/services/book_search.dart     # пошук і сортування
lib/repositories/book_repository.dart  # робота з data.json
test/book_test.dart               # модульні тести
```