import 'dart:async';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttService {
  final Logger log = Logger('MqttService');
  MqttClient _client;

  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>> _messageListener;

  Future<bool> connect(
      {@required String broker,
      @required String clientId,
      @required String username,
      @required String password,
      @required void onMessage(String topic, String message)}) async {
    log.info('Connecting to $broker with $clientId as $username');
    _client = MqttClient(broker, clientId);
    _client.secure = false;

    // enabled only for debug
    _client.logging(on: false);

    final MqttConnectMessage connMess = MqttConnectMessage()
//        .authenticateAs(username, key) // todo adding if necessary
        .withClientIdentifier(clientId)
        .keepAliveFor(60)
        .withWillTopic('connectivity')
        .withWillMessage('ByeBye')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client.connectionMessage = connMess;

    try {
      await _client.connect();
    } on Exception catch (e) {
      log.severe('EXCEPTION::client exception - $e');
      _client.disconnect();
      _client = null;
      return false;
    }

    if (_client.connectionStatus.state == MqttConnectionState.connected) {
      log.info('client connected to broker $broker');
      _startListening(onMessage);
      return true;
    } else {
      log.info('client connection failed - disconnecting, '
          'status is ${_client.connectionStatus}');
      _client.disconnect();
      _client = null;
      return false;
    }
  }

  void disconnect() async {
    if (_client.connectionStatus.state == MqttConnectionState.connected) {
      _messageListener.cancel();
      _client.disconnect();
    }
  }

  Future<void> subscribe(String topic) async {
    log.info('Subscribing to the topic $topic');
    _client.subscribe(topic, MqttQos.atMostOnce);
  }

  void unsubscribe(String topic) async {
    log.info('Unsubscribing from topic $topic');
    _client.unsubscribe(topic);
  }

  Future<void> publish(String topic, String value) async {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(value);
    _client.publishMessage(topic, MqttQos.atMostOnce, builder.payload);
  }

  bool isConnected() {
    return _client != null &&
        _client.connectionStatus.state == MqttConnectionState.connected;
  }

  void _startListening(void Function(String topic, String message) onMessage) {
    _messageListener = _client.updates.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      messages.forEach((receivedMessage) {
        final MqttPublishMessage mqttMessage = receivedMessage.payload;
        final String payloadMessage = MqttPublishPayload.bytesToStringAsString(
            mqttMessage.payload.message);

        onMessage(receivedMessage.topic, payloadMessage);

        log.info(
            'Change notification:: topic is <${messages[0].topic}>, payload is <-- $payloadMessage -->');
      });
    });
  }
}
