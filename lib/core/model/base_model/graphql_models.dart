class SortedInput {
  String id;
  bool desc;

  SortedInput(this.id, this.desc);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'desc': desc,
    };
  }
}

class FilteredInput {
  String id;
  dynamic value;
  String operation;

  FilteredInput(this.id, this.value, this.operation);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'operation': operation,
    };
  }
}
