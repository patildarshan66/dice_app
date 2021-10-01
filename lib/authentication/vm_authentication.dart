import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_app/global_functions_variables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../sharedPref.dart';

class VmAuthentication with ChangeNotifier {
  String _userName;
  String _email;
  String _userId;
  String _profilePicUrl;
  int _highestScore;

  int get highestScore {
    return _highestScore;
  }

  String get username {
    return _userName;
  }

  String get email {
    return _email;
  }

  String get userId {
    return _userId;
  }

  String get profilePicUrl {
    return _profilePicUrl;
  }

  bool get isAuth {
    return _userId != null;
  }

  Future<bool> tryAutologin() async {
    final prefs = await getShared();

    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedData =
        await json.decode(prefs.getString('userData')) as Map<String, Object>;

    _userId = extractedData['userId'];
    _userName = extractedData['userName'];
    _email = extractedData['email'];
    _profilePicUrl = extractedData['profilePicUrl'];

    _highestScore = extractedData['highScore'];

    final firestoreInstance = FirebaseFirestore.instance;
    final res = await firestoreInstance.collection("users").doc(_userId).get();
    if (res.data() != null) {
      var data = res.data();
      var highScore = data['highScore'];
      if (highScore > _highestScore) {
        _highestScore = highScore;
        setStringToPref("userData", json.encode(data));
      } else {
        firestoreInstance
            .collection("users")
            .doc(_userId)
            .update({"highScore": _highestScore});
      }
    } else {
      Map<String, dynamic> userData = {
        "userId": _userId,
        "userName": _userName,
        "email": _email,
        "profilePicUrl": _profilePicUrl,
        "highScore": _highestScore,
      };
      await firestoreInstance.collection("users").doc(_userId).set(userData);
    }
    notifyListeners();
    return true;
  }

  Future<void> storeUserData(UserCredential userCredential) async {
    final firestoreInstance = FirebaseFirestore.instance;
    var user = userCredential.user;
    _userName = user.displayName;
    _email = user.email;
    _profilePicUrl = user.photoURL;
    _highestScore = 0;
    _userId = user.uid;
    notifyListeners();
    try {
      final res =
          await firestoreInstance.collection("users").doc(_userId).get();

      if (res.data() != null) {
        var data = res.data();
        _highestScore = data['highScore'];
        setStringToPref("userData", json.encode(data));
      } else {
        Map<String, dynamic> userData = {
          "userId": _userId,
          "userName": _userName,
          "email": _email,
          "profilePicUrl": _profilePicUrl,
          "highScore": 0
        };
        await firestoreInstance.collection("users").doc(_userId).set(userData);
        setStringToPref("userData", json.encode(userData));
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> storeNewHighScore(int highScore) async {
    try {
      _highestScore = highScore;
      final firestoreInstance = FirebaseFirestore.instance;

      Map<String, dynamic> userData = {
        "userId": _userId,
        "userName": _userName,
        "email": _email,
        "profilePicUrl": _profilePicUrl,
        "highScore": highScore,
      };
      setStringToPref("userData", json.encode(userData));
      notifyListeners();
      await firestoreInstance
          .collection("users")
          .doc(_userId)
          .update({"highScore": highScore});
      await firestoreInstance.collection("leaderboard").doc(_userId).set({
        "userName": _userName,
        "highScore": highScore,
      }, SetOptions(merge: true));
    } catch (e) {
      throw e;
    }
  }
}