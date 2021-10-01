import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: const Text(
            'Loading...',
            style:
                TextStyle(color: Colors.black45, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
