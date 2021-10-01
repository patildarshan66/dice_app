import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dice_app/additionalFiles/offline_data_manager.dart';
import 'package:dice_app/additionalFiles/routes.dart';
import 'package:dice_app/additionalFiles/sharedPref.dart';
import 'package:dice_app/authentication/vm_authentication.dart';
import 'package:dice_app/additionalFiles/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../additionalFiles/global_functions_variables.dart';


class DiceGame extends StatefulWidget {
  final int highestScore;

  const DiceGame({
    this.highestScore = 0,
  });

  @override
  _DiceGameState createState() => _DiceGameState();
}

class _DiceGameState extends State<DiceGame> with WidgetsBindingObserver {
  bool _isRolling = false;
  int _currentScore = 0;
  int _attemptsLeft = 10;

  String _incompleteGamekey;
  String _highestScoreKey;

  StreamController<int> _diceConroller = StreamController.broadcast();

  @override
  void initState() {
    String userId =
        Provider.of<VmAuthentication>(context, listen: false).userId;
    _incompleteGamekey = getIncompleteGameKey(userId);
    _getIncompleteGameData(); //get incomplete game data if available

    WidgetsBinding.instance.addObserver(this); //add observer for list app state
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _storeScoreInShared(); // store score in shared if user minimize app
    }
  }

  @override
  void dispose() {
    _diceConroller.close(); // for closed controller when screen closed
    WidgetsBinding.instance.removeObserver(this); // remove observer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: onBackPress,
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(top: mediumPadding),
            child: StreamBuilder(
              stream: _diceConroller.stream,
              initialData: 1,
              builder: (ctx, snapshot) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _getHeader(),
                  Visibility(
                    visible: !_isRolling,
                    child: Expanded(
                      flex: 2,
                      child:
                          Image.asset(_getDiceImageFromResult(snapshot.data)),
                    ),
                  ),
                  Visibility(
                    visible: _isRolling,
                    child: Expanded(
                      flex: 2,
                      child: Image.asset(
                        'assets/dice_gif.gif',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    child: Text('Roll a dice'),
                    onPressed: _getDiceResult,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _playAgain() {
    _isRolling = false;
    _currentScore = 0;
    _attemptsLeft = 10;
    _getDiceResult();
  }

  //get dice result in between 1 to 6
  void _getDiceResult() {
    if (_isRolling) {
      return; //if dice is already rolling break function call
    }

    _isRolling = true; //set rolling true for show dice gif
    _diceConroller.add(
        0); // for passed new event as a int in controller to tell stream builder to update ui according to new data

    Random random = new Random(); // for generate random number
    int min = 1,
        max = 6; //min and max for generate random number between 1 to 6
    int result =
        min + random.nextInt(max - min); //generate random number between 1 to 6
    Timer(Duration(seconds: 1), () {
      // for show rolling dice gif for 1 seconds
      _attemptsLeft -= 1; // for decrease 1 attempt from remaining attempts
      _currentScore += result; //added current result in total current score
      if (_attemptsLeft == 0) {
        _onGameComplete(); // execute this function when attempts left zero and game is completed

      }
      _isRolling = false; //set rolling false for show result and hide gif
      _diceConroller.add(
          result); //for passed new event as a int in controoler to tell stream builder to update ui according to new data
    });
  }

  //get dice image of current result
  String _getDiceImageFromResult(int result) {
    switch (result) {
      case 1: //execute if result is 1
        return 'assets/dice_1.png';
        break;
      case 2: //execute if result is 2
        return 'assets/dice_2.png';
        break;
      case 3: //execute if result is 3
        return 'assets/dice_3.png';
        break;
      case 4: //execute if result is 4
        return 'assets/dice_4.png';
        break;
      case 5: //execute if result is 5
        return 'assets/dice_5.png';
        break;
      case 6: //execute if result is 6
        return 'assets/dice_6.png';
        break;
      default: //execute if result is non of the above cases
        return 'assets/dice_1.png';
        break;
    }
  }

  // show msg when user exit from incomplete game
  Future<bool> onBackPress() async {
    bool result = false;
    if (_attemptsLeft != 0 && _attemptsLeft != 10) {
      result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Warning'),
          content: const Text("Game is incomplete. Do you want to exit?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No')),
            TextButton(
                onPressed: () {
                  _storeScoreInShared(); // store score in shared if user exit incomplete game
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Yes')),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
    return result;
  }

  //score header
  Widget _getHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: smallPadding),
      child: Card(
        color: Colors.brown[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: mediumPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _chip('Score', _currentScore.toString()),
              _chip('Chances', _attemptsLeft.toString()),
            ],
          ),
        ),
      ),
    );
  }

  //clips in score header to show score and attempts left
  _chip(String label, String value) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: largePadding, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.brown[900],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: textStyle),
          const SizedBox(width: smallHeightWidth),
          Text(
            value,
            style: Theme.of(context).textTheme.subtitle2.copyWith(
                  color: Colors.yellow[600],
                ),
          ),
        ],
      ),
    );
  }

  void _storeScoreInShared() async {
    Map<String, int> _map = {
      'score': _currentScore,
      'attemptsLeft': _attemptsLeft,
    };
    String incompleteGameData = json.encode(_map);

    setStringToPref(_incompleteGamekey, incompleteGameData);
  }

  Future<void> _getIncompleteGameData() async {
    bool isAvailable = await hasPref(_incompleteGamekey);
    if (isAvailable) {
      String incompleteGameData = await getStringFromPref(_incompleteGamekey);
      Map<String, dynamic> _map = json.decode(incompleteGameData);
      _currentScore = _map['score'];
      _attemptsLeft = _map['attemptsLeft'];
      _diceConroller.add(0);
    }
  }

  void _clearStoreIncompleteGameData() async {
    removePref(_incompleteGamekey);
  }

  void _onGameComplete() {
    _clearStoreIncompleteGameData(); //clear incomplete game data from shared Pref when game complete
    if (widget.highestScore > _currentScore) {
      _showNewHighScoreDialog();
    } else {
      _storeUserHighestScore();
    }
  }

  void _storeUserHighestScore() async {
    try {
      bool isNet = await checkNetwork();
      if (!isNet) {
        showCustomSnackBar(
            context, 'You are offline. Please turn on your internet.',
            color: Colors.red);

        return;
      }
      await Provider.of<VmAuthentication>(context, listen: false).storeNewHighScore(
          _currentScore); //stored latest high score in shared for offline use and online
      _showNewHighScoreDialog(isHighScore: true);
    } catch (e) {
      showCustomSnackBar(context, e.toString(), color: Colors.red);
    }
  }

  void _showNewHighScoreDialog({
    bool isHighScore = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: !isHighScore
            ? const Text(
                'Game Over',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.ac_unit, color: Colors.green),
                  Text(
                    'New Highest Score $_currentScore',
                    style: TextStyle(color: Colors.green),
                  )
                ],
              ),
        content: !isHighScore
            ? Text(
                'Score $_currentScore',
                textAlign: TextAlign.center,
              )
            : const Text('You break your last highest score.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, MyRoutes.mainPage,
                  arguments: 1);
            },
            child:const Text('LeaderBoard'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _playAgain();
            },
            child: const Text('Play Again'),
          )
        ],
      ),
    );
  }
}
