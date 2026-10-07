import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/Background.png', fit: BoxFit.cover),
        Container(color: Colors.white.withValues(alpha: 0.18)),
        child,
      ],
    );
  }
}
