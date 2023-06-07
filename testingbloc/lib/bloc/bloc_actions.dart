import 'package:flutter/foundation.dart' show immutable;
import 'package:testingbloc/bloc/person.dart';

const person1Url = "http://192.168.88.19:8082/testingbloc/api/people1.json";
const person2Url = "http://192.168.88.19:8082/testingbloc/api/people2.json";

typedef PeopleLoader = Future<Iterable<Person>> Function(String url);

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPeopleAction implements LoadAction {
  final String url;
  final PeopleLoader loader;

  const LoadPeopleAction({
    required this.url,
    required this.loader,
  }) : super();
}
