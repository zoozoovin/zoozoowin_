import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zoozoowin_/features/game1/game1_timeslotscreen.dart';
import 'package:zoozoowin_/route/app_pages.dart';
import 'package:zoozoowin_/route/custom_navigator.dart';

class Game1Splash extends StatefulWidget {
  const Game1Splash({Key? key}) : super(key: key);

  @override
  State<Game1Splash> createState() => _Game1SplashState();
}

class _Game1SplashState extends State<Game1Splash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 2), () {
     CustomNavigator.pushReplace(context, AppPages.game1timeslot);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/game.gif',
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          // Adjust width and height as needed
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
