import 'package:shared_preferences/shared_preferences.dart';

const String KEY_LAST_EMAIL_ADDRESS = 'last_email_address';

class SharedPreferencesRepository {
  final SharedPreferences _sharedPreferences;

  SharedPreferencesRepository(this._sharedPreferences);

  void setLastEmailAddress(String lastEmailAddress) async {
    await _sharedPreferences.setString(
        KEY_LAST_EMAIL_ADDRESS, lastEmailAddress);
  }

  String getLastEmailAddress() {
    return _sharedPreferences.getString(KEY_LAST_EMAIL_ADDRESS) ?? '';
  }
}
