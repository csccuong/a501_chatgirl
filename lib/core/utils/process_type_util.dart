import 'package:get/get.dart';

import 'app_util.dart';
import '../values/constants.dart';

class ProcessTypeUtil {
  //isAppForeground: dành cho các type notify chưa được định nghĩa, nếu khi app đang mở thì sẽ show popup xem chi tiết thông báo
  static processClickNotifyInApp(String notifyType, String notifyDetail, bool isAppForeground, String content) async {
    // switch (notifyType) {
    //   case Constants.NOTIFY_CODE_APP_UPDATE:
    //     if (notifyDetail.isNotEmpty) {
    //       AppUtil.openAppInStore();
    //     }
    //     break;
    //   case Constants.NOTIFY_CODE_NEWS:
    //     if (notifyDetail.isNotEmpty) {
    //       // Get.toNamed(AppRoutes.NewsDetail, arguments: {"itemid": notifyDetail, 'categoryid': ""});
    //     }
    //     break;
    //   case Constants.NOTIFY_CODE_VIDEO_CALL:
    //     /*   try {
    //       ApiGraphQLQueryVideoCall apiController = new ApiGraphQLQueryVideoCall();
    //       ResponseData responseData = await apiController.requestGetDetailHistoryVideocall(notifyDetail);
    //       int status = responseData.status;
    //       String message = responseData.message;
    //
    //       if (status == Constants.RESPONSE_STATUS_SUCCESS) {
    //         if (responseData.data != null) {
    //           ShortVideoCallAppointmentModel itemData = ShortVideoCallAppointmentModel.fromJsonMap(responseData.data);
    //           Get.toNamed(AppRoutes.ResultVideoCall, arguments: {"item": itemData});
    //           if (itemData.id.isNotEmpty) {
    //             AppUtil.showLogFull("### jsonData: " + itemData.toJson().toString());
    //           }
    //         } else {
    //           AppUtil.showLogFull("### responseData.data NULL");
    //         }
    //       }
    //     } catch (e) {}*/
    //     break;
    //   case Constants.NOTIFY_CODE_QUESTION_ANSWER:
    //     // if (notifyDetail.isNotEmpty) {
    //     //   QAArgs argument = new QAArgs(itemid: notifyDetail, arrSpecialist: [], selectedSpecialist: new CommonInfo("", "", ""));
    //     //
    //     //   Get.toNamed(AppRoutes.QADetail, arguments: argument);
    //     // }
    //     break;
    //   case Constants.NOTIFY_CODE_WEB_VIEW:
    //     if (notifyDetail.isNotEmpty) {
    //       if (await canLaunchUrl(Uri.parse(notifyDetail))) {
    //         await launchUrl(Uri.parse(notifyDetail));
    //       } else {
    //         throw 'Could not launch $notifyDetail';
    //       }
    //     }
    //     break;
    //   default:
    //     if (isAppForeground == true && content.isNotEmpty) {
    //       if (content.isNotEmpty) {
    //         // DialogUtil.showDialog("Chi tiết", content, "Đồng ý", onOK: () => Get.back());
    //       }
    //     }
    //     break;
    // }
  }

}
