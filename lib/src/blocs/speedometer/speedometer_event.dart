import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SpeedometerEvent extends Equatable {
  SpeedometerEvent([List props = const []]) : super(props);
}

class ValueChanged extends SpeedometerEvent {
  final double newValue;

  ValueChanged(this.newValue) : super([newValue]);

  @override
  String toString() => 'Speedometer value changed: $newValue';
}

class Started extends SpeedometerEvent {
  final double start;
  final double end;

  Started(this.start, this.end) : super([start, end]);

  @override
  String toString() => 'Speedometer started ($start, $end)';
}

class Stopped extends SpeedometerEvent {
  @override
  String toString() => 'Speedometer stopped';
}
