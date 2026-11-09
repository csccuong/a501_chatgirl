import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../utils/app_util.dart';
import '../values/app_colors.dart';
import '../values/styles.dart';

class RowInputWithSvg extends StatelessWidget {
  const RowInputWithSvg(
    this.svgAssets,
    this.iconSize,
    this.textController,
    this.hintText,
    this.validated,
    this.errorText,
    this.textInputAction,
    this.textCapitalization,
    this.currentNode,
    this.nextNode, {
    Key? key,
    this.textInputType,
    this.textStyle,
    this.maxLine,
    this.isEnable,
  }) : super(key: key);

  final String svgAssets;
  final double iconSize;
  final TextEditingController textController;
  final String hintText;
  final bool validated;
  final String errorText;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final FocusNode? currentNode;
  final FocusNode? nextNode;
  final TextInputType? textInputType;
  final TextStyle? textStyle;
  final int? maxLine;
  final bool? isEnable;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.colorPrimary.withAlpha(50),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          // height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: SizedBox(
                  width: 44,
                  child: SvgPicture.asset(
                    svgAssets,
                    width: 22,
                    height: 22,
                    color: (isEnable == false)
                        ? AppColors.textSub1
                        : AppColors.textMain,
                  ).paddingOnly(top: 0),
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Center(
                  child: TextField(
                    enabled: isEnable ?? true,
                    controller: textController,
                    style: (isEnable != null && isEnable == false)
                        ? Styles.styleTextNormalSub1Color
                        : (textStyle ?? Styles.styleTextNormalMainColor),
                    keyboardType: textInputType ?? TextInputType.text,
                    textInputAction: textInputAction,
                    textCapitalization: textCapitalization,
                    focusNode: currentNode,
                    maxLines: maxLine == null ? maxLine : 1,
                    onSubmitted: (value) {
                      if (currentNode != null && nextNode != null) {
                        AppUtil
                            .fieldFocusChange(context, currentNode!, nextNode!);
                      }
                    },
                    decoration: InputDecoration(
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 0.0,
                      ),
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
              )
            ],
          ),
        ),
        validated == false
            ? Text(
                errorText,
                style: Styles.styleTextSmallRedColorItalic,
              ).marginOnly(top: 5, left: 10, bottom: 4)
            : const SizedBox()
      ],
    );
  }
}
