import 'dart:async';

import 'package:dice_app/additionalFiles/offline_data_manager.dart';
import 'package:dice_app/additionalFiles/routes.dart';
import 'package:dice_app/authentication/vm_authentication.dart';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import '../additionalFiles/constants.dart';
import '../additionalFiles/global_functions_variables.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _highestScore = 0;
  String _userName = 'Guest';
  String _profileUrl;
  bool _isNet = true;

  StreamController<bool> _profilePicController = StreamController.broadcast();

  void getNetStatus() async {
    _isNet = await checkNetwork();
    _profilePicController.add(true);
  }

  @override
  void dispose() {
    _profilePicController.close();
    super.dispose();
  }

  @override
  void initState() {
    getNetStatus();
    _userName = Provider.of<VmAuthentication>(context, listen: false).username;
    if (_userName == null) {
      _userName = 'Guest';
    }
    _profileUrl =
        Provider.of<VmAuthentication>(context, listen: false).profilePicUrl;
    if (_profileUrl == null) {
      _profileUrl = profileUrl;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _highestScore = Provider.of<VmAuthentication>(context).highestScore;
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(mediumPadding),
          child: Column(
            children: [
              _getProfileHeader(),
              const SizedBox(height: mediumHeightWidth),
              Expanded(
                child: Image.asset(
                  'assets/home_dice.png',
                ),
              ),
              const SizedBox(height: mediumHeightWidth),
              ElevatedButton(
                  onPressed: () async {
                    bool isNet = await checkNetwork();
                    if (!isNet) {
                      showCustomSnackBar(context,
                          'You are offline. Please turn on your internet.',
                          color: Colors.red);

                      return;
                    }
                    Navigator.pushNamed(context, MyRoutes.diceGame,
                        arguments: _highestScore);
                  },
                  child:const Text('Play'))
            ],
          ),
        ),
      ),
    );
  }

  Widget _getProfileHeader() {
    return Card(
      color: Colors.blue,
      child: Container(
        padding: const EdgeInsets.all(smallPadding),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, MyRoutes.profile);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder(
                    stream: _profilePicController.stream,
                    builder: (ctx, snapshot) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(
                          5,
                        ),
                      ),
                      height: 35,
                      width: 35,
                      child: _isNet
                          ? Image.network(
                              _profileUrl,
                              fit: BoxFit.contain,
                            )
                          : Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(width: smallHeightWidth),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: textStyle,
                      ),
                      const SizedBox(height: 5),
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerLeft,
                        children: [
                          LinearPercentIndicator(
                            width: 50.0,
                            lineHeight: 10.0,
                            percent: 0.65,
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            backgroundColor: Colors.blue[900],
                            progressColor: Colors.orange,
                          ),
                          Positioned(
                            left: -5,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                               const  Icon(
                                  Icons.star,
                                  size: 30,
                                  color: Colors.orange,
                                ),
                                const Text(
                                  '65',
                                  style: textStyle,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Highest Score',
                    style: textStyle,
                  ),
                  Text(
                    _highestScore.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
