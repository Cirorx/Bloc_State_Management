import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//Continue in 01:22:36

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (_) => PeopleBloc(),
        child: const HomePage(),
      ),
    ),
  );
}

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPeopleAction extends LoadAction {
  final PersonUrl url;

  const LoadPeopleAction({required this.url}) : super();
}

enum PersonUrl {
  people1,
  people2,
}

extension Subscript<T> on Iterable<T> {
  // if the lenght is bigger than the index, then return the element at the index
  // else return null
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

extension UrlString on PersonUrl {
  String get urlString {
    switch (this) {
      case PersonUrl.people1:
        return "http://192.168.88.19:8082/testingbloc/api/people1.json";
      case PersonUrl.people2:
        return "http://192.168.88.19:8082/testingbloc/api/people2.json";
    }
  }
}

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

Future<Iterable<Person>> getPeople(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));

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
}

class PeopleBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<PersonUrl, Iterable<Person>> _cache = {};

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
        final people = await getPeople(url.urlString);
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  context.read<PeopleBloc>().add(const LoadPeopleAction(
                        url: PersonUrl.people1,
                      ));
                },
                child: const Text(
                  "Load Json 1",
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<PeopleBloc>().add(const LoadPeopleAction(
                        url: PersonUrl.people2,
                      ));
                },
                child: const Text(
                  "Load Json 2",
                ),
              ),
            ],
          ),
          BlocBuilder<PeopleBloc, FetchResult?>(
            buildWhen: (previousResult, currentResult) {
              return previousResult?.people != currentResult?.people;
            },
            builder: ((context, fetchResult) {
              final people = fetchResult?.people;
              if (people == null) {
                return const SizedBox();
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: people.length,
                  itemBuilder: (context, index) {
                    final person = people[index]!;
                    return ListTile(
                      title: Text(person.name),
                    );
                  },
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}
