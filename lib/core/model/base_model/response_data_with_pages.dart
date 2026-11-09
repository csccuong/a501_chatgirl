import '../../values/constants.dart';

class ResponseDataWithPages {
  String message = '';
  int status = Constants.RESPONSE_STATUS_FAIL;
  String code = '';
  dynamic data;
  int records = 0;
  int pages = 0;
  double averageRating = 0;
  String extra = '';

  ResponseDataWithPages();

  ResponseDataWithPages.fromJson(Map<String, dynamic> map)
      : status = map['status'] ?? 0,
        code = map['code'] ?? '',
        message = map['message'] ?? '',
        data = map.containsKey("data") && map['data'] != null ? map['data'] : null,
        records = map['records'] ?? 0,
        averageRating = map['averageRating'] ?? 0,
        pages = map['pages'] ?? 0,
        extra = map['extra'] ?? '';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['code'] = code;
    data['data'] = data;
    data['records'] = records;
    data['averageRating'] = averageRating;
    data['pages'] = pages;
    data['extra'] = extra;
    return data;
  }
}
