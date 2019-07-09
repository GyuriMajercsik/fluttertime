import 'package:equatable/equatable.dart';
import 'package:flutter_time/src/blocs/analytics_event.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AuthenticationEvent extends Equatable {
  AuthenticationEvent([List props = const []]) : super(props);
}

class AppStarted extends AuthenticationEvent {
  @override
  String toString() => 'AppStarted';
}

class LoggedIn extends AuthenticationEvent implements AnalyticsEvent {
  @override
  String toString() => 'LoggedIn';

  @override
  String get analyticsName => 'LoggedIn';

  @override
  Map<String, dynamic> get analyticsParameters => {};
}

class LoggedOut extends AuthenticationEvent implements AnalyticsEvent {
  @override
  String toString() => 'LoggedOut';

  @override
  String get analyticsName => 'LoggedOut';

  @override
  Map<String, dynamic> get analyticsParameters => {};
}
