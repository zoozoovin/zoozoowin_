// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:provider/provider.dart';
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/core/constants/app_data.dart';
import 'package:zoozoowin_/core/utils/screen_utils.dart';
import 'package:zoozoowin_/features/game1/game1_timeslotscreen.dart';
import 'package:zoozoowin_/features/home/data/home_provider.dart';
import 'package:zoozoowin_/features/home/screens/notification_screen.dart';
import 'package:zoozoowin_/features/home/screens/profile_screen.dart';
import 'package:zoozoowin_/features/home/screens/spin_wheel_screen.dart';
import 'package:zoozoowin_/features/nav_screen.dart';
import 'package:zoozoowin_/features/wallet/data/wallet_provider.dart';
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late StreamController<String> _countdownController;
  late Stream<String> _countdownStream;
  String countdownText = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<HomeProvider>(context, listen: false)
          .initializeStream();

      await Provider.of<HomeProvider>(context, listen: false).fetchData();
    });
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true); // Repeat the animation back and forth
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
    _countdownController = StreamController<String>();
    _countdownStream = _countdownController.stream;
    _startCountdown();
  }

  @override
  void dispose() {
    _controller.dispose();
    _countdownController.close();
    super.dispose();
  }

  void _startCountdown() {
    Timer.periodic(Duration(seconds: 1), (timer) async {
      DateTime now = DateTime.now();
      int minute = now.minute;
      if (minute >= 55) {
        Duration remaining =
            Duration(minutes: 59 - minute, seconds: 59 - now.second);
        countdownText =
            "${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}";

        _countdownController.add(countdownText);

        if (remaining.inMinutes == 0 && remaining.inSeconds == 0) {
          await _updateData();
        }
      } else {
        countdownText = "";
        _countdownController.add(countdownText);
      }
    });
  }

  Future<void> _updateData() async {
    await Provider.of<HomeProvider>(context, listen: false).fetchData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(AppImages.background), fit: BoxFit.cover),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomSpacers.height24,
                  _buildTop(),
                  _buildResult(),
                  CustomSpacers.height8,
                  Divider(thickness: 3),
                  _buildCardGames(),
                  _buildBoardGames(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildTop() => Consumer<WalletProvider>(
        builder: (context, value, child) => Container(
          height: 100.h,
          width: 600.w,
          decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(AppImages.line1))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  _navigateToNotification(context, ProfileScreen());
                },
                child: Icon(
                  Icons.person,
                  size: 50.w,
                  color: Colors.white,
                ),
              ),
              CustomSpacers.width24,
              InkWell(
                onTap: () {
                  // _navigateToNotification(context, NavBarScreen(index: 3));

                  Navigator.of(context)
                      .pushReplacement(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return FadeTransition(
                          opacity: animation,
                          child: NavBarScreen(
                              index:
                                  3), // Replace with your notification screen
                        );
                      },
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;
                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ),
                  )
                      .then((v) async {
                    await Provider.of<HomeProvider>(context, listen: false)
                        .initializeStream();
                    await Provider.of<HomeProvider>(context, listen: false)
                        .fetchData();

                    setState(() {});
                  });
                },
                child: Container(
                  width: 140.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Image.asset(
                        AppIcons.wallet,
                        height: 35.h,
                        width: 35.w,
                      ),
                      Text("₹ " + value.walletBalance.toInt().toString(),
                          style: TextStyle(
                              fontSize: 20.w,
                              fontWeight: FontWeight.w500,
                              color: Colors.white))
                    ],
                  ),
                ),
              ),
              CustomSpacers.width4,
              Container(
                width: 70.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        _navigateToNotification(context, NotificationScreen());
                      },
                      child: Image.asset(
                        AppIcons.notification,
                        height: 30.h,
                        width: 30.w,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _navigateToNotification(context, SpinWheelPage());
                      },
                      child: Image.asset(
                        AppImages.spinwheelicon,
                        height: 35.h,
                        width: 35.w,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  _buildResult() => Consumer<HomeProvider>(
        builder: (context, value, child) {
          DateTime now = DateTime.now();
          if (now.hour < 12 || (now.hour == 23 && now.minute >= 59)) {
            return Container(
              height: 190.h,
              width: MediaQuery.of(context).size.width,
              // color: Colors.yellow,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: !value.isLoading
                    ? Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 130.h,
                                width: 500.w,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image:
                                            AssetImage('assets/result.gif'))),
                              ),
                              Positioned(
                                left: 170.w,
                                top: 35.h,
                                child: Container(
                                  height: 70.h,
                                  width: 70.w,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                    AppData.cardImages[value.data!['cardWon']]!,
                                  ))),
                                ),
                              )
                            ],
                          ),
                          CustomSpacers.height10,
                          Container(
                            height: 50.h,
                            child: Center(
                              child: Text(
                                "LAST DAY RESULT 11:00 PM SLOT",
                                style: TextStyle(
                                    fontSize: 24.w,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
              ),
            );
          } else {
            if (now.minute >= 55) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 130.h,
                          width: 500.w,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/result.gif'))),
                        ),
                        Positioned(
                          left: 170.w,
                          top: 35.h,
                          child: Container(
                            height: 70.h,
                            width: 70.w,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                              AppData.cardImages[value.data!['cardWon']]!,
                            ))),
                          ),
                        )
                      ],
                    ),
                    StreamBuilder<String>(
                      stream: _countdownStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Center(
                            child: Text(
                              'Result will be declared within ${snapshot.data}',
                              style: TextStyle(
                                fontSize: 22.w,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        } else {
                          return Center(
                            child: Text(
                              'Result will be declared within $countdownText',
                              style: TextStyle(
                                fontSize: 22.w,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                height: 190.h,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: !value.isLoading
                      ? Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 130.h,
                                  width: 500.w,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image:
                                              AssetImage('assets/result.gif'))),
                                ),
                                Positioned(
                                  left: 170.w,
                                  top: 35.h,
                                  child: Container(
                                    height: 70.h,
                                    width: 70.w,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                      AppData
                                          .cardImages[value.data!['cardWon']]!,
                                    ))),
                                  ),
                                )
                              ],
                            ),
                            CustomSpacers.height10,
                            Container(
                              height: 50.h,
                              child: Center(
                                child: Text(
                                  "PLAY WIN RESULT ${value.tc.toString()} SLOT",
                                  style: TextStyle(
                                      fontSize: 24.w,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              );
            }
          }
        },
      );

  // _buildResult() => Consumer<TicketProvider>(
  //       builder: (context, value, child) => Column(
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               InkWell(
  //                 onTap: () {
  //                   _navigateToNotification(context, TicketsScreen());
  //                 },
  //                 child: Padding(
  //                   padding: EdgeInsets.only(top: 5.h),
  //                   child: Stack(
  //                     children: [
  //                       Container(
  //                         height: 70.h,
  //                         width: 200.w,
  //                         decoration: BoxDecoration(
  //                             // color: Colors.amber,
  //                             image: DecorationImage(
  //                                 image: AssetImage(AppImages.ticketbg))),
  //                         child: Center(
  //                           child: Text(
  //                             "TICKETS",
  //                             style: TextStyle(
  //                                 fontSize: 20.w,
  //                                 fontWeight: FontWeight.w600,
  //                                 color: Colors.white),
  //                           ),
  //                         ),
  //                       ),
  // Positioned(
  //     left: 155.w,
  //     bottom: 35.h,
  //     child: badges.Badge(
  //       badgeContent: Padding(
  //         padding: const EdgeInsets.all(3.0),
  //         child: Text(
  //           value.totalCount.toString(),
  //           style: TextStyle(color: Colors.white),
  //         ),
  //       ),
  //     )),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               Padding(
  //                 padding: EdgeInsets.only(top: 7.h),
  //                 child: InkWell(
  //                   onTap: () {
  //                     _navigateToNotification(context, ResultScreen());
  //                   },
  //                   child: Stack(
  //                     children: [
  //                       Container(
  //                         height: 60.h,
  //                         width: 200.w,
  //                         decoration: BoxDecoration(
  //                             // color: Colors.amber,
  //                             image: DecorationImage(
  //                                 image: AssetImage(AppImages.ticketbg))),
  //                         child: Center(
  //                           child: Text(
  //                             "RESULT",
  //                             style: TextStyle(
  //                                 fontSize: 20.w,
  //                                 fontWeight: FontWeight.w600,
  //                                 color: Colors.white),
  //                           ),
  //                         ),
  //                       ),
  //                       Positioned(
  //                           // left: 160.w,
  //                           right: 10.w,
  //                           bottom: 40.h,
  //                           child: FadeTransition(
  //                               opacity: _animation,
  //                               child: Image.asset(
  //                                 AppImages.live,
  //                                 height: 18.h,
  //                               ))),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           Divider(
  //             thickness: 3,
  //           )
  //         ],
  //       ),
  //     );

  // _buildResult() => Consumer<HomeProvider>(
  //       builder: (context, value, child) {
  //         DateTime now = DateTime.now();
  //         if (now.hour < 12 || (now.hour == 23 && now.minute >= 59)) {
  //           return Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //             child: !value.isLoading
  //                 ? Column(
  //                     children: [
  //                       Stack(
  //                         children: [
  //                           Container(
  //                             height: 130.h,
  //                             width: 500.w,
  //                             decoration: BoxDecoration(
  //                                 image: DecorationImage(
  //                                     image: AssetImage('assets/result.gif'))),
  //                           ),
  //                           Positioned(
  //                             left: 170.w,
  //                             top: 35.h,
  //                             child: Container(
  //                               height: 70.h,
  //                               width: 70.w,
  //                               decoration: BoxDecoration(
  //                                   image: DecorationImage(
  //                                       image: AssetImage(
  //                                 AppData.cardImages[value.data!['cardWon']]!,
  //                               ))),
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                       CustomSpacers.height10,
  //                       Container(
  //                         height: 50.h,
  //                         child: Center(
  //                           child: Text(
  //                             "LAST DAY RESULT 11:00 PM SLOT",
  //                             style: TextStyle(
  //                                 fontSize: 24.w,
  //                                 color: Colors.white,
  //                                 fontWeight: FontWeight.w700),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   )
  //                 : Center(
  //                     child: LinearProgressIndicator(
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //           );
  //         } else {
  //           if (now.minute >= 55) {
  //             return Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Column(
  //                 children: [
  //                   Stack(
  //                     children: [
  //                       Container(
  //                         height: 130.h,
  //                         width: 500.w,
  //                         decoration: BoxDecoration(
  //                             image: DecorationImage(
  //                                 image: AssetImage('assets/result.gif'))),
  //                       ),
  //                       Positioned(
  //                         left: 170.w,
  //                         top: 35.h,
  //                         child: Container(
  //                           height: 70.h,
  //                           width: 70.w,
  //                           decoration: BoxDecoration(
  //                               image: DecorationImage(
  //                                   image: AssetImage(
  //                             AppData.cardImages[value.data!['cardWon']]!,
  //                           ))),
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //                     child: Center(
  //                       child: Text(
  //                         'Result will be declared within 0${countdownText}',
  //                         style: TextStyle(
  //                           fontSize: 22.w,
  //                           color: Colors.white,
  //                           fontWeight: FontWeight.w700,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           } else {
  //             return Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //               child: !value.isLoading
  //                   ? Column(
  //                       children: [
  //                         Stack(
  //                           children: [
  //                             Container(
  //                               height: 130.h,
  //                               width: 500.w,
  //                               decoration: BoxDecoration(
  //                                   image: DecorationImage(
  //                                       image:
  //                                           AssetImage('assets/result.gif'))),
  //                             ),
  //                             Positioned(
  //                               left: 170.w,
  //                               top: 35.h,
  //                               child: Container(
  //                                 height: 70.h,
  //                                 width: 70.w,
  //                                 decoration: BoxDecoration(
  //                                     image: DecorationImage(
  //                                         image: AssetImage(
  //                                   AppData.cardImages[value.data!['cardWon']]!,
  //                                 ))),
  //                               ),
  //                             )
  //                           ],
  //                         ),
  //                         CustomSpacers.height10,
  //                         Container(
  //                           height: 50.h,
  //                           child: Center(
  //                             child: Text(
  //                               "LAST SLOT WINNER",
  //                               style: TextStyle(
  //                                   fontSize: 24.w,
  //                                   color: Colors.white,
  //                                   fontWeight: FontWeight.w700),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     )
  //                   : Center(
  //                       child: LinearProgressIndicator(
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //             );
  //           }
  //         }
  //       },
  //     );

  // _buildVideoSection() => Column(
  //       children: [
  //         Container(
  //           height: 100.h,
  //           width: MediaQuery.of(context).size.width,
  //           color: Colors.black,
  //         ),
  // Divider(
  //   thickness: 3,
  // )
  //       ],
  //     );

  _buildCardGames() => Consumer<HomeProvider>(
        builder: (context, value, child) => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 12.w, top: 2.h),
                child: const Text(
                  'CARD GAMES',
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    _navigateToNotification(context, Game1TimeSlotScreen());
                  },
                  child: Container(
                    height: 160.h,
                    width: 200.w,
                    // color: Colors.amber,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          AppImages.game1,
                          height: 150.h,
                          // width: 140.w,
                        ),
                        Positioned(
                            left: 150.w,
                            bottom: 115.h,
                            child: badges.Badge(
                              badgeContent: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  value.totalCount.toString(),
                                  // "12",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20.w),
                                ),
                              ),
                            )

                            // child: Center(
                            //     child: Container(
                            //         height: 40.h,
                            //         width: 40.w,
                            //         // color: Colors.amber,
                            //         child: Center(
                            //             child: Text(
                            //           // "12",
                            //           value.totalCount.toString(),

                            //           style: TextStyle(
                            //               fontSize: 28.w,
                            //               color: Colors.yellow,
                            //               fontWeight: FontWeight.bold ,),
                            //         )))),
                            ),
                      ],
                    ),
                  ),
                ),
                Image.asset(
                  AppImages.game2,
                  height: 150.h,
                ),
                CustomSpacers.width14,
              ],
            ),
            CustomSpacers.height18,
            Divider(
              thickness: 3,
            )
          ],
        ),
      );

  void _navigateToNotification(BuildContext context, Widget? a) {
    Navigator.of(context)
        .push(
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
    )
        .then((v) async {
      await Provider.of<HomeProvider>(context, listen: false)
          .initializeStream();
      await Provider.of<HomeProvider>(context, listen: false).fetchData();

      setState(() {});
    });
  }

  _buildBoardGames() => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 12.w, top: 2.h),
              child: const Text(
                'BOARD GAMES',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.asset(
                  AppImages.ludo,
                  height: 140.h,
                ),
                Image.asset(
                  AppImages.ludo,
                  height: 130.h,
                  color: Colors.transparent,
                ),
                CustomSpacers.width14,
              ],
            ),
          ),
        ],
      );

  bool _showBanner = true;
  _buildBanner() => Container(
        width: MediaQuery.of(context).size.width,
        height: 120.h,
        decoration: const BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
              image: AssetImage(AppImages.banner), fit: BoxFit.cover),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              height: 10.h,
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _showBanner = false;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  AppIcons.cross,
                  height: 20.h,
                ),
              ),
            )
          ],
        ),
      );
}
