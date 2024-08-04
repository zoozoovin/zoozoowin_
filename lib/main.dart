import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoozoowin_/core/constants/app_themes.dart';
import 'package:zoozoowin_/core/constants/value_constants.dart';
import 'package:zoozoowin_/core/loaded_widget.dart';
import 'package:zoozoowin_/core/managers/app_manager.dart';
import 'package:zoozoowin_/core/managers/shared_preference_manager.dart';
import 'package:zoozoowin_/core/utils/screen_utils.dart';
import 'package:zoozoowin_/features/game1/game_provider.dart';
import 'package:zoozoowin_/features/home/data/home_provider.dart';
import 'package:zoozoowin_/features/home/data/profile_provider.dart';
import 'package:zoozoowin_/features/home/data/result_provider.dart';
import 'package:zoozoowin_/features/home/data/result_ticket_provider.dart';
import 'package:zoozoowin_/features/home/data/ticket_provider.dart';
import 'package:zoozoowin_/features/notificaiton_provider.dart';
import 'package:zoozoowin_/features/onboarding/data/update_provider.dart';
import 'package:zoozoowin_/features/onboarding/screens/splash_screen.dart';
import 'package:zoozoowin_/features/wallet/data/transaction_provider.dart';
import 'package:zoozoowin_/features/wallet/data/wallet_provider.dart';
import 'package:zoozoowin_/notification_service.dart';
import 'package:zoozoowin_/route/custom_navigator.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppManager.initialize();

  FirebaseMessaging.onBackgroundMessage(_FirebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> _FirebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  NotificationService notificationService = NotificationService();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    notificationService.requestNotificationPermission();
    // getDeviceID();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    notificationService.isRefreshToken();
    notificationService.getToken().then((v) async{
      print(v);
      SharedPreferencesManager.setString("fcm_token", v);
      await func();
    });
  }


  Future<void> func() async {
    print("hello");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone = prefs.getString('phone') ?? "";

    String fcm_token = prefs.getString('fcm_token')!;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final DatabaseReference _database =
        FirebaseDatabase.instance.ref('username');
    DatabaseReference ref = _database.child(phone);
    DataSnapshot snapshot = await ref.get();

    print(snapshot);

    print(fcm_token);
    if (snapshot.exists) {
      print("inside");
      await ref.update({'fcm_token': fcm_token});
    }
  }



  // Future<void> getDeviceID() async {
  //   String? id = await notificationService.getDeviceId(context);
  //   SharedPreferencesManager.setString("deviceID", id);
  //   print("Device ID");
  //   print(id);
  // }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WalletProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => NotificaitonProvider(),
        ),


        ChangeNotifierProvider
        (
          create: (_) => TicketProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ResultProvider(),
        ),


        ChangeNotifierProvider(
          create: (_) => TransactionProvider(),
        ),

        
        ChangeNotifierProvider(
          create: (_) => HomeProvider(),
        ),

        ChangeNotifierProvider
        (
          create: (_) => ResultTicketProvider(),
        ),


        ChangeNotifierProvider(
          create: (_) => GameProvider(),
        ),


        ChangeNotifierProvider(
          create: (_) => UpdateProvider(),
        ),
      ],
      child: ScreenUtilInit(
        designSize:
            const Size(VALUE_FIGMA_DESIGN_WIDTH, VALUE_FIGMA_DESIGN_HEIGHT),
        builder: () => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'zoozoowin',
          initialRoute: '/',
          onGenerateRoute: CustomNavigator.controller,
          themeMode: ThemeMode.light,
          builder: OverlayManager.transitionBuilder(),
          theme: AppThemes.light,
          home: SplashScreen(),
        ),
      ),
    );
  }
}
