// To parse this JSON data, do
//
//     final settlementRestaurantModel = settlementRestaurantModelFromJson(jsonString);

import 'dart:convert';

SettlementRestaurantModel settlementRestaurantModelFromJson(String str) =>
    SettlementRestaurantModel.fromJson(json.decode(str));

String settlementRestaurantModelToJson(SettlementRestaurantModel data) =>
    json.encode(data.toJson());

class SettlementRestaurantModel {
  bool? success;
  List<SettleMentData>? data;
  Totals? totals;

  SettlementRestaurantModel({
    this.success,
    this.data,
    this.totals,
  });

  factory SettlementRestaurantModel.fromJson(Map<String, dynamic> json) =>
      SettlementRestaurantModel(
        success: json["success"],
        data: List<SettleMentData>.from(
            json["data"].map((x) => SettleMentData.fromJson(x))),
        totals: Totals.fromJson(json["totals"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data?.map((x) => x.toJson()) ?? []),
        "totals": totals?.toJson(),
      };
}

class SettleMentData {
  DateTime? date;
  List<Waiter>? waiters;
  Totals? totals;

  bool? isShowWaiter;

  SettleMentData({
    this.date,
    this.waiters,
    this.totals,
    this.isShowWaiter,
  });
  SettleMentData copyWith({
    bool? isShowWaiter,
    DateTime? date,
    List<Waiter>? waiters,
  }) {
    return SettleMentData(
      isShowWaiter: isShowWaiter ?? this.isShowWaiter,
      date: date ?? this.date,
      waiters: waiters ?? this.waiters,
    );
  }

  factory SettleMentData.fromJson(Map<String, dynamic> json) => SettleMentData(
        date: DateTime.parse(json["date"]),
        waiters:
            List<Waiter>.from(json["waiters"].map((x) => Waiter.fromJson(x))),
        totals: Totals.fromJson(json["totals"]),
      );

  Map<String, dynamic> toJson() => {
        "date":
            "${date?.year.toString().padLeft(4, '0')}-${date?.month.toString().padLeft(2, '0')}-${date?.day.toString().padLeft(2, '0')}",
        "waiters": List<dynamic>.from(waiters?.map((x) => x.toJson()) ?? []),
        "totals": totals?.toJson(),
      };
}

class Totals {
  num? totalOpeningBalance;
  num? totalTodayCollection;
  num? totalTodayDeliveryCharge;
  num? totalTodayTips;
  num? totalTodaySettlement;
  num? lastDayPending;
  num? totalTotalFunds;
  num? totalTodayGiven;
  num? totalBalanceToSettle;
  int? settlementStatus;

  Totals({
    this.totalOpeningBalance,
    this.totalTodayCollection,
    this.totalTodayDeliveryCharge,
    this.totalTodayTips,
    this.totalTodaySettlement,
    this.lastDayPending,
    this.totalTotalFunds,
    this.totalTodayGiven,
    this.totalBalanceToSettle,
    this.settlementStatus,
  });

  factory Totals.fromJson(Map<String, dynamic> json) => Totals(
        totalOpeningBalance: json["total_opening_balance"],
        totalTodayCollection: json["total_today_collection"]?.toDouble(),
        totalTodayDeliveryCharge: json["total_today_delivery_charge"],
        totalTodayTips: json["total_today_tips"],
        totalTodaySettlement: json["total_today_settlement"],
        lastDayPending: json["last_day_pending"],
        totalTotalFunds: json["total_total_funds"]?.toDouble(),
        totalTodayGiven: json["total_today_given"],
        totalBalanceToSettle: json["total_balance_to_settle"]?.toDouble(),
        settlementStatus:
            json["stattlement_status"] ?? 0, // 0 for not  settled, 1 for settled
      );

  Map<String, dynamic> toJson() => {
        "total_opening_balance": totalOpeningBalance,
        "total_today_collection": totalTodayCollection,
        "total_today_delivery_charge": totalTodayDeliveryCharge,
        "total_today_tips": totalTodayTips,
        "total_today_settlement": totalTodaySettlement,
        "last_day_pending": lastDayPending,
        "total_total_funds": totalTotalFunds,
        "total_today_given": totalTodayGiven,
        "total_balance_to_settle": totalBalanceToSettle,
      };
}

class Waiter {
  int? waiterId;
  String? fullName;
  String? restaurantId;
  DateTime? date;
  String? lastDayPending;
  String? todayGiven;
  String? openingBalance;
  String? todayCollection;
  String? todayDeliveryCharge;
  String? todayServiceCharge;
  String? todayTips;
  String? todaySettlement;
  String? totalFunds;
  String? totalSale;
  String? totalPaid;
  String? totalUnPaid;
  String? balanceToSettle;
  String? cashDrawer;
  bool? isShowPaymentMode;
  bool? isShowRevenue;
  TipsByMode? tipsByMode;

  Waiter(
      {this.waiterId,
      this.fullName,
      this.restaurantId,
      this.date,
      this.lastDayPending,
      this.todayGiven,
      this.openingBalance,
      this.todayCollection,
      this.todayDeliveryCharge,
      this.todayTips,
      this.todaySettlement,
      this.totalFunds,
      this.tipsByMode,
      this.balanceToSettle,
      this.todayServiceCharge,
      this.cashDrawer,
      this.totalSale,
      this.totalPaid,
      this.totalUnPaid,
      this.isShowRevenue,
      this.isShowPaymentMode});

  factory Waiter.fromJson(Map<String, dynamic> json) => Waiter(
        waiterId: json["waiter_id"],
        fullName: json["full_name"],
        restaurantId: json["restaurant_id"],
        date: DateTime.parse(json["date"]),
        lastDayPending: json["last_day_pending"],
        todayGiven: json["today_given"],
        openingBalance: json["opening_balance"],
        todayCollection: json["today_collection"],
        todayDeliveryCharge: json["today_delivery_charge"],
        todayServiceCharge: json["today_service_charge"],
        todayTips: json["today_tips"],
        todaySettlement: json["today_settlement"],
        totalFunds: json["total_funds"],
        balanceToSettle: json["balance_to_settle"],
        cashDrawer: json['cash_draw'],
        totalSale: json["total_sale"],
        totalPaid: json["total_paid"],
        totalUnPaid: json["total_unpaid"],
        tipsByMode: TipsByMode.fromJson(json["tips_by_mode"]),
      );

  Map<String, dynamic> toJson() => {
        "waiter_id": waiterId,
        "full_name": fullName,
        "restaurant_id": restaurantId,
        "date":
            "${date?.year.toString().padLeft(4, '0')}-${date?.month.toString().padLeft(2, '0')}-${date?.day.toString().padLeft(2, '0')}",
        "last_day_pending": lastDayPending,
        "today_given": todayGiven,
        "opening_balance": openingBalance,
        "today_collection": todayCollection,
        "today_delivery_charge": todayDeliveryCharge,
        "today_service_charge": todayServiceCharge,
        "today_tips": todayTips,
        "today_settlement": todaySettlement,
        "total_funds": totalFunds,
        "balance_to_settle": balanceToSettle,
        "tips_by_mode": tipsByMode?.toJson(),
      };
}

class TipsByMode {
  String? cash;
  String? tab;
  String? card;
  String? upi;
  String? room;
  String? other;

  TipsByMode({
    this.cash,
    this.tab,
    this.card,
    this.upi,
    this.room,
    this.other,
  });

  factory TipsByMode.fromJson(Map<String, dynamic> json) => TipsByMode(
        cash: json["cash"],
        tab: json["TAB"],
        card: json["card"],
        upi: json["upi"],
        room: json["ROOM"],
        other: json["Other"],
      );

  Map<String, dynamic> toJson() => {
        "cash": cash,
        "TAB": tab,
        "card": card,
        "upi": upi,
        "ROOM": room,
        "Other": other,
      };
}
