// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:zoozoowin_/core/app_imports.dart';
// import 'package:zoozoowin_/core/managers/shared_preference_manager.dart';
// import 'package:zoozoowin_/core/utils/screen_utils.dart';
// import 'package:zoozoowin_/features/nav_screen.dart';
// import 'package:zoozoowin_/features/onboarding/data/profile_name_generator.dart';
// import 'package:zoozoowin_/route/app_pages.dart';
// import 'package:zoozoowin_/route/custom_navigator.dart';
// import 'package:zoozoowin_/ui/molecules/custom_text_field.dart';

// class PhoneAuthScreen extends StatefulWidget {
//   @override
//   _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
// }

// class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
//   final TextEditingController _phoneController = TextEditingController();
//   final List<TextEditingController> _otpController = List.generate(
//     6,
//     (index) => TextEditingController(),
//   );
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final DatabaseReference _database = FirebaseDatabase.instance.ref('username');

//   String _verificationId = '';
//   bool _isCodeSent = false;
//   bool _isLoading = false;

//   void _verifyPhoneNumber() async {
//     setState(() {
//       _isLoading = true;
//     });

//     await _auth.verifyPhoneNumber(
//       phoneNumber:
//           '${_countryCodeController.text}${_phoneController.text}', // Modify the country code as needed
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         // Auto-retrieval or instant verification
//         String? smsCode = credential.smsCode;
//         if (smsCode != null) {
//           for (int i = 0; i < smsCode.length; i++) {
//             _otpController[i].text = smsCode[i];
//           }
//         }
//         await _auth.signInWithCredential(credential);
//         _checkUserAndSaveData();
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         setState(() {
//           _isLoading = false;
//         });
//         Fluttertoast.showToast(
//           msg: 'Verification failed: ${e.message}',
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.BOTTOM,
//         );
//       },
//       codeSent: (String verificationId, int? resendToken) {
//         setState(() {
//           _verificationId = verificationId;
//           _isCodeSent = true;
//           _isLoading = false;
//         });
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {
//         setState(() {
//           _verificationId = verificationId;
//         });
//       },
//     );
//   }

//   void _signInWithOTP() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       String smsCode =
//           _otpController.map((controller) => controller.text).join();

//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: _verificationId,
//         smsCode: smsCode,
//       );
//       await _auth.signInWithCredential(credential);
//       _checkUserAndSaveData();
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       Fluttertoast.showToast(
//         msg: 'Failed to sign in: $e',
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.BOTTOM,
//       );
//     }
//   }

  // ProfileNameGenerator _generator = ProfileNameGenerator();
  // String _randomName = "";
  // void _checkUserAndSaveData() async {
  //   String phone = _phoneController.text;
  //   DatabaseReference ref = _database.child(phone);
  //   DataSnapshot snapshot = await ref.get();
  //   _randomName = _generator.generateRandomName();
  //   if (!snapshot.exists) {
  //     await ref.set({
  //       'phone': phone,
  //       'walletBalance': 0.0,
  //       'profileName': _randomName,
  //       'fcm_token': SharedPreferencesManager.getString("fcm_token")
  //     });
  //     _savePhoneNumberToLocalDatabase(phone);
  //     Navigator.pushReplacement(context,
  //         MaterialPageRoute(builder: (context) => NavBarScreen(index: 0)));
  //   } else {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     _savePhoneNumberToLocalDatabase(phone);

  //     Fluttertoast.showToast(
  //       msg: 'User already exists',
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.BOTTOM,
  //     );
  //     Navigator.pushReplacement(context,
  //         MaterialPageRoute(builder: (context) => NavBarScreen(index: 0)));
  //   }
  // }

  // Future<void> _savePhoneNumberToLocalDatabase(String phone) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('phone', phone);
  //   await prefs.setBool('isLogin', true);
  // }

//   final TextEditingController _countryCodeController =
//       TextEditingController(text: '+91');

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
          // height: MediaQuery.of(context).size.height,
          // width: MediaQuery.of(context).size.width,
          // decoration: BoxDecoration(
          //     image: DecorationImage(
          //         image: AssetImage(AppImages.phone_bg), fit: BoxFit.cover)),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 50.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 _buildVerification(),
//               ],
//             ),
//           )),
//     );
//   }

//   _buildVerification() => Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               height: 50.h,
//               width: MediaQuery.of(context).size.width,
//               decoration: BoxDecoration(
//                   border: Border.all(
//                       color: const Color.fromARGB(255, 53, 184, 255), width: 3),
//                   borderRadius: BorderRadius.circular(20),
//                   color: Colors.white),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   CustomSpacers.width10,
//                   SizedBox(
//                     child: Row(
//                       children: [
//                         Text(
//                           "+91",
//                           style: TextStyle(
//                               fontSize: 18.w, fontWeight: FontWeight.w500),
//                         ),
//                         CustomSpacers.width6,
//                         VerticalDivider(
//                           thickness: 2,
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     height: 50.h,
//                     width: 250.w,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       // color: Colors.black
//                     ),
//                     child: Padding(
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
//                       child: TextField(
//                         controller: _phoneController,
//                         decoration: const InputDecoration(
//                           hintText: 'Mobile Number',
//                           border: InputBorder.none,
//                         ),
//                         readOnly: _isCodeSent ? true : false,
//                         keyboardType: TextInputType.phone,
//                         // textAlign: TextAlign.cente,
//                         inputFormatters: [
//                           LengthLimitingTextInputFormatter(
//                               10), // Limit input to 10 characters
//                         ],
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//             CustomSpacers.height15,
//             _isCodeSent
//                 ? AutofillGroup(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: List.generate(
//                         6,
//                         (index) => SizedBox(
//                           width: 40,
//                           height: 40,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                   width: 3,
//                                   color:
//                                       const Color.fromARGB(255, 53, 184, 255)),
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             alignment: Alignment.center,
//                             child: TextField(
//                               controller: _otpController[index],
//                               decoration: const InputDecoration(
//                                 hintText: '_',
//                                 hintStyle: TextStyle(
//                                     fontSize:
//                                         20), // Adjust font size of hint text
//                                 counterText: '',
//                                 border: InputBorder.none,
//                               ),
//                               textAlign: TextAlign.center,
//                               keyboardType: TextInputType.number,
//                               maxLength: 1,
//                               autofillHints: [AutofillHints.oneTimeCode],
//                               style: const TextStyle(
//                                   fontSize:
//                                       24), // Adjust font size of entered digits
//                               onChanged: (value) {
//                                 if (value.length == 1 && index < 5) {
//                                   // Move focus to the next OTP input box
//                                   FocusScope.of(context).nextFocus();
//                                 }
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   )
//                 : Container(),
//             SizedBox(height: _isCodeSent ? 15 : 10),
//             _isLoading
//                 ? CircularProgressIndicator(
//                     color: Colors.white,
//                   )
//                 : GestureDetector(
//                     onTap: () {
//                       if (_isCodeSent) {
//                         // Disable keyboard
//                         FocusScope.of(context).unfocus();
//                         _signInWithOTP();
//                       } else {
//                         _verifyPhoneNumber();
//                       }
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                       child: Container(
//                         height: 50.h,
//                         width: MediaQuery.of(context).size.width,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(width: 3, color: Colors.white),
//                             color: const Color.fromARGB(255, 53, 184, 255)),
//                         child: Center(
//                           child: Text(
//                             _isCodeSent ? 'VERIFY' : 'SEND OTP',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.w800,
//                                 color: Colors.white,
//                                 fontSize: 20.w),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//           ],
//         ),
//       );
// }
