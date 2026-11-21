class GetSettlementReportResponse {
  final List<Settelmentlist> settelmentlist;
  final String? month;
  final String? year;
  final double grandTotalSale;
  final double grandTotalPaidRevenue;
  final double grandTotalUnpaidRevenue;

  GetSettlementReportResponse({
    required this.settelmentlist,
    this.month,
    this.year,
    required this.grandTotalSale,
    required this.grandTotalPaidRevenue,
    required this.grandTotalUnpaidRevenue,
  });

  factory GetSettlementReportResponse.fromJson(Map<String, dynamic> json) {
    List<Settelmentlist> list = [];
    if (json['settelmentlist'] != null) {
      list = (json['settelmentlist'] as List)
          .map((v) => Settelmentlist.fromJson(v as Map<String, dynamic>))
          .toList();
    }
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return GetSettlementReportResponse(
      settelmentlist: list,
      month: json['month'] as String?,
      year: json['year'] as String?,
      grandTotalSale: parseDouble(json['grand_total_sales']),
      grandTotalPaidRevenue: parseDouble(json['grand_total_paid_revenue']),
      grandTotalUnpaidRevenue: parseDouble(json['grand_total_unpaid_revenue']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'settelmentlist': settelmentlist.map((v) => v.toJson()).toList(),
      'month': month,
      'year': year,
      'grand_total_sales': grandTotalSale,
      'grand_total_paid_revenue': grandTotalPaidRevenue,
      'grand_total_unpaid_revenue': grandTotalUnpaidRevenue,
    };
  }
}

class Settelmentlist {
  final int? restId;
  final String? fromDate;
  final String? toDate;
  final double? totalPaidAmount;
  final double? totalUnpaidAmount;
  final double? tabRevenue;
  final double? totalAmount;
  final double? settelAmount;

  Settelmentlist({
    this.restId,
    this.fromDate,
    this.toDate,
    this.totalPaidAmount,
    this.totalUnpaidAmount,
    this.tabRevenue,
    this.totalAmount,
    this.settelAmount,
  });

  factory Settelmentlist.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return Settelmentlist(
      restId: json['rest_id'] as int?,
      fromDate: json['from_date'] as String?,
      toDate: json['to_date'] as String?,
      totalPaidAmount: parseDouble(json['total_paid_amount']),
      totalUnpaidAmount: parseDouble(json['total_unpaid_amount']),
      tabRevenue: parseDouble(json['tab_revenue']),
      totalAmount: parseDouble(json['total_amount']),
      settelAmount: parseDouble(json['settel_amount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rest_id': restId,
      'from_date': fromDate,
      'to_date': toDate,
      'total_paid_amount': totalPaidAmount,
      'total_unpaid_amount': totalUnpaidAmount,
      'tab_revenue': tabRevenue,
      'total_amount': totalAmount,
      'settel_amount': settelAmount,
    };
  }
}
