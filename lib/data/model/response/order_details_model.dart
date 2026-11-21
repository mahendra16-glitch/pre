import 'package:mygenie_restaurant/data/model/response/product_model.dart';

class OrderDetailsModel {
  int? id;
  int? foodId;
  int? orderId;
  double? price;
  Product? foodDetails;
  List<Variations>? variation;
  List<OldVariation>? oldVariation;
  List<AddOn>? addOns;
  double? discountOnFood;
  String? discountType;
  int? quantity;
  double? taxAmount;
  String? variant;
  String? createdAt;
  String? updatedAt;
  int? itemCampaignId;
  double? totalAddOnPrice;

  OrderDetailsModel({
    this.id,
    this.foodId,
    this.orderId,
    this.price,
    this.foodDetails,
    this.variation,
    this.oldVariation,
    this.addOns,
    this.discountOnFood,
    this.discountType,
    this.quantity,
    this.taxAmount,
    this.variant,
    this.createdAt,
    this.updatedAt,
    this.itemCampaignId,
    this.totalAddOnPrice,
  });

  OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    foodId = json['food_id'];
    orderId = json['order_id'];
    price = (json['price'] as num?)?.toDouble();
    foodDetails = json['food_details'] != null
        ? Product.fromJson(json['food_details'])
        : null;
    variation = <Variations>[];
    oldVariation = <OldVariation>[];
    if (json['variation'] != null && (json['variation'] as List).isNotEmpty) {
      if ((json['variation'][0] as Map<String, dynamic>)['values'] != null) {
        for (var v in json['variation']) {
          variation!.add(Variations.fromJson(v));
        }
      } else {
        for (var v in json['variation']) {
          oldVariation!.add(OldVariation.fromJson(v));
        }
      }
    }
    if (json['add_ons'] != null) {
      addOns = <AddOn>[];
      for (var v in json['add_ons']) {
        addOns!.add(AddOn.fromJson(v));
      }
    }
    discountOnFood = (json['discount_on_food'] as num?)?.toDouble();
    discountType = json['discount_type'];
    quantity = json['quantity'];
    taxAmount = (json['tax_amount'] as num?)?.toDouble();
    variant = json['variant'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    itemCampaignId = json['item_campaign_id'];
    totalAddOnPrice = (json['total_add_on_price'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['food_id'] = foodId;
    data['order_id'] = orderId;
    data['price'] = price;
    if (foodDetails != null) {
      data['food_details'] = foodDetails!.toJson();
    }
    if (variation != null) {
      data['variation'] = variation!.map((v) => v.toJson()).toList();
    }
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    data['discount_on_food'] = discountOnFood;
    data['discount_type'] = discountType;
    data['quantity'] = quantity;
    data['tax_amount'] = taxAmount;
    data['variant'] = variant;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['item_campaign_id'] = itemCampaignId;
    data['total_add_on_price'] = totalAddOnPrice;
    return data;
  }
}

class AddOn {
  String? name;
  double? price;
  int? quantity;

  AddOn({this.name, this.price, this.quantity});

  AddOn.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        price = (json['price'] as num?)?.toDouble(),
        quantity = int.tryParse(json['quantity'].toString());

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    data['quantity'] = quantity;
    return data;
  }
}

class OldVariation {
  String? type;
  double? price;

  OldVariation({this.type, this.price});

  OldVariation.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        price = (json['price'] as num?)?.toDouble();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['price'] = price;
    return data;
  }
}
