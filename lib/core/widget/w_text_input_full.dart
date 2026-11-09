import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../decorations/decorations.dart';
import '../utils/app_util.dart';
import '../values/styles.dart';

class WTextInputFull extends StatelessWidget {
  const WTextInputFull(
    this.textStyle,
    this.textController,
    this.hintText,
    this.validated,
    this.errorText,
    this.textInputType,
    this.textInputAction,
    this.textCapitalization,
    this.maxLine,
    this.currentNode,
    this.nextNode, {
    Key? key,
    this.autoFocus = false,
    this.prefixIcon,
  }) : super(key: key);

  final TextStyle textStyle;
  final TextEditingController textController;
  final String hintText;
  final bool validated;
  final String errorText;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final int maxLine;
  final FocusNode? currentNode;
  final FocusNode? nextNode;
  final bool? autoFocus;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            decoration: decorationWhiteShadow(borderRadius: 15),
            child: Row(
              children: [
                if (prefixIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: prefixIcon!,
                  ),
                Expanded(
                  child: TextField(
                    controller: textController,
                    style: textStyle,
                    keyboardType: textInputType,
                    textInputAction: textInputAction,
                    textCapitalization: textCapitalization,
                    focusNode: currentNode,
                    maxLines: maxLine,
                    onSubmitted: (value) {
                      if (currentNode != null && nextNode != null) {
                        AppUtil.fieldFocusChange(context, currentNode!, nextNode!);
                      }
                    },
                    decoration: InputDecoration(
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 12.0),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide.none,
                      ),
                      hintText: hintText,
                      hintStyle: Styles.styleTextSmallSub1Color,
                    ),
                  ),
                ),
              ],
            )),
        validated == false
            ? Text(
                errorText,
                style: Styles.styleTextSmallRedColorItalic,
              ).marginOnly(top: 5, left: 10, bottom: 4)
            : const SizedBox(),
      ],
    );
  }
}
