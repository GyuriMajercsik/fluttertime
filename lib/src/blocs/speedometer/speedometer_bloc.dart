import 'package:bloc/bloc.dart';
import 'package:flutter_time/src/blocs/speedometer/speedometer_event.dart';
import 'package:flutter_time/src/blocs/speedometer/speedometer_state.dart';

class SpeedometerBloc extends Bloc<SpeedometerEvent, SpeedometerState> {
  @override
  SpeedometerState get initialState => SpeedometerState.stopped();

  @override
  Stream<SpeedometerState> mapEventToState(SpeedometerEvent event) async* {
    if (event is Stopped) {
      yield SpeedometerState.stopped();
    }
    if (event is Started) {
      yield* _mapStartedToState(event);
    }

    if (event is ValueChanged) {
      yield* _mapValueChangedToState(event.newValue);
    }
  }

  Stream<SpeedometerState> _mapValueChangedToState(double newValue) async* {
    if (currentState.running) {
      yield currentState.withValue(newValue);
    }
  }

  Stream<SpeedometerState> _mapStartedToState(Started event) async* {
    yield SpeedometerState.ready(event.start, event.end);
  }
}
