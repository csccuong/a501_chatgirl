import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../values/styles.dart';

void showCupertinoDatePicker(
  BuildContext context, {
  Key? key,
  CupertinoDatePickerMode mode = CupertinoDatePickerMode.dateAndTime,
  required Function(DateTime value) onDateTimeChanged,
  required Function() onCancelClick,
  required Function(DateTime? value) onOkClick,
  DateTime? initialDateTime,
  DateTime? minimumDate,
  DateTime? maximumDate,
  int minimumYear = 1,
  int? maximumYear,
  int minuteInterval = 1,
  bool use24hFormat = false,
  Color? backgroundColor,
  ImageFilter? filter,
  bool useRootNavigator = true,
  bool? semanticsDismissible,
  Widget? cancelText,
  Widget? doneText,
  bool useText = false,
  bool leftHanded = false,
}) {
  // Default to right now.
  // initialDateTime ??= DateTime.now();
  DateTime selectedDateTime = initialDateTime ?? DateTime.now();

  if (!useText) {
    cancelText = const Icon(CupertinoIcons.clear_circled);
  } else {
    cancelText ??= const Text(
      'Hủy',
      style: Styles.styleTextNormalRedColor,
    );
  }

  if (!useText) {
    doneText = const Icon(CupertinoIcons.check_mark_circled);
  } else {
    doneText ??= const Text(
      'Đồng ý',
      style: Styles.styleTextNormalPrimaryColorBold,
    );
  }

  final cancelButton = CupertinoButton(
    padding: const EdgeInsets.symmetric(horizontal: 15.0),
    child: cancelText,
    onPressed: () {
      onCancelClick();
      Navigator.of(context).pop();
    },
  );

  final doneButton = CupertinoButton(
    padding: const EdgeInsets.symmetric(horizontal: 15.0),
    child: doneText,
    onPressed: () {
      onOkClick(selectedDateTime);
      Navigator.of(context).pop();
    },
  );

  Get.dialog(Center(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      height: 240.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
              child: CupertinoDatePicker(
            key: key,
            mode: mode,
            onDateTimeChanged: (DateTime value) {
              if (mode == CupertinoDatePickerMode.time) {
                onDateTimeChanged(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, value.hour, value.minute));
              } else {
                selectedDateTime = value;
                onDateTimeChanged(value);
              }
            },
            initialDateTime: initialDateTime,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            minimumYear: minimumYear,
            maximumYear: maximumYear,
            minuteInterval: minuteInterval,
            use24hFormat: use24hFormat,
            backgroundColor: backgroundColor,
          )),
          Container(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                leftHanded ? doneButton : cancelButton,
                leftHanded ? cancelButton : doneButton,
              ],
            ),
          ),
          const SizedBox(height: 10)
        ],
      ),
    ),
  ));
}
