
import '../../values/constants.dart';

class ResponseData {
  String message = '';
  int status = Constants.RESPONSE_STATUS_FAIL;
  String code = '';
  dynamic data;

  ResponseData();

  ResponseData.fromJson(Map<String, dynamic> map)
      : status = map['status'] ?? 0,
        code = map['code'] ?? '',
        message = map['message'] ?? '',
        data = map.containsKey("data") && map['data'] != null ? map['data'] : null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['code'] = code;
    data['message'] = message;
    data['data'] = data;
    return data;
  }
}
