import 'dart:async';
import 'dart:developer';
import 'package:debouncing_example/src/src.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'd_example_2_provider_state.dart';

/*

class DebounceExample2Cubit extends Cubit<DebounceExample2State> with DebounceMixin {
  ...
}

class DebounceExample2Controller extends GetxController with DebounceGetXMixin {
  ...
}

*/
class DebounceExample2Provider with ChangeNotifier, DebounceNotifierMixin {
  DebounceExample2State state;

  @override
  DebounceParams get debounceParams => const DebounceParams(delay: Duration(milliseconds: 1500));

  DebounceExample2Provider([DebounceExample2State? state]) : state = state ??= const DebounceExample2State();

  /*
  @override
  void dispose() {
    debounce.dispose(); // ❌ The dispose method is called automatically when the [Provider] is closed, it's not necessary to close it manually.
    super.dispose();
  }
  */

  @protected
  @visibleForTesting
  void emit(DebounceExample2State newState) {
    if (state == newState) return;
    state = newState;
    notifyListeners();
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

/// [DebounceMixin] for adding debounce (`debounce') to [Block] or [Cubit].
///
/// Allows you to limit the frequency of actions, for example:
/// - when entering text in search
/// - when events are triggered frequently
/// - when updating the status with a delay
///
/// It is used in conjunction with [BlocBase], so it is suitable for both [Block] and [Cubit].
///
/// ### Usage example:
///
/// ```dart
/// class MyCubit extends Cubit<MyState> with DebounceMixin {
///   MyCubit() : super(const MyState());
///
///   Use `debounceParams` if you need your `DebounceParams`
///   @override
///   DebounceParams get debounceParams => const DebounceParams(delay: Duration(milliseconds: 300), leading: true, trailing: false);
///
///   void onTextChanged(String text) {
///     debounce(() {
///       emit(MyNewState());
///       // ...
///     });
///   }
///
///   @override
///   Future<void> close() {
///     debounce.dispose(); // ❌ The dispose method is called automatically when the [Cubit] is closed, it's not necessary to close it manually.
///     return super.close();
///   }
///
/// }
/// ```
/// ---
/// ```dart
/// class MyBloc extends Bloc<MyEvent, MyState> with DebounceMixin {
///   MyBloc() : super(MyState()) {
///     on<SearchTextChanged>(_onChanged);
///   }
///
///   Use `debounceParams` if you need your `DebounceParams`
///   @override
///   DebounceParams get debounceParams => const DebounceParams(delay: Duration(milliseconds: 300), leading: true, trailing: false);
///
///   void _onChanged(SearchTextChanged event, Emitter emit) {
///     debounce(() {
///       emit(MyNewState());
///       // ...
///     });
///   }
///
///   @override
///   Future<void> close() {
///     debounce.dispose(); // ❌ The dispose method is called automatically when the [Bloc] is closed, it's not necessary to close it manually.
///     return super.close();
///   }
///
/// }
/// ```
///
/// 🧼 The [close] method automatically calls [debounce.dispose()], which ensures that timers are cleared and resources are released.
///
mixin DebounceMixin<T> on BlocBase<T> {
  /// Parameters defining the behavior of [Debounce].
  ///
  /// It can be overridden in the class that uses the mixin.
  @protected
  @visibleForTesting
  DebounceParams get debounceParams => const DebounceParams();

  /// An instance of [Debounce], which is used to implement the delay.
  @protected
  @nonVirtual
  @visibleForTesting
  late final Debounce debounce = Debounce(
    delay: debounceParams.delay,
    leading: debounceParams.leading,
    trailing: debounceParams.trailing,
  );

  /// Closes [debounce] when [Block] or [Cubit] is shut down.
  ///
  /// It is called automatically at [BlockBase.close].
  @override
  @protected
  @mustCallSuper
  Future<void> close() {
    debounce.dispose(); // 🧼 automatically triggers, safe cleaning
    return super.close();
  }
}
