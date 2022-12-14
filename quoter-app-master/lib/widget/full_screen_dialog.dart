import 'package:flutter/material.dart';

class FullScreenDialog extends StatelessWidget {
  const FullScreenDialog({
    Key? key,
    required this.child,
    required this.height,
    required this.width,
    required this.isHeighted,
  }) : super(key: key);
  final Widget child;
  final double height;
  final double width;
  final bool isHeighted;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0.0,
        child: SizedBox(
          height: isHeighted ? size.height * height : null,
          width: size.width * width,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
