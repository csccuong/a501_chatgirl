import 'package:flutter/material.dart';

class WrapKeepAliveTab extends StatefulWidget {
  WrapKeepAliveTab({required this.child});

  Widget child;

  @override
  WrapKeepAliveTabState createState() {
    return new WrapKeepAliveTabState();
  }
}

class WrapKeepAliveTabState extends State<WrapKeepAliveTab> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
