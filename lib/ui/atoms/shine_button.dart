import 'package:zoozoowin_/core/app_imports.dart';

class CustomShinyButton extends StatefulWidget {
  final String text;
  final double width;
  final double height;
  final TextStyle style;
  final bool ic;
  


 CustomShinyButton({
    Key? key,
    required this.text,
    required this.width,
    required this.height,
    required this.style,
    this.ic=false
  }) : super(key: key);

  @override
  _CustomShinyButtonState createState() => _CustomShinyButtonState();
}

class _CustomShinyButtonState extends State<CustomShinyButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
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
                colors: [Color.fromARGB(255, 2, 167, 7), Color.fromARGB(255, 32, 195, 7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                widget.text,
                style: widget.style
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
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(0, 2, 167, 8),
                        // Colors.white.withOpacity(0),
                        Colors.white.withOpacity(0.5),
                       !widget.ic? Colors.white.withOpacity(0):Colors.white.withOpacity(0.3),
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
