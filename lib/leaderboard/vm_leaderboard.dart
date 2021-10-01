import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_app/additionalFiles/offline_data_manager.dart';
import 'package:dice_app/authentication/vm_authentication.dart';
import 'package:dice_app/leaderboard/model_leaderboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../additionalFiles/global_functions_variables.dart';

class VmLeaderboard with ChangeNotifier {
  List<ModelLeaderboard> _leaderboardList = [];
  String fileName = 'leaderboard';

  List<ModelLeaderboard> get getLeaderboardList {
    return [..._leaderboardList];
  }

  requestResponseState responseState = requestResponseState.Loading;

  Future<void> fetchLeaderboard() async {
    try {
      responseState = requestResponseState.Loading;
      bool isNet = await checkNetwork();
      if (isNet) {
        final firestoreInstance = FirebaseFirestore.instance;

        final res = await firestoreInstance.collection("leaderboard").get();

        if (res.docs == null) {
          throw 'Noo data';
        }
        var data = res.docs;

        _leaderboardList = modelLeaderboardFromListFirestore(data);
        storeOfflineData(fileName, _leaderboardList);
      } else {
        final res = await getOfflineData(fileName);
        if (res == '') {
          throw 'Your are offline.';
        }
        _leaderboardList = modelLeaderboardFromListOffline(res);
      }

      responseState = requestResponseState.DataReceived;
      notifyListeners();
    } catch (e) {
      responseState = requestResponseState.Error;
      notifyListeners();
      throw e;
    }
  }
}
