// ignore_for_file: use_build_context_synchronously, unused_import



import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:phone_email_auth/phone_email_auth.dart';

import 'package:provider/provider.dart';
import 'shared_preference_manager.dart';



class AppManager {

  
  static Future<void> initialize() async {

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SharedPreferencesManager.init();    
      await Firebase.initializeApp();
      PhoneEmail.initializeApp(clientId: '18810700881589792944');
  }
}
