// To parse this JSON data, do
//
//     final waiterModel = waiterModelFromJson(jsonString);

import 'dart:convert';

WaiterModel waiterModelFromJson(String str) =>
    WaiterModel.fromJson(json.decode(str));

String waiterModelToJson(WaiterModel data) => json.encode(data.toJson());

class WaiterModel {
  String? message;
  List<WaiterData>? data;

  WaiterModel({
    this.message,
    this.data,
  });

  factory WaiterModel.fromJson(Map<String, dynamic> json) => WaiterModel(
        message: json["message"],
        data: List<WaiterData>.from(
            json["data"].map((x) => WaiterData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data?.map((x) => x.toJson()) ?? []),
      };
}

class WaiterData {
  int? id;
  String? name;
  bool? isChecked;

  WaiterData({this.id, this.name, this.isChecked = false});

  factory WaiterData.fromJson(Map<String, dynamic> json) => WaiterData(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
