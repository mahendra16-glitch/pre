import 'package:mygenie_restaurant/data/model/response/product_model.dart';

class CartModel {
  double price;
  double adjustPrice;
  double discountedPrice;
  List<List<bool>> variation;
  double quantity;
  List<AddOn> addOnIds;
  List<AddOns> addOns;
  bool isComplementry;
  Product product;
  String? foodNote;
  String? isInventory;

  CartModel({
    required this.price,
    required this.adjustPrice,
    required this.discountedPrice,
    required this.variation,
    required this.quantity,
    required this.addOnIds,
    required this.addOns,
    this.isComplementry = false,
    required this.product,
    this.foodNote,
    this.isInventory,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      price: (json['price'] ?? 0).toDouble(),
      adjustPrice: 1,
      discountedPrice: (json['discounted_price'] ?? 0).toDouble(),
      variation: (json['variations'] as List<dynamic>?)
              ?.map<List<bool>>((v) =>
                  (v as List<dynamic>).map<bool>((e) => e as bool).toList())
              .toList() ??
          [],
      // discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      addOnIds: (json['add_on_ids'] as List<dynamic>?)
              ?.map((v) => AddOn.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      addOns: (json['add_ons'] as List<dynamic>?)
              ?.map((v) => AddOns.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      isComplementry: json['is_complementoy'] ?? false,
      product: Product.fromJson(json['product'] ?? {}),
      foodNote: json['food_note'] ?? '',
      isInventory: json['is_inventory'] ?? 'No',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'discounted_price': discountedPrice,
      'variations': variation,
      'food_note': foodNote,
      'is_inventory': isInventory,
      'quantity': quantity,
      'add_on_ids': addOnIds.map((v) => v.toJson()).toList(),
      'add_ons': addOns.map((v) => v.toJson()).toList(),
      'is_complementoy': isComplementry,
      'product': product.toJson(),
    };
  }
}

class AddOn {
  int id;
  int quantity;
  String? name;
  double? price;

  AddOn({required this.id, required this.quantity, this.name, this.price});

  factory AddOn.fromJson(Map<String, dynamic> json) {
    return AddOn(
      id: json['id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      name: json['name'] ?? '',
      price: double.parse('${json['price'] ?? 0}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'name': name ?? '',
      'price': price,
    };
  }
}
