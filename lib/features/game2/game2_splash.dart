import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/core/constants/app_data.dart';
import 'package:zoozoowin_/features/game2/game2.dart';

class Game2SplashScreen extends StatefulWidget {
  const Game2SplashScreen({Key? key}) : super(key: key);

  @override
  State<Game2SplashScreen> createState() => _Game2SplashScreenState();
}

class _Game2SplashScreenState extends State<Game2SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(milliseconds: 700), () {

      // Navigator.pushReplacement(context,
      //     MaterialPageRoute(builder: (context) => const Game2Screen()));

      Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: Game2Screen(), // Replace with your notification screen
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  
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

          fit: BoxFit.cover, // Adjust width and height as needed
        ),
      ),
    );
  }
}
