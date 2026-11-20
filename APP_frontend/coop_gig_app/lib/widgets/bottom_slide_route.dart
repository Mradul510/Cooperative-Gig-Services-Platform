import 'package:flutter/material.dart';

class BottomSlideRoute<T> extends MaterialPageRoute<T> {
  final Widget page;

  BottomSlideRoute({
    required this.page,
    super.settings,
  }) : super(
          builder: (context) => page,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 0.12);
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;

    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

