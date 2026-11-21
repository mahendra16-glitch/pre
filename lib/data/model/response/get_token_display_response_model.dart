class GetTokenDisplayResponseModel {
  List<TokenEmployeeList>? tokenEmployeeList;

  GetTokenDisplayResponseModel({this.tokenEmployeeList});

  GetTokenDisplayResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['token_employee_list'] != null) {
      tokenEmployeeList = <TokenEmployeeList>[];
      json['token_employee_list'].forEach((v) {
        tokenEmployeeList!.add(new TokenEmployeeList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tokenEmployeeList != null) {
      data['token_employee_list'] =
          this.tokenEmployeeList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TokenEmployeeList {
  int? orderId;
  String? restaurantOrderId;
  String? tokenNo;
  String? userName;
  String? stationName;
  int? stationStatus;
  String? counterName;
  String? tempOrderId;

  TokenEmployeeList({
    this.orderId,
    this.restaurantOrderId,
    this.tokenNo,
    this.userName,
    this.stationName,
    this.stationStatus,
    this.counterName,
    this.tempOrderId,
  });

  TokenEmployeeList.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    restaurantOrderId = json['restaurant_order_id'];
    tokenNo = json['daily_token'] ?? '';
    userName = json['user_name'] == null ||
            json['user_name'].toString().toLowerCase() == 'unknown user'
        ? ''
        : json['user_name'];
    stationName = json['station_name'] ?? '';
    stationStatus = json['station_status'] ?? 0;
    counterName = json['counter_name'] ?? '';
    tempOrderId = '${json['order_id']}_${json['station_name']}';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['restaurant_order_id'] = this.restaurantOrderId;
    data['user_name'] = this.userName;
    data['station_name'] = this.stationName;
    data['station_status'] = this.stationStatus;
    data['counter_name'] = this.counterName;
    return data;
  }
}
