import 'storable.dart';

class Author implements Storable {
  Author({required this.name, this.country});

  final String name;
  final String? country;

  factory Author.fromJson(Map<String, dynamic> json) {
    if (json case {
      'name': final String name,
      'country': final String? country,
    }) {
      return Author(name: name, country: country);
    }
    throw const FormatException('Некоректні дані автора');
  }

  @override
  Map<String, dynamic> toJson() => {'name': name, 'country': country};

  @override
  String toString() => country == null ? name : '$name ($country)';
}
