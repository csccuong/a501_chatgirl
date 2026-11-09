import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../api_rest/api_repository.dart';
import '../../model/base_model/base_rest_model.dart';
import '../../utils/app_util.dart';
import '../../values/constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/request_interceptor.dart';
import 'interceptors/response_interceptor.dart';

class BaseProvider extends GetConnect {
  @override
  void onInit() {
    allowAutoSignedCert = true;
    httpClient.baseUrl = '';
    // httpClient.baseUrl = ApiConstants.httpApiUrlAuth;
    httpClient.addAuthenticator(authInterceptor);
    httpClient.addRequestModifier(requestInterceptor);
    httpClient.addResponseModifier(responseInterceptor);
    httpClient.timeout = const Duration(seconds: 60);
    timeout = const Duration(seconds: 60);
  }

  Future<BaseRestModel?> sendGet(String url) async {
    // request.headers['Content-Type'] = 'application/json';
    // request.headers['Token'] =
    String accessToken = AppUtil.getString(Constants.kAccessToken);
    AppUtil.showLog('sendGet Url:$url, Token: $accessToken');
    final res = await get(url,
            headers: <String, String>{'Authorization': 'Bearer $accessToken', 'Accept': 'application/json; charset=UTF-8', 'Accept-Language': 'vi'},
            contentType: 'application/json')
        .timeout(const Duration(seconds: 38));
    // try {
    try {
      AppUtil.showLog('BaseProvider sendGet url: $url response: ${jsonEncode(res.body)}');
    } catch (_) {}
    if (res.statusCode == 200) {
      // return BaseRestModel.fromJsonMap(res.body);
      BaseRestModel responseModel;
      AppUtil.showLog('BaseProvider sendGet res.body data type: ${res.body}');
      if (res.body is String) {
        responseModel = BaseRestModel.fromJsonMap(jsonDecode(res.body));
      } else {
        responseModel = BaseRestModel.fromJsonMap(res.body);
      }
      return responseModel;
/*
      // BaseRestModel responseModel = BaseRestModel.fromJsonMap(jsonDecode(res.body));
      if (responseModel.status == 0 && responseModel.code == 'TOKEN_EXPIRED') {
        AppUtil.showLog('BaseProvider sendPostStringee TOKEN_EXPIRED');
        ApiRepository apiRepository = ApiRepository();
        final res = await apiRepository.refreshToken();
        try {
          if (res != null && res.status == Constants.RESPONSE_STATUS_SUCCESS) {
            AppUtil.showLog('requestRefreshToken SUCCESS ==> RECALL API: ');
            if (res.data != null) {
              try {
                String newToken = res.data['token'];
                String newRefreshToken = res.data['refreshToken'];
                AppUtil.showLog('newToken: $newToken');
                AppUtil.showLog('newRefreshToken: $newRefreshToken');

                AppUtil.saveString(Constants.kAccessToken, newToken);
                AppUtil.saveString(Constants.kRefreshToken, newRefreshToken);

                AppUtil.showLog('Recall API');
                return await sendGet(url);
                // return queryResult;
              } catch (e) {
                AppUtil.showLog('refreshToken error: $e');
              }
            }
          } else {
            AppUtil.showLog('requestRefreshToken FAIL ==> CHECK CURRENT ROUTE ==> IF NOT LOGIN ==> GOTO LOGIN');
            AppUtil.showLog('requestRefreshToken FAIL ==> CURRENT ROUTE: ${Get.currentRoute}');
            if (!Get.currentRoute.contains('Login')) {
              AppUtil.showLog('requestRefreshToken FAIL ==> GO TO LOGIN');
              Get.offAllNamed(AppRoutes.LOGIN);
            } else {
              AppUtil.showLog('requestRefreshToken FAIL ==> NOT GO TO LOGIN');
            }
          }
        } catch (e) {
          AppUtil.hideLoading();
        }
      } else {
        AppUtil.showLog('BaseProvider TOKEN NOT EXPIRED');
        return responseModel;
      }*/
    } else {
      // AppUtil.showToast(Constants.CommonErrorMessage);
      return null;
    }
    return null;
    // } catch (e) {
    //   AppUtil.showLog('BaseProvider sendGet ERROR' + e.toString());
    //   return null;
    // }
  }

  Future<BaseRestModel?> sendPost(String url, dynamic data) async {
    try {
      AppUtil.showLog('BaseProvider sendPost url: $url, Body: ${jsonEncode(data)}');
    } catch (e) {
      AppUtil.showLog('Error log sendPost data:$e');
    }
    String accessToken = AppUtil.getString(Constants.kAccessToken);

    // final res = await get(url, headers: <String, String>{'Token': token, 'Accept': 'application/json; charset=UTF-8'}, contentType: 'application/json');
    final res = await post(url, data, headers: <String, String>{'Authorization': 'Bearer $accessToken', 'Accept': 'application/json; charset=UTF-8', 'Accept-Language': 'vi'})
        .timeout(const Duration(seconds: 38));
    try {
      AppUtil.showLogFull('BaseProvider sendPost $url response: ${jsonEncode(res.body)}');
      if (res.statusCode == 200) {
        BaseRestModel responseModel = BaseRestModel.fromJsonMap(res.body);
        return responseModel;
        /*if (responseModel.status == Constants.RESPONSE_STATUS_FAIL && responseModel.code == 'TOKEN_EXPIRED') {
          AppUtil.showLog('BaseProvider TOKEN_EXPIRED');
          AppUtil.showLog('Request refreshToken');
          ApiRepository apiRepository = ApiRepository();
          final res = await apiRepository.refreshToken();
          try {
            if (res != null && res.status == Constants.RESPONSE_STATUS_SUCCESS) {
              AppUtil.showLog('requestRefreshToken SUCCESS ==> RECALL API: ');
              if (res.data != null) {
                try {
                  String newToken = res.data['token'];
                  String newRefreshToken = res.data['refreshToken'];
                  AppUtil.showLog('newToken: $newToken');
                  AppUtil.showLog('newRefreshToken: $newRefreshToken');

                  AppUtil.saveString(Constants.kAccessToken, newToken);
                  AppUtil.saveString(Constants.kRefreshToken, newRefreshToken);

                  AppUtil.showLog('Recall API');
                  return await sendPost(url, data);
                  // return queryResult;
                } catch (e) {
                  AppUtil.showLog('refreshToken error: $e');
                }
              }
            } else {
              AppUtil.showLog('requestRefreshToken FAIL ==> CHECK CURRENT ROUTE ==> IF NOT LOGIN ==> GOTO LOGIN');
              AppUtil.showLog('requestRefreshToken FAIL ==> CURRENT ROUTE: ${Get.currentRoute}');
              if (!Get.currentRoute.contains('Login')) {
                AppUtil.showLog('requestRefreshToken FAIL ==> GO TO LOGIN');
                Get.offAllNamed(AppRoutes.LOGIN);
              } else {
                AppUtil.showLog('requestRefreshToken FAIL ==> NOT GO TO LOGIN');
              }
            }
          } catch (e) {
            AppUtil.hideLoading();
          }
        } else {
          AppUtil.showLog('BaseProvider TOKEN NOT EXPIRED');
          return responseModel;
        }*/
      } else if (res.statusCode == null) {
        // DialogUtil.showDialogErrorConnection();
        AppUtil.showToastError('No data');
        return null;
      } else {
        // AppUtil.showToast(Constants.CommonErrorMessage);
        return null;
      }
    } catch (e) {
      AppUtil.showLog('BaseProvider sendPost ERROR$e');
    }
    return null;
  }

  Future<BaseRestModel?> sendPostStringee(String url, String userId) async {
    try {
      AppUtil.showLog('BaseProvider sendPostStringee url: $url, Body: $userId');
    } catch (e) {
      AppUtil.showLog('Error log sendPostStringee data:$e');
    }
    String accessToken = AppUtil.getString(Constants.kAccessToken);
    var map = <String, dynamic>{};
    map['id'] = userId;
    Map<String, String> defaultHeaders = {'Accept-Language': 'vi', 'Token': accessToken};
    var response = await http.post(Uri.parse(url), body: map, headers: defaultHeaders);
    AppUtil.showLog('BaseProvider sendPostStringee response: ${response.toString()}');
    if (response.statusCode == 200) {
      BaseRestModel responseModel = BaseRestModel.fromJsonMap(jsonDecode(response.body));
      return responseModel;
  /*
      if (responseModel.status == 0 && responseModel.code == 'TOKEN_EXPIRED') {
        AppUtil.showLog('BaseProvider sendPostStringee TOKEN_EXPIRED');
        ApiRepository apiRepository = ApiRepository();
        final res = await apiRepository.refreshToken();
        try {
          if (res != null && res.status == Constants.RESPONSE_STATUS_SUCCESS) {
            AppUtil.showLog('requestRefreshToken SUCCESS ==> RECALL API: ');
            if (res.data != null) {
              try {
                String newToken = res.data['token'];
                String newRefreshToken = res.data['refreshToken'];
                AppUtil.showLog('sendPostStringee newToken: $newToken');
                AppUtil.showLog('sendPostStringee newRefreshToken: $newRefreshToken');

                AppUtil.saveString(Constants.kAccessToken, newToken);
                AppUtil.saveString(Constants.kRefreshToken, newRefreshToken);

                AppUtil.showLog('sendPostStringee Recall API');
                return await sendPostStringee(url, userId);
                // return queryResult;
              } catch (e) {
                AppUtil.showLog('sendPostStringee refreshToken error: $e');
              }
            }
          } else {
            AppUtil.showLog('sendPostStringee requestRefreshToken FAIL ==> CHECK CURRENT ROUTE ==> IF NOT LOGIN ==> GOTO LOGIN');
            AppUtil.showLog('sendPostStringee requestRefreshToken FAIL ==> CURRENT ROUTE: ${Get.currentRoute}');
            if (!Get.currentRoute.contains('Login')) {
              AppUtil.showLog('sendPostStringee requestRefreshToken FAIL ==> GO TO LOGIN');
              Get.offAllNamed(AppRoutes.LOGIN);
            } else {
              AppUtil.showLog('sendPostStringee requestRefreshToken FAIL ==> NOT GO TO LOGIN');
            }
          }
        } catch (e) {
          AppUtil.hideLoading();
        }
      } else {
        AppUtil.showLog('BaseProvider TOKEN NOT EXPIRED');
        return responseModel;
      }*/
    }
    return null;
  }

/*  Future<BaseRestModel?> sendPostRefreshToken(String url) async {
    try {
      AppUtil.showLogFull('BaseProvider sendPostRefreshToken url: $url');
    } catch (e) {
      AppUtil.showLog('Error log sendPostRefreshToken data:$e');
    }
    String accessToken = AppUtil.getString(Constants.kAccessToken);
    String refreshToken = AppUtil.getString(Constants.kRefreshToken);
    AppUtil.showLogFull('BaseProvider sendPostRefreshToken accessToken: $accessToken, refreshToken: $refreshToken ');

    Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    RefreshTokenRequest refreshTokenRequest =
        RefreshTokenRequest(refreshToken: refreshToken, deviceId: deviceId, branch: branch, model: model, osVersion: osVersion, appVersion: appVersion);

    AppUtil.showLogFull('BaseProvider sendPostRefreshToken refreshTokenRequest: ${refreshTokenRequest.toJson()}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(refreshTokenRequest.toJson()), headers: headers);
    AppUtil.showLog('BaseProvider sendPostRefreshToken response: ${jsonEncode(res.body)}');

    try {
      AppUtil.showLogFull('BaseProvider sendPostRefreshToken $url response: ${jsonEncode(res.body)}');
      if (res.statusCode == 200) {
        return BaseRestModel.fromJsonMap(jsonDecode(res.body));
        // return BaseRestModel.fromJsonMap(res.body);
      } else {
        // AppUtil.showToast(Constants.CommonErrorMessage);
        return null;
      }
    } catch (e) {
      AppUtil.showLog('BaseProvider sendPostRefreshToken ERROR: $e');
    }
    return null;
  }*/

  Future<BaseRestModel> uploadMultiFiles(String url, List<File> files) async {
    AppUtil.showLoading();
    // string to uri
    var uri = Uri.parse(url);
    AppUtil.showLog('uploadMultiFiles url: ${uri.path}');

    // create multipart request
    var request = http.MultipartRequest('POST', uri);

    for (var file in files) {
      String fileName = file.path.split('/').last;
      var stream = http.ByteStream(file.openRead())..cast();
      // get file length
      var length = await file.length(); //imageFile is your image file
      // multipart that takes file
      var multipartFileSign = http.MultipartFile('files', stream, length, filename: fileName);
      request.files.add(multipartFileSign);
    }
    // Map<String, String> headers = {'Accept': 'application/json', 'Authorization': 'Bearer $value'}; // ignore this headers if there is no authentication
    //add headers
    //     request.headers.addAll(headers);
    //adding params
    //     request.fields['id'] = userid;

    // send
    var res = await request.send();
    BaseRestModel responseModel = BaseRestModel();
    try {
      String strResponse = await res.stream.bytesToString();
      AppUtil.showLog('BaseProvider uploadMultiFiles response: $strResponse');
      if (res.statusCode == 200) {
        responseModel = BaseRestModel.fromJsonMap(jsonDecode(strResponse));
      } else {
        // AppUtil.showToast(Constants.CommonErrorMessage);
        responseModel = BaseRestModel();
      }
    } catch (e) {
      AppUtil.showLog('BaseProvider uploadMultiFiles ERROR: $e');
    }
    AppUtil.hideLoading();
    return responseModel;
  }
}
