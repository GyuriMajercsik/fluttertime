import 'package:equatable/equatable.dart';

class MqttEvent extends Equatable {
  MqttEvent([List<dynamic> args]) : super(args);
}

class Disconnect extends MqttEvent {
  @override
  String toString() => 'Disconnect';
}

class Connect extends MqttEvent {
  final String broker;
  final String username;
  final String clientId;
  final String password;

  Connect({
    this.broker,
    this.username,
    this.clientId,
    this.password,
  }) : super([
          broker,
          username,
          clientId,
          password,
        ]);

  @override
  String toString() => 'Connect to $broker as $username';
}

class Subscribe extends MqttEvent {
  final String topic;

  Subscribe(this.topic);

  @override
  String toString() => 'MQTT subscribe to $topic';
}

class Unsubscribe extends MqttEvent {
  final String topic;

  Unsubscribe(this.topic);

  @override
  String toString() => 'MQTT unsubscribe from $topic';
}

class Publish extends MqttEvent {
  final String topic;
  final String value;

  Publish(this.topic, this.value);

  @override
  String toString() => 'MQTT publish $value on $topic';
}

class Receive extends MqttEvent {
  final String topic;
  final String value;

  Receive(this.topic, this.value);

  @override
  String toString() => 'MQTT receive $value on $topic';
}
