part of 'throttle_example_1_cubit.dart';

class ThrottleExample1State extends Equatable {
  final double normalScrollPosition;
  final double throttleScrollPosition;

  const ThrottleExample1State({
    this.normalScrollPosition = 0,
    this.throttleScrollPosition = 0,
  });

  ThrottleExample1State copyWith({
    double? normalScrollPosition,
    double? throttleScrollPosition,
  }) {
    return ThrottleExample1State(
      normalScrollPosition: normalScrollPosition ?? this.normalScrollPosition,
      throttleScrollPosition: throttleScrollPosition ?? this.throttleScrollPosition,
    );
  }

  @override
  List<Object> get props => [normalScrollPosition, throttleScrollPosition];
}
