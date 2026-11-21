class AddonListModel {
  List<Addons> addons;

  AddonListModel({required this.addons});

  factory AddonListModel.fromJson(Map<String, dynamic> json) {
    return AddonListModel(
      addons: (json['addons'] as List<dynamic>?)
              ?.map((v) => Addons.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addons': addons.map((v) => v.toJson()).toList(),
    };
  }
}

class Addons {
  int id;
  String name;
  double price;
  bool addonCheck;

  Addons({
    required this.id,
    required this.name,
    required this.price,
    required this.addonCheck,
  });

  factory Addons.fromJson(Map<String, dynamic> json) {
    return Addons(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] as num).toDouble(),
      addonCheck: json['addonCheck'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'addonCheck': addonCheck,
    };
  }
}
