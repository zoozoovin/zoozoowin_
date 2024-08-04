import 'package:flutter/material.dart';

class LoaderWidget extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final double opacity;

  LoaderWidget({required this.isLoading, required this.child , this.opacity = 0.5});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(opacity),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white,),
            ),
          ),
      ],
    );
  }
}
