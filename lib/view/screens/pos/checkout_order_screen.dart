import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/print_debug_controller.dart';
import 'package:mygenie_restaurant/data/model/print_debug_log_model.dart';
import 'package:mygenie_restaurant/helper/print_debug_logger.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/controller/location_controller.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/controller/table_controller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/data/model/response/address_model.dart';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/get_member_id_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/get_room_list_respone.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/crm_customer_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/prediction_model.dart';
import 'package:mygenie_restaurant/data/model/response/product_model.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/data/model/response/response_model.dart';
import 'package:mygenie_restaurant/data/model/response/search_address_detail_model.dart';
import 'package:mygenie_restaurant/data/model/response/search_customer_response_model.dart';
import 'package:mygenie_restaurant/data/model/response/tap_managment_reesponse_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/print_byte_convert.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/util/windows_byte_convert.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/base/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/view/screens/pos/widget/quantity_button.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/loyalty_controller.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../data/model/response/get_customer_list_response.dart';
import '../../../helper/route_helper.dart';
import 'package:mygenie_restaurant/view/screens/custome management/controller/customer_management_controller.dart';

class POSCartScreen extends StatefulWidget {
  final bool? fromNav;
  final String? notes;
  final String? phoneNumber;
  final String? orderUUID;
  final OrderList? editOrder;

  const POSCartScreen({
    Key? key,
    this.fromNav,
    this.notes,
    this.editOrder,
    this.phoneNumber,
    this.orderUUID,
  }) : super(key: key);

  @override
  State<POSCartScreen> createState() => _POSCartScreenState();
}

class _POSCartScreenState extends State<POSCartScreen> {
  double foodTotal = 0;
  bool showPlayer = false;
  bool _showCustomerAdditionalFields = false;
  bool _showDeliveryAdditionalFields = false;
  List<Map<String, dynamic>> jsonCartList = [];
  double tipTaxAmount = 0;
  double gstServiceChargeTax = 0;
  double gstDeliveryChargeTax = 0;
  // String audioPath;
  TextEditingController _addNoteController = TextEditingController();

  double variationTotal = 0;

  int currentPrintIndex = 0;
  bool isConnect = true;
  String userId = '';
  String couponDiscountType = '';

  TextEditingController _nameController = TextEditingController();
  TextEditingController _memberController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _anniversaryController = TextEditingController();
  String? _selectedDropdownOption;
  TextEditingController addNameController = TextEditingController();
  TextEditingController selectedPhoneController = TextEditingController();
  TextEditingController selectedDeliveryCharge = TextEditingController();
  TextEditingController addFloorController = TextEditingController();
  TextEditingController manuallyAddressController = TextEditingController();
  TextEditingController addPhoneController = TextEditingController();
  TextEditingController addAddressController = TextEditingController();
  TextEditingController addPincodeController = TextEditingController();
  TextEditingController pCash = TextEditingController(text: '0');
  TextEditingController pCard = TextEditingController(text: '0');
  TextEditingController pUpi = TextEditingController(text: '0');
  TextEditingController pTXN = TextEditingController();

  final TextEditingController _couponController = TextEditingController();
  double couponDiscount = 0;

  bool isCouponValidate = false;

  AddressModel? selectedAddress;
  int _radioSelected = 1;
  int manuallyAddressSelectRadio = 1;
  String selectAddressType = '';
  int selectedAddressIndex = 0;
  double latitude = 0;
  double longitude = 0;
  double deliveryCharge = 0;
  double walletBalance = 0;
  double walletUsed = 0;
  CountryCode? countryCode = CountryCode.fromCountryCode('IN');
  bool isPrintKot = false;
  bool isPrepaid = false;
  bool isAutoBillPrint = false;
  String? audioPath;
  StreamSubscription<BTStatus>? _singlePrintBtStatus;

  double availableLoyaltyPoint = 0;
  double usedLoyaltyPoint = 0;
  double loyaltyDiscountPercent = 0;
  double crmLoyaltyDiscount = 0;
  double crmMaxPoints = 0;
  double crmAvailablePoints = 0;
  String crmLoyaltyTier = '';
  int crmEarnPoints = 0;
  String crmLoyaltyHint = '';
  bool crmLoyaltyHidden = false;
  bool crmLoyaltyBelowMin = false;
  String crmCouponTitle = '';
  String crmCouponBenefit = '';
  String crmCouponScope = '';
  double crmCouponRupee = 0;
  String crmCouponCode = '';
  bool crmCouponStackable = true;
  Timer? _crmOfferDebounce;
  String _crmOfferKey = '';
  int _crmCouponFetchCount = 0;
  bool _crmOfferInFlight = false;
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _addTips = TextEditingController();
  final TextEditingController paidController = TextEditingController();
  final TextEditingController changeController = TextEditingController();
  final TextEditingController _transactionNoController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  double discountedOrderSubTotal = 0;
  double vatAmount = 0;
  String selectedDiscountType = 'Fixed';
  List<String> discountType = ['No', 'Percent', 'Fixed'];

  bool isPrint = true;
  DiscountCategoryListModel? selectedDiscount;

  PrinterManager individualPrinter = PrinterManager.instance;
  List<int>? pendingTask;
  double coummunityDiscount = 0;
  double coummunityDiscountPercentage = 0;
  double gstAmount = 0;
  double gstTaxPercentage = 0;
  double orderDiscount = 0;
  double showServiceChargeValue = 0;
  double serviceChargePercentage = 0;
  double orderItemTotal = 0;
  double orderSubTotal = 0;
  double previousOrderSubTotal = 0;
  DateTime? selectedDateTime;
  String orderId = '';
  bool isCardOption = false;
  bool isUPIOption = false;
  bool _isFetchingCustomerDetail = false;
  bool _isSubmitting = false;

  bool _beginPlaceOrder() {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    if (mounted) setState(() {});
    return true;
  }

  void _releasePlaceOrderLock() {
    if (!_isSubmitting) return;
    _isSubmitting = false;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initData();
    isCardOption = Get.find<AuthController>()
            .profileModel
            ?.restaurants
            ?.first
            .paymentModes
            ?.any((e) => (e.name ?? '').toLowerCase() == 'card') ??
        false;
    isUPIOption = Get.find<AuthController>()
            .profileModel
            ?.restaurants
            ?.first
            .paymentModes
            ?.any((e) => (e.name ?? '').toLowerCase() == 'upi') ??
        false;
  }

  initData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.find<AuthController>()
              .profileModel!
              .restaurants!
              .first
              .printKot ==
          'Yes') {
        if (mounted)
          setState(() {
            isPrintKot = true; // Example: Set the initial state
          });
      }
      Get.find<CartController>().applyWalletBalance(false);
      Get.find<CartController>().applyLoyaltyValue(false);
    });

    _dobController.clear();
    _anniversaryController.clear();
    _selectedDropdownOption = null;
    _addNoteController.text = '${widget.editOrder?.orderNote ?? ''}';
    if (widget.editOrder?.user != null) {
      _nameController.text =
          '${widget.editOrder?.user?.fName ?? ''} ${widget.editOrder?.user?.lName ?? ''}';
      _phoneController.text = '${widget.editOrder?.user?.phone ?? ''}';

      _dobController.text = '${widget.editOrder?.user?.dob ?? ''}';
      _anniversaryController.text =
          '${widget.editOrder?.user?.anniversary ?? ''}';
      final membershipId = widget.editOrder?.user?.userRestaurant?.membershipId;
      _selectedDropdownOption =
          (membershipId == null || membershipId.isEmpty) ? null : membershipId;
    }
    if (widget.editOrder != null &&
        widget.editOrder!.deliveryAddress != null &&
        widget.editOrder!.deliveryAddress!.contactPersonNumber != '') {
      selectedPhoneController.text =
          widget.editOrder?.deliveryAddress?.contactPersonNumber ?? '';
    }
    if ((widget.editOrder?.userName ?? '').isNotEmpty) {
      _nameController.text = '${widget.editOrder?.userName ?? ''}';
    }

    if (widget.editOrder?.orderDetails != null) {
      deliveryCharge = widget.editOrder?.deliveryCharge ?? 0;
      if (deliveryCharge != 0)
        selectedDeliveryCharge.text =
            '${widget.editOrder?.deliveryCharge ?? 0}';
      double halfVariationPrice = 0;
      previousOrderSubTotal = 0;
      for (var i = 0; i < (widget.editOrder?.orderDetails?.length ?? 0); i++) {
        double variationTotal = 0;
        double addonsTotal = 0;
        final food = widget.editOrder!.orderDetails![i];
        if (food.variation != null && food.variation!.isNotEmpty) {
          for (int j = 0; j < food.variation!.length; j++) {
            final variation = food.variation![j];
            if (variation.values != null) {
              for (var element in variation.values!) {
                if ((variation.name ?? '').toUpperCase() == 'HALFNHALF') {
                  if (halfVariationPrice <
                      double.parse(element.optionPrice ?? '0') *
                          (food.quantity ?? 0)) {
                    halfVariationPrice =
                        double.parse(element.optionPrice ?? '0') *
                            (food.quantity ?? 0);
                  }
                } else {
                  variationTotal = variationTotal +
                      double.parse(element.optionPrice ?? '0') *
                          (food.quantity ?? 0);
                }
              }
            }
            variationTotal = variationTotal + halfVariationPrice;
          }
        }

        if (food.addOns != null) {
          for (var i = 0; i < food.addOns!.length; i++) {
            final addOn = food.addOns![i];
            addonsTotal = addonsTotal +
                (((addOn.price ?? 0) * (addOn.qty ?? 0)) *
                    (food.quantity ?? 0));
          }
        }
        // if(food.foodDetails!.name.toString().toLowerCase()!='check in'){

        if (food.foodStatus != 3)
          previousOrderSubTotal = previousOrderSubTotal +
              (food.unitPrice ?? 0) * (food.quantity ?? 0) +
              variationTotal +
              addonsTotal;
        // foodAmount = (food.unitPrice ?? 0) * (food.quantity ?? 0) +
        //     variationTotal +
        //     addonsTotal;
        // }
        // double itemPrice = 0;
        // // itemPrice = orderItemList[index].price.toDouble();
        // String variationText = '';
        // // Removed unused variable 'addons'

        // if (food.foodStatus != 3) {
        //   itemPrice = itemPrice + (food.price ?? 0);
        //   if (food.variation != null && food.variation!.isNotEmpty) {
        //     for (int j = 0; j < (food.variation?.length ?? 0); j++) {
        //       variationText +=
        //           '${variationText.isNotEmpty ? ', ' : ''}${food.variation![j].name} (';

        //       if (food.variation![j].values != null) {
        //         List<String> labelList = [];
        //         for (var element in food.variation![j].values!) {
        //           labelList.add(element.level ?? '');
        //           itemPrice = itemPrice +
        //               ((double.tryParse(element.optionPrice ?? '0') ?? 0) *
        //                   (food.quantity ?? 0));
        //         }
        //         variationText +=
        //             '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
        //       }

        //       variationText += ')';
        //     }
        //   }

        //   if (food.addOns != null && food.addOns!.isNotEmpty) {
        //     for (var k = 0; k < (food.addOns?.length ?? 0); k++) {
        //       final addOn = food.addOns![k];
        //       itemPrice = itemPrice +
        //           (((addOn.qty ?? 0) * (addOn.price ?? 0)).toDouble());
        //       // If you want to use the addOn name/qty, you can add logic here
        //       // e.g., addons += '${addOn.name} (${addOn.qty})';
        //     }
        //   }

        //   foodTotal = foodTotal + itemPrice;
        // }
      }
    }

    Get.find<CartController>().calculationCart();
    Get.find<PosController>().setPaymentTabName('');
    Get.find<PosController>().setcollectItemPrice(0);
    Get.find<PosController>().setRoomIndex(null);

    selectedDiscountType = Get.find<AuthController>()
        .profileModel!
        .restaurants!
        .first
        .discountType!;
    isAutoBillPrint = Get.find<AuthController>()
            .profileModel!
            .restaurants!
            .first
            .isAutoBillPrintBilling ==
        'Yes';
    // Get.find<PosController>().changeServeiceChargeValue(
    //     widget.editOrder != null && widget.editOrder!.serviceCharge != 0
    //         ? true
    //         : (Get.find<AuthController>()
    //                         .profileModel!
    //                         .restaurants!
    //                         .first
    //                         .serviceCharge ==
    //                     'Yes' &&
    //                 Get.find<AuthController>()
    //                         .profileModel!
    //                         .restaurants!
    //                         .first
    //                         .autoServiceCharge ==
    //                     'Yes' &&
    //                 (Get.find<TableController>().selectedTable != null &&
    //                     Get.find<TableController>().selectedTable!.tableNo !=
    //                         'Take Away' &&
    //                     Get.find<TableController>().selectedTable!.tableNo !=
    //                         'Delivery')
    //             ? true
    //             : false));
    Get.find<PosController>().changeServeiceChargeValue(
        Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .isOrderPaymentType ==
                'postpaid'
            ? false
            : widget.editOrder != null
                ? ((widget.editOrder!.orderType == 'take_away' ||
                        widget.editOrder!.orderType == 'delivery' ||
                        widget.editOrder!.orderType == 'takeaway')
                    ? false
                    : (widget.editOrder!.serviceCharge != 0
                        ? true
                        : (Get.find<AuthController>()
                                    .profileModel!
                                    .restaurants!
                                    .first
                                    .serviceCharge ==
                                'Yes' &&
                            Get.find<AuthController>()
                                    .profileModel!
                                    .restaurants!
                                    .first
                                    .autoServiceCharge ==
                                'Yes')))
                : (Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .serviceCharge ==
                            'Yes' &&
                        Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .autoServiceCharge ==
                            'Yes' &&
                        (Get.find<TableController>().selectedTable != null &&
                            Get.find<TableController>()
                                    .selectedTable!
                                    .tableNo !=
                                'Take Away' &&
                            Get.find<TableController>()
                                    .selectedTable!
                                    .tableNo !=
                                'Delivery')
                    ? true
                    : false));
    serviceChargePercentage = Get.find<AuthController>()
        .profileModel!
        .restaurants!
        .first
        .serviceChargePercentage!;
    discountCalculator();

    // Get.find<PosController>().setcollectItemPrice(orderAmount +
    //     gstAmount +
    //     showServiceChargeValue +
    //     (widget.editOrder == null
    //         ? 0
    //         : (double.parse(widget.editOrder!.orderAmount!))));
    if (widget.editOrder == null) {
      await Get.find<CartController>().getCustomerFromApi();
      await Get.find<CustomerManagementController>()
          .getCustomerDesignationList();

      // await Get.find<CartController>().getCustomerFromApi(isLoading: true);
      await Get.find<PosController>().getRoomList();

      await Get.find<PosController>().getTapManageMentCustomerList();
      individualListenBluetooth();
    }
    if (widget.editOrder?.orderType == 'delivery') {
      if (widget.editOrder?.deliveryAddress != null) {
        // selectedAddress = widget.editOrder?.deliveryAddress ;
        _dobController.text = widget.editOrder?.deliveryAddress?.dob ?? '';
        _anniversaryController.text =
            widget.editOrder?.deliveryAddress?.doa ?? '';
        _selectedDropdownOption =
            widget.editOrder?.deliveryAddress?.membershipId ?? '';
      }
    }
    if (Get.find<TableController>().selectedTable?.tableNo == 'Delivery') {
      if ((Get.find<CartController>().selectedCustomer?.phone ?? '') != '') {
        await Get.find<LocationController>().getAddressList(
            Get.find<CartController>().selectedCustomer?.phone ?? '');
        if (Get.find<LocationController>().addressList.isNotEmpty) {
          selectedAddress = Get.find<LocationController>().addressList.first;
          if (Get.find<CartController>().cartList.isNotEmpty &&
              (selectedAddress?.latitude ?? '') != '') {
            await Get.find<LocationController>().getDeliveryCharges(
                addLat: double.parse(selectedAddress?.latitude ?? '0'),
                addLong: double.parse(selectedAddress?.longitude ?? '0'),
                restId: Get.find<AuthController>()
                        .profileModel
                        ?.restaurants
                        ?.first
                        .id
                        ?.toString() ??
                    '');
            if ((Get.find<LocationController>()
                        .getDeliveryChargesResponse
                        ?.shippingCharge ??
                    0) !=
                0) {
              deliveryCharge = Get.find<LocationController>()
                      .getDeliveryChargesResponse
                      ?.shippingCharge ??
                  0;
              selectedDeliveryCharge.text = deliveryCharge.toString();
            }
          }
          Get.find<LocationController>().update();
          // pincodeController.text =Get.find<LocationController>().addressList?.first.address??'';
        }
      }
    }
    Get.find<CartController>().calculationCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          // toolbarHeight: Get.height / 10.72,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: ColorTheme.green,
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          elevation: 0,
          centerTitle: false,
          title: MediaQuery.of(context).size.shortestSide > 570
              ? Image.asset(
                  logoHelper.appLogo!,
                  width: Get.width * 0.2,
                )
              : Image.asset(
                  logoHelper.appLogo!,
                  width: Get.width * 0.25,
                ),
          actions: [
            if (widget.editOrder == null &&
                Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .scheduleOrder!)
              InkWell(
                onTap: () {
                  pickDateTime(context);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Row(
                    children: [
                      Icon(Icons.alarm, color: ColorTheme.appColor),
                      if (selectedDateTime != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            DateFormat('dd-MM hh:mm a')
                                .format(selectedDateTime!),
                            style: poppinsMedium.copyWith(
                                fontSize: 12, color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                ),
              ), // Placeholder for centering the title
            if (Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .restaurantType ==
                'Restaurant buffet')
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child:
                    GetBuilder<RestaurantController>(builder: (restController) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Priority', // Display the current mode
                        style: poppinsMedium.copyWith(
                            fontSize: 12, color: Colors.black),
                      ),
                      Transform.scale(
                        scale: 0.7,
                        child: SizedBox(
                          width: 45,
                          child: CupertinoSwitch(
                            value: restController.isPriority ==
                                'Yes', // Current state of the switch
                            onChanged: (bool value) {
                              restController.setOrderType(value ? 'Yes' : 'No');
                            },
                          ),
                        ),
                      ),

                      // Add some space between text and switch
                    ],
                  );
                }),
              ),
          ],
        ),
        body: SafeArea(
          child: GetBuilder<LoyaltyController>(builder: (loyaltyController) {
            return GetBuilder<CartController>(
              builder: (cartController) {
                return cartController.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : cartController.cartList.length > 0
                        ? SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (Get.find<AuthController>()
                                          .profileModel
                                          ?.restaurants
                                          ?.first
                                          .foodLevelNotes !=
                                      'Yes')
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 10, left: 20, right: 20),
                                      child: TextField(
                                        controller: _addNoteController,
                                        autofocus: false,
                                        maxLines: 4,
                                        decoration: InputDecoration(
                                          hintText: 'Add notes..'.tr,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.PADDING_SIZE_SMALL,
                                              vertical: Dimensions
                                                  .PADDING_SIZE_EXTRA_SMALL),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: ColorTheme.borderGrey),
                                            borderRadius:
                                                BorderRadius.circular(7.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: ColorTheme.borderGrey),
                                            borderRadius:
                                                BorderRadius.circular(7.0),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: ColorTheme.borderGrey),
                                            borderRadius:
                                                BorderRadius.circular(7.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: ColorTheme.borderGrey),
                                            borderRadius:
                                                BorderRadius.circular(7.0),
                                          ),
                                          hintStyle: poppinsMedium.copyWith(
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .shortestSide >
                                                      570
                                                  ? 15
                                                  : 13,
                                              color: ColorTheme.hintText),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        style: poppinsMedium.copyWith(
                                          color: Colors.black,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .shortestSide >
                                                  570
                                              ? 15
                                              : 13,
                                        ),
                                        onChanged: (value) async {},
                                      ),
                                    ),
                                  if (Get.find<AuthController>()
                                          .profileModel
                                          ?.restaurants
                                          ?.first
                                          .foodLevelNotes !=
                                      'Yes')
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child:
                                          Divider(color: ColorTheme.borderGrey),
                                    ),
                                  customerDetail(cartController),
                                  // if (widget.editOrder == null &&
                                  //     Get.find<TableController>()
                                  //             .selectedTable!
                                  //             .tableNo ==
                                  //         'Delivery')
                                  //   showPlayer
                                  //       ? Padding(
                                  //           padding: const EdgeInsets.symmetric(
                                  //               horizontal: 25),
                                  //           child: SizedBox(
                                  //             height: Get.height * 0.1,
                                  //             child: AudioPlayer(
                                  //               source: audioPath,
                                  //               onDelete: () {
                                  //                 audioPath = null;
                                  //                 setState(
                                  //                     () => showPlayer = false);
                                  //               },
                                  //             ),
                                  //           ),
                                  //         )
                                  //       : Padding(
                                  //           padding: const EdgeInsets.symmetric(
                                  //               horizontal: 20),
                                  //           child: SizedBox(
                                  //             height: Get.height * 0.1,
                                  //             child: Recorder(
                                  //               onStop: (path) {
                                  //                 setState(() {
                                  //                   audioPath = path;
                                  //                   showPlayer = true;
                                  //                 });
                                  //               },
                                  //             ),
                                  //           ),
                                  //         ),
                                  // if (widget.editOrder == null)
                                  //   InkWell(
                                  //     onTap: () {
                                  //       setState(() {
                                  //         isPrepaid = !isPrepaid;
                                  //       });
                                  //     },
                                  //     child: Padding(
                                  //       padding: const EdgeInsets.only(right: 20),
                                  //       child: Row(
                                  //         mainAxisAlignment:
                                  //             MainAxisAlignment.end,
                                  //         children: [
                                  //           SizedBox(
                                  //             width: 28,
                                  //             child: Checkbox(
                                  //               value: isPrepaid,
                                  //               onChanged: (bool? value) {
                                  //                 setState(() {
                                  //                   isPrepaid = !isPrepaid;
                                  //                 });
                                  //               },
                                  //             ),
                                  //           ),
                                  //           Text(
                                  //             "Pre-Paid",
                                  //             style: poppinsMedium.copyWith(
                                  //                 fontSize: 12,
                                  //                 color: Colors.black),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ),
                                  if (widget.editOrder != null)
                                    SizedBox(
                                        height: Dimensions.PADDING_SIZE_SMALL),
                                  widget.editOrder == null
                                      ? SizedBox.shrink()
                                      : Container(
                                          margin: EdgeInsets.only(
                                              top: 15, left: 20, right: 20),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 20),
                                          decoration: BoxDecoration(
                                            color: ColorTheme.productCard,
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.RADIUS_LARGE),
                                          ),
                                          child: ListView.builder(
                                              itemCount: widget.editOrder
                                                      ?.orderDetails?.length ??
                                                  0,
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int i) {
                                                OrderDetails food = widget
                                                    .editOrder!
                                                    .orderDetails![i];
                                                double itemPrice = 0;
                                                // itemPrice = orderItemList[index].price.toDouble();
                                                String variationText = '';
                                                if (food.foodStatus != 3) {
                                                  itemPrice = itemPrice +
                                                      (food.price ?? 0);
                                                  if (food.variation != null &&
                                                      (food.variation
                                                              ?.isNotEmpty ??
                                                          false)) {
                                                    for (int j = 0;
                                                        j <
                                                            (food.variation
                                                                    ?.length ??
                                                                0);
                                                        j++) {
                                                      variationText +=
                                                          '${variationText.isNotEmpty ? ', ' : ''}${food.variation?[j].name ?? ''} (';

                                                      if (food.variation?[j]
                                                              .values !=
                                                          null) {
                                                        List<String> labelList =
                                                            [];
                                                        for (var element in food
                                                                .variation?[j]
                                                                .values ??
                                                            []) {
                                                          labelList.add(
                                                              element.level ??
                                                                  '');
                                                          itemPrice = itemPrice +
                                                              ((double.tryParse(
                                                                          element.optionPrice ??
                                                                              '0') ??
                                                                      0) *
                                                                  (food.quantity ??
                                                                      0));
                                                        }
                                                        variationText +=
                                                            '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                                                      }

                                                      variationText += ')';
                                                    }
                                                  }

                                                  if (food.addOns != null) {
                                                    for (var k = 0;
                                                        k <
                                                            (food.addOns
                                                                    ?.length ??
                                                                0);
                                                        k++) {
                                                      itemPrice = itemPrice +
                                                          (((food.addOns?[k]
                                                                          .qty ??
                                                                      0) *
                                                                  (food.addOns?[k]
                                                                          .price ??
                                                                      0))
                                                              .toDouble());
                                                    }
                                                  }
                                                }
                                                return widget
                                                            .editOrder
                                                            ?.orderDetails?[i]
                                                            .foodStatus ==
                                                        3
                                                    ? SizedBox.shrink()
                                                    : Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: i == 0
                                                                    ? 0
                                                                    : 8),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                // '${widget.editOrder!.orderDetails?[i].foodDetails?.name ?? ''} (${widget.editOrder?.orderDetails?[i].quantity ?? ''})',

                                                                '${widget.editOrder!.orderDetails?[i].foodDetails?.name ?? ''} (${(widget.editOrder?.orderDetails?[i].quantity ?? 0) % 1 == 0 ? (widget.editOrder?.orderDetails?[i].quantity ?? 0).toInt() : widget.editOrder?.orderDetails?[i].quantity ?? 0})',

                                                                style: poppinsSemiBold
                                                                    .copyWith(
                                                                        fontSize:
                                                                            15),
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            if (Get.find<
                                                                        AuthController>()
                                                                    .profileModel!
                                                                    .restaurants!
                                                                    .first
                                                                    .isComplementry !=
                                                                'Yes')
                                                              Text('$itemPrice',
                                                                  style: poppinsBold.copyWith(
                                                                      color: ColorTheme
                                                                          .green,
                                                                      fontSize: MediaQuery.of(context).size.shortestSide >
                                                                              570
                                                                          ? 16
                                                                          : Dimensions
                                                                              .FONT_SIZE_DEFAULT)),
                                                          ],
                                                        ),
                                                      );
                                              }),
                                        ),
                                  SizedBox(
                                      height: Dimensions.PADDING_SIZE_LARGE),
                                  // Product
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: cartController.cartList.length,
                                      itemBuilder: (context, index) {
                                        return productWidget(
                                          cartC: cartController,
                                          onIncrease: (data) {
                                            if (data != null && data) {
                                              Future.delayed(
                                                  Duration(microseconds: 300),
                                                  () {
                                                discountCalculator();
                                              });
                                            }
                                          },
                                          cart: cartController.cartList[index],
                                          cartIndex: index,
                                          addOns:
                                              cartController.addOnsList[index],
                                          isAvailable: cartController
                                              .availableList[index],
                                        );
                                      },
                                    ),
                                  ),
                                  // SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                                  if (Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .restaurantType !=
                                      'Restaurant buffet')
                                    Padding(
                                      padding: const EdgeInsets.only(right: 25),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Checkbox(
                                            value: isPrintKot,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isPrintKot = value!;
                                              });
                                            },
                                          ),
                                          Text(
                                            "Print KOT",
                                            style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 15
                                                    : 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .restaurantType !=
                                      'Restaurant buffet')
                                    amountDetail(cartController),

                                  SizedBox(
                                      height: Dimensions.PADDING_SIZE_SMALL),
                                  if (widget.editOrder == null &&
                                      Get.find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .restaurantType !=
                                          'Restaurant buffet' &&
                                      Get.find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .isOrderPaymentType !=
                                          'postpaid')
                                    showPaymentDetail(),
                                ]),
                          )
                        : Center(child: Text('no_food_available'.tr));
              },
            );
          }),
        ),
        bottomNavigationBar:
            GetBuilder<TableController>(builder: (tableController) {
          return GetBuilder<PosController>(builder: (posController) {
            return GetBuilder<CartController>(builder: (cartController) {
              return cartController.isLoading
                  ? SizedBox(height: 2)
                  : cartController.cartList.isNotEmpty
                      ? GetBuilder<LocationController>(
                          builder: (locationController) {
                          return SafeArea(
                              child: Container(
                            height: 70,
                            width: Get.width,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions
                                  .PADDING_SIZE_LARGE, /* vertical: Dimensions.PADDING_SIZE_SMALL*/
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0xFF2A2A2A)
                                        .withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, -5))
                              ],
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (widget.editOrder != null)
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                              '${'item'.tr}: ${cartController.cartList.length}',
                                              style: poppinsMedium.copyWith(
                                                  color: ColorTheme.blue,
                                                  fontSize: 11)),
                                          if (deliveryCharge != 0)
                                            const SizedBox(
                                                height: Dimensions
                                                    .PADDING_SIZE_EXTRA_SMALL),
                                          if (deliveryCharge != 0)
                                            Text(
                                                'Delivery charge: $deliveryCharge',
                                                style: poppinsMedium.copyWith(
                                                    color: ColorTheme.blue,
                                                    fontSize: 11)),
                                          if (Get.find<AuthController>()
                                                  .profileModel!
                                                  .restaurants!
                                                  .first
                                                  .isComplementry !=
                                              'Yes')
                                            const SizedBox(
                                                height: Dimensions
                                                    .PADDING_SIZE_EXTRA_SMALL),
                                          if (Get.find<AuthController>()
                                                  .profileModel!
                                                  .restaurants!
                                                  .first
                                                  .isComplementry !=
                                              'Yes')
                                            Text(
                                              'Rs. ${PriceConverter.convertPrice(cartController.calculationCart() + deliveryCharge, isHideCurrency: true)}',
                                              style: poppinsSemiBold.copyWith(
                                                  fontSize: 15,
                                                  color: Colors.black),
                                            ),
                                        ]),
                                  if (Get.find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .restaurantType !=
                                          'Restaurant buffet' &&
                                      Get.find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .isOrderPaymentType !=
                                          'postpaid' &&
                                      (posController.paymentTab.toLowerCase() !=
                                              'paylater' &&
                                          posController.paymentTab
                                                  .toLowerCase() !=
                                              'tab') &&
                                      Get.find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .settings!
                                              .autoPaid !=
                                          'Yes')
                                        if(Get.find<AuthController>()
                            .profileModel!
                            .role!
                            .contains('clear_payment'))
                                    widget.editOrder == null
                                        ? cartController.isEDCLoading
                                            ? CircularProgressIndicator()
                                            : InkWell(
                                                mouseCursor: _isSubmitting
                                                    ? SystemMouseCursors
                                                        .forbidden
                                                    : SystemMouseCursors.click,
                                                onTap: _isSubmitting
                                                    ? null
                                                    : () {
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                  isPrepaid = true;

                                                  if (posController.paymentTab
                                                          .toLowerCase() ==
                                                      'tab') {
                                                    if (_phoneController
                                                        .text.isEmpty) {
                                                      showErrorToast(
                                                          'Please enter phone number ');
                                                    } else if (_phoneController
                                                            .text.isNotEmpty &&
                                                        (countryCode
                                                                    ?.dialCode ??
                                                                '+91') ==
                                                            '+91' &&
                                                        _phoneController
                                                                .text.length !=
                                                            10) {
                                                      showErrorToast(
                                                          'Minimum required 10 digit phone number');
                                                    } else {
                                                      if (discountedOrderSubTotal >=
                                                          0) {
                                                        // payTabBills();
                                                        placeOrderCallFunction(
                                                            posController);
                                                      } else {
                                                        showErrorToast(
                                                            'Please enter valid discount');
                                                      }
                                                    }
                                                  } else if (posController
                                                          .paymentTab ==
                                                      '') {
                                                    showErrorToast(
                                                        'Please select any payment method');
                                                  } else {
                                                    if (_phoneController
                                                            .text.isNotEmpty &&
                                                        (countryCode
                                                                    ?.dialCode ??
                                                                '+91') ==
                                                            '+91' &&
                                                        _phoneController
                                                                .text.length !=
                                                            10) {
                                                      showErrorToast(
                                                          'Minimum required 10 digit phone number');
                                                    } else {
                                                      if (discountedOrderSubTotal >=
                                                          0) {
                                                        if (posController
                                                                .paymentTab
                                                                .toLowerCase() ==
                                                            'room') {
                                                          if (posController
                                                                  .selectedRoom!
                                                                  .table!
                                                                  .id ==
                                                              0) {
                                                            showErrorToast(
                                                                'Please select room');
                                                          } else {
                                                            placeOrderCallFunction(
                                                                posController);
                                                          }
                                                        } else {
                                                          placeOrderCallFunction(
                                                              posController);
                                                        }
                                                      } else {
                                                        showErrorToast(
                                                            'Please enter valid discount');
                                                      }
                                                    }
                                                  }
                                                },
                                                child: Container(
                                                  height: 30,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .PADDING_SIZE_DEFAULT,
                                                  ),
                                                  decoration: BoxDecoration(
                                                      color: _isSubmitting
                                                          ? Colors.grey
                                                          : ColorTheme.appColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7)),
                                                  child: Center(
                                                    child: Text(
                                                      'Place & Collect Bill',
                                                      style: poppinsMedium
                                                          .copyWith(
                                                              fontSize: 13,
                                                              color:
                                                                  Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              )
                                        : SizedBox(),
                                  if (!cartController.isEDCLoading &&
                                      isShowPlaceOrder() &&
                                      (Get.find<AuthController>()
                                                  .profileModel!
                                                  .restaurants!
                                                  .first
                                                  .isOrderPaymentType !=
                                              'prepaid' ||
                                          posController.paymentTab
                                                  .toLowerCase() ==
                                              'paylater' ||
                                          posController.paymentTab
                                                  .toLowerCase() ==
                                              'tab'))
                                    InkWell(
                                      mouseCursor: _isSubmitting
                                          ? SystemMouseCursors.forbidden
                                          : SystemMouseCursors.click,
                                      onTap: _isSubmitting
                                          ? null
                                          : () async {
                                        isPrepaid = false;
                                        if (Get.find<AuthController>()
                                                .profileModel!
                                                .restaurants!
                                                .first
                                                .settings!
                                                .autoPaid ==
                                            'Yes') {
                                          placeOrderCallFunction(posController);
                                        } else {
                                          if (tableController
                                                      .selectedTable?.id ==
                                                  0 &&
                                              tableController
                                                      .selectedTable?.tableNo ==
                                                  'Delivery' &&
                                              selectedAddress == null &&
                                              widget.editOrder == null) {
                                            showErrorToast(
                                                'Please add address');
                                          } else if (_phoneController
                                              .text.isEmpty) {
                                            if (Get.find<AuthController>()
                                                    .profileModel!
                                                    .restaurants!
                                                    .first
                                                    .restaurantType ==
                                                'Restaurant buffet') {
                                              if (!_beginPlaceOrder()) return;
                                              try {
                                                await Get.find<CartController>()
                                                    .buffetPlaceOrder(
                                                  0,
                                                  '',
                                                  _nameController.text.isEmpty
                                                      ? ''
                                                      : _nameController.text,
                                                  _addNoteController.text.isEmpty
                                                      ? ''
                                                      : _addNoteController.text,
                                                  widget.editOrder == null
                                                      ? '${cartController.subTotal + deliveryCharge}'
                                                      : '${(cartController.subTotal) + previousOrderSubTotal + deliveryCharge}',
                                                  'pos',
                                                  callback,
                                                  addressId: '',
                                                  audioFile: '',
                                                );
                                              } catch (_) {
                                                _releasePlaceOrderLock();
                                              }
                                            } else {
                                              placeOrderCallFunction(
                                                  posController);
                                            }
                                            // }
                                          } else if (_phoneController
                                                  .text.isNotEmpty &&
                                              (countryCode?.dialCode ??
                                                      '+91') ==
                                                  '+91' &&
                                              _phoneController.text.length !=
                                                  10) {
                                            showErrorToast(
                                                'enter_a_valid_phone_number');
                                          } else {
                                            if (Get.find<AuthController>()
                                                    .profileModel!
                                                    .restaurants!
                                                    .first
                                                    .restaurantType ==
                                                'Restaurant buffet') {
                                              if (!_beginPlaceOrder()) return;
                                              try {
                                                await Get.find<CartController>()
                                                    .buffetPlaceOrder(
                                                  0,
                                                  _phoneController.text.isEmpty
                                                      ? ''
                                                      : _phoneController.text,
                                                  _nameController.text.isEmpty
                                                      ? ''
                                                      : _nameController.text,
                                                  _addNoteController.text.isEmpty
                                                      ? ''
                                                      : _addNoteController.text,
                                                  widget.editOrder == null
                                                      ? '${cartController.subTotal + deliveryCharge}'
                                                      : '${(cartController.subTotal) + previousOrderSubTotal + deliveryCharge}',
                                                  'pos',
                                                  callback,
                                                  addressId: '',
                                                  audioFile: '',
                                                );
                                              } catch (_) {
                                                _releasePlaceOrderLock();
                                              }
                                            } else {
                                              placeOrderCallFunction(
                                                  posController);
                                            }
                                          }
                                        }
                                      },
                                      child: Container(
                                        height: 30,
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.PADDING_SIZE_DEFAULT,
                                        ),
                                        decoration: BoxDecoration(
                                            color: _isSubmitting
                                                ? Colors.grey
                                                : ColorTheme.appColor,
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        child: Center(
                                          child: Text(
                                            'Place Order',
                                            style: poppinsMedium.copyWith(
                                                fontSize: 14,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                ]),
                          ));
                        })
                      : const SizedBox();
            });
          });
        }));
  }

  Widget showSelectedAddress(String title, String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Get.width * 0.3,
            child: Text(
              title,
              style: TextStyle(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 17 : 13,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Text('  :  ',
              style: TextStyle(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 17 : 13,
                  fontWeight: FontWeight.w600)),
          Flexible(
              child: Text(
            subTitle,
            style: TextStyle(
                fontSize:
                    MediaQuery.of(context).size.shortestSide > 570 ? 16 : 12),
          ))
        ],
      ),
    );
  }

  void showAddressListDialog() {
    bool isEdit = false;
    bool isTapButton = false;

    Get.bottomSheet(StatefulBuilder(builder: (context, setState) {
      return Container(
        height: Get.height * 0.6,
        padding: EdgeInsets.only(
            left: 25,
            right: 25,
            top: 25,
            bottom: Dimensions.PADDING_SIZE_DEFAULT),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
            color: Colors.white),
        child: GetBuilder<LocationController>(builder: (locationController) {
          return locationController.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isEdit ? 'Update Address' : 'Select Address',
                            style: poppinsMedium.copyWith(
                                fontSize: 18, color: Colors.black)),
                        InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: Icon(Icons.close,
                                size: 26, color: ColorTheme.appColor))
                      ],
                    ),
                    const SizedBox(height: 15),
                    isEdit
                        ? Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            child: Radio(
                                              value: 1,
                                              groupValue: _radioSelected,
                                              activeColor: ColorTheme.appColor,
                                              onChanged: (value) {
                                                _radioSelected = value as int;
                                                // _radioVal = 'Check In';
                                                // print(_radioVal);
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: InkWell(
                                                onTap: () {
                                                  _radioSelected = 1;
                                                  setState(() {});
                                                },
                                                child: const Text("Home")),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            child: Radio(
                                              value: 2,
                                              groupValue: _radioSelected,
                                              activeColor: Theme.of(context)
                                                  .primaryColor,
                                              onChanged: (value) {
                                                _radioSelected = value as int;
                                                // _radioVal = 'Check Out';
                                                // print(_radioVal);
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: InkWell(
                                                onTap: () {
                                                  _radioSelected = 2;
                                                  setState(() {});
                                                },
                                                child: const Text("Work")),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            child: Radio(
                                              value: 3,
                                              groupValue: _radioSelected,
                                              activeColor: Theme.of(context)
                                                  .primaryColor,
                                              onChanged: (value) {
                                                _radioSelected = value as int;
                                                // _radioVal = 'Check Out';
                                                // print(_radioVal);
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: InkWell(
                                                onTap: () {
                                                  _radioSelected = 3;
                                                  setState(() {});
                                                },
                                                child: const Text("Other")),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // const SizedBox(height: 20),

                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: MyTextField(
                                      showBorder: true,
                                      hintText: 'Contact Person Name'.tr,
                                      inputType: TextInputType.name,
                                      controller: addNameController,
                                      onChanged: (String v) {
                                        locationController.update();
                                      },
                                      capitalization: TextCapitalization.words,
                                    ),
                                  ),
                                  if (isTapButton &&
                                      addNameController.text.isEmpty)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          'Name required'.tr,
                                          style: poppinsRegular.copyWith(
                                              color: Colors.red, fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: ColorTheme.borderGrey),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: Row(children: [
                                        CountryCodePicker(
                                          onChanged:
                                              (CountryCode _countryCode) {
                                            countryCode = _countryCode;
                                          },
                                          initialSelection: 'IN',
                                          // enabled: false,
                                          showDropDownButton: true,
                                          padding: EdgeInsets.zero,
                                          showFlagMain: false,
                                          flagWidth: 20,
                                          dialogBackgroundColor:
                                              Theme.of(context).cardColor,
                                          textStyle: poppinsMedium.copyWith(
                                            fontSize: 13,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.only(right: 5),
                                            height: 40,
                                            child: TextField(
                                              onChanged: (String v) {
                                                locationController.update();
                                              },
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      signed: true),
                                              controller: addPhoneController,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly, // Allow only digits
                                              ],
                                              textAlignVertical:
                                                  TextAlignVertical.center,
                                              style: poppinsMedium.copyWith(
                                                  fontSize: 13),
                                              cursorColor: ColorTheme.appColor,
                                              autofocus: false,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                isDense: true,
                                                hintText:
                                                    'Contact Person Number',
                                                fillColor: Colors.white,
                                                hintStyle:
                                                    poppinsMedium.copyWith(
                                                        fontSize: 13,
                                                        color: ColorTheme
                                                            .hintText),
                                                filled: true,
                                              ),
                                            ),
                                          ),
                                        )
                                      ]),
                                    ),
                                  ),
                                  if (isTapButton &&
                                      addPhoneController.text.isEmpty)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          'Phone required'.tr,
                                          style: poppinsRegular.copyWith(
                                              color: Colors.red, fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  if (isTapButton &&
                                      addPhoneController.text.isNotEmpty &&
                                      (addPhoneController.text.length < 8 ||
                                          addPhoneController.text.length > 12))
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          'enter_a_valid_phone_number'.tr,
                                          style: poppinsRegular.copyWith(
                                              color: Colors.red, fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  // Padding(
                                  //   padding: const EdgeInsets.symmetric(horizontal: 10),
                                  //   child: MyTextField(
                                  //     showBorder: true,
                                  //     hintText: 'Contact Person Number (Ex: +911234567890)',
                                  //     inputType: TextInputType.phone,
                                  //     // focusNode: _numberNode,
                                  //     // nextFocus: _streetNode,
                                  //     controller: addPhoneController,
                                  //   ),
                                  // ),
                                  // Padding(
                                  //   padding: const EdgeInsets.symmetric(horizontal: 10),
                                  //   child: MyTextField(
                                  //     showBorder: true,
                                  //     controller: addAddressController,
                                  //     hintText: 'Delivery Address'.tr,
                                  //     inputType: TextInputType.streetAddress,
                                  //     // focusNode: _addressNode,
                                  //     // nextFocus: _nameNode,
                                  //     // controller: _addressController,
                                  //     // onChanged: (text) =>
                                  //     //     locationController.setPlaceMark(text),
                                  //   ),
                                  // ),

                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          border: Border.all(
                                              color: ColorTheme.borderGrey)),
                                      child: TypeAheadField(
                                        textFieldConfiguration:
                                            TextFieldConfiguration(
                                                controller:
                                                    addAddressController,
                                                textInputAction:
                                                    TextInputAction.search,
                                                textCapitalization:
                                                    TextCapitalization.words,
                                                keyboardType:
                                                    TextInputType.streetAddress,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          bottom: 0,
                                                          left: 13,
                                                          right: 13),
                                                  hintText:
                                                      'Delivery Address'.tr,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                    borderSide:
                                                        const BorderSide(
                                                            style: BorderStyle
                                                                .none,
                                                            width: 0),
                                                  ),
                                                  hintStyle:
                                                      poppinsMedium.copyWith(
                                                          color: ColorTheme
                                                              .hintText),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                                style: poppinsMedium.copyWith(
                                                    fontSize: 13,
                                                    color: Colors.black)),
                                        suggestionsCallback: (pattern) async {
                                          return await Get.find<
                                                  LocationController>()
                                              .searchLocation(context, pattern);
                                        },
                                        itemBuilder: (context,
                                            PredictionModel suggestion) {
                                          return Padding(
                                            padding: const EdgeInsets.all(
                                                Dimensions.PADDING_SIZE_SMALL),
                                            child: Row(children: [
                                              const Icon(Icons.location_on),
                                              Expanded(
                                                child: Text(
                                                  suggestion.description ?? '',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ]),
                                          );
                                        },
                                        onSuggestionSelected:
                                            (PredictionModel suggestion) async {
                                          addAddressController.text =
                                              suggestion.description ?? '';
                                          locationController.update();
                                          SearchAddressDetailModel? searchData =
                                              await locationController
                                                  .getSearchAddressDetail(
                                                      suggestion.placeId!);
                                          addPincodeController.text =
                                              searchData?.postalCode ?? "";
                                          latitude = searchData?.result
                                                  ?.geometry?.location?.lat ??
                                              0.0;
                                          longitude = searchData?.result
                                                  ?.geometry?.location?.lng ??
                                              0.0;
                                        },
                                      ),
                                    ),
                                  ),
                                  if (isTapButton &&
                                      addAddressController.text.isEmpty)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          'Address required'.tr,
                                          style: poppinsRegular.copyWith(
                                              color: Colors.red, fontSize: 10),
                                        ),
                                      ),
                                    ),

                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: MyTextField(
                                      showBorder: true,
                                      hintText: 'House No./Floor No.',
                                      inputType: TextInputType.name,
                                      controller: addFloorController,
                                      capitalization: TextCapitalization.words,
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: MyTextField(
                                      showBorder: true,
                                      hintText: 'Pincode.',
                                      inputType:
                                          TextInputType.numberWithOptions(
                                              signed: true),
                                      controller: addPincodeController,
                                      capitalization: TextCapitalization.words,
                                    ),
                                  ),
                                  if (isTapButton &&
                                      addPincodeController.text.isEmpty)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          'Pincode required'.tr,
                                          style: poppinsRegular.copyWith(
                                              color: Colors.red, fontSize: 10),
                                        ),
                                      ),
                                    ),

                                  const SizedBox(
                                      height: Dimensions.PADDING_SIZE_LARGE),
                                  locationController.isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                isEdit = false;
                                                addAddressController.clear();
                                                addNameController.clear();
                                                addFloorController.clear();
                                                addPhoneController.clear();
                                                addPincodeController.clear();
                                                manuallyAddressController
                                                    .clear();
                                                manuallyAddressSelectRadio = 1;
                                                _radioSelected = 1;
                                                setState(() {});
                                              },
                                              child: Container(
                                                height: 35,
                                                width: 110,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Colors.transparent),
                                                    color: ColorTheme.appColor,
                                                    // border:
                                                    //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                child: Center(
                                                  child: Text(
                                                    'Back',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 13,
                                                            color:
                                                                Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                isTapButton = true;
                                                locationController.update();

                                                if (addNameController
                                                    .text.isEmpty) {
                                                  // showCustomSnackBar(
                                                  //     'Name required');
                                                } else if (addPhoneController
                                                    .text.isEmpty) {
                                                  // showCustomSnackBar(
                                                  //     'Phone required');
                                                } else if (addAddressController
                                                    .text.isEmpty) {
                                                  // showCustomSnackBar(
                                                  //     'Address required');
                                                } else if (addPincodeController
                                                    .text.isEmpty) {
                                                  // showCustomSnackBar(
                                                  //     'Pincode required');
                                                } else {
                                                  if (addPhoneController
                                                              .text.length <
                                                          8 ||
                                                      addPhoneController
                                                              .text.length >
                                                          12) {
                                                    // showCustomSnackBar(
                                                    //     'Enter valid phone number');
                                                  } else {
                                                    // AddressModel addressModel =
                                                    //     AddressModel(
                                                    //   id: selectedAddress!.id,
                                                    //   pincode: addPincodeController
                                                    //           .text.isEmpty
                                                    //       ? ''
                                                    //       : addPincodeController
                                                    //           .text,
                                                    //   dialCode: countryCode
                                                    //           ?.dialCode ??
                                                    //       '+91',
                                                    //   addressType:
                                                    //       _radioSelected == 1
                                                    //           ? 'Home'
                                                    //           : _radioSelected ==
                                                    //                   2
                                                    //               ? 'Work'
                                                    //               : 'Other',
                                                    //   contactPersonName:
                                                    //       addNameController
                                                    //               .text.isEmpty
                                                    //           ? ''
                                                    //           : addNameController
                                                    //               .text,
                                                    //   contactPersonNumber:
                                                    //       addPhoneController
                                                    //               .text.isEmpty
                                                    //           ? ''
                                                    //           : addPhoneController
                                                    //               .text,
                                                    //   address: addAddressController
                                                    //           .text.isEmpty
                                                    //       ? ''
                                                    //       : addAddressController
                                                    //           .text,
                                                    //   latitude:
                                                    //       latitude.toString(),
                                                    //   longitude:
                                                    //       longitude.toString(),
                                                    //   zoneId: 3,
                                                    //   road: '',
                                                    //   house: addFloorController
                                                    //           .text ??
                                                    //       '',
                                                    //   floor: '',
                                                    // );

                                                    if (userId.isEmpty ||
                                                        selectedAddress!
                                                            .id!.isEmpty) {
                                                      showCustomSnackBar(
                                                          'Invalid customer or address');
                                                      return;
                                                    }

                                                    final body = {
                                                      'address':
                                                          addAddressController
                                                              .text,
                                                      'address_type':
                                                          _radioSelected == 1
                                                              ? 'Home'
                                                              : _radioSelected ==
                                                                      2
                                                                  ? 'Work'
                                                                  : 'Other',
                                                      'house':
                                                          addFloorController
                                                                  .text ??
                                                              '',
                                                      'floor': '',
                                                      'road': '',
                                                      'city': '',
                                                      'state': '',
                                                      'pincode':
                                                          addPincodeController
                                                              .text,
                                                      'latitude':
                                                          latitude.toString(),
                                                      'longitude':
                                                          longitude.toString(),
                                                      'contact_person_name':
                                                          addNameController
                                                              .text,
                                                      'contact_person_number':
                                                          addPhoneController
                                                              .text,
                                                      'delivery_instructions':
                                                          '',
                                                      'is_default': false,
                                                    };

                                                    // ResponseModel
                                                    //     responseModel =
                                                    //     await Get.find<
                                                    //             LocationController>()
                                                    //         .updateAddress(
                                                    //             addressModel,
                                                    //             false,
                                                    //             3);
                                                    ResponseModel
                                                        responseModel =
                                                        await Get.find<
                                                                LocationController>()
                                                            .updateCrmAddress(
                                                      userId,
                                                      selectedAddress!.id!,
                                                      body,
                                                    );

                                                    if (responseModel
                                                        .isSuccess) {
                                                      await Get.find<
                                                              LocationController>()
                                                          .getCrmAddressByPhone(
                                                              selectedPhoneController
                                                                  .text);
                                                      // 2. Move edited address to top
                                                      final updatedList = Get.find<
                                                              LocationController>()
                                                          .crmAddressList;
                                                      final editedId =
                                                          selectedAddress!.id;
                                                      final updatedIndex =
                                                          updatedList
                                                              .indexWhere((a) =>
                                                                  a.id ==
                                                                  editedId);

                                                      if (updatedIndex != -1) {
                                                        final editedAddr =
                                                            updatedList.removeAt(
                                                                updatedIndex); // ← pull it out
                                                        updatedList.insert(0,
                                                            editedAddr); // ← put at top

                                                        // 3. Selected is always index 0 now
                                                        selectedAddressIndex =
                                                            0;
                                                        selectedAddress =
                                                            AddressModel(
                                                          id: editedAddr.id,
                                                          addressType:
                                                              editedAddr
                                                                  .addressType,
                                                          contactPersonName:
                                                              editedAddr
                                                                  .contactPersonName,
                                                          contactPersonNumber:
                                                              editedAddr
                                                                  .contactPersonNumber,
                                                          address: editedAddr
                                                              .address,
                                                          house:
                                                              editedAddr.house,
                                                          floor:
                                                              editedAddr.floor,
                                                          road: editedAddr.road,
                                                          pincode: editedAddr
                                                              .pincode,
                                                          dialCode: editedAddr
                                                                  .dialCode ??
                                                              '+91',
                                                          zoneId:
                                                              editedAddr.zoneId,
                                                          latitude: editedAddr
                                                              .safeLatitude
                                                              ?.toString(),
                                                          longitude: editedAddr
                                                              .safeLongitude
                                                              ?.toString(),
                                                          userId: userId,
                                                        );
                                                        selectedPhoneController
                                                            .text = editedAddr
                                                                .contactPersonNumber ??
                                                            '';
                                                      }

                                                      isEdit = !isEdit;
                                                      locationController
                                                          .update();
                                                      if (Get.find<
                                                                  CartController>()
                                                              .cartList
                                                              .isNotEmpty &&
                                                          selectedAddress!
                                                                  .latitude !=
                                                              '' &&
                                                          selectedAddress
                                                                  ?.longitude !=
                                                              null &&
                                                          selectedAddress
                                                                  ?.latitude !=
                                                              null) {
                                                        await Get.find<LocationController>().getDeliveryCharges(
                                                            addLat: double.parse(
                                                                selectedAddress
                                                                        ?.latitude ??
                                                                    '0'),
                                                            addLong: double.parse(
                                                                selectedAddress
                                                                        ?.longitude ??
                                                                    '0'),
                                                            restId: Get.find<
                                                                    AuthController>()
                                                                .profileModel!
                                                                .restaurants!
                                                                .first
                                                                .id
                                                                .toString());
                                                        if (Get.find<
                                                                    LocationController>()
                                                                .getDeliveryChargesResponse!
                                                                .shippingCharge !=
                                                            0) {
                                                          deliveryCharge = Get.find<
                                                                  LocationController>()
                                                              .getDeliveryChargesResponse!
                                                              .shippingCharge!;
                                                          selectedDeliveryCharge
                                                                  .text =
                                                              deliveryCharge
                                                                  .toString();
                                                        }
                                                      }
                                                      setState(() {});
                                                      showErrorToast(
                                                          responseModel.message,
                                                          isError: false);
                                                    }
                                                  }
                                                }
                                              },
                                              child: Container(
                                                height: 35,
                                                width: 110,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Colors.transparent),
                                                    color: ColorTheme.appColor,
                                                    // border:
                                                    //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                child: Center(
                                                  child: Text(
                                                    'submit'.tr,
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 13,
                                                            color:
                                                                Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                ],
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                                padding: EdgeInsets.only(top: 0),
                                itemCount:
                                    locationController.crmAddressList.length ??
                                        0,
                                // shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (BuildContext context, int i) {
                                  return Container(
                                    margin:
                                        EdgeInsets.only(top: i == 0 ? 0 : 20),
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: ColorTheme.borderGrey),
                                        borderRadius: BorderRadius.circular(10),
                                        color: ColorTheme.addressBoxGrey),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            selectedAddressIndex = i;
                                            // selectedAddress =
                                            //     Get.find<LocationController>()
                                            //         .addressList[i];
                                            // selectedPhoneController.text =
                                            //     Get.find<LocationController>()
                                            //         .addressList[i]
                                            //         .contactPersonNumber!;

                                            // selectAddressType =
                                            //     Get.find<LocationController>()
                                            //             .addressList[i]
                                            //             .addressType ??
                                            //         '';
                                            // NEW:
                                            final addr =
                                                Get.find<LocationController>()
                                                    .crmAddressList[i];
                                            selectedAddress = AddressModel(
                                              id: addr.id,
                                              addressType: addr.addressType,
                                              contactPersonName:
                                                  addr.contactPersonName,
                                              contactPersonNumber:
                                                  addr.contactPersonNumber,
                                              address: addr.address,
                                              house: addr.house,
                                              floor: addr.floor,
                                              road: addr.road,
                                              pincode: addr.pincode,
                                              dialCode: addr.dialCode ?? '+91',
                                              zoneId: addr.zoneId,
                                              latitude:
                                                  addr.safeLatitude?.toString(),
                                              longitude: addr.safeLongitude
                                                  ?.toString(),
                                              userId: userId,
                                            );
                                            selectedPhoneController.text =
                                                addr.contactPersonNumber ?? '';
                                            selectAddressType =
                                                addr.addressType ?? '';

                                            Get.back();
                                            if (Get.find<CartController>()
                                                    .cartList
                                                    .isNotEmpty &&
                                                selectedAddress!.latitude !=
                                                    '' &&
                                                selectedAddress?.longitude !=
                                                    null &&
                                                selectedAddress?.latitude !=
                                                    null) {
                                              await Get.find<
                                                      LocationController>()
                                                  .getDeliveryCharges(
                                                      addLat: double.parse(
                                                          selectedAddress
                                                                  ?.latitude ??
                                                              '0'),
                                                      addLong: double.parse(
                                                          selectedAddress
                                                                  ?.longitude ??
                                                              '0'),
                                                      restId: Get.find<
                                                              AuthController>()
                                                          .profileModel!
                                                          .restaurants!
                                                          .first
                                                          .id
                                                          .toString());
                                              if (Get.find<LocationController>()
                                                      .getDeliveryChargesResponse!
                                                      .shippingCharge !=
                                                  0) {
                                                deliveryCharge = Get.find<
                                                        LocationController>()
                                                    .getDeliveryChargesResponse!
                                                    .shippingCharge!;
                                                selectedDeliveryCharge.text =
                                                    deliveryCharge.toString();
                                              }
                                              walletBalance = 0;
                                              walletUsed = 0;
                                              userId =
                                                  '${selectedAddress?.userId ?? ''}';
                                              if (Get.find<CartController>()
                                                  .isApplyWallet) {
                                                Get.find<CartController>()
                                                    .applyWalletBalance(false);
                                              }
                                              if (userId != '') {
                                                var data = await Get.find<
                                                        CartController>()
                                                    .getWalletBalanceOfCustomer(
                                                        '$userId');
                                                if (data != {} &&
                                                    data.containsKey(
                                                        'balance')) {
                                                  availableLoyaltyPoint =
                                                      double.parse(
                                                          '${data['loyalty_points'] ?? 0}');
                                                  walletBalance = double.parse(
                                                      '${data['balance'] ?? 0}');
                                                }
                                              }
                                            }
                                            locationController.update();
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(3),
                                            height: 18,
                                            width: 18,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color:
                                                        selectedAddressIndex == i
                                                            ? ColorTheme
                                                                .appColor
                                                            : Colors.black)),
                                            child: Container(
                                              height: 18,
                                              width: 18,
                                              decoration: BoxDecoration(
                                                color: selectedAddressIndex == i
                                                    ? ColorTheme.appColor
                                                    : Colors.transparent,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () async {
                                              selectedAddressIndex = i;
                                              // selectedAddress =
                                              //     locationController
                                              //         .addressList[i];
                                              // selectedPhoneController.text =
                                              //     Get.find<LocationController>()
                                              //         .addressList[i]
                                              //         .contactPersonNumber!;

                                              // selectAddressType =
                                              //     Get.find<LocationController>()
                                              //             .addressList[i]
                                              //             .addressType ??
                                              //         '';

// NEW:
                                              final addr =
                                                  Get.find<LocationController>()
                                                      .crmAddressList[i];
                                              selectedAddress = AddressModel(
                                                id: addr.id,
                                                addressType: addr.addressType,
                                                contactPersonName:
                                                    addr.contactPersonName,
                                                contactPersonNumber:
                                                    addr.contactPersonNumber,
                                                address: addr.address,
                                                house: addr.house,
                                                floor: addr.floor,
                                                road: addr.road,
                                                pincode: addr.pincode,
                                                dialCode:
                                                    addr.dialCode ?? '+91',
                                                zoneId: addr.zoneId,
                                                latitude: addr.safeLatitude
                                                    ?.toString(),
                                                longitude: addr.safeLongitude
                                                    ?.toString(),
                                                userId: userId,
                                              );
                                              selectedPhoneController.text =
                                                  addr.contactPersonNumber ??
                                                      '';
                                              selectAddressType =
                                                  addr.addressType ?? '';

                                              Get.back();
                                              if (Get.find<CartController>()
                                                      .cartList
                                                      .isNotEmpty &&
                                                  selectedAddress!.latitude !=
                                                      '' &&
                                                  selectedAddress?.longitude !=
                                                      null &&
                                                  selectedAddress?.latitude !=
                                                      null) {
                                                await Get.find<
                                                        LocationController>()
                                                    .getDeliveryCharges(
                                                        addLat: double.parse(
                                                            selectedAddress
                                                                    ?.latitude ??
                                                                '0'),
                                                        addLong: double.parse(
                                                            selectedAddress
                                                                    ?.longitude ??
                                                                '0'),
                                                        restId: Get.find<
                                                                AuthController>()
                                                            .profileModel!
                                                            .restaurants!
                                                            .first
                                                            .id
                                                            .toString());
                                                if (Get.find<
                                                            LocationController>()
                                                        .getDeliveryChargesResponse!
                                                        .shippingCharge !=
                                                    0) {
                                                  deliveryCharge = Get.find<
                                                          LocationController>()
                                                      .getDeliveryChargesResponse!
                                                      .shippingCharge!;
                                                  selectedDeliveryCharge.text =
                                                      deliveryCharge.toString();
                                                }
                                              }
                                              locationController.update();
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 12, right: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Name : ${locationController.crmAddressList[i].contactPersonName ?? ''}',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 13,
                                                            color: ColorTheme
                                                                .hintText),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    'Phone : ${locationController.crmAddressList[i].dialCode ?? ''} ${locationController.crmAddressList[i].contactPersonNumber ?? ''}',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 13,
                                                            color: ColorTheme
                                                                .hintText),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    'House no / Floor no : ${locationController.crmAddressList[i].house ?? ''}',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 13,
                                                            color: ColorTheme
                                                                .hintText),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    'Address : ${locationController.crmAddressList[i].address ?? ''}',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 13,
                                                            color: ColorTheme
                                                                .hintText),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    'Pincode : ${locationController.crmAddressList[i].pincode ?? ''}',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 13,
                                                            color: ColorTheme
                                                                .hintText),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Column(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  isEdit = true;
                                                  selectedAddressIndex = i;
                                                  // addAddressController.text =
                                                  //     locationController
                                                  //             .addressList[i]
                                                  //             .address ??
                                                  //         '';
                                                  // latitude = double.parse(
                                                  //     selectAddressType = Get.find<
                                                  //             LocationController>()
                                                  //         .addressList[i]
                                                  //         .latitude!);
                                                  // longitude = double.parse(
                                                  //     selectAddressType = Get.find<
                                                  //             LocationController>()
                                                  //         .addressList[i]
                                                  //         .longitude!);
                                                  // addNameController
                                                  //     .text = locationController
                                                  //         .addressList[i]
                                                  //         .contactPersonName ??
                                                  //     '';
                                                  // addPhoneController
                                                  //     .text = locationController
                                                  //         .addressList[i]
                                                  //         .contactPersonNumber ??
                                                  //     '';
                                                  // addFloorController
                                                  //     .text = Get.find<
                                                  //             LocationController>()
                                                  //         .addressList[i]
                                                  //         .house ??
                                                  //     '';
                                                  // addPincodeController.text =
                                                  //     locationController
                                                  //             .addressList[i]
                                                  //             .pincode ??
                                                  //         '';
                                                  // selectedAddress =
                                                  //     locationController
                                                  //         .addressList[i];
                                                  // selectAddressType = Get.find<
                                                  //             LocationController>()
                                                  //         .addressList[i]
                                                  //         .addressType ??
                                                  //     '';
                                                  final addr =
                                                      locationController
                                                              .crmAddressList[
                                                          i]; // ← CRM source

                                                  addAddressController.text =
                                                      addr.address ?? '';
                                                  latitude =
                                                      addr.safeLatitude ?? 0.0;
                                                  longitude =
                                                      addr.safeLongitude ?? 0.0;
                                                  addNameController.text =
                                                      addr.contactPersonName ??
                                                          '';
                                                  addPhoneController.text =
                                                      addr.contactPersonNumber ??
                                                          '';
                                                  addFloorController.text =
                                                      addr.house ?? '';
                                                  addPincodeController.text =
                                                      addr.pincode ?? '';

                                                  // Map CrmAddress → AddressModel for selectedAddress
                                                  selectedAddress =
                                                      AddressModel(
                                                    id: addr
                                                        .id, // ← use posAddressId, not id
                                                    addressType:
                                                        addr.addressType,
                                                    contactPersonName:
                                                        addr.contactPersonName,
                                                    contactPersonNumber: addr
                                                        .contactPersonNumber,
                                                    address: addr.address,
                                                    house: addr.house,
                                                    floor: addr.floor,
                                                    road: addr.road,
                                                    pincode: addr.pincode,
                                                    dialCode:
                                                        addr.dialCode ?? '91',
                                                    zoneId: addr.zoneId,
                                                    latitude: addr.safeLatitude
                                                        ?.toString(),
                                                    longitude: addr
                                                        .safeLongitude
                                                        ?.toString(),
                                                    userId: userId,
                                                  );

                                                  selectAddressType =
                                                      addr.addressType ?? '';
                                                  setState(() {});
                                                },
                                                child: Icon(
                                                  Icons.edit,
                                                  size: 30,
                                                  color: ColorTheme.appColor,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15),
                                                child: InkWell(
                                                  onTap: () async {
                                                    // ResponseModel
                                                    //     responseModel =
                                                    // await Get.find<
                                                    //         LocationController>()
                                                    //     .deleteAddress(
                                                    //         locationController
                                                    //             .addressList[
                                                    //                 i]
                                                    //             .id!,
                                                    //         i);
                                                    final crmAddress =
                                                        locationController
                                                            .crmAddressList[i];

                                                    print(
                                                        '========> ${locationController.crmAddressList[i]}');

                                                    final addressId =
                                                        crmAddress.id ?? '';
                                                    print(
                                                        '========> ${crmAddress.id ?? ''}'); // ← "addr_90406974bdfd"
                                                    final customerId =
                                                        userId; // ← from TypeAheadField selection
                                                    print(
                                                        '========> ${userId}');
                                                    if (customerId.isEmpty ||
                                                        addressId.isEmpty) {
                                                      showErrorToast(
                                                          'Invalid customer or address');
                                                      return;
                                                    }

                                                    ResponseModel
                                                        responseModel =
                                                        await Get.find<
                                                                LocationController>()
                                                            .deleteCrmAddress(
                                                                customerId,
                                                                addressId,
                                                                i);

                                                    if (responseModel
                                                        .isSuccess) {
                                                      // setState(() {});
                                                      selectedAddress = null;
                                                      showErrorToast(
                                                          responseModel.message,
                                                          isError: false);
                                                    }
                                                  },
                                                  child: Icon(
                                                    Icons.delete_outline,
                                                    size: 30,
                                                    color: ColorTheme.appColor,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          ),
                    const SizedBox(height: 20),
                  ],
                );
        }),
      );
    }),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        ignoreSafeArea: false);
  }

  void addAddressDialog() {
    bool isTapButton = false;
    Get.bottomSheet(StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.only(
              left: 25,
              right: 25,
              top: 25,
              bottom: Dimensions.PADDING_SIZE_DEFAULT),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
              color: Colors.white),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child:
                  GetBuilder<LocationController>(builder: (locationController) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add Address',
                            style: poppinsMedium.copyWith(fontSize: 18)),
                        InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: Icon(Icons.close,
                                size: 26, color: ColorTheme.appColor))
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              child: Radio(
                                value: 1,
                                groupValue: _radioSelected,
                                activeColor: ColorTheme.appColor,
                                onChanged: (value) {
                                  _radioSelected = value as int;
                                  // _radioVal = 'Check In';
                                  // print(_radioVal);
                                  setState(() {});
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: InkWell(
                                  onTap: () {
                                    _radioSelected = 1;
                                    setState(() {});
                                  },
                                  child: const Text("Home")),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              child: Radio(
                                value: 2,
                                groupValue: _radioSelected,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (value) {
                                  _radioSelected = value as int;
                                  // _radioVal = 'Check Out';
                                  // print(_radioVal);
                                  setState(() {});
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: InkWell(
                                  onTap: () {
                                    _radioSelected = 2;
                                    setState(() {});
                                  },
                                  child: const Text("Work")),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              child: Radio(
                                value: 3,
                                groupValue: _radioSelected,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (value) {
                                  _radioSelected = value as int;
                                  // _radioVal = 'Check Out';
                                  // print(_radioVal);
                                  setState(() {});
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: InkWell(
                                  onTap: () {
                                    _radioSelected = 3;
                                    setState(() {});
                                  },
                                  child: const Text("Other")),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: MyTextField(
                        showBorder: true,
                        hintText: 'Contact Person Name'.tr,
                        inputType: TextInputType.name,
                        controller: addNameController,
                        capitalization: TextCapitalization.words,
                        onChanged: (String v) {
                          locationController.update();
                        },
                      ),
                    ),

                    if (isTapButton && addNameController.text.isEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'Name required'.tr,
                            style: poppinsRegular.copyWith(
                                color: Colors.red, fontSize: 10),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorTheme.borderGrey),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(children: [
                          CountryCodePicker(
                            onChanged: (CountryCode _countryCode) {
                              countryCode = _countryCode;
                            },
                            initialSelection: 'IN',
                            // enabled: false,
                            showDropDownButton: true,
                            padding: EdgeInsets.zero,
                            showFlagMain: false,
                            flagWidth: 20,
                            dialogBackgroundColor: Theme.of(context).cardColor,
                            textStyle: poppinsMedium.copyWith(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: 5),
                              height: 40,
                              child: TextField(
                                onChanged: (String v) {
                                  locationController.update();
                                },
                                controller: addPhoneController,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Allow only digits
                                ],
                                keyboardType: TextInputType.numberWithOptions(
                                    signed: true),
                                textAlignVertical: TextAlignVertical.center,
                                style: poppinsMedium.copyWith(fontSize: 13),
                                cursorColor: ColorTheme.appColor,
                                autofocus: false,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: 'Contact Person Number',
                                  fillColor: Colors.white,
                                  hintStyle: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                  filled: true,
                                ),
                              ),
                            ),
                          )
                        ]),
                      ),
                    ),
                    if (isTapButton && addPhoneController.text.isEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'Phone required'.tr,
                            style: poppinsRegular.copyWith(
                                color: Colors.red, fontSize: 10),
                          ),
                        ),
                      ),
                    if (isTapButton &&
                        addPhoneController.text.isNotEmpty &&
                        (addPhoneController.text.length < 8 ||
                            addPhoneController.text.length > 12))
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'enter_a_valid_phone_number'.tr,
                            style: poppinsRegular.copyWith(
                                color: Colors.red, fontSize: 10),
                          ),
                        ),
                      ),

                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 10),
                    //   child: MyTextField(
                    //     showBorder: true,
                    //     hintText: 'Contact Person Number (Ex: +911234567890)',
                    //     inputType: TextInputType.phone,
                    //     // focusNode: _numberNode,
                    //     // nextFocus: _streetNode,
                    //     controller: addPhoneController,
                    //   ),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 10),
                    //   child: MyTextField(
                    //     showBorder: true,
                    //     controller: addAddressController,
                    //     hintText: 'Delivery Address'.tr,
                    //     inputType: TextInputType.streetAddress,
                    //     // focusNode: _addressNode,
                    //     // nextFocus: _nameNode,
                    //     // controller: _addressController,
                    //     // onChanged: (text) =>
                    //     //     locationController.setPlaceMark(text),
                    //   ),
                    // ),

                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 20,
                              child: Radio(
                                value: 1,
                                groupValue: manuallyAddressSelectRadio,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (value) {
                                  manuallyAddressSelectRadio = value as int;
                                  // _radioVal = 'Check Out';
                                  // print(_radioVal);
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  border:
                                      Border.all(color: ColorTheme.borderGrey)),
                              child: TypeAheadField(
                                textFieldConfiguration: TextFieldConfiguration(
                                    controller: addAddressController,
                                    textInputAction: TextInputAction.search,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    keyboardType: TextInputType.streetAddress,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(bottom: 0, left: 13),
                                      hintText:
                                          'Search for area, street name...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7),
                                        borderSide: const BorderSide(
                                            style: BorderStyle.none, width: 0),
                                      ),
                                      hintStyle: poppinsMedium.copyWith(
                                          color: ColorTheme.hintText),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13, color: Colors.black)),
                                suggestionsCallback: (pattern) async {
                                  // locationController.update();

                                  return await Get.find<LocationController>()
                                      .searchLocation(context, pattern);
                                },
                                itemBuilder:
                                    (context, PredictionModel suggestion) {
                                  return Padding(
                                    padding: const EdgeInsets.all(
                                        Dimensions.PADDING_SIZE_SMALL),
                                    child: Row(children: [
                                      const Icon(Icons.location_on),
                                      Expanded(
                                        child: Text(
                                          suggestion.description ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ]),
                                  );
                                },
                                onSuggestionSelected:
                                    (PredictionModel suggestion) async {
                                  addAddressController.text =
                                      suggestion.description ?? '';
                                  locationController.update();
                                  SearchAddressDetailModel? searchData =
                                      await locationController
                                          .getSearchAddressDetail(
                                              suggestion.placeId!);
                                  addPincodeController.text =
                                      searchData?.postalCode ?? "";
                                  latitude = latitude = searchData
                                          ?.result?.geometry?.location?.lat ??
                                      0.0;
                                  longitude = searchData
                                          ?.result?.geometry?.location?.lng ??
                                      0.0;
                                  // locationController.update();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isTapButton &&
                        (addAddressController.text.isEmpty &&
                            manuallyAddressSelectRadio == 1))
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'Address required'.tr,
                            style: poppinsRegular.copyWith(
                                color: Colors.red, fontSize: 10),
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 20,
                              child: Radio(
                                value: 2,
                                groupValue: manuallyAddressSelectRadio,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (value) {
                                  manuallyAddressSelectRadio = value as int;
                                  // _radioVal = 'Check Out';
                                  // print(_radioVal);
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: MyTextField(
                              showBorder: true,
                              hintText: 'Manually add address',
                              inputType: TextInputType.name,
                              controller: manuallyAddressController,
                              capitalization: TextCapitalization.words,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isTapButton &&
                        (manuallyAddressController.text.isEmpty &&
                            manuallyAddressSelectRadio == 2))
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'Address required'.tr,
                            style: poppinsRegular.copyWith(
                                color: Colors.red, fontSize: 10),
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: MyTextField(
                        showBorder: true,
                        hintText: 'House No./Flat No.',
                        inputType: TextInputType.name,
                        controller: addFloorController,
                        capitalization: TextCapitalization.words,
                      ),
                    ),
                    // const SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: MyTextField(
                        showBorder: true,
                        hintText: 'Pincode.',
                        inputType:
                            TextInputType.numberWithOptions(signed: true),
                        controller: addPincodeController,
                        capitalization: TextCapitalization.words,
                      ),
                    ),
                    //abhishek sir ne ye manaual address pe pincode not required karaya hai
                    if (isTapButton &&
                        addPincodeController.text.isEmpty &&
                        manuallyAddressSelectRadio == 1)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'Pincode required'.tr,
                            style: poppinsRegular.copyWith(
                                color: Colors.red, fontSize: 10),
                          ),
                        ),
                      ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 10),
                    //   child: MyTextField(
                    //     showBorder: true,
                    //     hintText: 'Pincode'.tr,
                    //     inputType: TextInputType.phone,
                    //     // focusNode: _numberNode,
                    //     // nextFocus: _streetNode,
                    //     controller: addPincodeController,
                    //   ),
                    // ),
                    // const SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                    // Date of Birth Field
                    // Container(
                    //   margin: EdgeInsets.only(top: 15),
                    //   height: 40,
                    //   child: TextField(
                    //     controller: _dobController,
                    //     readOnly: true,
                    //     autofocus: false,
                    //     decoration: InputDecoration(
                    //       hintText: 'Date of Birth',
                    //       contentPadding:
                    //           EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                    //       enabledBorder: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(7),
                    //         borderSide:
                    //             BorderSide(color: ColorTheme.borderGrey),
                    //       ),
                    //       focusedBorder: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(7),
                    //         borderSide:
                    //             BorderSide(color: ColorTheme.borderGrey),
                    //       ),
                    //       disabledBorder: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(7),
                    //         borderSide:
                    //             BorderSide(color: ColorTheme.borderGrey),
                    //       ),
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(7),
                    //         borderSide:
                    //             BorderSide(color: ColorTheme.borderGrey),
                    //       ),
                    //       hintStyle: poppinsMedium.copyWith(
                    //           fontSize: 13, color: ColorTheme.hintText),
                    //       filled: true,
                    //       fillColor: Colors.white,
                    //       suffixIcon: Icon(
                    //         Icons.calendar_today,
                    //         color: ColorTheme.grey1,
                    //         size: 18,
                    //       ),
                    //     ),
                    //     style: poppinsMedium.copyWith(
                    //       color: Colors.black,
                    //       fontSize: 13,
                    //     ),
                    //     onTap: () async {
                    //       DateTime? pickedDate = await showDatePicker(
                    //         context: context,
                    //         initialDate: DateTime.now(),
                    //         firstDate: DateTime(1900),
                    //         lastDate: DateTime.now(),
                    //         builder: (context, child) {
                    //           return Theme(
                    //             data: Theme.of(context).copyWith(
                    //               colorScheme: ColorScheme.light(
                    //                 primary: ColorTheme.appColor,
                    //                 onPrimary: Colors.white,
                    //                 onSurface: Colors.black,
                    //               ),
                    //             ),
                    //             child: child!,
                    //           );
                    //         },
                    //       );
                    //       if (pickedDate != null) {
                    //         String formattedDate =
                    //             "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    //         _dobController.text = formattedDate;
                    //       }
                    //     },
                    //   ),
                    // ),

                    // // Date of Anniversary Field
                    // Container(
                    //   margin: EdgeInsets.only(top: 15),
                    //   height: 40,
                    //   child: TextField(
                    //     controller: _anniversaryController,
                    //     readOnly: true,
                    //     autofocus: false,
                    //     decoration: InputDecoration(
                    //       hintText: 'Date of Anniversary',
                    //       contentPadding:
                    //           EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                    //       enabledBorder: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(7),
                    //         borderSide:
                    //             BorderSide(color: ColorTheme.borderGrey),
                    //       ),
                    //       focusedBorder: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(7),
                    //         borderSide:
                    //             BorderSide(color: ColorTheme.borderGrey),
                    //       ),
                    //       disabledBorder: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(7),
                    //         borderSide:
                    //             BorderSide(color: ColorTheme.borderGrey),
                    //       ),
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(7),
                    //         borderSide:
                    //             BorderSide(color: ColorTheme.borderGrey),
                    //       ),
                    //       hintStyle: poppinsMedium.copyWith(
                    //           fontSize: 13, color: ColorTheme.hintText),
                    //       filled: true,
                    //       fillColor: Colors.white,
                    //       suffixIcon: Icon(
                    //         Icons.calendar_today,
                    //         color: ColorTheme.grey1,
                    //         size: 18,
                    //       ),
                    //     ),
                    //     style: poppinsMedium.copyWith(
                    //       color: Colors.black,
                    //       fontSize: 13,
                    //     ),
                    //     onTap: () async {
                    //       DateTime? pickedDate = await showDatePicker(
                    //         context: context,
                    //         initialDate: DateTime.now(),
                    //         firstDate: DateTime(1900),
                    //         lastDate: DateTime(2100),
                    //         builder: (context, child) {
                    //           return Theme(
                    //             data: Theme.of(context).copyWith(
                    //               colorScheme: ColorScheme.light(
                    //                 primary: ColorTheme.appColor,
                    //                 onPrimary: Colors.white,
                    //                 onSurface: Colors.black,
                    //               ),
                    //             ),
                    //             child: child!,
                    //           );
                    //         },
                    //       );
                    //       if (pickedDate != null) {
                    //         String formattedDate =
                    //             "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    //         _anniversaryController.text = formattedDate;
                    //       }
                    //     },
                    //   ),
                    // ),

                    // // Dropdown Field
                    // GetBuilder<CustomerManagementController>(
                    //   builder: (customerController) {
                    //     // Filter active designations (status == 1)
                    //     final activeDesignations =
                    //         (customerController.customerDesignationList)
                    //             .where((designation) =>
                    //                 (designation['status'] as int? ?? 1) == 1)
                    //             .toList();

                    //     return StatefulBuilder(
                    //       builder: (context, setDropdownState) {
                    //         return Container(
                    //           margin: EdgeInsets.only(top: 15),
                    //           height: 40,
                    //           decoration: BoxDecoration(
                    //             color: Colors.white,
                    //             borderRadius: BorderRadius.circular(7),
                    //             border:
                    //                 Border.all(color: ColorTheme.borderGrey),
                    //           ),
                    //           padding: EdgeInsets.symmetric(horizontal: 15),
                    //           child: (customerController
                    //                   .isCustomerDesignationLoading.value)
                    //               ? Center(
                    //                   child: SizedBox(
                    //                     width: 20,
                    //                     height: 20,
                    //                   ),
                    //                 )
                    //               : DropdownButtonHideUnderline(
                    //                   child: DropdownButton<String>(
                    //                     value:
                    //                         (_selectedDropdownOption == null ||
                    //                                 _selectedDropdownOption!
                    //                                     .isEmpty)
                    //                             ? null
                    //                             : _selectedDropdownOption,
                    //                     hint: Text(
                    //                       'Select', //Select Designation
                    //                       style: poppinsMedium.copyWith(
                    //                         fontSize: 13,
                    //                         color: ColorTheme.hintText,
                    //                       ),
                    //                     ),
                    //                     isExpanded: true,
                    //                     icon: Icon(
                    //                       Icons.keyboard_arrow_down,
                    //                       color: ColorTheme.grey1,
                    //                     ),
                    //                     style: poppinsMedium.copyWith(
                    //                       color: Colors.black,
                    //                       fontSize: 13,
                    //                     ),
                    //                     items: activeDesignations.isEmpty
                    //                         ? [
                    //                             DropdownMenuItem(
                    //                               value: null,
                    //                               enabled: false,
                    //                               child: Text(
                    //                                 'No designation available',
                    //                                 style:
                    //                                     poppinsMedium.copyWith(
                    //                                   fontSize: 13,
                    //                                   color:
                    //                                       ColorTheme.hintText,
                    //                                 ),
                    //                               ),
                    //                             ),
                    //                           ]
                    //                         : activeDesignations
                    //                             .map<DropdownMenuItem<String>>(
                    //                             (designation) {
                    //                               final designationName =
                    //                                   designation['designation']
                    //                                           as String? ??
                    //                                       '';
                    //                               return DropdownMenuItem(
                    //                                 value: designationName,
                    //                                 child: Text(
                    //                                   designationName,
                    //                                   style: poppinsMedium
                    //                                       .copyWith(
                    //                                     fontSize: 13,
                    //                                     color: Colors.black,
                    //                                   ),
                    //                                 ),
                    //                               );
                    //                             },
                    //                           ).toList(),
                    //                     onChanged: activeDesignations.isEmpty
                    //                         ? null
                    //                         : (value) {
                    //                             setDropdownState(() {
                    //                               _selectedDropdownOption =
                    //                                   value;
                    //                             });
                    //                           },
                    //                   ),
                    //                 ),
                    //         );
                    //       },
                    //     );
                    //   },
                    // ),

                    Get.find<LoadingController>().isLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Center(child: CircularProgressIndicator()))
                        : Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: InkWell(
                                onTap: Get.find<LoadingController>().isLoading
                                    ? null
                                    : () async {
                                        isTapButton = true;
                                        locationController.update();
                                        if (addNameController.text.isEmpty) {
                                          // showCustomSnackBar('Name required');
                                        } else if (addPhoneController
                                            .text.isEmpty) {
                                          // showCustomSnackBar('Phone required');
                                        } else if (addAddressController
                                                .text.isEmpty &&
                                            manuallyAddressSelectRadio == 1) {
                                          // showCustomSnackBar('Address required');
                                        } else if (manuallyAddressController
                                                .text.isEmpty &&
                                            manuallyAddressSelectRadio == 2) {
                                          // showCustomSnackBar('Address required');
                                        } else if (addPincodeController
                                                .text.isEmpty &&
                                            manuallyAddressSelectRadio == 1) {
                                          // showCustomSnackBar('Pincode required');
                                        } else {
                                          if (addPhoneController.text.length <
                                                  8 ||
                                              addPhoneController.text.length >
                                                  12) {
                                            // showCustomSnackBar(
                                            //     'Enter valid phone number');
                                          } else {
                                            AddressModel addressModel =
                                                AddressModel(
                                              id: null,
                                              dialCode: countryCode?.dialCode ??
                                                  '+91',
                                              // userId: Get.find<CartController>()
                                              //             .selectedCustomer ==
                                              //         null
                                              //     ? null
                                              //     : int.parse(
                                              //         Get.find<CartController>()
                                              //             .selectedCustomer!
                                              //             .id),
                                              userId: Get.find<CartController>()
                                                          .selectedCustomer ==
                                                      null
                                                  ? null
                                                  : Get.find<CartController>()
                                                      .selectedCustomer!
                                                      .id,
                                              pincode: addPincodeController
                                                      .text.isEmpty
                                                  ? ''
                                                  : addPincodeController.text,
                                              addressType: _radioSelected == 1
                                                  ? 'Home'
                                                  : _radioSelected == 2
                                                      ? 'Work'
                                                      : 'Other',
                                              contactPersonName:
                                                  addNameController.text.isEmpty
                                                      ? ''
                                                      : addNameController.text,
                                              contactPersonNumber:
                                                  addPhoneController
                                                          .text.isEmpty
                                                      ? ''
                                                      : addPhoneController.text,
                                              address:
                                                  manuallyAddressSelectRadio ==
                                                          2
                                                      ? manuallyAddressController
                                                              .text ??
                                                          ''
                                                      : addAddressController
                                                              .text ??
                                                          '',
                                              latitude: latitude == 0
                                                  ? ''
                                                  : latitude.toString(),
                                              longitude: longitude == 0
                                                  ? ''
                                                  : longitude.toString(),
                                              zoneId: 3,
                                              road: '',
                                              house:
                                                  addFloorController.text ?? '',
                                              floor: '',
                                              dob: _dobController.text.isEmpty
                                                  ? ''
                                                  : _dobController.text,
                                              doa: _anniversaryController
                                                      .text.isEmpty
                                                  ? ''
                                                  : _anniversaryController.text,
                                              membershipId:
                                                  _selectedDropdownOption !=
                                                          null
                                                      ? _selectedDropdownOption
                                                      : '',
                                            );
                                            Get.find<LoadingController>()
                                                .startLoading(true);

                                            final crmId =
                                                await Get.find<CartController>()
                                                    .lookupAndSyncCrmCustomer(
                                              phone: addPhoneController.text,
                                              name: addNameController.text,
                                              backToPrevious: false,
                                            );

                                            Get.find<LoadingController>()
                                                .startLoading(false);

                                            if (crmId == null) {
                                              showCustomSnackBar(
                                                  'Could not sync customer. Try again.');
                                              return;
                                            }

                                            userId = crmId;

                                            // ← only ONE call now

                                            final body = {
                                              'address':
                                                  manuallyAddressSelectRadio ==
                                                          2
                                                      ? manuallyAddressController
                                                              .text ??
                                                          ''
                                                      : addAddressController
                                                              .text ??
                                                          '',
                                              'address_type':
                                                  _radioSelected == 1
                                                      ? 'Home'
                                                      : _radioSelected == 2
                                                          ? 'Work'
                                                          : 'Other',
                                              'house':
                                                  addFloorController.text ?? '',
                                              'floor': '',
                                              'road': '',
                                              'city': '',
                                              'state': '',
                                              'pincode': addPincodeController
                                                      .text.isEmpty
                                                  ? ''
                                                  : addPincodeController.text,
                                              'latitude': latitude == 0
                                                  ? ''
                                                  : latitude.toString(),
                                              'longitude': longitude == 0
                                                  ? ''
                                                  : longitude.toString(),
                                              'contact_person_name':
                                                  addNameController.text.isEmpty
                                                      ? ''
                                                      : addNameController.text,
                                              'contact_person_number':
                                                  addPhoneController
                                                          .text.isEmpty
                                                      ? ''
                                                      : addPhoneController.text,
                                              'delivery_instructions': '',
                                              'is_default': false,
                                            };

                                            final ResponseModel responseModel =
                                                await Get.find<
                                                        LocationController>()
                                                    .addCrmAddress(crmId, body);

                                            // ResponseModel responseModel =
                                            //     await Get.find<LocationController>()
                                            //         .addAddress(
                                            //             addressModel, false, 3);

                                            if (responseModel.isSuccess) {
                                              if (Get.find<LocationController>()
                                                  .crmAddressList
                                                  .isNotEmpty) {
                                                Get.find<LocationController>()
                                                    .getCrmAddressByPhone(
                                                        selectedPhoneController
                                                            .text);
                                                // selectedAddress =
                                                //     Get.find<LocationController>()
                                                //         .addressList
                                                //         .first;
                                                selectedAddress = AddressModel(
                                                  id: null,
                                                  contactPersonName:
                                                      addNameController.text,
                                                  contactPersonNumber:
                                                      addPhoneController.text,
                                                  address:
                                                      manuallyAddressSelectRadio ==
                                                              2
                                                          ? manuallyAddressController
                                                              .text
                                                          : addAddressController
                                                              .text,
                                                  house:
                                                      addFloorController.text,
                                                  pincode:
                                                      addPincodeController.text,
                                                  dialCode:
                                                      countryCode?.dialCode ??
                                                          '+91',
                                                  latitude: latitude != 0
                                                      ? latitude.toString()
                                                      : '',
                                                  longitude: longitude != 0
                                                      ? longitude.toString()
                                                      : '',
                                                  userId: userId,
                                                  zoneId: 3,
                                                  road: '',
                                                  floor: '',
                                                );

                                                print(
                                                    '.............${selectedAddress?.latitude}.......${selectedAddress?.longitude}...........');
                                                if (Get.find<CartController>()
                                                        .cartList
                                                        .isNotEmpty &&
                                                    selectedAddress?.latitude !=
                                                        '' &&
                                                    selectedAddress
                                                            ?.longitude !=
                                                        null &&
                                                    selectedAddress?.latitude !=
                                                        null) {
                                                  await Get.find<
                                                          LocationController>()
                                                      .getDeliveryCharges(
                                                          addLat: double.parse(
                                                              selectedAddress
                                                                      ?.latitude ??
                                                                  '0'),
                                                          addLong: double.parse(
                                                              selectedAddress
                                                                      ?.longitude ??
                                                                  '0'),
                                                          restId: Get.find<
                                                                  AuthController>()
                                                              .profileModel!
                                                              .restaurants!
                                                              .first
                                                              .id
                                                              .toString());
                                                  if (Get.find<
                                                              LocationController>()
                                                          .getDeliveryChargesResponse
                                                          ?.shippingCharge !=
                                                      0) {
                                                    deliveryCharge = Get.find<
                                                            LocationController>()
                                                        .getDeliveryChargesResponse!
                                                        .shippingCharge!;
                                                    selectedDeliveryCharge
                                                            .text =
                                                        deliveryCharge
                                                            .toString();
                                                  }
                                                }
                                                selectedPhoneController.text =
                                                    selectedAddress!
                                                        .contactPersonNumber!;

                                                Get.find<LocationController>()
                                                    .update();
                                              }
                                              Get.back();
                                              showErrorToast(
                                                  responseModel.message,
                                                  isError: false);
                                            }
                                          }
                                        }
                                      },
                                child: Container(
                                  height: 35,
                                  width: 110,
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.transparent),
                                      color: ColorTheme.appColor,
                                      // border:
                                      //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Center(
                                    child: Text(
                                      'submit'.tr,
                                      style: poppinsMedium.copyWith(
                                          fontSize: 13, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )

                    // CustomButton(
                    //     buttonText: 'Submit',
                    //     onPressed: () async {
                    //       if (addNameController.text.isEmpty) {
                    //         showCustomSnackBar('Name required');
                    //       } else if (addPhoneController.text.isEmpty) {
                    //         showCustomSnackBar('Phone required');
                    //       } else if (addAddressController.text.isEmpty) {
                    //         showCustomSnackBar('Address required');
                    //       } else if (addPincodeController.text.isEmpty) {
                    //         showCustomSnackBar('Pincode required');
                    //       } else {
                    //         if (addPhoneController.text.length < 10) {
                    //           showCustomSnackBar(
                    //               'Enter valid phone number');
                    //         } else {
                    //           AddressModel addressModel = AddressModel(
                    //             id: null,
                    //             userId: Get.find<CartController>()
                    //                         .selectedCustomer ==
                    //                     null
                    //                 ? null
                    //                 : int.parse(Get.find<CartController>()
                    //                     .selectedCustomer
                    //                     .id),
                    //             pincode: addPincodeController.text.isEmpty
                    //                 ? ''
                    //                 : addPincodeController.text,
                    //             addressType: _radioSelected == 1
                    //                 ? 'Home'
                    //                 : _radioSelected == 2
                    //                     ? 'Work'
                    //                     : 'Other',
                    //             contactPersonName:
                    //                 addNameController.text.isEmpty
                    //                     ? ''
                    //                     : addNameController.text,
                    //             contactPersonNumber:
                    //                 addPhoneController.text.isEmpty
                    //                     ? ''
                    //                     : addPhoneController.text,
                    //             address: addAddressController.text.isEmpty
                    //                 ? ''
                    //                 : addAddressController.text,
                    //             latitude: '12.44',
                    //             longitude: '12.44',
                    //             zoneId: 3,
                    //             road: '',
                    //             house: addFloorController?.text ?? '',
                    //             floor: '',
                    //           );
                    //           ResponseModel responseModel =
                    //               await Get.find<LocationController>()
                    //                   .addAddress(addressModel, false, 3);

                    //           if (responseModel != null &&
                    //               responseModel.isSuccess) {
                    //             Get.back();
                    //             showCustomSnackBar(responseModel.message,
                    //                 isError: false);
                    //           }
                    //         }
                    //       }
                    //     },
                    //   )
                  ],
                );
              }),
            ),
          ),
        );
      },
    ),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        ignoreSafeArea: false);
  }

  void callback(bool isSuccess, String message, String orderID,
      String tokenDisplay) async {
    if (isSuccess) {
      // Get.offNamed(RouteHelper.getWaiterDashboardInitialRoute());
      if (Get.find<AuthController>()
              .profileModel!
              .restaurants!
              .first
              .restaurantType ==
          'Restaurant buffet') {
        Get.until((route) =>
            route.settings.name == RouteHelper.getBuffetInitialRoute());
      } else {
        if (MediaQuery.of(context).size.shortestSide > 570 ||
            GetPlatform.isWindows) {
          Get.until((route) =>
              route.settings.name == RouteHelper.getTableViewHomeRoute());
        } else {
          Get.until((route) =>
              route.settings.name == RouteHelper.getTableViewHomeRoute());
          // Get.until((route) =>
          //     route.settings.name ==
          //     RouteHelper.getWaiterDashboardInitialRoute());
        }
      }

      Get.find<CartController>().clearCartList();
    } else {
      _releasePlaceOrderLock();
      showErrorToast(message);
    }
  }

  void prepaidCallback(bool isSuccess, String message, String orderID,
      String tokenDisplay) async {
    if (isSuccess) {
      // 1. INSTANT NAVIGATION: Clear cart and go home immediately (Zero Lag)
      Get.find<CartController>().showLoader(false);
      // 1. Take a snapshot of the current cart BEFORE clearing
      final List<CartModel> cartSnapshot =
          List.from(Get.find<CartController>().cartList);
      Get.find<CartController>().clearCartList();

      if (MediaQuery.of(context).size.shortestSide > 570 ||
          GetPlatform.isWindows) {
        Get.until((route) =>
            route.settings.name == RouteHelper.getTableViewHomeRoute());
      } else {
        Get.until((route) =>
            route.settings.name == RouteHelper.getTableViewHomeRoute());
      }

      // 2. BACKGROUND PRINTING
      if (isAutoBillPrint) {
        Future.microtask(() async {
          // GAP 5: Wait for the printer to be free before claiming the lock.
          // Previously this forcibly set isPrinterBusy=true without any check,
          // which could interrupt an ongoing KOT mid-print.
          int _waitCounter = 0;
          while (
              Get.find<CartController>().isPrinterBusy && _waitCounter < 15) {
            await Future.delayed(const Duration(seconds: 2));
            _waitCounter++;
          }

          // CLAIM THE LOCK (Turn Red Light ON)
          final _traceBill = PrintDebugController.generateTraceId();
          Get.find<CartController>().isPrinterBusy = true;
          PrintDebugLogger.lockClaim(
            traceId: _traceBill,
            flow: PrintFlowTag.bill,
            details: {
              'source':
                  'checkout_order_screen – auto bill (waited $_waitCounter cycles)',
              'orderId': orderID,
            },
          );

          try {
            int numberOfPrint = int.parse(Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .settings!
                    .noOfBillPrint ??
                '1');
            PrintDebugLogger.printStart(
              traceId: _traceBill,
              orderId: orderID?.toString(),
              printType: 'billing',
              currentPrintIndex: 0,
              platform: GetPlatform.isWindows ? 'Windows' : 'Android/iOS',
              printerName:
                  Get.find<AuthController>().profileModel!.wifiBillPrinterName,
              copyCount: numberOfPrint,
              flow: PrintFlowTag.bill,
              isAuto: true,
            );

            if (GetPlatform.isWindows) {
              print('=================/prepaid windows priting ');
              final printers = await Printing.listPrinters();
              for (var element in printers) {
                if (element.isAvailable &&
                    (element.name.toLowerCase() ==
                        Get.find<AuthController>()
                            .profileModel!
                            .wifiBillPrinterName!
                            .toLowerCase())) {
                  for (int i = 0; i < numberOfPrint; i++) {
                    await Printing.directPrintPdf(
                        printer: element,
                        onLayout: (_) => WindowsPrintByteConvert().byteConvert(
                            printType: 'billing',
                            tokenNo: tokenDisplay,
                            subTotalWithoutTax: orderSubTotal +
                                (deliveryCharge ?? 0) +
                                (showServiceChargeValue ?? 0) +
                                (double.tryParse(_addTips.text.trim()) ?? 0) -
                                ((Get.find<CartController>().isApplyLoyalty &&
                                        !crmLoyaltyBelowMin &&
                                        crmLoyaltyDiscount > 0)
                                    ? crmLoyaltyDiscount
                                    : 0) -
                                ((isCouponValidate && crmCouponRupee > 0)
                                    ? crmCouponRupee
                                    : 0),
                            paperRoll: Get.find<AuthController>().profileModel!.billPrinterPaperRoll == 58
                                ? 58
                                : 80,
                            paymentType: Get.find<PosController>().paymentTab,
                            orderId: orderID,
                            date:
                                '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                            waiterName:
                                '${Get.find<AuthController>().selectedEmployee == null ? Get.find<AuthController>().profileModel!.empFname : Get.find<AuthController>().selectedEmployee!.fName}',
                            tablename: 'Billing',
                            custName: _nameController.text.isEmpty
                                ? ''
                                : _nameController.text,
                            custPhone: _phoneController.text.isEmpty
                                ? ''
                                : _phoneController.text,
                            cartList: cartSnapshot ?? [],
                            orderNote: '',
                            orderSubTotal: orderItemTotal,
                            discount: orderDiscount,
                            couponCode:
                                (isCouponValidate) ? crmCouponCode : '',
                            couponDiscount:
                                (isCouponValidate) ? crmCouponRupee : 0,
                            loyaltyUsed: (Get.find<CartController>()
                                        .isApplyLoyalty &&
                                    !crmLoyaltyBelowMin)
                                ? crmLoyaltyDiscount
                                : 0,
                            serviceChargeAmount:
                                Get.find<PosController>().isAddServiceCharge
                                    ? showServiceChargeValue
                                    : 0,
                            roomRemainingPay: 0,
                            roomAdvancePay: 0,
                            roomGst: 0,
                            deliveryCharge: deliveryCharge ?? 0,
                            gstAmount:
                                gstAmount + gstServiceChargeTax + tipTaxAmount,
                            vatAmount: vatAmount,
                            deliveryCustName:
                                selectedAddress?.contactPersonName ?? '',
                            deliveryAddressType:
                                selectedAddress?.addressType ?? '',
                            deliveryCustAddress: selectedAddress?.address ?? '',
                            deliveryCustPhone:
                                selectedAddress?.contactPersonNumber ?? '',
                            deliveryCustPincode: selectedAddress?.pincode ?? '',
                            grandTotal:
                                Get.find<PosController>().collectItemPrice,
                            tips: _addTips.text.isEmpty
                                ? 0
                                : double.parse(_addTips.text),
                            orderType: Get.find<TableController>().selectedTable ==
                                    null
                                ? 'dine_in'
                                : (Get.find<TableController>().selectedTable?.id == 0 &&
                                        Get.find<TableController>().selectedTable?.tableNo ==
                                            'Delivery')
                                    ? 'delivery'
                                    : (Get.find<TableController>().selectedTable?.id == 0 &&
                                            Get.find<TableController>()
                                                    .selectedTable
                                                    ?.tableNo ==
                                                'Take Away')
                                        ? 'take_away'
                                        : 'dine_in'));
                    await Future.delayed(Duration(seconds: 2));
                  }
                  break;
                }
              }
            } else if (Platform.isAndroid) {
              print('=================/prepaid andorid priting ');
              _kdsPrintEscPos(await PrintByteConvert().byteConvert(
                  paymentType: Get.find<PosController>().paymentTab,
                  subTotalWithoutTax: orderSubTotal +
                      (deliveryCharge ?? 0) +
                      (showServiceChargeValue ?? 0) +
                      (double.tryParse(_addTips.text.trim()) ?? 0) -
                      ((Get.find<CartController>().isApplyLoyalty &&
                              !crmLoyaltyBelowMin &&
                              crmLoyaltyDiscount > 0)
                          ? crmLoyaltyDiscount
                          : 0) -
                      ((isCouponValidate && crmCouponRupee > 0)
                          ? crmCouponRupee
                          : 0),
                  printType: 'billing',
                  paperRoll: Get.find<AuthController>()
                              .profileModel!
                              .billPrinterPaperRoll ==
                          58
                      ? 58
                      : 80,
                  orderId: orderID,
                  date:
                      '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                  waiterName:
                      '${Get.find<AuthController>().selectedEmployee == null ? Get.find<AuthController>().profileModel!.empFname : Get.find<AuthController>().selectedEmployee!.fName}',
                  tablename: 'Billing',
                  custName:
                      _nameController.text.isEmpty ? '' : _nameController.text,
                  custPhone: _phoneController.text.isEmpty
                      ? ''
                      : _phoneController.text,
                  cartList: cartSnapshot ?? [],
                  orderNote: '',
                  orderSubTotal: orderItemTotal,
                  discount: orderDiscount,
                  couponCode: (isCouponValidate) ? crmCouponCode : '',
                  couponDiscount: (isCouponValidate) ? crmCouponRupee : 0,
                  loyaltyUsed: (Get.find<CartController>().isApplyLoyalty &&
                          !crmLoyaltyBelowMin)
                      ? crmLoyaltyDiscount
                      : 0,
                  serviceChargeAmount:
                      Get.find<PosController>().isAddServiceCharge
                          ? showServiceChargeValue
                          : 0,
                  roomRemainingPay: 0,
                  roomAdvancePay: 0,
                  deliveryCharge: deliveryCharge ?? 0,
                  gstAmount: gstAmount + gstServiceChargeTax + tipTaxAmount,
                  vatAmount: vatAmount,
                  grandTotal: Get.find<PosController>().collectItemPrice,
                  tips: _addTips.text.isEmpty ? 0 : double.parse(_addTips.text),
                  deliveryCustName: selectedAddress?.contactPersonName ?? '',
                  deliveryAddressType: selectedAddress?.addressType ?? '',
                  deliveryCustAddress: selectedAddress?.address ?? '',
                  deliveryCustPhone: selectedAddress?.contactPersonNumber ?? '',
                  deliveryCustPincode: selectedAddress?.pincode ?? '',
                  orderType: Get.find<TableController>().selectedTable == null
                      ? 'dine_in'
                      : (Get.find<TableController>().selectedTable?.id == 0 &&
                              Get.find<TableController>()
                                      .selectedTable
                                      ?.tableNo ==
                                  'Delivery')
                          ? 'delivery'
                          : (Get.find<TableController>().selectedTable?.id ==
                                      0 &&
                                  Get.find<TableController>()
                                          .selectedTable
                                          ?.tableNo ==
                                      'Take Away')
                              ? 'take_away'
                              : 'dine_in'));
            } else if (Platform.isIOS) {
              await _iosPrintEscPos(
                  await PrintByteConvert().byteConvert(
                      paymentType: Get.find<PosController>().paymentTab,
                      printType: 'billing',
                      subTotalWithoutTax: orderSubTotal +
                          (deliveryCharge ?? 0) +
                          (showServiceChargeValue ?? 0) +
                          (double.tryParse(_addTips.text.trim()) ?? 0) -
                          ((Get.find<CartController>().isApplyLoyalty &&
                                  !crmLoyaltyBelowMin &&
                                  crmLoyaltyDiscount > 0)
                              ? crmLoyaltyDiscount
                              : 0) -
                          ((isCouponValidate && crmCouponRupee > 0)
                              ? crmCouponRupee
                              : 0),
                      paperRoll: Get.find<AuthController>()
                                  .profileModel!
                                  .billPrinterPaperRoll ==
                              58
                          ? 58
                          : 80,
                      orderId: orderID,
                      date:
                          '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                      waiterName:
                          '${Get.find<AuthController>().selectedEmployee == null ? Get.find<AuthController>().profileModel!.empFname : Get.find<AuthController>().selectedEmployee!.fName}',
                      tablename: 'Billing',
                      custName: _nameController.text.isEmpty
                          ? ''
                          : _nameController.text,
                      custPhone: _phoneController.text.isEmpty
                          ? ''
                          : _phoneController.text,
                      cartList: cartSnapshot ?? [],
                      orderNote: '',
                      orderSubTotal: orderItemTotal,
                      discount: orderDiscount,
                      couponCode: (isCouponValidate) ? crmCouponCode : '',
                      couponDiscount: (isCouponValidate) ? crmCouponRupee : 0,
                      loyaltyUsed: (Get.find<CartController>().isApplyLoyalty &&
                              !crmLoyaltyBelowMin)
                          ? crmLoyaltyDiscount
                          : 0,
                      serviceChargeAmount:
                          Get.find<PosController>().isAddServiceCharge
                              ? showServiceChargeValue
                              : 0,
                      roomRemainingPay: 0,
                      roomAdvancePay: 0,
                      deliveryCharge: deliveryCharge ?? 0,
                      gstAmount: gstAmount + gstServiceChargeTax + tipTaxAmount,
                      vatAmount: vatAmount,
                      grandTotal: Get.find<PosController>().collectItemPrice,
                      tips: _addTips.text.isEmpty
                          ? 0
                          : double.parse(_addTips.text),
                      deliveryCustName:
                          selectedAddress?.contactPersonName ?? '',
                      deliveryAddressType: selectedAddress?.addressType ?? '',
                      deliveryCustAddress: selectedAddress?.address ?? '',
                      deliveryCustPhone:
                          selectedAddress?.contactPersonNumber ?? '',
                      deliveryCustPincode: selectedAddress?.pincode ?? '',
                      orderType: Get.find<TableController>().selectedTable ==
                              null
                          ? 'dine_in'
                          : (Get.find<TableController>().selectedTable?.id ==
                                      0 &&
                                  Get.find<TableController>()
                                          .selectedTable
                                          ?.tableNo ==
                                      'Delivery')
                              ? 'delivery'
                              : (Get.find<TableController>()
                                              .selectedTable
                                              ?.id ==
                                          0 &&
                                      Get.find<TableController>()
                                              .selectedTable
                                              ?.tableNo ==
                                          'Take Away')
                                  ? 'take_away'
                                  : 'dine_in'),
                  isBill: true);
            }
          } catch (e) {
            print("Background Print Error: $e");
            PrintDebugLogger.error(
              traceId: _traceBill,
              orderId: orderID?.toString(),
              message: 'Auto bill print failed: $e',
              flow: PrintFlowTag.bill,
              exception: e,
            );
          } finally {
            // RELEASE THE LOCK (Turn Green Light ON)
            PrintDebugLogger.lockRelease(
              traceId: _traceBill,
              orderId: orderID?.toString(),
              flow: PrintFlowTag.bill,
              source: 'checkout_order_screen finally',
            );
            Get.find<CartController>().isPrinterBusy = false;
          }
        });
      }
    } else {
      _releasePlaceOrderLock();
      showErrorToast(message);
    }
  }

  Widget amountDetail(CartController cartController) {
    return Container(
      margin: EdgeInsets.only(top: 15, left: 20, right: 20),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: ColorTheme.productCard,
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text('Item Total',
                    textAlign: TextAlign.right,
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 11)),
                Text(
                    ' :   ' +
                        PriceConverter.convertPrice(orderItemTotal,
                            isHideCurrency: true, asFixed: 2),
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 11)),
              ]),

              if (Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .settings!
                          .isCoupon ==
                      'Yes' &&
                  (widget.editOrder == null))
                Padding(
                  padding: const EdgeInsets.only(right: 0, top: 10),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text('Coupon Code',
                        textAlign: TextAlign.right,
                        style: poppinsMedium.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 11)),
                    Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      width: Get.width * 0.3,
                      height: MediaQuery.of(context).size.shortestSide > 570
                          ? 40
                          : 25,
                      child: TextField(
                        controller: _couponController,
                        autofocus: false,
                        decoration: InputDecoration(
                          // hintText: 'phone'.tr,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                                BorderSide(style: BorderStyle.none, width: 0),
                          ),
                          hintStyle: poppinsMedium.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 11,
                              color: ColorTheme.hintText),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: poppinsMedium.copyWith(
                          color: Colors.black,
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        ),
                        onChanged: (s) async {
                          // _discountController.text = '0';
                          // if (isCouponValidate) {
                          //   couponDiscountType = '';
                          //   usedLoyaltyPoint = 0;
                          //   cartController.applyLoyaltyValue(false);
                          //   discountCalculator();
                          //   if (mounted) {
                          //     setState(() {});
                          //   }
                          // }
                          isCouponValidate = false;
                          crmCouponRupee = 0;
                          crmCouponCode = '';
                          crmCouponTitle = '';
                          crmCouponBenefit = '';
                          if (mounted) setState(() {});
                          discountCalculator();
                        },
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: ColorTheme.borderGrey)),
                    ),
                    InkWell(
                      onTap: () async {
                        // String orderType = (Get.find<TableController>()
                        //                 .selectedTable
                        //                 ?.id ==
                        //             0 &&
                        //         Get.find<TableController>()
                        //                 .selectedTable
                        //                 ?.tableNo ==
                        //             'Delivery')
                        //     ? 'delivery'
                        //     : (Get.find<TableController>().selectedTable?.id ==
                        //                 0 &&
                        //             Get.find<TableController>()
                        //                     .selectedTable
                        //                     ?.tableNo ==
                        //                 'Take Away')
                        //         ? 'takeaway'
                        //         : 'dine in';
                        // var data = await Get.find<LoyaltyController>()
                        //     .checkValidCoupon(_couponController.text,
                        //         orderType, userId, orderItemTotal);
                        // if (data.containsKey('message') &&
                        //     data['message'] == 'Coupon is valid') {
                        //   selectedDiscountType =
                        //       data['discount_type'] == 'percentage'
                        //           ? 'Percent'
                        //           : 'Fixed';
                        //   couponDiscountType = data['discount_type'];
                        //   _discountController.text =
                        //       '${data['discount_value']}';
                        //   usedLoyaltyPoint = 0;
                        //   cartController.applyLoyaltyValue(false);
                        //   isCouponValidate = true;
                        //   discountCalculator();
                        // }
                        if (userId == '') {
                          showErrorToast(
                              'Please select customer for applying coupon');
                        } else if (_couponController.text.isEmpty) {
                          showErrorToast('Please enter coupon code');
                        } else {
                          await _applyCrmCoupon();
                        }
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                        decoration: BoxDecoration(
                            color: isCouponValidate
                                ? Colors.white
                                : ColorTheme.appColor,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: ColorTheme.appColor)),
                        child: Text(isCouponValidate ? 'Applied' : 'Apply',
                            textAlign: TextAlign.right,
                            style: poppinsMedium.copyWith(
                                color: isCouponValidate
                                    ? ColorTheme.appColor
                                    : Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 15
                                        : 11)),
                      ),
                    )
                  ]),
                ),
              if (isCouponValidate)
                Padding(
                  padding: const EdgeInsets.only(right: 15, top: 10),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(
                        // 'Coupon Discount ${(selectedDiscountType == 'Percent') ? '(${_discountController.text}%)' : ''} ',
                        crmCouponTitle.isEmpty
                            ? 'Coupon Discount'
                            : crmCouponTitle,
                        textAlign: TextAlign.right,
                        style: poppinsMedium.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 11)),
                    Text(
                        ' :   ' +
                            PriceConverter.convertPrice(crmCouponRupee,
                                isHideCurrency: true, asFixed: 2),
                        style: poppinsMedium.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 11)),
                  ]),
                ),
              if (isCouponValidate && crmCouponBenefit.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 15, top: 4),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      crmCouponBenefit,
                      style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 13
                                  : 10),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
              if (userId != '' &&
                  !crmLoyaltyHidden &&
                  (Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .settings!
                          .isLoyality ==
                      'Yes'))
                InkWell(
                  onTap: () async {
                    // cartController.applyLoyaltyValue(
                    //     cartController.isApplyLoyalty ? false : true);
                    // if (userId != '' && cartController.isApplyLoyalty) {
                    //   var data = await Get.find<LoyaltyController>()
                    //       .checkValidLoyaltyPoint('$userId',
                    //           Get.find<PosController>().collectItemPrice);
                    //   if (data != {} && data.containsKey('pointsToRedeem')) {
                    //     usedLoyaltyPoint =
                    //         double.parse('${data['pointsToRedeem'] ?? 0}');
                    //     discountCalculator();
                    //   }
                    // } else {
                    //   usedLoyaltyPoint = 0;
                    //   discountCalculator();
                    // }
                    _toggleCrmLoyalty();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 0, top: 6),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Checkbox(
                              value: cartController.isApplyLoyalty,
                              onChanged: (val) async {
                                // cartController.applyLoyaltyValue(
                                //     cartController.isApplyLoyalty ? false : true);
                                // if (userId != '' && cartController.isApplyLoyalty) {
                                //   var data = await Get.find<LoyaltyController>()
                                //       .checkValidLoyaltyPoint('$userId',
                                //           Get.find<PosController>().collectItemPrice);
                                //   if (data != {} &&
                                //       data.containsKey('pointsToRedeem')) {
                                //     usedLoyaltyPoint =
                                //         double.parse('${data['pointsToRedeem'] ?? 0}');
                                //   }
                                //   discountCalculator();
                                // } else {
                                //   usedLoyaltyPoint = 0;
                                //   discountCalculator();
                                // }
                                _toggleCrmLoyalty();
                              }),
                          Text('Apply Loyalty Reimbursement',
                              textAlign: TextAlign.right,
                              style: poppinsMedium.copyWith(
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 15
                                        : 11,
                              )),
                          Text(' :  ${crmLoyaltyDiscount.toStringAsFixed(2)}',
                              style: poppinsMedium.copyWith(
                                  fontSize: MediaQuery.of(context)
                                              .size
                                              .shortestSide >
                                          570
                                      ? 15
                                      : 11)),
                        ]),
                  ),
                ),
              if (!crmLoyaltyHidden &&
                  (crmLoyaltyHint.isNotEmpty ||
                      crmLoyaltyTier.isNotEmpty ||
                      crmAvailablePoints > 0) &&
                  (Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .settings!
                          .isLoyality ==
                      'Yes'))
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDFF6E4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (crmLoyaltyHint.isNotEmpty)
                          Text(
                            crmLoyaltyHint,
                            textAlign: TextAlign.left,
                            style: poppinsMedium.copyWith(
                                color: const Color.fromARGB(255, 125, 18, 18),
                                fontSize: MediaQuery.of(context)
                                            .size
                                            .shortestSide >
                                        570
                                    ? 10
                                    : 7),
                          ),
                        if (crmLoyaltyHint.isEmpty || crmEarnPoints > 0)
                          Text(
                            crmLoyaltyHint.isNotEmpty
                                ? 'You’ll earn $crmEarnPoints pts on this order'
                                : '${crmLoyaltyTier.isEmpty ? '' : '$crmLoyaltyTier · '}${crmAvailablePoints.toStringAsFixed(0)} pts · You’ll earn $crmEarnPoints pts',
                            textAlign: TextAlign.left,
                            style: poppinsMedium.copyWith(
                                fontSize: MediaQuery.of(context)
                                            .size
                                            .shortestSide >
                                        570
                                    ? 11
                                    : 8),
                          ),
                      ],
                    ),
                  ),
                ),
                    ],
                  ),
                ),
              ),
              if (userId != '' &&
                  Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .settings!
                          .isCustomerWallet ==
                      'Yes')
                InkWell(
                  onTap: () async {
                    cartController.applyWalletBalance(
                        cartController.isApplyWallet ? false : true);

                    discountCalculator();
                  },
                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Checkbox(
                        value: cartController.isApplyWallet,
                        onChanged: (val) async {
                          cartController.applyWalletBalance(
                              cartController.isApplyWallet ? false : true);
                          discountCalculator();
                        }),
                    Text('Wallet Balance',
                        textAlign: TextAlign.right,
                        style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        )),
                    Text(' :  ${walletBalance.toStringAsFixed(2)}',
                        style: poppinsMedium.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 11)),
                  ]),
                ),
              if (cartController.isApplyWallet)
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('(Remaining wallet balance',
                      textAlign: TextAlign.right,
                      style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11)),
                  Text(' :  ${(walletBalance - walletUsed).toStringAsFixed(2)})',
                      style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11)),
                ]),
              if (coummunityDiscount != 0)
                Padding(
                  padding: const EdgeInsets.only(right: 15, top: 5),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text('Community Discount'.tr,
                        textAlign: TextAlign.right,
                        style: poppinsMedium.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 11)),
                    Text(
                        ' :   ' +
                            PriceConverter.convertPrice(coummunityDiscount,
                                isHideCurrency: true, asFixed: 2),
                        style: poppinsMedium.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 11)),
                  ]),
                ),

              if ((Get.find<AuthController>()
                              .profileModel!
                              .restaurants!
                              .first
                              .isOrderPaymentType !=
                          'postpaid' &&
                      Get.find<AuthController>()
                              .profileModel!
                              .restaurants!
                              .first
                              .discountType !=
                          'No' &&
                      (widget.editOrder == null) &&
                      !isCouponValidate) &&
                  (Get.find<AuthController>()
                              .profileModel!
                              .restaurants!
                              .first
                              .settings!
                              .isRoleBaseDiscount ==
                          'Yes'
                      ? Get.find<AuthController>()
                          .profileModel!
                          .role!
                          .contains('discount')
                      : true))
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(
                        'Discount Category'
                        ' : ',
                        textAlign: TextAlign.right,
                        style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        )),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      padding: EdgeInsets.symmetric(horizontal: 7),
                      width: Get.width * 0.35,
                      height: MediaQuery.of(context).size.shortestSide > 570
                          ? 40
                          : 25,
                      child: DropdownButton<DiscountCategoryListModel>(
                        isExpanded: true,
                        underline: SizedBox.shrink(),
                        style: poppinsMedium.copyWith(
                          color: Colors.black,
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        ),
                        value: selectedDiscount,
                        hint: Text("Discount"),
                        onChanged: (DiscountCategoryListModel? newValue) {
                          selectedDiscount = newValue;
                          if (newValue == null) {
                            _discountController.clear();

                            // remove discount category
                            selectedDiscount = null;

                            discountCalculator();
                            Get.find<PosController>().update();
                            return;
                          }
                          _discountController.text = newValue.discount!;
                          discountCalculator();
                          Get.find<PosController>().update();
                          // setState(() {
                          //   selectedCategory = newValue;
                          // });
                        },
                        // items: Get.find<AuthController>()
                        //     .profileModel!
                        //     .discountList!
                        //     .map<DropdownMenuItem<DiscountCategoryListModel>>(
                        //   (DiscountCategoryListModel category) {
                        //     return DropdownMenuItem<DiscountCategoryListModel>(
                        //       value: category,
                        //       child: Text(category.discountType!),
                        //     );
                        //   },
                        // ).toList(),
                        items: [
                          DropdownMenuItem<DiscountCategoryListModel>(
                            value: null,
                            child: Text('Select Discount Category'),
                          ),
                          ...Get.find<AuthController>()
                              .profileModel!
                              .discountList!
                              .map<DropdownMenuItem<DiscountCategoryListModel>>(
                            (DiscountCategoryListModel category) {
                              return DropdownMenuItem<
                                  DiscountCategoryListModel>(
                                value: category,
                                child: Text(category.discountType!),
                              );
                            },
                          ).toList(),
                        ],
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: ColorTheme.borderGrey)),
                    ),
                  ]),
                ),
              if ((Get.find<AuthController>()
                              .profileModel!
                              .restaurants!
                              .first
                              .isOrderPaymentType !=
                          'postpaid' &&
                      Get.find<AuthController>()
                              .profileModel!
                              .restaurants!
                              .first
                              .discountType !=
                          'No' &&
                      selectedDiscountType != 'No' &&
                      !isCouponValidate) &&
                  (widget.editOrder == null) &&
                  (Get.find<AuthController>()
                              .profileModel!
                              .restaurants!
                              .first
                              .settings!
                              .isRoleBaseDiscount ==
                          'Yes'
                      ? Get.find<AuthController>()
                          .profileModel!
                          .role!
                          .contains('discount')
                      : true))
                Padding(
                  padding: const EdgeInsets.only(right: 0, top: 10),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(
                        'Discount Type'
                        ' : ',
                        textAlign: TextAlign.right,
                        style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        )),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      padding: EdgeInsets.symmetric(horizontal: 7),
                      width: Get.width * 0.35,
                      height: MediaQuery.of(context).size.shortestSide > 570
                          ? 40
                          : 25,
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: SizedBox.shrink(),
                        style: poppinsMedium.copyWith(
                          color: Colors.black,
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        ),
                        value: selectedDiscountType,
                        hint: Text("Discount"),
                        onChanged: (String? newValue) {
                          selectedDiscountType = newValue!;
                          _discountController.text = '0';
                          discountCalculator();
                          // setState(() {
                          //   selectedCategory = newValue;
                          // });
                        },
                        items: discountType.map<DropdownMenuItem<String>>(
                          (String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          },
                        ).toList(),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: ColorTheme.borderGrey)),
                    ),
                  ]),
                ),

              if ((Get.find<AuthController>()
                              .profileModel!
                              .restaurants!
                              .first
                              .isOrderPaymentType !=
                          'postpaid' &&
                      Get.find<AuthController>()
                              .profileModel!
                              .restaurants!
                              .first
                              .discountType !=
                          'No' &&
                      (widget.editOrder == null) &&
                      selectedDiscountType != 'No' &&
                      !isCouponValidate) &&
                  (Get.find<AuthController>()
                              .profileModel!
                              .restaurants!
                              .first
                              .settings!
                              .isRoleBaseDiscount ==
                          'Yes'
                      ? Get.find<AuthController>()
                          .profileModel!
                          .role!
                          .contains('discount')
                      : true))
                Padding(
                  padding: const EdgeInsets.only(right: 0, top: 10),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(
                        Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .discountText! +
                            ' : ',
                        textAlign: TextAlign.right,
                        style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        )),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      width: Get.width * 0.2,
                      height: MediaQuery.of(context).size.shortestSide > 570
                          ? 40
                          : 25,
                      child: TextField(
                        controller: _discountController,
                        keyboardType:
                            TextInputType.numberWithOptions(signed: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,4}')),
                        ],
                        autofocus: false,
                        decoration: InputDecoration(
                          // hintText: 'phone'.tr,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                                BorderSide(style: BorderStyle.none, width: 0),
                          ),
                          hintStyle: poppinsMedium.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 11,
                              color: ColorTheme.hintText),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: poppinsMedium.copyWith(
                          color: Colors.black,
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        ),
                        onChanged: (value) async {
                          discountCalculator();
                        },
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: ColorTheme.borderGrey)),
                    ),
                  ]),
                ),

              if (Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .isOrderPaymentType !=
                      'postpaid' &&
                  Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .isShowTips ==
                      'Yes' &&
                  (widget.editOrder == null) &&
                  (Get.find<TableController>().selectedTable?.tableNo !=
                          'Delivery' &&
                      widget.editOrder?.orderType != 'delivery') &&
                  (Get.find<TableController>().selectedTable?.tableNo !=
                          'Take Away' &&
                      widget.editOrder?.orderType != 'take_away' &&
                      widget.editOrder?.orderType != 'takeaway'))
                Padding(
                  padding: const EdgeInsets.only(right: 0, top: 10),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text('Add tips : ',
                        textAlign: TextAlign.right,
                        style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        )),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      width: Get.width * 0.2,
                      height: MediaQuery.of(context).size.shortestSide > 570
                          ? 40
                          : 25,
                      child: TextField(
                        controller: _addTips,
                        keyboardType:
                            TextInputType.numberWithOptions(signed: true),
                        autofocus: false,
                        decoration: InputDecoration(
                          // hintText: 'phone'.tr,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                                BorderSide(style: BorderStyle.none, width: 0),
                          ),
                          hintStyle: poppinsMedium.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 11,
                              color: ColorTheme.hintText),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: poppinsMedium.copyWith(
                          color: Colors.black,
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        ),
                        onChanged: (value) async {
                          discountCalculator();
                        },
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: ColorTheme.borderGrey)),
                    ),
                  ]),
                ),

              if (Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .isOrderPaymentType !=
                      'postpaid' &&
                  Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .serviceCharge ==
                      'Yes')
                if ((Get.find<TableController>().selectedTable?.tableNo !=
                            'Delivery' &&
                        widget.editOrder?.orderType != 'delivery') &&
                    (Get.find<TableController>().selectedTable?.tableNo !=
                            'Take Away' &&
                        widget.editOrder?.orderType != 'take_away'))
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Checkbox(
                        value: Get.find<PosController>().isAddServiceCharge,
                        onChanged: (val) {
                          Get.find<PosController>()
                              .changeServeiceChargeValue(val!);
                          discountCalculator();
                        }),
                    Text(
                        '${Get.find<AuthController>().profileModel!.restaurants!.first.settings!.serviceChrgTaxt}',
                        textAlign: TextAlign.right,
                        style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        )),
                    Text(
                        ' :  ${PriceConverter.convertPrice(showServiceChargeValue, isHideCurrency: true)}',
                        style: poppinsMedium.copyWith(
                            fontSize:
                                MediaQuery.of(context).size.shortestSide > 570
                                    ? 15
                                    : 11)),
                  ]),
              if (Get.find<AuthController>()
                      .profileModel!
                      .restaurants!
                      .first
                      .isOrderPaymentType !=
                  'postpaid')
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      // width: 28,
                      child: Checkbox(
                        value: isAutoBillPrint,
                        onChanged: (bool? value) {
                          setState(() {
                            isAutoBillPrint = value!;
                          });
                        },
                      ),
                    ),
                    Text(
                      "Auto Bill Print",
                      style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 12),
                    ),
                  ],
                ),

              if ((Get.find<TableController>().selectedTable?.tableNo ==
                          'Delivery' ||
                      widget.editOrder?.orderType == 'delivery') &&
                  deliveryCharge != 0)
                Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Delivery Charge',
                              textAlign: TextAlign.right,
                              style: poppinsMedium.copyWith(
                                  fontSize:
                                      MediaQuery.of(context).size.shortestSide >
                                              570
                                          ? 15
                                          : 11)),
                          Text(
                              ' :   ' +
                                  PriceConverter.convertPrice(deliveryCharge,
                                      isHideCurrency: true, asFixed: 2),
                              style: poppinsMedium.copyWith(
                                  fontSize:
                                      MediaQuery.of(context).size.shortestSide >
                                              570
                                          ? 15
                                          : 11)),
                        ])),

              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text('Sub Total',
                    textAlign: TextAlign.right,
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 11)),
                Text(
                    ' :   ' +
                        PriceConverter.convertPrice(
                            orderSubTotal +
                                deliveryCharge +
                                showServiceChargeValue +
                                (double.parse(_addTips.text.isEmpty
                                    ? "0"
                                    : _addTips.text)) -
                                ((cartController.isApplyLoyalty &&
                                        !crmLoyaltyBelowMin &&
                                        crmLoyaltyDiscount > 0)
                                    ? crmLoyaltyDiscount
                                    : 0) -
                                ((isCouponValidate && crmCouponRupee > 0)
                                    ? crmCouponRupee
                                    : 0),
                            isHideCurrency: true,
                            asFixed: 2),
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 11)),
              ]),
              if ((gstAmount + tipTaxAmount + gstServiceChargeTax) != 0)
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text('CGST'.tr,
                            textAlign: TextAlign.right,
                            style: poppinsMedium.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 11,
                            )),
                        Text(
                            ' :   ${((gstAmount + tipTaxAmount + gstServiceChargeTax) / 2).toStringAsFixed(2)}',
                            style: poppinsMedium.copyWith(
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 15
                                        : 11)),
                      ]),
                      SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text('SGST'.tr,
                            textAlign: TextAlign.right,
                            style: poppinsMedium.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 11,
                            )),
                        Text(
                            ' :   ${((gstAmount + tipTaxAmount + gstServiceChargeTax) / 2).toStringAsFixed(2)}',
                            style: poppinsMedium.copyWith(
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 15
                                        : 11)),
                      ]),
                    ],
                  ),
                ),
              if (vatAmount != 0)
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text('VAT',
                            textAlign: TextAlign.right,
                            style: poppinsMedium.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 11,
                            )),
                        Text(' :   ${((vatAmount)).toStringAsFixed(2)}',
                            style: poppinsMedium.copyWith(
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 15
                                        : 11)),
                      ]),
                      // SizedBox(height: 10),
                      // Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      //   Text('SGST'.tr,
                      //       textAlign: TextAlign.right,
                      //       style: poppinsMedium.copyWith(
                      //         fontSize:
                      //             MediaQuery.of(context).size.shortestSide > 570
                      //                 ? 15
                      //                 : 11,
                      //       )),
                      //   Text(
                      //       ' :   ${((gstAmount + tipTaxAmount + gstServiceChargeTax) / 2).toStringAsFixed(2)}',
                      //       style: poppinsMedium.copyWith(
                      //           fontSize:
                      //               MediaQuery.of(context).size.shortestSide >
                      //                       570
                      //                   ? 15
                      //                   : 11)),
                      // ]),
                    ],
                  ),
                ),
              // SizedBox(
              //     height: Dimensions
              //         .PADDING_SIZE_SMALL),
            ],
          ),
          // if (availableLoyaltyPoint != 0 &&
          if (false &&
              availableLoyaltyPoint != 0 &&
              (Get.find<AuthController>()
                      .profileModel!
                      .restaurants!
                      .first
                      .settings!
                      .isLoyality ==
                  'Yes'))
            Padding(
              padding: const EdgeInsets.only(right: 0, top: 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text('(Available loyalty points',
                    textAlign: TextAlign.right,
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 11)),
                Text(' :  ${availableLoyaltyPoint.toStringAsFixed(2)})',
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 11)),
              ]),
            ),
          Padding(
            padding: EdgeInsets.only(right: 0, top: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('Total',
                  textAlign: TextAlign.right,
                  style: poppinsBold.copyWith(
                    color: ColorTheme.green,
                    fontSize: MediaQuery.of(context).size.shortestSide > 570
                        ? 17
                        : 14,
                  )),
              Text(
                  ' :  ' +
                      (Get.find<AuthController>()
                                  .profileModel!
                                  .restaurants!
                                  .first
                                  .isTotalRound ==
                              'Yes'
                          ? '${getRoundUpValue(value: (Get.find<PosController>().collectItemPrice))} (${PriceConverter.convertPrice((Get.find<PosController>().collectItemPrice), isHideCurrency: true, asFixed: 2)})'
                          : PriceConverter.convertPrice(
                              (Get.find<PosController>().collectItemPrice),
                              isHideCurrency: true,
                              asFixed: 2)),
                  style: poppinsBold.copyWith(
                      color: ColorTheme.green,
                      fontSize: MediaQuery.of(context).size.shortestSide > 570
                          ? 17
                          : 14)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget customerDetail(CartController cartController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((Get.find<TableController>().selectedTable != null &&
                Get.find<TableController>().selectedTable!.tableNo ==
                    'Delivery') ||
            (widget.editOrder != null &&
                widget.editOrder!.orderType == 'delivery' &&
                widget.editOrder!.deliveryAddress != null))
          GetBuilder<LocationController>(builder: (locationController) {
            return Container(
              margin: EdgeInsets.only(top: 0, left: 20, right: 20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: ColorTheme.productCard,
                borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          // if (userId.isEmpty &&
                          if (selectedPhoneController.text.isEmpty) {
                            showCustomSnackBar(
                                'Please select/Enter a customer first');
                            return;
                          }
                          addAddressController.clear();
                          addNameController.clear();
                          addPhoneController.clear();
                          addFloorController.clear();
                          manuallyAddressController.clear();
                          manuallyAddressSelectRadio = 1;
                          addPincodeController.clear();
                          _showDeliveryAdditionalFields = false;
                          _dobController.clear();
                          _anniversaryController.clear();
                          _selectedDropdownOption = null;
                          // userId = '';
                          usedLoyaltyPoint = 0;
                          walletBalance = 0;
                          walletUsed = 0;
                          if (cartController.isApplyWallet) {
                            cartController.applyWalletBalance(false);
                          }
                          _radioSelected = 1;
                          addAddressDialog();
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: Colors.transparent,
                              border: Border.all(color: ColorTheme.borderGrey)),
                          child: Text(
                            'Add Address +',
                            style: poppinsMedium.copyWith(
                                fontSize: 13, color: ColorTheme.appColor),
                          ),
                        ),
                      ),
                      // InkWell(
                      //   onTap: () {
                      //     if (locationController.addressList.isNotEmpty) {
                      //       showAddressListDialog();
                      //     }
                      //   },
                      //   child: Container(
                      //     padding:
                      //         EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      //     decoration: BoxDecoration(
                      //         borderRadius: BorderRadius.circular(7),
                      //         color: Colors.transparent,
                      //         border: Border.all(color: ColorTheme.borderGrey)),
                      //     child: Text(
                      //       'Select Address',
                      //       style: poppinsMedium.copyWith(
                      //           fontSize: 13, color: ColorTheme.appColor),
                      //     ),
                      //   ),
                      // )
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (locationController
                                  .crmAddressList.isNotEmpty) {
                                showAddressListDialog();
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color: Colors.transparent,
                                  border:
                                      Border.all(color: ColorTheme.borderGrey)),
                              child: Text(
                                'Select Address',
                                style: poppinsMedium.copyWith(
                                    fontSize: 13, color: ColorTheme.appColor),
                              ),
                            ),
                          ),
                          // IconButton(
                          //   padding: EdgeInsets.zero,
                          //   constraints: BoxConstraints(),
                          //   icon: Icon(
                          //     _showDeliveryAdditionalFields
                          //         ? Icons.expand_less
                          //         : Icons.expand_more,
                          //     color: ColorTheme.appColor,
                          //     size: 20,
                          //   ),
                          //   onPressed: () {
                          //     setState(() {
                          //       _showDeliveryAdditionalFields =
                          //           !_showDeliveryAdditionalFields;
                          //     });
                          //   },
                          // ),
                        ],
                      ),
                    ],
                  ),
                  if (widget.editOrder == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: DottedLine(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.center,
                        lineThickness: 1.0,
                        dashLength: 2.5,
                        dashColor: ColorTheme.hintText,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorTheme.borderGrey),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CountryCodePicker(
                              onChanged: (CountryCode _countryCode) async {
                                countryCode = _countryCode;
                                selectedAddress = null;
                                userId = '';
                                walletBalance = 0;
                                walletUsed = 0;
                                if (cartController.isApplyWallet) {
                                  cartController.applyWalletBalance(false);
                                }
                                if (selectedPhoneController.text.isNotEmpty &&
                                    selectedPhoneController.text.length > 7) {
                                  await Get.find<LocationController>()
                                      .getAddressList(
                                          selectedPhoneController.text,
                                          dialCode:
                                              countryCode?.dialCode ?? '+91');
                                  if (Get.find<LocationController>()
                                      .addressList
                                      .isNotEmpty) {
                                    selectedAddress =
                                        Get.find<LocationController>()
                                            .addressList
                                            .first;
                                    if (Get.find<CartController>()
                                            .cartList
                                            .isNotEmpty &&
                                        selectedAddress!.latitude != '' &&
                                        selectedAddress?.longitude != null &&
                                        selectedAddress?.latitude != null) {
                                      await Get.find<LocationController>()
                                          .getDeliveryCharges(
                                              addLat: double.parse(
                                                  selectedAddress?.latitude ??
                                                      '0'),
                                              addLong: double.parse(
                                                  selectedAddress?.longitude ??
                                                      '0'),
                                              restId: Get.find<AuthController>()
                                                  .profileModel!
                                                  .restaurants!
                                                  .first
                                                  .id
                                                  .toString());
                                      if (Get.find<LocationController>()
                                              .getDeliveryChargesResponse!
                                              .shippingCharge !=
                                          0) {
                                        deliveryCharge =
                                            Get.find<LocationController>()
                                                .getDeliveryChargesResponse!
                                                .shippingCharge!;
                                        selectedDeliveryCharge.text =
                                            deliveryCharge.toString();
                                      }
                                    }
                                  }
                                }
                                locationController.update();
                              },
                              initialSelection: 'IN',
                              // enabled: false,
                              showDropDownButton: true,
                              padding: EdgeInsets.zero,
                              showFlagMain: false,
                              flagWidth: 20,
                              dialogBackgroundColor:
                                  Theme.of(context).cardColor,
                              textStyle: poppinsMedium.copyWith(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: 5),
                                height: 40,
                                child: TypeAheadField<CrmCustomerItem>(
                                  getImmediateSuggestions: false,

                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                    controller: selectedPhoneController,
                                    // readOnly: widget.editOrder != null,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            signed: true), // ✅ kept
                                    textAlignVertical:
                                        TextAlignVertical.center, // ✅ kept
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13), // ✅ kept
                                    cursorColor: ColorTheme.appColor, // ✅ kept
                                    autofocus: false, // ✅ kept
                                    decoration: InputDecoration(
                                      border: InputBorder.none, // ✅ kept
                                      isDense: true, // ✅ kept
                                      hintText:
                                          'Contact Person Number', // ✅ kept
                                      fillColor: Colors.white, // ✅ kept
                                      hintStyle: poppinsMedium.copyWith(
                                          fontSize: 13,
                                          color: ColorTheme.hintText), // ✅ kept
                                      filled: true, // ✅ kept
                                    ),
                                  ),

                                  loadingBuilder: (context) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: ColorTheme.appColor,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text('Searching...',
                                            style: poppinsRegular.copyWith(
                                                fontSize: 12,
                                                color: ColorTheme.hintText)),
                                      ],
                                    ),
                                  ),

                                  // ── only fire when length >= 8 digits ──
                                  suggestionsCallback: (pattern) async {
                                    final trimmed = pattern.trim();
                                    if (trimmed.length < 8)
                                      return <CrmCustomerItem>[];
                                    await Get.find<CartController>()
                                        .getCustomerFromApiCrm(
                                            search: trimmed, limit: 10);
                                    return Get.find<CartController>()
                                            .crmCustomerList
                                            ?.customerList ??
                                        [];
                                  },

                                  // ── dropdown item ──
                                  itemBuilder:
                                      (context, CrmCustomerItem suggestion) {
                                    return Padding(
                                      padding: EdgeInsets.all(
                                          Dimensions.PADDING_SIZE_SMALL),
                                      child: Row(children: [
                                        SizedBox(
                                            width:
                                                Dimensions.PADDING_SIZE_SMALL),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                suggestion.phone ?? '',
                                                style: poppinsRegular.copyWith(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .color,
                                                    fontSize: Dimensions
                                                        .FONT_SIZE_SMALL),
                                              ),
                                              Text(
                                                suggestion.name
                                                            ?.trim()
                                                            .isNotEmpty ==
                                                        true
                                                    ? suggestion.name!.trim()
                                                    : 'No Name',
                                                style: poppinsRegular.copyWith(
                                                    color: ColorTheme.hintText,
                                                    fontSize: Dimensions
                                                        .FONT_SIZE_SMALL),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                    );
                                  },

                                  // ── no user found — just text ──
                                  noItemsFoundBuilder: (context) => Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      'No user found, please add address',
                                      style: poppinsRegular.copyWith(
                                          fontSize: 13,
                                          color: ColorTheme.hintText),
                                    ),
                                  ),

                                  // ── on selection — all your existing logic ──
                                  onSuggestionSelected:
                                      (CrmCustomerItem suggestion) async {
                                    selectedAddress = null;
                                    Get.find<LocationController>()
                                        .crmAddressList = [];
                                    selectedPhoneController.text =
                                        suggestion.phone ?? '';
                                    FocusScope.of(context).unfocus();

                                    // parallel fetch
                                    await Future.wait([
                                      Get.find<LocationController>()
                                          .getCrmAddressByPhone(
                                              suggestion.phone ?? ''),
                                      Get.find<CartController>()
                                          .getCrmCustomerDetail(
                                              suggestion.id ?? ''),
                                    ]);

                                    // ── address logic — UNCHANGED ──
                                    final crmAddressList =
                                        Get.find<LocationController>()
                                            .crmAddressList;
                                    if (crmAddressList.isNotEmpty) {
                                      final addr = crmAddressList.firstWhere(
                                        (a) => a.isDefault == true,
                                        orElse: () => crmAddressList.first,
                                      );
                                      selectedAddress = AddressModel(
                                        id: addr.id,
                                        address: addr.address,
                                        house: addr.house,
                                        pincode: addr.pincode,
                                        contactPersonName:
                                            addr.contactPersonName,
                                        contactPersonNumber:
                                            addr.contactPersonNumber,
                                        dialCode: addr.dialCode,
                                        addressType: addr.addressType,
                                        latitude: addr.latitude?.toString(),
                                        longitude: addr.longitude?.toString(),
                                        zoneId: addr.zoneId,
                                        road: addr.road,
                                        floor: addr.floor,
                                      );

                                      if (Get.find<CartController>()
                                              .cartList
                                              .isNotEmpty &&
                                          selectedAddress!.latitude != '' &&
                                          selectedAddress?.longitude != null &&
                                          selectedAddress?.latitude != null) {
                                        await Get.find<LocationController>()
                                            .getDeliveryCharges(
                                                addLat: double.parse(
                                                    selectedAddress?.latitude ??
                                                        '0'),
                                                addLong: double.parse(
                                                    selectedAddress
                                                            ?.longitude ??
                                                        '0'),
                                                restId:
                                                    Get.find<AuthController>()
                                                        .profileModel!
                                                        .restaurants!
                                                        .first
                                                        .id
                                                        .toString());
                                        if (Get.find<LocationController>()
                                                .getDeliveryChargesResponse!
                                                .shippingCharge !=
                                            0) {
                                          deliveryCharge =
                                              Get.find<LocationController>()
                                                  .getDeliveryChargesResponse!
                                                  .shippingCharge!;
                                          selectedDeliveryCharge.text =
                                              deliveryCharge.toString();
                                        }
                                      }
                                    }

                                    // ── dob/anniversary from getCrmCustomerDetail ──
                                    final detail = Get.find<CartController>()
                                        .selectedCrmCustomer;
                                    if (detail != null && mounted) {
                                      setState(() {
                                        if (detail.dob != null &&
                                            detail.dob!.isNotEmpty)
                                          _dobController.text = detail.dob!;
                                        if (detail.anniversary != null &&
                                            detail.anniversary!.isNotEmpty)
                                          _anniversaryController.text =
                                              detail.anniversary!;
                                      });
                                    }

                                    // ── wallet — UNCHANGED ──
                                    walletBalance = 0;
                                    walletUsed = 0;
                                    userId = suggestion.id ??
                                        ''; // ✅ from CrmCustomerItem directly
                                    print('==========>${userId}');

                                    if (cartController.isApplyWallet) {
                                      cartController.applyWalletBalance(false);
                                    }
                                    if (userId != '') {
                                      var data = await cartController
                                          .getWalletBalanceOfCustomer(userId);
                                      if (data != {} &&
                                          data.containsKey('balance')) {
                                        availableLoyaltyPoint = double.parse(
                                            '${data['loyalty_points'] ?? 0}');
                                        walletBalance = double.parse(
                                            '${data['balance'] ?? 0}');
                                      }
                                    }

                                    locationController.update();
                                    if (mounted) setState(() {});
                                  },
                                ),
                              ),
                            )
                          ]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 12),
                    margin: EdgeInsets.only(top: 15),
                    height: 40,
                    width: Get.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: ColorTheme.borderGrey)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.editOrder?.deliveryAddress?.contactPersonName ??
                            selectedAddress?.contactPersonName ??
                            'Contact Person Name',
                        style: poppinsMedium.copyWith(
                            fontSize: 13, color: ColorTheme.hintText),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    padding: EdgeInsets.only(left: 12, right: 12),
                    height: 40,
                    width: Get.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: ColorTheme.borderGrey)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.editOrder?.deliveryAddress != null
                            ? (widget.editOrder?.deliveryAddress?.address ??
                                'Delivery Address')
                            : (selectedAddress?.address ?? 'Delivery Address'),
                        style: poppinsMedium.copyWith(
                            fontSize: 13, color: ColorTheme.hintText),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    padding: EdgeInsets.only(left: 12),
                    height: 40,
                    width: Get.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: ColorTheme.borderGrey)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.editOrder != null &&
                                widget.editOrder!.deliveryAddress != null
                            ? (widget.editOrder?.deliveryAddress?.house ??
                                'House No./Flat No.')
                            : selectedAddress?.house ?? 'House No./Flat No.',
                        style: poppinsMedium.copyWith(
                            fontSize: 13, color: ColorTheme.hintText),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    padding: EdgeInsets.only(left: 12),
                    height: 40,
                    width: Get.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: ColorTheme.borderGrey)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.editOrder?.deliveryAddress != null
                            ? (widget.editOrder?.deliveryAddress?.pincode ??
                                'Pincode')
                            : (selectedAddress?.pincode ?? 'Pincode'),
                        style: poppinsMedium.copyWith(
                            fontSize: 13, color: ColorTheme.hintText),
                      ),
                    ),
                  ),
                  if (Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .isSurcharge ==
                      'Yes')
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      height: 40,
                      width: Get.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: ColorTheme.borderGrey)),
                      child: Center(
                        child: TextField(
                          controller: selectedDeliveryCharge,
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType:
                              TextInputType.numberWithOptions(signed: true),
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                          cursorColor: ColorTheme.appColor,
                          autofocus: false,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.only(bottom: 0, left: 13, right: 13),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7),
                                borderSide: BorderSide.none),
                            isDense: true,
                            hintText: 'Enter Delivery Charge',
                            fillColor: Colors.white,
                            hintStyle: poppinsMedium.copyWith(
                                fontSize: 13, color: ColorTheme.hintText),
                            filled: true,
                          ),
                          onChanged: (String data) async {
                            if (data == '') {
                              deliveryCharge = 0;
                            } else {
                              deliveryCharge =
                                  double.parse(selectedDeliveryCharge.text);
                            }
                            discountCalculator();
                            locationController.update();
                          },
                        ),
                      ),
                    ),
                  // Additional Delivery Address Fields (DOB, DOA, Designation)
                  if (_showDeliveryAdditionalFields) ...[
                    // Date of Birth Field
                    IgnorePointer(
                      ignoring: widget.editOrder != null,
                      child: Container(
                        margin: EdgeInsets.only(top: 15),
                        height: 40,
                        child: TextField(
                          controller: _dobController,
                          readOnly: true,
                          autofocus: false,
                          decoration: InputDecoration(
                            hintText: 'Date of Birth',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 15),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            hintStyle: poppinsMedium.copyWith(
                                fontSize: 13, color: ColorTheme.hintText),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: ColorTheme.grey1,
                              size: 18,
                            ),
                          ),
                          style: poppinsMedium.copyWith(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: ColorTheme.appColor,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate != null) {
                              String formattedDate =
                                  "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                              _dobController.text = formattedDate;
                            }
                          },
                        ),
                      ),
                    ),

                    // Date of Anniversary Field
                    IgnorePointer(
                      ignoring: widget.editOrder != null,
                      child: Container(
                        margin: EdgeInsets.only(top: 15),
                        height: 40,
                        child: TextField(
                          controller: _anniversaryController,
                          readOnly: true,
                          autofocus: false,
                          decoration: InputDecoration(
                            hintText: 'Date of Anniversary',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 15),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            hintStyle: poppinsMedium.copyWith(
                                fontSize: 13, color: ColorTheme.hintText),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: ColorTheme.grey1,
                              size: 18,
                            ),
                          ),
                          style: poppinsMedium.copyWith(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: ColorTheme.appColor,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate != null) {
                              String formattedDate =
                                  "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                              _anniversaryController.text = formattedDate;
                            }
                          },
                        ),
                      ),
                    ),

                    // Dropdown Field
                    IgnorePointer(
                      ignoring: widget.editOrder != null,
                      child: GetBuilder<CustomerManagementController>(
                        builder: (customerController) {
                          // Filter active designations (status == 1)
                          final activeDesignations =
                              (customerController.customerDesignationList)
                                  .where((designation) =>
                                      (designation['status'] as int? ?? 1) == 1)
                                  .toList();

                          return StatefulBuilder(
                            builder: (context, setDropdownState) {
                              return Container(
                                margin: EdgeInsets.only(top: 15),
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(7),
                                  border:
                                      Border.all(color: ColorTheme.borderGrey),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: (customerController
                                        .isCustomerDesignationLoading.value)
                                    ? Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                        ),
                                      )
                                    : DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: (_selectedDropdownOption ==
                                                      null ||
                                                  _selectedDropdownOption!
                                                      .isEmpty)
                                              ? null
                                              : _selectedDropdownOption,
                                          hint: Text(
                                            'Select', //Select Designation
                                            style: poppinsMedium.copyWith(
                                              fontSize: 13,
                                              color: ColorTheme.hintText,
                                            ),
                                          ),
                                          isExpanded: true,
                                          icon: Icon(
                                            Icons.keyboard_arrow_down,
                                            color: ColorTheme.grey1,
                                          ),
                                          style: poppinsMedium.copyWith(
                                            color: Colors.black,
                                            fontSize: 13,
                                          ),
                                          items: activeDesignations.isEmpty
                                              ? [
                                                  DropdownMenuItem(
                                                    value: null,
                                                    enabled: false,
                                                    child: Text(
                                                      'No designation available',
                                                      style: poppinsMedium
                                                          .copyWith(
                                                        fontSize: 13,
                                                        color:
                                                            ColorTheme.hintText,
                                                      ),
                                                    ),
                                                  ),
                                                ]
                                              : activeDesignations.map<
                                                  DropdownMenuItem<String>>(
                                                  (designation) {
                                                    final designationName =
                                                        designation['designation']
                                                                as String? ??
                                                            '';
                                                    return DropdownMenuItem(
                                                      value: designationName,
                                                      child: Text(
                                                        designationName,
                                                        style: poppinsMedium
                                                            .copyWith(
                                                          fontSize: 13,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).toList(),
                                          onChanged: activeDesignations.isEmpty
                                              ? null
                                              : (value) {
                                                  setDropdownState(() {
                                                    _selectedDropdownOption =
                                                        value;
                                                  });
                                                },
                                        ),
                                      ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        if (Get.find<AuthController>()
                .profileModel!
                .restaurants!
                .first
                .isComplementry !=
            'Yes')
          if (widget.editOrder == null
              ? Get.find<TableController>().selectedTable?.tableNo != 'Delivery'
              : widget.editOrder?.orderType != 'delivery')
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Customer Details',
                      style: poppinsMedium.copyWith(
                          fontSize: 13, color: ColorTheme.hintText)),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(
                      _showCustomerAdditionalFields
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: ColorTheme.appColor,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _showCustomerAdditionalFields =
                            !_showCustomerAdditionalFields;
                      });
                    },
                  ),
                ],
              ),
            ),
        if (Get.find<AuthController>()
                .profileModel!
                .restaurants!
                .first
                .isComplementry !=
            'Yes')
          if (widget.editOrder == null
              ? Get.find<TableController>().selectedTable?.tableNo != 'Delivery'
              : widget.editOrder?.orderType != 'delivery')
            Container(
              margin: EdgeInsets.only(top: 15, left: 20, right: 20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: ColorTheme.productCard,
                borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .isShowMemberId ==
                      'Yes')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SizedBox(
                        height: 40,
                        child: IgnorePointer(
                          ignoring: widget.editOrder!.restaurantTable != null &&
                              widget.editOrder!.restaurantTable!.rtype == 'RM',
                          child: cartController.customerList == null
                              ? TextField(
                                  controller: _memberController,
                                  autofocus: false,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    hintText: 'Member Id',
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 15),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7),
                                      borderSide: BorderSide(
                                          color: ColorTheme.borderGrey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7),
                                      borderSide: BorderSide(
                                          color: ColorTheme.borderGrey),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7),
                                      borderSide: BorderSide(
                                          color: ColorTheme.borderGrey),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7),
                                      borderSide: BorderSide(
                                          color: ColorTheme.borderGrey),
                                    ),
                                    hintStyle: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  style: poppinsMedium.copyWith(
                                    color: Colors.black,
                                    fontSize: 13,
                                  ),
                                )
                              : TypeAheadField(
                                  getImmediateSuggestions: true,
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                    onChanged: (s) {
                                      userId = '';
                                      walletBalance = 0;
                                      walletUsed = 0;
                                      if (cartController.isApplyWallet) {
                                        cartController
                                            .applyWalletBalance(false);
                                      }
                                      if (userId != '' &&
                                          isCouponValidate == true) {
                                        userId = '';
                                        _discountController.text = '0';
                                        discountCalculator();
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      }
                                      if (userId != '' &&
                                          cartController.isApplyLoyalty) {
                                        userId = '';
                                        Get.find<PosController>()
                                            .applyLoyaltyValue(false);
                                        usedLoyaltyPoint = 0;
                                        discountCalculator();
                                      }
                                    },
                                    controller: _memberController,
                                    textInputAction: TextInputAction.search,
                                    autofocus: false,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 15),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.RADIUS_SMALL),
                                        borderSide: BorderSide(
                                            color: ColorTheme.borderGrey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.RADIUS_SMALL),
                                        borderSide: BorderSide(
                                            color: ColorTheme.borderGrey),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.RADIUS_SMALL),
                                        borderSide: BorderSide(
                                            color: ColorTheme.borderGrey),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.RADIUS_SMALL),
                                        borderSide: BorderSide(
                                            color: ColorTheme.borderGrey),
                                      ),
                                      hintStyle: poppinsMedium.copyWith(
                                          fontSize: 13, color: Colors.grey),
                                      hintText: 'Member Id',
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    style: poppinsMedium.copyWith(
                                      color: Colors.black,
                                      fontSize: 13,
                                    ),
                                  ),
                                  noItemsFoundBuilder: (context) =>
                                      SizedBox.shrink(),
                                  suggestionsCallback: (pattern) async {
                                    return cartController
                                        .memberList!.customerList
                                        .where((item) =>
                                            item.memberId != '' &&
                                            item.memberId
                                                .toString()
                                                .trim()
                                                .toLowerCase()
                                                .contains(pattern
                                                    .toLowerCase()
                                                    .trim()))
                                        .toList();
                                  },
                                  itemBuilder:
                                      (context, MemberList suggestion) {
                                    return Padding(
                                      padding: EdgeInsets.all(
                                          Dimensions.PADDING_SIZE_SMALL),
                                      child: Row(children: [
                                        SizedBox(
                                            width:
                                                Dimensions.PADDING_SIZE_SMALL),
                                        Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    '${suggestion.memberId ?? ''}',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        poppinsRegular.copyWith(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color,
                                                      fontSize: Dimensions
                                                          .FONT_SIZE_SMALL,
                                                    )),
                                              ]),
                                        ),
                                      ]),
                                    );
                                  },
                                  onSuggestionSelected:
                                      (MemberList suggestion) async {
                                    _memberController.text =
                                        suggestion.memberId.toString();
                                    _phoneController.text =
                                        suggestion.phone.toString();
                                    _nameController.text =
                                        suggestion.customerName;

                                    userId = '${suggestion.id}';
                                    if (userId != '' &&
                                        (Get.find<AuthController>()
                                                .profileModel!
                                                .restaurants!
                                                .first
                                                .settings!
                                                .isLoyality ==
                                            'Yes')) {
                                      Get.find<PosController>()
                                          .applyLoyaltyValue(false);
                                      // var data =
                                      //     await Get.find<LoyaltyController>()
                                      //         .checkValidLoyaltyPoint(
                                      //             '$userId',
                                      //             Get.find<PosController>()
                                      //                 .collectItemPrice,
                                      //             isLoading: false);
                                      // if (data != {} &&
                                      //     data.containsKey('pointsToRedeem')) {
                                      //   availableLoyaltyPoint = double.parse(
                                      //       '${data['availablePoints'] ?? 0}');
                                      // }
                                      _crmOfferKey = '';
                                      _scheduleCrmOffers();
                                    }
                                    if (userId != '' &&
                                        Get.find<AuthController>()
                                                .profileModel!
                                                .restaurants!
                                                .first
                                                .settings!
                                                .isCustomerWallet ==
                                            'Yes') {
                                      walletBalance = 0;
                                      walletUsed = 0;
                                      var data =
                                          await Get.find<CartController>()
                                              .getWalletBalanceOfCustomer(
                                                  '$userId');
                                      if (data != {} &&
                                          data.containsKey('balance')) {
                                        // usedLoyaltyPoint = double.parse('${data['pointsToRedeem'] ?? 0}');
                                        walletBalance = double.parse(
                                            '${data['balance'] ?? 0}');
                                      }
                                    }
                                  },
                                ),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 40,
                    child: IgnorePointer(
                      ignoring: widget.editOrder?.restaurantTable != null &&
                          widget.editOrder!.restaurantTable!.rtype == 'RM',
                      child: TypeAheadField<CrmCustomerItem>(
                        getImmediateSuggestions: true,
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: _nameController,
                          onChanged: (s) async {
                            userId = '';
                            walletBalance = 0;
                            walletUsed = 0;
                            if (cartController.isApplyWallet) {
                              cartController.applyWalletBalance(false);
                            }
                            if (userId != '' && isCouponValidate == true) {
                              userId = '';
                              _discountController.text = '0';
                              discountCalculator();
                              if (mounted) {
                                setState(() {});
                              }
                            }
                            if (userId != '' && cartController.isApplyLoyalty) {
                              Get.find<PosController>()
                                  .applyLoyaltyValue(false);

                              usedLoyaltyPoint = 0;
                              userId = '';
                              discountCalculator();
                            }
                          },
                          textInputAction: TextInputAction.search,
                          autofocus: false,
                          textCapitalization: TextCapitalization.words,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 15),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            hintStyle: poppinsMedium.copyWith(
                                fontSize: 13, color: Colors.grey),
                            hintText: 'Name',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: poppinsMedium.copyWith(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                        loadingBuilder: (context) => Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: ColorTheme.appColor,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Searching...',
                                  style: poppinsRegular.copyWith(
                                      fontSize: 12,
                                      color: ColorTheme.hintText)),
                            ],
                          ),
                        ),
                        noItemsFoundBuilder: (context) => SizedBox.shrink(),
                        suggestionsCallback: (pattern) async {
                          final trimmed = pattern.trim();
                          if (trimmed.length < 2) return <CrmCustomerItem>[];
                          await Get.find<CartController>()
                              .getCustomerFromApiCrm(
                                  search: trimmed, limit: 10);
                          return Get.find<CartController>()
                                  .crmCustomerList
                                  ?.customerList ??
                              [];
                        },
                        itemBuilder: (context, CrmCustomerItem suggestion) {
                          return Padding(
                            padding:
                                EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                            child: Row(children: [
                              SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      suggestion.name?.trim().isNotEmpty == true
                                          ? suggestion.name!.trim()
                                          : 'No Name',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: poppinsRegular.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color,
                                        fontSize: Dimensions.FONT_SIZE_SMALL,
                                      ),
                                    ),
                                    Text(
                                      suggestion.phone ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: poppinsRegular.copyWith(
                                        color: ColorTheme.hintText,
                                        fontSize: Dimensions.FONT_SIZE_SMALL,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          );
                        },
                        onSuggestionSelected:
                            (CrmCustomerItem suggestion) async {
                          _phoneController.text = suggestion.phone ?? '';
                          _nameController.text = suggestion.name?.trim() ?? '';
                          walletBalance = suggestion.walletBalance ?? 0;
                          walletUsed = 0;
                          if (cartController.isApplyWallet)
                            cartController.applyWalletBalance(false);
                          _dobController.text = '';
                          _anniversaryController.text = '';
                          _selectedDropdownOption = null;

                          if (mounted) setState(() {});

                          userId = '${suggestion.id}';
                          if (userId != '' &&
                              (Get.find<AuthController>()
                                      .profileModel!
                                      .restaurants!
                                      .first
                                      .settings!
                                      .isLoyality ==
                                  'Yes')) {
                            Get.find<PosController>().applyLoyaltyValue(false);
                            // var data = await Get.find<LoyaltyController>()
                            //     .checkValidLoyaltyPoint('$userId',
                            //         Get.find<PosController>().collectItemPrice,
                            //         isLoading: false);
                            // if (data != {} &&
                            //     data.containsKey('pointsToRedeem')) {
                            //   availableLoyaltyPoint = double.parse(
                            //       '${data['availablePoints'] ?? 0}');
                            // }
                            _crmOfferKey = '';
                            _scheduleCrmOffers();
                          }
                          // ── Step 3: Silently fetch dob/anniversary/email ──
                          Get.find<CartController>()
                              .getCrmCustomerDetail(suggestion.id!)
                              .then((detailResponse) {
                            if (detailResponse != null && mounted) {
                              setState(() {
                                if (detailResponse.dob != null &&
                                    detailResponse.dob!.isNotEmpty)
                                  _dobController.text = detailResponse.dob!;
                                if (detailResponse.anniversary != null &&
                                    detailResponse.anniversary!.isNotEmpty)
                                  _anniversaryController.text =
                                      detailResponse.anniversary!;
                                // if (detailResponse.email != null && detailResponse.email!.isNotEmpty)
                                //   _emailController.text = detailResponse.email!;
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  IgnorePointer(
                    ignoring: widget.editOrder != null,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorTheme.borderGrey),
                        borderRadius:
                            BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CountryCodePicker(
                            onChanged: (CountryCode _countryCode) {
                              setState(() {
                                countryCode = _countryCode;
                              });
                            },
                            initialSelection: 'IN',
                            showDropDownButton: true,
                            padding: EdgeInsets.zero,
                            showFlagMain: false,
                            flagWidth: 20,
                            dialogBackgroundColor:
                                Theme.of(context).cardColor,
                            textStyle: poppinsMedium.copyWith(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                          Expanded(
                            child: TypeAheadField<CrmCustomerItem>(
                              getImmediateSuggestions: true,
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _phoneController,
                                textInputAction: TextInputAction.search,
                                onChanged: (s) {
                                  userId = '';
                                  walletBalance = 0;
                                  walletUsed = 0;
                                  if (cartController.isApplyWallet) {
                                    cartController.applyWalletBalance(false);
                                  }
                                  if (userId != '' &&
                                      isCouponValidate == true) {
                                    userId = '';
                                    _discountController.text = '0';
                                    discountCalculator();
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  }
                                  if (userId != '' &&
                                      cartController.isApplyLoyalty) {
                                    userId = '';
                                    Get.find<PosController>()
                                        .applyLoyaltyValue(false);

                                    usedLoyaltyPoint = 0;
                                    discountCalculator();
                                  }
                                },
                                autofocus: false,
                                textCapitalization: TextCapitalization.words,
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType:
                                    TextInputType.numberWithOptions(
                                        signed: true),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  if ((countryCode?.dialCode ?? '+91') ==
                                      '+91')
                                    LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 10),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintStyle: poppinsMedium.copyWith(
                                      fontSize: 13, color: Colors.grey),
                                  hintText: 'Phone Number',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                style: poppinsMedium.copyWith(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              suggestionsCallback: (pattern) async {
                          final trimmed = pattern.trim();
                          if (trimmed.length < 3)
                            return <CrmCustomerItem>[]; // ← 3 for phone
                          await Get.find<CartController>()
                              .getCustomerFromApiCrm(
                                  search: trimmed, limit: 10);
                          return Get.find<CartController>()
                                  .crmCustomerList
                                  ?.customerList ??
                              [];
                        },
                        loadingBuilder: (context) => Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: ColorTheme.appColor,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Searching...',
                                  style: poppinsRegular.copyWith(
                                      fontSize: 12,
                                      color: ColorTheme.hintText)),
                            ],
                          ),
                        ),
                        noItemsFoundBuilder: (context) => SizedBox.shrink(),
                        itemBuilder: (context, CrmCustomerItem suggestion) {
                          return Padding(
                            padding:
                                EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                            child: Row(children: [
                              SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      suggestion.phone ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: poppinsRegular.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color,
                                        fontSize: Dimensions.FONT_SIZE_SMALL,
                                      ),
                                    ),
                                    Text(
                                      suggestion.name?.trim().isNotEmpty == true
                                          ? suggestion.name!.trim()
                                          : 'No Name',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: poppinsRegular.copyWith(
                                        color: ColorTheme.hintText,
                                        fontSize: Dimensions.FONT_SIZE_SMALL,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          );
                        },
                        onSuggestionSelected:
                            (CrmCustomerItem suggestion) async {
                          _phoneController.text = suggestion.phone ?? '';
                          _nameController.text = suggestion.name?.trim() ?? '';
                          _dobController.text = '';
                          _anniversaryController.text = '';
                          _selectedDropdownOption = null;

                          if (mounted) setState(() {});

                          userId = '${suggestion.id}';
                          walletBalance = suggestion.walletBalance ?? 0;
                          walletUsed = 0;
                          if (cartController.isApplyWallet)
                            cartController.applyWalletBalance(false);

                          if (userId != '' &&
                              (Get.find<AuthController>()
                                      .profileModel!
                                      .restaurants!
                                      .first
                                      .settings!
                                      .isLoyality ==
                                  'Yes')) {
                            Get.find<PosController>().applyLoyaltyValue(false);
                            // var data = await Get.find<LoyaltyController>()
                            //     .checkValidLoyaltyPoint('$userId',
                            //         Get.find<PosController>().collectItemPrice,
                            //         isLoading: false);
                            // if (data != {} &&
                            //     data.containsKey('pointsToRedeem')) {
                            //   availableLoyaltyPoint = double.parse(
                            //       '${data['availablePoints'] ?? 0}');
                            // }
                            _crmOfferKey = '';
                            _scheduleCrmOffers();
                          }

                          // emailController.text = suggestion.email;
                          // Get.find<CartController>().update();
                          // ── Step 3: Silently fetch dob/anniversary/email ──
                          Get.find<CartController>()
                              .getCrmCustomerDetail(suggestion.id!)
                              .then((detailResponse) {
                            if (detailResponse != null && mounted) {
                              setState(() {
                                if (detailResponse.dob != null &&
                                    detailResponse.dob!.isNotEmpty)
                                  _dobController.text = detailResponse.dob!;
                                if (detailResponse.anniversary != null &&
                                    detailResponse.anniversary!.isNotEmpty)
                                  _anniversaryController.text =
                                      detailResponse.anniversary!;
                                // if (detailResponse.email != null && detailResponse.email!.isNotEmpty)
                                //   _emailController.text = detailResponse.email!;
                              });
                            }
                          });
                        },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Additional Customer Fields (DOB, DOA, Designation)
                  if (_showCustomerAdditionalFields) ...[
                    // Date of Birth Field
                    IgnorePointer(
                      ignoring: widget.editOrder != null,
                      child: Container(
                        margin: EdgeInsets.only(top: 15),
                        height: 40,
                        child: TextField(
                          controller: _dobController,
                          readOnly: true,
                          autofocus: false,
                          decoration: InputDecoration(
                            hintText: 'Date of Birth',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 15),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            hintStyle: poppinsMedium.copyWith(
                                fontSize: 13, color: ColorTheme.hintText),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: ColorTheme.grey1,
                              size: 18,
                            ),
                          ),
                          style: poppinsMedium.copyWith(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: ColorTheme.appColor,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate != null) {
                              String formattedDate =
                                  "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                              _dobController.text = formattedDate;
                            }
                          },
                        ),
                      ),
                    ),

                    // Date of Anniversary Field
                    IgnorePointer(
                      ignoring: widget.editOrder != null,
                      child: Container(
                        margin: EdgeInsets.only(top: 15),
                        height: 40,
                        child: TextField(
                          controller: _anniversaryController,
                          readOnly: true,
                          autofocus: false,
                          decoration: InputDecoration(
                            hintText: 'Date of Anniversary',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 15),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            hintStyle: poppinsMedium.copyWith(
                                fontSize: 13, color: ColorTheme.hintText),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: ColorTheme.grey1,
                              size: 18,
                            ),
                          ),
                          style: poppinsMedium.copyWith(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: ColorTheme.appColor,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate != null) {
                              String formattedDate =
                                  "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                              _anniversaryController.text = formattedDate;
                            }
                          },
                        ),
                      ),
                    ),

                    // Dropdown Field
                    IgnorePointer(
                      ignoring: widget.editOrder != null,
                      child: GetBuilder<CustomerManagementController>(
                        builder: (customerController) {
                          // Filter active designations (status == 1)
                          final activeDesignations =
                              (customerController.customerDesignationList)
                                  .where((designation) =>
                                      (designation['status'] as int? ?? 1) == 1)
                                  .toList();

                          return StatefulBuilder(
                            builder: (context, setDropdownState) {
                              return Container(
                                margin: EdgeInsets.only(top: 15),
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(7),
                                  border:
                                      Border.all(color: ColorTheme.borderGrey),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: (customerController
                                        .isCustomerDesignationLoading.value)
                                    ? Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                        ),
                                      )
                                    : DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: (_selectedDropdownOption ==
                                                      null ||
                                                  _selectedDropdownOption!
                                                      .isEmpty)
                                              ? null
                                              : _selectedDropdownOption,
                                          hint: Text(
                                            'Select', //Select Designation
                                            style: poppinsMedium.copyWith(
                                              fontSize: 13,
                                              color: ColorTheme.hintText,
                                            ),
                                          ),
                                          isExpanded: true,
                                          icon: Icon(
                                            Icons.keyboard_arrow_down,
                                            color: ColorTheme.grey1,
                                          ),
                                          style: poppinsMedium.copyWith(
                                            color: Colors.black,
                                            fontSize: 13,
                                          ),
                                          items: activeDesignations.isEmpty
                                              ? [
                                                  DropdownMenuItem(
                                                    value: null,
                                                    enabled: false,
                                                    child: Text(
                                                      'No designation available',
                                                      style: poppinsMedium
                                                          .copyWith(
                                                        fontSize: 13,
                                                        color:
                                                            ColorTheme.hintText,
                                                      ),
                                                    ),
                                                  ),
                                                ]
                                              : activeDesignations.map<
                                                  DropdownMenuItem<String>>(
                                                  (designation) {
                                                    final designationName =
                                                        designation['designation']
                                                                as String? ??
                                                            '';
                                                    return DropdownMenuItem(
                                                      value: designationName,
                                                      child: Text(
                                                        designationName,
                                                        style: poppinsMedium
                                                            .copyWith(
                                                          fontSize: 13,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).toList(),
                                          onChanged: activeDesignations.isEmpty
                                              ? null
                                              : (value) {
                                                  setDropdownState(() {
                                                    _selectedDropdownOption =
                                                        value;
                                                  });
                                                },
                                        ),
                                      ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
      ],
    );
  }

  String _checkoutCrmChannel() {
    final table = Get.find<TableController>().selectedTable;
    if (table?.id == 0 && table?.tableNo == 'Delivery') return 'delivery';
    if (table?.id == 0 && table?.tableNo == 'Take Away') return 'takeaway';
    return LoyaltyController.crmOrderChannel('dine in');
  }

  double _crmBillBase() {
    final manual = orderDiscount < 0 ? 0.0 : orderDiscount;
    final base = orderItemTotal - manual;
    return base < 0 ? 0 : base;
  }

  List<Map<String, dynamic>> _crmCartItems() {
    return Get.find<CartController>().cartList.map((cart) {
      final price = cart.product.price == 1
          ? cart.discountedPrice
          : (cart.product.price ?? 0);
      final qty = cart.quantity;
      return {
        'food_id': '${cart.product.id ?? ''}',
        'item_id': '${cart.product.id ?? ''}',
        'name': cart.product.name ?? '',
        'quantity': qty,
        'unit_price': price,
        'line_total': price * qty,
        'category_name': '',
        'give_discount': cart.product.giveDiscount ?? 'Yes',
      };
    }).toList();
  }

  void _scheduleCrmOffers() {
    _crmOfferDebounce?.cancel();
    _crmOfferDebounce = Timer(const Duration(milliseconds: 400), _loadCrmOffers);
  }

  Future<void> _loadCrmOffers() async {
    if (!mounted || _crmOfferInFlight) return;
    final settings = Get.find<AuthController>()
        .profileModel
        ?.restaurants
        ?.first
        .settings;
    final phone = _phoneController.text.trim();
    final bill = _crmBillBase();
    if (bill <= 0 || (userId.isEmpty && phone.isEmpty)) return;
    final key = '$userId|$phone|$bill';
    if (key == _crmOfferKey) return;
    _crmOfferKey = key;
    _crmOfferInFlight = true;
    try {
      if (settings?.isLoyality == 'Yes') {
        final result = await Get.find<LoyaltyController>().fetchCrmMaxRedeemable(
          customerId: userId,
          phone: phone,
          billAmount: bill,
        );
        if (!mounted) return;
        final previousDiscount = crmLoyaltyDiscount;
        setState(() {
          crmLoyaltyHidden = result['hidden'] == true;
          crmLoyaltyBelowMin = result['belowMin'] == true;
          crmLoyaltyHint = result['message']?.toString() ?? '';
          crmMaxPoints = LoyaltyController.crmNum(result['maxPoints']);
          crmLoyaltyDiscount = LoyaltyController.crmNum(result['maxDiscount']);
          crmAvailablePoints =
              LoyaltyController.crmNum(result['availablePoints']);
          crmLoyaltyTier = result['tier']?.toString() ?? '';
          crmEarnPoints = LoyaltyController.crmNum(result['earnPoints']).round();
        });
        final loyaltyOn = Get.find<CartController>().isApplyLoyalty;
        if (loyaltyOn &&
            (crmLoyaltyHidden || crmLoyaltyBelowMin || crmLoyaltyDiscount <= 0)) {
          Get.find<CartController>().applyLoyaltyValue(false);
          discountCalculator();
          return;
        }
        if (loyaltyOn && previousDiscount != crmLoyaltyDiscount) {
          discountCalculator();
          return;
        }
      }
      // if (settings?.isCoupon == 'Yes' &&
      //     userId.isNotEmpty &&
      //     _couponController.text.isEmpty &&
      //     !isCouponValidate &&
      //     _crmCouponFetchCount < 3) {
      //   _crmCouponFetchCount++;
      //   final best = await Get.find<LoyaltyController>().fetchBestCrmOrderCoupon(
      //     customerId: userId,
      //     orderTotal: bill,
      //     channel: _checkoutCrmChannel(),
      //   );
      //   final code = best?['code']?.toString() ?? '';
      //   if (code.isNotEmpty && mounted && _couponController.text.isEmpty) {
      //     _couponController.text = code;
      //     await _applyCrmCoupon(fromAuto: true);
      //   }
      // }
    } finally {
      _crmOfferInFlight = false;
    }
  }

  Future<void> _applyCrmCoupon({bool fromAuto = false}) async {
    final items = _crmCartItems();
    final result = await Get.find<LoyaltyController>().validateCrmCoupon(
      code: _couponController.text,
      customerId: userId,
      orderTotal: _crmBillBase(),
      channel: _checkoutCrmChannel(),
      loyaltyPointsUsed: Get.find<CartController>().isApplyLoyalty
          ? crmMaxPoints.round()
          : 0,
      items: items,
    );
    if (!mounted) return;
    if (result['valid'] == true) {
      final blocked = LoyaltyController.crmBenefitBlocked(
        result['benefitItems'],
        (id) => items.any((line) =>
            (line['food_id'] == id || line['item_id'] == id) &&
            line['give_discount'].toString() != 'Yes'),
      );
      if (blocked) {
        if (!fromAuto) showErrorToast('Coupon not available for this item');
        return;
      }
      if (result['stackable'] == false &&
          Get.find<CartController>().isApplyLoyalty) {
        if (!fromAuto) {
          showErrorToast('Cannot combine coupon with loyalty points');
        }
        return;
      }
      setState(() {
        isCouponValidate = true;
        crmCouponCode = result['code']?.toString() ?? '';
        crmCouponTitle = result['title']?.toString() ?? '';
        crmCouponScope = result['couponType']?.toString() ?? 'order';
        crmCouponRupee = LoyaltyController.crmNum(result['discount']);
        crmCouponBenefit = result['benefit']?.toString() ?? '';
        crmCouponStackable = result['stackable'] != false;
      });
      discountCalculator();
    } else if (!fromAuto) {
      setState(() {
        isCouponValidate = false;
        crmCouponRupee = 0;
        crmCouponCode = '';
        crmCouponTitle = '';
        crmCouponBenefit = '';
      });
      showErrorToast(result['message']?.toString() ?? 'Invalid coupon code');
    }
  }

  void _toggleCrmLoyalty() {
    final cartController = Get.find<CartController>();
    if (crmLoyaltyBelowMin || crmLoyaltyDiscount <= 0) {
      cartController.applyLoyaltyValue(false);
      if (crmLoyaltyHint.isNotEmpty) showErrorToast(crmLoyaltyHint);
      discountCalculator();
      return;
    }
    cartController.applyLoyaltyValue(!cartController.isApplyLoyalty);
    if (cartController.isApplyLoyalty &&
        !crmCouponStackable &&
        isCouponValidate) {
      isCouponValidate = false;
      crmCouponRupee = 0;
      crmCouponCode = '';
      crmCouponTitle = '';
      crmCouponBenefit = '';
      showErrorToast('Cannot combine coupon with loyalty points');
    }
    discountCalculator();
  }

  void discountCalculator() {
    orderItemTotal = 0;
    double discountableItemTotal = 0;
    orderSubTotal = 0;
    gstServiceChargeTax = 0;
    discountedOrderSubTotal = 0;
    couponDiscount = 0;

    orderDiscount = 0;
    gstAmount = 0;
    vatAmount = 0;
    showServiceChargeValue = 0;
    //gstserivechargetax need to be zero
    // debugPrint('discount cal gstservicecharge ===> $gstServiceChargeTax');
    gstServiceChargeTax = 0;
    tipTaxAmount = 0;

    // double gstTypeFood = 0;
    // double vatTypeFood = 0;
    jsonCartList = [];
    Restaurant restaurant =
        Get.find<AuthController>().profileModel!.restaurants!.first;
    if (selectedDiscountType == 'Percent' &&
        _discountController.text.isNotEmpty &&
        double.parse(_discountController.text) > 100) {
      showErrorToast('Please enter valid discount');
    } else {
      for (var i = 0; i < Get.find<CartController>().cartList.length; i++) {
        CartModel cart = Get.find<CartController>().cartList[i];

        double variationTotal = 0;
        double addonsTotal = 0;
        double foodAmount = 0;
        double apiFoodAmount = 0;
        double complementFoodTotal = 0;
        double halfVariationPrice = 0;
        double foodGstAmount = 0;
        double foodVatAmount = 0;
        double discountFood = 0;
        // List<int> ids = [];
        // List<int> qtys = [];
        // int index0 = 0;

        for (var addOn in cart.addOnIds) {
          if (addOn.quantity != 0) {
            addonsTotal = addonsTotal +
                (((addOn.price ?? 0) * addOn.quantity) * cart.quantity);
            // index0 = index0 + 1;
          }
        }
        if (cart.variation.isNotEmpty) {
          for (int index = 0; index < cart.variation.length; index++) {
            if (cart.variation[index].isNotEmpty &&
                cart.variation[index].contains(true)) {
              for (int i = 0; i < cart.variation[index].length; i++) {
                if (cart.variation[index][i]) {
                  final variations = cart.product.variations;
                  if (variations != null &&
                      index < variations.length &&
                      variations[index].values != null &&
                      i < variations[index].values!.length) {
                    if ((variations[index].name ?? '').toUpperCase() ==
                        'HALFNHALF') {
                      final optionPrice =
                          variations[index].values![i].optionPrice ?? '0';
                      if (halfVariationPrice <
                          double.parse(optionPrice) * cart.quantity) {
                        halfVariationPrice =
                            double.parse(optionPrice) * cart.quantity;
                      }
                    } else {
                      final optionPrice =
                          variations[index].values![i].optionPrice ?? '0';
                      variationTotal +=
                          double.parse(optionPrice) * cart.quantity;
                    }
                  }
                }
              }
              variationTotal = variationTotal + halfVariationPrice;
            }
          }
        }
        if (Get.find<TableController>().selectedTable == null ||
            Get.find<TableController>().selectedTable!.tableNo ==
                'Select Table') {
          orderItemTotal = twoDecimal(orderItemTotal +
              (cart.isComplementry
                  ? 0
                  : ((cart.product.price == 1
                              ? cart.discountedPrice
                              : cart.product.price)! *
                          cart.quantity +
                      variationTotal +
                      addonsTotal)));
          foodAmount = twoDecimal(cart.isComplementry
              ? 0
              : ((cart.product.price == 1
                          ? cart.discountedPrice
                          : cart.product.price)! *
                      cart.quantity +
                  variationTotal +
                  addonsTotal));
          apiFoodAmount = twoDecimal(cart.isComplementry
              ? 0
              : ((cart.product.price == 1
                      ? cart.discountedPrice
                      : cart.product.price)! *
                  cart.quantity));
          if (cart.isComplementry)
            complementFoodTotal = twoDecimal(((cart.product.price == 1
                    ? cart.discountedPrice
                    : cart.product.price)! *
                cart.quantity));
        } else if (Get.find<TableController>().selectedTable!.tableNo ==
            'Take Away') {
          orderItemTotal = twoDecimal(orderItemTotal +
              (cart.isComplementry
                  ? 0
                  : ((cart.product.price == 1
                              ? cart.discountedPrice
                              : (cart.product.price! +
                                  cart.product.takeAwayFoodPrice!)) *
                          cart.quantity +
                      variationTotal +
                      addonsTotal)));
          foodAmount = twoDecimal(cart.isComplementry
              ? 0
              : ((cart.product.price == 1
                          ? cart.discountedPrice
                          : (cart.product.price! +
                              cart.product.takeAwayFoodPrice!)) *
                      cart.quantity +
                  variationTotal +
                  addonsTotal));
          apiFoodAmount = twoDecimal(cart.isComplementry
              ? 0
              : ((cart.product.price == 1
                      ? cart.discountedPrice
                      : (cart.product.price! +
                          cart.product.takeAwayFoodPrice!)) *
                  cart.quantity));
          if (cart.isComplementry)
            complementFoodTotal = twoDecimal(((cart.product.price == 1
                    ? cart.discountedPrice
                    : (cart.product.price! + cart.product.takeAwayFoodPrice!)) *
                cart.quantity));
        } else if (Get.find<TableController>().selectedTable!.tableNo ==
            'Delivery') {
          orderItemTotal = twoDecimal(orderItemTotal +
              (cart.isComplementry
                  ? 0
                  : ((cart.product.price == 1
                              ? cart.discountedPrice
                              : (cart.product.price! +
                                  cart.product.deliveryFoodPrice!)) *
                          cart.quantity +
                      variationTotal +
                      addonsTotal)));
          foodAmount = twoDecimal(cart.isComplementry
              ? 0
              : ((cart.product.price == 1
                          ? cart.discountedPrice
                          : (cart.product.price! +
                              cart.product.deliveryFoodPrice!)) *
                      cart.quantity +
                  variationTotal +
                  addonsTotal));
          apiFoodAmount = twoDecimal(cart.isComplementry
              ? 0
              : ((cart.product.price == 1
                      ? cart.discountedPrice
                      : (cart.product.price! +
                          cart.product.deliveryFoodPrice!)) *
                  cart.quantity));
          if (cart.isComplementry)
            complementFoodTotal = twoDecimal(((cart.product.price == 1
                    ? cart.discountedPrice
                    : (cart.product.price! + cart.product.deliveryFoodPrice!)) *
                cart.quantity));
        } else {
          if (!cart.isComplementry)
            orderItemTotal = twoDecimal(orderItemTotal +
                (cart.product.price == 1
                        ? cart.discountedPrice
                        : cart.product.price)! *
                    cart.quantity +
                variationTotal +
                addonsTotal);
          if (!cart.isComplementry)
            foodAmount = twoDecimal((cart.product.price == 1
                    ? cart.discountedPrice
                    : (cart.product.price)! * cart.quantity) +
                variationTotal +
                addonsTotal);
          if (!cart.isComplementry)
            apiFoodAmount = twoDecimal((cart.product.price == 1
                    ? cart.discountedPrice
                    : cart.product.price)! *
                cart.quantity);
          if (cart.isComplementry) {
            complementFoodTotal = twoDecimal((cart.product.price == 1
                    ? cart.discountedPrice
                    : cart.product.price)! *
                cart.quantity);
          }
        }

        if (!cart.isComplementry &&
            cart.product.giveDiscount.toString() == 'Yes') {
          discountableItemTotal =
              twoDecimal(discountableItemTotal + foodAmount);
        }

        if (selectedDiscountType == 'Percent' || selectedDiscountType == 'No') {
          double tempDiscountPercent = selectedDiscountType == 'No'
              ? 0
              : _discountController.text.isEmpty
                  ? 0
                  : double.parse(_discountController.text);
          double tempAmount = 0;
          if (cart.product.giveDiscount.toString() == 'Yes') {
            tempAmount = twoDecimal(foodAmount -
                (foodAmount *
                    (coummunityDiscountPercentage + tempDiscountPercent) /
                    100));
            orderSubTotal = twoDecimal(orderSubTotal + tempAmount);

            orderDiscount = twoDecimal(orderDiscount +
                (foodAmount *
                    (coummunityDiscountPercentage + tempDiscountPercent) /
                    100));
            couponDiscount = twoDecimal(
                couponDiscount + (foodAmount * (tempDiscountPercent) / 100));
            discountFood = twoDecimal((foodAmount *
                (coummunityDiscountPercentage + tempDiscountPercent) /
                100));
          } else {
            tempAmount = twoDecimal(foodAmount);
            orderSubTotal = twoDecimal(orderSubTotal + tempAmount);
          }
          if (cart.product.taxType.toString() == 'GST') {
            if (restaurant.gstStatus == 'true') {
              //   gstAmount = gstAmount +
              //       ((tempAmount * double.parse(cart.product.tax.toString())) /
              //           100);
              // }
              if (Get.find<PosController>().isAddServiceCharge) {
                gstAmount = twoDecimal(gstAmount +
                    (((tempAmount) *
                            double.parse(cart.product.tax.toString())) /
                        100));
                showServiceChargeValue = twoDecimal(showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100));
                foodGstAmount = twoDecimal((((tempAmount) *
                        double.parse(cart.product.tax.toString())) /
                    100));
              } else {
                gstAmount = twoDecimal(gstAmount +
                    ((tempAmount * double.parse(cart.product.tax.toString())) /
                        100));
                foodGstAmount = twoDecimal(
                    (tempAmount * double.parse(cart.product.tax.toString())) /
                        100);
              }
            } else {
              if (Get.find<PosController>().isAddServiceCharge) {
                showServiceChargeValue = twoDecimal(showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100));
              }
            }
            discountedOrderSubTotal =
                twoDecimal(discountedOrderSubTotal + tempAmount);
          } else if (cart.product.taxType.toString() == 'VAT') {
            if (Get.find<AuthController>().profileModel!.vatInfo!.status ==
                'true') {
              // vatAmount = vatAmount +
              //     ((tempAmount * double.parse(cart.product.tax.toString())) /
              //         100);

              if (Get.find<PosController>().isAddServiceCharge) {
                vatAmount = twoDecimal(vatAmount +
                    (((tempAmount) *
                            double.parse(cart.product.tax.toString())) /
                        100));
                foodVatAmount = twoDecimal((((tempAmount) *
                        double.parse(cart.product.tax.toString())) /
                    100));
                showServiceChargeValue = twoDecimal(showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100));
              } else {
                vatAmount = twoDecimal(vatAmount +
                    ((tempAmount * double.parse(cart.product.tax.toString())) /
                        100));
                foodVatAmount = twoDecimal(
                    (tempAmount * double.parse(cart.product.tax.toString())) /
                        100);
              }
            } else {
              if (Get.find<PosController>().isAddServiceCharge) {
                showServiceChargeValue = twoDecimal(showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100));
              }
            }
            discountedOrderSubTotal =
                twoDecimal(discountedOrderSubTotal + tempAmount);
          }
          var jsonData = {
            // "food_id": cart.product.id,
            // "quantity": cart.quantity,
            "food_amount": cart.isComplementry ? 0 : apiFoodAmount,
            "variation_amount": cart.isComplementry ? 0 : variationTotal,
            "addon_amount": cart.isComplementry ? 0 : addonsTotal,
            "gst_amount":
                cart.isComplementry ? 0 : foodGstAmount.toStringAsFixed(2),
            "vat_amount":
                cart.isComplementry ? 0 : foodVatAmount.toStringAsFixed(2),
            "discount_amount":
                cart.isComplementry ? 0 : discountFood.toStringAsFixed(2),
            'complementary_price':
                complementFoodTotal + addonsTotal + variationTotal,
            'is_complementary': cart.isComplementry == true ? 'Yes' : 'No',

            // "service_charge": foodServiceCharge.toStringAsFixed(2),
          };
          jsonCartList.add(jsonData);
        }
        // else {
        //   if (cart.product.taxType.toString() == 'GST') {
        //     gstTypeFood = gstTypeFood + foodAmount;
        //   } else if (cart.product.taxType.toString() == 'VAT') {
        //     vatTypeFood = vatTypeFood + foodAmount;
        //   }
        // }
      }

      if (selectedDiscountType == 'Fixed') {
        for (var i = 0; i < Get.find<CartController>().cartList.length; i++) {
          CartModel cart = Get.find<CartController>().cartList[i];

          double variationTotal = 0;
          double addonsTotal = 0;
          double foodAmount = 0;
          double apiFoodAmount = 0;
          double halfVariationPrice = 0;
          double foodGstAmount = 0;
          double foodVatAmount = 0;
          double discountFood = 0;
          double complementFoodTotal = 0;
          // double foodServiceCharge = 0;
          for (var addOn in cart.addOnIds) {
            if (addOn.quantity != 0) {
              addonsTotal = addonsTotal +
                  (((addOn.price ?? 0) * addOn.quantity) * cart.quantity);
              // index0 = index0 + 1;
            }
          }
          // if (cart.product.addOns != null) {
          //   for (var addOn in cart.product.addOns!) {
          //     if (ids.contains(addOn.id)) {
          //       addonsTotal = addonsTotal + ((addOn.price ?? 0) * qtys[index0]);
          //       index0 = index0 + 1;
          //     }
          //   }
          // }
          if (cart.variation.isNotEmpty) {
            for (int index = 0; index < cart.variation.length; index++) {
              if (cart.variation[index].isNotEmpty &&
                  cart.variation[index].contains(true)) {
                for (int i = 0; i < cart.variation[index].length; i++) {
                  if (cart.variation[index][i]) {
                    final variations = cart.product.variations;
                    if (variations != null &&
                        index < variations.length &&
                        variations[index].values != null &&
                        i < variations[index].values!.length) {
                      if ((variations[index].name ?? '').toUpperCase() ==
                          'HALFNHALF') {
                        final optionPrice =
                            variations[index].values![i].optionPrice ?? '0';
                        if (halfVariationPrice <
                            double.parse(optionPrice) * cart.quantity) {
                          halfVariationPrice =
                              double.parse(optionPrice) * cart.quantity;
                        }
                      } else {
                        final optionPrice =
                            variations[index].values![i].optionPrice ?? '0';
                        variationTotal +=
                            double.parse(optionPrice) * cart.quantity;
                      }
                    }
                  }
                }
                variationTotal = variationTotal + halfVariationPrice;
              }
            }
          }
          if ((Get.find<TableController>().selectedTable == null ||
              Get.find<TableController>().selectedTable!.tableNo ==
                  'Select Table')) {
            if (!cart.isComplementry) {
              foodAmount = twoDecimal((cart.product.price == 1
                          ? cart.discountedPrice
                          : cart.product.price)! *
                      cart.quantity +
                  variationTotal +
                  addonsTotal);
              apiFoodAmount = twoDecimal((cart.product.price == 1
                      ? cart.discountedPrice
                      : cart.product.price)! *
                  cart.quantity);
            }
            if (cart.isComplementry) {
              complementFoodTotal = twoDecimal((cart.product.price == 1
                      ? cart.discountedPrice
                      : cart.product.price)! *
                  cart.quantity);
            }
          } else if (Get.find<TableController>().selectedTable!.tableNo ==
              'Take Away') {
            // orderSubTotal = orderSubTotal +
            //     (cart.product.price == 1
            //             ? cart.discountedPrice
            //             : (cart.product.price! +
            //                 cart.product.takeAwayFoodPrice!)) *
            //         cart.quantity +
            //     variationTotal +
            //     addonsTotal;

            if (!cart.isComplementry) {
              foodAmount = twoDecimal((cart.product.price == 1
                          ? cart.discountedPrice
                          : (cart.product.price! +
                              cart.product.takeAwayFoodPrice!)) *
                      cart.quantity +
                  variationTotal +
                  addonsTotal);
              apiFoodAmount = twoDecimal((cart.product.price == 1
                      ? cart.discountedPrice
                      : (cart.product.price! +
                          cart.product.takeAwayFoodPrice!)) *
                  cart.quantity);
            }
            if (cart.isComplementry) {
              complementFoodTotal = twoDecimal((cart.product.price == 1
                      ? cart.discountedPrice
                      : (cart.product.price! +
                          cart.product.takeAwayFoodPrice!)) *
                  cart.quantity);
            }
          } else if (Get.find<TableController>().selectedTable!.tableNo ==
              'Delivery') {
            // orderSubTotal = orderSubTotal +
            //     (cart.product.price == 1
            //             ? cart.discountedPrice
            //             : (cart.product.price! +
            //                 cart.product.deliveryFoodPrice!)) *
            //         cart.quantity +
            //     variationTotal +
            //     addonsTotal;
            if (!cart.isComplementry) {
              foodAmount = twoDecimal((cart.product.price == 1
                          ? cart.discountedPrice
                          : (cart.product.price! +
                              cart.product.deliveryFoodPrice!)) *
                      cart.quantity +
                  variationTotal +
                  addonsTotal);
              apiFoodAmount = twoDecimal((cart.product.price == 1
                      ? cart.discountedPrice
                      : (cart.product.price! +
                          cart.product.deliveryFoodPrice!)) *
                  cart.quantity);
            }
            if (cart.isComplementry) {
              complementFoodTotal = twoDecimal((cart.product.price == 1
                      ? cart.discountedPrice
                      : (cart.product.price! +
                          cart.product.deliveryFoodPrice!)) *
                  cart.quantity);
            }
          } else {
            // orderSubTotal = orderSubTotal +
            //     (cart.product.price == 1
            //             ? cart.discountedPrice
            //             : cart.product.price)! *
            //         cart.quantity +
            //     variationTotal +
            //     addonsTotal;
            if (!cart.isComplementry) {
              foodAmount = twoDecimal((cart.product.price == 1
                          ? cart.discountedPrice
                          : cart.product.price)! *
                      cart.quantity +
                  variationTotal +
                  addonsTotal);
              apiFoodAmount = twoDecimal((cart.product.price == 1
                  ? cart.discountedPrice
                  : (cart.product.price)! * cart.quantity));
            }
            if (cart.isComplementry) {
              complementFoodTotal = twoDecimal((cart.product.price == 1
                  ? cart.discountedPrice
                  : (cart.product.price)! * cart.quantity));
            }
          }

          double enteredDiscount = _discountController.text.isEmpty
              ? 0
              : double.parse(_discountController.text);
          if (enteredDiscount > discountableItemTotal) {
            enteredDiscount = discountableItemTotal;
          }
          double tempDiscountPercent =
              (_discountController.text.isEmpty || discountableItemTotal == 0)
                  ? 0
                  : double.parse(
                      ((enteredDiscount / discountableItemTotal) * 100)
                          .toStringAsFixed(2));
          double tempAmount = 0;
          if (cart.product.giveDiscount.toString() == 'Yes') {
            tempAmount = twoDecimal(foodAmount -
                (foodAmount *
                    (coummunityDiscountPercentage + tempDiscountPercent) /
                    100));
            orderSubTotal = twoDecimal(orderSubTotal + tempAmount);

            orderDiscount = _discountController.text.isEmpty
                ? 0
                : twoDecimal(double.parse(_discountController.text));
            couponDiscount = twoDecimal(
                couponDiscount + (foodAmount * (tempDiscountPercent) / 100));
            discountFood = twoDecimal((foodAmount *
                (coummunityDiscountPercentage + tempDiscountPercent) /
                100));
          } else {
            tempAmount = twoDecimal(foodAmount);
            orderSubTotal = twoDecimal(orderSubTotal + tempAmount);
          }
          if (cart.product.taxType.toString() == 'GST') {
            if (restaurant.gstStatus == 'true') {
              //   gstAmount = gstAmount +
              //       ((tempAmount * double.parse(cart.product.tax.toString())) /
              //           100);
              // }
              if (Get.find<PosController>().isAddServiceCharge) {
                gstAmount = twoDecimal(gstAmount +
                    (((tempAmount) *
                            double.parse(cart.product.tax.toString())) /
                        100));
                showServiceChargeValue = twoDecimal(showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100));
                foodGstAmount = twoDecimal(
                    ((tempAmount) * double.parse(cart.product.tax.toString())) /
                        100);
              } else {
                gstAmount = twoDecimal(gstAmount +
                    ((tempAmount * double.parse(cart.product.tax.toString())) /
                        100));
                foodGstAmount = twoDecimal(
                    (tempAmount * double.parse(cart.product.tax.toString())) /
                        100);
              }
            } else {
              if (Get.find<PosController>().isAddServiceCharge) {
                showServiceChargeValue = twoDecimal(showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100));
              }
            }
            discountedOrderSubTotal =
                twoDecimal(discountedOrderSubTotal + tempAmount);
          } else if (cart.product.taxType.toString() == 'VAT') {
            if (Get.find<AuthController>().profileModel!.vatInfo!.status ==
                'true') {
              // vatAmount = vatAmount +
              //     ((tempAmount * double.parse(cart.product.tax.toString())) /
              //         100);

              if (Get.find<PosController>().isAddServiceCharge) {
                vatAmount = twoDecimal(vatAmount +
                    (((tempAmount) *
                            double.parse(cart.product.tax.toString())) /
                        100));
                foodVatAmount = twoDecimal(
                    ((tempAmount) * double.parse(cart.product.tax.toString())) /
                        100);
                showServiceChargeValue = twoDecimal(showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100));
              } else {
                vatAmount = twoDecimal(vatAmount +
                    ((tempAmount * double.parse(cart.product.tax.toString())) /
                        100));
                foodVatAmount = twoDecimal(
                    (tempAmount * double.parse(cart.product.tax.toString())) /
                        100);
              }
            } else {
              if (Get.find<PosController>().isAddServiceCharge) {
                showServiceChargeValue = twoDecimal(showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100));
              }
            }
            discountedOrderSubTotal =
                twoDecimal(discountedOrderSubTotal + tempAmount);
          }

          // else {
          //   if (cart.product.taxType.toString() == 'GST') {
          //     gstTypeFood = gstTypeFood + foodAmount;
          //   } else if (cart.product.taxType.toString() == 'VAT') {
          //     vatTypeFood = vatTypeFood + foodAmount;
          //   }
          // }
          var jsonData = {
            // "food_id": cart.product.id,
            // "quantity": cart.quantity,
            "food_amount": cart.isComplementry ? 0 : apiFoodAmount,
            "addon_amount": cart.isComplementry ? 0 : addonsTotal,
            "variation_amount": cart.isComplementry ? 0 : variationTotal,
            "gst_amount":
                cart.isComplementry ? 0 : foodGstAmount.toStringAsFixed(2),
            "vat_amount":
                cart.isComplementry ? 0 : foodVatAmount.toStringAsFixed(2),
            "discount_amount":
                cart.isComplementry ? 0 : discountFood.toStringAsFixed(2),
            'is_complementary': cart.isComplementry == true ? 'Yes' : 'No',
            'complementary_price': complementFoodTotal +
                addonsTotal +
                variationTotal // "service_charge": foodServiceCharge.toStringAsFixed(2),
          };
          jsonCartList.add(jsonData);
        }
      }
// //////////////////   Calculate GST and VAT and Discount if discount type is fixed or no
      // if (selectedDiscountType == 'No' || selectedDiscountType == 'Fixed') {
      //   double tempFoodAmount = 0;
      //   double tempBarAmount = 0;
      //   double tempDiscountPercent = _discountController.text.isEmpty
      //       ? 0
      //       : double.parse(_discountController.text) == 0
      //           ? 0
      //           : ((double.parse(_discountController.text) / gstTypeFood +
      //                   vatTypeFood) *
      //               100);
      //   tempBarAmount =
      //       vatTypeFood - ((vatTypeFood * tempDiscountPercent) / 100);
      //   tempFoodAmount =
      //       gstTypeFood - ((gstTypeFood * tempDiscountPercent) / 100);
      //   orderDiscount = ((gstTypeFood * tempDiscountPercent) / 100) +
      //       ((vatTypeFood * tempDiscountPercent) / 100);
      //   discountedOrderSubTotal = tempBarAmount + tempFoodAmount;
      //   if (restaurant.gstStatus == 'true') {
      //     //   gstAmount =
      //     //       gstAmount + ((tempFoodAmount * (restaurant.gstTax ?? 0)) / 100);
      //     if (Get.find<PosController>().isAddServiceCharge) {
      //       gstAmount = gstAmount +
      //           (((tempFoodAmount +
      //                       ((tempFoodAmount * serviceChargePercentage) /
      //                           100)) *
      //                   (restaurant.gstTax ?? 0)) /
      //               100);
      //       showServiceChargeValue = showServiceChargeValue +
      //           ((tempFoodAmount * serviceChargePercentage) / 100);
      //     } else {
      //       gstAmount = gstAmount +
      //           (((tempFoodAmount) * (restaurant.gstTax ?? 0)) / 100);
      //     }
      //   } else {
      //     if (Get.find<PosController>().isAddServiceCharge)
      //       showServiceChargeValue = showServiceChargeValue +
      //           ((tempFoodAmount * serviceChargePercentage) / 100);
      //   }

      //   if (Get.find<AuthController>().profileModel?.vatInfo?.status ==
      //       'true') {
      //     if (Get.find<PosController>().isAddServiceCharge) {
      //       vatAmount = vatAmount +
      //           (((tempBarAmount +
      //                       ((tempBarAmount * serviceChargePercentage) / 100)) *
      //                   (restaurant.tax ?? 0)) /
      //               100);
      //       showServiceChargeValue = showServiceChargeValue +
      //           ((tempBarAmount * serviceChargePercentage) / 100);
      //     } else {
      //       vatAmount =
      //           vatAmount + (((tempBarAmount) * (restaurant.tax ?? 0)) / 100);
      //     }

      //     // vatAmount =
      //     //     vatAmount + ((tempBarAmount * (restaurant.tax ?? 0)) / 100);
      //   } else {
      //     if (Get.find<PosController>().isAddServiceCharge)
      //       showServiceChargeValue = showServiceChargeValue +
      //           ((tempBarAmount * serviceChargePercentage) / 100);
      //   }
      // }

      if (discountedOrderSubTotal >= 0) {
        ////final calculation for addition of gst, vat, service charge
        // if (Get.find<PosController>().isAddServiceCharge) {
        //   showServiceChargeValue =
        //       (discountedOrderSubTotal * serviceChargePercentage) / 100;
        //   paidController.text = (discountedOrderSubTotal +
        //           (discountedOrderSubTotal * serviceChargePercentage / 100) +
        //           gstAmount +
        //           vatAmount +
        //           (_addTips.text.isEmpty ? 0 : double.parse(_addTips.text)))
        //       .toStringAsFixed(2);
        //   Get.find<PosController>().setcollectItemPrice(
        //       discountedOrderSubTotal +
        //           (discountedOrderSubTotal * serviceChargePercentage / 100) +
        //           gstAmount +
        //           vatAmount +
        //           (_addTips.text.isEmpty ? 0 : double.parse(_addTips.text)));
        // } else {
        double crmOffer = 0;
        if (widget.editOrder == null) {
          if (Get.find<CartController>().isApplyLoyalty &&
              !crmLoyaltyBelowMin &&
              crmLoyaltyDiscount > 0) {
            crmOffer += crmLoyaltyDiscount;
          }
          if (isCouponValidate && crmCouponRupee > 0) {
            crmOffer += crmCouponRupee;
          }
          if (crmOffer > discountedOrderSubTotal) {
            crmOffer = discountedOrderSubTotal;
          }
          if (crmOffer > 0 && discountedOrderSubTotal > 0) {
            final ratio =
                (discountedOrderSubTotal - crmOffer) / discountedOrderSubTotal;
            gstAmount = twoDecimal(gstAmount * ratio);
            vatAmount = twoDecimal(vatAmount * ratio);
            showServiceChargeValue =
                twoDecimal(showServiceChargeValue * ratio);
            for (final line in jsonCartList) {
              final lineGst =
                  double.tryParse('${line['gst_amount'] ?? 0}') ?? 0;
              final lineVat =
                  double.tryParse('${line['vat_amount'] ?? 0}') ?? 0;
              line['gst_amount'] =
                  twoDecimal(lineGst * ratio).toStringAsFixed(2);
              line['vat_amount'] =
                  twoDecimal(lineVat * ratio).toStringAsFixed(2);
            }
          }
        }
        if (_addTips.text.isNotEmpty) {
          tipTaxAmount = twoDecimal((double.parse(_addTips.text) *
                  restaurant.serviceChargeTaxPercent!) /
              100); //<-------------here we take serive charge gst on tip restaurant.tipTaxPercent! ---> restaurant.serviceChargeTaxPercent!
        }

        if (Get.find<PosController>().isAddServiceCharge) {
          gstServiceChargeTax = twoDecimal(
              (showServiceChargeValue * restaurant.serviceChargeTaxPercent!) /
                  100);
          // debugPrint('cart item gst service charge == > $gstServiceChargeTax');
        }
        if (deliveryCharge != 0 &&
            restaurant.settings!.gstDeliveryCharge != 0) {
          gstDeliveryChargeTax = twoDecimal(
              ((deliveryCharge * restaurant.settings!.gstDeliveryCharge!) /
                  100));
          gstAmount = twoDecimal(gstAmount +
              ((deliveryCharge * restaurant.settings!.gstDeliveryCharge!) /
                  100));
        }

        double addOrderAmount = (discountedOrderSubTotal - crmOffer) +
            showServiceChargeValue +
            gstAmount +
            vatAmount +
            gstServiceChargeTax +
            tipTaxAmount +
            deliveryCharge +
            (_addTips.text.isEmpty ? 0 : double.parse(_addTips.text));
        // if (Get.find<CartController>().isApplyLoyalty) {
        //   addOrderAmount = twoDecimal(addOrderAmount - usedLoyaltyPoint);
        // }
        // if (Get.find<CartController>().isApplyLoyalty &&
        //     !crmLoyaltyBelowMin &&
        //     crmLoyaltyDiscount > 0) {
        //   addOrderAmount = twoDecimal(addOrderAmount - crmLoyaltyDiscount);
        // }
        // if (isCouponValidate && crmCouponRupee > 0) {
        //   addOrderAmount = twoDecimal(addOrderAmount - crmCouponRupee);
        // }
        //// wallet used
        double tempWalletUsed = 0;
        double payable = twoDecimal(addOrderAmount);

        if (Get.find<CartController>().isApplyWallet) {
          // get wallet balance from controller (null-safe)
          double tempWalletBalance = walletBalance;

          if (tempWalletBalance >= payable) {
            // wallet covers whole amount
            tempWalletUsed = payable;
            payable = 0;
          } else {
            // wallet covers partial
            tempWalletUsed = tempWalletBalance;
            payable = payable - tempWalletBalance;
          }
          if (payable < 0) payable = 0;
        }

        // Round to 2 decimals if you'd like
        payable = double.parse(payable.toStringAsFixed(2));
        walletUsed = double.parse(tempWalletUsed.toStringAsFixed(2));
        paidController.text = restaurant.isTotalRound == 'Yes'
            ? '${getRoundUpValue(value: payable)}'
            : (payable).toStringAsFixed(2);
        Get.find<PosController>().setcollectItemPrice(
            twoDecimal(payable)); // existing method you already call
        if (widget.editOrder != null) editAmountCalculation();
        // Get.find<PosController>().setcollectItemPrice(addOrderAmount);
        // }
      } else {
        showErrorToast('Please enter valid discount');
      }
    }

    _scheduleCrmOffers();
    if (mounted) setState(() {});
  }

  void editAmountCalculation() {
    Restaurant restaurant =
        Get.find<AuthController>().profileModel!.restaurants!.first;
    double discountableItemTotal = 0;
    if (selectedDiscountType == 'Percent' &&
        _discountController.text.isNotEmpty &&
        double.parse(_discountController.text) > 100) {
      // showErrorToast('Please enter valid discount');
    } else {
      for (var i = 0; i < widget.editOrder!.orderDetails!.length; i++) {
        OrderDetails food = widget.editOrder!.orderDetails![i];

        double variationTotal = 0;
        double addonsTotal = 0;
        double foodAmount = 0;
        double halfVariationPrice = 0;

        if (food.variation != null && food.variation!.isNotEmpty) {
          for (int j = 0; j < food.variation!.length; j++) {
            final variation = food.variation![j];
            if (variation.values != null) {
              for (var element in variation.values!) {
                if ((variation.name ?? '').toUpperCase() == 'HALFNHALF') {
                  if (halfVariationPrice <
                      double.parse(element.optionPrice ?? '0') *
                          (food.quantity ?? 0)) {
                    halfVariationPrice =
                        double.parse(element.optionPrice ?? '0') *
                            (food.quantity ?? 0);
                  }
                } else {
                  variationTotal = variationTotal +
                      double.parse(element.optionPrice ?? '0') *
                          (food.quantity ?? 0);
                }
              }
            }
            variationTotal = variationTotal + halfVariationPrice;
          }
        }

        if (food.addOns != null) {
          for (var i = 0; i < food.addOns!.length; i++) {
            final addOn = food.addOns![i];
            addonsTotal = addonsTotal +
                (((addOn.price ?? 0) * (addOn.qty ?? 0)) *
                    (food.quantity ?? 0));
          }
        }
        if (food.foodDetails!.name.toString().toLowerCase() != 'check in' &&
            food.foodStatus != 3) {
          orderItemTotal = twoDecimal(orderItemTotal +
              (food.unitPrice ?? 0) * (food.quantity ?? 0) +
              variationTotal +
              addonsTotal);
          foodAmount = twoDecimal((food.unitPrice ?? 0) * (food.quantity ?? 0) +
              variationTotal +
              addonsTotal);
          if (food.foodDetails!.giveDiscount.toString() == 'Yes') {
            discountableItemTotal =
                twoDecimal(discountableItemTotal + foodAmount);
          }
        }

        if (selectedDiscountType == 'Percent' || selectedDiscountType == 'No') {
          double tempDiscountPercent = selectedDiscountType == 'No'
              ? 0
              : _discountController.text.isEmpty
                  ? 0
                  : double.parse(_discountController.text);
          double tempAmount = 0;
          if (food.foodDetails!.giveDiscount.toString() == 'Yes') {
            tempAmount = twoDecimal(foodAmount -
                (foodAmount *
                    (coummunityDiscountPercentage + tempDiscountPercent) /
                    100));
            orderSubTotal = twoDecimal(orderSubTotal + tempAmount);

            orderDiscount = twoDecimal(orderDiscount +
                (foodAmount *
                    (coummunityDiscountPercentage + tempDiscountPercent) /
                    100));
            couponDiscount = twoDecimal(
                couponDiscount + (foodAmount * (tempDiscountPercent) / 100));
          } else {
            tempAmount = twoDecimal(foodAmount);
            orderSubTotal = twoDecimal(orderSubTotal + tempAmount);
          }
          if (food.foodDetails!.taxType.toString() == 'GST') {
            // debugPrint('food detail tax type is =====> GST');
            if (restaurant.gstStatus == 'true') {
              // debugPrint('resturant gst status =====> true');
              //   gstAmount = gstAmount +
              //       ((tempAmount * double.parse(cart.product.tax.toString())) /
              //           100);
              // }
              if (Get.find<PosController>().isAddServiceCharge) {
                // debugPrint('gst add serive charge  =====> true');
                gstAmount = twoDecimal(gstAmount +
                    (((tempAmount) *
                            double.parse(food.foodDetails!.tax.toString())) /
                        100));
                showServiceChargeValue = twoDecimal(showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100));
                // debugPrint('gst serive charge value  =====> $showServiceChargeValue');
              } else {
                // debugPrint('gst add serive charge  =====> fasle');
                gstAmount = twoDecimal(gstAmount +
                    ((tempAmount *
                            double.parse(food.foodDetails!.tax.toString())) /
                        100));
              }
            } else {
              // debugPrint('resturant gst status =====> false');
              if (Get.find<PosController>().isAddServiceCharge) {
                showServiceChargeValue = twoDecimal(showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100));
              }
            }
            discountedOrderSubTotal =
                twoDecimal(discountedOrderSubTotal + tempAmount);
          } else if (food.foodDetails!.taxType.toString() == 'VAT') {
            // debugPrint('food detail tax type is =====>  VAT');
            if (Get.find<AuthController>().profileModel!.vatInfo!.status ==
                'true') {
              // debugPrint('resturant vat status =====> true');
              // vatAmount = vatAmount +
              //     ((tempAmount * double.parse(cart.product.tax.toString())) /
              //         100);

              if (Get.find<PosController>().isAddServiceCharge) {
                // debugPrint('vat add serive charge  =====> true');
                vatAmount = twoDecimal(vatAmount +
                    (((tempAmount) *
                            double.parse(food.foodDetails!.tax.toString())) /
                        100));
                showServiceChargeValue = twoDecimal(showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100));
                // debugPrint('vat serive charge value  =====> $showServiceChargeValue');
              } else {
                // debugPrint('vat add serive charge  =====> false');
                vatAmount = twoDecimal(vatAmount +
                    ((tempAmount *
                            double.parse(food.foodDetails!.tax.toString())) /
                        100));
              }
            } else {
              // debugPrint('resturant vat status =====> false');
              if (Get.find<PosController>().isAddServiceCharge) {
                showServiceChargeValue = twoDecimal(showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100));
              }
            }
            discountedOrderSubTotal =
                twoDecimal(discountedOrderSubTotal + tempAmount);
          }
        }
        // else {
        //   if (cart.product.taxType.toString() == 'GST') {
        //     gstTypeFood = gstTypeFood + foodAmount;
        //   } else if (cart.product.taxType.toString() == 'VAT') {
        //     vatTypeFood = vatTypeFood + foodAmount;
        //   }
        // }
      }

      if (selectedDiscountType == 'Fixed') {
        for (var i = 0; i < widget.editOrder!.orderDetails!.length; i++) {
          OrderDetails food = widget.editOrder!.orderDetails![i];

          double variationTotal = 0;
          double addonsTotal = 0;
          double foodAmount = 0;
          double halfVariationPrice = 0;

          if (food.variation != null && food.variation!.isNotEmpty) {
            for (int j = 0; j < food.variation!.length; j++) {
              final variation = food.variation![j];
              if (variation.values != null) {
                for (var element in variation.values!) {
                  if ((variation.name ?? '').toUpperCase() == 'HALFNHALF') {
                    if (halfVariationPrice <
                        double.parse(element.optionPrice ?? '0') *
                            (food.quantity ?? 0)) {
                      halfVariationPrice =
                          double.parse(element.optionPrice ?? '0') *
                              (food.quantity ?? 0);
                    }
                  } else {
                    variationTotal = variationTotal +
                        double.parse(element.optionPrice ?? '0') *
                            (food.quantity ?? 0);
                  }
                }
              }
              variationTotal = variationTotal + halfVariationPrice;
            }
          }

          if (food.addOns != null) {
            for (var i = 0; i < food.addOns!.length; i++) {
              final addOn = food.addOns![i];
              addonsTotal = addonsTotal +
                  (((addOn.price ?? 0) * (addOn.qty ?? 0)) *
                      (food.quantity ?? 0));
            }
          }
          if (food.foodDetails!.name.toString().toLowerCase() != 'check in' &&
              food.foodStatus != 3) {
            // orderItemTotal = twoDecimal(orderItemTotal +
            //     (food.unitPrice ?? 0) * (food.quantity ?? 0) +
            //     variationTotal +
            //     addonsTotal);
            foodAmount = twoDecimal(
                (food.unitPrice ?? 0) * (food.quantity ?? 0) +
                    variationTotal +
                    addonsTotal);
          }

          double enteredDiscount = _discountController.text.isEmpty
              ? 0
              : double.parse(_discountController.text);
          if (enteredDiscount > discountableItemTotal) {
            enteredDiscount = discountableItemTotal;
          }
          double tempDiscountPercent =
              (_discountController.text.isEmpty || discountableItemTotal == 0)
                  ? 0
                  : double.parse(
                      ((enteredDiscount / discountableItemTotal) * 100)
                          .toStringAsFixed(2));
          double tempAmount = 0;
          if (food.foodDetails!.giveDiscount.toString() == 'Yes') {
            tempAmount = twoDecimal(foodAmount -
                (foodAmount *
                    (coummunityDiscountPercentage + tempDiscountPercent) /
                    100));
            orderSubTotal = twoDecimal(orderSubTotal + tempAmount);

            orderDiscount = _discountController.text.isEmpty
                ? 0
                : twoDecimal(double.parse(_discountController.text));
            couponDiscount = twoDecimal(
                couponDiscount + (foodAmount * (tempDiscountPercent) / 100));
          } else {
            tempAmount = twoDecimal(foodAmount);
            orderSubTotal = twoDecimal(orderSubTotal + tempAmount);
          }
          if (food.foodDetails!.taxType.toString() == 'GST') {
            if (restaurant.gstStatus == 'true') {
              //   gstAmount = gstAmount +
              //       ((tempAmount * double.parse(cart.product.tax.toString())) /
              //           100);
              // }
              if (Get.find<PosController>().isAddServiceCharge) {
                gstAmount = twoDecimal(gstAmount +
                    (((tempAmount) *
                            double.parse(food.foodDetails!.tax.toString())) /
                        100));
                showServiceChargeValue = twoDecimal(showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100));
              } else {
                gstAmount = twoDecimal(gstAmount +
                    ((tempAmount *
                            double.parse(food.foodDetails!.tax.toString())) /
                        100));
              }
            } else {
              if (Get.find<PosController>().isAddServiceCharge) {
                showServiceChargeValue = twoDecimal(showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100));
              }
            }
            discountedOrderSubTotal =
                twoDecimal(discountedOrderSubTotal + tempAmount);
          } else if (food.foodDetails!.taxType.toString() == 'VAT') {
            if (Get.find<AuthController>().profileModel!.vatInfo!.status ==
                'true') {
              // vatAmount = vatAmount +
              //     ((tempAmount * double.parse(cart.product.tax.toString())) /
              //         100);

              if (Get.find<PosController>().isAddServiceCharge) {
                vatAmount = twoDecimal(vatAmount +
                    (((tempAmount) *
                            double.parse(food.foodDetails!.tax.toString())) /
                        100));

                showServiceChargeValue = twoDecimal(showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100));
              } else {
                vatAmount = twoDecimal(vatAmount +
                    ((tempAmount *
                            double.parse(food.foodDetails!.tax.toString())) /
                        100));
              }
            } else {
              if (Get.find<PosController>().isAddServiceCharge) {
                showServiceChargeValue = twoDecimal(showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100));
              }
            }
            discountedOrderSubTotal =
                twoDecimal(discountedOrderSubTotal + tempAmount);
          }
        }
      }

      if (discountedOrderSubTotal >= 0) {
        double crmOffer = 0;
        if (Get.find<CartController>().isApplyLoyalty &&
            !crmLoyaltyBelowMin &&
            crmLoyaltyDiscount > 0) {
          crmOffer += crmLoyaltyDiscount;
        }
        if (isCouponValidate && crmCouponRupee > 0) {
          crmOffer += crmCouponRupee;
        }
        if (crmOffer > discountedOrderSubTotal) {
          crmOffer = discountedOrderSubTotal;
        }
        if (crmOffer > 0 && discountedOrderSubTotal > 0) {
          final ratio =
              (discountedOrderSubTotal - crmOffer) / discountedOrderSubTotal;
          double deliveryGst = 0;
          if (deliveryCharge != 0 &&
              restaurant.settings!.gstDeliveryCharge != 0) {
            deliveryGst = twoDecimal(
                (deliveryCharge * restaurant.settings!.gstDeliveryCharge!) /
                    100);
          }
          double foodGst = gstAmount - deliveryGst;
          if (foodGst < 0) foodGst = 0;
          gstAmount = twoDecimal((foodGst * ratio) + deliveryGst);
          vatAmount = twoDecimal(vatAmount * ratio);
          showServiceChargeValue = twoDecimal(showServiceChargeValue * ratio);
          for (final line in jsonCartList) {
            final lineGst = double.tryParse('${line['gst_amount'] ?? 0}') ?? 0;
            final lineVat = double.tryParse('${line['vat_amount'] ?? 0}') ?? 0;
            line['gst_amount'] = twoDecimal(lineGst * ratio).toStringAsFixed(2);
            line['vat_amount'] = twoDecimal(lineVat * ratio).toStringAsFixed(2);
          }
        }
        if (_addTips.text.isNotEmpty) {
          tipTaxAmount = twoDecimal((double.parse(_addTips.text) *
                  restaurant.serviceChargeTaxPercent!) /
              100); //<-------------here we take serive charge gst on tip restaurant.tipTaxPercent! ---> restaurant.serviceChargeTaxPercent!
        }

        if (Get.find<PosController>().isAddServiceCharge) {
          // debugPrint(' gst on serive charge  =====> $gstServiceChargeTax');
          // debugPrint(' serive charge value  =====> $showServiceChargeValue');
          // gstServiceChargeTax = twoDecimal((gstServiceChargeTax +
          //     (showServiceChargeValue * restaurant.serviceChargeTaxPercent!) /
          //         100));
          gstServiceChargeTax = twoDecimal(
              ((showServiceChargeValue * restaurant.serviceChargeTaxPercent!) /
                  100));
          // debugPrint( '18% tax on service charge serive charge  =====> $gstServiceChargeTax');
        }
        // GST on Delivery Charge - Only for NEW orders (Prevent double charging in Edit Mode)
        if (deliveryCharge != 0 &&
            restaurant.settings!.gstDeliveryCharge != 0 &&
            widget.editOrder == null)
          gstAmount = twoDecimal(gstAmount +
              ((deliveryCharge * restaurant.settings!.gstDeliveryCharge!) /
                  100));

        double addOrderAmount = (discountedOrderSubTotal - crmOffer) +
            showServiceChargeValue +
            gstAmount +
            vatAmount +
            gstServiceChargeTax +
            tipTaxAmount +
            deliveryCharge +
            (_addTips.text.isEmpty ? 0 : double.parse(_addTips.text));
        // if (Get.find<CartController>().isApplyLoyalty) {
        //   addOrderAmount = twoDecimal(addOrderAmount - usedLoyaltyPoint);
        // }
        // if (Get.find<CartController>().isApplyLoyalty &&
        //     !crmLoyaltyBelowMin &&
        //     crmLoyaltyDiscount > 0) {
        //   addOrderAmount = twoDecimal(addOrderAmount - crmLoyaltyDiscount);
        // }
        // if (isCouponValidate && crmCouponRupee > 0) {
        //   addOrderAmount = twoDecimal(addOrderAmount - crmCouponRupee);
        // }
        //// wallet used
        double tempWalletUsed = 0;
        double payable = twoDecimal(addOrderAmount);

        if (Get.find<CartController>().isApplyWallet) {
          // get wallet balance from controller (null-safe)
          double tempWalletBalance = walletBalance;

          if (tempWalletBalance >= payable) {
            // wallet covers whole amount
            tempWalletUsed = payable;
            payable = 0;
          } else {
            // wallet covers partial
            tempWalletUsed = tempWalletBalance;
            payable = payable - tempWalletBalance;
          }
          if (payable < 0) payable = 0;
        }

        // Round to 2 decimals if you'd like
        payable = double.parse(payable.toStringAsFixed(2));
        walletUsed = double.parse(tempWalletUsed.toStringAsFixed(2));
        paidController.text = restaurant.isTotalRound == 'Yes'
            ? '${getRoundUpValue(value: payable)}'
            : (payable).toStringAsFixed(2);
        print(payable);
        Get.find<PosController>().setcollectItemPrice(
            twoDecimal(payable)); // existing method you already call
      } else {
        showErrorToast('Please enter valid discount');
      }
    }

    if (mounted) setState(() {});
  }

  showPaymentDetail() {
    return GetBuilder<PosController>(builder: (posController) {
      return GetBuilder<CartController>(builder: (cartController) {
        return posController.isLoading || cartController.isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 15, right: 15,
                      top: Dimensions.PADDING_SIZE_DEFAULT,
                      bottom: Dimensions.PADDING_SIZE_SMALL,
                      // left: Dimensions.PADDING_SIZE_DEFAULT,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: ColorTheme.bgSettleCardGreyColor),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(
                                  Get.find<AuthController>()
                                          .profileModel
                                          ?.restaurants
                                          ?.first
                                          .paymentModes
                                          ?.length ??
                                      0,
                                  (index) {
                                    PaymentModes? item =
                                        Get.find<AuthController>()
                                            .profileModel
                                            ?.restaurants
                                            ?.first
                                            .paymentModes![index];

                                    // ROOM condition (same as your existing logic)
                                    // if (item!.name!.toLowerCase() == 'room') {
                                    //   final isRoomAllowed = widget.editOrder ==
                                    //           null ||
                                    //       (widget.editOrder != null &&
                                    //           (widget.editOrder!.orderType !=
                                    //                   'delivery' &&
                                    //               widget.editOrder!.orderType !=
                                    //                   'take_away' &&
                                    //               (widget.editOrder!
                                    //                           .restaurantTable !=
                                    //                       null &&
                                    //                   widget
                                    //                           .editOrder!
                                    //                           .restaurantTable!
                                    //                           .rtype ==
                                    //                       'RM')));

                                    // if (!isRoomAllowed)
                                    //   return const SizedBox.shrink();
                                    // }
                                    if (item!.isPrepaid == 0) {
                                      return const SizedBox.shrink();
                                    }

                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();

                                        // Reset only when needed
                                        pCash.text = '0';
                                        pCard.text = '0';
                                        pUpi.text = '0';

                                        posController
                                            .setPaymentTabName(item.name!);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 5),
                                        padding: EdgeInsets.symmetric(
                                            vertical: Dimensions
                                                .PADDING_SIZE_EXTRA_SMALL,
                                            horizontal: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: posController.paymentTab ==
                                                    item.name
                                                ? Colors.transparent
                                                : ColorTheme.borderGrey,
                                          ),
                                          color: posController.paymentTab ==
                                                  item.name
                                              ? ColorTheme.appColor
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        child: Center(
                                          child: Text(
                                            item.displayName ?? '',
                                            style: poppinsMedium.copyWith(
                                              fontSize: 13,
                                              color: posController.paymentTab ==
                                                      item.name
                                                  ? Colors.white
                                                  : ColorTheme.appColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // SingleChildScrollView(
                            //   scrollDirection: Axis.horizontal,
                            //   child: Row(
                            //     children: [
                            //       if (Get.find<AuthController>()
                            //               .profileModel!
                            //               .restaurants!
                            //               .first
                            //               .payCash ==
                            //           'Yes')
                            //         SizedBox(
                            //           width: Get.width * 0.16,
                            //           child: InkWell(
                            //             splashColor: Colors.transparent,
                            //             hoverColor: Colors.transparent,
                            //             highlightColor: Colors.transparent,
                            //             onTap: () {
                            //               FocusManager.instance.primaryFocus
                            //                   ?.unfocus();
                            //               pCash.text = '0';
                            //               pCard.text = '0';
                            //               pUpi.text = '0';
                            //               posController.setPaymentTabIndex(0);
                            //             },
                            //             child: Container(
                            //               width: Get.width,
                            //               margin: EdgeInsets.only(right: 5),
                            //               padding: EdgeInsets.symmetric(
                            //                   vertical: Dimensions
                            //                       .PADDING_SIZE_EXTRA_SMALL),
                            //               decoration: BoxDecoration(
                            //                   border: Border.all(
                            //                       color: posController
                            //                                   .selectedPaymentTab ==
                            //                               0
                            //                           ? Colors.transparent
                            //                           : ColorTheme.borderGrey),
                            //                   color: posController
                            //                               .selectedPaymentTab ==
                            //                           0
                            //                       ? ColorTheme.appColor
                            //                       : Colors.transparent,
                            //                   // border:
                            //                   //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                            //                   borderRadius:
                            //                       BorderRadius.circular(7)),
                            //               child: Center(
                            //                 child: Text(
                            //                   'Cash'.tr,
                            //                   style: poppinsMedium.copyWith(
                            //                       fontSize: 13,
                            //                       color: posController
                            //                                   .selectedPaymentTab ==
                            //                               0
                            //                           ? Colors.white
                            //                           : ColorTheme.appColor),
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //         ),
                            //       if (Get.find<AuthController>()
                            //               .profileModel!
                            //               .restaurants!
                            //               .first
                            //               .payCC ==
                            //           'Yes')
                            //         SizedBox(
                            //           width: Get.width * 0.16,
                            //           child: InkWell(
                            //             splashColor: Colors.transparent,
                            //             hoverColor: Colors.transparent,
                            //             highlightColor: Colors.transparent,
                            //             onTap: () {
                            //               FocusManager.instance.primaryFocus
                            //                   ?.unfocus();
                            //               pCash.text = '0';
                            //               pCard.text = '0';
                            //               pUpi.text = '0';
                            //               posController.setPaymentTabIndex(1);
                            //             },
                            //             child: Container(
                            //               width: Get.width,
                            //               margin: EdgeInsets.only(right: 5),
                            //               padding: EdgeInsets.symmetric(
                            //                   vertical: Dimensions
                            //                       .PADDING_SIZE_EXTRA_SMALL),
                            //               decoration: BoxDecoration(
                            //                   border: Border.all(
                            //                       color: posController
                            //                                   .selectedPaymentTab ==
                            //                               1
                            //                           ? Colors.transparent
                            //                           : ColorTheme.borderGrey),
                            //                   color: posController
                            //                               .selectedPaymentTab ==
                            //                           1
                            //                       ? ColorTheme.appColor
                            //                       : Colors.transparent,
                            //                   borderRadius:
                            //                       BorderRadius.circular(7)),
                            //               child: Center(
                            //                 child: Text(
                            //                   'Card'.tr,
                            //                   style: poppinsMedium.copyWith(
                            //                       fontSize: 13,
                            //                       color: posController
                            //                                   .selectedPaymentTab ==
                            //                               1
                            //                           ? Colors.white
                            //                           : ColorTheme.appColor),
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //         ),
                            //       if (Get.find<AuthController>()
                            //               .profileModel!
                            //               .restaurants!
                            //               .first
                            //               .payUpi ==
                            //           'Yes')
                            //         SizedBox(
                            //           width: Get.width * 0.16,
                            //           child: InkWell(
                            //             splashColor: Colors.transparent,
                            //             hoverColor: Colors.transparent,
                            //             highlightColor: Colors.transparent,
                            //             onTap: () {
                            //               FocusManager.instance.primaryFocus
                            //                   ?.unfocus();
                            //               pCash.text = '0';
                            //               pCard.text = '0';
                            //               pUpi.text = '0';
                            //               posController.setPaymentTabIndex(2);
                            //             },
                            //             child: Container(
                            //               width: Get.width,
                            //               margin: EdgeInsets.only(right: 5),
                            //               padding: EdgeInsets.symmetric(
                            //                   vertical: Dimensions
                            //                       .PADDING_SIZE_EXTRA_SMALL),
                            //               decoration: BoxDecoration(
                            //                   border: Border.all(
                            //                       color: posController
                            //                                   .selectedPaymentTab ==
                            //                               2
                            //                           ? Colors.transparent
                            //                           : ColorTheme.borderGrey),
                            //                   color: posController
                            //                               .selectedPaymentTab ==
                            //                           2
                            //                       ? ColorTheme.appColor
                            //                       : Colors.transparent,

                            //                   // border:
                            //                   //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                            //                   borderRadius:
                            //                       BorderRadius.circular(7)),
                            //               child: Center(
                            //                 child: Text(
                            //                   'UPI'.tr,
                            //                   style: poppinsMedium.copyWith(
                            //                       fontSize: 13,
                            //                       color: posController
                            //                                   .selectedPaymentTab ==
                            //                               2
                            //                           ? Colors.white
                            //                           : ColorTheme.appColor),
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //         ),
                            //       if (Get.find<AuthController>()
                            //               .profileModel!
                            //               .restaurants!
                            //               .first
                            //               .payTab ==
                            //           'Yes')
                            //         SizedBox(
                            //           width: Get.width * 0.16,
                            //           child: InkWell(
                            //             splashColor: Colors.transparent,
                            //             hoverColor: Colors.transparent,
                            //             highlightColor: Colors.transparent,
                            //             onTap: () {
                            //               FocusManager.instance.primaryFocus
                            //                   ?.unfocus();
                            //               pCash.text = '0';
                            //               pCard.text = '0';
                            //               pUpi.text = '0';
                            //               posController.setPaymentTabIndex(3);
                            //             },
                            //             child: Container(
                            //               width: Get.width,
                            //               margin: EdgeInsets.only(right: 5),
                            //               padding: EdgeInsets.symmetric(
                            //                   // horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                            //                   vertical: Dimensions
                            //                       .PADDING_SIZE_EXTRA_SMALL),
                            //               decoration: BoxDecoration(
                            //                   border: Border.all(
                            //                       color: posController
                            //                                   .selectedPaymentTab ==
                            //                               3
                            //                           ? Colors.transparent
                            //                           : ColorTheme.borderGrey),
                            //                   color: posController
                            //                               .selectedPaymentTab ==
                            //                           3
                            //                       ? ColorTheme.appColor
                            //                       : Colors.transparent,

                            //                   // border:
                            //                   //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                            //                   borderRadius:
                            //                       BorderRadius.circular(7)),
                            //               child: Center(
                            //                 child: Text(
                            //                   'Credit',
                            //                   style: poppinsMedium.copyWith(
                            //                       fontSize: 13,
                            //                       color: posController
                            //                                   .selectedPaymentTab ==
                            //                               3
                            //                           ? Colors.white
                            //                           : ColorTheme.appColor),
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //         ),
                            //       if (Get.find<AuthController>()
                            //               .profileModel!
                            //               .restaurants!
                            //               .first
                            //               .showRoom ==
                            //           'Yes')
                            //         SizedBox(
                            //           width: Get.width * 0.16,
                            //           child: InkWell(
                            //             splashColor: Colors.transparent,
                            //             hoverColor: Colors.transparent,
                            //             highlightColor: Colors.transparent,
                            //             onTap: () {
                            //               FocusManager.instance.primaryFocus
                            //                   ?.unfocus();
                            //               pCash.text = '0';
                            //               pCard.text = '0';
                            //               pUpi.text = '0';
                            //               posController.setPaymentTabIndex(4);
                            //             },
                            //             child: Container(
                            //               width: Get.width,
                            //               margin: EdgeInsets.only(right: 5),
                            //               padding: EdgeInsets.symmetric(
                            //                   vertical: Dimensions
                            //                       .PADDING_SIZE_EXTRA_SMALL),
                            //               decoration: BoxDecoration(
                            //                   border: Border.all(
                            //                       color: posController
                            //                                   .selectedPaymentTab ==
                            //                               4
                            //                           ? Colors.transparent
                            //                           : ColorTheme.borderGrey),
                            //                   color: posController
                            //                               .selectedPaymentTab ==
                            //                           4
                            //                       ? ColorTheme.appColor
                            //                       : Colors.transparent,

                            //                   // border:
                            //                   //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                            //                   borderRadius:
                            //                       BorderRadius.circular(7)),
                            //               child: Center(
                            //                 child: Text(
                            //                   'Room'.tr,
                            //                   style: poppinsMedium.copyWith(
                            //                       fontSize: 13,
                            //                       color: posController
                            //                                   .selectedPaymentTab ==
                            //                               4
                            //                           ? Colors.white
                            //                           : ColorTheme.appColor),
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //         ),
                            //       SizedBox(
                            //         width: Get.width * 0.16,
                            //         child: InkWell(
                            //           splashColor: Colors.transparent,
                            //           hoverColor: Colors.transparent,
                            //           highlightColor: Colors.transparent,
                            //           onTap: () {
                            //             FocusManager.instance.primaryFocus
                            //                 ?.unfocus();

                            //             posController.setPaymentTabIndex(5);
                            //           },
                            //           child: Container(
                            //             width: Get.width,
                            //             margin: EdgeInsets.only(right: 5),
                            //             padding: EdgeInsets.symmetric(
                            //                 vertical: Dimensions
                            //                     .PADDING_SIZE_EXTRA_SMALL),
                            //             decoration: BoxDecoration(
                            //                 border: Border.all(
                            //                     color: posController
                            //                                 .selectedPaymentTab ==
                            //                             5
                            //                         ? Colors.transparent
                            //                         : ColorTheme.borderGrey),
                            //                 color: posController
                            //                             .selectedPaymentTab ==
                            //                         5
                            //                     ? ColorTheme.appColor
                            //                     : Colors.transparent,

                            //                 // border:
                            //                 //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                            //                 borderRadius:
                            //                     BorderRadius.circular(7)),
                            //             child: Center(
                            //               child: Text(
                            //                 'Partial',
                            //                 style: poppinsMedium.copyWith(
                            //                     fontSize: 13,
                            //                     color: posController
                            //                                 .selectedPaymentTab ==
                            //                             5
                            //                         ? Colors.white
                            //                         : ColorTheme.appColor),
                            //               ),
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),

                            SizedBox(height: 15),
                            DottedLine(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.center,
                              lineThickness: 1.0,
                              dashLength: 2.5,
                              dashColor: ColorTheme.hintText,
                            ),

                            Get.find<PosController>()
                                        .paymentTab
                                        .toLowerCase() ==
                                    'room'
                                ? posController.roomList.isNotEmpty
                                    ? Column(
                                        children: [
                                          Container(
                                            height: 30,
                                            margin: EdgeInsets.only(
                                                top: 20, bottom: 15),
                                            // width: Get.width * 0.8,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .PADDING_SIZE_SMALL),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: ColorTheme.borderGrey),
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: DropdownButton<
                                                GetRoomListResponse>(
                                              isExpanded: true,
                                              icon: Icon(
                                                Icons.keyboard_arrow_down,
                                                color: ColorTheme.appColor,
                                              ),
                                              value: posController
                                                          .selectedRoom ==
                                                      null
                                                  ? posController.roomList.first
                                                  : posController.selectedRoom,
                                              items: posController.roomList.map(
                                                  (GetRoomListResponse value) {
                                                return DropdownMenuItem<
                                                    GetRoomListResponse>(
                                                  value: value,
                                                  child: Text(
                                                    '${value.table!.title} ${value.table!.tableNo}',
                                                    maxLines: 1,
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      color:
                                                          value.table!.id == 0
                                                              ? Colors.grey
                                                              : Colors.black,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged:
                                                  (GetRoomListResponse? value) {
                                                posController
                                                    .setRoomIndex(value);

                                                if (value!.user != null) {
                                                  _nameController.clear();
                                                  _phoneController.clear();
                                                  if (value.user!.fName != '') {
                                                    _nameController.text =
                                                        value.user!.fName;
                                                  }
                                                }
                                                if (value.user != null) {
                                                  if (value.user!.phone != '') {
                                                    _phoneController.text =
                                                        value.user!.phone;
                                                  }
                                                }
                                              },
                                              underline: SizedBox(),
                                            ),
                                          ),
                                          SizedBox(height: 15),
                                          nameTextField(context),
                                          SizedBox(height: 15),
                                          phoneTextField(context),
                                        ],
                                      )
                                    : SizedBox.shrink()
                                : Container(
                                    margin: EdgeInsets.only(
                                      top: Dimensions.PADDING_SIZE_LARGE,
                                    ),
                                    child: Column(
                                      children: [
                                        Get.find<PosController>()
                                                    .paymentTab
                                                    .toLowerCase() ==
                                                'cash'
                                            ? Column(
                                                children: [
                                                  Container(
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            color: ColorTheme
                                                                .borderGrey)),
                                                    child: TextField(
                                                      controller:
                                                          paidController,
                                                      keyboardType: TextInputType
                                                          .numberWithOptions(
                                                              signed: true),
                                                      decoration:
                                                          InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          borderSide: BorderSide(
                                                              style: BorderStyle
                                                                  .none,
                                                              width: 0),
                                                        ),
                                                        hintStyle: poppinsMedium
                                                            .copyWith(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .grey),
                                                        filled: true,
                                                        hintText: 'Paid',
                                                        fillColor: Colors.white,
                                                      ),
                                                      style: poppinsMedium
                                                          .copyWith(
                                                        color: Colors.black,
                                                        fontSize: 13,
                                                      ),
                                                      onChanged: (value) async {
                                                        if (paidController
                                                            .text.isEmpty) {
                                                          changeController
                                                              .text = '';
                                                        } else {
                                                          if (double.parse(
                                                                  paidController
                                                                      .text) >
                                                              (posController
                                                                  .collectItemPrice)) {
                                                            changeController
                                                                    .text =
                                                                '${(double.parse(paidController.text) - posController.collectItemPrice).toStringAsFixed(2)}';
                                                          } else {
                                                            changeController
                                                                .text = '0';
                                                          }
                                                        }
                                                        // posController.update();
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(height: 15),
                                                  Container(
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .circular(Dimensions
                                                                .RADIUS_SMALL),
                                                        border: Border.all(
                                                            color: ColorTheme
                                                                .borderGrey)),
                                                    child: TextField(
                                                      controller:
                                                          changeController,
                                                      autofocus: false,
                                                      readOnly: true,
                                                      decoration:
                                                          InputDecoration(
                                                              contentPadding:
                                                                  EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                borderSide: BorderSide(
                                                                    style:
                                                                        BorderStyle
                                                                            .none,
                                                                    width: 0),
                                                              ),
                                                              hintStyle: poppinsMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .grey),
                                                              filled: true,
                                                              fillColor:
                                                                  Colors.white,
                                                              hintText:
                                                                  'Change'),
                                                      style: poppinsMedium
                                                          .copyWith(
                                                        color: Colors.black,
                                                        fontSize: 13,
                                                      ),
                                                      onChanged:
                                                          (value) async {},
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : SizedBox.shrink(),
                                        Get.find<PosController>()
                                                    .paymentTab
                                                    .toLowerCase() ==
                                                'card'
                                            ? Container(
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(
                                                        color: ColorTheme
                                                            .borderGrey)),
                                                child: TextField(
                                                  controller:
                                                      _transactionNoController,
                                                  autofocus: false,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      borderSide: BorderSide(
                                                          style:
                                                              BorderStyle.none,
                                                          width: 0),
                                                    ),
                                                    hintStyle:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 13,
                                                            color: Colors.grey),
                                                    hintText: 'Transaction No.',
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
                                                  style: poppinsMedium.copyWith(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                  ),
                                                  onChanged: (value) async {},
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                        if (Get.find<PosController>()
                                                .paymentTab
                                                .toLowerCase() ==
                                            'tab')
                                          nameTextField(context),
                                        if (Get.find<PosController>()
                                                .paymentTab
                                                .toLowerCase() ==
                                            'tab')
                                          SizedBox(height: 15),
                                        if (Get.find<PosController>()
                                                .paymentTab
                                                .toLowerCase() ==
                                            'tab')
                                          phoneTextField(context),
                                        Get.find<PosController>()
                                                        .paymentTab
                                                        .toLowerCase() ==
                                                    'upi' &&
                                                Get.find<AuthController>()
                                                        .profileModel!
                                                        .restaurants!
                                                        .first
                                                        .upiId !=
                                                    ''
                                            ? QrImageView(
                                                data:
                                                    'upi://pay?pa=${Get.find<AuthController>().profileModel!.restaurants!.first.upiId}&pn=&am=${Get.find<PosController>().collectItemPrice}&tn=',
                                                size: 120,
                                              )
                                            : SizedBox.shrink(),
                                        if (Get.find<PosController>()
                                                .paymentTab
                                                .toLowerCase() ==
                                            'partial')
                                          partialPayment(),
                                      ],
                                    ),
                                  ), // : SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
      });
    });
  }

  // payNormalBill(PosController posController) {
  //   double orderPay = posController.collectItemPrice;

  //   Map<String, dynamic> jsonData = {
  //     'waiter_id': Get.find<AuthController>().profileModel!.empId.toString(),
  //     'payment_method': Get.find<AuthController>()
  //                 .profileModel!
  //                 .restaurants!
  //                 .first
  //                 .settings!
  //                 .autoPaid ==
  //             'Yes'
  //         ? 'cash'
  //         : Get.find<PosController>().paymentTab,
  //     'order_sub_total_without_tax': orderSubTotal +
  //         deliveryCharge +
  //         showServiceChargeValue +
  //         (double.parse(_addTips.text.isEmpty ? "0" : _addTips.text)),
  //     'paid_room': Get.find<PosController>().paymentTab.toLowerCase() == 'room'
  //         ? 'Yes'
  //         : '',
  //     'payment_status': 'sucess',
  //     if (selectedDateTime != null)
  //       "schedule_at":
  //           DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDateTime!),
  //     if (selectedDateTime != null) "scheduled": 1,

  //     'tip_tax_amount': tipTaxAmount,
  //     'service_gst_tax_amount': gstServiceChargeTax,

  //     'cust_email': '',
  //     "payment_type": "prepaid",
  //     'discount_type':
  //         Get.find<CartController>().isApplyLoyalty ? 'Loyality' : '',

  //     "order_note":
  //         _addNoteController.text.isEmpty ? '' : _addNoteController.text,
  //     'delivery_charge': '$deliveryCharge',
  //     // "order_amount": orderSubTotal,
  //     'use_wallet_balance':
  //         Get.find<CartController>().isApplyWallet ? walletUsed : 0,

  //     "tax_amount": gstAmount + vatAmount + gstServiceChargeTax + tipTaxAmount,
  //     'order_sub_total_amount': orderItemTotal,
  //     'order_amount': Get.find<AuthController>()
  //                 .profileModel
  //                 ?.restaurants
  //                 ?.first
  //                 .isTotalRound ==
  //             'Yes'
  //         ? orderPay.ceil()
  //         : orderPay.toStringAsFixed(2),
  //     'vat_tax': vatAmount,
  //     'gst_tax': gstAmount + tipTaxAmount + gstServiceChargeTax,
  //     'address_id': Get.find<TableController>().selectedTable?.id == 0 &&
  //             Get.find<TableController>().selectedTable?.tableNo == 'Delivery'
  //         ? selectedAddress!.id.toString()
  //         : '',
  //     'print_kot': isPrintKot ? 'Yes' : 'No',
  //     // 'self_discount': orderDiscount,
  //     'self_discount': (isCouponValidate && _couponController.text.isNotEmpty)
  //         ? 0
  //         : orderDiscount,
  //     'coupon_discount': (isCouponValidate && _couponController.text.isNotEmpty)
  //         ? orderDiscount
  //         : 0,
  //     'coupon_title': (isCouponValidate && _couponController.text.isNotEmpty)
  //         ? _couponController.text
  //         : '',
  //     'coupon_type': (isCouponValidate && _couponController.text.isNotEmpty)
  //         ? couponDiscountType
  //         : '',
  //     'room_id': '${Get.find<PosController>().selectedRoom?.table?.id ?? ''}',
  //     'round_up': Get.find<AuthController>()
  //                 .profileModel
  //                 ?.restaurants
  //                 ?.first
  //                 .isTotalRound ==
  //             'Yes'
  //         ? '${(orderPay.ceil() - orderPay).toStringAsFixed(2)}'
  //         : '0',
  //     'order_type': Get.find<TableController>().selectedTable == null
  //         ? 'pos'
  //         : (Get.find<TableController>().selectedTable?.id == 0 &&
  //                 Get.find<TableController>().selectedTable?.tableNo ==
  //                     'Delivery')
  //             ? 'delivery'
  //             : (Get.find<TableController>().selectedTable?.id == 0 &&
  //                     Get.find<TableController>().selectedTable?.tableNo ==
  //                         'Take Away')
  //                 ? 'take_away'
  //                 : 'pos',
  //     "table_id": Get.find<TableController>().selectedTable?.id == 0
  //         ? '0'
  //         : Get.find<TableController>().selectedTable?.id.toString() ?? '0',

  //     'tip_amount': _addTips.text.isEmpty ? '0' : _addTips.text,
  //     'order_discount': orderDiscount,
  //     'used_loyalty_point':
  //         ((Get.find<CartController>().isApplyLoyalty) ? usedLoyaltyPoint : 0),
  //     'cust_mobile': _phoneController.text.isEmpty ? '' : _phoneController.text,
  //     'cust_name': _nameController.text.isEmpty ? '' : _nameController.text,
  //     'cust_dob': _dobController.text.isEmpty ? '' : _dobController.text,
  //     'cust_anniversary': _anniversaryController.text.isEmpty
  //         ? ''
  //         : _anniversaryController.text,
  //     'cust_membership_id': _selectedDropdownOption ?? '',
  //     'restaurant_name':
  //         Get.find<AuthController>().profileModel!.restaurants![0].name,
  //     'service_tax': Get.find<PosController>().isAddServiceCharge
  //         ? showServiceChargeValue
  //         : 0,
  //     'transaction_id': _transactionNoController.text.isEmpty
  //         ? ''
  //         : _transactionNoController.text,
  //     'room_id': Get.find<PosController>().paymentTab.toLowerCase() == 'room'
  //         ? '${Get.find<PosController>().selectedRoom!.table!.id}'
  //         : '',
  //     'auto_dispatch': Get.find<AuthController>()
  //             .profileModel!
  //             .restaurants
  //             ?.first
  //             .settings
  //             ?.autoDispatch ??
  //         'No',
  //     if (Get.find<PosController>().paymentTab.toLowerCase() == 'partial')
  //       'partial_payments': [
  //         {
  //           "payment_mode": "cash",
  //           "payment_amount": pCash.text,
  //           "grant_amount": pCash.text,
  //           "transaction_id": ""
  //         },
  //         {
  //           "payment_mode": "card",
  //           "payment_amount": pCard.text,
  //           "grant_amount": pCard.text,
  //           "transaction_id": pTXN.text
  //         },
  //         {
  //           "payment_mode": "upi",
  //           "payment_amount": pUpi.text,
  //           "grant_amount": pUpi.text,
  //           "transaction_id": ""
  //         }
  //       ],
  //   };
  //   if (Get.find<PosController>().paymentTab.toLowerCase() == 'cash') {
  //     if (paidController.text.isEmpty) {
  //       showErrorToast('Please enter paid amount');
  //     } else if (double.parse(paidController.text) <
  //         Get.find<PosController>().collectItemPrice) {
  //       showErrorToast('Paid amount cannot be less than bill amount');
  //     } else {
  //       callCollectBillApi(jsonData);
  //     }
  //   } else if (Get.find<AuthController>()
  //           .profileModel!
  //           .restaurants!
  //           .first
  //           .settings!
  //           .autoPaid ==
  //       'Yes') {
  //     callCollectBillApi(jsonData);
  //   } else if (Get.find<PosController>().paymentTab.toLowerCase() ==
  //       'partial') {
  //     double totalPay = Get.find<PosController>().collectItemPrice;
  //     if (pCash.text.isEmpty) {
  //       showErrorToast('Please enter cash amount');
  //     } else if (pCard.text.isEmpty) {
  //       showErrorToast('Please enter card amount');
  //     } else if (pUpi.text.isEmpty) {
  //       showErrorToast('Please enter UPI amount');
  //     } else if (pCard.text.isNotEmpty &&
  //         pCard.text != '0' &&
  //         pTXN.text.isEmpty) {
  //       showErrorToast('Please enter transaction number for card payment');
  //     } else if (pCard.text.isNotEmpty &&
  //         pCard.text != '0' &&
  //         pTXN.text.isNotEmpty &&
  //         pTXN.text.trim().length < 4) {
  //       showErrorToast('Enter valid transaction number for card payment');
  //     } else {
  //       double totalPartialAmt = double.parse(pCash.text) +
  //           double.parse(pCard.text) +
  //           double.parse(pUpi.text);
  //       if (totalPartialAmt <
  //           (Get.find<AuthController>()
  //                       .profileModel!
  //                       .restaurants!
  //                       .first
  //                       .isTotalRound ==
  //                   'Yes'
  //               ? totalPay.ceil()
  //               : totalPay)) {
  //         showErrorToast(
  //             'Total partial amount cannot be less than bill amount');
  //       } else if (totalPartialAmt >
  //           (Get.find<AuthController>()
  //                       .profileModel!
  //                       .restaurants!
  //                       .first
  //                       .isTotalRound ==
  //                   'Yes'
  //               ? totalPay.ceil()
  //               : totalPay)) {
  //         showErrorToast(
  //             'Total partial amount cannot be greater than bill amount');
  //       } else {
  //         callCollectBillApi(jsonData);
  //       }
  //     }
  //   } else if (Get.find<PosController>().paymentTab.toLowerCase() == 'card') {
  //     if ((((_transactionNoController.text.isEmpty) ||
  //             _transactionNoController.text.trim().length < 4)) &&
  //         Get.find<AuthController>()
  //                 .profileModel!
  //                 .restaurants!
  //                 .first
  //                 .edcDetail!
  //                 .pinelab !=
  //             'Yes') {
  //       showErrorToast('Please enter transaction number');
  //     } else {
  //       callCollectBillApi(jsonData);
  //     }
  //   } else {
  //     callCollectBillApi(jsonData);
  //   }
  // }

  Widget nameTextField(BuildContext context) {
    return Container(
      height: 30,
      child: Get.find<PosController>().paymentTab.toLowerCase() == 'tab' &&
              Get.find<PosController>().tapManagmentCustomerListResponse != null
          ? TypeAheadField(
              getImmediateSuggestions: true,
              textFieldConfiguration: TextFieldConfiguration(
                onChanged: (s) {
                  if (userId != '' && isCouponValidate == true) {
                    userId = '';
                    _discountController.text = '0';
                    discountCalculator();
                    if (mounted) {
                      setState(() {});
                    }
                  }
                },
                controller: _nameController,
                textInputAction: TextInputAction.search,
                autofocus: false,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  hintStyle:
                      poppinsMedium.copyWith(fontSize: 13, color: Colors.grey),
                  hintText: 'Name',
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: poppinsMedium.copyWith(
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
              noItemsFoundBuilder: (context) => SizedBox.shrink(),
              suggestionsCallback: (pattern) async {
                return Get.find<PosController>()
                    .tapManagmentCustomerListResponse!
                    .employeeTapList
                    .where((item) => item.name
                        .toString()
                        .trim()
                        .toLowerCase()
                        .contains(pattern.toLowerCase().trim()))
                    .toList();
              },
              itemBuilder: (context, EmployeeTapList suggestion) {
                return Padding(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  child: Row(children: [
                    SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${suggestion.name ?? ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: poppinsRegular.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                                  fontSize: Dimensions.FONT_SIZE_SMALL,
                                )),
                          ]),
                    ),
                  ]),
                );
              },
              onSuggestionSelected: (EmployeeTapList suggestion) {
                _phoneController.text = suggestion.mobile.toString();
                _nameController.text = suggestion.name;
                userId = '${suggestion.id}';

                // emailController.text = suggestion.email;
                Get.find<PosController>().update();
              },
            )
          : TextField(
              controller: _nameController,
              textInputAction: TextInputAction.search,
              onChanged: (s) {
                if (userId != '' && isCouponValidate == true) {
                  userId = '';
                  _discountController.text = '0';
                  discountCalculator();
                  if (mounted) {
                    setState(() {});
                  }
                }
              },
              autofocus: false,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  borderSide: BorderSide(color: ColorTheme.borderGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  borderSide: BorderSide(color: ColorTheme.borderGrey),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  borderSide: BorderSide(color: ColorTheme.borderGrey),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  borderSide: BorderSide(color: ColorTheme.borderGrey),
                ),
                hintStyle: poppinsSemiBold.copyWith(
                    fontSize: Dimensions.FONT_SIZE_SMALL, color: Colors.grey),
                filled: true,
                hintText: 'Name',
                fillColor: Theme.of(context).cardColor,
              ),
              style: poppinsSemiBold.copyWith(
                color: Colors.black,
                fontSize: Dimensions.FONT_SIZE_SMALL,
              ),
            ),
    );
  }

  Widget phoneTextField(BuildContext context) {
    return Container(
      height: 30,
      child: Get.find<PosController>().paymentTab.toLowerCase() == 'tab' &&
              Get.find<PosController>().tapManagmentCustomerListResponse != null
          ? TypeAheadField(
              getImmediateSuggestions: true,
              textFieldConfiguration: TextFieldConfiguration(
                onChanged: (s) {
                  if (userId != '' && isCouponValidate == true) {
                    userId = '';
                    _discountController.text = '0';
                    discountCalculator();
                    if (mounted) {
                      setState(() {});
                    }
                  }
                },
                controller: _phoneController,
                textInputAction: TextInputAction.search,
                autofocus: false,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  hintStyle:
                      poppinsMedium.copyWith(fontSize: 13, color: Colors.grey),
                  hintText: 'Phone No.',
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: poppinsMedium.copyWith(
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
              noItemsFoundBuilder: (context) => SizedBox.shrink(),
              suggestionsCallback: (pattern) async {
                return Get.find<PosController>()
                    .tapManagmentCustomerListResponse!
                    .employeeTapList
                    .where((item) => item.mobile
                        .toString()
                        .trim()
                        .toLowerCase()
                        .contains(pattern.toLowerCase().trim()))
                    .toList();
              },
              itemBuilder: (context, EmployeeTapList suggestion) {
                return Padding(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  child: Row(children: [
                    SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${suggestion.mobile}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: poppinsRegular.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                                  fontSize: 13,
                                )),
                          ]),
                    ),
                  ]),
                );
              },
              onSuggestionSelected: (EmployeeTapList suggestion) {
                _phoneController.text = suggestion.mobile.toString();
                _nameController.text = suggestion.name;
                userId = '${suggestion.id}';

                // emailController.text = suggestion.email;
                Get.find<PosController>().update();
              },
            )
          : TextField(
              controller: _phoneController,
              textInputAction: TextInputAction.search,
              autofocus: false,
              keyboardType: TextInputType.numberWithOptions(signed: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp("[0-9,+]")),
              ],
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  borderSide: BorderSide(color: ColorTheme.borderGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  borderSide: BorderSide(color: ColorTheme.borderGrey),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  borderSide: BorderSide(color: ColorTheme.borderGrey),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  borderSide: BorderSide(color: ColorTheme.borderGrey),
                ),
                hintStyle:
                    poppinsMedium.copyWith(fontSize: 13, color: Colors.grey),
                filled: true,
                hintText: 'Phone No.',
                fillColor: Colors.white,
              ),
              onChanged: (String d) async {
                if (_phoneController.text.isNotEmpty &&
                    _phoneController.text.length > 9) {
                  List<SearchCustomerResponseModel> searchData =
                      await Get.find<CartController>()
                          .searchWaiterPOSCustomer(_phoneController.text);
                  if (searchData.isNotEmpty && searchData.first.id != 'false') {
                    if (searchData.first.name != '')
                      _nameController.text = searchData.first.name;
                  }
                }
              },
              style: poppinsMedium.copyWith(
                color: Colors.black,
                fontSize: 13,
              ),
            ),
    );
  }

  Future _kdsPrintEscPos(List<int> bytes) async {
    try {
      final profile = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>().profileModel
          : null;
      if (profile == null) return;

      final billType = (profile.billPrinterType ?? '').toLowerCase();
      final isWifi = billType == 'wifi' ||
          billType == 'network' ||
          ((profile.billWifiIp ?? '').isNotEmpty &&
              billType != 'bluetooth' &&
              billType != 'usb');
      final isUsb = billType == 'usb';

      BluetoothPrinter bluetoothPrinter;
      if (isUsb) {
        bluetoothPrinter = BluetoothPrinter(
            productId: profile.billProductId,
            vendorId: profile.billVendorId,
            typePrinter: PrinterType.usb);
      } else if (isWifi) {
        bluetoothPrinter = BluetoothPrinter(
            typePrinter: PrinterType.network,
            port: '9100',
            address: (profile.billWifiIp ?? '').isNotEmpty
                ? profile.billWifiIp!
                : (profile.billPrinterIp ?? ''),
            deviceName: profile.billPrinterName);
      } else {
        bluetoothPrinter = BluetoothPrinter(
            typePrinter: PrinterType.bluetooth,
            address: (profile.macBillPrinterIp ?? '').isNotEmpty
                ? profile.macBillPrinterIp!
                : (profile.billPrinterIp ?? ''),
            deviceName: profile.billPrinterName);
      }

      var data;
      switch (bluetoothPrinter.typePrinter) {
        case PrinterType.usb:
          data = await individualPrinter.connect(
            type: bluetoothPrinter.typePrinter,
            model: UsbPrinterInput(
              name: bluetoothPrinter.deviceName,
              productId: bluetoothPrinter.productId,
              vendorId: bluetoothPrinter.vendorId,
            ),
          );
          break;
        case PrinterType.bluetooth:
          data = await individualPrinter.connect(
            type: bluetoothPrinter.typePrinter,
            model: BluetoothPrinterInput(
              name: bluetoothPrinter.deviceName,
              address: bluetoothPrinter.address ?? '',
              isBle: bluetoothPrinter.isBle,
            ),
          );
          pendingTask = null;
          if (Platform.isIOS || Platform.isAndroid) pendingTask = bytes;
          break;
        case PrinterType.network:
          data = await individualPrinter.connect(
            type: bluetoothPrinter.typePrinter,
            model: TcpPrinterInput(ipAddress: bluetoothPrinter.address ?? ''),
          );
          break;
      }

      try {
        await individualPrinter.send(
            type: bluetoothPrinter.typePrinter, bytes: bytes);
        Future.delayed(
            Duration(
                seconds: bytes.length <= 5850
                    ? 1
                    : bytes.length <= 7890
                        ? 2
                        : bytes.length <= 10195
                            ? 5
                            : bytes.length <= 13100
                                ? 10
                                : bytes.length <= 21150
                                    ? 15
                                    : 20), () async {
          pendingTask = null;
          try {
            if (Get.isRegistered<LoadingController>()) {
              Get.find<LoadingController>().startLoading(false);
              await Get.find<LoadingController>()
                  .changeText(data: 'Successfully printed!!');
              await Get.find<LoadingController>().changeStatus(data: true);
            }
            await PrinterManager.instance
                .disconnect(type: bluetoothPrinter.typePrinter);
          } catch (_) {}
        });
      } catch (e) {}

      if (data != null && !data) {
        if (Get.isRegistered<LoadingController>()) {
          await Get.find<LoadingController>().changeText(
              data: bluetoothPrinter.typePrinter == PrinterType.usb
                  ? 'Failed to usb connect!!'
                  : bluetoothPrinter.typePrinter == PrinterType.network
                      ? 'Failed to Wi-Fi connect!!'
                      : 'Failed to bluetooth connect!!',
              error: true);
          await Get.find<LoadingController>().changeStatus(data: true);
        }
      }
    } catch (e) {
      if (Get.isRegistered<LoadingController>()) {
        try {
          await Get.find<LoadingController>().changeText(
              data: 'Printing error occurred: $e', error: true);
          await Get.find<LoadingController>().changeStatus(data: true);
        } catch (_) {}
      }
    }
  }

  // Future _iosPrintEscPos(List<int> bytes) async {
  //   print('########## bytes length ${bytes.length}');
  //   // bytes += generator.feed(2);
  //   // await PrintBluetoothThermal.pairedBluetooths;

  //   // Future.delayed(Duration(seconds: 5), () async {
  //   final bool result = await PrintBluetoothThermal.connect(
  //       macPrinterAddress:
  //           Get.find<AuthController>().profileModel!.macBillPrinterIp!);

  //   Future.delayed(Duration(seconds: 1), () async {
  //     if (result) {
  //       // List<int> ticket = await testTicket();
  //       await PrintBluetoothThermal.writeBytes(bytes);

  //       Future.delayed(
  //           Duration(
  //               seconds: bytes.length <= 5850
  //                   ? 2
  //                   : bytes.length <= 7890
  //                       ? 3
  //                       : bytes.length <= 10195
  //                           ? 6
  //                           : bytes.length <= 13100
  //                               ? 10
  //                               : bytes.length <= 21150
  //                                   ? 15
  //                                   : 20), () async {
  //         Get.find<LoadingController>().startLoading(false);

  //         await Get.find<LoadingController>()
  //             .changeText(data: 'Successfully printed!!');
  //         await Get.find<LoadingController>().changeStatus(data: true);
  //         var isDisconnect = await PrintBluetoothThermal.disconnect;
  //         print('is disconnect $isDisconnect');
  //       });
  //       print("print test result:  $result");
  //     } else {
  //       //no conectado, reconecte
  //       Get.find<LoadingController>().startLoading(false);

  //       await Get.find<LoadingController>()
  //           .changeText(data: 'Failed to bluetooth connect!!', error: true);
  //       await Get.find<LoadingController>().changeStatus(data: true);
  //       // showErrorToast('Failed to bluetooth connect');
  //     }
  //     // });
  //   });
  // }

  Future<void> _iosPrintEscPos(List<int> bytes, {bool isBill = false}) async {
    try {
      print('####24###### bytes length ${bytes.length}');

      final profile = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>().profileModel
          : null;
      final macAddress = (profile?.macBillPrinterIp ?? '').isNotEmpty
          ? profile!.macBillPrinterIp!
          : (profile?.billPrinterIp ?? '');

      final bool result = await IosPrintTransport.connect(
        wifiPrinter: NetworkPrinterResolver.billPrinter(),
        macPrinterAddress: macAddress,
      );

    if (!result) {
      Get.find<LoadingController>().startLoading(false);
      await Get.find<LoadingController>()
          .changeText(data: 'Failed to bluetooth connect!!', error: true);
      await Get.find<LoadingController>().changeStatus(data: true);
      return;
    }

    try {
      // iPad-safe chunked write
      (Get.find<AuthController>().profileModel!.billPrinterPaperRoll == 58 ||
              MediaQuery.of(context).size.shortestSide < 570)
          ? await IosPrintTransport.writeBytes(bytes)
          : await _writeBytesForIPad(bytes);

      // Wait for printer to finish processing bytes
      await Future.delayed(Duration(
          seconds: bytes.length <= 5850
              ? 2
              : bytes.length <= 7890
                  ? 3
                  : bytes.length <= 10195
                      ? 6
                      : bytes.length <= 13100
                          ? 10
                          : bytes.length <= 21150
                              ? 15
                              : 20));

      if (Get.isRegistered<LoadingController>()) {
        Get.find<LoadingController>().startLoading(false);
        await Get.find<LoadingController>()
            .changeText(data: 'Successfully printed!!');
        await Get.find<LoadingController>().changeStatus(data: true);
      }
      if (isBill) {
        Get.find<CartController>().showLoader(false);
        Get.until((route) =>
            route.settings.name == RouteHelper.getTableViewHomeRoute());
        Get.find<CartController>().clearCartList();
      }
    } catch (e) {
      print('Print error: $e');
      if (Get.isRegistered<LoadingController>()) {
        Get.find<LoadingController>().startLoading(false);
        await Get.find<LoadingController>()
            .changeText(data: 'Printing failed!!', error: true);
        await Get.find<LoadingController>().changeStatus(data: true);
      }
    }
    } catch (e) {
      if (Get.isRegistered<LoadingController>()) {
        Get.find<LoadingController>().startLoading(false);
        await Get.find<LoadingController>()
            .changeText(data: 'Connection failed: $e', error: true);
        await Get.find<LoadingController>().changeStatus(data: true);
      }
    }
  }

  Future<void> _writeBytesForIPad(List<int> bytes) async {
    const int chunkSize = 255; // 🔥 SAFE for all iPads
    const int delayMs = 60; // Required for 80mm stability

    for (int i = 0; i < bytes.length; i += chunkSize) {
      final chunk = bytes.sublist(
        i,
        (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize,
      );

      await IosPrintTransport.writeBytes(chunk);
      await Future.delayed(const Duration(milliseconds: delayMs));
    }
  }

  individualListenBluetooth() async {
    if (GetPlatform.isAndroid) {
      _singlePrintBtStatus =
          individualPrinter.stateBluetooth.listen((status) async {
        if (status == BTStatus.connecting) {}
        if (status == BTStatus.connected && pendingTask != null) {
          isConnect = true;
          if (mounted) setState(() {});

          Future.delayed(const Duration(milliseconds: 1000), () async {
            pendingTask = null;
          });
        } else if (status == BTStatus.none) {
          Get.find<LoadingController>().startLoading(false);

          await Get.find<LoadingController>()
              .changeText(data: 'Failed to bluetooth connect!!', error: true);
          await Get.find<LoadingController>().changeStatus(data: true);
        }
      });
    }
  }

  Widget partialPayment() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 1,
                child: Text(
                  'Cash : ',
                  style: poppinsMedium.copyWith(fontSize: 13),
                )),
            SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: Container(
                height: 30,
                child: TextField(
                  controller: pCash,
                  textInputAction: TextInputAction.search,
                  autofocus: false,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                  ],
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                    ),
                    hintStyle: poppinsMedium.copyWith(
                        fontSize: 13, color: Colors.grey),
                    filled: true,
                    hintText: 'Cash Amount',
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    if (value.trim().isNotEmpty) {
                      final auth = Get.find<AuthController>();
                      final pos = Get.find<PosController>();

                      final isRound =
                          auth.profileModel?.restaurants?.first.isTotalRound ==
                              'Yes';

                      double cash = double.tryParse(value) ?? 0.0;

                      double totalPay = pos.collectItemPrice;

                      var finalTotal =
                          isRound ? getRoundUpValue(value: totalPay) : totalPay;

                      // ✅ STEP 1: Reset first (VERY IMPORTANT)
                      pUpi.text = '0';
                      pCard.text = '0';

                      double card = 0.0;
                      double upi = 0.0;

                      // ✅ STEP 2: Calculate remaining
                      if (cash < finalTotal) {
                        double remain = finalTotal - cash;

                        if (isUPIOption && !isCardOption) {
                          pUpi.text = remain.toStringAsFixed(2);
                        } else if (!isUPIOption && isCardOption) {
                          pCard.text = remain.toStringAsFixed(2);
                        } else if (isUPIOption && isCardOption) {
                          // 🔥 Safe split (no overflow)
                          double upiAmt =
                              double.parse((remain / 2).toStringAsFixed(2));
                          double cardAmt = double.parse(
                              (remain - upiAmt).toStringAsFixed(2));

                          pUpi.text = upiAmt.toString();
                          pCard.text = cardAmt.toString();
                        }
                      }

                      // ✅ STEP 3: Safe parsing
                      card = double.tryParse(pCard.text) ?? 0.0;
                      upi = double.tryParse(pUpi.text) ?? 0.0;

                      double totalPartialAmt =
                          double.parse((cash + card + upi).toStringAsFixed(2));

                      double finalCheck =
                          double.parse(finalTotal.toStringAsFixed(2));

                      // ✅ STEP 4: Validation (with tolerance)
                      if (totalPartialAmt > finalCheck + 0.01) {
                        showErrorToast(
                            'Total partial amount cannot be greater than bill amount');
                        pCash.text = '';
                      }
                    }
                  },
                  style: poppinsMedium.copyWith(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (isUPIOption)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text(
                      'UPI  : ',
                      style: poppinsMedium.copyWith(fontSize: 13),
                    )),
                SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 30,
                    child: TextField(
                      controller: pUpi,
                      textInputAction: TextInputAction.search,
                      autofocus: false,
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                      ],
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          borderSide: BorderSide(color: ColorTheme.borderGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          borderSide: BorderSide(color: ColorTheme.borderGrey),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          borderSide: BorderSide(color: ColorTheme.borderGrey),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          borderSide: BorderSide(color: ColorTheme.borderGrey),
                        ),
                        hintStyle: poppinsMedium.copyWith(
                            fontSize: 13, color: Colors.grey),
                        filled: true,
                        hintText: 'UPI Amount',
                        fillColor: Colors.white,
                      ),
                      style: poppinsMedium.copyWith(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (isCardOption)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text(
                      'Card : ',
                      style: poppinsMedium.copyWith(fontSize: 13),
                    )),
                SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 30,
                    child: TextField(
                      controller: pCard,
                      textInputAction: TextInputAction.search,
                      autofocus: false,
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                      ],
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          borderSide: BorderSide(color: ColorTheme.borderGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          borderSide: BorderSide(color: ColorTheme.borderGrey),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          borderSide: BorderSide(color: ColorTheme.borderGrey),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          borderSide: BorderSide(color: ColorTheme.borderGrey),
                        ),
                        hintStyle: poppinsMedium.copyWith(
                            fontSize: 13, color: Colors.grey),
                        filled: true,
                        hintText: 'Card Amount',
                        fillColor: Colors.white,
                      ),
                      style: poppinsMedium.copyWith(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (isCardOption)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text(
                      'Transaction No : ',
                      style: poppinsMedium.copyWith(fontSize: 13),
                    )),
                SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 30,
                    child: TextField(
                      controller: pTXN,
                      textInputAction: TextInputAction.search,
                      autofocus: false,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          borderSide: BorderSide(color: ColorTheme.borderGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          borderSide: BorderSide(color: ColorTheme.borderGrey),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          borderSide: BorderSide(color: ColorTheme.borderGrey),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          borderSide: BorderSide(color: ColorTheme.borderGrey),
                        ),
                        hintStyle: poppinsMedium.copyWith(
                            fontSize: 13, color: Colors.grey),
                        filled: true,
                        hintText: 'Transacation No',
                        fillColor: Colors.white,
                      ),
                      style: poppinsMedium.copyWith(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget productWidget({
    CartController? cartC,
    CartModel? cart,
    int? cartIndex,
    List<AddOns>? addOns,
    bool? isAvailable,
    Function? onIncrease,
  }) {
    String addOnText = '';
    double addonsTotal = 0;
    int index0 = 0;
    // List<int> ids = [];
    // List<int> qtys = [];
    // for (var addOn in cart!.addOnIds) {
    //   ids.add(addOn.id);
    //   qtys.add(addOn.quantity);
    // }
    for (var addOn in cart!.addOnIds) {
      if (addOn.quantity != 0) {
        addOnText =
            '$addOnText${(index0 == 0) ? '' : ',  '}${addOn.name} (${addOn.quantity})';
        addonsTotal =
            addonsTotal + ((addOn.price ?? 0) * (addOn.quantity ?? 0));
        index0 = index0 + 1;
      }
    }

    String variationText = '';
    double halfVariationPrice = 0;
    variationTotal = 0;
    if (cart.variation.isNotEmpty) {
      for (int index = 0; index < cart.variation.length; index++) {
        if (cart.variation[index].isNotEmpty &&
            cart.variation[index].contains(true)) {
          variationText +=
              '${variationText.isNotEmpty ? ', ' : ''}${cart.product.variations![index].name} (';

          for (int i = 0; i < cart.variation[index].length; i++) {
            if (cart.variation[index][i]) {
              if (cart.product.variations![index].name!.toUpperCase() ==
                  'HALFNHALF') {
                if (halfVariationPrice <
                    double.parse(cart
                        .product.variations![index].values![i].optionPrice!)) {
                  halfVariationPrice = double.parse(
                      cart.product.variations![index].values![i].optionPrice!);
                }
              } else {
                variationTotal += double.parse(
                    cart.product.variations![index].values![i].optionPrice!);
              }
              // print(variationTotal);
              variationText +=
                  '${variationText.endsWith('(') ? '' : ', '}${cart.product.variations![index].values![i].level}';
            }
          }
          variationText += ')';
          variationTotal = variationTotal + halfVariationPrice;
        }
      }
    }

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: ColorTheme.productCard,
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cart.product.name ?? '',
                            style: poppinsSemiBold.copyWith(
                                color: Colors.black, fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // if ((cart.product.description ?? '') != '')
                          //   const SizedBox(height: 2),
                          // if ((cart.product.description ?? '') != '')
                          //   Text(
                          //     cart.product.description ?? '',
                          //     style: poppinsMedium.copyWith(
                          //         color: ColorTheme.hintText,
                          //         fontSize: MediaQuery.of(context)
                          //                     .size
                          //                     .shortestSide >
                          //                 570
                          //             ? 13
                          //             : 10),
                          //     maxLines: 2,
                          //     overflow: TextOverflow.ellipsis,
                          //   ),
                          const SizedBox(height: 2),

                          // Ratig should be removed from web browser

                          const SizedBox(height: 5),
                          if (Get.find<AuthController>()
                                  .profileModel!
                                  .restaurants!
                                  .first
                                  .restaurantType !=
                              'Restaurant buffet')
                            Row(children: [
                              Text(
                                PriceConverter.convertPrice(
                                    cart.discountedPrice,
                                    // cart.discountedPrice*cart.quantity,
                                    asFixed: 2,
                                    isHideCurrency: true),
                                style: poppinsBold.copyWith(
                                    color: ColorTheme.green, fontSize: 13),
                              ),
                              if (Get.find<AuthController>()
                                  .profileModel!
                                  .role!
                                  .contains('complementary_food'))
                                Padding(
                                  padding: const EdgeInsets.only(left: 25),
                                  child: InkWell(
                                      onTap: () async {
                                        List<int> qtyList = [];
                                        for (var i = 0;
                                            i < cart.quantity;
                                            i++) {
                                          qtyList.add(i + 1);
                                        }
                                        await Get.bottomSheet(
                                            complementryFoodBottomSheet(
                                                cartC!,
                                                cart,
                                                qtyList,
                                                cart.product.name ?? '',
                                                variationText,
                                                addOnText,
                                                onIncrease!),
                                            backgroundColor: Colors.transparent,
                                            isScrollControlled: true,
                                            ignoreSafeArea: false);
                                      },
                                      child: Icon(Icons.free_breakfast_outlined,
                                          color: ColorTheme.appColor)),
                                )
                            ]),
                        ]),
                  ),
                  Container(
                    width: 100,
                    padding: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: ColorTheme.borderGrey)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: QuantityButton(
                              onTap: () {
                                cartC!.setQuantity(false, cart);
                                // if (cart.quantity > 1) {
                                //   Get.find<CartController>()
                                //       .setQuantity(false, cart);
                                // } else {
                                //   Get.find<CartController>()
                                //       .removeFromCart(cartIndex!);
                                //   if (Get.find<CartController>()
                                //       .cartList
                                //       .isEmpty) {
                                //     Navigator.pop(context);
                                //   }
                                // }

                                if (onIncrease != null) onIncrease(true);
                              },
                              isIncrement: false,
                            ),
                          ),
                          Text(
                              // cart.quantity.toString(),
                              cart.quantity % 1 == 0
                                  ? cart.quantity.toInt().toString()
                                  : cart.quantity.toString(),
                              style: poppinsMedium.copyWith(fontSize: 14)),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: QuantityButton(
                              onTap: () {
                                // if (addOnText == '') {
                                //   Get.find<CartController>()
                                //       .setQuantity(true, cart);
                                // if (onIncrease != null)
                                //               onIncrease(true);

                                // }

                                cartC!.setQuantity(true, cart);
                                if (onIncrease != null) onIncrease(true);
                              },
                              isIncrement: true,
                            ),
                          ),
                        ]),
                  ),
                ],
              ),
              (variationText != '' &&
                      cart.product.variations != null &&
                      cart.product.variations!.isNotEmpty)
                  ? Padding(
                      padding: const EdgeInsets.only(
                          top: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Variants: ',
                              style: poppinsMedium.copyWith(
                                  color: ColorTheme.blue,
                                  fontSize:
                                      MediaQuery.of(context).size.shortestSide >
                                              570
                                          ? 14
                                          : 10),
                            ),
                            Flexible(
                              child: Text(variationText,
                                  style: poppinsMedium.copyWith(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .shortestSide >
                                              570
                                          ? 14
                                          : 10,
                                      color: ColorTheme.green)),
                            ),
                          ]),
                    )
                  : const SizedBox(),
              addOnText.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(
                          top: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${'addons'.tr}: ',
                                style: poppinsMedium.copyWith(
                                    color: ColorTheme.blue,
                                    fontSize: MediaQuery.of(context)
                                                .size
                                                .shortestSide >
                                            570
                                        ? 14
                                        : 10)),
                            Flexible(
                                child: Text(
                              addOnText,
                              style: poppinsMedium.copyWith(
                                  fontSize:
                                      MediaQuery.of(context).size.shortestSide >
                                              570
                                          ? 14
                                          : 10,
                                  color: Colors.black),
                            )),
                          ]),
                    )
                  : const SizedBox(),
              if (cart.foodNote != null && cart.foodNote != '')
                Padding(
                  padding: const EdgeInsets.only(
                      top: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notes: ',
                          style: poppinsMedium.copyWith(
                              color: ColorTheme.blue,
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 14
                                      : 10),
                        ),
                        Flexible(
                          child: Text(cart.foodNote ?? '',
                              style: poppinsMedium.copyWith(
                                  fontSize:
                                      MediaQuery.of(context).size.shortestSide >
                                              570
                                          ? 14
                                          : 10,
                                  color: ColorTheme.green)),
                        ),
                      ]),
                ),
              if (Get.find<CartController>().cartList.length - 1 != cartIndex)
                Padding(
                  padding: const EdgeInsets.only(top: 13),
                  child: DottedLine(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.center,
                    lineThickness: 1.0,
                    dashLength: 2.5,
                    dashColor: ColorTheme.hintText,
                  ),
                ),
            ],
          )),
    );
  }

  // callCollectBillApi(Map<String, dynamic> jsonData) async {
  //   Restaurant restaurant =
  //       Get.find<AuthController>().profileModel!.restaurants!.first;

  //   if ((isCouponValidate && _couponController.text.isNotEmpty)) {
  //     var data = await Get.find<LoyaltyController>()
  //         .redeemCoupon(_couponController.text ?? '', userId);
  //     if (data.containsKey('message') &&
  //         data['message'] == 'Coupon redeemed successfully') {
  //       jsonData['usage_id'] = data['usage_id'];
  //       if (restaurant.edcDetail != null &&
  //           restaurant.edcDetail!.pinelab == 'Yes' &&
  //           restaurant.edcDetail!.pineLabDetail != null &&
  //           (jsonData['payment_method'] == 'card' ||
  //               jsonData['payment_method'] == 'upi')) {
  //         jsonData.addAll({
  //           "merchant_id": restaurant.edcDetail!.pineLabDetail!.merchantId,
  //           "security_token":
  //               restaurant.edcDetail!.pineLabDetail!.securityToken,
  //           "store_id": restaurant.edcDetail!.pineLabDetail!.storeId,
  //           "client_id": restaurant.edcDetail!.pineLabDetail!.clientId,
  //         });
  //         await Get.find<CartController>().edcPrepaidOrder(prepaidCallback,
  //             jsonBody: jsonData, jsonFoodList: jsonCartList);
  //       } else {
  //         await Get.find<CartController>().prepaidOrder(prepaidCallback,
  //             jsonBody: jsonData, jsonFoodList: jsonCartList);
  //       }
  //       // await Get.find<CartController>().prepaidOrder(prepaidCallback,
  //       //     jsonBody: jsonData, jsonFoodList: jsonCartList);
  //     }
  //   } else {
  //     jsonData['usage_id'] = '';
  //     if (restaurant.edcDetail != null &&
  //         restaurant.edcDetail!.pinelab == 'Yes' &&
  //         restaurant.edcDetail!.pineLabDetail != null &&
  //         (jsonData['payment_method'] == 'card' ||
  //             jsonData['payment_method'] == 'upi')) {
  //       jsonData.addAll({
  //         "merchant_id": restaurant.edcDetail!.pineLabDetail!.merchantId,
  //         "security_token": restaurant.edcDetail!.pineLabDetail!.securityToken,
  //         "store_id": restaurant.edcDetail!.pineLabDetail!.storeId,
  //         "client_id": restaurant.edcDetail!.pineLabDetail!.clientId,
  //       });
  //       await Get.find<CartController>().edcPrepaidOrder(prepaidCallback,
  //           jsonBody: jsonData, jsonFoodList: jsonCartList);
  //     } else {
  //       await Get.find<CartController>().prepaidOrder(prepaidCallback,
  //           jsonBody: jsonData, jsonFoodList: jsonCartList);
  //     }
  //   }
  // }

  Future<void> pickDateTime(BuildContext context) async {
    // Pick Date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 31)),
    );

    if (pickedDate == null) return;

    // Pick Time
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    // Combine Date & Time
    selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // Format
    String formatted = DateFormat('dd-MM hh:mm a').format(selectedDateTime!);
    print(formatted);
    if (mounted) setState(() {});
  }

  Widget complementryFoodBottomSheet(
      CartController cartC,
      CartModel cart,
      List<int> qtyList,
      String productTitle,
      String variation,
      String addOn,
      Function onIncrease) {
    int selectedQty = 1;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE),
            ),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 25,
              right: 25,
              top: 25,
              bottom: Dimensions.PADDING_SIZE_DEFAULT,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Complementary Food',
                        style: poppinsMedium.copyWith(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.back(),
                        child: Icon(
                          Icons.close,
                          size: 30,
                          color: ColorTheme.appColor,
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: ColorTheme.borderGrey),
                  ),

                  const SizedBox(height: 12),

                  /// PRODUCT DETAILS
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Product Name
                            Text(
                              cart.product.name ?? '',
                              style: poppinsSemiBold.copyWith(
                                  color: Colors.black, fontSize: 15),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 4),

                            /// VARIATION
                            if (variation.isNotEmpty &&
                                cart.product.variations != null &&
                                cart.product.variations!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Variants: ',
                                      style: poppinsMedium.copyWith(
                                        color: ColorTheme.blue,
                                        fontSize: MediaQuery.of(context)
                                                    .size
                                                    .shortestSide >
                                                570
                                            ? 14
                                            : 10,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        variation,
                                        style: poppinsMedium.copyWith(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .shortestSide >
                                                  570
                                              ? 14
                                              : 10,
                                          color: ColorTheme.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            /// ADDONS
                            if (addOn.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${'addons'.tr}: ',
                                      style: poppinsMedium.copyWith(
                                        color: ColorTheme.blue,
                                        fontSize: MediaQuery.of(context)
                                                    .size
                                                    .shortestSide >
                                                570
                                            ? 14
                                            : 10,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        addOn,
                                        style: poppinsMedium.copyWith(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .shortestSide >
                                                  570
                                              ? 14
                                              : 10,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        width: 70,
                        margin: EdgeInsets.only(bottom: 15, left: 10),
                        height:
                            MediaQuery.of(context).size.width > 1600 ? 65 : 40,
                        padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.PADDING_SIZE_SMALL),
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorTheme.borderGrey),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: selectedQty,
                          items: qtyList.map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(
                                '$value',
                                maxLines: 1,
                                style: poppinsRegular.copyWith(
                                  fontSize:
                                      MediaQuery.of(context).size.width > 1600
                                          ? 17
                                          : Dimensions.FONT_SIZE_SMALL,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (int? value) {
                            if (value != null) {
                              setModalState(() {
                                selectedQty = value;
                              });
                            }
                          },
                          underline: SizedBox(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// SUBMIT BUTTON
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        cartC.addPRoductAfterComplement(cart, cart.product,
                            qty: selectedQty);

                        cartC.setQuantity(false, cart,
                            qty: qtyList.length - selectedQty,
                            removeFromCart: selectedQty == qtyList.length);
                        onIncrease(true);

                        Get.back();
                      },
                      child: Container(
                        height: 38,
                        width: 120,
                        decoration: BoxDecoration(
                          color: ColorTheme.appColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Submit',
                            style: poppinsMedium.copyWith(
                              fontSize: MediaQuery.of(context).size.width > 1600
                                  ? 18
                                  : 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  placeOrderCallFunction(PosController posController) async {
    if (!_beginPlaceOrder()) return;
    var orderSent = false;
    try {
    final crmPhone = _phoneController.text.trim().isNotEmpty
        ? _phoneController.text.trim()
        : selectedPhoneController.text.trim();
    final crmName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : (selectedAddress?.contactPersonName ?? '').trim();

    if (crmPhone.length >= 10 && crmName.isNotEmpty) {
      try {
        final crmId = await Get.find<CartController>().lookupAndSyncCrmCustomer(
          phone: crmPhone,
          name: crmName,
          dob: _dobController.text,
          anniversary: _anniversaryController.text,
          countryCode: countryCode?.dialCode ?? '',
          backToPrevious: false,
        );
        if (crmId != null && crmId.isNotEmpty) {
          userId = crmId;
        }
      } catch (_) {}
    }

    double orderPay = posController.collectItemPrice;

    Map<String, dynamic>? buildDeliveryAddressPayload() {
      if (selectedAddress == null) {
        return null;
      }

      return {
        "contact_person_name": selectedAddress?.contactPersonName,
        "contact_person_number": selectedAddress?.contactPersonNumber,
        "address_type": selectedAddress?.addressType,
        "address": selectedAddress?.address,
        "pincode": selectedAddress?.pincode,
        "floor": selectedAddress?.floor,
        "road": selectedAddress?.road,
        "house": selectedAddress?.house,
        "date_of_birth":
            _dobController.text.isEmpty ? null : _dobController.text,
        "date_of_anniversary": _anniversaryController.text.isEmpty
            ? null
            : _anniversaryController.text,
        "membership_id": _selectedDropdownOption,
        "longitude": selectedAddress?.longitude,
        "latitude": selectedAddress?.latitude,
      };
    }

    Map<String, dynamic> jsonbody = {
      if (widget.editOrder != null) 'order_id': widget.editOrder!.id.toString(),
      if (Get.find<AuthController>()
              .profileModel!
              .restaurants!
              .first
              .restaurantType !=
          'Restaurant buffet')
        "request_uuid": widget.orderUUID ?? '',
      if (widget.editOrder == null)
        "user_id": Get.find<TableController>().selectedTable?.tableNo ==
                'Delivery'
            // ? Get.find<LocationController>().addressList.first.userId ?? ''
            ? userId
            : '',

      if (selectedDateTime != null)
        "schedule_at":
            DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDateTime!),
      if (selectedDateTime != null) "scheduled": 1,
      "payment_method": widget.editOrder != null || !isPrepaid
          ? 'pending'
          : Get.find<AuthController>()
                      .profileModel!
                      .restaurants!
                      .first
                      .settings!
                      .autoPaid ==
                  'Yes'
              ? 'cash'
              : Get.find<PosController>().paymentTab,
      "order_sub_total_without_tax": orderSubTotal +
          deliveryCharge +
          showServiceChargeValue +
          (double.parse(_addTips.text.isEmpty ? "0" : _addTips.text)) -
          ((Get.find<CartController>().isApplyLoyalty &&
                  !crmLoyaltyBelowMin &&
                  crmLoyaltyDiscount > 0)
              ? crmLoyaltyDiscount
              : 0) -
          ((isCouponValidate && crmCouponRupee > 0) ? crmCouponRupee : 0),

      "paid_room": Get.find<PosController>().paymentTab.toLowerCase() == 'room'
          ? 'Yes'
          : '',
      "payment_status": Get.find<PosController>().paymentTab == '' || !isPrepaid
          ? 'unpaid'
          : 'paid', // "sucess", //paid, unpaid
      "tip_tax_amount": tipTaxAmount,
      "service_gst_tax_amount": gstServiceChargeTax,
      "delivery_charge_gst": gstDeliveryChargeTax,
      "cust_email": "",
      "payment_type": Get.find<PosController>().paymentTab == '' || !isPrepaid
          ? 'postpaid'
          : "prepaid",
      "discount_type":
          Get.find<CartController>().isApplyLoyalty ? 'Loyality' : '',
      "discount_value": _discountController.text.isNotEmpty
          ? double.parse(_discountController.text)
          : 0,
      "order_discount_type": selectedDiscountType,
      "order_note":
          _addNoteController.text.isEmpty ? '' : _addNoteController.text,

      'delivery_charge': '$deliveryCharge',
      'use_wallet_balance':
          Get.find<CartController>().isApplyWallet ? walletUsed : 0,

      "tax_amount": gstAmount + vatAmount + gstServiceChargeTax + tipTaxAmount,
      'order_sub_total_amount': orderItemTotal,
      'order_amount': Get.find<AuthController>()
                  .profileModel
                  ?.restaurants
                  ?.first
                  .isTotalRound ==
              'Yes'
          ? getRoundUpValue(value: orderPay)
          : orderPay.toStringAsFixed(2),
      'vat_tax': vatAmount,
      'gst_tax': gstAmount + tipTaxAmount + gstServiceChargeTax,

      if (widget.editOrder == null)
        'address_id': Get.find<TableController>().selectedTable?.id == 0 &&
                Get.find<TableController>().selectedTable?.tableNo == 'Delivery'
            ? selectedAddress!.id.toString()
            : '',
      if (widget.editOrder == null)
        'delivery_address': Get.find<TableController>().selectedTable?.id ==
                    0 &&
                Get.find<TableController>().selectedTable?.tableNo == 'Delivery'
            ? buildDeliveryAddressPayload()
            : '',
      'print_kot': isPrintKot ? 'Yes' : 'No',

      // 'self_discount': (isCouponValidate && _couponController.text.isNotEmpty)
      //     ? 0
      //     : orderDiscount,
      // 'coupon_discount': (isCouponValidate && _couponController.text.isNotEmpty)
      //     ? orderDiscount
      //     : 0,
      // 'coupon_title': (isCouponValidate && _couponController.text.isNotEmpty)
      //     ? _couponController.text
      //     : '',
      // 'coupon_type': (isCouponValidate && _couponController.text.isNotEmpty)
      //     ? couponDiscountType
      //     : '',
      'self_discount': orderDiscount,
      'coupon_code': (isPrepaid && isCouponValidate) ? crmCouponCode : '',
      'coupon_discount': (isPrepaid && isCouponValidate) ? crmCouponRupee : 0,
      'coupon_title': (isPrepaid && isCouponValidate) ? crmCouponTitle : '',
      'coupon_type': (isPrepaid && isCouponValidate) ? crmCouponScope : '',
      'round_up': getRoundUpAmount(orderPay),

      'order_type': Get.find<TableController>().selectedTable == null
          ? 'pos'
          : (Get.find<TableController>().selectedTable?.id == 0 &&
                  Get.find<TableController>().selectedTable?.tableNo ==
                      'Delivery')
              ? 'delivery'
              : (Get.find<TableController>().selectedTable?.id == 0 &&
                      Get.find<TableController>().selectedTable?.tableNo ==
                          'Take Away')
                  ? 'take_away'
                  : 'pos',
      if (widget.editOrder == null)
        "table_id": Get.find<TableController>().selectedTable?.id == 0
            ? '0'
            : Get.find<TableController>().selectedTable?.id.toString() ?? '0',
      'tip_amount': _addTips.text.isEmpty ? '0' : _addTips.text,
      'order_discount': orderDiscount,
      // 'used_loyalty_point':
      //     ((Get.find<CartController>().isApplyLoyalty) ? usedLoyaltyPoint : 0),
      'used_loyalty_point': (isPrepaid &&
              Get.find<CartController>().isApplyLoyalty &&
              !crmLoyaltyBelowMin)
          ? crmMaxPoints
          : 0,
      'loyalty_points_used': (isPrepaid &&
              Get.find<CartController>().isApplyLoyalty &&
              !crmLoyaltyBelowMin)
          ? crmMaxPoints
          : 0,
      'loyalty_discount': (isPrepaid &&
              Get.find<CartController>().isApplyLoyalty &&
              !crmLoyaltyBelowMin)
          ? crmLoyaltyDiscount
          : 0,
      'loyalty_redemption_id': null,
      'cust_mobile':
          _phoneController.text.isEmpty ? '' : _phoneController.text,
      'cust_name': _nameController.text.isEmpty ? '' : _nameController.text,
      if (widget.editOrder == null)
        'cust_dob': _dobController.text.isEmpty ? '' : _dobController.text,
      if (widget.editOrder == null)
        'cust_anniversary': _anniversaryController.text.isEmpty
            ? ''
            : _anniversaryController.text,
      'cust_membership_id': userId ?? '',
      'service_tax': Get.find<PosController>().isAddServiceCharge
          ? showServiceChargeValue
          : 0,
      if (widget.editOrder == null)
        'transaction_id': _transactionNoController.text.isEmpty
            ? ''
            : _transactionNoController.text,
      'room_id': '${Get.find<PosController>().selectedRoom?.table?.id ?? ''}',
      'auto_dispatch': Get.find<AuthController>()
              .profileModel!
              .restaurants
              ?.first
              .settings
              ?.autoDispatch ??
          'No',
      'discount_member_category_id':
          selectedDiscount == null ? 0 : selectedDiscount!.id,
      'discount_member_category_name':
          selectedDiscount == null ? '' : selectedDiscount!.discountType,
      'comm_discount': selectedDiscount == null ? 0 : orderDiscount,
      "usage_id": "",
      if (Get.find<PosController>().paymentTab.toLowerCase() == 'partial')
        'partial_payments': [
          {
            "payment_mode": "cash",
            "payment_amount": pCash.text,
            "grant_amount": pCash.text,
            "transaction_id": ""
          },
          {
            "payment_mode": "card",
            "payment_amount": pCard.text,
            "grant_amount": pCard.text,
            "transaction_id": pTXN.text
          },
          {
            "payment_mode": "upi",
            "payment_amount": pUpi.text,
            "grant_amount": pUpi.text,
            "transaction_id": ""
          }
        ],
    };
    if (isPrepaid) {
      if (Get.find<PosController>().paymentTab.toLowerCase() == 'cash' &&
          isPrepaid) {
        if (paidController.text.isEmpty) {
          showErrorToast('Please enter paid amount');
        } else if (double.parse(paidController.text) <
            (Get.find<AuthController>()
                        .profileModel
                        ?.restaurants
                        ?.first
                        .isTotalRound ==
                    'Yes'
                ? getRoundUpValue(
                    value: Get.find<PosController>().collectItemPrice)
                : Get.find<PosController>().collectItemPrice)) {
          showErrorToast('Paid amount cannot be less than bill amount');
        } else {
          orderSent = true;
          await callCollectBillApiNew(jsonbody);
        }
      } else if (Get.find<AuthController>()
              .profileModel!
              .restaurants!
              .first
              .settings!
              .autoPaid ==
          'Yes') {
        orderSent = true;
        await callCollectBillApiNew(jsonbody);
      } else if (Get.find<PosController>().paymentTab.toLowerCase() ==
              'partial' &&
          isPrepaid) {
        double totalPay = Get.find<PosController>().collectItemPrice;
        if (pCash.text.isEmpty) {
          showErrorToast('Please enter cash amount');
        } else if (pCard.text.isEmpty) {
          showErrorToast('Please enter card amount');
        } else if (pUpi.text.isEmpty) {
          showErrorToast('Please enter UPI amount');
        } else if (pCard.text.isNotEmpty &&
            pCard.text != '0' &&
            pTXN.text.isEmpty) {
          showErrorToast('Please enter transaction number for card payment');
        } else if (pCard.text.isNotEmpty &&
            pCard.text != '0' &&
            pTXN.text.isNotEmpty &&
            pTXN.text.trim().length < 4) {
          showErrorToast('Enter valid transaction number for card payment');
        } else {
          double totalPartialAmt = double.parse(pCash.text) +
              double.parse(pCard.text) +
              double.parse(pUpi.text);
          if (totalPartialAmt <
              (Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .isTotalRound ==
                      'Yes'
                  ? getRoundUpValue(value: totalPay)
                  : totalPay)) {
            showErrorToast(
                'Total partial amount cannot be less than bill amount');
          } else if (totalPartialAmt >
              (Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .isTotalRound ==
                      'Yes'
                  ? getRoundUpValue(value: totalPay)
                  : totalPay)) {
            showErrorToast(
                'Total partial amount cannot be greater than bill amount');
          } else {
            orderSent = true;
            await callCollectBillApiNew(jsonbody);
          }
        }
      } else if (Get.find<PosController>().paymentTab.toLowerCase() == 'card' &&
          isPrepaid) {
        if ((((_transactionNoController.text.isEmpty) ||
                _transactionNoController.text.trim().length < 4)) &&
            Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .edcDetail!
                    .pinelab !=
                'Yes') {
          showErrorToast('Please enter transaction number');
        } else {
          orderSent = true;
          await callCollectBillApiNew(jsonbody);
        }
      } else {
        orderSent = true;
        await callCollectBillApiNew(jsonbody);
      }
    } else {
      orderSent = true;
      await Get.find<CartController>().newPlaceOrder(callback,
          jsonBody: jsonbody,
          jsonFoodList: jsonCartList,
          isUpdate: widget.editOrder != null);
    }
    } finally {
      if (!orderSent) _releasePlaceOrderLock();
    }
  }

  callCollectBillApiNew(Map<String, dynamic> jsonData) async {
    print('this is callCollectBillApiNew');
    Restaurant restaurant =
        Get.find<AuthController>().profileModel!.restaurants!.first;

    // CRM records coupon usage when the paid order is committed.
    // if ((isCouponValidate && _couponController.text.isNotEmpty)) {
    if (false && (isCouponValidate && _couponController.text.isNotEmpty)) {
      var data = await Get.find<LoyaltyController>()
          .redeemCoupon(_couponController.text ?? '', userId);
      if (data.containsKey('message') &&
          data['message'] == 'Coupon redeemed successfully') {
        jsonData['usage_id'] = data['usage_id'];
        if (restaurant.edcDetail != null &&
            restaurant.edcDetail!.pinelab == 'Yes' &&
            restaurant.edcDetail!.pineLabDetail != null &&
            (jsonData['payment_method'] == 'card' ||
                jsonData['payment_method'] == 'upi')) {
          jsonData.addAll({
            "merchant_id": restaurant.edcDetail!.pineLabDetail!.merchantId,
            "security_token":
                restaurant.edcDetail!.pineLabDetail!.securityToken,
            "store_id": restaurant.edcDetail!.pineLabDetail!.storeId,
            "client_id": restaurant.edcDetail!.pineLabDetail!.clientId,
          });
          await Get.find<CartController>().edcPrepaidOrder(prepaidCallback,
              jsonBody: jsonData, jsonFoodList: jsonCartList);
        } else {
          await Get.find<CartController>().newPlaceOrder(prepaidCallback,
              jsonBody: jsonData,
              jsonFoodList: jsonCartList,
              isUpdate: widget.editOrder != null);
        }
        // await Get.find<CartController>().prepaidOrder(prepaidCallback,
        //     jsonBody: jsonData, jsonFoodList: jsonCartList);
      }
    } else {
      jsonData['usage_id'] = '';
      if (restaurant.edcDetail != null &&
          restaurant.edcDetail!.pinelab == 'Yes' &&
          restaurant.edcDetail!.pineLabDetail != null &&
          (jsonData['payment_method'] == 'card' ||
              jsonData['payment_method'] == 'upi')) {
        jsonData.addAll({
          "merchant_id": restaurant.edcDetail!.pineLabDetail!.merchantId,
          "security_token": restaurant.edcDetail!.pineLabDetail!.securityToken,
          "store_id": restaurant.edcDetail!.pineLabDetail!.storeId,
          "client_id": restaurant.edcDetail!.pineLabDetail!.clientId,
        });
        await Get.find<CartController>().edcPrepaidOrder(prepaidCallback,
            jsonBody: jsonData, jsonFoodList: jsonCartList);
      } else {
        await Get.find<CartController>().newPlaceOrder(prepaidCallback,
            jsonBody: jsonData,
            jsonFoodList: jsonCartList,
            isUpdate: widget.editOrder != null);
      }
    }
  }

  bool isShowPlaceOrder() {
    return isTextEmpty(_addTips.text) &&
        !isCouponValidate &&
        !Get.find<CartController>().isApplyLoyalty &&
        !Get.find<CartController>().isApplyWallet &&
        isTextEmpty(_discountController.text);
  }
}
