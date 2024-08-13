import 'package:flutter/material.dart';

class LoadingBar extends StatefulWidget {
  @override
  _LoadingBarState createState() => _LoadingBarState();
}

class _LoadingBarState extends State<LoadingBar>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: false);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller!);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            Container(
              width: 300,
              height: 21,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                color: Colors.transparent,
              ),
            ),
            AnimatedBuilder(
              animation: _animation!,
              builder: (context, child) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    width: 300 * _animation!.value,
                    height: 13,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 0, 255, 8),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          'Loading......',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: LoadingBar(),
      ),
    ),
  ));
}
