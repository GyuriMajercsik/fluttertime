import 'dart:async';
import 'dart:math';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time/main.dart';
import 'package:flutter_time/src/blocs/mqtt/bloc.dart';
import 'package:flutter_time/src/blocs/speedometer/bloc.dart';
import 'package:flutter_time/src/blocs/speedometer/speedometer_widget.dart';
import 'package:flutter_time/src/speedometer_data_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logging/logging.dart';

class SpeedometerScreen extends StatefulWidget {
  @override
  _SpeedometerScreenState createState() => _SpeedometerScreenState();
}

class _SpeedometerScreenState extends State<SpeedometerScreen>
    with AfterLayoutMixin<SpeedometerScreen> {
  final Logger log = Logger('SpeedometerScreen');

  SpeedometerDataProvider _dataProvider;

  @override
  Widget build(BuildContext context) {
    bool isRandomDataProvider = _dataProvider is SpeedometerRandomDataProvider;
    bool isMqttDataProvider = _dataProvider is SpeedometerMQTTDataProvider;

    log.fine('Using ${isRandomDataProvider ? 'random' : 'mqtt'} data');
    return Scaffold(
      appBar: AppBar(
        title: Text('Speedometer'),
      ),
      persistentFooterButtons: <Widget>[
        IconButton(
          color: isRandomDataProvider ? Colors.blue : Colors.blueGrey,
          icon: Icon(FontAwesomeIcons.random),
          onPressed: () {
            _useRandomDataProvider();
          },
        ),
        IconButton(
          color: isMqttDataProvider ? Colors.blue : Colors.blueGrey,
          icon: Icon(FontAwesomeIcons.cloud),
          onPressed: () {
            _useMqttDataProvider();
          },
        ),
      ],
      body: SpeedometerWidget(
        speedometerBloc: getIt<SpeedometerBloc>(),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    var mqttBloc = getIt<MqttBloc>();

    mqttBloc.dispatch(Connect(
      broker: 'test.mosquitto.org',
      clientId: 'mqtt_client_${Random().nextInt(200)}',
    ));

    _useRandomDataProvider();
  }

  @override
  void deactivate() {
    super.deactivate();
    _stopDataProvider();
    var mqttBloc = getIt<MqttBloc>();

    mqttBloc.dispatch(Disconnect());

  }

  void _useRandomDataProvider() async {
    _stopDataProvider();

    String publishOnTopic = await _showMqttTopicInputDialog(
      title: 'Publish on MQTT topic',
      hint: 'MQTT topic',
      button: 'PUBLISH',
    );

    setState(() {
      _dataProvider = SpeedometerRandomDataProvider(
        getIt<SpeedometerBloc>(),
        getIt<MqttBloc>(),
        publishOnTopic: publishOnTopic,
      );
      _dataProvider.start();
    });
  }

  void _useMqttDataProvider() async {
    _stopDataProvider();

    String listenTopic = await _showMqttTopicInputDialog(
      title: 'Listen on MQTT topic',
      hint: 'MQTT topic',
      button: 'LISTEN',
    );

    setState(() {
      _dataProvider = SpeedometerMQTTDataProvider(
        getIt<SpeedometerBloc>(),
        getIt<MqttBloc>(),
        listenTopic,
      );
      _dataProvider.start();
    });
  }

  void _stopDataProvider() {
    if (_dataProvider != null) {
      _dataProvider.stop();
      _dataProvider = null;
    }
  }

  Future<String> _showMqttTopicInputDialog({
    String title,
    String hint,
    String button,
  }) {
    return showDialog(
        context: context,
        builder: (context) {
          TextEditingController controller = TextEditingController();

          return AlertDialog(
            title: Text(title),
            content: TextField(
              decoration: InputDecoration(hintText: hint),
              controller: controller,
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text(button),
                onPressed: () {
                  Navigator.of(context).pop(controller.value.text);
                },
              ),
            ],
          );
        });
  }
}
