class ConfigModel {
  String? businessName;
  String? logo;
  String? address;
  String? phone;
  String? email;
  BaseUrls? baseUrls;
  String? currencySymbol;
  bool? cashOnDelivery;
  bool? digitalPayment;
  String? termsAndConditions;
  String? privacyPolicy;
  String? aboutUs;
  String? country;
  DefaultLocation? defaultLocation;
  String? appUrl;
  bool? customerVerification;
  bool? orderDeliveryVerification;
  String? currencySymbolDirection;
  int? appMinimumVersion;
  bool? demo;
  bool? scheduleOrder;
  String? orderConfirmationModel;
  bool? showDmEarning;
  bool? canceledByDeliveryman;
  bool? canceledByRestaurant;
  String? timeformat;
  bool? toggleVegNonVeg;
  bool? toggleDmRegistration;
  bool? toggleRestaurantRegistration;
  bool? maintenanceMode;
  String? appUrlAndroid;
  String? appUrlIos;
  List<Language>? language;
  int? scheduleOrderSlotDuration;
  int? digitAfterDecimalPoint;
  BusinessPlan? businessPlan;
  double? adminCommission;
  int? freeTrialPeriodStatus;
  int? freeTrialPeriodDay;
  String? footerText;
  double? appMinimumVersionAndroid;
  double? appMinimumVersionIos;

  ConfigModel({
    this.businessName,
    this.logo,
    this.address,
    this.phone,
    this.email,
    this.baseUrls,
    this.currencySymbol,
    this.cashOnDelivery,
    this.digitalPayment,
    this.termsAndConditions,
    this.privacyPolicy,
    this.aboutUs,
    this.country,
    this.defaultLocation,
    this.appUrl,
    this.customerVerification,
    this.orderDeliveryVerification,
    this.currencySymbolDirection,
    this.appMinimumVersion,
    this.demo,
    this.scheduleOrder,
    this.orderConfirmationModel,
    this.showDmEarning,
    this.canceledByDeliveryman,
    this.canceledByRestaurant,
    this.timeformat,
    this.toggleVegNonVeg,
    this.toggleDmRegistration,
    this.toggleRestaurantRegistration,
    this.maintenanceMode,
    this.appUrlAndroid,
    this.appUrlIos,
    this.language,
    this.scheduleOrderSlotDuration,
    this.digitAfterDecimalPoint,
    this.businessPlan,
    this.adminCommission,
    this.freeTrialPeriodStatus,
    this.freeTrialPeriodDay,
    this.footerText,
    this.appMinimumVersionAndroid,
    this.appMinimumVersionIos,
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) => ConfigModel(
        businessName: json['business_name'] as String?,
        logo: json['logo'] as String?,
        address: json['address'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        baseUrls: json['base_urls'] != null
            ? BaseUrls.fromJson(json['base_urls'] as Map<String, dynamic>)
            : null,
        currencySymbol: json['currency_symbol'] as String?,
        cashOnDelivery: json['cash_on_delivery'] as bool?,
        digitalPayment: json['digital_payment'] as bool?,
        termsAndConditions: json['terms_and_conditions'] as String?,
        privacyPolicy: json['privacy_policy'] as String?,
        aboutUs: json['about_us'] as String?,
        country: json['country'] as String?,
        defaultLocation: json['default_location'] != null
            ? DefaultLocation.fromJson(
                json['default_location'] as Map<String, dynamic>)
            : null,
        appUrl: json['app_url'] as String?,
        customerVerification: json['customer_verification'] as bool?,
        orderDeliveryVerification: json['order_delivery_verification'] as bool?,
        currencySymbolDirection: json['currency_symbol_direction'] as String?,
        appMinimumVersion: json['app_minimum_version'] as int?,
        demo: json['demo'] as bool?,
        scheduleOrder: json['schedule_order'] as bool?,
        orderConfirmationModel: json['order_confirmation_model'] as String?,
        showDmEarning: json['show_dm_earning'] as bool?,
        canceledByDeliveryman: json['canceled_by_deliveryman'] as bool?,
        canceledByRestaurant: json['canceled_by_restaurant'] as bool?,
        timeformat: json['timeformat'] as String?,
        toggleVegNonVeg: json['toggle_veg_non_veg'] as bool?,
        toggleDmRegistration: json['toggle_dm_registration'] as bool?,
        toggleRestaurantRegistration:
            json['toggle_restaurant_registration'] as bool?,
        maintenanceMode: json['maintenance_mode'] as bool?,
        appUrlAndroid: json['app_url_android'] as String?,
        appUrlIos: json['app_url_ios'] as String?,
        language: (json['language'] as List<dynamic>?)
            ?.map((v) => Language.fromJson(v as Map<String, dynamic>))
            .toList(),
        scheduleOrderSlotDuration: json['schedule_order_slot_duration'] as int?,
        digitAfterDecimalPoint: json['digit_after_decimal_point'] as int?,
        businessPlan: json['business_plan'] != null
            ? BusinessPlan.fromJson(
                json['business_plan'] as Map<String, dynamic>)
            : null,
        adminCommission: (json['admin_commission'] != null)
            ? (json['admin_commission'] as num).toDouble()
            : null,
        freeTrialPeriodStatus: json['free_trial_period_status'] as int?,
        freeTrialPeriodDay: json['free_trial_period_data'] as int?,
        footerText: json['footer_text'] as String?,
        appMinimumVersionAndroid: (json['app_minimum_version_android'] != null)
            ? (json['app_minimum_version_android'] as num).toDouble()
            : null,
        appMinimumVersionIos: (json['app_minimum_version_ios'] != null)
            ? (json['app_minimum_version_ios'] as num).toDouble()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'business_name': businessName,
        'logo': logo,
        'address': address,
        'phone': phone,
        'email': email,
        if (baseUrls != null) 'base_urls': baseUrls!.toJson(),
        'currency_symbol': currencySymbol,
        'cash_on_delivery': cashOnDelivery,
        'digital_payment': digitalPayment,
        'terms_and_conditions': termsAndConditions,
        'privacy_policy': privacyPolicy,
        'about_us': aboutUs,
        'country': country,
        if (defaultLocation != null)
          'default_location': defaultLocation!.toJson(),
        'app_url': appUrl,
        'customer_verification': customerVerification,
        'order_delivery_verification': orderDeliveryVerification,
        'currency_symbol_direction': currencySymbolDirection,
        'app_minimum_version': appMinimumVersion,
        'demo': demo,
        'schedule_order': scheduleOrder,
        'order_confirmation_model': orderConfirmationModel,
        'show_dm_earning': showDmEarning,
        'canceled_by_deliveryman': canceledByDeliveryman,
        'canceled_by_restaurant': canceledByRestaurant,
        'timeformat': timeformat,
        'toggle_veg_non_veg': toggleVegNonVeg,
        'toggle_dm_registration': toggleDmRegistration,
        'toggle_restaurant_registration': toggleRestaurantRegistration,
        'maintenance_mode': maintenanceMode,
        'app_url_android': appUrlAndroid,
        'app_url_ios': appUrlIos,
        if (language != null)
          'language': language!.map((v) => v.toJson()).toList(),
        'schedule_order_slot_duration': scheduleOrderSlotDuration,
        'digit_after_decimal_point': digitAfterDecimalPoint,
        'footer_text': footerText,
        'app_minimum_version_android': appMinimumVersionAndroid,
        'app_minimum_version_ios': appMinimumVersionIos,
      };
}

class BaseUrls {
  String? productImageUrl;
  String? customerImageUrl;
  String? bannerImageUrl;
  String? categoryImageUrl;
  String? reviewImageUrl;
  String? notificationImageUrl;
  String? restaurantImageUrl;
  String? vendorImageUrl;
  String? restaurantCoverPhotoUrl;
  String? deliveryManImageUrl;
  String? chatImageUrl;
  String? campaignImageUrl;
  String? businessLogoUrl;

  BaseUrls({
    this.productImageUrl,
    this.customerImageUrl,
    this.bannerImageUrl,
    this.categoryImageUrl,
    this.reviewImageUrl,
    this.notificationImageUrl,
    this.restaurantImageUrl,
    this.vendorImageUrl,
    this.restaurantCoverPhotoUrl,
    this.deliveryManImageUrl,
    this.chatImageUrl,
    this.campaignImageUrl,
    this.businessLogoUrl,
  });

  factory BaseUrls.fromJson(Map<String, dynamic> json) => BaseUrls(
        productImageUrl: json['product_image_url'] as String?,
        customerImageUrl: json['customer_image_url'] as String?,
        bannerImageUrl: json['banner_image_url'] as String?,
        categoryImageUrl: json['category_image_url'] as String?,
        reviewImageUrl: json['review_image_url'] as String?,
        notificationImageUrl: json['notification_image_url'] as String?,
        restaurantImageUrl: json['restaurant_image_url'] as String?,
        vendorImageUrl: json['vendor_image_url'] as String?,
        restaurantCoverPhotoUrl: json['restaurant_cover_photo_url'] as String?,
        deliveryManImageUrl: json['delivery_man_image_url'] as String?,
        chatImageUrl: json['chat_image_url'] as String?,
        campaignImageUrl: json['campaign_image_url'] as String?,
        businessLogoUrl: json['business_logo_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'product_image_url': productImageUrl,
        'customer_image_url': customerImageUrl,
        'banner_image_url': bannerImageUrl,
        'category_image_url': categoryImageUrl,
        'review_image_url': reviewImageUrl,
        'notification_image_url': notificationImageUrl,
        'restaurant_image_url': restaurantImageUrl,
        'vendor_image_url': vendorImageUrl,
        'restaurant_cover_photo_url': restaurantCoverPhotoUrl,
        'delivery_man_image_url': deliveryManImageUrl,
        'chat_image_url': chatImageUrl,
        'campaign_image_url': campaignImageUrl,
        'business_logo_url': businessLogoUrl,
      };
}

class DefaultLocation {
  String? lat;
  String? lng;

  DefaultLocation({this.lat, this.lng});

  factory DefaultLocation.fromJson(Map<String, dynamic> json) =>
      DefaultLocation(
        lat: json['lat'] as String?,
        lng: json['lng'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
      };
}

class Language {
  String? key;
  String? value;

  Language({this.key, this.value});

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        key: json['key'] as String?,
        value: json['value'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
      };
}

class BusinessPlan {
  int? commission;
  int? subscription;

  BusinessPlan({this.commission, this.subscription});

  factory BusinessPlan.fromJson(Map<String, dynamic> json) => BusinessPlan(
        commission: json['commission'] as int?,
        subscription: json['subscription'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'commission': commission,
        'subscription': subscription,
      };
}
