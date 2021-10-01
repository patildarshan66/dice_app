import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_app/authentication/vm_authentication.dart';
import 'package:dice_app/leaderboard/model_leaderboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../global_functions_variables.dart';

class VmLeaderboard with ChangeNotifier {
  List<ModelLeaderboard> _leaderboardList = [];

  List<ModelLeaderboard> get getLeaderboardList {
    return [..._leaderboardList];
  }

  requestResponseState responseState = requestResponseState.Loading;

  Future<void> fetchLeaderboard() async {
    try {
      responseState = requestResponseState.Loading;
      final firestoreInstance = FirebaseFirestore.instance;

      final res = await firestoreInstance.collection("leaderboard").get();

      if (res.docs == null) {
        return;
      }
      var data = res.docs;
      _leaderboardList = modelLeaderboardFromList(data);
      responseState = requestResponseState.DataReceived;
      notifyListeners();
    } catch (e) {
      responseState = requestResponseState.Error;
      notifyListeners();
      throw e;
    }
  }
}
