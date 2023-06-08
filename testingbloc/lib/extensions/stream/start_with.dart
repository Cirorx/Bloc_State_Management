import 'package:async/async.dart' show StreamGroup;

//Search for explanation with diagram to visualize better
extension StartWith<T> on Stream<T> {
  Stream<T> startWith(T value) => StreamGroup.merge(
        [
          this,
          Stream<T>.value(value),
        ],
      );
}
