// class DailySalesResponse {
//   List<DailyReport> dailyReports;
//   GrandTotal grandTotal;
//   OrderStatus orderStatus;
//   String from;
//   String to;

//   DailySalesResponse({
//     required this.dailyReports,
//     required this.grandTotal,
//     required this.orderStatus,
//     required this.from,
//     required this.to,
//   });

//   factory DailySalesResponse.fromJson(Map<String, dynamic> json) {
//     return DailySalesResponse(
//       dailyReports: (json['daily_reports'] as List)
//           .map((e) => DailyReport.fromJson(e))
//           .toList(),
//       grandTotal: GrandTotal.fromJson(json['grand_total']),
//       orderStatus: OrderStatus.fromJson(json['order_stats']),
//       from: json['from'],
//       to: json['to'],
//     );
//   }
// }

// class DailyReport {
//   String date;
//   List<Order> report;
//   String paidRevenue;
//   OrderRevenue orderRevenue;
//   TabRevenue tabRevenue;
//   RoomRevenue roomRevenue;
//   UnpaidRevenue unpaidRevenue;
//   String totalSales;
//   String gstAmount;
//   String deliveryCharge;
//   String serviceTax;
//   String tipAmount;

//   DailyReport({
//     required this.date,
//     required this.report,
//     required this.paidRevenue,
//     required this.orderRevenue,
//     required this.tabRevenue,
//     required this.roomRevenue,
//     required this.unpaidRevenue,
//     required this.totalSales,
//     required this.gstAmount,
//     required this.deliveryCharge,
//     required this.serviceTax,
//     required this.tipAmount,
//   });

//   factory DailyReport.fromJson(Map<String, dynamic> json) {
//     return DailyReport(
//       date: json['date'],
//       report: (json['report'] as List).map((e) => Order.fromJson(e)).toList(),
//       paidRevenue: json['paid_revenue'],
//       orderRevenue: OrderRevenue.fromJson(json['order_revenue']),
//       tabRevenue: TabRevenue.fromJson(json['tab_revenue']),
//       roomRevenue: RoomRevenue.fromJson(json['room_revenue']),
//       unpaidRevenue: UnpaidRevenue.fromJson(json['unpaid_revenue']),
//       totalSales: json['total_sales'],
//       gstAmount: json['gst_amount'],
//       deliveryCharge: json['delivery_charge'],
//       serviceTax: json['service_tax'],
//       tipAmount: json['tip_amount'],
//     );
//   }
// }

// class Order {
//   int orderId;
//   String restaurantOrderId;
//   String orderType;
//   String orderDate;
//   String orderNewDate;
//   String waiter;
//   String collectedBy;
//   String gstAmount;
//   String deliveryCharge;
//   String serviceTax;
//   String tipAmount;
//   String paymentType;
//   String amount;
//   String orderDiscount;

//   Order({
//     required this.orderId,
//     required this.restaurantOrderId,
//     required this.orderType,
//     required this.orderDate,
//     required this.orderNewDate,
//     required this.waiter,
//     required this.collectedBy,
//     required this.gstAmount,
//     required this.deliveryCharge,
//     required this.serviceTax,
//     required this.tipAmount,
//     required this.paymentType,
//     required this.amount,
//     required this.orderDiscount,
//   });

//   factory Order.fromJson(Map<String, dynamic> json) {
//     return Order(
//       // orderId: json['order_id'],
//       orderId: int.tryParse(json['order_id'].toString()) ?? 0,
//       restaurantOrderId: json['restaurant_order_id'],
//       orderType: json['order_type'],
//       orderDate: json['order_date'],
//       orderNewDate: json['order_new_date'],
//       waiter: json['waiter'],
//       collectedBy: json['collected_by'],
//       gstAmount: json['gst_amount'],
//       deliveryCharge: json['delivery_charge'],
//       serviceTax: json['service_tax'],
//       tipAmount: json['tip_amount'],
//       paymentType: json['payment_type'],
//       amount: json['amount'],
//       orderDiscount: json['order_discount'],
//     );
//   }
// }

// class OrderRevenue {
//   String cash;
//   String card;
//   String upi;

//   OrderRevenue({
//     required this.cash,
//     required this.card,
//     required this.upi,
//   });

//   factory OrderRevenue.fromJson(Map<String, dynamic> json) {
//     return OrderRevenue(
//       cash: json['Cash'],
//       card: json['Card'],
//       upi: json['UPI'],
//     );
//   }
// }

// class TabRevenue {
//   String tabCash;
//   String tabCard;
//   String tabUpi;

//   TabRevenue({
//     required this.tabCash,
//     required this.tabCard,
//     required this.tabUpi,
//   });

//   factory TabRevenue.fromJson(Map<String, dynamic> json) {
//     return TabRevenue(
//       tabCash: json['tab_cash'],
//       tabCard: json['tab_card'],
//       tabUpi: json['tab_upi'],
//     );
//   }
// }

// class RoomRevenue {
//   String roomCash;
//   String roomCard;
//   String roomUpi;

//   RoomRevenue({
//     required this.roomCash,
//     required this.roomCard,
//     required this.roomUpi,
//   });

//   factory RoomRevenue.fromJson(Map<String, dynamic> json) {
//     return RoomRevenue(
//       roomCash: json['Room Cash'],
//       roomCard: json['Room Card'],
//       roomUpi: json['Room UPI'],
//     );
//   }
// }

// class UnpaidRevenue {
//   String orderTab;
//   String orderRoom;

//   UnpaidRevenue({
//     required this.orderTab,
//     required this.orderRoom,
//   });

//   factory UnpaidRevenue.fromJson(Map<String, dynamic> json) {
//     return UnpaidRevenue(
//       orderTab: json['orderTAB'],
//       orderRoom: json['orderRoom'],
//     );
//   }
// }

// class GrandTotal {
//   String paidRevenue;
//   OrderRevenue orderRevenue;
//   TabRevenue tabRevenue;
//   RoomRevenue roomRevenue;
//   UnpaidRevenue unpaidRevenue;
//   String totalSales;
//   String gstAmount;
//   String deliveryCharge;
//   String serviceTax;
//   String tipAmount;
//   String totalDiscount;

//   GrandTotal({
//     required this.paidRevenue,
//     required this.orderRevenue,
//     required this.tabRevenue,
//     required this.roomRevenue,
//     required this.unpaidRevenue,
//     required this.totalSales,
//     required this.gstAmount,
//     required this.deliveryCharge,
//     required this.serviceTax,
//     required this.tipAmount,
//     required this.totalDiscount,
//   });

//   factory GrandTotal.fromJson(Map<String, dynamic> json) {
//     return GrandTotal(
//       paidRevenue: json['paid_revenue'],
//       orderRevenue: OrderRevenue.fromJson(json['order_revenue']),
//       tabRevenue: TabRevenue.fromJson(json['tab_revenue']),
//       roomRevenue: RoomRevenue.fromJson(json['room_revenue']),
//       unpaidRevenue: UnpaidRevenue.fromJson(json['unpaid_revenue']),
//       totalSales: json['total_sales'],
//       gstAmount: json['gst_amount'],
//       deliveryCharge: json['delivery_charge'],
//       serviceTax: json['service_tax'],
//       tipAmount: json['tip_amount'],
//       totalDiscount: json['total_discount'],
//     );
//   }
// }

// class OrderStatus {
//   int paidOrders;
//   int unpaidOrders;
//   int cancelOrders;

//   OrderStatus({
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

import 'dart:developer';

class DailySalesResponse {
  List<DailyReport>? dailyReports; // Made nullable
  GrandTotal? grandTotal; // Made nullable
  OrderStatus? orderStatus; // Made nullable
  String? from; // Made nullable
  String? to; // Made nullable

  DailySalesResponse({
    this.dailyReports,
    this.grandTotal,
    this.orderStatus,
    this.from,
    this.to,
  });

  factory DailySalesResponse.fromJson(Map<String, dynamic> json) {
    try {
      return DailySalesResponse(
        dailyReports: json['daily_reports'] != null
            ? (json['daily_reports'] as List)
                .map((e) => DailyReport.fromJson(e))
                .toList()
            : null,
        grandTotal: json['grand_total'] != null
            ? GrandTotal.fromJson(json['grand_total'])
            : null,
        orderStatus: json['order_stats'] != null
            ? OrderStatus.fromJson(json['order_stats'])
            : null,
        from: json['from']?.toString(),
        to: json['to']?.toString(),
      );
    } catch (e) {
      log("Error in DailySalesResponse.fromJson: $e");
      rethrow;
    }
  }
}

class DailyReport {
  String? date; // Made nullable
  List<Order>? report; // Made nullable
  String? paidRevenue; // Made nullable
  OrderRevenue? orderRevenue; // Made nullable
  TabRevenue? tabRevenue; // Made nullable
  RoomRevenue? roomRevenue; // Made nullable
  UnpaidRevenue? unpaidRevenue; // Made nullable
  String? totalSales; // Made nullable
  String? gstAmount; // Made nullable
  String? deliveryCharge; // Made nullable
  String? serviceTax; // Made nullable
  String? tipAmount; // Made nullable

  DailyReport({
    this.date,
    this.report,
    this.paidRevenue,
    this.orderRevenue,
    this.tabRevenue,
    this.roomRevenue,
    this.unpaidRevenue,
    this.totalSales,
    this.gstAmount,
    this.deliveryCharge,
    this.serviceTax,
    this.tipAmount,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    try {
      return DailyReport(
        date: json['date']?.toString(),
        report: json['report'] != null
            ? (json['report'] as List).map((e) => Order.fromJson(e)).toList()
            : null,
        paidRevenue: json['paid_revenue']?.toString(),
        orderRevenue: json['order_revenue'] != null
            ? OrderRevenue.fromJson(json['order_revenue'])
            : null,
        tabRevenue: json['tab_revenue'] != null
            ? TabRevenue.fromJson(json['tab_revenue'])
            : null,
        roomRevenue: json['room_revenue'] != null
            ? RoomRevenue.fromJson(json['room_revenue'])
            : null,
        unpaidRevenue: json['unpaid_revenue'] != null
            ? UnpaidRevenue.fromJson(json['unpaid_revenue'])
            : null,
        totalSales: json['total_sales']?.toString(),
        gstAmount: json['gst_amount']?.toString(),
        deliveryCharge: json['delivery_charge']?.toString(),
        serviceTax: json['service_tax']?.toString(),
        tipAmount: json['tip_amount']?.toString(),
      );
    } catch (e) {
      log("Error in DailyReport.fromJson: $e");
      rethrow;
    }
  }
}

class Order {
  int? orderId; // Made nullable
  String? restaurantOrderId; // Made nullable
  String? orderType; // Made nullable
  String? orderDate; // Made nullable
  String? orderNewDate; // Made nullable
  String? waiter; // Made nullable
  String? collectedBy; // Made nullable
  String? gstAmount; // Made nullable
  String? deliveryCharge; // Made nullable
  String? serviceTax; // Made nullable
  String? tipAmount; // Made nullable
  String? paymentType; // Made nullable
  String? amount; // Made nullable
  String? orderDiscount; // Made nullable
  String? roundOff; // Made nullable
  String? quantity;
  String? foodName;
  String? membershipId;
  String? dateOfBirth;
  String? dateOfAnniversary;
  // Added missing fields from API
  int? waiterId; // Added for API field
  int? employeeId; // Added for API field
  String? paymentFor; // Added for API field
  String? orderPlateform;
  CustomerInfo? customerInfo; // Made nullable
  Payment? payment; // Made nullable

  Order({
    this.orderId,
    this.restaurantOrderId,
    this.orderType,
    this.orderDate,
    this.orderNewDate,
    this.waiter,
    this.collectedBy,
    this.gstAmount,
    this.deliveryCharge,
    this.serviceTax,
    this.tipAmount,
    this.paymentType,
    this.amount,
    this.membershipId,
    this.dateOfBirth,
    this.dateOfAnniversary,
    this.orderDiscount,
    this.quantity,
    this.roundOff,
    this.foodName,
    this.waiterId,
    this.employeeId,
    this.paymentFor,
    this.orderPlateform,
    this.customerInfo,
    this.payment,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    try {
      return Order(
        orderId: int.tryParse(json['order_id']?.toString() ?? '') ?? 0,
        restaurantOrderId: json['restaurant_order_id']?.toString(),
        orderType: json['order_type']?.toString(),
        orderDate: json['order_date']?.toString(),
        orderNewDate: json['order_new_date']?.toString(),
        waiter: json['waiter']?.toString(),
        collectedBy: json['collected_by']?.toString(),
        gstAmount: json['gst_amount']?.toString(),
        deliveryCharge: json['delivery_charge']?.toString(),
        serviceTax: json['service_tax']?.toString(),
        tipAmount: json['tip_amount']?.toString(),
        paymentType: json['payment_type']?.toString(),
        amount: json['amount']?.toString(),
        membershipId: json['membership_id']?.toString(),
        dateOfBirth: json['date_of_birth']?.toString(),
        dateOfAnniversary: json['date_of_anniversary']?.toString(),
        roundOff: json['roundoff']?.toString(),
        orderDiscount:
            json['order_discount']?.toString() ?? '0.00', // Default value
        quantity: json['quantity']?.toString() ?? '0',
        foodName: json['food_name']?.toString(),
        waiterId: int.tryParse(json['waiter_id']?.toString() ?? '') ?? 0,
        employeeId: int.tryParse(json['employee_id']?.toString() ?? '') ?? 0,
        paymentFor: json['payment_for']?.toString(),
        orderPlateform: json['order_plateform']?.toString(),
        customerInfo: json['customer_info'] != null
            ? CustomerInfo.fromJson(json['customer_info'])
            : null,
        payment:
            json['payment'] != null ? Payment.fromJson(json['payment']) : null,
      );
    } catch (e) {
      log("Error in Order.fromJson: $e");
      rethrow;
    }
  }
}

class OrderRevenue {
  String? cash; // Made nullable
  String? card; // Made nullable
  String? upi; // Made nullable

  OrderRevenue({
    this.cash,
    this.card,
    this.upi,
  });

  factory OrderRevenue.fromJson(Map<String, dynamic> json) {
    return OrderRevenue(
      cash: json['Cash']?.toString(),
      card: json['Card']?.toString(),
      upi: json['UPI']?.toString(),
    );
  }
}

class TabRevenue {
  String? tabCash; // Made nullable
  String? tabCard; // Made nullable
  String? tabUpi; // Made nullable

  TabRevenue({
    this.tabCash,
    this.tabCard,
    this.tabUpi,
  });

  factory TabRevenue.fromJson(Map<String, dynamic> json) {
    return TabRevenue(
      tabCash: json['tab_cash']?.toString(),
      tabCard: json['tab_card']?.toString(),
      tabUpi: json['tab_upi']?.toString(),
    );
  }
}

class RoomRevenue {
  String? roomCash; // Made nullable
  String? roomCard; // Made nullable
  String? roomUpi; // Made nullable

  RoomRevenue({
    this.roomCash,
    this.roomCard,
    this.roomUpi,
  });

  factory RoomRevenue.fromJson(Map<String, dynamic> json) {
    return RoomRevenue(
      roomCash: json['Room Cash']?.toString(),
      roomCard: json['Room Card']?.toString(),
      roomUpi: json['Room UPI']?.toString(),
    );
  }
}

class UnpaidRevenue {
  String? orderTab; // Made nullable
  String? orderRoom; // Made nullable

  UnpaidRevenue({
    this.orderTab,
    this.orderRoom,
  });

  factory UnpaidRevenue.fromJson(Map<String, dynamic> json) {
    return UnpaidRevenue(
      orderTab: json['orderTAB']?.toString(),
      orderRoom: json['orderRoom']?.toString(),
    );
  }
}

class GrandTotal {
  String? paidRevenue; // Made nullable
  OrderRevenue? orderRevenue; // Made nullable
  TabRevenue? tabRevenue; // Made nullable
  RoomRevenue? roomRevenue; // Made nullable
  UnpaidRevenue? unpaidRevenue; // Made nullable
  String? totalSales; // Made nullable
  String? gstAmount; // Made nullable
  String? deliveryCharge; // Made nullable
  String? serviceTax; // Made nullable
  String? tipAmount; // Made nullable
  String? totalDiscount; // Made nullable
  String? roundOff; // Made nullable

  GrandTotal({
    this.paidRevenue,
    this.orderRevenue,
    this.tabRevenue,
    this.roomRevenue,
    this.unpaidRevenue,
    this.totalSales,
    this.gstAmount,
    this.deliveryCharge,
    this.serviceTax,
    this.tipAmount,
    this.totalDiscount,
    this.roundOff,
  });

  factory GrandTotal.fromJson(Map<String, dynamic> json) {
    try {
      return GrandTotal(
        paidRevenue: json['paid_revenue']?.toString(),
        orderRevenue: json['order_revenue'] != null
            ? OrderRevenue.fromJson(json['order_revenue'])
            : null,
        tabRevenue: json['tab_revenue'] != null
            ? TabRevenue.fromJson(json['tab_revenue'])
            : null,
        roomRevenue: json['room_revenue'] != null
            ? RoomRevenue.fromJson(json['room_revenue'])
            : null,
        unpaidRevenue: json['unpaid_revenue'] != null
            ? UnpaidRevenue.fromJson(json['unpaid_revenue'])
            : null,
        totalSales: json['total_sales']?.toString(),
        gstAmount: json['gst_amount']?.toString(),
        deliveryCharge: json['delivery_charge']?.toString(),
        serviceTax: json['service_tax']?.toString(),
        tipAmount: json['tip_amount']?.toString(),
        totalDiscount:
            json['total_discount']?.toString() ?? '0.00', // Default value
        roundOff: json['roundoff']?.toString(),
      );
    } catch (e) {
      log("Error in GrandTotal.fromJson: $e");
      rethrow;
    }
  }
}

class OrderStatus {
  int? paidOrders; // Made nullable
  int? unpaidOrders; // Made nullable
  int? cancelOrders; // Made nullable

  OrderStatus({
    this.paidOrders,
    this.unpaidOrders,
    this.cancelOrders,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      paidOrders: json['paidOrders'] as int?,
      unpaidOrders: json['unpaidOrders'] as int?,
      cancelOrders: json['cancelOrders'] as int?,
    );
  }
}

class CustomerInfo {
  String? contactPersonName; // Made nullable
  String? contactPersonNumber; // Made nullable
  String? addressType; // Made nullable
  String? address; // Made nullable
  String? pincode; // Made nullable
  String? floor; // Made nullable
  String? road; // Made nullable
  String? house; // Made nullable
  String? longitude; // Made nullable
  String? latitude; // Made nullable

  CustomerInfo({
    this.contactPersonName,
    this.contactPersonNumber,
    this.addressType,
    this.address,
    this.pincode,
    this.floor,
    this.road,
    this.house,
    this.longitude,
    this.latitude,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    try {
      return CustomerInfo(
        contactPersonName: json['contact_person_name']?.toString(),
        contactPersonNumber: json['contact_person_number']?.toString(),
        addressType: json['address_type']?.toString(),
        address: json['address']?.toString(),
        pincode: json['pincode']?.toString(),
        floor: json['floor']?.toString(),
        road: json['road']?.toString(),
        house: json['house']?.toString(),
        longitude: json['longitude']?.toString(),
        latitude: json['latitude']?.toString(),
      );
    } catch (e) {
      log("Error in CustomerInfo.fromJson: $e");
      rethrow;
    }
  }
}

class Payment {
  String? Cash; // Made nullable
  String? Card; // Made nullable
  String? Upi; // Made nullable
  String? Tab; // Made nullable

  Payment({
    this.Cash,
    this.Card,
    this.Upi,
    this.Tab,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      Cash: json['cash']?.toString(),
      Card: json['card']?.toString(),
      Upi: json['upi']?.toString(),
      Tab: json['tab']?.toString(),
    );
  }
}
