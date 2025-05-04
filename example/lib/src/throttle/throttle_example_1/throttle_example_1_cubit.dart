import 'dart:async';
import 'package:debouncing_example/src/src.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'throttle_example_1_state.dart';

/*

class ThrottleExample1Provider with ChangeNotifier, ThrottleNotifierMixin {
  ...
}

class ThrottleExample1Controller extends GetxController with ThrottleGetXMixin {
  ...
}

*/

class ThrottleExample1Cubit extends Cubit<ThrottleExample1State> with ThrottleMixin {
  ThrottleExample1Cubit() : super(const ThrottleExample1State());

  @override
  ThrottleParams get throttleParams => const ThrottleParams(interval: Duration(milliseconds: 1500), trailing: true);

  /*
  @override
  Future<void> close() {
    throttle.dispose(); // ❌ The dispose method is called automatically when the [Cubit] is closed, it's not necessary to close it manually.
    return super.close();
  }
  */

  Future<void> onScroll({required double scrollPosition}) async {
    emit(state.copyWith(normalScrollPosition: scrollPosition));

    throttle(() {
      emit(state.copyWith(throttleScrollPosition: scrollPosition));
    });
  }
}

/// [ThrottleMixin] for adding throttling (`throttle`) to [Block] or [Cubit].
///
/// Used to limit the frequency of actions, for example:
/// - when events are triggered frequently
/// - when updating a state with a frequency limit
///
/// ### Usage example:
///
/// ```dart
/// class MyCubit extends Cubit<MyState> with ThrottleMixin {
///   MyCubit() : super(const MyState());
///
///   Use `throttleParams` if you need your `ThrottleParams`
///   @override
///   ThrottleParams get throttleParams => const ThrottleParams(interval: Duration(milliseconds: 300),leading: false,trailing: true);
///
///   void onEvent() {
///     throttle(() {
///       emit(MyNewState());
///     });
///   }
///
///   @override
///   Future<void> close() {
///     throttle.dispose(); // ❌ The dispose method is called automatically when the [Cubit] is closed, it's not necessary to close it manually.
///     return super.close();
///   }
///
/// }
/// ```
/// ---
/// ```dart
/// class MyBloc extends Bloc<MyEvent, MyState> with ThrottleMixin {
///   MyBloc() : super(MyStateInitial()) {
///     on<OnEvent>(_onEvent);
///   }
///
///   Use `throttleParams` if you need your `ThrottleParams`
///   @override
///   ThrottleParams get throttleParams => const ThrottleParams(interval: Duration(milliseconds: 300),leading: false,trailing: true);
///
///   void _onEvent(OnEvent event, Emitter emit) {
///     throttle(() {
///       emit(MyNewState());
///     });
///   }
///
///   @override
///   Future<void> close() {
///     throttle.dispose(); // ❌ The dispose method is called automatically when the [Bloc] is closed, it's not necessary to close it manually.
///     return super.close();
///   }
///
/// }
/// ```
///
/// 🧼 The [close] method automatically calls [throttle.dispose()], which ensures that timers are cleared and resources are released.
///
mixin ThrottleMixin<T> on BlocBase<T> {
  /// Parameters defining the behavior of [Throttle].
  ///
  /// It can be overridden in the class that uses the mixin.
  @protected
  @visibleForTesting
  ThrottleParams get throttleParams => const ThrottleParams();

  /// An instance of [Throttle] used to limit the frequency of calls.
  @protected
  @nonVirtual
  @visibleForTesting
  late final Throttle throttle = Throttle(
    interval: throttleParams.interval,
    leading: throttleParams.leading,
    trailing: throttleParams.trailing,
  );

  /// Automatically cleans up resources when closing [Block] or [Cubit].
  ///
  /// It is called automatically at [BlockBase.close].
  @override
  @protected
  @mustCallSuper
  Future<void> close() {
    throttle.dispose(); // 🧼 automatically triggers, safe cleaning
    return super.close();
  }
}
