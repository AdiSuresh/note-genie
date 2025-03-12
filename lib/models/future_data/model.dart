import 'package:copy_with_extension/copy_with_extension.dart';

part 'model.g.dart';

enum AsyncDataState {
  loading,
  loaded,
}

@CopyWith()
final class AsyncData<T extends Object?> {
  final Future<T> future;
  final T data;
  final AsyncDataState state;

  const AsyncData({
    required this.future,
    required this.data,
    required this.state,
  });

  factory AsyncData.initial(
    T data,
  ) {
    return AsyncData(
      future: Future.value(
        data,
      ),
      data: data,
      state: AsyncDataState.loaded,
    );
  }
}
