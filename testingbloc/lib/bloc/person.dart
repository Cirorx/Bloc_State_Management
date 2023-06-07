import 'package:flutter/foundation.dart' show immutable;

@immutable
class Person {
  final String name;
  final int age;

  const Person({
    required this.name,
    required this.age,
  });

  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        age = int.parse(json['age']);

  @override
  String toString() => "name = $name, age = $age";
}
