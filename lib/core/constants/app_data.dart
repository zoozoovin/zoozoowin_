import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:zoozoowin_/core/app_imports.dart';


import '../helpers/utils.dart';

class AppData {


  static String lang = "en";


  static Color hexToColor(String hexColor) {
    final buffer = StringBuffer();
    if (hexColor.length == 6 || hexColor.length == 7) buffer.write('ff');
    buffer.write(hexColor.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  //Convert to Argb
  static List<int> hexToRgba(String hexColor) {
    Color color = hexToColor(hexColor);
    return [color.red, color.green, color.blue, (color.alpha * 255).toInt()];
  }

  //Format Date and Time
  static String FormatDate(String a) {
    DateTime dateTime = DateTime.parse(a);

    String formattedDate = DateFormat('dd.MM.yyyy').format(dateTime);

    return formattedDate;
  }

  static String FormatTime(String a) {
    DateTime dateTime = DateTime.parse(a);

    String formattedTime = DateFormat('hh:mm a').format(dateTime);
    return formattedTime;
  }





  

 static Map<String, String> cardImages = {
   "c1": "assets/images/k_jack.png",
    "c2": "assets/images/k_heart.png",
    "c3": "assets/images/k_club.png",
    "c4": "assets/images/k_diamond.png",
    "c5": "assets/images/q_jack.png",
    "c6": "assets/images/q_heart.png",
    "c7": "assets/images/q_club.png",
    "c8": "assets/images/q_diamond.png",
    "c9": "assets/images/j_jack.png",
    "c10": "assets/images/j_heart.png",
    "c11": "assets/images/j_club.png",
    "c12": "assets/images/j_diamond.png",
  };


  static List<String> timeSlots = [
      '12:00 PM',
      '01:00 PM',
      '02:00 PM',
      '03:00 PM',
      '04:00 PM',
      '05:00 PM',
      '06:00 PM',
      '07:00 PM',
      '08:00 PM',
      '09:00 PM',
      '10:00 PM',
      '11:00 PM'
    ];




    static void navigateToNotification(BuildContext context, Widget? a) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: a, // Replace with your notification screen
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
}
