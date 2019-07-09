import 'package:bloc/bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_time/src/blocs/analytics_event.dart';
import 'package:logging/logging.dart';

class LoggingBlocDelegate extends BlocDelegate {
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  final Logger log = Logger('LoggingBlocDelegate');

  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    if (event is AnalyticsEvent) {
      analytics.logEvent(
          name: event.analyticsName, parameters: event.analyticsParameters);
    }
    log.info(event);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    log.severe(error);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log.finer(transition);
  }
}
