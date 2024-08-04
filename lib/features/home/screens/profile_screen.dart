// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/core/managers/shared_preference_manager.dart';
import 'package:zoozoowin_/core/utils/screen_utils.dart';
import 'package:zoozoowin_/features/home/data/profile_provider.dart';
import 'package:zoozoowin_/features/nav_screen.dart';
import 'package:zoozoowin_/features/onboarding/screens/auth_screen.dart';
import 'package:zoozoowin_/features/onboarding/screens/phone_auth.dart';
import 'package:zoozoowin_/features/wallet/data/wallet_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WalletProvider>(
        builder: (context, value, child) => Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(AppImages.background), fit: BoxFit.cover)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSpacers.height48,
                  _buildTop(),
                  CustomSpacers.height30,

                  _buildUser(),
                  CustomSpacers.height16,
                  //========choose lang ======================
                  Divider(
                    color: Colors.grey.shade600,
                  ),

                  CustomSpacers.height26,

                  _buildLangSelecttion(),
                  CustomSpacers.height30,
                  //========Wallet Balance ======================
                  Divider(
                    color: Colors.grey.shade600,
                  ),
                  CustomSpacers.height30,

                  ColWid(
                      icon: Icons.wallet,
                      ontap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NavBarScreen(index: 3)));
                      },
                      subtitle: "₹ " + value.walletBalance.toString(),
                      title: "Wallet Balance"),
                  CustomSpacers.height6,
                  Divider(
                    color: Colors.grey.shade600,
                  ),
                  CustomSpacers.height6,
                  ColWid(
                      icon: Icons.security,
                      ontap: () {},
                      subtitle: "Add Bank Account",
                      title: "Complete KYC"),
                  CustomSpacers.height6,
                  Divider(
                    color: Colors.grey.shade600,
                  ),
                  CustomSpacers.height6,
                  ColWid(
                      icon: Icons.settings,
                      ontap: () {},
                      subtitle: "Change settings",
                      title: "Settings"),
                  CustomSpacers.height6,
                  Divider(
                    color: Colors.grey.shade600,
                  ),
                  CustomSpacers.height6,
                  ColWid(
                      icon: Icons.help,
                      ontap: () {},
                      subtitle: "Customer support and call",
                      title: "Help"),
                  CustomSpacers.height6,
                  Divider(
                    color: Colors.grey.shade600,
                  ),
                  CustomSpacers.height6,
                  ColWid(
                      icon: Icons.logout,
                      ontap: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Logout'),
                              content: Text('Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: Text('No'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    // Perform the logout
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setBool("isLogin", false);
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PhoneAuthScreen()),
                                      (Route<dynamic> route) => false,
                                    );
                                  },
                                  child: Text('Yes'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      subtitle: "Sign-out from this account",
                      title: "Log Out"),
                  CustomSpacers.height6,
                  Divider(
                    color: Colors.grey.shade600,
                  ),
                  CustomSpacers.height6,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildTop() => InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Row(
          children: [
            Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ),
            CustomSpacers.width12,
            Text(
              "ACCOUNT",
              style: TextStyle(
                  fontSize: 17.h,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            )
          ],
        ),
      );

  _buildUser() => Consumer<ProfileProvider>(
        builder: (context, value, child) => Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(AppImages.usericon),
            CustomSpacers.width16,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.profileName,
                  style: TextStyle(
                      fontSize: 15.w,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                Text(
                  value.pphone,
                  style: TextStyle(
                      fontSize: 14.w,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        TextEditingController _profileNameController =
                            TextEditingController();
                        return AlertDialog(
                          title: Text("Enter Profile Name"),
                          content: TextField(
                            controller: _profileNameController,
                            decoration:
                                InputDecoration(hintText: "Profile Name"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                await value
                                    .changeName(_profileNameController.text);
                                Navigator.pop(context);
                              },
                              child: Text("Save"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        "Profile",
                        style: TextStyle(
                            fontSize: 13.w,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                      ),
                      CustomSpacers.width6,
                      Icon(
                        Icons.arrow_forward_ios_outlined,
                        size: 14.w,
                        color: Colors.white,
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      );

  bool isEnglishSelected = true;
  _buildLangSelecttion() => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choose Language",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.w,
              fontWeight: FontWeight.w400,
            ),
          ),
          CustomSpacers.height12,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    isEnglishSelected = true;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isEnglishSelected
                        ? Colors.green
                        : const Color.fromARGB(169, 244, 67, 54),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    'English',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isEnglishSelected = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isEnglishSelected
                        ? const Color.fromARGB(169, 244, 67, 54)
                        : Colors.green,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    'Hindi',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
}

class ColWid extends StatefulWidget {
  String title;
  String subtitle;
  Function() ontap;
  IconData icon;
  ColWid(
      {super.key,
      required this.icon,
      required this.ontap,
      required this.subtitle,
      required this.title});

  @override
  State<ColWid> createState() => _ColWidState();
}

class _ColWidState extends State<ColWid> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: InkWell(
        onTap: widget.ontap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      widget.icon,
                      color: Colors.black,
                    ),
                  ),
                  CustomSpacers.width10,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                            fontSize: 18.w,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                            fontSize: 15.w,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
