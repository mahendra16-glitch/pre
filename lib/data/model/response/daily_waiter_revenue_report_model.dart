class DailyWaiterSalesResponse {
  List<DailyWaiterReport> dailyReports;
  GrandTotal grandTotal;
  // OrderStatus orderStatus;
  String from;
  String to;

  DailyWaiterSalesResponse({
    required this.dailyReports,
    required this.grandTotal,
    // required this.orderStatus,
    required this.from,
    required this.to,
  });

  factory DailyWaiterSalesResponse.fromJson(Map<String, dynamic> json) {
    return DailyWaiterSalesResponse(
      dailyReports: (json['daily_reports'] as List)
          .map((e) => DailyWaiterReport.fromJson(e))
          .toList(),
      grandTotal: GrandTotal.fromJson(json['grand_total']),
      // orderStatus: OrderStatus.fromJson(json['order_stats']),
      from: json['from'],
      to: json['to'],
    );
  }
}

class DailyWaiterReport {
  String date;
  List<Order> report;
  String paidRevenue;
  OrderRevenue orderRevenue;
  TabRevenue tabRevenue;
  RoomRevenue roomRevenue;
  UnpaidRevenue unpaidRevenue;
  String totalSales;
  String gstAmount;
  String deliveryCharge;
  String serviceTax;
  String tipAmount;

  DailyWaiterReport({
    required this.date,
    required this.report,
    required this.paidRevenue,
    required this.orderRevenue,
    required this.tabRevenue,
    required this.roomRevenue,
    required this.unpaidRevenue,
    required this.totalSales,
    required this.gstAmount,
    required this.deliveryCharge,
    required this.serviceTax,
    required this.tipAmount,
  });

  factory DailyWaiterReport.fromJson(Map<String, dynamic> json) {
    return DailyWaiterReport(
      date: json['date'],
      report: (json['report'] as List).map((e) => Order.fromJson(e)).toList(),
      paidRevenue: json['paid_revenue'],
      orderRevenue: OrderRevenue.fromJson(json['order_revenue']),
      tabRevenue: TabRevenue.fromJson(json['tab_revenue']),
      roomRevenue: RoomRevenue.fromJson(json['room_revenue']),
      unpaidRevenue: UnpaidRevenue.fromJson(json['unpaid_revenue']),
      totalSales: json['total_sales'],
      gstAmount: json['gst_amount'],
      deliveryCharge: json['delivery_charge'],
      serviceTax: json['service_tax'],
      tipAmount: json['tip_amount'],
    );
  }
}

class Order {
  int orderId;
  String restaurantOrderId;
  String orderType;
  String orderDate;
  String orderNewDate;
  String waiter;
  String collectedBy;
  String gstAmount;
  String deliveryCharge;
  String serviceTax;
  String tipAmount;
  String paymentType;
  String amount;
  String orderDiscount;

  Order({
    required this.orderId,
    required this.restaurantOrderId,
    required this.orderType,
    required this.orderDate,
    required this.orderNewDate,
    required this.waiter,
    required this.collectedBy,
    required this.gstAmount,
    required this.deliveryCharge,
    required this.serviceTax,
    required this.tipAmount,
    required this.paymentType,
    required this.amount,
    required this.orderDiscount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      // orderId: json['order_id'],
      orderId: int.tryParse(json['order_id'].toString()) ?? 0,
      restaurantOrderId: json['restaurant_order_id'],
      orderType: json['order_type'],
      orderDate: json['order_date'],
      orderNewDate: json['order_new_date'],
      waiter: json['waiter'],
      collectedBy: json['collected_by'],
      gstAmount: json['gst_amount'],
      deliveryCharge: json['delivery_charge'],
      serviceTax: json['service_tax'],
      tipAmount: json['tip_amount'],
      paymentType: json['payment_type'],
      amount: json['amount'],
      orderDiscount: json['order_discount'],
    );
  }
}

class OrderRevenue {
  String cash;
  String card;
  String upi;

  OrderRevenue({
    required this.cash,
    required this.card,
    required this.upi,
  });

  factory OrderRevenue.fromJson(Map<String, dynamic> json) {
    return OrderRevenue(
      cash: json['Cash'],
      card: json['Card'],
      upi: json['UPI'],
    );
  }
}

class TabRevenue {
  String tabCash;
  String tabCard;
  String tabUpi;

  TabRevenue({
    required this.tabCash,
    required this.tabCard,
    required this.tabUpi,
  });

  factory TabRevenue.fromJson(Map<String, dynamic> json) {
    return TabRevenue(
      tabCash: json['tab_cash'],
      tabCard: json['tab_card'],
      tabUpi: json['tab_upi'],
    );
  }
}

class RoomRevenue {
  String roomCash;
  String roomCard;
  String roomUpi;

  RoomRevenue({
    required this.roomCash,
    required this.roomCard,
    required this.roomUpi,
  });

  factory RoomRevenue.fromJson(Map<String, dynamic> json) {
    return RoomRevenue(
      roomCash: json['Room Cash'],
      roomCard: json['Room Card'],
      roomUpi: json['Room UPI'],
    );
  }
}

class UnpaidRevenue {
  String orderTab;
  String orderRoom;

  UnpaidRevenue({
    required this.orderTab,
    required this.orderRoom,
  });

  factory UnpaidRevenue.fromJson(Map<String, dynamic> json) {
    return UnpaidRevenue(
      orderTab: json['orderTAB'],
      orderRoom: json['orderRoom'],
    );
  }
}

class GrandTotal {
  String paidRevenue;
  OrderRevenue orderRevenue;
  TabRevenue tabRevenue;
  RoomRevenue roomRevenue;
  UnpaidRevenue unpaidRevenue;
  String totalSales;
  String gstAmount;
  String deliveryCharge;
  String serviceTax;
  String tipAmount;
  String totalDiscount;

  GrandTotal({
    required this.paidRevenue,
    required this.orderRevenue,
    required this.tabRevenue,
    required this.roomRevenue,
    required this.unpaidRevenue,
    required this.totalSales,
    required this.gstAmount,
    required this.deliveryCharge,
    required this.serviceTax,
    required this.tipAmount,
    required this.totalDiscount,
  });

  factory GrandTotal.fromJson(Map<String, dynamic> json) {
    return GrandTotal(
      paidRevenue: json['paid_revenue'],
      orderRevenue: OrderRevenue.fromJson(json['order_revenue']),
      tabRevenue: TabRevenue.fromJson(json['tab_revenue']),
      roomRevenue: RoomRevenue.fromJson(json['room_revenue']),
      unpaidRevenue: UnpaidRevenue.fromJson(json['unpaid_revenue']),
      totalSales: json['total_sales'],
      gstAmount: json['gst_amount'],
      deliveryCharge: json['delivery_charge'],
      serviceTax: json['service_tax'],
      tipAmount: json['tip_amount'],
      totalDiscount: json['total_discount'],
    );
  }
}

// class OrderStatus {
//   int paidOrders;
//   int unpaidOrders;
//   int cancelOrders;

// OrderStatus({
//     required this.paidOrders,
//     required this.unpaidOrders,
//     required this.cancelOrders,
//   });

//   factory OrderStatus.fromJson(Map<String, dynamic> json) {
//     return OrderStatus(
//       paidOrders: json['paidOrders'],
//       unpaidOrders: json['unpaidOrders'],
//       cancelOrders: json['cancelOrders'],
//     );
//   } 

// }