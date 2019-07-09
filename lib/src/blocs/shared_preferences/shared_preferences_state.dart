import 'package:meta/meta.dart';

@immutable
class SharedPreferencesState {
  final String lastEmailAddress;

  SharedPreferencesState({this.lastEmailAddress});

  SharedPreferencesState update({String lastEmailAddress}) {
    return SharedPreferencesState(lastEmailAddress: lastEmailAddress);
  }
}
