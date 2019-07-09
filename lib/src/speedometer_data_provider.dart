import 'dart:async';
import 'dart:math';

import 'package:flutter_time/src/blocs/mqtt/bloc.dart';
import 'package:quiver/strings.dart';

import 'blocs/speedometer/bloc.dart';

abstract class SpeedometerDataProvider {
  final SpeedometerBloc _speedometerBloc;

  SpeedometerDataProvider(this._speedometerBloc);

  bool _running = false;

  void start() {
    assert(!_running, 'Speedometer data provider is already running');

    _running = true;
    _speedometerBloc.dispatch(Started(0, 200));

    _doStart();
  }

  void stop() {
    assert(_running, 'Speedometer data provider is not running');

    _running = false;
    _speedometerBloc.dispatch(Stopped());
    _doStop();
  }

  void _doStart();

  void _doStop();
}

class SpeedometerRandomDataProvider extends SpeedometerDataProvider {
  final Random _random = Random();
  final String _topic;
  final MqttBloc _mqttBloc;

  SpeedometerRandomDataProvider(
    SpeedometerBloc speedometerBloc,
    this._mqttBloc, {
    String publishOnTopic,
  })  : _topic = publishOnTopic,
        assert(speedometerBloc != null),
        assert(_mqttBloc != null),
        super(speedometerBloc);

  void _generateData() {
    var nextRandomData = _random.nextInt(200);

    _speedometerBloc.dispatch(ValueChanged(nextRandomData.toDouble()));
    if (isNotEmpty(_topic)) {
      _mqttBloc.dispatch(Publish(_topic, nextRandomData.toString()));
    }
  }

  @override
  void _doStart() async {
    while (_running) {
      await Future.delayed(Duration(milliseconds: 500));
      if (_running) {
        _generateData();
      }
    }
  }

  @override
  void _doStop() {
    // nothing to do here
  }
}

class SpeedometerMQTTDataProvider extends SpeedometerDataProvider {
  final MqttBloc _mqttBloc;
  final String _topic;

  StreamSubscription<MqttState> _listener;

  SpeedometerMQTTDataProvider(
    SpeedometerBloc speedometerBloc,
    this._mqttBloc,
    this._topic,
  )   : assert(_topic != null),
        assert(speedometerBloc != null),
        assert(_mqttBloc != null),
        super(speedometerBloc);

  @override
  void _doStart() async {
    _mqttBloc.dispatch(Subscribe(_topic));
    _listener = _mqttBloc.state.listen((state) {
      if (state is Received) {
        print('Received message $state');
        if (state.topic == _topic) {
          _speedometerBloc.dispatch(ValueChanged(double.parse(state.message)));
        }
      }
    });
  }

  @override
  void _doStop() {
    _listener.cancel();
    _mqttBloc.dispatch(Unsubscribe(_topic));
  }
}
