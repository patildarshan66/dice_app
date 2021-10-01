import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences _prefs;

setStringToPref(String key, var value) async {
  SharedPreferences sharedPreferences = await getShared();
  sharedPreferences.setString(key, value);
}

setIntToPref(String key, var value) async {
  SharedPreferences sharedPreferences = await getShared();
  sharedPreferences.setInt(key, value);
}

Future<int> getIntFromPref(String key) async {
  var value;

  try {
    SharedPreferences sharedPreferences = await getShared();

    value = sharedPreferences.getInt(key);
  } catch (e) {
    return null;
  }

  return value;
}

Future<String> getStringFromPref(String key) async {
  var value;

  try {
    SharedPreferences sharedPreferences = await getShared();

    value = sharedPreferences.getString(key);
  } catch (e) {
    return null;
  }

  return value;
}

Future<bool> hasPref(String key) async {
  SharedPreferences prefs = await getShared();
  return prefs.containsKey(key);
}

removePref(String key) async {
  bool isAvailable = await hasPref(key);
  if (!isAvailable) {
    return;
  }
  SharedPreferences prefs = await getShared();
  prefs.remove(key);
}

Future<SharedPreferences> getShared() async {
  if (_prefs == null) {
    _prefs = await SharedPreferences.getInstance();
  }
  return _prefs;
}
