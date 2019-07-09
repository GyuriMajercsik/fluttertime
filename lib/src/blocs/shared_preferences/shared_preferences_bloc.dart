import 'package:bloc/bloc.dart';
import 'package:flutter_time/src/blocs/shared_preferences/shared_preferences_event.dart';
import 'package:flutter_time/src/blocs/shared_preferences/shared_preferences_state.dart';
import 'package:flutter_time/src/shared_preferences_repository.dart';

class SharedPreferencesBloc
    extends Bloc<SharedPreferencesEvent, SharedPreferencesState> {
  final SharedPreferencesRepository _sharedPreferencesRepository;

  SharedPreferencesBloc(this._sharedPreferencesRepository);

  @override
  SharedPreferencesState get initialState => SharedPreferencesState(
      lastEmailAddress: _sharedPreferencesRepository.getLastEmailAddress());

  @override
  Stream<SharedPreferencesState> mapEventToState(
    SharedPreferencesEvent event,
  ) async* {
    if (event is SaveLastEmailAddress) {
      yield* _mapEmailChangedToState(event.lastEmailAddress);
    }
  }

  Stream<SharedPreferencesState> _mapEmailChangedToState(String email) async* {
    _sharedPreferencesRepository.setLastEmailAddress(email);
    yield currentState.update(lastEmailAddress: email);
  }
}
