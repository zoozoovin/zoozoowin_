import 'package:flutter/material.dart';
import 'package:zoozoowin_/core/utils/custom_spacers.dart';
import 'package:badges/badges.dart' as badges;
import 'package:zoozoowin_/core/utils/screen_utils.dart';

class CustomShinyButton1 extends StatefulWidget {
  final String text;
  final double width;
  final double height;
  final int count;

  const CustomShinyButton1(
      {Key? key,
      required this.text,
      required this.width,
      required this.height,
      required this.count})
      : super(key: key);

  @override
  _CustomShinyButton1State createState() => _CustomShinyButton1State();
}

class _CustomShinyButton1State extends State<CustomShinyButton1>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: false);

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff00ff0a), Color.fromARGB(255, 58, 199, 2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomSpacers.width4,
                CircleAvatar(
                    radius: 25.r,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      'assets/images/tickets.png',
                      height: 30.h,
                      width: 30.w,
                    )),
                CustomSpacers.width16,
                Center(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                        fontSize: 26.w,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontStyle: FontStyle.italic),
                  ),
                ),
                CustomSpacers.width20,
                widget.count != 0
                    ? badges.Badge(
                        badgeStyle: badges.BadgeStyle(
                            borderSide:
                                BorderSide(color: Colors.white, width: 2)),
                        badgeContent: Container(
                          height: 23.h,
                          width: 23.w,
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Center(
                              child: Text(
                                widget.count.toString(),
                                // '12',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14.w),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return FractionalTranslation(
                  translation: Offset(_animation.value, 0),
                  child: child,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(0.6),
                        Colors.white.withOpacity(0),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
