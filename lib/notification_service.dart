// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/core/managers/shared_preference_manager.dart';
import 'package:zoozoowin_/features/home/screens/notification_screen.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<bool> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User Granted Permission");
      return true;
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("User Granted provisional Permission");
      return true;
    } else {
      print("User denied Permission");
      return false;
    }
  }

  Future<String> getToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  Future<String?> getDeviceId(BuildContext context) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor;
    } else {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    }
  }

  void isRefreshToken() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }

  void initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        const AndroidInitializationSettings("@mipmap/launcher_icon");
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
      HandleReceive(context, message);
    });
  }

  Future<void> firebaseInit(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((message) {
      if (Platform.isAndroid) {
        initLocalNotification(context, message);
        showNotification(message);
        HandleReceive(context, message); // Handle navigation here
      } else {
        showNotification(message);
        HandleReceive(context, message); // Handle navigation here
      }
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(10000).toString(),
        'High Importance Notification',
        importance: Importance.max);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: 'Your Channel Description',
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker');

    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    // Extracting payload data
    Map<String, dynamic> payloadData = message.data;

    Future.delayed(Duration.zero, () {
      print("=============payload data===============");
      print(payloadData);
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails,
          payload: payloadData.toString()); // Adding payload data
    });
  }

  void HandleReceive(BuildContext context, RemoteMessage? message) {
    print("===============handle Receive ================");
    print(message!.data);

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => NotificationScreen()));
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    // when app terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      HandleReceive(context, initialMessage); // Handle navigation here
    }

    //when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      HandleReceive(context, event); // Handle navigation here
    });
  }
}

class PushNotificationService {
  static Future<String> getAccessToken() async {
    // Your client ID and client secret obtained from Google Cloud Console
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "zoozoovin-86d2e",
      "private_key_id": "d0ed8cbd19f0801bd29158469fbf5780f6503935",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC5uneOvL1dqFtk\nDVk30raWfLdKI0exNZG1DPKiIxFj3LxEf5rrzd29/SMFGR4z+XnsC7ZZFQivLInc\nXWgy7MCpzvRjddWABuRvQaZphCVPAZYKDcEJlEtD7cAZ8iOSFw62Eubvy1K7YBPB\ntD0mZf8uKNOwLChLtyd5VN78K/iAgx04cCljT/mFn1EKsSRTirXacN1SjhFgCMSt\nAFXAnHOIMF6g5w5FYi7RNxqQJmFJReTDTs03xpioqu/jBpkpRmWGb8aq1Qi7h8jX\n+7Ad94f/kDF7TrHRle1KjYhomBL87AIH8Hf6SHXuk8r4cB8kW12biI0/0dBW8Kpy\nhCHf/ilLAgMBAAECggEABMvkf4qvR0ZsScqwdaka7wr8fs0nclOkVi0l7PsD3XTb\nZdd3zEQuSFRLvbt21LfKJsbsqCNLbJ61VrwQz1Pe6+O82v61i09iQd9LqWjwv7gW\nRF8zj4hFY1U2A1WGBqVSy2/0h9fT5KPoDrYVaDL1Ip+KS//v8Hij69W9xnxqOANf\nfqufnDrIcr1VBsTmzUJfqPM8z67+1htjf0CbcLvxOUXZoXrbETpbYou1z7IproHh\nWlNp0sJi/0BR5omoLLGaaJfFBwcFV5TLKKwXbqJ/Vnzec+rnWLaVqx5OM3jRRPq4\ndO6zp5XWb7dLZIu39j4bTiMhpxCJUj17zAG2/ErqkQKBgQDzYFwc6tnuT7tKiLDK\nY5V8fkd15+89S6WhSLgfTt4TmuHMFOW1FzkmHPcFUkK1wbr0HFXHzO8sJcSNw7zI\njCjgdIUOeUFqPcqvWE8NmMvmTE/4zoIETBkisT2J6szuVPaDMe0yUbwYdapjqadO\n8S3fwWyf5reVcp1QWtc9UwgR2wKBgQDDXKLKnvjG/agp4uQ1AbQyRxO8Ias6dtIR\nhbGbzzzBTZHlTzPcTmOg4cOLsGTI/6FY1gxvWIIAV76BJrDwZmT4+ktHKSy1nimW\n0bFO13bPTlUHK8zdYEn8yPZAUjqoWtH1xnwwD6FPjHbi+7pxXlnNYCGOLb05o9g5\nbDm2fgB5UQKBgQDkzPZMCU4QiMye6Zqq6qwieeVcp0t26KMx2Veft1l4POeCITNC\n6C5F8n0Yd5lXnmXQEMNkLvm7G1aJoDbeo0XanjBoxv4Ej0r5RaAsPDWUsLGOSzZY\nK+KFhvM/sYovlZibBljkMYsPw68IOvqbcImcDg+80/5LdZEHdh9b+69eeQKBgHxP\np+7StW653ZW5oIjyKp2LiM0/h1tOXGF19ww0FG7UUy/c9B0NbGvk/K8YcSlNMHf8\nzDDV2vMo4joASrrODRY4/kmrs51lpQUpLXADvsAvEf/cKSH8sVe+8KMBL/4MvGlu\nAXv7liOuN8A7eenFpdL/hpqYFD5nOaFgcmDjUJ3hAoGBAOyTqoD5yB9h6hUZt1nZ\nLHbeJJtXlzvx46CGqSdauYhF741rErmYq4ogXOBI16wyRRM2WNxdIV1kFXlavSXk\n1LNDeaIEidgAIuFRV01dv4DjVXJ0ic+vtm5kT52315fCuMOqVwCuD1b1m/XWsPQZ\nKPVzb4GH0smZ8blBd7IJ9jKF\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-csbnn@zoozoovin-86d2e.iam.gserviceaccount.com",
      "client_id": "105698991271697926998",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-csbnn%40zoozoovin-86d2e.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // Obtain the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    // Close the HTTP client
    client.close();

    // Return the access token
    return credentials.accessToken.data;
  }

  static Future<void> sendFCMMessage(String title,  String body) async {
    final String serverKey = await getAccessToken(); // Your FCM server key
    final String fcmEndpoint =
        'https://fcm.googleapis.com/v1/projects/zoozoovin-86d2e/messages:send';
    final currentFCMToken = await SharedPreferencesManager.getString("fcm_token");
    print("fcmkey : $currentFCMToken");
    final Map<String, dynamic> message = {
      'message': {
        'token':
            currentFCMToken, // Token of the device you want to send the message to
        'notification': {
          'body': body,
          'title': title
        }, 
        'data': {
          'current_user_fcm_token':
              currentFCMToken, // Include the current user's FCM token in data payload
        },
      }
    };

    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('FCM message sent successfully');
    } else {
      print('Failed to send FCM message: ${response.statusCode}');
    }
  }
}
