import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/core/utils/screen_utils.dart';
import 'package:zoozoowin_/features/home/data/home_provider.dart';
import 'package:zoozoowin_/features/home/screens/home_screen.dart';
import 'package:zoozoowin_/features/refer%20and%20earn/refer_earn.dart';
import 'package:zoozoowin_/features/tutorial/tutorial_screen.dart';
import 'package:zoozoowin_/features/wallet/wallet_screen.dart';

class NavBarScreen extends StatefulWidget {
  final int index;
  NavBarScreen({super.key, required this.index});

  @override
  _NavBarScreenState createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.index;
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    //   await Provider.of<HomeProvider>(context, listen: false)
    //       .initializeStream();

    //   // await Provider.of<HomeProvider>(context, listen: false)
    //   // .fetchData();
    // });
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const TutorialScreen(),
    const ReferEarnScreen(),
    const WalletScreen()
  ];

  void _onItemTapped(int index) {
    if (index == 1 || index == 2) {
      // Show popup instead of navigating
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Coming soon'),
            content: Text('This feature is coming soon!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // backgroundColor: const Color.fromARGB(255, 0, 73, 122),
        // backgroundColor: const Color.fromARGB(255, 0, 107, 173),

        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(AppImages.background), fit: BoxFit.cover),
              ),
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 400),
              child: _pages[_selectedIndex],
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: animation, curve: Curves.easeInOut)),
                  child: child,
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: Container(
          height: 70.h,
          width: MediaQuery.of(context).size.width,
          // color: const Color.fromARGB(255, 0, 107, 173),
          // color: ,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(AppImages.nav_bg), fit: BoxFit.cover),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  _onItemTapped(0);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home,
                      size: 34.h,
                      color: _selectedIndex == 0
                          ? const Color.fromARGB(255, 255, 157, 0)
                          : Colors.white,
                    ),
                    Text(
                      "Home",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16.w,
                          color: Colors.white),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  _onItemTapped(1);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppIcons.tutorial,
                      height: 30.h,
                      color: _selectedIndex == 1
                          ? const Color.fromARGB(255, 255, 157, 0)
                          : Colors.white,
                    ),
                    Text(
                      "Tutorial",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16.w,
                          color: Colors.white),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  _onItemTapped(2);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppIcons.refer_earn,
                      height: 27.h,
                      color: _selectedIndex == 2
                          ? const Color.fromARGB(255, 255, 157, 0)
                          : Colors.white,
                    ),
                    Text(
                      "Refer & Earn",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16.w,
                          color: Colors.white),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  _onItemTapped(3);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppIcons.wallet,
                      height: 27.h,
                      color: _selectedIndex == 3
                          ? const Color.fromARGB(255, 255, 157, 0)
                          : Colors.white,
                    ),
                    Text(
                      "Wallet",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16.w,
                          color: Colors.white),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
