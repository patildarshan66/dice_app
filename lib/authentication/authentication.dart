import 'package:dice_app/authentication/vm_authentication.dart';
import 'package:dice_app/constants.dart';
import 'package:dice_app/global_functions_variables.dart';
import 'package:dice_app/home/home.dart';
import 'package:dice_app/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../main.dart';

class Authentication extends StatefulWidget {
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login With',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: mediumHeightWidth),
            InkWell(
              onTap: _authenticate,
              child: Image.network(
                googlePicUrl,
                height: 100,
                width: 100,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
    // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      throw e;
    }
  }

  Future<void> _authenticate() async {
    try {
      UserCredential userCredential = await signInWithGoogle();
      await VmAuthentication().storeUserData(userCredential);
      showCustomSnackBar(context, 'Login Successful.');
      Navigator.pushReplacementNamed(
        context,
        MyRoutes.mainPage,
      );
    } catch (e) {
      showCustomSnackBar(context, e.toString(),
          color: Colors.red); //show error msg at bottom of the screen
    }
  }
}
