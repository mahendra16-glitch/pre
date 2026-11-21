class GetPrintReportResponse {
  String totalSales;
  String totalPaidAmount;
  String orderCash;
  String orderCard;
  String orderUPI;
  String runningOrder;
  String orderTAB;
  String orderRoundOff;
  String orderRoom;
  String unpaidRevenue;
  String todayGalla;
  String totalExpense;
  String expenseCashDraw;
  String expenseCash;
  String expenseCard;
  String expenseUpi;
  String expenseStore;
  String expenseUnpaid;
  String expenseUpiDrawer;
  String expenseBankTransfer;
  String expenseOthers;
  String totalOpeningBalance;
  String totalTodaySettlement;
  String lastDayPending;
  String totalBalanceToSettle;
  String totalPaidCashRevenue;
  String totalPurchase;
  String totalPurchaseAndExpense;
  String totalPilferage;
  String totalProfitLoss;
  // String? totalTabPayment;
  String tabInCash;
  String tabInCard;
  String tabInUpi;
  String from;
  String to;
  String serviceCharge;
  String discount;
  String tips;
  String tax;
  Map<String, dynamic>? stationReport;
  Map<String, dynamic>? cancelOrderReport;
  Map<String, dynamic>? roomOrderRevenue;
  Map<String, dynamic>? aggregatorOrderRevenue;
  Map<String, dynamic>? paidRevenuePaymenetMode;
  DailyReportSummary? reportSummary;

  GetPrintReportResponse({
    required this.totalSales,
    required this.totalPaidAmount,
    required this.orderCash,
    required this.orderCard,
    required this.orderUPI,
    required this.runningOrder,
    required this.orderTAB,
    required this.orderRoundOff,
    required this.orderRoom,
    required this.unpaidRevenue,
    required this.todayGalla,
    required this.totalExpense,
    required this.expenseCashDraw,
    required this.expenseCash,
    required this.expenseCard,
    required this.expenseUpi,
    required this.expenseStore,
    required this.expenseUnpaid,
    required this.expenseUpiDrawer,
    required this.expenseBankTransfer,
    required this.expenseOthers,
    required this.totalOpeningBalance,
    required this.totalTodaySettlement,
    required this.lastDayPending,
    required this.totalBalanceToSettle,
    required this.totalPaidCashRevenue,
    required this.totalPurchase,
    required this.totalPurchaseAndExpense,
    required this.totalPilferage,
    required this.totalProfitLoss,
    // this.totalTabPayment,
    required this.tabInCash,
    required this.tabInCard,
    required this.tabInUpi,
    required this.serviceCharge,
    required this.discount,
    required this.tips,
    required this.tax,
    required this.from,
    required this.to,
    this.stationReport,
    this.cancelOrderReport,
    this.roomOrderRevenue,
    this.paidRevenuePaymenetMode,
    this.aggregatorOrderRevenue,
    this.reportSummary,
  });

  factory GetPrintReportResponse.fromJson(Map<String, dynamic> json) {
    return GetPrintReportResponse(
      totalSales: json['total_sales']?.toString() ?? '0',
      totalPaidAmount: json['paid_revenue']?.toString() ?? '0',
      orderCash: json['Cash']?.toString() ?? '0',
      orderCard: json['Card']?.toString() ?? '0',
      orderUPI: json['UPI']?.toString() ?? '0',
      runningOrder: json['running_order']?.toString() ?? '0',
      orderTAB: json['orderTAB']?.toString() ?? '0',
      orderRoundOff: json['round_off']?.toString() ?? '0',
      orderRoom: json['orderRoom']?.toString() ?? '0',
      unpaidRevenue: json['unpaid_revenue']?.toString() ?? '0',
      todayGalla: json['today_galla']?.toString() ?? '0',
      totalExpense: json['total_expense']?.toString() ?? '0',
      expenseCashDraw: json['expense_cash_draw']?.toString() ?? '0',
      expenseCash: json['expense_cash']?.toString() ?? '0',
      expenseCard: json['expense_card']?.toString() ?? '0',
      expenseUpi: json['expense_upi']?.toString() ?? '0',
      expenseStore: json['expense_store']?.toString() ?? '0',
      expenseUnpaid: json['expense_unpaid']?.toString() ?? '0',
      expenseUpiDrawer: json['expense_upi_drawer']?.toString() ?? '0',
      expenseBankTransfer: json['expense_bank_transfer']?.toString() ?? '0',
      expenseOthers: json['expense_others']?.toString() ?? '0',
      totalOpeningBalance: json['total_opening_balance']?.toString() ?? '0',
      totalTodaySettlement: json['total_today_settlement']?.toString() ?? '0',
      lastDayPending: json['last_day_pending']?.toString() ?? '0',
      totalBalanceToSettle: json['total_balance_to_settle']?.toString() ?? '0',
      totalPaidCashRevenue: json['total_paid_cash']?.toString() ?? '0',
      totalPurchase: json['total_purchase']?.toString() ?? '0',
      totalPurchaseAndExpense:
          json['total_purchase_and_expense']?.toString() ?? '0',
      totalPilferage: json['total_pilferage']?.toString() ?? '0',
      totalProfitLoss: json['total_profit_loss']?.toString() ?? '0',

      // totalTabPayment: json['total_tab_payment']?.toString() ?? '0',
      tabInCash: json['tab_cash']?.toString() ?? '0',
      tabInCard: json['tab_card']?.toString() ?? '0',
      tabInUpi: json['tab_upi']?.toString() ?? '0',
      serviceCharge: json['service_charge']?.toString() ?? '0',
      discount: json['discount']?.toString() ?? '0',
      tips: json['tips']?.toString() ?? '0',
      tax: json['tax']?.toString() ?? '0',
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      stationReport: json['station_revenue'] is Map<String, dynamic>
          ? json['station_revenue'] as Map<String, dynamic>
          : null,
      cancelOrderReport: json['cancel_revenue'] is Map<String, dynamic>
          ? json['cancel_revenue'] as Map<String, dynamic>
          : null,
      roomOrderRevenue: json['room_revenue'] is Map<String, dynamic>
          ? json['room_revenue'] as Map<String, dynamic>
          : null,
      paidRevenuePaymenetMode:
          json['paid_revenue_method'] is Map<String, dynamic>
              ? json['paid_revenue_method'] as Map<String, dynamic>
              : null,
      aggregatorOrderRevenue: json['aggrigator_order'] is Map<String, dynamic>
          ? json['aggrigator_order'] as Map<String, dynamic>
          : null,
      reportSummary: json['report_summary'] is Map<String, dynamic>
          ? DailyReportSummary.fromJson(
              json['report_summary'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['total_sales'] = totalSales;
    data['total_paid_amount'] = totalPaidAmount;
    data['unpaid_revenue'] = unpaidRevenue;
    data['orderCash'] = orderCash;
    data['orderCard'] = orderCard;
    data['orderUPI'] = orderUPI;
    data['running_order'] = runningOrder;
    data['orderTAB'] = orderTAB;
    data['orderRoom'] = orderRoom;
    // data['total_tab_payment'] = totalTabPayment;
    data['tab_in_cash'] = tabInCash;
    data['tab_in_card'] = tabInCard;
    data['tab_in_upi'] = tabInUpi;
    data['service_charge'] = serviceCharge;
    data['discount'] = discount;
    data['tips'] = tips;
    data['tax'] = tax;
    data['from'] = from;
    data['to'] = to;
    if (stationReport != null) data['station_revenue'] = stationReport;
    if (cancelOrderReport != null) data['cancel_revenue'] = cancelOrderReport;
    if (roomOrderRevenue != null) data['room_revenue'] = roomOrderRevenue;
    if (reportSummary != null) data['report_summary'] = reportSummary!.toJson();
    return data;
  }
}

class DailyReportSummary {
  SalesRevenueSummary? salesRevenueSummary;
  BalanceSummary? balanceSummary;
  TotalPurchaseAndExpenseSummary? totalPurchaseAndExpense;
  Map<String, String> aggregatorOrder;
  AdditionalSummary? additionalSummary;
  Map<String, String> stationRevenue;
  Map<String, String> cancelRevenue;

  DailyReportSummary({
    this.salesRevenueSummary,
    this.balanceSummary,
    this.totalPurchaseAndExpense,
    this.aggregatorOrder = const {},
    this.additionalSummary,
    this.stationRevenue = const {},
    this.cancelRevenue = const {},
  });

  factory DailyReportSummary.fromJson(Map<String, dynamic> json) {
    return DailyReportSummary(
      salesRevenueSummary: json['sales_revenue_summary'] is Map<String, dynamic>
          ? SalesRevenueSummary.fromJson(
              json['sales_revenue_summary'] as Map<String, dynamic>)
          : null,
      balanceSummary: json['balance_summary'] is Map<String, dynamic>
          ? BalanceSummary.fromJson(
              json['balance_summary'] as Map<String, dynamic>)
          : null,
      totalPurchaseAndExpense:
          json['total_purchase_and_expense'] is Map<String, dynamic>
              ? TotalPurchaseAndExpenseSummary.fromJson(
                  json['total_purchase_and_expense'] as Map<String, dynamic>)
              : null,
      aggregatorOrder: _mapToStringMap(json['aggrigator_order']),
      additionalSummary: json['additional_summary'] is Map<String, dynamic>
          ? AdditionalSummary.fromJson(
              json['additional_summary'] as Map<String, dynamic>)
          : null,
      stationRevenue: _mapToStringMap(json['station_revenue']),
      cancelRevenue: _mapToStringMap(json['cancel_revenue']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (salesRevenueSummary != null)
        'sales_revenue_summary': salesRevenueSummary!.toJson(),
      if (balanceSummary != null) 'balance_summary': balanceSummary!.toJson(),
      if (totalPurchaseAndExpense != null)
        'total_purchase_and_expense': totalPurchaseAndExpense!.toJson(),
      'aggrigator_order': aggregatorOrder,
      if (additionalSummary != null)
        'additional_summary': additionalSummary!.toJson(),
      'station_revenue': stationRevenue,
      'cancel_revenue': cancelRevenue,
    };
  }
}

class SalesRevenueSummary {
  SalesSection? sales;
  FoodSalesSection? foodSales;
  CreditSection? credit;
  RoomSalesSection? roomSales;

  SalesRevenueSummary({
    this.sales,
    this.foodSales,
    this.credit,
    this.roomSales,
  });

  factory SalesRevenueSummary.fromJson(Map<String, dynamic> json) {
    return SalesRevenueSummary(
      sales: json['sales'] is Map<String, dynamic>
          ? SalesSection.fromJson(json['sales'] as Map<String, dynamic>)
          : null,
      foodSales: json['food_sales'] is Map<String, dynamic>
          ? FoodSalesSection.fromJson(
              json['food_sales'] as Map<String, dynamic>)
          : null,
      credit: json['credit'] is Map<String, dynamic>
          ? CreditSection.fromJson(json['credit'] as Map<String, dynamic>)
          : null,
      roomSales: json['room_sales'] is Map<String, dynamic>
          ? RoomSalesSection.fromJson(
              json['room_sales'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (sales != null) 'sales': sales!.toJson(),
      if (foodSales != null) 'food_sales': foodSales!.toJson(),
      if (credit != null) 'credit': credit!.toJson(),
      if (roomSales != null) 'room_sales': roomSales!.toJson(),
    };
  }
}

class SalesSection {
  String totalSales;
  String totalPaidRevenue;
  String paidCashRevenue;
  Map<String, String> breakdown;

  SalesSection({
    this.totalSales = '0.00',
    this.totalPaidRevenue = '0.00',
    this.paidCashRevenue = '0.00',
    this.breakdown = const {},
  });

  factory SalesSection.fromJson(Map<String, dynamic> json) {
    return SalesSection(
      totalSales: _asAmount(json['total_sales']),
      totalPaidRevenue: _asAmount(json['total_paid_revenue']),
      paidCashRevenue: _asAmount(json['paid_cash_revenue']),
      breakdown: _mapToStringMap(json['breakdown']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sales': totalSales,
      'total_paid_revenue': totalPaidRevenue,
      'paid_cash_revenue': paidCashRevenue,
      'breakdown': breakdown,
    };
  }
}

class FoodSalesSection {
  String foodSales;
  String foodPaidRevenue;
  String foodPaidCashRevenue;
  Map<String, String> breakdown;
  String? roomCash;
  String? roomCard;
  String? roomUpi;
  String runningOrders;

  FoodSalesSection({
    this.foodSales = '0.00',
    this.foodPaidRevenue = '0.00',
    this.foodPaidCashRevenue = '0.00',
    this.breakdown = const {},
    this.roomCash,
    this.roomCard,
    this.roomUpi,
    this.runningOrders = '0',
  });

  factory FoodSalesSection.fromJson(Map<String, dynamic> json) {
    return FoodSalesSection(
      foodSales: _asAmount(json['food_sales']),
      foodPaidRevenue: _asAmount(json['food_paid_revenue']),
      foodPaidCashRevenue: _asAmount(json['food_paid_cash_revenue']),
      breakdown: _mapToStringMap(json['breakdown']),
      roomCash:
          json.containsKey('room_cash') ? _asAmount(json['room_cash']) : null,
      roomCard:
          json.containsKey('room_card') ? _asAmount(json['room_card']) : null,
      roomUpi:
          json.containsKey('room_upi') ? _asAmount(json['room_upi']) : null,
      runningOrders: _asCount(json['running_orders']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_sales': foodSales,
      'food_paid_revenue': foodPaidRevenue,
      'food_paid_cash_revenue': foodPaidCashRevenue,
      'breakdown': breakdown,
      if (roomCash != null) 'room_cash': roomCash,
      if (roomCard != null) 'room_card': roomCard,
      if (roomUpi != null) 'room_upi': roomUpi,
      'running_orders': runningOrders,
    };
  }
}

class CreditSection {
  String credit;
  String creditPaidRevenue;
  Map<String, String> breakdown;

  CreditSection({
    this.credit = '0.00',
    this.creditPaidRevenue = '0.00',
    this.breakdown = const {},
  });

  factory CreditSection.fromJson(Map<String, dynamic> json) {
    return CreditSection(
      credit: _asAmount(json['credit']),
      creditPaidRevenue: _asAmount(json['credit_paid_revenue']),
      breakdown: _mapToStringMap(json['breakdown']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'credit': credit,
      'credit_paid_revenue': creditPaidRevenue,
      'breakdown': breakdown,
    };
  }
}

class RoomSalesSection {
  String roomSales;
  String roomPaidRevenue;
  Map<String, String> breakdown;
  String advanceAmount;
  String checkoutPaidRevenue;
  String runningRooms;

  RoomSalesSection({
    this.roomSales = '0.00',
    this.roomPaidRevenue = '0.00',
    this.breakdown = const {},
    this.advanceAmount = '0.00',
    this.checkoutPaidRevenue = '0.00',
    this.runningRooms = '0',
  });

  factory RoomSalesSection.fromJson(Map<String, dynamic> json) {
    return RoomSalesSection(
      roomSales: _asAmount(json['room_sales']),
      roomPaidRevenue: _asAmount(json['room_paid_revenue']),
      breakdown: _mapToStringMap(json['breakdown']),
      advanceAmount: _asAmount(json['advance_amount']),
      checkoutPaidRevenue: _asAmount(json['checkout_paid_revenue']),
      runningRooms: _asCount(json['running_rooms']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_sales': roomSales,
      'room_paid_revenue': roomPaidRevenue,
      'breakdown': breakdown,
      'advance_amount': advanceAmount,
      'checkout_paid_revenue': checkoutPaidRevenue,
      'running_rooms': runningRooms,
    };
  }
}

class BalanceSummary {
  String openingBalance;
  String paidCashRevenue;
  String totalPurchase;
  String totalExpense;
  String currentBalanceGalla;
  String cashCollected;
  String totalPilferage;
  String closingBalance;
  String totalProfitLoss;

  BalanceSummary({
    this.openingBalance = '0.00',
    this.paidCashRevenue = '0.00',
    this.totalPurchase = '0.00',
    this.totalExpense = '0.00',
    this.currentBalanceGalla = '0.00',
    this.cashCollected = '0.00',
    this.totalPilferage = '0.00',
    this.closingBalance = '0.00',
    this.totalProfitLoss = '0.00',
  });

  factory BalanceSummary.fromJson(Map<String, dynamic> json) {
    return BalanceSummary(
      openingBalance: _asAmount(json['opening_balance']),
      paidCashRevenue: _asAmount(json['paid_cash_revenue']),
      totalPurchase: _asAmount(json['total_purchase']),
      totalExpense: _asAmount(json['total_expense']),
      currentBalanceGalla: _asAmount(json['current_balance_galla']),
      cashCollected: _asAmount(json['cash_collected']),
      totalPilferage: _asAmount(json['total_pilferage']),
      closingBalance: _asAmount(json['closing_balance']),
      totalProfitLoss: _asAmount(json['total_profit_loss']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'opening_balance': openingBalance,
      'paid_cash_revenue': paidCashRevenue,
      'total_purchase': totalPurchase,
      'total_expense': totalExpense,
      'current_balance_galla': currentBalanceGalla,
      'cash_collected': cashCollected,
      'total_pilferage': totalPilferage,
      'closing_balance': closingBalance,
      'total_profit_loss': totalProfitLoss,
    };
  }
}

class TotalPurchaseAndExpenseSummary {
  String totalPurchaseAndExpense;
  String cashDrawer;
  String cash;
  String card;
  String upi;
  String store;
  String unpaid;
  String upiDrawer;
  String bankTransfer;
  String others;

  TotalPurchaseAndExpenseSummary({
    this.totalPurchaseAndExpense = '0.00',
    this.cashDrawer = '0.00',
    this.cash = '0.00',
    this.card = '0.00',
    this.upi = '0.00',
    this.store = '0.00',
    this.unpaid = '0.00',
    this.upiDrawer = '0.00',
    this.bankTransfer = '0.00',
    this.others = '0.00',
  });

  factory TotalPurchaseAndExpenseSummary.fromJson(Map<String, dynamic> json) {
    final breakdown = _asMap(json['breakdown']);
    return TotalPurchaseAndExpenseSummary(
      totalPurchaseAndExpense: _asAmount(json['total_purchase_and_expense']),
      cashDrawer: _asAmount(json['cash_drawer']),
      cash: _asAmount(breakdown['cash']),
      card: _asAmount(breakdown['card']),
      upi: _asAmount(breakdown['upi']),
      store: _asAmount(breakdown['store']),
      unpaid: _asAmount(breakdown['unpaid']),
      upiDrawer: _asAmount(breakdown['upi_drawer']),
      bankTransfer: _asAmount(breakdown['bank_transfer']),
      others: _asAmount(breakdown['others']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_purchase_and_expense': totalPurchaseAndExpense,
      'cash_drawer': cashDrawer,
      'breakdown': {
        'cash': cash,
        'card': card,
        'upi': upi,
        'store': store,
        'unpaid': unpaid,
        'upi_drawer': upiDrawer,
        'bank_transfer': bankTransfer,
        'others': others,
      },
    };
  }
}

class AdditionalSummary {
  String serviceCharge;
  String discount;
  String tips;
  String tax;

  AdditionalSummary({
    this.serviceCharge = '0.00',
    this.discount = '0.00',
    this.tips = '0.00',
    this.tax = '0.00',
  });

  factory AdditionalSummary.fromJson(Map<String, dynamic> json) {
    return AdditionalSummary(
      serviceCharge: _asAmount(json['service_charge']),
      discount: _asAmount(json['discount']),
      tips: _asAmount(json['tips']),
      tax: _asAmount(json['tax']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_charge': serviceCharge,
      'discount': discount,
      'tips': tips,
      'tax': tax,
    };
  }
}

String _asAmount(dynamic value) {
  final parsed = double.tryParse(value?.toString() ?? '');
  return (parsed ?? 0).toStringAsFixed(2);
}

String _asCount(dynamic value) {
  final parsed = double.tryParse(value?.toString() ?? '');
  if (parsed == null) return '0';
  if (parsed == parsed.roundToDouble()) return parsed.toInt().toString();
  return parsed.toString();
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

Map<String, String> _mapToStringMap(dynamic value) {
  if (value is Map) {
    return value.map(
        (key, item) => MapEntry(key.toString(), _asAmount(item)));
  }
  if (value is List) {
    final mapped = <String, String>{};
    for (final item in value) {
      if (item is Map) {
        if (item.length == 1) {
          final entry = item.entries.first;
          mapped[entry.key.toString()] = _asAmount(entry.value);
        } else {
          final name = item['name'] ?? item['station'] ?? item['key'];
          final amount = item['amount'] ?? item['revenue'] ?? item['value'];
          if (name != null) {
            mapped[name.toString()] = _asAmount(amount);
          }
        }
      }
    }
    return mapped;
  }
  return {};
}
