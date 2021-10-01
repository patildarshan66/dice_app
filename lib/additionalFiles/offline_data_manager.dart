import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<bool> checkNetwork() async {
  bool networkStatus = false;
  try {
    final result = await InternetAddress.lookup('google.com');

    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      networkStatus = true;
    }
  } on SocketException catch (_) {
    networkStatus = false;
  }
  return networkStatus;
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> _localFile(String fileName) async {
  final path = await _localPath;
  return File('$path/$fileName');
}

void _writeJson({String jsonBody, File filePath}) async {
  filePath.writeAsString(jsonBody);
}

Future<dynamic> getOfflineData(String fileName) async {
  try {
    File _filePath = await _localFile(fileName);
    bool _fileExists = await _filePath.exists();
    if (_fileExists) {
      String response = await _filePath.readAsString();
      print("Offline get");
      return json.decode(response);
    } else {
      return '';
    }
  } catch (e) {
    throw e;
  }
}

Future<void> storeOfflineData(String fileName, dynamic data) async {
  try {
    File _filePath = await _localFile(fileName);
    _writeJson(jsonBody: json.encode(data), filePath: _filePath);
    print("Offline saved");
  } catch (e) {
    throw e;
  }
}
