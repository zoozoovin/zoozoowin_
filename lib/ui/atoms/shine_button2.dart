import 'package:flutter/material.dart';
import 'package:zoozoowin_/core/app_imports.dart';

class CustomShinyButton2 extends StatefulWidget {
  final String text;
  final double width;
  final double height;
  final TextStyle style;
  final String image;

  const CustomShinyButton2(
      {Key? key,
      required this.text,
      required this.width,
      required this.height,
      required this.style,
      required this.image})
      : super(key: key);

  @override
  _CustomShinyButton2State createState() => _CustomShinyButton2State();
}

class _CustomShinyButton2State extends State<CustomShinyButton2>
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
      borderRadius: BorderRadius.circular(25),
      child: Stack(
        children: [
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              border: Border.all(width: 5 ,color: Colors.white),
              // color: const Color.fromARGB(255, 21, 255, 0),
              gradient: LinearGradient(
                colors: [Color(0xff00ff0a), Color.fromARGB(255, 58, 199, 2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(widget.image),
                  CustomSpacers.width10,
                  Text(widget.text, style: widget.style),
                ],
              ),
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
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(132, 7, 190, 10).withOpacity(0),
                        Colors.white.withOpacity(0.7),
                        const Color.fromARGB(132, 7, 190, 10).withOpacity(0),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
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
