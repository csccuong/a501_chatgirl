import 'dart:convert';
import 'dart:io';
import 'package:adjust_sdk/adjust.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/network/base_rest/base_provider.dart';
import '../core/utils/app_util.dart';
import '../core/values/constants.dart';
import '../flavors/build_config.dart';
import '../flavors/environment.dart';
import '../utils/app_setting.dart';

class ApiRepository extends BaseProvider {
  static String baseAPIAuth = BuildConfig.instance.config.baseUrlAuthen;
  static String baseAPIUtility = BuildConfig.instance.config.baseUrlUtility;
  String urlGSMDev = 'https://gsmdev.cscmobicorp.com';
  String urlGSMProd = 'https://gsm.cscmobicorp.com';
  String GSMAppID = '69d63797e75be4583154138a';

  //Auth
  String urlLoginAPP = '$baseAPIAuth/user/getOtp';
  String urlVerifyOTP = '$baseAPIAuth/user/verifyOtp';
  String urlLogoutAPP = '$baseAPIAuth/user/logout';
  String urlRefreshToken = '$baseAPIAuth/user/refresh-token';
  String urlverifySubscription = '/api/iap/subcription/check';

  //Ultility
  String urlUploadAvatar = '$baseAPIUtility/fileUpload/uploadAvatar';

  // AI Features (từ Swagger config mới cung cấp)
  String urlCMSWeifuBase = 'https://app.cscmobicorp.com/waifuapi';
  // String urlCMSWeifuBase = 'http://20.198.254.31:7005';

  String get urlGetCategories => '$urlCMSWeifuBase/api/categories/';

  String get urlGetCharacters => '$urlCMSWeifuBase/api/characters/';

  String urlLogin = '/api/auth/login';
  String urlverifyIAP = '/api/economy/google-play/verify';

  String urlLoginWeifu = '/api/users/login';
  String urlGetProfileWeifu = '/api/users/profile';

  String get urlGetInteractionWeifu =>
      '$urlCMSWeifuBase/api/users/interactions/';

  ApiRepository() {
    timeout = const Duration(seconds: 60);
  }

  Future<Map<String, String>> _getWeifuHeaders() async {
    String deviceId = await AppUtil().getDeviceId();
    String lang = AppSetting.selectedLanguageCode;
    if (lang.isEmpty) {
      lang = Get.locale?.languageCode ?? 'en';
    }

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'x-device-id': deviceId,
      'Accept-Language': lang,
      'x-language': lang,
    };

    AppUtil.showLogFull("Weifu API Headers for Postman: $headers");

    return headers;
  }

  getBaseUrlGSM() {
    if (BuildConfig.instance.environment == Environment.PRODUCTION) {
      return urlGSMProd;
    } else {
      return urlGSMDev;
    }
  }

  requestGSMLogin() async {
    String appVersionName = await AppUtil().getAppVersion();
    /*
      1 : android
      2 : ios
    * */
    Map requestBody = {
      'appId': GSMAppID,
      'deviceId': await AppUtil().getDeviceId(),
      'pkName': Platform.isIOS
          ? 'com.aichat.chatbotai.lovechat'
          : 'com.aichat.chatbotai.lovechat',
      'os': Platform.isIOS ? 2 : 1,
      'version': appVersionName,
    };
    return await sendRequestPostGSM(getBaseUrlGSM() + urlLogin, requestBody);
  }

  sendRequestPostGSM(String url, dynamic requestBody) async {
    if (await checkNetwork()) {
      var finalURI = Uri.parse(url);
      String encodedBody = json.encode(requestBody);
      AppUtil.showLogFull(
          "ApiRepository sendRequestPostGSM encodedBody: $encodedBody");
      final res = await http
          .post(finalURI, body: encodedBody, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Connection': 'keep-alive',
        'Authorization': Constants.GSMAccessToken != null
            ? 'Bearer ${Constants.GSMAccessToken!}'
            : '',
      });
      try {
        if (res != null) {
          AppUtil.showLogFull(
              "ApiRepository _sendPost response: " + jsonEncode(res.body));
          if (res.statusCode == 200) {
            AppUtil.showLog("ApiRepository _sendPost statusCode 200");
            return res.body;
          } else {
            AppUtil.showLog(
                "ApiRepository _sendPost Không có dữ liệu: res.statusCode: ${res.statusCode}");
            return null;
          }
        } else {
          AppUtil.showLog("ApiRepository sendPost response: NULL");
        }
      } catch (e) {
        AppUtil.showLog("ApiRepository sendPost ERROR" + e.toString());
      }
      // AppUtil.showToast('msg_no_connection'.tr);
    }
  }

  Future<List<dynamic>> getCategoriesWeifu() async {
    if (await checkNetwork()) {
      try {
        final headers = await _getWeifuHeaders();
        AppUtil.showLogFull(
            'ApiRepository getCategoriesWeifu urlGetCategories: $urlGetCategories');
        final res =
            await http.get(Uri.parse(urlGetCategories), headers: headers);
        if (res.statusCode == 200) {
          // AppUtil.showLogFull('ApiRepository getCategoriesWeifu: ${res.body}');
          return jsonDecode(utf8.decode(res.bodyBytes));
        }
      } catch (e) {
        AppUtil.showLog('ApiRepository getCategoriesWeifu ERROR: $e');
      }
    }
    return [];
  }

  Future<List<dynamic>> getCharactersWeifu() async {
    if (await checkNetwork()) {
      try {
        final headers = await _getWeifuHeaders();
        // AppUtil.showLogFull('ApiRepository getCharactersWeifu urlGetCharacters: $urlGetCharacters');
        final res =
            await http.get(Uri.parse(urlGetCharacters), headers: headers);
        if (res.statusCode == 200) {
          // AppUtil.showLogFull('ApiRepository getCharactersWeifu: ${res.body}');
          return jsonDecode(utf8.decode(res.bodyBytes));
        }
      } catch (e) {
        AppUtil.showLog('ApiRepository getCharactersWeifu ERROR: $e');
      }
    }
    return [];
  }

  Future<List<dynamic>> getCharacterOutfits(String characterId) async {
    if (await checkNetwork()) {
      try {
        final headers = await _getWeifuHeaders();
        final res = await http.get(
            Uri.parse('$urlGetCharacters$characterId/outfits'),
            headers: headers);
        if (res.statusCode == 200) {
          return jsonDecode(utf8.decode(res.bodyBytes));
        }
      } catch (e) {
        AppUtil.showLog('ApiRepository getCharacterOutfits ERROR: $e');
      }
    }
    return [];
  }

  Future<List<dynamic>> getCharacterActions(String characterId) async {
    if (await checkNetwork()) {
      try {
        final headers = await _getWeifuHeaders();
        final res = await http.get(
            Uri.parse('$urlGetCharacters$characterId/actions'),
            headers: headers);
        if (res.statusCode == 200) {
          return jsonDecode(utf8.decode(res.bodyBytes));
        }
      } catch (e) {
        AppUtil.showLog('ApiRepository getCharacterActions ERROR: $e');
      }
    }
    return [];
  }

  Future<dynamic> useActionWeifu(String actionId) async {
    if (await checkNetwork()) {
      try {
        final headers = await _getWeifuHeaders();
        final body = jsonEncode({"item_id": actionId});
        final res = await http.post(
            Uri.parse('$urlCMSWeifuBase/api/economy/use-action'),
            headers: headers,
            body: body);
        if (res.statusCode == 200) {
          return jsonDecode(utf8.decode(res.bodyBytes));
        } else {
          AppUtil.showLog(
              'ApiRepository useActionWeifu Error: ${res.statusCode} ${res.body}');
        }
      } catch (e) {
        AppUtil.showLog('ApiRepository useActionWeifu ERROR: $e');
      }
    }
    return null;
  }

  Future<dynamic> useOutfitWeifu(String outfitId) async {
    if (await checkNetwork()) {
      try {
        final headers = await _getWeifuHeaders();
        final body = jsonEncode({"item_id": outfitId});
        final res = await http.post(
            Uri.parse('$urlCMSWeifuBase/api/economy/use-outfit'),
            headers: headers,
            body: body);
        if (res.statusCode == 200) {
          return jsonDecode(utf8.decode(res.bodyBytes));
        } else {
          AppUtil.showLog(
              'ApiRepository useOutfitWeifu Error: ${res.statusCode} ${res.body}');
        }
      } catch (e) {
        AppUtil.showLog('ApiRepository useOutfitWeifu ERROR: $e');
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> unlockCharacterCardWeifu({
    required String characterId,
    required String cardId,
  }) async {
    if (!await checkNetwork()) return null;
    try {
      final headers = await _getWeifuHeaders();
      final uri = Uri.parse(
          '$urlCMSWeifuBase/api/characters/$characterId/cards/$cardId/unlock');
      final res = await http.post(uri, headers: headers);
      AppUtil.showLogFull(
          'unlockCharacterCardWeifu status=${res.statusCode} body=${res.body}');
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      AppUtil.showLog('ApiRepository unlockCharacterCardWeifu ERROR: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> claimAdsRewardWeifu({
    required String rewardId,
  }) async {
    if (!await checkNetwork()) return null;
    try {
      final headers = await _getWeifuHeaders();
      final bodyMap = {'reward_id': rewardId};
      final body = jsonEncode(bodyMap);
      final uri = Uri.parse('$urlCMSWeifuBase/api/economy/ads-reward/claim');
      final res = await http.post(uri, headers: headers, body: body);
      AppUtil.showLogFull(
          'claimAdsRewardWeifu request body=$body status=${res.statusCode} response=${res.body}');
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      AppUtil.showLog('ApiRepository claimAdsRewardWeifu ERROR: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> dailyCheckinStatusWeifu() async {
    if (!await checkNetwork()) return null;
    try {
      final headers = await _getWeifuHeaders();
      final uri =
          Uri.parse('$urlCMSWeifuBase/api/economy/daily-checkin/status');
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      AppUtil.showLog('ApiRepository dailyCheckinStatusWeifu ERROR: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> dailyCheckinWeifu({
    required int dayIndex,
  }) async {
    if (!await checkNetwork()) return null;
    try {
      final headers = await _getWeifuHeaders();
      final uri = Uri.parse('$urlCMSWeifuBase/api/economy/daily-checkin');
      final res = await http.post(uri, headers: headers);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      AppUtil.showLog('ApiRepository dailyCheckinWeifu ERROR: $e');
    }
    return null;
  }

  Future<dynamic> loginWeifu({String? firebaseToken}) async {
    if (await checkNetwork()) {
      try {
        String deviceId = await AppUtil().getDeviceId();
        Map<String, dynamic> body = {
          "device_id": deviceId,
        };
        if (firebaseToken != null && firebaseToken.isNotEmpty) {
          body['firebase_token'] = firebaseToken;
        }

        final res = await http.post(
          Uri.parse('$urlCMSWeifuBase$urlLoginWeifu'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(body),
        );
        if (res.statusCode == 200) {
          return jsonDecode(utf8.decode(res.bodyBytes));
        } else {
          AppUtil.showLogFull(
              "loginWeifu FAILED: statusCode ${res.statusCode}");
          AppUtil.showLogFull("loginWeifu BODY: ${res.body}");
          throw Exception("API returned ${res.statusCode}: ${res.body}");
        }
      } catch (e) {
        AppUtil.showLog('ApiRepository loginWeifu ERROR: $e');
        rethrow; // Rethrow to let Controller catch it
      }
    }
    return null;
  }

  Future<dynamic> getProfileWeifu() async {
    if (await checkNetwork()) {
      try {
        final headers = await _getWeifuHeaders();
        final res = await http.get(
            Uri.parse('$urlCMSWeifuBase$urlGetProfileWeifu'),
            headers: headers);
        if (res.statusCode == 200) {
          return jsonDecode(utf8.decode(res.bodyBytes));
        }
      } catch (e) {
        AppUtil.showLog('ApiRepository getProfileWeifu ERROR: $e');
      }
    }
    return null;
  }

  static String mapToBackendProductId(String productId) {
    final lower = productId.toLowerCase().trim();
    if (lower.contains('p01')) return 'waifu-coin-p01';
    if (lower.contains('p02')) return 'waifu-coin-p02';
    if (lower.contains('p03')) return 'waifu-coin-p03';
    if (lower.contains('p04')) return 'waifu-coin-p04';
    if (lower.contains('p05')) return 'waifu-coin-p05';
    if (lower.contains('p06')) return 'waifu-coin-p06';
    if (lower.contains('m01')) return 'waifu.sub.m01';
    if (lower.contains('y01.sale') || lower.contains('y01_sale') || lower.contains('y01-sale')) {
      return 'waifu.sub.y01.sale';
    }
    if (lower.contains('y01')) return 'waifu.sub.y01';
    return productId;
  }

  /// Xác thực purchase với backend Weifu (Swagger: `product_id`, `product_type` + header `x-device-id`).
  Future<Map<String, dynamic>?> verifyPurchaseWeifu({
    required String productId,
    required String productType,
  }) async {
    if (!await checkNetwork()) return null;
    try {
      final headers = await _getWeifuHeaders();
      final targetProductId = mapToBackendProductId(productId);
      final requestMap = {
        'product_id': targetProductId,
        'product_type': productType,
      };
      final body = jsonEncode(requestMap);
      final uri = Uri.parse('$urlCMSWeifuBase$urlverifyIAP');
      final curl = "curl -X POST '$uri' "
          "-H 'Content-Type: application/json; charset=UTF-8' "
          "-H 'x-device-id: ${headers['x-device-id'] ?? ''}' "
          "-d '${jsonEncode(requestMap)}'";
      AppUtil.showLogFull(
          'verifyPurchaseWeifu request => url=$uri headers=$headers body=$body originalProductId=$productId mappedProductId=$targetProductId product_type=$productType');
      AppUtil.showLogFull('verifyPurchaseWeifu curl => $curl');
      final res = await http.post(uri, headers: headers, body: body);
      AppUtil.showLogFull(
          'verifyPurchaseWeifu status=${res.statusCode} body=${res.body}');
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      AppUtil.showLog('ApiRepository verifyPurchaseWeifu ERROR: $e');
    }
    return null;
  }

  Future<dynamic> getCharacterInteractionWeifu(String characterId) async {
    if (await checkNetwork()) {
      try {
        final headers = await _getWeifuHeaders();
        final res = await http.get(
            Uri.parse('$urlGetInteractionWeifu$characterId'),
            headers: headers);
        if (res.statusCode == 200) {
          return jsonDecode(utf8.decode(res.bodyBytes));
        } else {
          AppUtil.showLogFull(
              "getInteractionWeifu FAILED: statusCode ${res.statusCode}");
        }
      } catch (e) {
        AppUtil.showLog('ApiRepository getInteractionWeifu ERROR: $e');
      }
    }
    return null;
  }

  String _getLanguagePromptName(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'vi':
        return 'Vietnamese (tiếng Việt)';
      case 'en':
        return 'English';
      case 'fr':
        return 'French (Français)';
      case 'es':
        return 'Spanish (Español)';
      case 'de':
        return 'German (Deutsch)';
      case 'id':
        return 'Indonesian (Bahasa Indonesia)';
      case 'pt':
        return 'Portuguese (Português)';
      case 'ru':
        return 'Russian (Русский)';
      case 'tr':
        return 'Turkish (Türkçe)';
      case 'hi':
        return 'Hindi (हिन्दी)';
      case 'bn':
        return 'Bengali (বাংলা)';
      case 'ar':
        return 'Arabic (العربية)';
      case 'fil':
        return 'Filipino (Tagalog)';
      case 'ja':
        return 'Japanese (日本語)';
      case 'ko':
        return 'Korean (한국어)';
      case 'it':
        return 'Italian (Italiano)';
      default:
        return 'the user\'s selected language ($langCode)';
    }
  }

  Stream<String> sendChatMessageWeifu(String characterId,
      List<Map<String, dynamic>> history, String message) async* {
    if (await checkNetwork()) {
      try {
        final headers = await _getWeifuHeaders();
        String langCode = AppSetting.selectedLanguageCode;
        if (langCode.isEmpty) {
          langCode = Get.locale?.languageCode ?? 'en';
        }
        final langPrompt = _getLanguagePromptName(langCode);

        final List<Map<String, dynamic>> enrichedHistory = [
          {
            'role': 'system',
            'content':
                'CRITICAL INSTRUCTION: You must respond exclusively in $langPrompt. Both dialogue and actions must be in $langPrompt. Stay strictly in character.',
          },
          ...history.where((m) => m['role'] != 'system'),
        ];

        final body = {
          "character_id": characterId,
          "history": enrichedHistory,
          "message": message,
          "language": langCode,
        };

        final request =
            http.Request('POST', Uri.parse('$urlCMSWeifuBase/api/chat/'));
        request.headers.addAll(headers);
        request.body = jsonEncode(body);

        final response = await http.Client().send(request);
        // try {
        //   // 2. Đọc stream từ response và chuyển đổi thành String
        //   final responseString = await response.stream.bytesToString();
        //
        //   // 3. In kết quả ra log
        //   AppUtil.showLogFull('--- API RESPONSE ---');
        //   AppUtil.showLogFull('sendChatMessageWeifu Status Code: ${response.statusCode}');
        //   AppUtil.showLogFull('sendChatMessageWeifu Body: $responseString');
        // } catch (e) {
        //   AppUtil.showLogFull('Exception: $e');
        // }
        if (response.statusCode == 200 || response.statusCode == 201) {
          /*  try {
            if (Get.isRegistered<ChatDetailController>()) {
              ChatDetailController chatDetailController = Get.find();
              //Cứ thành công trừ đi 1 gem , Lần đầu về 0 Gem sẽ bắn ra thông báo luôn => xử lý tạm đã.
              final currentGems = chatDetailController.profileController.currentUser.value?.gems ?? 0;

              AppUtil.showLogFull("sendChatMessageWeifu currentGems: $currentGems");
              if (currentGems > 1) {
                chatDetailController.profileController.currentUser.value?.gems = currentGems - 1;
                if (chatDetailController.profileController.currentUser.value?.gems == 0) {
                  //Cần làm multi language khi có thời gian
                  AppUtil.showToastError('You just used your last gem.');
                }
                chatDetailController.update();
                AppUtil.showLogFull("sendChatMessageWeifu final profileController.currentUser.value?.gems: $chatDetailController.profileController.currentUser.value?.gems");
              }
            }
          } catch (e) {
            AppUtil.showLogFull('Exception: $e');
          }*/

          final stream = response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter());
          await for (var line in stream) {
            if (line.startsWith('data: ')) {
              final dataStr = line.substring(6).trim();
              if (dataStr == '[DONE]') break;
              if (dataStr.isNotEmpty) {
                try {
                  final data = jsonDecode(dataStr);
                  if (data['chunk'] != null) {
                    yield data['chunk'].toString();
                  }
                } catch (e) {
                  // ignore JSON parse errors on incomplete chunks if any
                }
              }
            }
          }
        } else {
          AppUtil.showLogFull(
              "sendChatMessageWeifu FAILED: statusCode \${response.statusCode}");
        }
      } catch (e) {
        AppUtil.showLog('ApiRepository sendChatMessageWeifu ERROR: $e');
      }
    }
  }

  Future<bool> checkNetwork() async {
    bool isConnected = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (_) {
      isConnected = false;
    }
    return isConnected;
  }

  requestGSMVerifySubscription({
    required String purchaseToken,
    required String productId,
    required String productName,
  }) async {
    String? adjustADID = '';
    try {
      adjustADID = await Adjust.getAdid();
    } catch (ex) {
      AppUtil.showLog(
          'requestGSMVerifyOTP getFaceBookKeyHash fail: ${ex.toString()}');
    }
    Map requestBody = {
      'packageName': Platform.isIOS
          ? 'com.aichat.chatbotai.lovechat'
          : 'com.aichat.chatbotai.lovechat',
      'purchaseToken': purchaseToken,
      'productId': productId,
      'productName': productName,
      'keyhash': '',
      'rechargePoint': "1",
      'adid': adjustADID ?? '',
      'userType': '0',
    };
    return await sendRequestPostGSM(
        getBaseUrlGSM() + urlverifySubscription, requestBody);
  }
}
