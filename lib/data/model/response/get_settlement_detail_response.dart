class GetSettlementDetailReportResponse {
  final List<Settelmentdetails> settelmentdetails;
  final String? settleDate;
  final double grandTotalSale;
  final double grandTotalPaidRevenue;
  final double grandTotalUnpaidRevenue;

  GetSettlementDetailReportResponse({
    required this.settelmentdetails,
    this.settleDate,
    required this.grandTotalSale,
    required this.grandTotalPaidRevenue,
    required this.grandTotalUnpaidRevenue,
  });

  factory GetSettlementDetailReportResponse.fromJson(
      Map<String, dynamic> json) {
    List<Settelmentdetails> details = [];
    if (json['settelmentdetails'] != null) {
      details = List<Settelmentdetails>.from(
        (json['settelmentdetails'] as List)
            .map((v) => Settelmentdetails.fromJson(v)),
      );
    }
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return GetSettlementDetailReportResponse(
      settelmentdetails: details,
      settleDate: json['settle_date'] as String?,
      grandTotalSale: parseDouble(json['grand_total_sales']),
      grandTotalPaidRevenue: parseDouble(json['grand_total_paid_revenue']),
      grandTotalUnpaidRevenue: parseDouble(json['grand_total_unpaid_revenue']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'settelmentdetails': settelmentdetails.map((v) => v.toJson()).toList(),
      'settle_date': settleDate,
      'grand_total_sales': grandTotalSale,
      'grand_total_paid_revenue': grandTotalPaidRevenue,
      'grand_total_unpaid_revenue': grandTotalUnpaidRevenue,
    };
  }
}

class Settelmentdetails {
  String? from;
  String? to;
  int? waiterID;
  String? waiterName;
  double? totalSales;
  double? totalRevenue;
  double? totCash;
  double? totUpi;
  double? totCc;
  double? totTab;
  double? totUnpaid;
  double? totUnpaidRoom;
  double? totUnpaidTable;
  double? totAmt;
  double? tabCash;
  double? tabUpi;
  double? tabCc;
  double? totTabRevenue;
  double? totRevenueAmnt;
  double? totSettleAmt;
  double? serviceTax;
  double? tipAmount;
  double? deliveryCharge;

  Settelmentdetails({
    this.from,
    this.to,
    this.waiterID,
    this.waiterName,
    this.totalSales,
    this.totalRevenue,
    this.totCash,
    this.totUpi,
    this.totCc,
    this.totTab,
    this.totUnpaid,
    this.totUnpaidRoom,
    this.totUnpaidTable,
    this.totAmt,
    this.tabCash,
    this.tabUpi,
    this.tabCc,
    this.totTabRevenue,
    this.totRevenueAmnt,
    this.totSettleAmt,
    this.serviceTax,
    this.tipAmount,
    this.deliveryCharge,
  });

  factory Settelmentdetails.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return Settelmentdetails(
      from: json['from'] as String?,
      to: json['to'] as String?,
      waiterID: json['WaiterID'] is int
          ? json['WaiterID'] as int
          : int.tryParse('${json['WaiterID']}'),
      waiterName: json['WaiterName'] as String? ?? '',
      totalSales: parseDouble(json['total_sales']),
      totalRevenue: parseDouble(json['total_revenue']),
      totCash: parseDouble(json['tot_cash']),
      totUpi: parseDouble(json['Tot_upi']),
      totCc: parseDouble(json['tot_cc']),
      totTab: parseDouble(json['tot_tab']),
      totUnpaid: parseDouble(json['tot_unpaid']),
      totUnpaidRoom: parseDouble(json['tot_unpaid_room']),
      totUnpaidTable: parseDouble(json['tot_unpaid_table']),
      totAmt: parseDouble(json['tot_amt']),
      tabCash: parseDouble(json['tab_cash']),
      tabUpi: parseDouble(json['tab_upi']),
      tabCc: parseDouble(json['tab_cc']),
      totTabRevenue: parseDouble(json['tot_tab_revenue']),
      totRevenueAmnt: parseDouble(json['tot_revenue_amnt']),
      totSettleAmt: parseDouble(json['tot_settle_amt']),
      serviceTax: parseDouble(json['total_service_tax_amount']),
      tipAmount: parseDouble(json['total_tip_amount']),
      deliveryCharge: parseDouble(json['total_delivery_charge']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'WaiterID': waiterID,
      'WaiterName': waiterName,
      'total_sales': totalSales,
      'tot_cash': totCash,
      'Tot_upi': totUpi,
      'tot_cc': totCc,
      'tot_tab': totTab,
      'tot_unpaid': totUnpaid,
      'tot_unpaid_room': totUnpaidRoom,
      'tot_unpaid_table': totUnpaidTable,
      'tot_amt': totAmt,
      'tab_cash': tabCash,
      'tab_upi': tabUpi,
      'tab_cc': tabCc,
      'tot_tab_revenue': totTabRevenue,
      'tot_revenue_amnt': totRevenueAmnt,
      'tot_settle_amt': totSettleAmt,
      'total_service_tax_amount': serviceTax,
      'total_tip_amount': tipAmount,
      'total_delivery_charge': deliveryCharge,
    };
  }
}
