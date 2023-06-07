import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testingbloc/bloc/person.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'bloc_actions.dart';

extension IsEqualIgnoringOrdering<T> on Iterable<T> {
  bool isEqualToIgnoringOrdering(Iterable<T> other) =>
      length == other.length &&
      {...this}.intersection({...other}).length == length;
}

@immutable
class FetchResult {
  final Iterable<Person> people;

  final bool isRetrievedFromCached;
  const FetchResult({
    required this.people,
    required this.isRetrievedFromCached,
  });

  @override
  String toString() =>
      'Fetch result (isRetrievedFromCache = $isRetrievedFromCached, people = $people)';

  @override
  bool operator ==(covariant FetchResult other) =>
      people.isEqualToIgnoringOrdering(other.people) &&
      isRetrievedFromCached == other.isRetrievedFromCached;

  @override
  int get hashCode => Object.hash(
        people,
        isRetrievedFromCached,
      );
}

class PeopleBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<String, Iterable<Person>> _cache = {};

  PeopleBloc() : super(null) {
    on<LoadPeopleAction>((event, emit) async {
      final url = event.url;
      if (_cache.containsKey(url)) {
        // the value is at cache
        final cachePeople = _cache[url]!;
        final result = FetchResult(
          people: cachePeople,
          isRetrievedFromCached: true,
        );
        emit(result);
      } else {
        final loader = event.loader;
        final people = await loader(url);
        _cache[url] = people;

        final result = FetchResult(
          people: people,
          isRetrievedFromCached: false,
        );
        emit(result);
      }
    });
  }
}
