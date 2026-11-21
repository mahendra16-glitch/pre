class MenuFoodListModel {
  List<Foods>? foods;

  MenuFoodListModel({this.foods});

  MenuFoodListModel.fromJson(Map<String, dynamic> json) {
    if (json['foods'] != null) {
      foods = <Foods>[];
      json['foods'].forEach((v) {
        foods!.add(Foods.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (foods != null) {
      data['foods'] = foods!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Foods {
  int? id;
  String? name;
  Category? category;
  int? price;
  int? itemType;
  String? foodFor;
  String? discountType;
  int? discount;
  String? availableTimeStarts;
  String? availableTimeEnds;
  int? foodOrder;
  int? preprationTimeMin;
  int? serveTimeMin;
  String? dinein;
  String? delivery;
  String? takeaway;
  List<Variation>? variation;
  Addonss? addons;

  Foods({
    this.id,
    this.name,
    this.category,
    this.price,
    this.itemType,
    this.foodFor,
    this.discountType,
    this.discount,
    this.availableTimeStarts,
    this.availableTimeEnds,
    this.foodOrder,
    this.preprationTimeMin,
    this.serveTimeMin,
    this.dinein,
    this.delivery,
    this.takeaway,
    this.variation,
    this.addons,
  });

  Foods.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    category =
        json['category'] != null ? Category.fromJson(json['category']) : null;
    price = json['price'];
    itemType = json['item_type'];
    foodFor = json['food_for'];
    discountType = json['discount_type'];
    discount = json['discount'];
    availableTimeStarts = json['available_time_starts'];
    availableTimeEnds = json['available_time_ends'];
    foodOrder = json['food_order'];
    preprationTimeMin = json['prepration_time_min'];
    serveTimeMin = json['serve_time_min'];
    dinein = json['dinein'];
    delivery = json['delivery'];
    takeaway = json['takeaway'];
    if (json['variation'] != null) {
      variation = <Variation>[];
      json['variation'].forEach((v) {
        variation!.add(Variation.fromJson(v));
      });
    }
    addons = json['addons'] != null ? Addonss.fromJson(json['addons']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    data['price'] = price;
    data['item_type'] = itemType;
    data['food_for'] = foodFor;
    data['discount_type'] = discountType;
    data['discount'] = discount;
    data['available_time_starts'] = availableTimeStarts;
    data['available_time_ends'] = availableTimeEnds;
    data['food_order'] = foodOrder;
    data['prepration_time_min'] = preprationTimeMin;
    data['serve_time_min'] = serveTimeMin;
    data['dinein'] = dinein;
    data['delivery'] = delivery;
    data['takeaway'] = takeaway;
    if (variation != null) {
      data['variation'] = variation!.map((v) => v.toJson()).toList();
    }
    if (addons != null) {
      data['addons'] = addons!.toJson();
    }
    return data;
  }
}

class Category {
  int? id;
  String? name;

  Category({this.id, this.name});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class Variation {
  String? name;
  String? type;
  String? required;
  List<Values>? values;

  Variation({this.name, this.type, this.required, this.values});

  Variation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    required = json['required'];
    if (json['values'] != null) {
      values = <Values>[];
      json['values'].forEach((v) {
        values!.add(Values.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    data['required'] = required;
    if (values != null) {
      data['values'] = values!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Values {
  String? label;
  String? optionPrice;

  Values({this.label, this.optionPrice});

  Values.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    optionPrice = json['optionPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    data['optionPrice'] = optionPrice;
    return data;
  }
}

class Addonss {
  List<int>? id;
  String? name;

  Addonss({this.id, this.name});

  Addonss.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? List<int>.from(json['id']) : null;
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
