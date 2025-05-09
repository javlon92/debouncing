import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';
import 'package:debouncing/debouncing.dart';

part 'debounce.dart';

part 'debounce_stream_transform.dart';

part 'throttle.dart';

part 'throttle_stream_transform.dart';

void main() {
  runDebounce();
  runDebounceStreamTransformer();
  runThrottle();
  runThrottleStreamTransformer();
}
