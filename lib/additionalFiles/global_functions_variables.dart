import 'package:flutter/material.dart';

String getIncompleteGameKey(String userId) {
  return userId + "|Incomplete";
}

enum requestResponseState { Error, DataReceived, Loading }

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
