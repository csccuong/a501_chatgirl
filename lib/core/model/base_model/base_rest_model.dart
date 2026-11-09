class BaseRestModel {
  int status = 1;
  String code = '';
  String message = '';
  dynamic data;

  BaseRestModel();

  BaseRestModel.fromJsonMap(Map<String, dynamic> map)
      : status = map['status'] ?? 0,
        code = map['code'] ?? '',
        message = map['message'] ?? '',
        data = map.containsKey("data") && map['data'] != null ? map['data'] : null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['code;'] = code;
    data['message'] = message;
    data['data'] = data;
    return data;
  }
}
