import 'package:flutter/material.dart';

import 'app_colors.dart';

class Styles {
  static const String FORMAT_DATE = "dd/MM/yyyy";
  static const String FORMAT_DATE_AND_TIME = "dd/MM/yyyy HH:mm:ss";
  static const String FORMAT_DATEONLY = "dd/MM/yyyy";
  static const String FORMAT_TIMEONLY = "HH:mm";
  static const String FORMAT_DATETIME_START_DAY = "dd/MM/yyyy 00:00:00";
  static const String FORMAT_DATETIME_END_DAY = "dd/MM/yyyy 23:59:59";
  static const String FORMAT_MONTH_ONLY = "MM, yyyy";
  static const String FORMAT_DATE_WITHOUT_YEAR = "dd-MM";

  // static const String FORMAT_DATE_COVID = "yyyy-DD-mm";
  static const String FORMAT_DATEREQUEST = "yyyy-MM-dd";
  static const String FORMAT_DATETIMEREQUEST = "yyyy-MM-dd HH:mm:ss";

  // static const String FORMAT_TIMEONLY = "hh:mm";
  static const String FORMAT_DATETIME = "dd/MM/yyyy HH:mm";
  static const String FORMAT_DATETIME_TIMEFIRST = "HH:mm - dd/MM/yyyy";

  static const String test = 'test';
  static const num testNum = 1;
  static const double largeText = 40.0;
  static const double normalText = 22.0;
  static const double smallText = 16.0;

  static const double Size_text_tiny = 9;
  static const double Size_text_supersmall = 11;
  static const double Size_text_small = 13;
  static const double Size_text_normal = 14;
  static const double Size_text_button = 15;
  static const double Size_text_title = 17;
  static const double Size_text_super_big = 20;
  static const double Size_text_screen_title = 22;
  static const double Size_title_introduce = 24;
  static const double Size_greeting = 28;

  static const TextStyle styleTextScreenTitleMainColor = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.normal, fontSize: Size_text_screen_title);
  static const TextStyle styleTextScreenTitleMainColorBold = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600, fontSize: Size_text_screen_title);
  static const TextStyle styleTextScreenTitleWhiteBold = TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: Size_text_screen_title);

  static const TextStyle styleTextGreetingMainColor = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.normal, fontSize: Size_greeting);
  static const TextStyle styleTextGreetingMainColorBold = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600, fontSize: Size_greeting);
  static const TextStyle styleTextGreetingPrimaryColorBold = TextStyle(color: AppColors.colorPrimary, fontWeight: FontWeight.w600, fontSize: Size_greeting);

  static const TextStyle styleTextSuperBigMainColor = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.normal, fontSize: Size_text_super_big);
  static const TextStyle styleTextSuperBigMainColorBold = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: Size_text_super_big);
  static const TextStyle styleTextSuperBigWhiteColor = TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.normal, fontSize: Size_text_super_big);
  static const TextStyle styleTextSuperBigWhiteColorBold = TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w600, fontSize: Size_text_super_big);
  static const TextStyle styleTextSuperBigPrimaryColorBold = TextStyle(color: AppColors.colorPrimary, fontWeight: FontWeight.bold, fontSize: Size_text_super_big);

  static const TextStyle styleTextButtonWhiteColor = TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.normal, fontSize: Size_text_button);
  static const TextStyle styleTextButtonMainColor = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w500, fontSize: Size_text_button);
  static const TextStyle styleTextButtonMainColorBold = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600, fontSize: Size_text_button);
  static const TextStyle styleTextButtonWhiteColorBold = TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w600, fontSize: Size_text_button);

  static const TextStyle styleTextTitleRedColorBold = TextStyle(color: AppColors.redPrimary, fontWeight: FontWeight.bold, fontSize: Size_text_title);
  static const TextStyle styleTextTitleWhiteColorBold = TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold, fontSize: Size_text_title);
  static const TextStyle styleTextTitleMainColorBold = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: Size_text_title);
  static const TextStyle styleTextTitlePrimaryColorBold = TextStyle(color: AppColors.colorPrimary, fontWeight: FontWeight.w600, fontSize: Size_text_title);
  static const TextStyle styleTextTitleWhiteColor = TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.normal, fontSize: Size_text_title);
  static const TextStyle styleTextTitleBlueColor = TextStyle(color: Color(0xFF192A56), fontWeight: FontWeight.normal, fontSize: Size_text_title);
  static const TextStyle styleTextTitleMainColorLight = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.normal, fontSize: Size_text_title);
  static const TextStyle styleTextTitleMainColor = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w500, fontSize: Size_text_title);
  static const TextStyle styleTextTitleSubColorLight = TextStyle(color: AppColors.textSub, fontWeight: FontWeight.normal, fontSize: Size_text_title);
  static const TextStyle styleTextTitleSubColor = TextStyle(color: AppColors.textSub, fontWeight: FontWeight.w500, fontSize: Size_text_title);

  static const TextStyle styleTextNormalWhiteColorBold = TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w600, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalWhiteColorLight = TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.normal, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalWhiteColor = TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w500, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalBlueColor = TextStyle(color: Color(0xFF192A56), fontWeight: FontWeight.normal, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalPrimaryColorBold = TextStyle(color: AppColors.colorPrimary, fontWeight: FontWeight.w600, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalPrimaryColorLight = TextStyle(color: AppColors.colorPrimary, fontWeight: FontWeight.normal, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalPrimaryColor = TextStyle(color: AppColors.colorPrimary, fontWeight: FontWeight.w500, fontSize: Size_text_normal);

  static const TextStyle styleTextNormalBlueSecondaryColor = TextStyle(color: AppColors.blueSecondary, fontWeight: FontWeight.w500, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalBlueSecondaryColorBold = TextStyle(color: AppColors.blueSecondary, fontWeight: FontWeight.w600, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalBlueSecondaryColorLight = TextStyle(color: AppColors.blueSecondary, fontWeight: FontWeight.normal, fontSize: Size_text_normal);

  static const TextStyle styleTextSmallBlueSecondaryColor = TextStyle(color: AppColors.blueSecondary, fontWeight: FontWeight.w500, fontSize: Size_text_small);
  static const TextStyle styleTextSmallBlueSecondaryColorBold = TextStyle(color: AppColors.blueSecondary, fontWeight: FontWeight.w600, fontSize: Size_text_small);
  static const TextStyle styleTextSmallBlueSecondaryColorLight = TextStyle(color: AppColors.blueSecondary, fontWeight: FontWeight.normal, fontSize: Size_text_small);
  static const TextStyle styleTextSmallGreenSecondaryColorBold = TextStyle(color: AppColors.greenSecondary, fontWeight: FontWeight.w600, fontSize: Size_text_small);

  // static const TextStyle styleTextNormalPrimaryColor = TextStyle(color: AppColors.colorPrimary, fontWeight: FontWeight.normal, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalMainColorBold = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalMainColorLight = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.normal, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalMainColor = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w500, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalSubColorBold = TextStyle(color: AppColors.textSub, fontWeight: FontWeight.w600, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalSubColorLight = TextStyle(color: AppColors.textSub, fontWeight: FontWeight.normal, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalSubColor = TextStyle(color: AppColors.textSub, fontWeight: FontWeight.w500, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalSub1Color = TextStyle(color: AppColors.textSub1, fontWeight: FontWeight.normal, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalHintColor = TextStyle(color: AppColors.textSub1, fontWeight: FontWeight.normal, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalRedColorBold = TextStyle(color: AppColors.redPrimary, fontWeight: FontWeight.w500, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalRedColor = TextStyle(color: AppColors.redPrimary, fontWeight: FontWeight.normal, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalRedColorItalic =
      TextStyle(color: AppColors.redPrimary, fontWeight: FontWeight.normal, fontSize: Size_text_normal, fontStyle: FontStyle.italic);
  static const TextStyle styleTextNormalYellowColor = TextStyle(color: Color(0xFFF5D43D), fontWeight: FontWeight.normal, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalIconGrayColor = TextStyle(color: AppColors.iconGray, fontWeight: FontWeight.normal, fontSize: Size_text_normal);
  static const TextStyle styleTextNormalIconGrayColorBold = TextStyle(color: AppColors.iconGray, fontWeight: FontWeight.w600, fontSize: Size_text_normal);

  static const TextStyle styleTextIntroduceWhiteColorBold = TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w700, fontSize: Size_title_introduce);
  static const TextStyle styleTextIntroduceMainColorBold = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w700, fontSize: Size_title_introduce);

  static const TextStyle styleTextSmallWhiteColorBold = TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w600, fontSize: Size_text_small);
  static const TextStyle styleTextSmallWhiteColorLight = TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.normal, fontSize: Size_text_small);
  static const TextStyle styleTextSmallWhiteColor = TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w500, fontSize: Size_text_small);
  static const TextStyle styleTextSmallMainColorItalic =
      TextStyle(color: AppColors.textMain, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic, fontSize: Size_text_small);
  static const TextStyle styleTextSmallMainColorBold = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600, fontSize: Size_text_small);
  static const TextStyle styleTextSmallMainColorBoldUnderline = TextStyle(
    color: AppColors.textMain,
    fontWeight: FontWeight.w500,
    fontSize: Size_text_small,
    decoration: TextDecoration.underline,
  );
  static const TextStyle styleTextSmallSubColorBold = TextStyle(color: AppColors.textSub, fontWeight: FontWeight.w600, fontSize: Size_text_small);
  static const TextStyle styleTextSmallMainColorLight = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.normal, fontSize: Size_text_small);
  static const TextStyle styleTextSmallMainColor = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w500, fontSize: Size_text_small);
  static const TextStyle styleTextSmallSubColorLight = TextStyle(color: AppColors.textSub, fontWeight: FontWeight.normal, fontSize: Size_text_small);
  static const TextStyle styleTextSmallSubColor = TextStyle(color: AppColors.textSub, fontWeight: FontWeight.w500, fontSize: Size_text_small);
  static const TextStyle styleTextSmallSubColorItalic = TextStyle(color: AppColors.textSub, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic, fontSize: Size_text_small);
  static const TextStyle styleTextSmallSub1Color = TextStyle(color: AppColors.textSub1, fontWeight: FontWeight.normal, fontSize: Size_text_small);
  static const TextStyle styleTextSmallBlueColor = TextStyle(color: Color(0xFF192A56), fontWeight: FontWeight.normal, fontSize: Size_text_small);
  static const TextStyle styleTextSmallPrimaryColor = TextStyle(color: AppColors.colorPrimary, fontWeight: FontWeight.normal, fontSize: Size_text_small);
  static const TextStyle styleTextSmallPrimaryColorLight = TextStyle(color: AppColors.colorPrimary, fontWeight: FontWeight.w400, fontSize: Size_text_small);
  static const TextStyle styleTextSmallPrimaryColorItalic =
      TextStyle(color: Color(0xFF1B92F6), fontWeight: FontWeight.normal, fontSize: Size_text_small, fontStyle: FontStyle.italic);
  static const TextStyle styleTextSmallPrimaryColorBold = TextStyle(color: Color(0xFF1B92F6), fontWeight: FontWeight.w500, fontSize: Size_text_small);
  static const TextStyle styleTextSmallPrimaryColorBoldUnderline = TextStyle(
    color: Color(0xFF1B92F6),
    fontWeight: FontWeight.w500,
    fontSize: Size_text_small,
    decoration: TextDecoration.underline,
  );
  static const TextStyle styleTextSmallRedColor = TextStyle(color: Colors.red, fontWeight: FontWeight.normal, fontSize: Size_text_small);
  static const TextStyle styleTextSmallRedColorBoldUnderline = TextStyle(
    color: Colors.red,
    fontWeight: FontWeight.bold,
    fontSize: Size_text_small,
    decoration: TextDecoration.underline,
  );
  static const TextStyle styleTextSmallRedColorBold = TextStyle(color: Colors.red, fontWeight: FontWeight.w500, fontSize: Size_text_small);
  static const TextStyle styleTextSmallRedColorItalic = TextStyle(color: Colors.red, fontWeight: FontWeight.normal, fontSize: Size_text_small, fontStyle: FontStyle.italic);

  static const TextStyle styleTextSuperSmallMainColorBold = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w700, fontSize: Size_text_supersmall);
  static const TextStyle styleTextSuperSmallMainColor = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.normal, fontSize: Size_text_supersmall);
  static const TextStyle styleTextSuperSmallSubColorLight = TextStyle(color: AppColors.textSub, fontWeight: FontWeight.normal, fontSize: Size_text_supersmall);
  static const TextStyle styleTextSuperSmallSubColor = TextStyle(color: AppColors.textSub, fontWeight: FontWeight.w500, fontSize: Size_text_supersmall);
  static const TextStyle styleTextSuperSmallSubColorBold = TextStyle(color: AppColors.textSub, fontWeight: FontWeight.w600, fontSize: Size_text_supersmall);
  static const TextStyle styleTextSuperSmallSub1ColorLight = TextStyle(color: AppColors.textSub1, fontWeight: FontWeight.w400, fontSize: Size_text_supersmall);
  static const TextStyle styleTextSuperSmallSub1Color = TextStyle(color: AppColors.textSub1, fontWeight: FontWeight.w500, fontSize: Size_text_supersmall);
  static const TextStyle styleTextSuperSmallBlueColor = TextStyle(color: Color(0xFF192A56), fontWeight: FontWeight.normal, fontSize: Size_text_supersmall);
  static const TextStyle styleTextSuperSmallWhiteColor = TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.normal, fontSize: Size_text_supersmall);
  static const TextStyle styleTextSuperSmallWhiteColorBold = TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w500, fontSize: Size_text_supersmall);
  static const TextStyle styleTextSuperSmallPrimaryColor = TextStyle(color: Color(0xFF1B92F6), fontWeight: FontWeight.normal, fontSize: Size_text_supersmall);
  static const TextStyle styleTextSuperSmallPrimaryColorBold = TextStyle(color: Color(0xFF1B92F6), fontWeight: FontWeight.w500, fontSize: Size_text_supersmall);
  static const TextStyle styleTextSuperSmallAppBarBlueColorBold = TextStyle(color: AppColors.colorAppBarBlue, fontWeight: FontWeight.w600, fontSize: Size_text_supersmall);
  static const TextStyle styleTextSuperSmallRedColor = TextStyle(color: Color(0xFFFB6D77), fontWeight: FontWeight.normal, fontSize: Size_text_supersmall);
  static const TextStyle styleTextSuperSmallSubColorItalic =
      TextStyle(color: AppColors.textSub, fontWeight: FontWeight.normal, fontSize: Size_text_supersmall, fontStyle: FontStyle.italic);

  static const TextStyle styleTextTinyWhiteColor = TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.normal, fontSize: Size_text_tiny);
  static const TextStyle styleTextTinyIconGrayColor = TextStyle(color: AppColors.iconGray, fontWeight: FontWeight.normal, fontSize: Size_text_tiny);
  static const TextStyle styleTextTinyMainColor = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w500, fontSize: Size_text_tiny);
  static const TextStyle styleTextTinyMainColorLight = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.normal, fontSize: Size_text_tiny);
  static const TextStyle styleTextTinyMainColorBold = TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w700, fontSize: Size_text_tiny);
  static const TextStyle styleTextTinySubColor = TextStyle(color: AppColors.textSub, fontWeight: FontWeight.w500, fontSize: Size_text_tiny);
  static const TextStyle styleTextTinyPrimaryColor = TextStyle(color: AppColors.colorPrimary, fontWeight: FontWeight.w500, fontSize: Size_text_tiny);
  static const TextStyle styleTextTinyPrimaryColorBold = TextStyle(color: AppColors.colorPrimary, fontWeight: FontWeight.w700, fontSize: Size_text_tiny);
  static const TextStyle styleTextTinyWhiteColorLight = TextStyle(color: AppColors.white, fontWeight: FontWeight.w400, fontSize: Size_text_tiny);

  // Gradient
  static const LinearGradient appLinearGradient = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFfFFFFFF), Color(0xFfEDF9FF)]);

  static List<BoxShadow>? boxShadow = [
    BoxShadow(color: AppColors.bgColor.withOpacity(0.4), spreadRadius: 2, blurRadius: 2, offset: const Offset(0, 3)),
  ];
  static List<BoxShadow>? boxShadow3 = [
    BoxShadow(color: AppColors.bgColor.withOpacity(0.4), spreadRadius: 2, blurRadius: 2, offset: const Offset(0, -2)),
    BoxShadow(color: AppColors.bgColor.withOpacity(0.4), spreadRadius: 1, blurRadius: 1, offset: const Offset(-2, 0)),
    BoxShadow(color: AppColors.bgColor.withOpacity(0.4), spreadRadius: 1, blurRadius: 1, offset: const Offset(2, 0)),
  ];
  static List<BoxShadow>? boxShadowPrimaryColor = [
    BoxShadow(
      color: AppColors.colorPrimary.withAlpha(70),
      blurRadius: 6,
      offset: const Offset(0, 3),
    )
  ];
}
