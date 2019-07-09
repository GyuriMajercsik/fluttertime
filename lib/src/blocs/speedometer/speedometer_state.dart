import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class SpeedometerState extends Equatable {
  final bool running;
  final double value;
  final double start;
  final double end;

  SpeedometerState._({
    this.running,
    this.value,
    this.start,
    this.end,
  }) : super([running, value, start, end]);

  factory SpeedometerState.stopped() {
    return SpeedometerState._(
      running: false,
      value: 0,
      start: 0,
      end: 0,
    );
  }

  factory SpeedometerState.ready(
    double start,
    double end,
  ) {
    return SpeedometerState._(
      running: true,
      value: 0,
      start: start,
      end: end,
    );
  }

  SpeedometerState withValue(double newValue) {
    return copyWith(value: newValue);
  }

  SpeedometerState copyWith({
    bool loading,
    double value,
    double start,
    double end,
  }) {
    return SpeedometerState._(
      running: loading ?? this.running,
      start: start ?? this.start,
      end: end ?? this.end,
      value: value ?? this.value,
    );
  }
}
