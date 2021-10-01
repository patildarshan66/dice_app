import 'package:dice_app/authentication/authentication.dart';
import 'package:dice_app/dice/dice_game.dart';
import 'package:dice_app/profile.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'main.dart';

abstract class MyRoutes {
  static const mainPage = "/";
  static const authentication = "/Authentication";
  static const diceGame = "/DiceGame";
  static const profile = "/Profile";

}

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    var name = settings.name;
    final args = settings.arguments;

    switch (name) {
      case MyRoutes.mainPage:
        return PageTransition(child: MainPage(), settings: settings);
        case MyRoutes.profile:
        return PageTransition(child: Profile(), settings: settings);
      case MyRoutes.diceGame:
        return PageTransition(
            child: DiceGame(highestScore: args), settings: settings);
      case MyRoutes.authentication:
      default:
        return PageTransition(child: Authentication(), settings: settings);
    }
  }
}
