import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../anim/ease_in_widget.dart';
import '../values/app_colors.dart';
import '../values/constants.dart';
import '../values/enums.dart';
import '../values/styles.dart';
import '../widget/button_primary.dart';
import '../widget/button_primary_outline.dart';
import '../widget/custom_date_picker.dart';
import 'app_util.dart';

class DialogUtil {


  static showSimpleDialog(
    String message, {
    String? title,
    required String okLabel,
    required void Function() onOK,
    Widget? iconResource,
  }) async {
    await Get.dialog(
      Container(
        margin: EdgeInsets.only(top: 30),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20.0),
                  title != null
                      ? iconResource != null
                          ? Center(
                              child: Text(title,
                                      style:
                                          Styles.styleTextNormalMainColorBold,
                                      textAlign: TextAlign.center)
                                  .marginOnly(bottom: 5),
                            )
                          : Text(
                              title,
                              style: Styles.styleTextNormalMainColorBold,
                              textAlign: TextAlign.left,
                            ).marginOnly(bottom: 5)
                      : SizedBox(),
                  iconResource != null
                      ? Center(child: iconResource)
                          .marginOnly(top: 15, bottom: 10, left: 5, right: 5)
                      : const SizedBox(),
                  const SizedBox(height: 10.0),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: iconResource != null ? 10 : 0),
                    child: iconResource != null
                        ? Center(
                            child: Text(
                              message,
                              style: Styles.styleTextNormalMainColorLight,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Text(
                            message,
                            style: Styles.styleTextNormalMainColorLight,
                            textAlign: TextAlign.left,
                          ),
                  ),
                  const SizedBox(height: 12.0),
                  Align(
                    alignment: iconResource != null
                        ? Alignment.center
                        : Alignment.centerRight,
                    child: EaseInWidget(
                      onTap: onOK,
                      child: Container(
                        color: AppColors.transparent,
                        alignment: Alignment.centerRight,
                        height: 40,
                        width: 200,
                        child: iconResource != null
                            ? Center(
                                child: Text(
                                  okLabel,
                                  style: Styles.styleTextNormalPrimaryColorBold,
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : Text(
                                okLabel,
                                style: Styles.styleTextNormalPrimaryColorBold,
                                textAlign: TextAlign.right,
                              ).marginOnly(right: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15.0),
                ],
              ),
            ),
            Positioned(
                top: 0,
                right: 10,
                child: EaseInWidget(
                  child: Container(
                    padding: EdgeInsets.all(4),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.colorPrimary,
                    ),
                  ),
                  onTap: () => Get.back(),
                ))
          ],
        ),
      ),
    );
  }

  static void showConfirmDialog(
    String message, {
    required String cancelLabel,
    required String okLabel,
    required void Function() onCancel,
    required void Function() onOK,
    Widget? iconResource,
  }) {
    Get.dialog(
      Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Center(
                  child: Text(
                    message,
                    style: Styles.styleTextNormalMainColorBold,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              iconResource != null
                  ? Center(child: iconResource).marginOnly(top: 15)
                  : const SizedBox(),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: ButtonPrimaryOutline(
                      btnTitle: cancelLabel,
                      onTap: onCancel,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ButtonPrimary(
                      btnTitle: okLabel,
                      onTap: onOK,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 23.0),
            ],
          ),
        ),
      ),
    );
  }

  static showDatePicker(
    BuildContext context, {
    DateTime? minDate,
    DateTime? maxDate,
    required Function(DateTime? value) onOkClick,
    DateTime? initialDateTime,
    Function()? onCancelClick,
    Function(DateTime value)? onDateTimeChange,
  }) {
    AppUtil.showLog("showDatePicker initialDateTime: $initialDateTime");
    AppUtil.showLog("showDatePicker         maxDate: $maxDate");

    // if (minDate != null) {
    showCupertinoDatePicker(context,
        mode: CupertinoDatePickerMode.date,
        initialDateTime: initialDateTime,
//     leftHanded: true,
        useText: true,
        minimumDate: minDate,
        maximumDate: maxDate != null
            ? DateTime(
                maxDate.year, maxDate.month, maxDate.day, 23, 59, 59, 999)
            : null,
        // maximumDate: maxDate != null ? maxDate.add(Duration(minutes: 30)) : null,
        onDateTimeChanged: onDateTimeChange ?? (value) {},
        onCancelClick: onCancelClick ?? () {},
        onOkClick: onOkClick);
//     } else {
//       showCupertinoDatePicker(context,
//           mode: CupertinoDatePickerMode.date,
//           initialDateTime: initialDateTime != null ? initialDateTime : DateTime.now(),
// //     leftHanded: true,
//           useText: true,
//           onDateTimeChanged: onDateTimeChange != null ? onDateTimeChange : (value) {},
//           onCancelClick: onCancelClick != null ? onCancelClick : () {},
//           onOkClick: onOkClick);
//     }
  }

  static showMonthPicker(
    BuildContext context, {
    DateTime? minDate,
    DateTime? maxDate,
    required Function(DateTime? value) onOkClick,
    DateTime? initialDateTime,
    Function()? onCancelClick,
    Function(DateTime value)? onDateTimeChange,
  }) {
    // if (minDate != null) {
    showCupertinoDatePicker(context,
        mode: CupertinoDatePickerMode.date,
        initialDateTime: initialDateTime ?? DateTime.now(),
//     leftHanded: true,
        useText: true,
        minimumDate: minDate,
        maximumDate: maxDate,
        onDateTimeChanged: onDateTimeChange ?? (value) {},
        onCancelClick: onCancelClick ?? () {},
        onOkClick: onOkClick);
//     } else {
//       showCupertinoDatePicker(context,
//           mode: CupertinoDatePickerMode.date,
//           initialDateTime: initialDateTime != null ? initialDateTime : DateTime.now(),
// //     leftHanded: true,
//           useText: true,
//           onDateTimeChanged: onDateTimeChange != null ? onDateTimeChange : (value) {},
//           onCancelClick: onCancelClick != null ? onCancelClick : () {},
//           onOkClick: onOkClick);
//     }
  }

  static void showDialogBottom(
    String actionTitle,
    String actionDescription,
    String cancelTitle, {
    required void Function() onTap,
  }) {
    Get.bottomSheet(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              actionTitle,
              style: Styles.styleTextNormalMainColorBold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            const Divider(
              color: AppColors.dividerColor,
              indent: 60,
              endIndent: 60,
            ),
            const SizedBox(height: 15),
            ButtonPrimary(btnTitle: actionDescription, onTap: onTap),
            const SizedBox(height: 15),
            const Divider(
              color: AppColors.dividerColor,
              indent: 80,
              endIndent: 80,
            ),
            EaseInWidget(
              child: Container(
                height: 45,
                color: AppColors.transparent,
                child: Center(
                  child: Text(
                    cancelTitle,
                    style: Styles.styleTextNormalMainColorLight,
                  ),
                ),
              ),
              onTap: () {
                Get.back();
              },
              // onTap: () => onTap,
            ),
          ],
        ),
      ),
      elevation: 20.0,
      enableDrag: false,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
    );
  }

  static void showDialogLogout({
    required void Function() onTapLogout,
  }) {
    Get.bottomSheet(
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Bạn có chắc chắn muốn đăng xuất khỏi My Medlatec không?',
              style: Styles.styleTextNormalMainColorBold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Divider(
              color: AppColors.dividerColor,
              indent: 60,
              endIndent: 60,
            ),
            const SizedBox(height: 5),
            ButtonPrimary(btnTitle: 'Đăng xuất', onTap: onTapLogout),
            const SizedBox(height: 5),
            const Divider(
              color: AppColors.dividerColor,
              indent: 80,
              endIndent: 80,
            ),
            const SizedBox(height: 5),
            EaseInWidget(
              child: Container(
                height: 45,
                color: AppColors.transparent,
                child: const Center(
                  child: Text(
                    'Hủy',
                    style: Styles.styleTextNormalMainColorLight,
                  ),
                ),
              ),
              onTap: () {
                Get.back();
              },
            ),
          ],
        ),
      ),
      elevation: 20.0,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
    );
  }

}
