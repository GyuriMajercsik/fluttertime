import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SharedPreferencesEvent extends Equatable {
  SharedPreferencesEvent([List props = const []]) : super(props);
}

class SaveLastEmailAddress extends SharedPreferencesEvent {
  final String lastEmailAddress;

  SaveLastEmailAddress(this.lastEmailAddress) : super([lastEmailAddress]);

  @override
  String toString() {
    return 'SaveLastEmailAddress: $lastEmailAddress';
  }
}

class SharedPreferencesChanged extends SharedPreferencesEvent {
  @override
  String toString() {
    return 'SharedPreferencesChanged';
  }
}
