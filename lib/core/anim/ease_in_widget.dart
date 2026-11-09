import 'package:flutter/material.dart';

class EaseInWidget extends StatefulWidget {
  final Widget child;
  final Function? onTap;
  final Function? onLongTap;

  const EaseInWidget({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongTap,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EaseInWidgetState();
}

class _EaseInWidgetState extends State<EaseInWidget> with TickerProviderStateMixin<EaseInWidget> {
  late AnimationController controller;
  final Tween<double> _tween = Tween(begin: 1, end: 0.9);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        if (widget.onLongTap == null) return;

        await controller.forward();
        await controller.reverse();

        widget.onLongTap != null ? widget.onLongTap!() : () {};
      },
      onTap: () async {
        if (widget.onTap == null) return;

        await controller.forward();
        await controller.reverse();

        widget.onTap != null ? widget.onTap!() : () {};
      },
      child: ScaleTransition(
        scale: _tween.animate(CurvedAnimation(
          parent: controller,
          curve: Curves.easeIn,
        )),
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
