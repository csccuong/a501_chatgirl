import 'package:flutter/material.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class RouteObserverWidget extends StatefulWidget {
  const RouteObserverWidget({
    Key? key,
    required this.child,
    this.didPush,
    this.didPushNext,
    this.didPop,
    this.didPopNext,
  }) : super(key: key);

  final Widget child;

  // Called when the current route has been pushed.
  final void Function()? didPush;

  // Called when a new route has been pushed, and the current route is no longer visible.
  final void Function()? didPushNext;

  // Called when the current route has been popped off.
  final void Function()? didPop;

  // Called when the top route has been popped off, and the current route shows up.
  final void Function()? didPopNext;

  @override
  State<RouteObserverWidget> createState() => _RouteObserverWidgetState();
}

class _RouteObserverWidgetState extends State<RouteObserverWidget> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    super.didPush();
    widget.didPush?.call();
  }

  @override
  void didPushNext() {
    super.didPushNext();
    widget.didPushNext?.call();
  }

  @override
  void didPop() {
    super.didPop();
    widget.didPop?.call();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    widget.didPopNext?.call();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
