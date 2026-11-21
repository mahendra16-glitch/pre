import 'package:flutter/material.dart';

class ProductModel {
  final int? totalSize;
  final String? limit;
  final String? offset;
  final List<Product>? products;

  ProductModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.products,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      totalSize: json['total_size'] as int?,
      limit: json['limit']?.toString(),
      offset: json['offset']?.toString(),
      products: (json['products'] as List<dynamic>?)
          ?.map((v) => Product.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_size': totalSize,
      'limit': limit,
      'offset': offset,
      'products': products?.map((v) => v.toJson()).toList(),
    };
  }
}

class Product {
  int? id;
  bool? isAddFirstTime;
  String? name;
  String? itemCode;
  String? description;
  String? image;
  int? categoryId;
  List<CategoryIds>? categoryIds;
  List<String>? mainCategoryId;
  List<Variations>? variations;
  List<AddOns>? addOns;
  // List<int>? attributes;
  // List<ChoiceOptions>? choiceOptions;
  double? price;
  double? takeAwayFoodPrice;
  double? deliveryFoodPrice;
  double? tax;
  String? taxType;
  String? taxCalculate;
  dynamic discount;
  String? discountType;
  String? availableTimeStarts;
  String? availableTimeEnds;
  int? setMenu;
  int? status;
  int? restaurantId;
  String? createdAt;
  String? updatedAt;
  String? restaurantName;
  dynamic restaurantDiscount;
  String? giveDiscount;
  bool? scheduleOrder;
  double? avgRating;
  int? ratingCount;
  int? veg;
  List<Translation>? translations;
  String? stationName;
  List<Tag>? tags;
  int? recommendedStatus;
  double? qty;
  String? foodFor;
  String? isInventory;
  // TextEditingController? qtyController = TextEditingController();

  Product({
    this.id,
    this.name,
    this.isAddFirstTime,
    this.itemCode,
    this.description,
    this.image,
    this.categoryId,
    this.categoryIds,
    this.mainCategoryId,
    this.variations,
    this.addOns,
    // this.attributes,
    // this.choiceOptions,
    this.price,
    this.takeAwayFoodPrice,
    this.deliveryFoodPrice,
    this.tax,
    this.taxType,
    this.taxCalculate,
    this.discount,
    this.discountType,
    this.availableTimeStarts,
    this.availableTimeEnds,
    this.setMenu,
    this.status,
    this.restaurantId,
    this.createdAt,
    this.updatedAt,
    this.restaurantName,
    this.restaurantDiscount,
    this.giveDiscount,
    this.scheduleOrder,
    this.avgRating,
    this.ratingCount,
    this.veg,
    this.translations,
    this.stationName,
    this.tags,
    this.recommendedStatus,
    this.qty,
    this.foodFor,
    this.isInventory,
    // this.qtyController,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isAddFirstTime = true;
    name = json['name']?.toString().toUpperCase();
    itemCode = json['item_code']?.toString().toUpperCase();
    description = '';
    // description = json['description'] ?? '';
    image = json['image'];
    categoryId = json['category_id'];
    giveDiscount = json['give_discount'] ?? 'Yes';
    foodFor = json['food_for'] ?? 'Normal';
    // qtyController = TextEditingController();
    stationName = '';

    if (json.containsKey('station_name')) {
      stationName = json['station_name'] ?? '';
    }
    qty = 0;
    if (json['category_ids'] != null) {
      categoryIds = <CategoryIds>[];
      mainCategoryId = <String>[];
      for (var v in json['category_ids']) {
        mainCategoryId!.add(v['id'].toString());
        categoryIds!.add(CategoryIds.fromJson(v));
      }
    }
    if (json['variations'] != null) {
      variations = <Variations>[];
      for (var v in json['variations']) {
        variations!.add(Variations.fromJson(v));
      }
      // if (variations!.isNotEmpty) {
      //   variations!.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      // }
    }
    if (json['add_ons'] != null) {
      addOns = <AddOns>[];
      for (var v in json['add_ons']) {
        addOns!.add(AddOns.fromJson(v));
      }
      if (addOns!.isNotEmpty) {
        addOns!.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      }
    }
    // attributes
    // if (json['attributes'] != null) {
    //   attributes = <int>[];
    //   for (var attr in json['attributes']) {
    //     attributes!.add(int.tryParse(attr.toString()) ?? 0);
    //   }
    // }
    // choiceOptions
    // if (json['choice_options'] != null) {
    //   choiceOptions = <ChoiceOptions>[];
    //   for (var v in json['choice_options']) {
    //     choiceOptions!.add(ChoiceOptions.fromJson(v));
    //   }
    // } else {
    //   choiceOptions = <ChoiceOptions>[];
    // }
    price = json['price'] == null ? 0 : (json['price'] as num).toDouble();
    takeAwayFoodPrice = json['takeaway_charge'] == null
        ? 0
        : double.parse('${json['takeaway_charge']}');
    deliveryFoodPrice = json['delivery_charge'] == null
        ? 0
        : double.parse('${json['delivery_charge']}');
    tax = json['tax'] != null ? (json['tax'] as num).toDouble() : null;
    discount =
        json['discount'] == null ? 0 : (json['discount'] as num).toDouble();
    discountType = json['discount_type'];
    taxType = json['tax_type'];
    taxCalculate = 'Exclusive';
    availableTimeStarts = json['available_time_starts'];
    availableTimeEnds = json['available_time_ends'];
    setMenu = json['set_menu'];
    status = json['status'];
    restaurantId = json['restaurant_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    restaurantName = json['restaurant_name'];
    restaurantDiscount = json['restaurant_discount'];
    scheduleOrder = json['schedule_order'];
    avgRating =
        json['avg_rating'] == null ? 0 : (json['avg_rating'] as num).toDouble();
    ratingCount = json['rating_count'];
    veg = json['veg'];
    if (json['translations'] != null) {
      translations = <Translation>[];
      for (var v in json['translations']) {
        translations!.add(Translation.fromJson(v));
      }
    }
    if (json['tags'] != null) {
      tags = <Tag>[];
      for (var v in json['tags']) {
        tags!.add(Tag.fromJson(v));
      }
    }
    recommendedStatus = json['recommended'];
    isInventory = json['is_inventory'];
  }

  factory Product.fromSocketJson(
    Map<String, dynamic> json,
  ) {
    Product product = Product();

    product.id = json['id'];

    product.name = json['name']?.toString().toUpperCase();

    product.itemCode = json['item_code']?.toString();

    product.price = double.tryParse('${json['price']}') ?? 0;

    product.tax = double.tryParse('${json['tax']}') ?? 0;

    product.discount = double.tryParse('${json['discount']}') ?? 0;

    product.taxType = json['tax_type']?.toString();

    product.discountType = json['discount_type']?.toString();

    product.stationName = json['station_name']?.toString();

    product.foodFor = json['food_for']?.toString();

    product.giveDiscount = json['give_discount']?.toString();

    product.isInventory = json['is_inventory']?.toString();

    product.availableTimeStarts = json['available_time_starts']?.toString();

    product.availableTimeEnds = json['available_time_ends']?.toString();

    product.takeAwayFoodPrice = double.tryParse(
          '${json['takeaway_charge']}',
        ) ??
        0;

    product.deliveryFoodPrice = double.tryParse(
          '${json['delivery_charge']}',
        ) ??
        0;

    product.image = json['image']?.toString();

    product.veg = json['veg'];

    product.status = json['status'];

    if (json['variations'] != null) {
      product.variations = [];

      for (var v in json['variations']) {
        product.variations!.add(
          Variations.fromJson(v),
        );
      }

      // if (product.variations!.isNotEmpty) {
      //   product.variations!.sort(
      //     (a, b) => (a.name ?? '').compareTo(
      //       b.name ?? '',
      //     ),
      //   );
      // }
    }

    if (json['add_ons'] != null) {
      product.addOns = [];

      for (var v in json['add_ons']) {
        product.addOns!.add(
          AddOns.fromJson(v),
        );
      }

      if (product.addOns!.isNotEmpty) {
        product.addOns!.sort(
          (a, b) => (a.name ?? '').compareTo(
            b.name ?? '',
          ),
        );
      }
    }

    return product;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['item_code'] = itemCode;
    data['description'] = description;
    data['station_name'] = stationName;
    data['image'] = image;
    data['category_id'] = categoryId;
    if (categoryIds != null) {
      data['category_ids'] = categoryIds!.map((v) => v.toJson()).toList();
    }
    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    // data['attributes'] = attributes;
    // if (choiceOptions != null) {
    //   data['choice_options'] = choiceOptions!.map((v) => v.toJson()).toList();
    // }
    data['price'] = price;
    data['delivery_charge'] = deliveryFoodPrice;
    data['takeaway_charge'] = takeAwayFoodPrice;
    data['food_for'] = foodFor;
    data['tax'] = tax;
    data['tax_type'] = taxType;
    data['tax_calc'] = taxCalculate;
    data['give_discount'] = giveDiscount;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['available_time_starts'] = availableTimeStarts;
    data['available_time_ends'] = availableTimeEnds;
    data['set_menu'] = setMenu;
    data['status'] = status;
    data['restaurant_id'] = restaurantId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['restaurant_name'] = restaurantName;
    data['restaurant_discount'] = restaurantDiscount;
    data['schedule_order'] = scheduleOrder;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['recommended'] = recommendedStatus;
    data['veg'] = veg;
    data['is_inventory'] = isInventory;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    if (tags != null) {
      data['tags'] = tags!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  void applySocketUpdate(Map<String, dynamic> json) {
    name = json['name']?.toString().toUpperCase() ?? name;

    itemCode = json['item_code']?.toString().toUpperCase() ?? itemCode;

    stationName = json['station_name']?.toString() ?? stationName;

    foodFor = json['food_for']?.toString() ?? foodFor;

    giveDiscount = json['give_discount']?.toString() ?? giveDiscount;

    isInventory = json['is_inventory']?.toString() ?? isInventory;

    availableTimeStarts =
        json['available_time_starts']?.toString() ?? availableTimeStarts;

    availableTimeEnds =
        json['available_time_ends']?.toString() ?? availableTimeEnds;

    image = json['image']?.toString() ?? image;

    veg = json['veg'];

    status = json['status'];

    price = double.tryParse('${json['price']}') ?? price;

    tax = double.tryParse('${json['tax']}') ?? tax;

    discount = double.tryParse('${json['discount']}') ?? discount;

    takeAwayFoodPrice =
        double.tryParse('${json['takeaway_charge']}') ?? takeAwayFoodPrice;

    deliveryFoodPrice =
        double.tryParse('${json['delivery_charge']}') ?? deliveryFoodPrice;

    taxType = json['tax_type']?.toString() ?? taxType;

    discountType = json['discount_type']?.toString() ?? discountType;

    if (json['variations'] != null) {
      variations = [];

      for (var v in json['variations']) {
        variations!.add(
          Variations.fromJson(v),
        );
      }

      // if (variations!.isNotEmpty) {
      //   variations!.sort(
      //     (a, b) => (a.name ?? '').compareTo(
      //       b.name ?? '',
      //     ),
      //   );
      // }
    }

    if (json['add_ons'] != null) {
      addOns = [];

      for (var v in json['add_ons']) {
        addOns!.add(
          AddOns.fromJson(v),
        );
      }

      if (addOns!.isNotEmpty) {
        addOns!.sort(
          (a, b) => (a.name ?? '').compareTo(
            b.name ?? '',
          ),
        );
      }
    }
  }
}

class CategoryIds {
  String? id;

  CategoryIds({this.id});

  CategoryIds.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    return data;
  }
}

class Variations {
  String? name;
  String? type;
  String? min;
  String? max;
  String? required;
  List<VariationOption>? values;

  Variations({
    this.name,
    this.type,
    this.min,
    this.max,
    this.required,
    this.values,
  });

  Variations.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString().toUpperCase();
    type = json['type'];
    min = json['min']?.toString();
    max = json['max']?.toString();
    required = json['required'];
    if (json['values'] != null) {
      values = <VariationOption>[];
      for (var v in json['values']) {
        values!.add(VariationOption.fromJson(v));
      }
      // values!.sort((a, b) => (a.level ?? '').compareTo(b.level ?? ''));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    data['min'] = min;
    data['max'] = max;
    data['required'] = required;
    if (values != null) {
      data['values'] = values!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VariationOption {
  String? level;
  String? optionPrice;

  VariationOption({this.level, this.optionPrice});

  VariationOption.fromJson(Map<String, dynamic> json) {
    level = json['label']?.toString().toUpperCase();
    optionPrice = json['optionPrice']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = level;
    data['optionPrice'] = optionPrice;
    return data;
  }
}

class AddOns {
  int? id;
  String? name;
  int? qty;
  double? price;
  int? status;
  int? restaurantId;
  List<Translation>? translations;

  AddOns({
    this.id,
    this.name,
    this.qty,
    this.price,
    this.status,
    this.restaurantId,
    this.translations,
  });

  AddOns.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString().toUpperCase();
    qty = json['quantity'];
    price = json['price'] != null ? (json['price'] as num).toDouble() : null;
    status = json['status'];
    restaurantId = json['restaurant_id'];
    if (json['translations'] != null) {
      translations = <Translation>[];
      json['translations'].forEach((v) {
        translations!.add(Translation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['quantity'] = qty;
    data['status'] = status;
    if (restaurantId != null) {
      data['restaurant_id'] = restaurantId;
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// class ChoiceOptions {
//   String? name;
//   String? title;
//   List<String>? options;

//   ChoiceOptions({this.name, this.title, this.options});

//   ChoiceOptions.fromJson(Map<String, dynamic> json) {
//     name = json['name'];
//     title = json['title'];
//     if (json['options'] != null) {
//       options = List<String>.from(json['options']);
//     } else {
//       options = [];
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['name'] = name;
//     data['title'] = title;
//     data['options'] = options;
//     return data;
//   }
// }

class Translation {
  int? id;
  String? locale;
  String? key;
  String? value;

  Translation({this.id, this.locale, this.key, this.value});

  Translation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    locale = json['locale'];
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['locale'] = locale;
    data['key'] = key;
    data['value'] = value;
    return data;
  }
}

class Tag {
  int? id;
  String? tag;

  Tag({this.id, this.tag});

  Tag.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tag = json['tag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['tag'] = tag;
    return data;
  }
}
