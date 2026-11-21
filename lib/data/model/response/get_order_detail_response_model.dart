import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/data/model/response/product_model.dart';
import 'package:get/get.dart';

class GetOrderDetailModel {
  List<Detail>? orders;

  GetOrderDetailModel({this.orders});

  GetOrderDetailModel.fromJson(Map<String, dynamic> json) {
    if (json['orders'] != null) {
      orders = <Detail>[];
      json['orders'].forEach((v) {
        orders!.add(Detail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Detail {
  OrderDetails? orderDetailsOrder;
  List<FoodList>? orderDetailsFood;
  RestaurantDetails? restaurantDetails;
  List<UserDetails>? userDetails;

  Detail({
    this.orderDetailsOrder,
    this.orderDetailsFood,
    this.restaurantDetails,
    this.userDetails,
  });

  Detail.fromJson(Map<String, dynamic> json) {
    orderDetailsOrder = json['order_details_order'] != null
        ? OrderDetails.fromJson(json['order_details_order'])
        : null;
    if (json['order_details_food'] != null) {
      orderDetailsFood = <FoodList>[];
      json['order_details_food'].forEach((v) {
        orderDetailsFood!.add(FoodList.fromJson(v));
      });
    }
    if (json.containsKey('user_details')) {
      if (json['user_details'] != null) {
        userDetails = <UserDetails>[];
        json['user_details'].forEach((v) {
          userDetails!.add(UserDetails.fromJson(v));
        });
      }
    }
    restaurantDetails = json['restaurant_details'] != null
        ? RestaurantDetails.fromJson(json['restaurant_details'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (orderDetailsOrder != null) {
      data['order_details_order'] = orderDetailsOrder!.toJson();
    }
    if (userDetails != null) {
      data['user_details'] = userDetails!.map((v) => v.toJson()).toList();
    }
    if (orderDetailsFood != null) {
      data['order_details_food'] =
          orderDetailsFood!.map((v) => v.toJson()).toList();
    }
    if (restaurantDetails != null) {
      data['restaurant_details'] = restaurantDetails!.toJson();
    }
    return data;
  }
}

class OrderDetails {
  String? id;
  String? originalOrderId;
  int? userId;
  String? username;
  dynamic orderAmount;
  String? paymentStatus;
  String? orderStatus;
  String? orderNote;
  String? orderType;
  int? checked;
  int? restaurantId;
  String? createdAt;
  String? updatedAt;
  int? tableId;
  int? waiterId;
  int? fOrderStatus;
  int? barOrderStatus;
  int? kdsOrderStatus;

  OrderDetails({
    this.id,
    this.originalOrderId,
    this.userId,
    this.username,
    this.orderAmount,
    this.paymentStatus,
    this.orderStatus,
    this.orderNote,
    this.orderType,
    this.checked,
    this.restaurantId,
    this.createdAt,
    this.updatedAt,
    this.tableId,
    this.waiterId,
    this.fOrderStatus,
    this.barOrderStatus,
    this.kdsOrderStatus,
  });

  OrderDetails.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    originalOrderId = json['id']?.toString();
    userId = json['user_id'];
    orderAmount = json['order_amount'];
    paymentStatus = json['payment_status'];
    username = '';
    if (json.containsKey('user_name')) {
      username = json['user_name'] ?? '';
    }
    orderStatus = json['order_status'];
    orderNote = json['order_note'] ?? '';
    orderType = json['order_type'] ?? '';
    checked = json['checked'];
    restaurantId = json['restaurant_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    tableId = json['table_id'];
    waiterId = json['waiter_id'];
    fOrderStatus = json['f_order_status'];
    barOrderStatus = json['b_order_status'];
    kdsOrderStatus = json['k_order_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['order_amount'] = orderAmount;
    data['payment_status'] = paymentStatus;
    data['order_status'] = orderStatus;
    data['order_note'] = orderNote;
    data['order_type'] = orderType;
    data['checked'] = checked;
    data['restaurant_id'] = restaurantId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['username'] = username;
    data['table_id'] = tableId;
    data['waiter_id'] = waiterId;
    data['f_order_status'] = fOrderStatus;
    data['b_order_status'] = barOrderStatus;
    data['k_order_status'] = kdsOrderStatus;
    return data;
  }
}

class FoodList {
  int? id;
  int? foodId;
  int? orderId;
  int? price;
  bool isSelected;
  bool isSplited;
  ProductDetails? foodDetails;
  List<Variations>? variation;
  List<AddOns>? addOns;
  int? quantity;
  int? splitQuantity;
  String? createdAt;
  String? updatedAt;
  int? foodStatus;
  String? readyAt;
  String? serveAt;
  String? cancelAt;
  double? unitPrice;

  FoodList({
    this.id,
    this.foodId,
    this.orderId,
    this.price,
    this.isSelected = false,
    this.isSplited = false,
    this.foodDetails,
    this.variation,
    this.addOns,
    this.quantity,
    this.splitQuantity,
    this.createdAt,
    this.updatedAt,
    this.foodStatus,
    this.readyAt,
    this.serveAt,
    this.cancelAt,
    this.unitPrice,
  });

  FoodList.fromJson(Map<String, dynamic> json)
      : isSelected = false,
        isSplited = false {
    id = json['id'];
    foodId = json['food_id'];
    orderId = json['order_id'];
    price = json['price'];
    foodDetails = json['food_details'] != null
        ? ProductDetails.fromJson(json['food_details'])
        : null;
    if (json['variation'] != null) {
      variation = <Variations>[];
      json['variation'].forEach((v) {
        variation!.add(Variations.fromJson(v));
      });
    }
    if (json['add_ons'] != null) {
      addOns = <AddOns>[];
      json['add_ons'].forEach((v) {
        addOns!.add(AddOns.fromJson(v));
      });
      if (addOns!.isNotEmpty) {
        addOns!.sort((a, b) => a.name!.compareTo(b.name!));
      }
    }
    quantity = json['quantity'];
    splitQuantity = quantity;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    foodStatus = json['food_status'];
    readyAt = json['ready_at'];
    serveAt = json['serve_at'];
    cancelAt = json['cancel_at'];
    unitPrice = (json['unit_price'] == null || json['unit_price'] == '')
        ? 0
        : double.tryParse(json['unit_price'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['food_id'] = foodId;
    data['order_id'] = orderId;
    data['price'] = price;
    data['food_details'] = foodDetails?.toJson();
    data['variation'] = variation?.map((v) => v.toJson()).toList();
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    data['quantity'] = quantity;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['food_status'] = foodStatus;
    data['unit_price'] = unitPrice?.toString();
    return data;
  }
}

class AddOns {
  int? id;
  String? name;
  int? price;
  int? quantity;

  AddOns({this.id, this.name, this.price, this.quantity});

  AddOns.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString().toUpperCase();
    price = json['price'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['quantity'] = quantity;
    return data;
  }
}

class RestaurantDetails {
  String? tableArea;
  String? tableNo;
  String? waiterName;

  RestaurantDetails({
    this.tableArea,
    this.tableNo,
    this.waiterName,
  });

  RestaurantDetails.fromJson(Map<String, dynamic> json) {
    tableArea = json['restaurant_table_area'] ?? '';
    tableNo = json['restaurant_table_no'] ?? '';
    waiterName = json['restaurant_waiter_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['restaurant_table_area'] = tableArea;
    data['restaurant_table_no'] = tableNo;
    data['restaurant_waiter_name'] = waiterName;
    return data;
  }
}

class UserDetails {
  String? fName;
  String? lName;
  String? phone;

  UserDetails({this.fName, this.lName, this.phone});

  UserDetails.fromJson(Map<String, dynamic> json) {
    fName = json['f_name'] ?? '';
    lName = json['l_name'] ?? '';
    phone = json['phone'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    return data;
  }
}

class ProductDetails {
  int? id;
  String? name;
  String? description;
  String? image;
  int? categoryId;
  List<CategoryIds>? categoryIds;
  List<String>? mainCategoryId;
  List<Variations>? variations;
  List<ProductDetailAddOns>? addOns;
  String? attributes;
  String? choiceOptions;
  double? price;
  double? tax;
  String? taxType;
  dynamic discount;
  String? discountType;
  String? availableTimeStarts;
  String? availableTimeEnds;
  int? veg;
  int? status;
  int? restaurantId;
  String? createdAt;
  String? updatedAt;
  int? qty;
  String? foodType;

  ProductDetails({
    this.id,
    this.name,
    this.description,
    this.image,
    this.categoryId,
    this.categoryIds,
    this.variations,
    this.addOns,
    this.attributes,
    this.choiceOptions,
    this.price,
    this.tax,
    this.taxType,
    this.discount,
    this.discountType,
    this.availableTimeStarts,
    this.availableTimeEnds,
    this.veg,
    this.status,
    this.restaurantId,
    this.createdAt,
    this.updatedAt,
    this.qty,
    this.foodType,
  });

  ProductDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString().toUpperCase();
    description = json['description'] ?? '';
    image = json['image'];
    categoryId = json['category_id'];
    qty = 0;

    if (json['category_ids'] != null) {
      categoryIds = [];
      mainCategoryId = [];
      json['category_ids'].forEach((v) {
        mainCategoryId!.add(v['id'].toString());
        categoryIds!.add(CategoryIds.fromJson(v));
      });
    }
    if (json['variations'] != null) {
      variations = <Variations>[];
      json['variations'].forEach((v) {
        variations!.add(Variations.fromJson(v));
      });
      if (variations!.isNotEmpty) {
        variations!.sort((a, b) => a.name!.compareTo(b.name!));
      }
    }
    if (json['add_ons'] != null) {
      addOns = <ProductDetailAddOns>[];
      json['add_ons'].forEach((v) {
        addOns!.add(ProductDetailAddOns.fromJson(v));
      });
      if (addOns!.isNotEmpty) {
        addOns!.sort((a, b) => a.name!.compareTo(b.name!));
      }
    }
    attributes = json['attributes'];
    choiceOptions = '';
    price = json['price'] == null ? 0 : json['price'].toDouble();
    tax = json['tax'] != null ? json['tax'].toDouble() : null;
    taxType = json['tax_type'];
    discount = json['discount'] == null ? 0 : json['discount'].toDouble();
    discountType = json['discount_type'];
    availableTimeStarts = json['available_time_starts'];
    availableTimeEnds = json['available_time_ends'];
    veg = json['veg'];
    status = json['status'];
    restaurantId = json['restaurant_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    // foodType = '';
    // if (mainCategoryId != null && mainCategoryId!.isNotEmpty) {
    //   for (var e in mainCategoryId!) {
    //     for (var i = 0;
    //         i <
    //             Get.find<AuthController>()
    //                 .profileModel!
    //                 .restaurantPrinterNew!
    //                 .length;
    //         i++) {
    //       if (Get.find<AuthController>()
    //           .profileModel!
    //           .restaurantPrinterNew![i]
    //           .categoriesId!
    //           .contains(int.parse(e))) {
    //         foodType = Get.find<AuthController>()
    //             .profileModel!
    //             .restaurantPrinterNew![i]
    //             .areaName;
    //         break;
    //       }
    //     }
    //   }
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
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
    data['attributes'] = attributes;
    data['choice_options'] = choiceOptions;
    data['price'] = price;
    data['tax'] = tax;
    data['tax_type'] = taxType;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['available_time_starts'] = availableTimeStarts;
    data['available_time_ends'] = availableTimeEnds;
    data['veg'] = veg;
    data['status'] = status;
    data['restaurant_id'] = restaurantId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['foodType'] = foodType;
    return data;
  }
}

class ProductDetailAddOns {
  int? id;
  String? name;
  dynamic price;
  int? qty;
  int? restaurantId;
  int? status;

  ProductDetailAddOns({
    this.id,
    this.name,
    this.price,
    this.qty,
    this.restaurantId,
    this.status,
  });

  ProductDetailAddOns.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString().toUpperCase();
    price = json['price']?.toDouble();
    qty = 0;
    restaurantId = json['restaurant_id'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['restaurant_id'] = restaurantId;
    data['status'] = status;
    return data;
  }
}
