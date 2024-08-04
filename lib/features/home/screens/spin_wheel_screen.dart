import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoozoowin_/core/app_imports.dart';
import 'package:zoozoowin_/core/loader_widget.dart';
import 'package:zoozoowin_/core/utils/screen_utils.dart';
import 'package:zoozoowin_/features/wallet/data/wallet_provider.dart';
import 'package:zoozoowin_/ui/atoms/shine_button.dart';

class SpinWheelPage extends StatefulWidget {
  @override
  _SpinWheelPageState createState() => _SpinWheelPageState();
}

class _SpinWheelPageState extends State<SpinWheelPage> {
  List<int?> blocks = List.filled(9, null);
  int wallet = 0;
  bool hasStarted = false;
  bool isAnimating = false;
  int currentIndex = 0;
  Timer? animationTimer;
  bool canSpinToday = true;
  Duration timeUntilNextSpin = Duration.zero;
  StreamController<Duration> timerStreamController =
      StreamController<Duration>();

  @override
  void initState() {
    super.initState();
    _assignRandomPoints();
    _checkCanSpinToday();
  }

  String _currentDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  void _assignRandomPoints() {
    Random random = Random();
    List<int> indices = List.generate(9, (index) => index)..shuffle();
    for (int i = 0; i < 6; i++) {
      blocks[indices[i]] = random.nextInt(31) + 10; // Points between 10 to 40
    }
  }

  void _startAnimation() {
    if (hasStarted || isAnimating || !canSpinToday) return;

    setState(() {
      isAnimating = true;
      hasStarted = true;
    });

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('lastSpinDate', _currentDateString());
    });

    const duration = Duration(milliseconds: 100);
    animationTimer = Timer.periodic(duration, (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % 9;
      });
    });

    Future.delayed(Duration(seconds: 3), _stopAnimation);
  }

  void _stopAnimation() {
    if (animationTimer != null) {
      animationTimer!.cancel();
    }

    setState(() {
      isAnimating = false;
    });

    int? result = blocks[currentIndex];
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<WalletProvider>(
          builder: (context, value, child) => AlertDialog(
            title: Text(result != null ? 'Congratulations!' : 'Oops!'),
            content: Text(result != null
                ? 'You won $result points!'
                : 'No result this time.'),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  if (result != null) {
                    await value.addPointsToSpinWheelPage(result);
                  }
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _checkCanSpinToday() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastSpinDate = prefs.getString('lastSpinDate');

    if (lastSpinDate == _currentDateString()) {
      setState(() {
        canSpinToday = false;
        DateTime now = DateTime.now();
        DateTime nextSpinTime = DateTime(now.year, now.month, now.day + 1);
        timeUntilNextSpin = nextSpinTime.difference(now);
      });

      Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          timeUntilNextSpin -= Duration(seconds: 1);
          if (timeUntilNextSpin.isNegative) {
            canSpinToday = true;
            timer.cancel();
            timerStreamController.add(Duration.zero);
          } else {
            timerStreamController.add(timeUntilNextSpin);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    timerStreamController.close();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, value, child) => LoaderWidget(
        isLoading: value.isLoading,
        child: Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(AppImages.background),
                    fit: BoxFit.cover)),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/spinwheel.png'),
                          fit: BoxFit.cover)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CustomSpacers.height40,
                      _buildTop(),
                      CustomSpacers.height60,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              height: 60.h,
                              width: 150.w,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage('assets/points.png'))),
                              child: Center(
                                child: Text(
                                  value.point.toString(),
                                  style: TextStyle(
                                      fontSize: 22.w,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white),
                                ),
                              )),
                          CustomSpacers.width20,
                          InkWell(
                              onTap: () async {
                                if (value.point >= 100) {
                                  int a = (value.point / 100).toInt();

                                  await value.redeemPoints(a * 100);
                                }
                              },
                              child: Image.asset('assets/redeem.png')),
                        ],
                      ),
                      CustomSpacers.height20,
                      GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          bool isSelected =
                              index == currentIndex && isAnimating;
                          return Container(
                            height: 80.h, // Set the desired height here
                            decoration: BoxDecoration(
                              color: blocks[index] != null
                                  ? Colors.green
                                  : Colors.red,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.black,
                                width: isSelected ? 4 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                blocks[index]?.toString() ?? 'OOPS!',
                                style: TextStyle(
                                  fontSize: 18.w,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      CustomSpacers.height36,
                      CustomSpacers.height60,
                      InkWell(
                        onTap: () {
                          if (canSpinToday) {
                            _startAnimation();
                          }
                        },
                        child: StreamBuilder<Duration>(
                          stream: timerStreamController.stream,
                          initialData: timeUntilNextSpin,
                          builder: (context, snapshot) {
                            Duration remaining = snapshot.data ?? Duration.zero;
                            return CustomShinyButton(
                              height: 60.h,
                              text: canSpinToday
                                  ? 'EARN BONUS'
                                  : '${_formatDuration(remaining)}',
                              width: 250.w,
                              // ic: false,
                          style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                ),
                CustomSpacers.width12,
                Text(
                  "BONUS",
                  style: TextStyle(
                      fontSize: 17.h,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      );
}
