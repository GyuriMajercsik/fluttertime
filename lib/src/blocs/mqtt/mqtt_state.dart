import 'package:equatable/equatable.dart';

abstract class MqttState extends Equatable {
  MqttState([List<dynamic> args]) : super(args);
}

class Disconnected extends MqttState {

  @override
  String toString() => 'Disconnected';
}

class Connected extends MqttState {
  final String broker;
  final String username;

  Connected(this.broker, this.username) : super([broker, username]);

  @override
  String toString() => 'Connected to $broker as $username';

}

class Subscribed extends MqttState {
  final String topic;

  Subscribed(this.topic) : super([topic]);

  @override
  String toString() => 'Subscribed to $topic';

}

class Unsubscribed extends MqttState {
  final String topic;

  Unsubscribed(this.topic) : super([topic]);

  @override
  String toString() => 'Unsubscribed from $topic';
}

class Published extends MqttState {
  final String topic;
  final String message;

  Published(this.topic, this.message) : super([topic, message]);

  @override
  String toString() => 'Message $message sent on $topic topic';
}

class Received extends MqttState {
  final String topic;
  final String message;

  Received(this.topic, this.message) : super([topic, message]);

  @override
  String toString() => 'Message $message received on $topic topic';
}