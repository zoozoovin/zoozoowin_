// ignore_for_file: unnecessary_import

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/core/constants/app_data.dart';
import 'package:zoozoowin_/core/loaded_widget.dart';
import 'package:zoozoowin_/core/loader_widget.dart';
import 'package:zoozoowin_/core/utils/screen_utils.dart';
import 'package:zoozoowin_/features/home/data/result_provider.dart';
import 'package:zoozoowin_/features/home/data/ticket_provider.dart';
import 'package:zoozoowin_/features/home/screens/ticketsscreen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Timer _timer;
  Duration _countdownDuration = Duration.zero;
  String _timeSlot = '';
  String formattedDate = '';
  bool _hasBet = false;
  bool _isCountdownFinished = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    setState(() {
      _isLoading = true;
    });
    await _determineTimeSlot();
    await _checkForBet();
    setState(() {
      _isLoading = false;
    });
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<ResultProvider>(context, listen: false)
          .showHistory(formattedDate);
    });

    // await showHistory(formattedDate);
  }

  Future<void> _determineTimeSlot() async {
    DateTime now = DateTime.now();
    formattedDate =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    int hour = now.hour;
    int minute = now.minute;
    _formattedDatePick = formattedDate;

    // Adjust the hour based on the rule: if the current time is before the 5th minute of the hour, use the previous hour
    if (minute < 5) {
      hour -= 1;
      if (hour < 0) {
        hour = 23; // Edge case for midnight
      }
    }

    // Format hour to be in 12-hour format with AM/PM
    String period = hour >= 12 ? 'PM' : 'AM';
    int displayHour = hour % 12;
    if (displayHour == 0) {
      displayHour = 12; // 12 AM/PM instead of 0 AM/PM
    }

    // Pad the displayHour with a leading zero if necessary
    String displayHourStr = displayHour < 10 ? '0$displayHour' : '$displayHour';

    // Build the time slot string manually
    _timeSlot = '$displayHourStr:00 $period';

    // Calculate the next result announcement time
    DateTime nextResultTime = DateTime(now.year, now.month, now.day, hour + 1);
    _countdownDuration = nextResultTime.difference(now);

    setState(() {});
  }

  bool _isLoading = false;
  Future<void> _checkForBet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DatabaseReference ref = FirebaseDatabase.instance
        .ref('Game1/${formattedDate}_${_timeSlot}/${prefs.getString('phone')}');
    print('Game1/${formattedDate}_${_timeSlot}/${prefs.getString('phone')}');

    DataSnapshot snapshot = await ref.get();

    if (snapshot.value != null) {
      print(snapshot.value);
      Map<Object?, Object?> data = snapshot.value as Map<Object?, Object?>;
      print(data['mobile']);
      _hasBet = snapshot.exists;
    } else {
      _hasBet = false;
    }

    setState(() {
      // Any state updates related to the bet check can be done here
    });
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdownDuration -= const Duration(seconds: 1);
        if (_countdownDuration.isNegative) {
          _timer.cancel();
          _isCountdownFinished = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String cardWon = '';
  String cardWonImage = '';
  bool _showCard = false;

  Future<void> showResult() async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref('result_game1/${formattedDate}_${_timeSlot}');

    DataSnapshot snapshot = await ref.get();

    if (snapshot.value != null) {
      Map<Object?, Object?> data = snapshot.value as Map<Object?, Object?>;

      print(data['cardWon']);

      setState(() {
        cardWon = data['cardWon'].toString();
        cardWonImage = AppData.cardImages[cardWon]!;
        _showCard = true;
      });

      print(cardWon);
      print(cardWonImage);
    } else {
      // Handle the case where the result does not exist
      setState(() {
        _showCard = false;
      });
      print("No result data found.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ResultProvider>(
      builder: (context, value, child) => LoaderWidget(
        isLoading: value.isLoading,
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              _buildbackground(),
              Positioned(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  _buildbackground() => Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              AppImages.background,
            ),
            fit: BoxFit.cover,
          ),
        ),
      );

  _buildBody() => Positioned(
        child: Column(
          children: [
            CustomSpacers.height36,
            _buildLiveResult(),
            _buildHistoryResult(),
          ],
        ),
      );

  _buildLiveResult() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour >= 12 && hour < 24) {
      // Update _timeSlot based on current hour
      String period = hour >= 12 ? 'PM' : 'AM';
      int displayHour = hour % 12;
      if (displayHour == 0) {
        displayHour = 12; // 12 AM/PM instead of 0 AM/PM
      }
      String displayHourStr =
          displayHour < 10 ? '0$displayHour' : '$displayHour';
      _timeSlot = '$displayHourStr:00 $period';

      return Column(
        children: [
          CustomSpacers.height10,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Center(
                child: Image.asset(
                  "assets/images/result/live.png",
                  height: 30.h,
                ),
              ),
              Container(
                height: 50.h,
                width: 200.w,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/result/slotButton.png'),
                  ),
                ),
                child: Center(
                  child: Text(
                    _timeSlot + ' SLOT',
                    style: TextStyle(
                      fontSize: 20.w,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
          CustomSpacers.height20,
          // Rest of your UI components
          !_showCard
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: _hasBet
                              ? Text(
                                  "Result will be \ndeclared within",
                                  style: TextStyle(
                                      fontSize: 28.w,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 2),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  "You have not placed Bet\n for the Particular Slot ",
                                  style: TextStyle(
                                      fontSize: 28.w,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 2),
                                  textAlign: TextAlign.center,
                                )),
                      GestureDetector(
                          onTap: () {
                            // if (_isCountdownFinished) {
                            //   showResult();
                            // }
                          },
                          child: Container(
                            height: 80.h,
                            width: 250.w,
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/result/timer.png'))),
                            child: Center(
                                child: _isCountdownFinished
                                    ? Container(
                                        height: 150.h,
                                        child: Image.asset(
                                          cardWonImage,
                                          height: 50.h,
                                        ),
                                      ) // ? Text(
                                    //     'Check Result',
                                    //     style: TextStyle(
                                    //         fontSize: 25.w,
                                    //         color: Colors.white,
                                    //         fontWeight: FontWeight.w600),
                                    //   )
                                    : Text(
                                        '0${_countdownDuration.inHours}:${_countdownDuration.inMinutes}:${_countdownDuration.inSeconds % 60}',
                                        style: TextStyle(
                                            fontSize: 25.w,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      )),
                          ))
                    ],
                  ),
                )
              : Container(
                  height: 150.h,
                  child: Image.asset(
                    cardWonImage,
                    height: 50.h,
                  ),
                ),
          CustomSpacers.height24,
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: Text(
            "Live betting starts at 12 PM",
            style: TextStyle(
              fontSize: 24.w,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  DateTime? _selectedDate;
  String _formattedDatePick = '';

  // Function to display the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        // _formattedDatePick = _formatDate(pickedDate);
        formattedDate = _formatDate(pickedDate);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<ResultProvider>(context, listen: false)
          .showHistory(formattedDate);
    });

    // ignore: await_only_futures
    // await showHistory(_formattedDatePick);
  }

  // Function to format the date manually
  String _formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return "$day-$month-$year";
  }

  _buildHistoryResult() => Consumer<ResultProvider>(
        builder: (context, value, child) => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 70.h,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 50.h,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedDate,
                            style: TextStyle(
                                fontSize: 18.w, fontWeight: FontWeight.w700),
                          ),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey,
                            child: Center(
                                child: Icon(
                              Icons.date_range,
                              color: Colors.white,
                              size: 20.w,
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // CustomSpacers.height10,
            // !value.isLoading
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                height: 380.h,
                child: GridView.builder(
                  shrinkWrap: false,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Number of columns
                    crossAxisSpacing: 20.w, // Space between columns
                    mainAxisSpacing: 20.h, // Space between rows
                    childAspectRatio: 0.95, // Aspect ratio of the items
                  ),
                  itemCount: value.resultHistoryList.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final p = Provider.of<TicketProvider>(context,
                                listen: false);

                            print(
                                '${formattedDate}_${AppData.timeSlots[index]}');
                            await value.getSelCards(
                                formattedDate, AppData.timeSlots[index]);
                            // await p.showResult(
                            //     formattedDate, AppData.timeSlots[index]);

                            _showUserCard(
                                context, AppData.timeSlots[index], index);
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.07,
                            width: MediaQuery.of(context).size.width * 0.15,
                            decoration: BoxDecoration(
                                image: value.resultHistoryList[index]
                                            ['cardWon'] !=
                                        'coming'
                                    ? DecorationImage(
                                        image: AssetImage(
                                            value.resultHistoryList[index]
                                                ['cardWon']!),
                                        scale: 4.w)
                                    : null,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(60)),
                            child: value.resultHistoryList[index]['cardWon'] ==
                                    'coming'
                                ? Center(
                                    child: Text(
                                    'coming',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ))
                                : null,
                          ),
                        ),
                        Text(
                          // resultHistoryList[index]['time'],
                          AppData.timeSlots[index],
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            // : Center(
            //     child: CircularProgressIndicator(
            //       color: Colors.white,
            //     ),
            //   ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.asset(
                  'assets/images/result/clickonresults.png',
                  height: 45,
                ),
                GestureDetector(
                  onTap: () {
                    // setState(() {});
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ResultScreen()));
                  },
                  child: Image.asset(
                    'assets/images/result/Refresh.png',
                    height: 35,
                  ),
                )
              ],
            )
          ],
        ),
      );
  bool isthere = false;
  void _showUserCard(BuildContext context, String s, int index) async {
    final p = Provider.of<ResultProvider>(context, listen: false);
    final a = Provider.of<TicketProvider>(context, listen: false);
    // print(p.cardLists);

    if (p.cardLists[s] != null && p.cardLists[s]!.isNotEmpty) {
      // for (var i in a.cardLists[AppData.timeSlots[index]]!) {
      //   print(AppData.timeSlots[index]);
      //   print(i['image']);

      //   if (i['image'] == a.cardWon) {
      //     setState(() {
      //       isthere = true;
      //     });
      //   }
      // }
      double price = double.parse(p.cardTotalAmount[s].toString());
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
                      image: AssetImage("assets/images/show_my_cards.png"),
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
                          width: 130.w,
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
                                  fontSize: 22.w,
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
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10.w,
                                mainAxisSpacing: 10.h,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: p.cardLists[s]!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      p.cardLists[s]![index]['image']
                                          .toString(),
                                      height: 50.h,
                                      width: 50.w,
                                    ),
                                    CustomSpacers.height10,
                                    Text(
                                      p.cardLists[s]![index]['amount']
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
                      // Column(
                      //   children: [
                      a.cardWon != ""
                          ? Text(
                              "Result already declared",
                              style: TextStyle(
                                fontSize: 14.w,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 2,
                              ),
                            )
                          : Text(
                              "Result not declared\n for ${s} slot",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.w,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 2,
                              ),
                            ),

                      CustomSpacers.height6,

                      // a.cardWon != ""
                      //     ? Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           Image.asset(
                      //             a.cardWon,
                      //             height: 40.h,
                      //           ),
                      //           CustomSpacers.width20,
                      // isthere
                      //     ? Text("You Won !",
                      //         style: TextStyle(
                      //           fontSize: 22.w,
                      //           fontWeight: FontWeight.w600,
                      //         ))
                      //     : Text("You Loss !",
                      //         style: TextStyle(
                      //           fontSize: 22.w,
                      //           fontWeight: FontWeight.w600,
                      //         ))
                      //     ],
                      //   )
                      // : Container(),
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
                      //   ],
                      // ),
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

      // OverlayManager.showToast(
      //     type: ToastType.Error, msg: "No cards selected !");

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
}
