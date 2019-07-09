import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';

class LoggingBlocTestDelegate extends BlocDelegate {
  final Logger log = Logger('LoggingBlocDelegate');

  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    log.info(event);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    log.info(error);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log.info(transition);
  }
}
