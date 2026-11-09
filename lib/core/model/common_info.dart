class CommonInfo {
  String id;
  String code;
  String name;
  String startTime = '';
  String svgAsset;

  CommonInfo(this.id, this.name, this.code, {this.svgAsset = ''});

  CommonInfo.fromJsonMap(Map<String, dynamic> map)
      : id = map['id'] ?? '',
        code = map['code'] ?? '',
        name = map['name'] ?? '',
        startTime = map['startTime'] ?? '',
        svgAsset = map['svgAsset'] ?? '';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    data['startTime'] = startTime;
    data['svgAsset'] = svgAsset;
    return data;
  }
}
