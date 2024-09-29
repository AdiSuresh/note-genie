import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/widgets/draggable_scrollable_bloc/event.dart';
import 'package:note_maker/widgets/draggable_scrollable_bloc/state.dart';

typedef _Event = DraggableScrollableEvent;
typedef _State = DraggableScrollableState;

class DraggableScrollableBloc extends Bloc<_Event, _State> {
  final controller = DraggableScrollableController();

  DraggableScrollableBloc([
    super.initialState = const DraggableScrollableState(),
  ]) {
    on<UpdateVisibilityEvent>(
      (event, emit) {
        final previous = state.isOpen;
        final next = switch (event.size) {
          < 0.01 => false,
          _ => true,
        };
        if (previous ^ next) {
          emit(
            DraggableScrollableState(
              isOpen: next,
            ),
          );
        }
      },
    );
    controller.addListener(
      _updateVisibility,
    );
  }

  void _updateVisibility() {
    if (controller.isAttached) {
      add(
        UpdateVisibilityEvent(
          size: controller.size,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    controller
      ..removeListener(
        _updateVisibility,
      )
      ..dispose();
    return super.close();
  }
}
