import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/app/router/navigation/event.dart';
import 'package:note_maker/app/router/navigation/state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final logger = AppLogger(
    NavigationBloc,
  );

  NavigationBloc(
    super.initialState,
  ) {
    on<NavigationEvent>(
      (event, emit) {
        logger.i(event);
        emit(
          NavigationState(
            event: event,
            currentPath: event.currentPath,
          ),
        );
      },
    );
  }
}
