import 'package:flutter/material.dart';
import 'w_text_input_full.dart';

import '../values/styles.dart';

class WTextInput extends StatelessWidget {
  const WTextInput(
    this.textController,
    this.hintText,
    this.validated,
    this.errorText,
    this.textInputAction,
    this.currentNode,
    this.nextNode, {
    Key? key,
    this.textInputType,
    this.textCapitalization,
    this.autoFocus = false,
    this.maxLine = 1,
    this.prefixIcon,
  }) : super(key: key);

  final TextEditingController textController;
  final String hintText;
  final bool validated;
  final String errorText;
  final TextInputAction textInputAction;
  final FocusNode? currentNode;
  final FocusNode? nextNode;
  final TextInputType? textInputType;
  final TextCapitalization? textCapitalization;

  final bool? autoFocus;
  final int maxLine;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return WTextInputFull(
      Styles.styleTextNormalMainColor,
      textController,
      hintText,
      validated,
      errorText,
      textInputType != null ? textInputType! : TextInputType.text,
      textInputAction,
      textCapitalization != null
          ? textCapitalization!
          : TextCapitalization.sentences,
      maxLine,
      currentNode,
      nextNode,
      autoFocus: autoFocus,
      prefixIcon: prefixIcon,
    );
  }
}
