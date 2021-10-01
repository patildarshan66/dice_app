import 'dart:async';

import 'package:dice_app/home/home.dart';
import 'package:dice_app/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'additionalFiles/routes.dart';
import 'authentication/authentication.dart';
import 'authentication/vm_authentication.dart';
import 'leaderboard/leaderboard.dart';
import 'leaderboard/vm_leaderboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => VmAuthentication()),
        ChangeNotifierProvider(create: (context) => VmLeaderboard()),
      ],
      child: MaterialApp(
        title: 'Dice App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        onGenerateRoute: Routes.generateRoute,
        home: Consumer<VmAuthentication>(builder: (ctx, auth, _) {
          return auth.isAuth
              ? MainPage()
              : FutureBuilder(
                  future: auth.tryAutologin(),
                  builder: (ctx, authResultSnapShot) =>
                      authResultSnapShot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : Authentication(),
                );
        }),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  StreamController<bool> _stateController = StreamController.broadcast();

  @override
  void dispose() {
    _stateController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedIndex == null) {
      _selectedIndex = ModalRoute.of(context).settings.arguments;
      if (_selectedIndex == null) {
        _selectedIndex = 0;
      }
    }
    print(_selectedIndex);
    return StreamBuilder(
      stream: _stateController.stream,
      builder: (ctx, snapshot) => Scaffold(
        bottomNavigationBar: _getBottomNavigationBar(),
        body: _getMainBody(),
      ),
    );
  }

  Widget _getMainBody() {
    switch (_selectedIndex) {
      case 0:
        return Home();
        break;
      case 1:
        return Leaderboard();
        break;
      default:
        return Home();
        break;
    }
  }

  BottomNavigationBar _getBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).primaryColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(.60),
      selectedFontSize: 14,
      unselectedFontSize: 14,
      currentIndex: _selectedIndex,
      onTap: (value) {
        if (_selectedIndex != value) {
          _selectedIndex = value;
          _stateController.add(true);
        }
      },
      items: [
        BottomNavigationBarItem(
          label: 'Home',
          icon: Icon(Icons.home),
        ),
        BottomNavigationBarItem(
          label: 'Leaderboard',
          icon: Icon(Icons.leaderboard),
        ),
      ],
    );
  }
}
