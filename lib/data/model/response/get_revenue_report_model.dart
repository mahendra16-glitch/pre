class GetRevenueReportResponse {
  List<Revenue> revenue;
  String? from;
  String? to;

  double grandTotalSale;
  double grandTotalPaidRevenue;
  double grandTotalUnpaidRevenue;

  GetRevenueReportResponse({
    required this.revenue,
    required this.from,
    required this.to,
    required this.grandTotalSale,
    required this.grandTotalPaidRevenue,
    required this.grandTotalUnpaidRevenue,
  });

  factory GetRevenueReportResponse.fromJson(Map<String, dynamic> json) {
    return GetRevenueReportResponse(
      revenue: (json['revenue'] as List<dynamic>?)
              ?.map((v) => Revenue.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      from: json['from'] as String?,
      to: json['to'] as String?,
      grandTotalSale: double.tryParse('${json['grand_total_sales'] ?? 0}') ?? 0,
      grandTotalPaidRevenue:
          double.tryParse('${json['grand_total_paid_revenue'] ?? 0}') ?? 0,
      grandTotalUnpaidRevenue:
          double.tryParse('${json['grand_total_unpaid_revenue'] ?? 0}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenue': revenue.map((v) => v.toJson()).toList(),
      'from': from,
      'to': to,
      'grand_total_sales': grandTotalSale,
      'grand_total_paid_revenue': grandTotalPaidRevenue,
      'grand_total_unpaid_revenue': grandTotalUnpaidRevenue,
    };
  }
}

class Revenue {
  int? sn;
  String? revenueDate;
  double totalSales;
  double totalPaidAmount;
  double totalUnpaidAmount;
  double tabRevenue;
  double totalAmount;
  double settelAmount;

  Revenue({
    required this.sn,
    required this.revenueDate,
    required this.totalSales,
    required this.totalPaidAmount,
    required this.totalUnpaidAmount,
    required this.tabRevenue,
    required this.totalAmount,
    required this.settelAmount,
  });

  factory Revenue.fromJson(Map<String, dynamic> json) {
    return Revenue(
      sn: json['Sn'] as int?,
      revenueDate: json['revenue_date'] as String?,
      totalSales: double.tryParse('${json['total_sales'] ?? 0}') ?? 0,
      totalPaidAmount:
          double.tryParse('${json['total_paid_amount'] ?? 0}') ?? 0,
      totalUnpaidAmount:
          double.tryParse('${json['total_unpaid_amount'] ?? 0}') ?? 0,
      tabRevenue: double.tryParse('${json['tab_revenue'] ?? 0}') ?? 0,
      totalAmount: double.tryParse('${json['total_amount'] ?? 0}') ?? 0,
      settelAmount: double.tryParse('${json['settel_amount'] ?? 0}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Sn': sn,
      'revenue_date': revenueDate,
      'total_sales': totalSales,
      'total_paid_amount': totalPaidAmount,
      'total_unpaid_amount': totalUnpaidAmount,
      'tab_revenue': tabRevenue,
      'total_amount': totalAmount,
      'settel_amount': settelAmount,
    };
  }
}
