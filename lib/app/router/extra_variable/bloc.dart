import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'event.dart';
import 'state.dart';

// BLoC to manage the extra variable state
class ExtraVariableBloc extends Bloc<ExtraVariableEvent, ExtraVariableState> {
  ExtraVariableBloc()
      : super(
          const ExtraVariableState(
            extra: null,
          ),
        ) {
    on<ExtraVariableUpdate>(
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
      ExtraVariableUpdate(
        extra: data,
      ),
    );
  }

  dynamic get extra {
    return read<ExtraVariableBloc>().state.extra;
  }
}
