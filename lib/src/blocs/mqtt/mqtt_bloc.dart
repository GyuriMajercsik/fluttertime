import 'package:bloc/bloc.dart';
import 'package:flutter_time/src/blocs/mqtt/mqtt_event.dart';
import 'package:flutter_time/src/blocs/mqtt/mqtt_state.dart';
import 'package:flutter_time/src/mqtt_service.dart';
import 'package:meta/meta.dart';

class MqttBloc extends Bloc<MqttEvent, MqttState> {
  final MqttService _mqttService;

  MqttBloc() : _mqttService = MqttService();

  @override
  MqttState get initialState => Disconnected();

  @override
  Stream<MqttState> mapEventToState(MqttEvent event) async* {
    if (event is Connect) {
      yield* _mapConnectToState(
          broker: event.broker,
          clientId: event.clientId,
          username: event.username,
          password: event.password);
    } else if (event is Disconnect) {
      yield* _mapDisconnectToState();
    } else if (event is Subscribe) {
      yield* _mapSubscribeToState(
        topic: event.topic,
      );
    } else if (event is Unsubscribe) {
      yield* _mapUnsubscribeToState(topic: event.topic);
    } else if (event is Receive) {
      yield* _mapReceiveToState(
        topic: event.topic,
        value: event.value,
      );
    } else if (event is Publish) {
      yield* _mapPublishToState(
        topic: event.topic,
        value: event.value,
      );
    }
  }

  Stream<MqttState> _mapConnectToState({
    @required String broker,
    @required String clientId,
    @required String username,
    @required String password,
  }) async* {
    var connected = await _mqttService.connect(
        broker: broker,
        username: username,
        clientId: clientId,
        password: password,
    onMessage: (topic, message) => dispatch(Receive(topic, message)));

    if (connected) {
      yield Connected(broker, username);
    } else {
      yield Disconnected();
    }
  }

  Stream<MqttState> _mapDisconnectToState() async* {
    _mqttService.disconnect();

    yield Disconnected();
  }

  Stream<MqttState> _mapPublishToState({
    @required String topic,
    @required String value,
  }) async* {
    if (_mqttService.isConnected()) {
      await _mqttService.publish(topic, value);

      yield Published(topic, value);
    } else {
      yield Disconnected();
    }
  }

  Stream<MqttState> _mapSubscribeToState({@required String topic}) async* {
    if (_mqttService.isConnected()) {
      await _mqttService.subscribe(topic);

      yield Subscribed(topic);
    } else {
      yield Disconnected();
    }
  }

  Stream<MqttState> _mapUnsubscribeToState({@required String topic}) async* {
    if (_mqttService.isConnected()) {
      _mqttService.unsubscribe(topic);

      yield Subscribed(topic);
    } else {
      yield Disconnected();
    }
  }

  Stream<MqttState> _mapReceiveToState({
    String topic,
    String value,
  }) async* {
    yield Received(topic, value);
  }
}
