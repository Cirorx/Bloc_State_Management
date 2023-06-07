import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testingbloc/bloc/bloc_actions.dart';

import 'bloc/bloc_people.dart';
import 'bloc/person.dart';

//Continue in 2:10:46

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

extension Subscript<T> on Iterable<T> {
  // if the lenght is bigger than the index, then return the element at the index
  // else return null
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

Future<Iterable<Person>> getPeople(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));

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
                  context.read<PeopleBloc>().add(
                        const LoadPeopleAction(
                          url: person1Url,
                          loader: getPeople,
                        ),
                      );
                },
                child: const Text(
                  "Load Json 1",
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<PeopleBloc>().add(
                        const LoadPeopleAction(
                          url: person2Url,
                          loader: getPeople,
                        ),
                      );
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
