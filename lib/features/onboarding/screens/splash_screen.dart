// ignore_for_file: unused_import

import 'dart:async';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/features/home/screens/home_screen.dart';
import 'package:zoozoowin_/features/nav_screen.dart';
import 'package:zoozoowin_/features/onboarding/data/update_provider.dart';
import 'package:zoozoowin_/features/wallet/data/wallet_provider.dart';
import 'package:zoozoowin_/route/app_pages.dart';
import 'package:zoozoowin_/route/custom_navigator.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<UpdateProvider>(context, listen: false).update_app();
      initialize();
    });
    // _getAppVersion();


    
  }


// String _appVersion = '';
//    Future<void> _getAppVersion() async {
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();

//     setState(() {
//       _appVersion = packageInfo.version;
//     });
//     print(_appVersion);
//   }

  void _showUpdateDialog(String url) {
    showDialog(
      context: context,
     barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Available'),
          content: Text(
              'A new version of the app is available. Please update to continue.'),
          actions: [
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: Text('Later'),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
                _launchURL(url);
              },
              child: Text('Update Now'),
            ),
          ],
        );
      },
    );
  }

  void _launchURL(String link) async {
    String url = link;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> initialize() async {
    final p = Provider.of<UpdateProvider>(context, listen: false);
    if (p.isUpdate) {
      _showUpdateDialog(p.url);
    } else {
      print("==============Else===========");
      Timer(Duration(milliseconds: 1000), () async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        bool isLogin = prefs.getBool('isLogin') ?? false;

        if (isLogin) {
          await _audioPlayer.play(AssetSource('sounds/splash.mp3'));
          _navigateToNotification(context);
        } else {
          await _audioPlayer.play(AssetSource('sounds/splash.mp3'));

          CustomNavigator.pushReplace(context, AppPages.phoneAuth);
        }
      });
    }
  }

  void _navigateToNotification(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: NavBarScreen(
              index: 0,
            ), // Replace with your notification screen
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
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.splash_bg),
            fit: BoxFit.cover,
          ),
        ),
        child: const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 88.0),
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
