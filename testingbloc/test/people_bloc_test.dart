//remember that all test file must have 'test' at the end of file name

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testingbloc/bloc/bloc_actions.dart';
import 'package:testingbloc/bloc/bloc_people.dart';
import 'package:testingbloc/bloc/person.dart';

const mockedPeople1 = [
  Person(
    name: 'Foo',
    age: 20,
  ),
  Person(
    name: 'Baz',
    age: 30,
  ),
];

const mockedPeople2 = [
  Person(
    name: 'Foo',
    age: 20,
  ),
  Person(
    name: 'Baz',
    age: 30,
  ),
];

Future<Iterable<Person>> mockGetPeople1(String _) =>
    Future.value(mockedPeople1);

Future<Iterable<Person>> mockGetPeople2(String _) =>
    Future.value(mockedPeople2);

void main() {
  //test group
  group(
    "Testing bloc",
    () {
      //tests
      late PeopleBloc bloc;

      setUp(() {
        bloc = PeopleBloc();
      });

      blocTest<PeopleBloc, FetchResult?>(
        "Test the initial state",
        build: () => bloc,
        verify: (bloc) => expect(bloc.state, null),
      );

      // fetch mock data (People1) and compare it with FetchResult
      blocTest<PeopleBloc, FetchResult?>(
        'Mock retrieving People from first iterable',
        build: () => bloc,
        act: (bloc) {
          bloc.add(
            const LoadPeopleAction(
              url: 'random_url',
              loader: mockGetPeople1,
            ),
          );
          bloc.add(
            const LoadPeopleAction(
              url: 'random_url',
              loader: mockGetPeople1,
            ),
          );
        },
        expect: () => [
          const FetchResult(
            people: mockedPeople1,
            isRetrievedFromCached: false,
          ),
          const FetchResult(
            people: mockedPeople1,
            isRetrievedFromCached: true,
          )
        ],
      );

      // fetch mock data (People2) and compare it with FetchResult
      blocTest<PeopleBloc, FetchResult?>(
        'Mock retrieving People from second iterable',
        build: () => bloc,
        act: (bloc) {
          bloc.add(
            const LoadPeopleAction(
              url: 'random_url',
              loader: mockGetPeople2,
            ),
          );
          bloc.add(
            const LoadPeopleAction(
              url: 'random_url',
              loader: mockGetPeople2,
            ),
          );
        },
        expect: () => [
          const FetchResult(
            people: mockedPeople2,
            isRetrievedFromCached: false,
          ),
          const FetchResult(
            people: mockedPeople2,
            isRetrievedFromCached: true,
          )
        ],
      );
    },
  );
}
