library speedometer;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_time/src/blocs/speedometer/bloc.dart';
import 'package:flutter_time/src/blocs/speedometer/hand_painter.dart';
import 'package:flutter_time/src/blocs/speedometer/line_painter.dart';
import 'package:flutter_time/src/blocs/speedometer/speed_text_painter.dart';

class SpeedometerWidget extends StatefulWidget {
  final SpeedometerBloc _speedometerBloc;

  SpeedometerWidget({SpeedometerBloc speedometerBloc})
      : _speedometerBloc = speedometerBloc;

  @override
  _SpeedometerWidgetState createState() => _SpeedometerWidgetState();
}

class _SpeedometerWidgetState extends State<SpeedometerWidget>
    with TickerProviderStateMixin {
  SpeedometerState _speedometerState = SpeedometerState.stopped();

  AnimationController percentageAnimationController;
  double val = 0;
  double newVal;

  ThemeData _themeData;

  @override
  void initState() {
    super.initState();
    _themeData = ThemeData.light();
    percentageAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..addListener(() {
        if (mounted) {
          setState(() {
            val = lerpDouble(val, newVal, percentageAnimationController.value);
          });
        }
      });
  }

  @override
  void deactivate() {
    super.deactivate();
    percentageAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpeedometerEvent, SpeedometerState>(
      bloc: widget._speedometerBloc,
      listener: (context, state) {
        if (state.running) {
          _speedometerState = state;
          newVal = state.value;
          percentageAnimationController.forward(from: 0.0);
        }
      },
      child: Center(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              height: constraints.maxWidth - 100,
              width: constraints.maxWidth - 100,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Container(
                    child: CustomPaint(
                      foregroundPainter: LinePainter(
                          lineColor: _themeData.backgroundColor,
                          completeColor: _themeData.primaryColor,
                          startValue: _speedometerState.start.toInt(),
                          endValue: _speedometerState.end.toInt(),
                          startPercent: 0.05,
                          endPercent: 0.95,
                          width: 20.0),
                    ),
                  ),
                  Center(
                    child: Container(
                      height: constraints.maxWidth,
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      child: Stack(fit: StackFit.expand, children: <Widget>[
                        CustomPaint(
                          painter: HandPainter(
                            value: val,
                            start: _speedometerState.start.toInt(),
                            end: _speedometerState.end.toInt(),
                            color: _themeData.accentColor,
                          ),
                        ),
                      ]),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 30.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _themeData.backgroundColor,
                      ),
                    ),
                  ),
                  CustomPaint(
                    painter: SpeedTextPainter(
                      start: _speedometerState.start.toInt(),
                      end: _speedometerState.end.toInt(),
                      value: this.val,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
