class OrderVariation {
  String? name;
  OrderVariationValue? values;

  OrderVariation({this.name, this.values});

  OrderVariation.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String?,
        values = json['values'] != null
            ? OrderVariationValue.fromJson(
                json['values'] as Map<String, dynamic>)
            : null;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    if (values != null) {
      data['values'] = values!.toJson();
    }
    return data;
  }
}

class OrderVariationValue {
  List<String>? label;

  OrderVariationValue({this.label});

  OrderVariationValue.fromJson(Map<String, dynamic> json)
      : label =
            (json['label'] as List<dynamic>?)?.map((e) => e as String).toList();

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['label'] = label;
    return data;
  }
}
