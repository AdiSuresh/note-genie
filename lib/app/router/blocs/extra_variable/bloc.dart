import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/app/router/blocs/extra_variable/event.dart';
import 'package:note_maker/app/router/blocs/extra_variable/state.dart';

/// Bloc for managing the extra variable state.
final class ExtraVariableBloc
    extends Bloc<ExtraVariableEvent, ExtraVariableState> {
  ExtraVariableBloc([
    super.initialState = const ExtraVariableState(
      extra: null,
    ),
  ]) {
    on<UpdateVariableEvent>(
      (event, emit) {
        emit(
          ExtraVariableState(
            extra: event.extra,
          ),
        );
      },
    );
  }
}

extension ExtraVariableExtension on BuildContext {
  set extra(
    dynamic data,
  ) {
    read<ExtraVariableBloc>().add(
      UpdateVariableEvent(
        extra: data,
      ),
    );
  }

  dynamic get extra {
    return read<ExtraVariableBloc>().state.extra;
  }
}
