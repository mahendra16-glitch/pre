class ChatListModel {
  int? totalSize;
  int? limit;
  int? offset;
  MessagesData? messagesData;

  ChatListModel({this.totalSize, this.limit, this.offset, this.messagesData});

  ChatListModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    messagesData = json['messages'] != null
        ? MessagesData.fromJson(json['messages'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (messagesData != null) {
      data['messages'] = messagesData!.toJson();
    }
    return data;
  }
}

class MessagesData {
  int? currentPage;
  List<Data>? data;

  MessagesData({this.currentPage, this.data});

  MessagesData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['current_page'] = currentPage;
    if (data != null) {
      dataMap['data'] = data!.map((v) => v.toJson()).toList();
    }
    return dataMap;
  }
}

class Data {
  int? orderId;
  int? userId;
  int? conversationsCount;
  Customer? customer;

  Data({this.orderId, this.userId, this.conversationsCount, this.customer});

  Data.fromJson(Map<String, dynamic> json) {
    orderId = json['id'];
    userId = json['user_id'];
    conversationsCount = json['conversations_count'];
    customer =
        json['customer'] != null ? Customer.fromJson(json['customer']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['id'] = orderId;
    dataMap['user_id'] = userId;
    dataMap['conversations_count'] = conversationsCount;
    if (customer != null) {
      dataMap['customer'] = customer!.toJson();
    }
    return dataMap;
  }
}

class Customer {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? image;
  String? createdAt;
  String? updatedAt;
  int? loyaltyPoint;
  String? refCode;

  Customer({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.loyaltyPoint,
    this.refCode,
  });

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    loyaltyPoint = json['loyalty_point'];
    refCode = json['ref_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['id'] = id;
    dataMap['f_name'] = fName;
    dataMap['l_name'] = lName;
    dataMap['phone'] = phone;
    dataMap['email'] = email;
    dataMap['image'] = image;
    dataMap['created_at'] = createdAt;
    dataMap['updated_at'] = updatedAt;
    dataMap['loyalty_point'] = loyaltyPoint;
    dataMap['ref_code'] = refCode;
    return dataMap;
  }
}
