import 'package:flutter/material.dart';

String getIncompleteGameKey(String userId) {
  return userId + "|Incomplete";
}

enum requestResponseState { Error, DataReceived, Loading }

BuildContext _dialogContext;

void closeLoader() {
  if (_dialogContext != null) {
    Navigator.pop(_dialogContext);
    _dialogContext = null;
  }
}

Future<void> startLoader(BuildContext context) async {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (buildContext) {
      _dialogContext = buildContext;
      return Container(
          height: 50,
          width: 50,
          child: Center(child: CircularProgressIndicator()));
    },
  );
}

void showCustomSnackBar(
  BuildContext context,
  String msg, {
  Color color = Colors.green,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,
      content: Text(msg),
    ),
  );
}
