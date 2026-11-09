import 'dart:async';

import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';

import '../../../model/base_model/error_response.dart';
import '../../../utils/app_util.dart';

FutureOr<dynamic> responseInterceptor(Request request, Response response) async {
  AppUtil.hideLoading();

  if (response.statusCode != 200) {
    handleErrorStatus(response);
    return;
  }

  return response;
}

void handleErrorStatus(Response response) {
  switch (response.statusCode) {
    case 400:
      final message = ErrorResponse.fromJson(response.body);
      AppUtil.showToast(message.error);
      break;
    default:
  }

  return;
}
