import 'package:flutter/material.dart';
import 'package:zoozoowin_/core/app_imports.dart';

class CustomButtonGame2 extends StatefulWidget {
  final String text;
  final double width;
  final double height;
  final TextStyle style;
  final String image;
  final Color color;

  const CustomButtonGame2(
      {Key? key,
      required this.text,
      required this.width,
      required this.height,
      required this.style,
       this.image = '' , required this.color})
      : super(key: key);

  @override
  _CustomButtonGame2State createState() => _CustomButtonGame2State();
}

class _CustomButtonGame2State extends State<CustomButtonGame2>
    with SingleTickerProviderStateMixin {
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
              border: Border.all(width: 5, color: Colors.white),
              // color: const Color.fromARGB(255, 21, 255, 0),
              color:widget.color,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.image != '' ?   Image.asset(widget.image) : Container(),
                  CustomSpacers.width10,
                  Text(widget.text, style: widget.style),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
