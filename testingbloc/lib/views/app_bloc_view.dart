import 'package:flutter/material.dart';
import 'package:testingbloc/bloc/app_bloc.dart';
import 'package:testingbloc/bloc/app_state.dart';
import 'package:testingbloc/bloc/bloc_events.dart';
import 'package:testingbloc/extensions/stream/start_with.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
/*
  logic
  loading 
  displaying an error 
  displaying the image itself
  managing the app_bloc to load a new image
*/

// Bloc with T to be able to accept Top and Bottom
class AppBlocView<T extends AppBloc> extends StatelessWidget {
  const AppBlocView({super.key});

  void startUpdatingBloc(BuildContext context) {
    Stream.periodic(
      const Duration(seconds: 10),
      (_) => const LoadNextUrlEvent(),
    ).startWith(const LoadNextUrlEvent()).forEach((event) {
      context.read<T>().add(
            event,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    startUpdatingBloc(context);
    return Expanded(
      //default flex on 1 so same size
      child: BlocBuilder<T, AppState>(
        builder: (context, appState) {
          if (appState.error != null) {
            return const Text("Oh no! Try again in a moment.");
          } else if (appState.data != null) {
            return Image.memory(
              appState.data!,
              fit: BoxFit.scaleDown,
            );
          }
          // then is loading
          else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
