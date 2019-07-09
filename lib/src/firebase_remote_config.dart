import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseRemoteConfigRepository {
  RemoteConfig _remoteConfig;

  Future<void> initialize() async {
    _remoteConfig = await RemoteConfig.instance;
    return refresh();
  }

  String getString(String key) {
    return _remoteConfig.getString(key);
  }

  bool getBool(String key) {
    return _remoteConfig.getBool(key);
  }

  int getInt(String key) {
    return _remoteConfig.getInt(key);
  }

  double getDouble(String key) {
    return _remoteConfig.getDouble(key);
  }

  Future<void> refresh() async {
    await _remoteConfig.fetch(expiration: Duration(hours: 6));
    await _remoteConfig.activateFetched();
  }
}
