import 'dart:async';
import 'dart:developer';
import 'package:debouncing_example/src/src.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'd_example_1_event.dart';

part 'd_example_1_state.dart';

/*
class DebounceExample1Cubit extends Cubit<DebounceExample1State> with DebounceMixin {
  DebounceExample1Cubit() : super(const DebounceExample1State());


  @override
  Future<void> close() {
    debounce.dispose(); // ❌ The dispose method is called automatically when the [Cubit] is closed, it's not necessary to close it manually.
    return super.close();
  }


  Future<void> onSearchWithoutResettable({required String text}) async {
    emit(state.copyWith(withoutResettableTextStatus: Status.loading));

    final result = await someUseCaseCall(someParams: text);

    result.fold(
      (left) {
        emit(
          state.copyWith(
            withoutResettableTextStatus: Status.failure,
            withoutResettableText: '$left\n❌ The request went to Server, even text is not valid',
          ),
        );
        log('Error handling: $left');
      },
      (right) {
        emit(state.copyWith(withoutResettableTextStatus: Status.success, withoutResettableText: right));
      },
    );
  }

  Future<void> onSearchWithResettable({required String text}) async {
    emit(state.copyWith(withResettableTextStatus: Status.loading));

    final result = await someUseCaseCall(someParams: text);

    result.fold(
      (left) {
        emit(state.copyWith(withResettableTextStatus: Status.failure, withResettableText: left));
        log('Error handling: $left');
      },
      (right) {
        emit(state.copyWith(withResettableTextStatus: Status.success, withResettableText: right));
      },
    );
  }

  void onChangedWithResettable({required String text}) {
    emit(state.copyWith(withResettableTextStatus: Status.loading));

    /// You can write your specific validation
    final bool isNotValidTextExample = text.isEmpty;

    if (isNotValidTextExample) {
      emit(
        state.copyWith(
          withResettableTextStatus: Status.failure,
          withResettableText: "✅ The request was not sent to Server, after all, text is not valid",
        ),
      );

      /// We need to cancel the previous request, because text is not valid.
      debounce.reset();
    } else {
      ///  We can send request to Server, because text is valid.
      debounce(() {
        onSearchWithResettable(
          text: text,
        );
      });
    }
  }

  void onChangedWithoutResettable({required String text}) {
    emit(state.copyWith(withoutResettableTextStatus: Status.loading));

    /// Always the request will be send to Server, because we don't check text to valid or not valid
    debounce(() {
      onSearchWithoutResettable(text: text);
    });
  }
}
*/
class DebounceExample1Bloc extends Bloc<DebounceExample1Event, DebounceExample1State> {
  DebounceExample1Bloc() : super(const DebounceExample1State()) {
    on<OnSearchWithoutResettable>(
      _onSearchWithoutResettable,
      transformer: debounceTransform(delay: const Duration(milliseconds: 1500)),
    );
    on<OnSearchWithResettable>(
      _onSearchWithResettable,
      transformer: debounceTransform(delay: const Duration(milliseconds: 1500)),
    );
    on<OnChangedWithResettable>(_onChangedWithResettable);
    on<OnChangedWithoutResettable>(_onChangedWithoutResettable);
  }

  Future<void> _onSearchWithoutResettable(OnSearchWithoutResettable event, Emitter<DebounceExample1State> emit) async {
    emit(state.copyWith(withoutResettableTextStatus: Status.loading));

    final result = await someUseCaseCall(someParams: event.text);

    result.fold(
      (left) {
        emit(
          state.copyWith(
            withoutResettableTextStatus: Status.failure,
            withoutResettableText: '$left\n❌ The request went to Server, even text is not valid',
          ),
        );
        log('Error handling: $left');
      },
      (right) {
        emit(state.copyWith(withoutResettableTextStatus: Status.success, withoutResettableText: right));
      },
    );
  }

  Future<void> _onSearchWithResettable(OnSearchWithResettable event, Emitter<DebounceExample1State> emit) async {
    emit(state.copyWith(withResettableTextStatus: Status.loading));

    final result = await someUseCaseCall(someParams: event.text);

    result.fold(
      (left) {
        emit(state.copyWith(withResettableTextStatus: Status.failure, withResettableText: left));
        log('Error handling: $left');
      },
      (right) {
        emit(state.copyWith(withResettableTextStatus: Status.success, withResettableText: right));
      },
    );
  }

  void _onChangedWithResettable(OnChangedWithResettable event, Emitter<DebounceExample1State> emit) {
    emit(state.copyWith(withResettableTextStatus: Status.loading));

    /// You can write your specific validation
    final bool isNotValidTextExample = event.text.isEmpty;

    if (isNotValidTextExample) {
      emit(
        state.copyWith(
          withResettableTextStatus: Status.failure,
          withResettableText: "✅ The request was not sent to Server, after all, text is not valid",
        ),
      );

      add(
        OnSearchWithResettable(
          text: event.text,

          /// resetOnlyPreviousEvent = true, because text is not valid, we can not send request to Server
          resetOnlyPreviousEvent: isNotValidTextExample,
        ),
      );
    } else {
      add(
        OnSearchWithResettable(
          text: event.text,

          /// resetOnlyPreviousEvent = false, because text is valid, we can send request to Server
          resetOnlyPreviousEvent: isNotValidTextExample,
        ),
      );
    }
  }

  void _onChangedWithoutResettable(OnChangedWithoutResettable event, Emitter<DebounceExample1State> emit) {
    emit(state.copyWith(withoutResettableTextStatus: Status.loading));

    /// Always the request will be send to Server, because event [OnSearchWithOutResettable] don't support cancel previous event like event [OnSearchWithResettable]
    add(OnSearchWithoutResettable(text: event.text));
  }
}
