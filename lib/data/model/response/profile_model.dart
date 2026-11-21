import 'dart:convert';

class ProfileModel {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? createdAt;
  String? updatedAt;
  String? bankName;
  String? branch;
  String? holderName;
  String? accountNo;
  String? firebaseToken;
  // String? aggregatorAutoKot;
  // String? aggregatorAutoBill;
  // String? aggregatorAutoBillStage;
  // String? confirmOrderTone;
  // String? aggregatorTone;
  // String? isCouponShow;
  // String? isLoyaltyShow;
  // String? serviceChargeText;
  String? image;
  int? orderCount;
  int? todaysOrderCount;
  int? thisWeekOrderCount;
  int? thisMonthOrderCount;
  int? memberSinceDays;
  int? isPOS;
  String? billPrinterIp;
  String? billWifiIp;
  String? billPrinterType;
  String? billProductId;
  String? billVendorId;
  String? macBillPrinterIp;
  int? billPrinterPaperRoll;
  String? billPrinterName;
  String? wifiBillPrinterName;
  List<Restaurant>? restaurants;
  List<int>? categoryIds;
  VatInfo? vatInfo;

  String? roleName;
  String? empFname;
  String? empEmail;
  String? empLname;
  int? empId;
  List<String>? role;
  List<String>? stationRole;

  String? defaultUser;
  String? billingUserView;
  String? isEdcUser;
  List<RestaurantPrinterNew>? restaurantPrinterNew;
  List<PrintAgent>? printAgent;
  List<PrintConfigModel>? printConfigList;
  List<PrintConfigModel>? windowsPrintConfigList;
  List<DiscountCategoryListModel>? discountList;
  String? lastOrderId;
  PrintConfigModel? printConfig;
  String? isLANPrint;
  List<int>? aggregatorAutoKotId;
  List<String>? termsCondition;

  ProfileModel({
    this.id,
    this.fName,
    this.lName,
    this.empEmail,
    this.phone,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.bankName,
    this.branch,
    this.holderName,
    this.accountNo,
    this.firebaseToken,
    this.image,
    this.orderCount,
    this.todaysOrderCount,
    this.thisWeekOrderCount,
    this.thisMonthOrderCount,
    this.memberSinceDays,
    this.isPOS,
    this.billPrinterIp,
    this.billWifiIp,
    this.billPrinterType,
    this.billVendorId,
    this.billProductId,
    this.macBillPrinterIp,
    this.billPrinterPaperRoll,
    this.billPrinterName,
    this.wifiBillPrinterName,
    this.restaurants,
    // this.subscriptionOtherData,
    this.categoryIds,
    this.roleName,
    this.empFname,
    this.empLname,
    this.empId,
    this.vatInfo,
    this.role,
    this.stationRole,
    this.defaultUser,
    this.billingUserView,
    this.isEdcUser,
    this.printConfig,
    this.restaurantPrinterNew,
    this.printAgent,
    this.discountList,
    this.lastOrderId,
    this.printConfigList,
    this.windowsPrintConfigList,
    this.isLANPrint,
    this.aggregatorAutoKotId,
    this.termsCondition,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    String loginType = '';
    String isLANPrint = 'No';
    List<String> roleList = [];
    if (json['role'] != null) {
      for (var v in json['role']) {
        roleList.add(v.toString());
        if (v.toString().toLowerCase() == 'billing') {
          loginType = 'billing';
        }
      }
    }
    List<String> stationRoleList = [];
    if (json['station_role'] != null) {
      for (var v in json['station_role']) {
        stationRoleList.add(v.toString().toUpperCase());
      }
    }

    List<PrintConfigModel> printConfigList = [];
    if (json['restaurant_printer_config'] != null &&
        json['restaurant_printer_config'] is List) {
      printConfigList = (json['restaurant_printer_config'] as List)
          .map((v) => PrintConfigModel.fromJson(v))
          .toList();
    }
    List<PrintConfigModel> windowsPrintConfigList = [];
    if (json['restaurant_printer_windows_config'] != null &&
        json['restaurant_printer_windows_config'] is List) {
      windowsPrintConfigList =
          (json['restaurant_printer_windows_config'] as List)
              .map((v) => PrintConfigModel.fromJson(v))
              .toList();
    }

    List<DiscountCategoryListModel> discountList = [];
    if (json['restaurant_discount_type'] != null &&
        json['restaurant_discount_type'] is List) {
      discountList = (json['restaurant_discount_type'] as List)
          .map((v) => DiscountCategoryListModel.fromJson(v))
          .toList();
    }

    List<Restaurant> restaurants = [];
    if (json['restaurants'] != null && json['restaurants'] is List) {
      restaurants = (json['restaurants'] as List)
          .map((v) => Restaurant.fromJson(v))
          .toList();
    }

    // SubscriptionOtherData? subscriptionOtherData;
    // if (json['subscription_other_data'] != null) {
    //   subscriptionOtherData =
    //       SubscriptionOtherData.fromJson(json['subscription_other_data']);
    // }

    List<int> categoryIds = [];
    if (json['category_ids'] != null && json['category_ids'] is List) {
      categoryIds = List<int>.from(json['category_ids']);
    }
    List<int> aggregatorAutoKotId = [];
    if (json['auto_kot_id'] != null && json['auto_kot_id'] is List) {
      aggregatorAutoKotId = List<int>.from(json['auto_kot_id']);
    }
    List<String> termsCondition = [];
    if (json['terms_conditions'] != null && json['terms_conditions'] is List) {
      termsCondition = List<String>.from(json['terms_conditions']);
    }

    List<RestaurantPrinterNew> restaurantPrinterNew = [];
    String billPrinterIp = '';
    String macBillPrinterIp = '';
    String billPrinterType = '';
    String billWifiIp = '';
    String billVendorId = '';
    String billProductId = '';
    String wifiBillPrinterName = '';
    String billPrinterName = '';
    int billPrinterPaperRoll = 58;

    if (json['restaurant_printer_new'] != null &&
        json['restaurant_printer_new'] is List) {
      for (var v in json['restaurant_printer_new']) {
        if (loginType == 'billing'
            ? v['printer_type'].toString().toLowerCase() == 'offline'
            : v['printer_type'].toString().toLowerCase() == 'online') {
          restaurantPrinterNew.add(RestaurantPrinterNew.fromJson(v));
        }

        if (v['area_name'].toString().toUpperCase() == 'BILL' &&
            (loginType == 'billing'
                ? v['printer_type'].toString().toLowerCase() == 'offline'
                : v['printer_type'].toString().toLowerCase() == 'online')) {
          billPrinterIp = v['printer_ip'] ?? '';
          billWifiIp = v['wifi_printer_ip'] ?? '';
          billPrinterPaperRoll = v['printer_paper_roll'] ?? 58;
          macBillPrinterIp = v['mac_printer_ip'] ?? '';
          if (v['wifi_printer_ip'] != null && v['wifi_printer_ip'] != '') {
            isLANPrint = 'Yes';
          }
          wifiBillPrinterName = v['wifi_printer_name'] ?? '';
          billPrinterType = v['printer_name'] ?? '';
          billVendorId = v['vendor_id']?.toString() ?? '';
          billProductId = v['product_id']?.toString() ?? '';
        }
      }
    }

    List<PrintAgent> printAgent = [];
    if (json['print_agent'] != null && json['print_agent'] is List) {
      for (var v in json['print_agent']) {
        if (v is Map<String, dynamic>) {
          printAgent.add(PrintAgent.fromJson(v));
        } else if (v is Map) {
          printAgent.add(PrintAgent.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }

    return ProfileModel(
      id: json['id'],
      fName: json['f_name'],
      lName: json['l_name'],
      phone: json['phone'],
      email: json['email'],
      empEmail: json['emp_email'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      bankName: json['bank_name'],
      branch: json['branch'],
      holderName: json['holder_name'],
      accountNo: json['account_no'],
      firebaseToken: json['firebase_token'] ?? '',
      image: json['image'],
      orderCount: json['order_count'],
      todaysOrderCount: json['todays_order_count'],
      thisWeekOrderCount: json['this_week_order_count'],
      thisMonthOrderCount: json['this_month_order_count'],
      isPOS: json['pos'],
      memberSinceDays: json['member_since_days'],
      vatInfo:
          json['vat_info'] != null ? VatInfo.fromJson(json['vat_info']) : null,
      printConfigList: printConfigList,
      windowsPrintConfigList: windowsPrintConfigList,
      discountList: discountList,
      restaurants: restaurants,
      // subscriptionOtherData: subscriptionOtherData,
      categoryIds: categoryIds,
      aggregatorAutoKotId: aggregatorAutoKotId,
      termsCondition: termsCondition,
      roleName: json['role_name'],
      empFname: json['emp_f_name'],
      empLname: json['emp_l_name'],
      empId: json['emp_id'],
      defaultUser: json['default_user'] ?? 'No',
      billingUserView: json['bill_user_view'] ?? 'No',
      isEdcUser: json['edc_user'] ?? 'No',
      lastOrderId: json['employee_last_order_id'] ?? '',
      role: roleList,
      stationRole: stationRoleList,
      billPrinterIp: billPrinterIp,
      macBillPrinterIp: macBillPrinterIp,
      billWifiIp: billWifiIp,
      billPrinterType: billPrinterType,
      billVendorId: billVendorId,
      billProductId: billProductId,
      wifiBillPrinterName: wifiBillPrinterName,
      billPrinterName: '',
      isLANPrint: isLANPrint,
      billPrinterPaperRoll: billPrinterPaperRoll,
      restaurantPrinterNew: restaurantPrinterNew,
      printAgent: printAgent,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['emp_email'] = empEmail;
    data['default_user'] = defaultUser;
    data['bill_user_view'] = billingUserView;
    data['edc_user'] = isEdcUser;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['bank_name'] = bankName;
    data['branch'] = branch;
    data['holder_name'] = holderName;
    data['account_no'] = accountNo;
    data['image'] = image;
    data['order_count'] = orderCount;
    if (vatInfo != null) {
      data['vat_info'] = vatInfo!.toJson();
    }
    data['todays_order_count'] = todaysOrderCount;
    data['this_week_order_count'] = thisWeekOrderCount;
    data['this_month_order_count'] = thisMonthOrderCount;
    data['pos'] = isPOS;
    data['member_since_days'] = memberSinceDays;
    data['firebase_token'] = firebaseToken;
    data['employee_last_order_id'] = lastOrderId;

    if (printConfigList != null) {
      data['restaurant_printer_config'] =
          printConfigList!.map((v) => v.toJson()).toList();
    }
    if (windowsPrintConfigList != null) {
      data['restaurant_printer_windows_config'] =
          windowsPrintConfigList!.map((v) => v.toJson()).toList();
    }
    if (discountList != null) {
      data['restaurant_discount_type'] =
          discountList!.map((v) => v.toJson()).toList();
    }

    if (restaurants != null) {
      data['restaurants'] = restaurants!.map((v) => v.toJson()).toList();
    }

    // if (subscriptionOtherData != null) {
    //   data['subscription_other_data'] = subscriptionOtherData!.toJson();
    // }

    data['category_ids'] = categoryIds;
    data['auto_kot_id'] = aggregatorAutoKotId;
    data['terms_conditions'] = termsCondition;
    data['role_name'] = roleName;
    data['emp_f_name'] = empFname;
    data['emp_l_name'] = empLname;
    data['emp_id'] = empId;
    if (role != null) {
      data['role'] = role!.map((v) => v).toList();
    }
    if (stationRole != null) {
      data['station_role'] = stationRole!.map((v) => v).toList();
    }
    data['bill_printer_ip'] = billPrinterIp;
    data['wifi_printer_ip'] = billWifiIp;
    data['mac_printer_ip'] = macBillPrinterIp;
    data['wifi_printer_name'] = wifiBillPrinterName;
    data['bill_printer_paper_roll'] = billPrinterPaperRoll;
    data['printer_name'] = billPrinterType;
    data['product_id'] = billProductId;
    data['vendor_id'] = billVendorId;

    if (restaurantPrinterNew != null) {
      data['restaurant_printer_new'] =
          restaurantPrinterNew!.map((v) => v.toJson()).toList();
    }
    if (printAgent != null) {
      data['print_agent'] = printAgent!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class Restaurant {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? logo;
  String? upiId;
  String? latitude;
  String? longitude;
  String? address;
  double? minimumOrder;
  bool? scheduleOrder;
  String? currency;
  String? createdAt;
  String? updatedAt;
  bool? freeDelivery;
  String? coverPhoto;
  bool? delivery;
  bool? takeAway;
  double? tax;
  double? gstTax;
  bool? reviewsSection;
  bool? foodSection;
  String? availableTimeStarts;
  String? isDineIn;
  String? availableTimeEnds;
  double? avgRating;
  int? ratingCount;
  bool? active;
  String? gstStatus;
  String? gstCode;
  int? selfDeliverySystem;
  bool? posSystem;
  double? minimumShippingCharge;
  double? maximumShippingCharge;
  double? perKmShippingCharge;
  String? restaurantModel;
  int? veg;
  int? nonVeg;
  List<Schedules>? schedules;
  List<PaymentModes>? paymentModes;
  List<String>? searchBy;
  String? deliveryTime;
  String? fssai;
  int? defOrdStatus;
  int? showOrderStatus;
  int? cancelOrderTime;
  List<Cuisine>? cuisines;
  String? isDelivery;
  String? serviceCharge;
  double? serviceChargePercentage;
  double? serviceChargeTaxPercent;
  double? tipTaxPercent;
  String? feedback;
  String? showUserGst;
  String? showFoodDate;
  String? showRoom;
  String? payUpi;
  String? payTab;
  String? payCC;
  String? payCash;
  String? roomPrice;
  String? guestDetail;
  String? bookingDetail;
  String? isPreCancel;
  String? printKot;
  String? discountType;
  String? discountText;
  String? isShowAcNonAcMenu;
  String? isShowTips;
  String? isShowInventory;
  String? isNegativeInventory;
  String? roomGstApply;
  RoomGstConfig? roomGst;
  String? printingOption;
  String? listServeItem;
  String? isShowPopularCategory;
  String? isComplementry;
  String? isDeliveryAssign;
  String? isOrderPaymentType;
  String? isTotalRound;
  String? isShowEmpList;
  String? isShowAddressKot;
  String? isSurcharge;
  String? footerTextBill;
  String? logoPath;
  String? foodLevelNotes;
  String? foodWithVariance;
  String? autoServiceCharge;
  String? dynamicUpiValue;
  String? showVoiceInKds;
  String? showPrintInKds;
  String? isShowMemberId;
  String? searchFood;
  String? billDateFormat;
  String? isShowOrderConfirmTab;
  String? isAutoBillPrintBilling;
  String? resturantType;
  String? feedbackUrl;
  String? resturantGst;
  String? settelmentReport;
  Settings? settings;
  RazorPayDetail? razorPayDetail;
  EDCResponse? edcDetail;
  String? restaurantType;

  Restaurant({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.logo,
    this.upiId,
    this.latitude,
    this.longitude,
    this.address,
    this.minimumOrder,
    this.scheduleOrder,
    this.currency,
    this.createdAt,
    this.updatedAt,
    this.freeDelivery,
    this.coverPhoto,
    this.delivery,
    this.takeAway,
    this.tax,
    this.gstTax,
    this.reviewsSection,
    this.foodSection,
    this.isDineIn,
    this.availableTimeStarts,
    this.availableTimeEnds,
    this.avgRating,
    this.ratingCount,
    this.active,
    this.gstStatus,
    this.gstCode,
    this.selfDeliverySystem,
    this.posSystem,
    this.minimumShippingCharge,
    this.maximumShippingCharge,
    this.perKmShippingCharge,
    this.restaurantModel,
    this.veg,
    this.nonVeg,
    this.schedules,
    this.paymentModes,
    this.searchBy,
    this.deliveryTime,
    this.fssai,
    this.defOrdStatus,
    this.showOrderStatus,
    this.cancelOrderTime,
    this.cuisines,
    this.isDelivery,
    this.serviceCharge,
    this.serviceChargePercentage,
    this.serviceChargeTaxPercent,
    this.tipTaxPercent,
    this.showUserGst,
    this.feedback,
    this.showFoodDate,
    this.showRoom,
    this.payUpi,
    this.payTab,
    this.payCC,
    this.payCash,
    this.roomPrice,
    this.guestDetail,
    this.bookingDetail,
    this.isPreCancel,
    this.printKot,
    this.discountType,
    this.discountText,
    this.isShowTips,
    this.isShowInventory,
    this.isNegativeInventory,
    this.roomGstApply,
    this.roomGst,
    this.isShowAcNonAcMenu,
    this.printingOption,
    this.listServeItem,
    this.isShowPopularCategory,
    this.isDeliveryAssign,
    this.isOrderPaymentType,
    this.isTotalRound,
    this.isComplementry,
    this.isShowEmpList,
    this.isShowAddressKot,
    this.isSurcharge,
    this.footerTextBill,
    this.logoPath,
    this.foodLevelNotes,
    this.foodWithVariance,
    this.autoServiceCharge,
    this.dynamicUpiValue,
    this.showVoiceInKds,
    this.showPrintInKds,
    this.isShowMemberId,
    this.searchFood,
    this.billDateFormat,
    this.isShowOrderConfirmTab,
    this.isAutoBillPrintBilling,
    this.resturantType,
    this.feedbackUrl,
    this.resturantGst,
    this.settelmentReport,
    this.settings,
    this.razorPayDetail,
    this.edcDetail,
    this.restaurantType,
  });

  Restaurant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'] ?? '';
    email = json['email'];
    logo = json['logo'];
    latitude = json['latitude'];
    address = json['address'];
    longitude = json['longitude'];
    upiId = json['upi_id'] ?? '';
    restaurantType = json['restaurant_type'] ?? 'Restaurant';

    minimumOrder = (json['minimum_order'] is int)
        ? (json['minimum_order'] as int).toDouble()
        : (json['minimum_order'] as num?)?.toDouble();
    scheduleOrder = json['schedule_order'] ?? false;
    currency = json['currency'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    freeDelivery = json['free_delivery'];
    coverPhoto = json['cover_photo'];
    delivery = json['delivery'].toString() == 'true';
    defOrdStatus = json['def_ord_status'];
    searchBy = [];

    if (json['search_by'] != null) {
      var raw = json['search_by'];
      if (raw is String) {
        // It's a stringified list -> decode it
        searchBy = List<String>.from(jsonDecode(raw));
      } else if (raw is List) {
        // It's already a proper list
        searchBy = List<String>.from(raw);
      }
    }
    guestDetail = json['guest_details'];
    roomPrice = json['room_price'];
    bookingDetail = json['booking_details'] ?? 'No';
    printKot = json['print_kot'] ?? 'Yes';
    isPreCancel = json['cancle_post_serve'] ?? 'Yes';
    foodLevelNotes = json['food_level_notes'] ?? 'No';
    autoServiceCharge = json['auto_service_charge'] ?? 'No';
    dynamicUpiValue = json['dynamic_upi_value'] ?? 'Yes';
    isNegativeInventory = json['inventory_negative'] ?? 'No';
    isAutoBillPrintBilling = json['billing_auto_bill_print'] ?? 'No';
    feedbackUrl = json['feedback_url'] ?? '';
    roomGstApply = json['room_gst_applicable'] ?? 'No';
    roomGst = json['room_gst'] != null && json['room_gst'] is Map
        ? RoomGstConfig.fromJson(Map<String, dynamic>.from(json['room_gst']))
        : null;
    isShowInventory = json['inventory'] ?? 'No';
    isShowMemberId = json['member_id'] ?? 'No';
    showPrintInKds = json['printing_in_kds'] ?? 'Yes';
    showVoiceInKds = json['voice_in_kds'] ?? 'Yes';
    foodWithVariance = json['show_food_varriance'] ?? 'No';
    isShowOrderConfirmTab = json['confirm_order_show_tab'] ?? 'No';
    takeAway = json['take_away'].toString() == 'true';
    tax = json['tax'] != null ? double.tryParse('${json['tax']}') ?? 0 : 0;
    gstTax = json['gst_tax'] == null || json['gst_tax'] == ''
        ? 0
        : double.tryParse('${json['gst_tax']}') ?? 0;
    reviewsSection = json['reviews_section'];
    foodSection = json['food_section'];
    availableTimeStarts = json['available_time_starts'];
    isDineIn = json['dine_in'] ?? 'Yes';
    availableTimeEnds = json['available_time_ends'];
    avgRating = (json['avg_rating'] is int)
        ? (json['avg_rating'] as int).toDouble()
        : (json['avg_rating'] as num?)?.toDouble();
    ratingCount = json['rating_count '];
    active = json['active'];
    cancelOrderTime = json['cancel_order_time'];
    gstStatus = '${json['gst_status'] ?? 'false'}';
    gstCode = json['gst_code'];
    logoPath = json['bill_logo_path'] ?? '';
    searchFood = json['search_food'] ?? 'Search Food';
    billDateFormat = json['bill_date_format'] ?? 'dd/MM/yyyy hh:mm';
    selfDeliverySystem = json['self_delivery_system'];
    posSystem = json['pos_system'];
    minimumShippingCharge = (json['minimum_shipping_charge'] is int)
        ? (json['minimum_shipping_charge'] as int).toDouble()
        : (json['minimum_shipping_charge'] as num?)?.toDouble();
    maximumShippingCharge = (json['maximum_shipping_charge'] is int)
        ? (json['maximum_shipping_charge'] as int).toDouble()
        : (json['maximum_shipping_charge'] as num?)?.toDouble();
    perKmShippingCharge = (json['per_km_shipping_charge'] is int)
        ? (json['per_km_shipping_charge'] as int).toDouble()
        : (json['per_km_shipping_charge'] as num?)?.toDouble();
    veg = json['veg'];
    restaurantModel = json['restaurant_model'];
    fssai = json['fssai'] ?? '';
    nonVeg = json['non_veg'];
    showOrderStatus = json['def_ord_status'];
    footerTextBill = json['footer_text'] ?? '';

    if (json['schedules'] != null) {
      schedules = <Schedules>[];
      for (var v in json['schedules']) {
        schedules!.add(Schedules.fromJson(v));
      }
    }
    paymentModes = [];
    if (json['payment_types'] != null) {
      paymentModes = <PaymentModes>[];
      for (var v in json['payment_types']) {
        paymentModes!.add(PaymentModes.fromJson(v));
      }
    }
    deliveryTime = json['delivery_time'];
    if (json['cuisine'] != null) {
      cuisines = <Cuisine>[];
      for (var v in json['cuisine']) {
        cuisines!.add(Cuisine.fromJson(v));
      }
    }
    serviceCharge = json['service_charge'];
    serviceChargeTaxPercent = json['service_charge_tax'] == null
        ? 0
        : double.parse('${json['service_charge_tax'] ?? 0}');
    tipTaxPercent =
        json['tip_tax'] == null ? 0 : double.parse('${json['tip_tax'] ?? 0}');
    serviceChargePercentage = json['service_charge_percentage'] == null
        ? 0
        : double.tryParse('${json['service_charge_percentage']}') ?? 0;
    isDelivery = json['delivery'].toString();
    feedback = json['feed_back'];
    showFoodDate = json['food_date'] ?? '';
    showUserGst = json['show_user_gst'] ?? 'No';
    showRoom = json['room'] ?? 'No';
    payUpi = json['pay_upi'] ?? 'No';
    payTab = json['pay_tab'] ?? 'No';
    payCC = json['pay_cc'] ?? 'No';
    payCash = json['pay_cash'] ?? 'No';
    isShowTips = json['tip'] ?? 'No';
    discountType = json['discount_type'] ?? 'Percent';
    discountText = json['discount_text'] ?? 'Add Discount';
    isShowAcNonAcMenu = json['show_ac_non_menu'] ?? 'No';
    printingOption = json['printing_option'] ?? 'Waiter';
    listServeItem = json['list_serve_item'] ?? 'Fixed';
    isShowPopularCategory = json['show_popular_category'] ?? 'Yes';
    isDeliveryAssign = json['delivery_assign'] ?? 'No';
    isTotalRound = json['total_round'] ?? 'No';
    isOrderPaymentType = json['order_payment_type'] ?? 'both';
    isComplementry = json['complementary'] ?? 'No';
    isShowEmpList = json['billing_emp'] ?? 'Yes';
    isShowAddressKot = json['show_address_on_bill'] ?? 'Yes';
    isSurcharge = json['surcharge'] ?? 'No';
    resturantType = json['restaurant_type'] ?? '';
    resturantGst = json['restaurent_gst'] ?? '';
    settelmentReport = json['settelment_report'] ?? 'No';
    settings = json['settings'] != null
        ? new Settings.fromJson(json['settings'])
        : null;
    razorPayDetail = json['razorpay'] != null
        ? new RazorPayDetail.fromJson(json['razorpay'])
        : null;
    edcDetail =
        json['edc'] != null ? new EDCResponse.fromJson(json['edc']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['upi_id'] = upiId;
    data['total_round'] = isTotalRound;
    data['billing_auto_bill_print'] = isAutoBillPrintBilling;
    data['food_level_notes'] = foodLevelNotes;
    data['feedback_url'] = feedbackUrl;
    data['show_food_varriance'] = foodWithVariance;
    data['auto_service_charge'] = autoServiceCharge;
    data['dynamic_upi_value'] = dynamicUpiValue;
    data['bill_logo_path'] = logoPath;
    data['delivery_assign'] = isDeliveryAssign;
    data['order_payment_type'] = isOrderPaymentType;
    data['tip_tax'] = tipTaxPercent;
    data['service_charge_tax'] = serviceChargeTaxPercent;
    data['show_user_gst'] = showUserGst;
    data['email'] = email;
    data['logo'] = logo;
    data['guest_details'] = guestDetail;
    data['latitude'] = latitude;
    data['restaurant_type'] = restaurantType;
    data['printing_in_kds'] = showPrintInKds;
    data['confirm_order_show_tab'] = isShowOrderConfirmTab;
    data['voice_in_kds'] = showVoiceInKds;
    data['cancel_order_time'] = cancelOrderTime;
    data['longitude'] = longitude;
    if (searchBy != null) {
      data['search_by'] = jsonEncode(searchBy);
    }
    data['address'] = address;
    data['minimum_order'] = minimumOrder;
    data['schedule_order'] = scheduleOrder;
    data['currency'] = currency;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['free_delivery'] = freeDelivery;
    data['cover_photo'] = coverPhoto;
    data['booking_details'] = bookingDetail;
    data['delivery'] = delivery;
    data['take_away'] = takeAway;
    data['tax'] = tax;
    data['gst_tax'] = gstTax;
    data['reviews_section'] = reviewsSection;
    data['food_section'] = foodSection;
    data['bill_date_format'] = billDateFormat;
    data['search_food'] = searchFood;
    data['available_time_starts'] = availableTimeStarts;
    data['dine_in'] = isDineIn;
    data['available_time_ends'] = availableTimeEnds;
    data['avg_rating'] = avgRating;
    data['rating_count '] = ratingCount;
    data['active'] = active;
    data['gst_status'] = gstStatus;
    data['gst_code'] = gstCode;
    data['self_delivery_system'] = selfDeliverySystem;
    data['pos_system'] = posSystem;
    data['minimum_shipping_charge'] = minimumShippingCharge;
    data['maximum_shipping_charge'] = maximumShippingCharge;
    data['per_km_shipping_charge'] = perKmShippingCharge;
    data['restaurant_model'] = restaurantModel;
    data['veg'] = veg;
    data['non_veg'] = nonVeg;
    data['food_date'] = showFoodDate;
    data['room'] = showRoom;
    data['service_charge'] = serviceCharge;
    data['feed_back'] = feedback;
    data['pay_cc'] = payCC;
    data['pay_upi'] = payUpi;
    data['print_kot'] = printKot;
    data['inventory'] = isShowInventory;
    data['inventory_negative'] = isNegativeInventory;
    data['room_gst_applicable'] = roomGstApply;
    if (roomGst != null) {
      data['room_gst'] = roomGst!.toJson();
    }
    data['pay_tab'] = payTab;
    data['pay_cash'] = payCash;
    data['tip'] = isShowTips;
    data['def_ord_status'] = defOrdStatus;
    data['member_id'] = isShowMemberId;
    data['discount_type'] = discountType;
    data['discount_text'] = discountText;
    data['delivery'] = isDelivery;
    data['show_ac_non_menu'] = isShowAcNonAcMenu;
    data['service_charge_percentage'] = serviceChargePercentage;
    data['printing_option'] = printingOption;
    data['list_serve_item'] = listServeItem;
    data['show_popular_category'] = isShowPopularCategory;
    data['complementary'] = isComplementry;
    data['billing_emp'] = isShowEmpList;
    data['show_address_on_bill'] = isShowAddressKot;
    data['surcharge'] = isSurcharge;
    data['footer_text'] = footerTextBill;
    data['restaurant_type'] = this.resturantType;

    if (schedules != null) {
      data['schedules'] = schedules!.map((v) => v.toJson()).toList();
    }
    if (paymentModes != null) {
      data['payment_types'] = paymentModes!.map((v) => v.toJson()).toList();
    }
    data['delivery_time'] = deliveryTime;
    if (cuisines != null) {
      data['cuisine'] = cuisines!.map((v) => v.toJson()).toList();
    }
    if (this.settings != null) {
      data['settings'] = this.settings!.toJson();
    }
    if (this.razorPayDetail != null) {
      data['razorpay'] = this.razorPayDetail!.toJson();
    }
    if (this.edcDetail != null) {
      data['edc'] = this.edcDetail!.toJson();
    }
    return data;
  }
}

class Cuisine {
  int? id;
  String? name;
  String? image;
  int? status;
  String? slug;
  String? createdAt;
  String? updatedAt;
  Pivot? pivot;

  Cuisine({
    this.id,
    this.name,
    this.image,
    this.status,
    this.slug,
    this.createdAt,
    this.updatedAt,
    this.pivot,
  });

  Cuisine.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    status = json['status'];
    slug = json['slug'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['status'] = status;
    data['slug'] = slug;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (pivot != null) {
      data['pivot'] = pivot!.toJson();
    }
    return data;
  }
}

class Pivot {
  int? restaurantId;
  int? cuisineId;

  Pivot({this.restaurantId, this.cuisineId});

  Pivot.fromJson(Map<String, dynamic> json) {
    restaurantId = int.tryParse(json['restaurant_id'].toString());
    cuisineId = int.tryParse(json['cuisine_id'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['restaurant_id'] = restaurantId;
    data['cuisine_id'] = cuisineId;
    return data;
  }
}

class Schedules {
  int? id;
  int? restaurantId;
  int? day;
  String? openingTime;
  String? closingTime;

  Schedules({
    this.id,
    this.restaurantId,
    this.day,
    this.openingTime,
    this.closingTime,
  });

  Schedules.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    day = json['day'];
    openingTime = (json['opening_time'] as String?)?.substring(0, 5);
    closingTime = (json['closing_time'] as String?)?.substring(0, 5);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_id'] = restaurantId;
    data['day'] = day;
    data['opening_time'] = openingTime;
    data['closing_time'] = closingTime;
    return data;
  }
}

class PaymentModes {
  int? id;
  String? name;
  String? displayName;
  int? isPrepaid;
  int? isPostpaid;

  PaymentModes({
    this.id,
    this.name,
    this.displayName,
    this.isPrepaid,
    this.isPostpaid,
  });

  PaymentModes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'] ?? '';
    displayName = json['display_name'] ?? '';
    isPrepaid = json['prepaid'] ?? 1;
    isPostpaid = json['postpaid'] ?? 1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['display_name'] = displayName;
    data['prepaid'] = isPrepaid;
    data['postpaid'] = isPostpaid;
    return data;
  }
}

class Package {
  int? id;
  String? packageName;
  double? price;
  int? validity;
  String? maxOrder;
  String? maxProduct;
  int? pos;
  int? mobileApp;
  int? chat;
  int? review;
  int? selfDelivery;
  int? status;
  int? def;
  String? colour;
  String? text;
  String? createdAt;
  String? updatedAt;

  Package({
    this.id,
    this.packageName,
    this.price,
    this.validity,
    this.maxOrder,
    this.maxProduct,
    this.pos,
    this.mobileApp,
    this.chat,
    this.review,
    this.selfDelivery,
    this.status,
    this.def,
    this.colour,
    this.text,
    this.createdAt,
    this.updatedAt,
  });

  Package.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    packageName = json['package_name'];
    price = (json['price'] is int)
        ? (json['price'] as int).toDouble()
        : (json['price'] as num?)?.toDouble();
    validity = json['validity'];
    maxOrder = json['max_order'];
    maxProduct = json['max_product'];
    pos = json['pos'];
    mobileApp = json['mobile_app'];
    chat = json['chat'];
    review = json['review'];
    selfDelivery = json['self_delivery'];
    status = json['status'];
    def = json['default'];
    colour = json['colour'];
    text = json['text'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['package_name'] = packageName;
    data['price'] = price;
    data['validity'] = validity;
    data['max_order'] = maxOrder;
    data['max_product'] = maxProduct;
    data['pos'] = pos;
    data['mobile_app'] = mobileApp;
    data['chat'] = chat;
    data['review'] = review;
    data['self_delivery'] = selfDelivery;
    data['status'] = status;
    data['default'] = def;
    data['colour'] = colour;
    data['text'] = text;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

// class SubscriptionOtherData {
//   double? totalBill;
//   int? maxProductUpload;

//   SubscriptionOtherData({this.totalBill, this.maxProductUpload});

//   SubscriptionOtherData.fromJson(Map<String, dynamic> json) {
//     totalBill = json['total_bill'] != null
//         ? (json['total_bill'] as num).toDouble()
//         : null;
//     maxProductUpload = json['max_product_uploads'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['total_bill'] = totalBill;
//     data['max_product_uploads'] = maxProductUpload;
//     return data;
//   }
// }

class PrintAgentMapping {
  String? areaName;
  int? defaultEmployeeId;

  PrintAgentMapping({
    this.areaName,
    this.defaultEmployeeId,
  });

  PrintAgentMapping.fromJson(Map<String, dynamic> json) {
    areaName = json['area_name'];
    defaultEmployeeId = json['default_employee_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['area_name'] = areaName;
    data['default_employee_id'] = defaultEmployeeId;
    return data;
  }
}

class PrintAgent {
  PrintAgentMapping? mapping;
  List<RestaurantPrinterNew>? printerData;

  PrintAgent({
    this.mapping,
    this.printerData,
  });

  PrintAgent.fromJson(Map<String, dynamic> json) {
    mapping = json['mapping'] != null
        ? PrintAgentMapping.fromJson(
            Map<String, dynamic>.from(json['mapping'] as Map))
        : null;
    if (json['printer_data'] != null && json['printer_data'] is List) {
      printerData = [];
      for (var v in json['printer_data']) {
        if (v is Map<String, dynamic>) {
          printerData!.add(RestaurantPrinterNew.fromJson(v));
        } else if (v is Map) {
          printerData!
              .add(RestaurantPrinterNew.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (mapping != null) {
      data['mapping'] = mapping!.toJson();
    }
    if (printerData != null) {
      data['printer_data'] = printerData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

/// Builds order-place `printer_agent` for stations present in the cart only.
List<Map<String, dynamic>> buildPrinterAgentPayload({
  required List<PrintAgent>? printAgents,
  required Iterable<String?> cartStations,
}) {
  final stationSet = <String>{};
  for (final station in cartStations) {
    final trimmed = station?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      stationSet.add(trimmed.toUpperCase());
    }
  }
  if (stationSet.isEmpty || printAgents == null || printAgents.isEmpty) {
    return [];
  }

  String? emptyToNull(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value;
  }

  final List<Map<String, dynamic>> result = [];
  for (final agent in printAgents) {
    final areaName = agent.mapping?.areaName?.trim();
    if (areaName == null || areaName.isEmpty) continue;
    if (!stationSet.contains(areaName.toUpperCase())) continue;

    final printers = agent.printerData;
    if (printers == null || printers.isEmpty) continue;

    for (final printer in printers) {
      result.add({
        'station': areaName,
        'printer_agent_id': '${agent.mapping?.defaultEmployeeId ?? ''}',
        'printer_type': printer.printerName,
        'printer_ip': printer.printerIp,
        'printer_paper_roll': '${printer.printerPaperRoll ?? ''}',
        'vendor_id': emptyToNull(printer.vendorId),
        'product_id': emptyToNull(printer.productId),
        'wifi_printer_ip': emptyToNull(printer.wifiPrinterIp),
        'printer_name': emptyToNull(printer.wifiPrinterName),
      });
    }
  }
  return result;
}

List<String> _parseStationKotList(String? stationKot) {
  if (stationKot == null || stationKot.trim().isEmpty) return [];
  return stationKot
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

/// Builds `printer_agent` for order-temp-store from print_type + station_kot.
/// bill → BILL only; kot → station_kot stations; both → BILL + station_kot.
List<Map<String, dynamic>> buildPrinterAgentForTempStore({
  required List<PrintAgent>? printAgents,
  required String? printType,
  required String? stationKot,
}) {
  final type = (printType ?? '').trim().toLowerCase();
  final stations = <String>[];

  if (type == 'bill' || type == 'billing') {
    stations.add('BILL');
  } else if (type == 'kot') {
    stations.addAll(_parseStationKotList(stationKot));
  } else if (type == 'both') {
    stations.add('BILL');
    stations.addAll(_parseStationKotList(stationKot));
  }

  return buildPrinterAgentPayload(
    printAgents: printAgents,
    cartStations: stations,
  );
}

class RestaurantPrinterNew {
  int? id;
  int? restaurantId;
  String? areaName;
  String? printerName;
  String? printerIp;
  String? macPrinterIp;
  String? printerType;
  String? productId;
  String? vendorId;
  String? wifiPrinterName;
  String? wifiPrinterIp;
  int? printerPaperRoll;
  // List<int>? categoriesId;

  RestaurantPrinterNew({
    this.id,
    this.restaurantId,
    this.areaName,
    this.printerName,
    this.printerIp,
    this.macPrinterIp,
    this.printerType,
    this.productId,
    this.vendorId,
    this.wifiPrinterName,
    this.wifiPrinterIp,
    this.printerPaperRoll,
    // this.categoriesId,
  });

  RestaurantPrinterNew.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    areaName = json['area_name'];
    printerName = json['printer_name'] ?? '';
    printerIp = json['printer_ip'];
    macPrinterIp = json['mac_printer_ip'] ?? '';
    wifiPrinterIp = json['wifi_printer_ip'] ?? '';
    wifiPrinterName = json['wifi_printer_name'] ?? '';
    printerType = json['printer_type'] ?? 'online';
    printerPaperRoll = json['printer_paper_roll'];
    vendorId = json['vendor_id'];
    productId = json['product_id'];
    // categoriesId =
    //     (json['categories_id'] as List?)?.map((e) => e as int).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_id'] = restaurantId;
    data['area_name'] = areaName;
    data['printer_name'] = printerName;
    data['printer_ip'] = printerIp;
    data['mac_printer_ip'] = macPrinterIp;
    data['product_id'] = productId;
    data['vendor_id'] = vendorId;
    data['printer_paper_roll'] = printerPaperRoll;
    data['wifi_printer_ip'] = wifiPrinterIp;
    data['wifi_printer_name'] = wifiPrinterName;
    data['printer_type'] = printerType;
    // data['categories_id'] = categoriesId;
    return data;
  }
}

class PrintConfigModel {
  int? id;
  int? restaurantId;
  String? billSize;
  String? restaurantTitle;
  String? restaurantAddress;
  String? restaurantFoodList;
  String? restaurantGstno;
  String? restaurantSubTotal;
  String? restaurantTotalAmount;
  String? resturantFoodListHeader;
  String? resturantOrderId;
  String? resturantTable;
  String? resturantScanToPay;
  String? resturantScanToFeedback;
  String? stationName;
  String? deliveryCharge;
  String? deliveryAddress;
  String? restaurantLogo;
  String? restaurantAddress1;
  String? restaurantAddress2;
  String? restaurantFssaiNo;
  String? dateTime;
  String? orderType;
  String? customerName;
  String? customerNumber;
  String? billerName;
  String? serviceCharge;
  String? tip;
  String? discount;
  String? poweredByMygenie;
  String? gstParcent;
  String? vatParcent;
  String? updatedAt;
  String? createdAt;
  double? padding;
  double? margin;
  double? paperWidth;

  PrintConfigModel({
    this.id,
    this.restaurantId,
    this.billSize,
    this.restaurantTitle,
    this.restaurantAddress,
    this.restaurantFoodList,
    this.restaurantGstno,
    this.restaurantSubTotal,
    this.restaurantTotalAmount,
    this.resturantFoodListHeader,
    this.resturantOrderId,
    this.resturantTable,
    this.resturantScanToPay,
    this.restaurantLogo,
    this.restaurantAddress1,
    this.restaurantAddress2,
    this.restaurantFssaiNo,
    this.dateTime,
    this.orderType,
    this.customerName,
    this.customerNumber,
    this.billerName,
    this.serviceCharge,
    this.tip,
    this.discount,
    this.poweredByMygenie,
    this.gstParcent,
    this.vatParcent,
    this.updatedAt,
    this.createdAt,
    this.resturantScanToFeedback,
    this.stationName,
    this.deliveryCharge,
    this.deliveryAddress,
    this.padding,
    this.margin,
    this.paperWidth,
  });

  PrintConfigModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    billSize = json['bill_size'];
    restaurantTitle = json['restaurant_title'];
    restaurantAddress = json['restaurant_address'];
    restaurantFoodList = json['restaurant_food_list'];
    restaurantGstno = json['restaurant_gstno'];
    restaurantSubTotal = json['restaurant_sub_total'];
    restaurantTotalAmount = json['restaurant_total_amount'];
    resturantFoodListHeader = json['resturant_food_list_header'];
    resturantOrderId = json['resturant_order_id'];
    resturantTable = json['resturant_table'];
    resturantScanToPay = json['resturant_scan_to_pay'];
    restaurantLogo = json['restaurant_logo'];
    restaurantAddress1 = json['restaurant_address_1'];
    restaurantAddress2 = json['restaurant_address_2'];
    restaurantFssaiNo = json['restaurant_fssai_no'];
    dateTime = json['date_time'];
    orderType = json['order_type'];
    customerName = json['customer_name'];
    customerNumber = json['customer_number'];
    billerName = json['biller_name'];
    serviceCharge = json['service_charge'];
    tip = json['tip'];
    discount = json['discount'];
    poweredByMygenie = json['powered_by_mygenie'];
    gstParcent = json['gst_parcent'];
    vatParcent = json['vat_parcent'];
    resturantScanToFeedback = json['scan_to_feedback'];
    stationName = json['station_name'];
    deliveryCharge = json['delivery_charge'];
    deliveryAddress = json['delivery_address_detail'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    padding = double.parse('${json['padding'] ?? 0}');
    margin = double.parse('${json['margin'] ?? 0}');
    paperWidth = double.parse('${json['paperwidth'] ?? 0}');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_id'] = restaurantId;
    data['bill_size'] = billSize;
    data['restaurant_title'] = restaurantTitle;
    data['restaurant_address'] = restaurantAddress;
    data['restaurant_food_list'] = restaurantFoodList;
    data['restaurant_gstno'] = restaurantGstno;
    data['restaurant_sub_total'] = restaurantSubTotal;
    data['restaurant_total_amount'] = restaurantTotalAmount;
    data['resturant_food_list_header'] = resturantFoodListHeader;
    data['resturant_order_id'] = resturantOrderId;
    data['resturant_table'] = resturantTable;
    data['resturant_scan_to_pay'] = resturantScanToPay;
    data['restaurant_logo'] = restaurantLogo;
    data['restaurant_address_1'] = restaurantAddress1;
    data['restaurant_address_2'] = restaurantAddress2;
    data['restaurant_fssai_no'] = restaurantFssaiNo;
    data['date_time'] = dateTime;
    data['order_type'] = orderType;
    data['customer_name'] = customerName;
    data['customer_number'] = customerNumber;
    data['biller_name'] = billerName;
    data['service_charge'] = serviceCharge;
    data['tip'] = tip;
    data['discount'] = discount;
    data['powered_by_mygenie'] = poweredByMygenie;
    data['scan_to_feedback'] = resturantScanToFeedback;
    data['station_name'] = stationName;
    data['delivery_charge'] = deliveryCharge;
    data['delivery_address_detail'] = deliveryAddress;
    data['gst_parcent'] = gstParcent;
    data['vat_parcent'] = vatParcent;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['padding'] = padding;
    data['margin'] = margin;
    data['paperwidth'] = paperWidth;
    return data;
  }
}

class VatInfo {
  String? status;
  String? code;

  VatInfo({this.status, this.code});

  VatInfo.fromJson(Map<String, dynamic> json) {
    status = '${json['status'] ?? 'false'}';
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['code'] = code;
    return data;
  }
}

class DiscountCategoryListModel {
  int? id;
  int? restaurantId;
  String? discountType;
  String? discount;

  DiscountCategoryListModel({
    this.id,
    this.restaurantId,
    this.discountType,
    this.discount,
  });

  DiscountCategoryListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    discountType = json['discount_type'];
    discount = '${json['discount_percent'] ?? 0}';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_id'] = restaurantId;
    data['discount_type'] = discountType;
    data['discount_percent'] = discount;
    return data;
  }
}

class Settings {
  int? id;
  int? restaurantId;
  String? inventoryManagerName;
  String? onlineOrderingLink;
  String? phoneNumberOnBill;
  String? showUserGst;
  String? updatedAt;
  String? createdAt;
  String? aggregatorAutoKot;
  String? aggregatorAutoBill;
  String? aggregatorAutoBillStage;
  String? autoDispatch;
  String? confirmOrderTone;
  String? aggregatorOrderTone;
  String? isCoupon;
  String? isLoyality;
  String? serviceChrgTaxt;
  String? isCustomerWallet;
  String? isRoleBaseDiscount;
  double? gstDeliveryCharge;
  String? shortCode;
  String? noOfKotPrint;
  String? noOfBillPrint;
  String? autoPaid;
  String? printBillCustomerCopy;
  String? useDisplayToken;
  String? language;
  String? restaurantFor;
  RoomGstConfig? roomGst;

  Settings({
    this.id,
    this.restaurantId,
    this.inventoryManagerName,
    this.onlineOrderingLink,
    this.phoneNumberOnBill,
    this.showUserGst,
    this.updatedAt,
    this.createdAt,
    this.aggregatorAutoKot,
    this.aggregatorAutoBill,
    this.aggregatorAutoBillStage,
    this.autoDispatch,
    this.confirmOrderTone,
    this.aggregatorOrderTone,
    this.isCoupon,
    this.isLoyality,
    this.serviceChrgTaxt,
    this.isCustomerWallet,
    this.isRoleBaseDiscount,
    this.gstDeliveryCharge,
    this.shortCode,
    this.noOfKotPrint,
    this.noOfBillPrint,
    this.autoPaid,
    this.printBillCustomerCopy,
    this.useDisplayToken,
    this.language,
    this.restaurantFor,
    this.roomGst,
  });

  Settings.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    inventoryManagerName = json['inventory_manager_name'];
    onlineOrderingLink = json['online_ordering_link'];
    phoneNumberOnBill = json['phone_number_on_bill'];
    showUserGst = json['show_user_gst'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    aggregatorAutoKot = json['aggregator_auto_kot'];
    aggregatorAutoBill = json['aggregator_auto_bill'];
    aggregatorAutoBillStage = json['aggregator_auto_bill_stage'];
    autoDispatch = json['auto_dispatch'] ?? 'No';
    confirmOrderTone = json['confirm_order_tone'] ?? '';
    aggregatorOrderTone = json['aggregator_order_tone'] ?? '';
    isCoupon = json['is_coupon'] ?? 'No';
    isLoyality = json['is_loyality'] ?? 'No';
    isRoleBaseDiscount = json['role_base_discount'] ?? 'No';
    serviceChrgTaxt = json['service_chrg_taxt'] ?? 'Service Charge';
    isCustomerWallet = json['is_customer_wallet'] ?? 'No';
    gstDeliveryCharge = double.parse('${json['deliver_charge_gst'] ?? 0}');
    shortCode = json['short_code'] ?? 'No';
    // autoPaid = 'Yes';
    autoPaid = json['auto_paid'] ?? 'No';
    printBillCustomerCopy = json['print_bill_customer_copy'] ?? 'No';
    noOfKotPrint = json['no_of_kot'] ?? '1';
    noOfBillPrint = json['no_of_bill'] ?? '1';
    useDisplayToken = json['use_token'] ?? 'No';
    language = json['kot_language'] ?? 'English';
    restaurantFor = json['restaurant_for'];
    roomGst = json['room_gst'] != null && json['room_gst'] is Map
        ? RoomGstConfig.fromJson(Map<String, dynamic>.from(json['room_gst']))
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['restaurant_id'] = this.restaurantId;
    data['inventory_manager_name'] = this.inventoryManagerName;
    data['online_ordering_link'] = this.onlineOrderingLink;
    data['phone_number_on_bill'] = this.phoneNumberOnBill;
    data['show_user_gst'] = this.showUserGst;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['aggregator_auto_kot'] = this.aggregatorAutoKot;
    data['print_bill_customer_copy'] = this.printBillCustomerCopy;
    data['aggregator_auto_bill'] = this.aggregatorAutoBill;
    data['aggregator_auto_bill_stage'] = this.aggregatorAutoBillStage;
    data['auto_dispatch'] = this.autoDispatch;
    data['role_base_discount'] = this.isRoleBaseDiscount;
    data['confirm_order_tone'] = this.confirmOrderTone;
    data['aggregator_order_tone'] = this.aggregatorOrderTone;
    data['is_coupon'] = this.isCoupon;
    data['is_loyality'] = this.isLoyality;
    data['service_chrg_taxt'] = this.serviceChrgTaxt;
    data['is_customer_wallet'] = this.isCustomerWallet;
    data['deliver_charge_gst'] = this.gstDeliveryCharge;
    data['no_of_kot'] = this.noOfKotPrint;
    data['no_of_bill'] = this.noOfBillPrint;
    data['auto_paid'] = this.autoPaid;
    data['use_token'] = this.useDisplayToken;
    data['restaurant_for'] = this.restaurantFor;
    if (roomGst != null) {
      data['room_gst'] = roomGst!.toJson();
    }
    return data;
  }
}

class RazorPayDetail {
  String? key;

  RazorPayDetail({
    this.key,
  });

  RazorPayDetail.fromJson(Map<String, dynamic> json) {
    key = json['razorpay_key'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['razorpay_key'] = this.key;

    return data;
  }
}

class EDCResponse {
  String? pinelab;
  String? edcType;
  PineLabDetail? pineLabDetail;
  EDCResponse({
    this.pinelab,
    this.edcType,
    this.pineLabDetail,
  });

  EDCResponse.fromJson(Map<String, dynamic> json) {
    pinelab = json['edc_pinelab'] ?? 'No';
    edcType = json['edc_type'] ?? 'No';
    pineLabDetail = json['edc_pinelab_key'] != null
        ? PineLabDetail.fromJson(json['edc_pinelab_key'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['edc_pinelab'] = this.pinelab;
    data['edc_type'] = this.edcType;
    if (this.pineLabDetail != null) {
      data['edc_pinelab_key'] = this.pineLabDetail!.toJson();
    }
    return data;
  }
}

class PineLabDetail {
  String? storeId;
  String? clientId;
  String? merchantId;
  String? securityToken;

  PineLabDetail({
    this.storeId,
    this.clientId,
    this.merchantId,
    this.securityToken,
  });

  PineLabDetail.fromJson(Map<String, dynamic> json) {
    storeId = json['StoreId'] ?? '';
    clientId = json['ClientId'] ?? '';
    merchantId = json['MerchantID'] ?? '';
    securityToken = json['SecurityToken'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['StoreId'] = this.storeId;
    data['ClientId'] = this.clientId;
    data['MerchantID'] = this.merchantId;
    data['SecurityToken'] = this.securityToken;

    return data;
  }
}

class RoomGstConfig {
  String? basis;
  String? currency;
  List<RoomGstSlab> slabs;

  RoomGstConfig({
    this.basis,
    this.currency,
    this.slabs = const [],
  });

  factory RoomGstConfig.fromJson(Map<String, dynamic> json) {
    final rawSlabs = json['slabs'];
    return RoomGstConfig(
      basis: json['basis']?.toString(),
      currency: json['currency']?.toString(),
      slabs: rawSlabs is List
          ? rawSlabs
              .whereType<Map>()
              .map((e) => RoomGstSlab.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basis': basis,
      'currency': currency,
      'slabs': slabs.map((e) => e.toJson()).toList(),
    };
  }
}

class RoomGstSlab {
  bool itc;
  double min;
  double? max;
  double gstPercent;

  RoomGstSlab({
    this.itc = false,
    this.min = 0,
    this.max,
    this.gstPercent = 0,
  });

  factory RoomGstSlab.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value, {double fallback = 0}) {
      if (value == null) return fallback;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? fallback;
    }

    return RoomGstSlab(
      itc: json['itc'] == true || json['itc']?.toString() == 'true',
      min: parseDouble(json['min']),
      max: json['max'] == null ? null : parseDouble(json['max']),
      gstPercent: parseDouble(json['gst_percent']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itc': itc,
      'min': min,
      'max': max,
      'gst_percent': gstPercent,
    };
  }
}
