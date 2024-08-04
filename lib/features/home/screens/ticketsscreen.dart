import 'dart:async';

import 'package:badges/badges.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/core/constants/app_data.dart';
import 'package:zoozoowin_/core/loaded_widget.dart';
import 'package:zoozoowin_/core/utils/screen_utils.dart';
import 'package:zoozoowin_/features/home/data/ticket_provider.dart';
import 'package:zoozoowin_/features/home/screens/result_screen.dart';
import 'package:badges/badges.dart' as badges;

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                AppImages.background,
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Column(
              children: [
                CustomSpacers.height32,
                _buildTop(),
                CustomSpacers.height20,
                _buildBody(),
              ],
            ),
          )),
    );
  }

  Widget _buildTop() => InkWell(
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
              "TICKETS",
              style: TextStyle(
                  fontSize: 17.h,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            )
          ],
        ),
      );

  Widget _buildBody() => SingleChildScrollView(
          child: Consumer<TicketProvider>(
        builder: (context, value, child) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ticketsWidget(
              title: "12:00 PM",
              cardCount: value.cardCounts["12:00 PM"] ?? 0,
              cardList: value.cardLists["12:00 PM"] ?? [],
            ),
            CustomSpacers.height6,
            Divider(
              thickness: 0.5,
              color: Colors.white.withOpacity(0.3),
            ),
            CustomSpacers.height6,
            ticketsWidget(
              title: "01:00 PM",
              cardCount: value.cardCounts["01:00 PM"] ?? 0,
              cardList: value.cardLists["01:00 PM"] ?? [],
            ),
            CustomSpacers.height6,
            Divider(
              thickness: 0.5,
              color: Colors.white.withOpacity(0.3),
            ),
            CustomSpacers.height6,
            ticketsWidget(
              title: "02:00 PM",
              cardCount: value.cardCounts["02:00 PM"] ?? 0,
              cardList: value.cardLists["02:00 PM"] ?? [],
            ),
            CustomSpacers.height6,
            Divider(
              thickness: 0.5,
              color: Colors.white.withOpacity(0.3),
            ),
            CustomSpacers.height6,
            ticketsWidget(
              title: "03:00 PM",
              cardCount: value.cardCounts["03:00 PM"] ?? 0,
              cardList: value.cardLists["03:00 PM"] ?? [],
            ),
            CustomSpacers.height6,
            Divider(
              thickness: 0.5,
              color: Colors.white.withOpacity(0.3),
            ),
            CustomSpacers.height6,
            ticketsWidget(
              title: "04:00 PM",
              cardCount: value.cardCounts["04:00 PM"] ?? 0,
              cardList: value.cardLists["04:00 PM"] ?? [],
            ),
            CustomSpacers.height6,
            Divider(
              thickness: 0.5,
              color: Colors.white.withOpacity(0.3),
            ),
            CustomSpacers.height6,
            ticketsWidget(
              title: "05:00 PM",
              cardCount: value.cardCounts["05:00 PM"] ?? 0,
              cardList: value.cardLists["05:00 PM"] ?? [],
            ),
            CustomSpacers.height6,
            Divider(
              thickness: 0.5,
              color: Colors.white.withOpacity(0.3),
            ),
            CustomSpacers.height6,
            ticketsWidget(
              title: "06:00 PM",
              cardCount: value.cardCounts["06:00 PM"] ?? 0,
              cardList: value.cardLists["06:00 PM"] ?? [],
            ),
            CustomSpacers.height6,
            Divider(
              thickness: 0.5,
              color: Colors.white.withOpacity(0.3),
            ),
            CustomSpacers.height6,
            ticketsWidget(
              title: "07:00 PM",
              cardCount: value.cardCounts["07:00 PM"] ?? 0,
              cardList: value.cardLists["07:00 PM"] ?? [],
            ),
            CustomSpacers.height6,
            Divider(
              thickness: 0.5,
              color: Colors.white.withOpacity(0.3),
            ),
            CustomSpacers.height6,
            ticketsWidget(
              title: "08:00 PM",
              cardCount: value.cardCounts["08:00 PM"] ?? 0,
              cardList: value.cardLists["08:00 PM"] ?? [],
            ),
            CustomSpacers.height6,
            Divider(
              thickness: 0.5,
              color: Colors.white.withOpacity(0.3),
            ),
            CustomSpacers.height6,
            ticketsWidget(
              title: "09:00 PM",
              cardCount: value.cardCounts["09:00 PM"] ?? 0,
              cardList: value.cardLists["09:00 PM"] ?? [],
            ),
            CustomSpacers.height6,
            Divider(
              thickness: 0.5,
              color: Colors.white.withOpacity(0.3),
            ),
            CustomSpacers.height6,
            ticketsWidget(
              title: "10:00 PM",
              cardCount: value.cardCounts["10:00 PM"] ?? 0,
              cardList: value.cardLists["10:00 PM"] ?? [],
            ),
            CustomSpacers.height6,
            Divider(
              thickness: 0.5,
              color: Colors.white.withOpacity(0.3),
            ),
            CustomSpacers.height6,
            ticketsWidget(
              title: "11:00 PM",
              cardCount: value.cardCounts["11:00 PM"] ?? 0,
              cardList: value.cardLists["11:00 PM"] ?? [],
            ),
            CustomSpacers.height6,
            Divider(
              thickness: 0.5,
              color: Colors.white.withOpacity(0.3),
            ),
            CustomSpacers.height6,
          ],
        ),
      ));
}

class ticketsWidget extends StatefulWidget {
  final String title;
  final int cardCount;
  final List<Map<String, dynamic>> cardList; // New parameter

  const ticketsWidget(
      {Key? key,
      required this.title,
      required this.cardCount,
      required this.cardList})
      : super(key: key);

  @override
  _ticketsWidgetState createState() => _ticketsWidgetState();
}

class _ticketsWidgetState extends State<ticketsWidget> {
  String formattedDate = '';
  late DateTime targetTime;
  late Duration countdownDuration;
  late Timer countdownTimer;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
    DateTime now = DateTime.now();
    formattedDate =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
  }

  @override
  void dispose() {
    countdownTimer.cancel();
    super.dispose();
  }

  void _initializeTimer() {
    List<String> timeParts = widget.title.split(' ');
    List<String> hourMinuteParts = timeParts[0].split(':');
    int hour = int.parse(hourMinuteParts[0]);
    int minute = int.parse(hourMinuteParts[1]);
    String period = timeParts[1];

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    DateTime now = DateTime.now();
    targetTime = DateTime(now.year, now.month, now.day, hour, minute)
        .add(Duration(hours: 1));
    countdownDuration = targetTime.difference(now);

    if (countdownDuration.isNegative) {
      countdownDuration = Duration.zero;
    }
    // else {
    //   countdownTimer = Timer.periodic(Duration(seconds: 0), (timer) {
    //     setState(() {
    //       countdownDuration = targetTime.difference(DateTime.now());
    //       if (countdownDuration.isNegative) {
    //         countdownDuration = Duration.zero;
    //         countdownTimer.cancel();
    //       }
    //     });
    //   });
    // }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _showUserCard(BuildContext context) async {
    final p = Provider.of<TicketProvider>(context, listen: false);
    if (widget.cardList.isNotEmpty) {
      double price = double.parse(p.cardTotalAmount[widget.title].toString());
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  height: 700.h,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        "assets/images/show_my_cards.png",
                      ),
                      fit: BoxFit.none,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomSpacers.height52,
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Icon(
                                Icons.cancel,
                                size: 35.w,
                                color: Colors.white,
                              ),
                            )),
                      ),
                      CustomSpacers.height14,
                      Center(
                        child: Container(
                          width: 120.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                              ),
                              child: Text(
                                "₹ ${price.toInt().toString()}",
                                style: TextStyle(
                                  fontSize: 20.w,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      CustomSpacers.height20,
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 50.w,
                          // vertical: 30.h,
                        ),
                        child: Container(
                          height: 340.h,
                          width: 300.w,
                          child: Scrollbar(
                            thumbVisibility: true,
                            // scrollbarOrientation:  ,
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10.w,
                                mainAxisSpacing: 10.h,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: widget.cardList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      widget.cardList[index]['image']
                                          .toString(),
                                      height: 50.h,
                                      width: 50.w,
                                    ),
                                    CustomSpacers.height10,
                                    Text(
                                      widget.cardList[index]['amount']
                                              .toString() +
                                          ' ₹',
                                      style: TextStyle(
                                        fontSize: 18.w,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      CustomSpacers.height40,
                      Column(
                        children: [
                          Text(
                            "Result",
                            style: TextStyle(
                              fontSize: 14.w,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 2,
                            ),
                          ),
                          // Text(
                          //   "declared within",
                          //   style: TextStyle(
                          //     fontSize: 14.w,
                          //     fontWeight: FontWeight.w900,
                          //     color: Colors.black,
                          //     fontStyle: FontStyle.italic,
                          //     letterSpacing: 2,
                          //   ),
                          // ),
                          CustomSpacers.height6,

                          // p.cardWon != ""
                          // ? Text(
                          //     "Result",
                          //     style: TextStyle(
                          //       fontSize: 14.w,
                          //       fontWeight: FontWeight.w900,
                          //       color: Colors.black,
                          //       fontStyle: FontStyle.italic,
                          //       letterSpacing: 2,
                          //     ),
                          //   )
                          // : Text(
                          //     "Result not declared\n for ${s} slot",
                          //     textAlign: TextAlign.center,
                          //     style: TextStyle(
                          //       fontSize: 14.w,
                          //       fontWeight: FontWeight.w900,
                          //       color: Colors.black,
                          //       fontStyle: FontStyle.italic,
                          //       letterSpacing: 2,
                          //     ),
                          // ),

                          CustomSpacers.height6,

                          p.cardWon != ""
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      p.cardWon,
                                      height: 40.h,
                                    ),
                                    CustomSpacers.width20,
                                    isthere
                                        ? Text("You Won !",
                                            style: TextStyle(
                                              fontSize: 22.w,
                                              fontWeight: FontWeight.w600,
                                            ))
                                        : Text("You Loss !",
                                            style: TextStyle(
                                              fontSize: 22.w,
                                              fontWeight: FontWeight.w600,
                                            ))
                                  ],
                                )
                              : Text('Result not declared yet !'),
                          // Container(
                          //   child: StreamBuilder<int>(
                          //     stream: Stream.periodic(
                          //             Duration(seconds: 1), (x) => x)
                          //         .takeWhile(
                          //             (x) => x <= countdownDuration.inSeconds)
                          //         .asBroadcastStream(),
                          //     builder: (context, snapshot) {
                          //       if (snapshot.hasData) {
                          //         final remainingSeconds =
                          //             countdownDuration.inSeconds -
                          //                 snapshot.data!;

                          //         if (_formatDuration(Duration(
                          //                 seconds: remainingSeconds)) ==
                          //             "00:00:00") {
                          //           return Row(
                          //             mainAxisAlignment: MainAxisAlignment.center,
                          //             children: [
                          //               Image.asset(
                          //                 p.cardWon,
                          //                 height: 40.h,
                          //               ),
                          //               CustomSpacers.width20,
                          //               isthere
                          //                   ? Text("You Won !",
                          //                       style: TextStyle(
                          //                         fontSize: 22.w,
                          //                         fontWeight: FontWeight.w600,
                          //                       ))
                          //                   : Text("You Loss !",
                          //                       style: TextStyle(
                          //                         fontSize: 22.w,
                          //                         fontWeight: FontWeight.w600,
                          //                       ))
                          //             ],
                          //           );
                          //         }
                          //         return Container(
                          //           height: 40.h,
                          //           width: 130.w,
                          //           decoration: BoxDecoration(
                          //             color: Colors.black,
                          //             border: Border.all(
                          //                 color: Colors.white, width: 2),
                          //             borderRadius: BorderRadius.circular(20),
                          //           ),
                          //           child: Center(
                          //             child: Text(
                          //               _formatDuration(Duration(
                          //                   seconds: remainingSeconds)),
                          //               style: TextStyle(
                          //                 fontSize: 16.w,
                          //                 fontWeight: FontWeight.w700,
                          //                 color: Colors.white,
                          //               ),
                          //             ),
                          //           ),
                          //         );
                          //       } else {
                          //         return Text("");
                          //       }
                          //     },
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    } else {
      // Fluttertoast.showToast(msg: "No cards Selected");
      // OverlayManager.showToast(type: ToastType.Error, msg: "No cards selected !");

      Fluttertoast.showToast(
        msg: "No cards selected !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<TicketProvider>(context, listen: false);
    return GestureDetector(
      onTap: () async {
        await p.showResult(formattedDate, widget.title);
        for (var i in widget.cardList) {
          if (i['image'] == p.cardWon) {
            setState(() {
              isthere = true;
            });
          }
        }

        _showUserCard(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              child: Row(
                children: [
                  SizedBox(
                    width: 70.w,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: Image.asset(
                            "assets/images/tickets.png",
                            height: 30.h,
                            width: 30.w,
                          ),
                        ),
                        Positioned(
                          left: 30.w,
                          bottom: 12.h,
                          child: widget.cardCount != 0
                              ? SizedBox(
                                  height: 28.h,
                                  width: 28.w,
                                  child: badges.Badge(
                                    badgeContent: Center(
                                      child: Text(
                                        widget.cardCount.toString(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.w),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                        ),
                      ],
                    ),
                  ),
                  CustomSpacers.height12,
                  Text(
                    widget.title + " SLOT",
                    style: TextStyle(
                      fontSize: 20.w,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  bool isthere = false;

  // void showResult() async {
  //   final p = Provider.of<TicketProvider>(context, listen: false);
  //   await p.showResult(formattedDate, widget.title);

  // for (var i in widget.cardList) {
  //   if (i['image'] == p.cardWon) {
  //     setState(() {
  //       isthere = true;
  //     });
  //   }
  // }

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             CustomSpacers.height20,
  //             Image.asset(
  //               p.cardWon,
  //               height: 140.h,
  //             ),
  //             CustomSpacers.height30,
  // isthere
  //     ? Text("YOU WON !",
  //         style: TextStyle(
  //           fontSize: 24.w,
  //           fontWeight: FontWeight.w600,
  //         ))
  //     : Text("YOU LOSS !",
  //         style: TextStyle(
  //           fontSize: 24.w,
  //           fontWeight: FontWeight.w600,
  //         ))
  //           ],
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('Close'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
