import 'dart:async';
import 'dart:io';
import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/data/model/response/get_paid_order_detail_response.dart'
    as paid;
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart'
    as profile;
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/printer_config.dart';
import 'package:mygenie_restaurant/util/windows_byte_convert.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image/image.dart' as prefix;
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/data/model/response/get_collect_bill_resoonse_model.dart';
import 'package:mygenie_restaurant/data/model/response/get_collect_bill_resoonse_model.dart'
    as p;
import 'package:mygenie_restaurant/data/model/response/get_room_bills_response_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/loyalty_controller.dart';
import 'package:mygenie_restaurant/view/screens/waiter/collect_payment/widget/payment_method_tab.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tablet_screen/payment_tab/tablet_payment_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../data/model/response/get_customer_list_response.dart';
import '../../../../data/model/response/search_customer_response_model.dart';
import '../../../../util/print_byte_convert.dart';
import '../../../../view/screens/custome management/controller/customer_management_controller.dart';

class PayLaterCollectBill extends StatefulWidget {
  final String? orderId;
  const PayLaterCollectBill({this.orderId});

  @override
  State<PayLaterCollectBill> createState() => _PayLaterCollectBillState();
}

class _PayLaterCollectBillState extends State<PayLaterCollectBill> {
  ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> jsonCartList = [];
  bool isCouponValidate = false;
  bool isPrint = true;
  bool isAutoBillPrint = false;
  bool isApplyDiscountForRoleBase = false;
  int currentPrintIndex = 0;
  bool isConnect = true;
  double roomTotalPaymnet = 0;
  double showServiceChargeValue = 0;
  double discountedOrderSubTotal = 0;
  double gstServiceChargeTax = 0;
  double walletBalance = 0;
  double walletUsed = 0;

  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _discountNoteController = TextEditingController();
  final TextEditingController _addTips = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cGSTController = TextEditingController();
  final TextEditingController _cGSTNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _anniversaryController = TextEditingController();
  final TextEditingController _memberIdController = TextEditingController();
  TextEditingController paidController = TextEditingController();
  TextEditingController changeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final TextEditingController _serviceChargeController =
      TextEditingController();
  TextEditingController _transactionNoController = TextEditingController();

  // Dropdown selection for Root
  String? _selectedDropdownOption;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  // String _countryDialCode;
  DiscountCategoryListModel? selectedDiscount;
  String selectedDiscountType = 'Fixed';
  List<String> discountType = ['No', 'Percent', 'Fixed'];
  PrinterManager printerManager = PrinterManager.instance;
  PrinterManager individualPrinter = PrinterManager.instance;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  StreamSubscription<BTStatus>? _singlePrintBtStatus;
  List<int>? pendingTask;
  BTStatus currentStatus = BTStatus.none;
  String couponDiscountType = '';
  double serviceChargePercentage = 0;
  double orderItemTotal = 0;
  double orderSubTotal = 0;
  double gstAmount = 0;
  double vatAmount = 0;
  double tipTaxAmount = 0;
  double availableLoyaltyPoint = 0;
  double usedLoyaltyPoint = 0;
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
  double loyaltyDiscountPercent = 0;
  // double gstTaxPercentage = 0;
  // double vatTaxPercentage = 0;
  // double foodTotalAmount = 0;
  // double barTotalAmount = 0;
  double orderDiscount = 0;
  double couponDiscount = 0;
  double coummunityDiscount = 0;
  double coummunityDiscountPercentage = 0;
  List<bool> isSelectPrinterList = [];
  List<bool> isPrinterProccessingList = [];
  List<bool> isPrintedList = [];
  String userId = '';
  @override
  void initState() {
    super.initState();
    initData();
  }

  listenBluetooth() async {
    for (var i = 0;
        i < Get.find<PosController>().roomBillsList.length + 2;
        i++) {
      isSelectPrinterList.add(i == 0 ? true : false);
      isPrintedList.add(false);
      isPrinterProccessingList.add(false);
      // if (widget.cartProductList[i].isNotEmpty) {
      //   printedTotal = printedTotal + 1;
      // }
    }
    Get.find<PosController>().hideLoader(false);

    if (Platform.isAndroid) {
      _subscriptionBtStatus =
          PrinterManager.instance.stateBluetooth.listen((status) async {
        if (status == BTStatus.connecting) {
          // isProcessing = true;
          // isPrinterProccessingList[currentPrintIndex] = true;
          // if (mounted) setState(() {});
        }
        if (status == BTStatus.connected) {
          isConnect = true;
          isPrinterProccessingList[currentPrintIndex] = false;
          // isProcessing = false;
          if (mounted) setState(() {});

          Future.delayed(const Duration(milliseconds: 1000), () async {
            // PrinterManager.instance
            //     .send(type: PrinterType.bluetooth, bytes: pendingTask);
            pendingTask = null;
          });
        } else if (status == BTStatus.none) {
          // if (!isConnect) {
          //   Future.delayed(Duration(seconds: 1), () async {
          //     isConnect = true;
          //     isPrinterProccessingList[currentPrintIndex] = false;
          //     currentPrintIndex = currentPrintIndex + 1;
          //     dataCheck();
          //   });
          // } else {
          //   isConnect = false;
          //   // isProcessing = false;
          //   isPrinterProccessingList[currentPrintIndex] = false;
          //   if (mounted) setState(() {});
          //   print('%%%%%%%%%');
          // }
        }
      });
    }
  }

  individualListenBluetooth() async {
    if (Platform.isAndroid) {
      _singlePrintBtStatus =
          individualPrinter.stateBluetooth.listen((status) async {
        if (status == BTStatus.connecting) {}
        if (status == BTStatus.connected) {
          isConnect = true;
          if (mounted) setState(() {});

          Future.delayed(const Duration(milliseconds: 1000), () async {
            individualPrinter.send(
                type: PrinterType.bluetooth, bytes: pendingTask ?? []);
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

  initData() async {
    profile.Restaurant restaurant =
        Get.find<AuthController>().profileModel!.restaurants!.first;
    serviceChargePercentage = restaurant.serviceChargePercentage!;
    _serviceChargeController.text = '$serviceChargePercentage';
    _discountController.text = '0';
    _addTips.text = '0';
    selectedDiscountType = restaurant.discountType!;
    isAutoBillPrint = restaurant.isAutoBillPrintBilling == 'Yes';
    Get.find<PosController>().applyLoyaltyValue(false);
    Get.find<PosController>().applyWalletBalance(false);
    Get.find<PosController>().disableEdcLoader(false);
    Get.find<CartController>().calculationCart();
    Get.find<PosController>().clearTableList();
    Get.find<PosController>().setRoomIndex(null);
    await Get.find<PosController>().getRoomList();
    // Get.find<PosController>().calculationCart();
    Get.find<PosController>().setPaymentTabName('');
    // if (restaurant.payCash == 'Yes') {
    //   Get.find<PosController>().setPaymentTabIndex(0);
    // } else if (restaurant.payCC == 'Yes') {
    //   Get.find<PosController>().setPaymentTabIndex(1);
    // } else if (restaurant.payUpi == 'Yes') {
    //   Get.find<PosController>().setPaymentTabIndex(2);
    // } else if (restaurant.payTab == 'Yes') {
    //   Get.find<PosController>().setPaymentTabIndex(3);
    // }
    await Get.find<PosController>()
        .getCollectBillDetail({'order_id': '${widget.orderId}'});

    if (Get.find<PosController>()
                .getCollectBillDetailResponse!
                .orders
                ?.orderDetailsOrder
                ?.orderType ==
            'delivery' ||
        Get.find<PosController>()
                .getCollectBillDetailResponse!
                .orders
                ?.orderDetailsOrder
                ?.orderType ==
            'take_away') serviceChargePercentage = 0;
    if (Get.find<PosController>().roomBillsList.isNotEmpty) {
      for (var e in Get.find<PosController>().roomBillsList) {
        roomTotalPaymnet = roomTotalPaymnet + double.parse(e.orderAmount!);
      }
    }

    final orders =
        Get.find<PosController>().getCollectBillDetailResponse?.orders;
    if (orders?.orderDetailsOrder!.appliedCouponCode != null &&
        orders?.orderDetailsOrder!.appliedCouponCode != '') {
      _couponController.text = orders!.orderDetailsOrder!.appliedCouponCode!;
      // isCouponValidate = true;
    }
    userId = '${orders?.orderDetailsOrder?.userId ?? ''}';
    if (orders?.orderDetailsOrder?.username != null &&
        orders!.orderDetailsOrder!.username != '') {
      _nameController.text = orders.orderDetailsOrder!.username ?? '';
    }
    if (orders?.orderUser != null) {
      _phoneController.text = orders!.orderUser!.phone ?? '';
      emailController.text = orders.orderUser!.email ?? '';
      if (orders.orderUser!.userGst != '')
        _cGSTController.text = orders.orderUser?.userGst ?? '';
      if (orders.orderUser!.userGstName != '')
        _cGSTNameController.text = orders.orderUser?.userGstName ?? '';
      if (orders.orderUser!.dateOfBirth != '')
        _dobController.text = orders.orderUser?.dateOfBirth ?? '';
      if (orders.orderUser!.dateOfAnniversary != '')
        _anniversaryController.text = orders.orderUser?.dateOfAnniversary ?? '';
      if (orders.orderUser!.membershipId != '')
        _memberIdController.text = orders.orderUser?.membershipId ?? '';

      // Set dropdown selection based on membershipId
      if (orders.orderUser!.membershipId != '') {
        String memberId = orders.orderUser?.membershipId ?? '';

        _selectedDropdownOption = memberId;
      }

      // coummunityDiscountPercentage = orders.orderUser!.discount ?? 0.0;
    }

    if (orders?.deliveryAddress != null &&
        orders!.deliveryAddress!.phone != null &&
        orders!.deliveryAddress!.phone != '') {
      _phoneController.text = orders.deliveryAddress!.phone ?? '';
      _nameController.text = orders.deliveryAddress!.name ?? '';
      _dobController.text = orders.deliveryAddress!.dob ?? '';
      _anniversaryController.text = orders.deliveryAddress!.doa ?? '';
      _selectedDropdownOption = orders.deliveryAddress!.membershipId ?? '';
    }
    // if (orders!.orderDiscountJson != null &&
    //     Get.find<AuthController>()
    //             .profileModel!
    //             .restaurants!
    //             .first
    //             .settings!
    //             .isRoleBaseDiscount ==
    //         'Yes') {
    selectedDiscountType =
        orders?.orderDetailsOrder?.orderDiscountValueType ?? 'Percent';

    if (selectedDiscountType == 'Percent') {
      final categoryKey =
          (orders?.orderDetailsOrder?.discountMemberCategory ?? '')
              .trim()
              .toLowerCase();

      selectedDiscount = Get.find<AuthController>()
          .profileModel!
          .discountList!
          .cast<DiscountCategoryListModel?>()
          .firstWhere(
            (item) =>
                (item?.discountType ?? '').trim().toLowerCase() == categoryKey,
            orElse: () => null,
          );
    } else {
      selectedDiscount = null;
    }

    _discountController.text =
        orders?.orderDetailsOrder?.orderDiscountValue ?? '0';
    // if (orders?.orderDiscountJson!.discountAmount != 0) {
    //   isApplyDiscountForRoleBase = true;
    // }
    // if (orders?.orderDiscountJson!.discountNote != '') {
    //   _discountNoteController.text =
    //       orders?.orderDiscountJson?.discountNote ?? '';
    // }
    // }
    _addTips.text = orders?.orderDetailsOrder!.tipAmount ?? '0';
    // Get.find<PosController>().changeServeiceChargeValue(
    //     orders?.orderDetailsOrder?.serviceChargeAmount != '' &&
    //             orders?.orderDetailsOrder?.serviceChargeAmount != '0'
    //         ? true
    //         : false);
    Get.find<PosController>().changeServeiceChargeValue(
        (Get.find<PosController>()
                        .getCollectBillDetailResponse!
                        .orders
                        ?.orderDetailsOrder
                        ?.orderType !=
                    'delivery' &&
                Get.find<PosController>()
                        .getCollectBillDetailResponse!
                        .orders
                        ?.orderDetailsOrder
                        ?.orderType !=
                    'take_away' &&
                restaurant.serviceCharge == 'Yes' &&
                restaurant.autoServiceCharge == 'Yes')
            ? true
            : false);
    amountCalculation();
    if (Get.find<PosController>().roomBillsList.isNotEmpty) {
      await listenBluetooth();
    } else {
      Get.find<PosController>().hideLoader(false);
      individualListenBluetooth();
    }
    await Get.find<PosController>().getTapManageMentCustomerList();
    if (orders!.orderDetailsOrder!.userId != null &&
        orders.orderDetailsOrder!.userId != '' &&
        Get.find<AuthController>()
                .profileModel!
                .restaurants!
                .first
                .settings!
                .isCustomerWallet ==
            'Yes') {
      var data = await Get.find<CartController>()
          .getWalletBalanceOfCustomer('${orders.orderDetailsOrder!.userId}');
      if (data != {} && data.containsKey('balance')) {
        // usedLoyaltyPoint = double.parse('${data['pointsToRedeem'] ?? 0}');
        walletBalance = double.parse('${data['balance'] ?? 0}');
      }
    }
    if (orders.orderDetailsOrder!.userId != null &&
        orders.orderDetailsOrder!.userId != '' &&
        (Get.find<AuthController>()
                .profileModel!
                .restaurants!
                .first
                .settings!
                .isLoyality ==
            'Yes')) {
      // var data = await Get.find<LoyaltyController>().checkValidLoyaltyPoint(
      //     '${orders.orderDetailsOrder!.userId}',
      //     Get.find<PosController>().collectItemPrice,
      //     isLoading: false);
      // if (data != {} && data.containsKey('pointsToRedeem')) {
      //   availableLoyaltyPoint = double.parse('${data['availablePoints'] ?? 0}');
      // }
      _crmOfferKey = '';
      _scheduleCrmOffers();
    }
  }

  @override
  void dispose() {
    _crmOfferDebounce?.cancel();
    _subscriptionBtStatus?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: Icon(Icons.chevron_left, size: 40),
              color: ColorTheme.green,
              onPressed: () {
                Get.back();
              }),
          titleSpacing: 0,
          elevation: 0,
          centerTitle: false,
          title: Column(
            children: [
              MediaQuery.of(context).size.width > 650
                  ? SizedBox(
                      child: Image.asset(
                        logoHelper.appLogo!,
                        width: Get.width * 0.13,
                      ),
                    )
                  : SizedBox(
                      child: Image.asset(
                        logoHelper.appLogo!,
                        width: Get.width * 0.3,
                        // height: Get.height / 10.72,
                      ),
                    ),
            ],
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            reverse: true,
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            physics: BouncingScrollPhysics(),
            child: Center(
              child:
                  GetBuilder<LoyaltyController>(builder: (loyaltyController) {
                return GetBuilder<PosController>(builder: (posController) {
                  return (loyaltyController.isLoading ||
                          posController.isLoading)
                      ? Center(child: CircularProgressIndicator())
                      : Column(children: [
                          Padding(
                            padding: EdgeInsets.only(left: 30, right: 30),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Collect Payment',
                                  style: poppinsSemiBold.copyWith(fontSize: 15),
                                ),
                                Spacer(),
                                if (Get.find<AuthController>()
                                    .profileModel!
                                    .role!
                                    .contains('complementary_food'))
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 20),
                                    child: InkWell(
                                        onTap: () async {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          List<OrderDetailsBar> tempOrder =
                                              await posController
                                                  .seprateFoodBasedOnFoodQty(
                                                      posController
                                                          .getCollectBillDetailResponse!
                                                          .orders!
                                                          .orderDetailsBar);
                                          if (!posController.isEDCLoading) {
                                            await Get.bottomSheet(
                                                complementryFoodBottomSheet(
                                                    posController, tempOrder),
                                                backgroundColor:
                                                    Colors.transparent,
                                                isScrollControlled: true,
                                                ignoreSafeArea: false);
                                          }
                                        },
                                        child: Icon(
                                            Icons.free_breakfast_outlined,
                                            color: ColorTheme.appColor,
                                            size: 30)),
                                  ),
                                InkWell(
                                    onTap: () async {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      if (!posController.isEDCLoading) {
                                        await Get.find<CartController>()
                                            .getCustomerFromApi();
                                        await Get.find<
                                                CustomerManagementController>()
                                            .getCustomerDesignationList();

                                        Get.bottomSheet(editUserBottomSheet(),
                                            backgroundColor: Colors.transparent,
                                            isScrollControlled: true,
                                            ignoreSafeArea: false);
                                      }
                                    },
                                    child: Icon(Icons.manage_accounts,
                                        color: ColorTheme.appColor, size: 30))
                              ],
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Divider(color: ColorTheme.borderGrey)),
                          // SizedBox(height: Get.height * 0.04),
                          if (posController
                                      .getCollectBillDetailResponse!
                                      .orders!
                                      .restaurantDetails!
                                      .restaurantOrderFor ==
                                  'ROOM' &&
                              posController.roomBillsList.isNotEmpty)
                            previousBill(),
                          // if (foodTotalAmount + barTotalAmount != 0)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: ColorTheme.bgSettleCardGreyColor),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: MediaQuery.of(context)
                                                    .size
                                                    .shortestSide >
                                                570
                                            ? Get.width * 0.2
                                            : 15),
                                    child: Text(
                                      'Order Id: ${posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.restaurantOrderId == '0' ? (posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.id ?? '') : (posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.restaurantOrderId ?? '')}',
                                      style: poppinsSemiBold.copyWith(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .shortestSide >
                                                  570
                                              ? 17
                                              : 16,
                                          color: ColorTheme.appColor),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                if (posController
                                            .getCollectBillDetailResponse
                                            ?.orders
                                            ?.restaurantDetails
                                            ?.restaurantOrderFor ==
                                        'ROOM' &&
                                    (posController.getCollectBillDetailResponse
                                                ?.orders?.roomInfo !=
                                            null &&
                                        posController
                                                .getCollectBillDetailResponse
                                                ?.orders
                                                ?.roomInfo
                                                ?.roomPrice !=
                                            0))
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 8,
                                        left: MediaQuery.of(context)
                                                    .size
                                                    .shortestSide >
                                                570
                                            ? Get.width * 0.2
                                            : 15,
                                        right: MediaQuery.of(context)
                                                    .size
                                                    .shortestSide >
                                                570
                                            ? Get.width * 0.2
                                            : 15),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Room Check-in ',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 17
                                                        : 11),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        SizedBox(
                                          width: 50,
                                          child: Text(
                                              posController
                                                  .getCollectBillDetailResponse!
                                                  .orders!
                                                  .roomInfo!
                                                  .roomPrice
                                                  .toStringAsFixed(1),
                                              style: poppinsSemiBold.copyWith(
                                                  color: Colors.black,
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 16
                                                      : 11),
                                              textAlign: TextAlign.right),
                                        ),
                                      ],
                                    ),
                                  ),

                                Padding(
                                  padding: EdgeInsets.only(
                                      left: MediaQuery.of(context)
                                                  .size
                                                  .shortestSide >
                                              570
                                          ? Get.width * 0.2
                                          : 15,
                                      right: MediaQuery.of(context)
                                                  .size
                                                  .shortestSide >
                                              570
                                          ? Get.width * 0.2
                                          : 15),
                                  child: ListView.builder(
                                      itemCount: posController
                                              .getCollectBillDetailResponse
                                              ?.orders
                                              ?.mergeFoodList
                                              .length ??
                                          0,
                                      shrinkWrap: true,
                                      physics: BouncingScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int i) {
                                        OrderDetailsBar orderDetailsFood =
                                            posController
                                                .getCollectBillDetailResponse!
                                                .orders!
                                                .mergeFoodList[i];
                                        String variationText = '';
                                        double variationTotal = 0;
                                        double addonsTotal = 0;
                                        double halfVariationPrice = 0;

                                        if (orderDetailsFood.variation !=
                                                null &&
                                            orderDetailsFood
                                                .variation!.isNotEmpty) {
                                          for (int j = 0;
                                              j <
                                                  orderDetailsFood
                                                      .variation!.length;
                                              j++) {
                                            variationText +=
                                                '${variationText.isNotEmpty ? ', ' : ''}${orderDetailsFood.variation![j].name} (';

                                            if (orderDetailsFood
                                                    .variation![j].values !=
                                                null) {
                                              List<String> labelList = [];
                                              if (orderDetailsFood
                                                      .variation![j].values !=
                                                  null) {
                                                for (var element
                                                    in orderDetailsFood
                                                        .variation![j]
                                                        .values!) {
                                                  labelList
                                                      .add(element.level ?? '');
                                                  // variationTotal += (int.parse(
                                                  //         element.optionPrice) *
                                                  //     orderDetailsFood.quantity);
                                                  final variationName =
                                                      orderDetailsFood
                                                              .variation![j]
                                                              .name ??
                                                          '';
                                                  final optionPrice =
                                                      double.tryParse(element
                                                                  .optionPrice ??
                                                              '0') ??
                                                          0.0;
                                                  final quantity =
                                                      orderDetailsFood
                                                              .quantity ??
                                                          0;
                                                  if (variationName
                                                          .toUpperCase() ==
                                                      'HALFNHALF') {
                                                    if (halfVariationPrice <
                                                        optionPrice *
                                                            quantity) {
                                                      halfVariationPrice =
                                                          optionPrice *
                                                              quantity;
                                                    }
                                                  } else {
                                                    variationTotal =
                                                        variationTotal +
                                                            optionPrice *
                                                                quantity;
                                                  }
                                                }
                                              }
                                              variationText +=
                                                  '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                                            }

                                            variationText += ')';
                                            variationTotal = variationTotal +
                                                halfVariationPrice;
                                          }
                                        }

                                        String addons = '';
                                        if (orderDetailsFood.addOns != null) {
                                          for (var i = 0;
                                              i <
                                                  (orderDetailsFood
                                                          .addOns?.length ??
                                                      0);
                                              i++) {
                                            final addOn =
                                                orderDetailsFood.addOns![i];
                                            final addOnPrice = addOn.price ?? 0;
                                            final addOnQuantity =
                                                addOn.quantity ?? 0;
                                            final foodQuantity =
                                                orderDetailsFood.quantity ?? 0;
                                            addonsTotal = addonsTotal +
                                                ((addOnPrice * addOnQuantity) *
                                                    foodQuantity);
                                            addons +=
                                                '${addOn.name ?? ''} (${addOnQuantity})';
                                          }
                                        }
                                        return orderDetailsFood
                                                    .foodDetails!['name']
                                                    .toString()
                                                    .toLowerCase() ==
                                                'check in'
                                            ? SizedBox.shrink()
                                            : Padding(
                                                padding: EdgeInsets.only(
                                                    top: i == 0 ? 0 : 8),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '${orderDetailsFood.foodDetails!['name'] ?? ''} (${orderDetailsFood.quantity ?? ''})',
                                                            style: poppinsMedium.copyWith(
                                                                color: orderDetailsFood.isComplementary!
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .black,
                                                                decoration: orderDetailsFood
                                                                            .foodStatus ==
                                                                        3
                                                                    ? TextDecoration
                                                                        .lineThrough
                                                                    : TextDecoration
                                                                        .none,
                                                                fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .shortestSide >
                                                                        570
                                                                    ? 17
                                                                    : 11),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          addons == ''
                                                              ? SizedBox
                                                                  .shrink()
                                                              : Text.rich(
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            'Add-Ons :',
                                                                        style: poppinsMedium.copyWith(
                                                                            decoration: orderDetailsFood.foodStatus == 3
                                                                                ? TextDecoration.lineThrough
                                                                                : TextDecoration.none,
                                                                            fontSize: MediaQuery.of(context).size.shortestSide > 570 ? 14 : 10,
                                                                            color: ColorTheme.blue),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            ' $addons',
                                                                        style: poppinsMedium
                                                                            .copyWith(
                                                                          decoration: orderDetailsFood.foodStatus == 3
                                                                              ? TextDecoration.lineThrough
                                                                              : TextDecoration.none,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          fontSize: MediaQuery.of(context).size.shortestSide > 570
                                                                              ? 13
                                                                              : 10,
                                                                          color:
                                                                              ColorTheme.green,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                          variationText == ''
                                                              ? SizedBox
                                                                  .shrink()
                                                              : Text.rich(
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            'Variants  :',
                                                                        style: poppinsMedium.copyWith(
                                                                            decoration: orderDetailsFood.foodStatus == 3
                                                                                ? TextDecoration.lineThrough
                                                                                : TextDecoration.none,
                                                                            fontSize: MediaQuery.of(context).size.shortestSide > 570 ? 14 : 10,
                                                                            color: ColorTheme.blue),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            ' $variationText',
                                                                        style: poppinsMedium.copyWith(
                                                                            decoration: orderDetailsFood.foodStatus == 3
                                                                                ? TextDecoration.lineThrough
                                                                                : TextDecoration.none,
                                                                            fontSize: MediaQuery.of(context).size.shortestSide > 570 ? 13 : 10,
                                                                            color: ColorTheme.green),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                          if ((posController
                                                                          .getCollectBillDetailResponse
                                                                          ?.orders
                                                                          ?.orderDetailsOrder
                                                                          ?.orderNote ??
                                                                      '') !=
                                                                  '' &&
                                                              (orderDetailsFood
                                                                      .foodDetails?[
                                                                          'name']
                                                                      ?.toString()
                                                                      .toLowerCase()
                                                                      .contains(
                                                                          'out of') ??
                                                                  false))
                                                            Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        'Notes  :',
                                                                    style: poppinsMedium.copyWith(
                                                                        decoration: orderDetailsFood.foodStatus ==
                                                                                3
                                                                            ? TextDecoration
                                                                                .lineThrough
                                                                            : TextDecoration
                                                                                .none,
                                                                        fontSize: MediaQuery.of(context).size.shortestSide >
                                                                                570
                                                                            ? 14
                                                                            : 10,
                                                                        color: ColorTheme
                                                                            .blue),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        ' ${posController.getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderNote ?? ''}',
                                                                    style: poppinsMedium.copyWith(
                                                                        decoration: orderDetailsFood.foodStatus ==
                                                                                3
                                                                            ? TextDecoration
                                                                                .lineThrough
                                                                            : TextDecoration
                                                                                .none,
                                                                        fontSize: MediaQuery.of(context).size.shortestSide >
                                                                                570
                                                                            ? 13
                                                                            : 10,
                                                                        color: ColorTheme
                                                                            .green),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    SizedBox(
                                                      width: 50,
                                                      child: Text(
                                                          '${((orderDetailsFood.unitPrice ?? 0) * (orderDetailsFood.quantity ?? 0) + variationTotal + addonsTotal)}',
                                                          style: poppinsSemiBold.copyWith(
                                                              decoration: orderDetailsFood
                                                                          .foodStatus ==
                                                                      3
                                                                  ? TextDecoration
                                                                      .lineThrough
                                                                  : TextDecoration
                                                                      .none,
                                                              color: orderDetailsFood
                                                                      .isComplementary!
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .black,
                                                              fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .shortestSide >
                                                                      570
                                                                  ? 16
                                                                  : 11),
                                                          textAlign:
                                                              TextAlign.right),
                                                    ),
                                                  ],
                                                ),
                                              );
                                      }),
                                ),

                                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  child: DottedLine(
                                    direction: Axis.horizontal,
                                    alignment: WrapAlignment.center,
                                    lineThickness: 1.0,
                                    dashLength: 2.5,
                                    dashColor: ColorTheme.hintText,
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text('Item Total',
                                            textAlign: TextAlign.right,
                                            style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 15
                                                    : 11)),
                                        Text(
                                            ' :   ' +
                                                PriceConverter.convertPrice(
                                                    orderItemTotal +
                                                        (posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.roomInfo
                                                                ?.roomPrice ??
                                                            0),
                                                    isHideCurrency: true,
                                                    asFixed: 2),
                                            style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 15
                                                    : 11)),
                                      ]),
                                ),

                                if (Get.find<AuthController>()
                                        .profileModel!
                                        .restaurants!
                                        .first
                                        .settings!
                                        .isCoupon ==
                                    'Yes')
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15, top: 10),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('Coupon Code',
                                              textAlign: TextAlign.right,
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11)),
                                          Container(
                                            margin: EdgeInsets.only(
                                                right: 10, left: 10),
                                            width: Get.width * 0.3,
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .shortestSide >
                                                    570
                                                ? 40
                                                : 25,
                                            child: TextField(
                                              controller: _couponController,
                                              autofocus: false,
                                              decoration: InputDecoration(
                                                // hintText: 'phone'.tr,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: Dimensions
                                                            .PADDING_SIZE_EXTRA_SMALL),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  borderSide: BorderSide(
                                                      style: BorderStyle.none,
                                                      width: 0),
                                                ),
                                                hintStyle: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 11,
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
                                                    : 11,
                                              ),
                                              onChanged: (s) async {
                                                // _discountController.text = '0';
                                                // if (isCouponValidate) {
                                                //   couponDiscountType = '';
                                                //   usedLoyaltyPoint = 0;
                                                //   posController.applyLoyaltyValue(false);
                                                //   amountCalculation();
                                                //   if (mounted) setState(() {});
                                                // }
                                                isCouponValidate = false;
                                                crmCouponRupee = 0;
                                                crmCouponCode = '';
                                                crmCouponTitle = '';
                                                crmCouponBenefit = '';
                                                if (mounted) setState(() {});
                                                amountCalculation();
                                              },
                                            ),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                border: Border.all(
                                                    color:
                                                        ColorTheme.borderGrey)),
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              if (!posController.isEDCLoading) {
                                                double orderAmount = (orderItemTotal +
                                                    (posController
                                                            .getCollectBillDetailResponse
                                                            ?.orders
                                                            ?.orderDetailsOrder
                                                            ?.deliveryCharge ??
                                                        0) +
                                                    (Get.find<PosController>()
                                                            .getCollectBillDetailResponse
                                                            ?.orders
                                                            ?.roomInfo
                                                            ?.remainingPay ??
                                                        0) +
                                                    roomTotalPaymnet);
                                                // ignore: unused_local_variable
                                                String orderType = (posController
                                                            .getCollectBillDetailResponse!
                                                            .orders
                                                            ?.orderDetailsOrder
                                                            ?.orderType ==
                                                        'delivery')
                                                    ? 'delivery'
                                                    : (posController
                                                                .getCollectBillDetailResponse!
                                                                .orders
                                                                ?.orderDetailsOrder
                                                                ?.orderType ==
                                                            'take_away')
                                                        ? 'takeaway'
                                                        : 'dine in';
                                                if (userId == '') {
                                                  showErrorToast(
                                                      'Please select customer for applying coupon');
                                                } else if (_couponController
                                                    .text.isEmpty) {
                                                  showErrorToast(
                                                      'Please enter coupon code');
                                                } else {
                                                  // var data = await Get.find<LoyaltyController>()
                                                  //     .checkValidCoupon(_couponController.text, orderType, userId, orderAmount);
                                                  // if (data['message'] == 'Coupon is valid') {
                                                  //   selectedDiscountType = data['discount_type'] == 'percentage' ? 'Percent' : 'Fixed';
                                                  //   couponDiscountType = data['discount_type'];
                                                  //   _discountController.text = '${data['discount_value']}';
                                                  //   usedLoyaltyPoint = 0;
                                                  //   posController.applyLoyaltyValue(false);
                                                  //   isCouponValidate = true;
                                                  //   amountCalculation();
                                                  // }
                                                  await _applyCrmCoupon();
                                                  //     });
                                                  //   }
                                                  // }
                                                }
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 7, vertical: 5),
                                              decoration: BoxDecoration(
                                                  color: isCouponValidate
                                                      ? Colors.white
                                                      : ColorTheme.appColor,
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                  border: Border.all(
                                                      color:
                                                          ColorTheme.appColor)),
                                              child: Text(
                                                  isCouponValidate
                                                      ? 'Applied'
                                                      : 'Apply',
                                                  textAlign: TextAlign.right,
                                                  style: poppinsMedium.copyWith(
                                                      color: isCouponValidate
                                                          ? ColorTheme.appColor
                                                          : Colors.white,
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .shortestSide >
                                                              570
                                                          ? 15
                                                          : 11)),
                                            ),
                                          )
                                        ]),
                                  ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: IntrinsicWidth(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
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
                                      if (!posController.isEDCLoading) {
                                        // posController.applyLoyaltyValue(
                                        //     posController.isApplyLoyalty ? false : true);
                                        // if (userId != '' && posController.isApplyLoyalty) {
                                        //   var data = await Get.find<LoyaltyController>()
                                        //       .checkValidLoyaltyPoint('$userId', posController.collectItemPrice);
                                        //   if (data.containsKey('pointsToRedeem')) {
                                        //     usedLoyaltyPoint = double.parse('${data['pointsToRedeem'] ?? 0}');
                                        //     amountCalculation();
                                        //   }
                                        // } else {
                                        //   usedLoyaltyPoint = 0;
                                        //   amountCalculation();
                                        // }
                                        _toggleCrmLoyalty();
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 6),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Checkbox(
                                                value: posController
                                                    .isApplyLoyalty,
                                                onChanged: (val) async {
                                                  if (!posController
                                                      .isEDCLoading) {
                                                    // posController.applyLoyaltyValue(
                                                    //     posController.isApplyLoyalty ? false : true);
                                                    // if (userId != '' && posController.isApplyLoyalty) {
                                                    //   var data = await Get.find<LoyaltyController>()
                                                    //       .checkValidLoyaltyPoint('$userId', posController.collectItemPrice);
                                                    //   if (data.containsKey('pointsToRedeem')) {
                                                    //     usedLoyaltyPoint = double.parse('${data['pointsToRedeem'] ?? 0}');
                                                    //   }
                                                    //   amountCalculation();
                                                    // } else {
                                                    //   usedLoyaltyPoint = 0;
                                                    //   amountCalculation();
                                                    // }
                                                    _toggleCrmLoyalty();
                                                  }
                                                }),
                                            Text('Apply Loyalty Reimbursement',
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11,
                                                )),
                                            Text(
                                                ' :  ${crmLoyaltyDiscount.toStringAsFixed(2)}',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
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
                                        crmAvailablePoints > 0))
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4),
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
                                          if (crmLoyaltyHint.isEmpty ||
                                              crmEarnPoints > 0)
                                            Text(
                                              crmLoyaltyHint.isNotEmpty
                                                  ? 'You’ll earn $crmEarnPoints pts on this order'
                                                  : '${crmLoyaltyTier.isEmpty ? '' : '$crmLoyaltyTier · '}${crmAvailablePoints.toStringAsFixed(0)} pts · You’ll earn $crmEarnPoints pts',
                                              textAlign: TextAlign.left,
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
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
                                      if (!posController.isEDCLoading) {
                                        posController.applyWalletBalance(
                                            posController.isApplyWallet
                                                ? false
                                                : true);

                                        amountCalculation();
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Checkbox(
                                                value:
                                                    posController.isApplyWallet,
                                                onChanged: (val) async {
                                                  if (!posController
                                                      .isEDCLoading) {
                                                    posController
                                                        .applyWalletBalance(
                                                            posController
                                                                    .isApplyWallet
                                                                ? false
                                                                : true);
                                                    amountCalculation();
                                                  }
                                                }),
                                            Text('Wallet Balance',
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11,
                                                )),
                                            Text(
                                                ' :  ${walletBalance.toStringAsFixed(2)}',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 11)),
                                          ]),
                                    ),
                                  ),
                                if (posController.isApplyWallet)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15, top: 0),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('(Remaining wallet balance',
                                              textAlign: TextAlign.right,
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11)),
                                          Text(
                                              ' :  ${(walletBalance - walletUsed).toStringAsFixed(2)})',
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11)),
                                        ]),
                                  ),
                                // if (coummunityDiscount != 0)
                                // Padding(
                                //   padding: const EdgeInsets.only(
                                //       right: 15, top: 5),
                                //   child: Row(
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.end,
                                //       children: [
                                //         Text('Community Discount'.tr,
                                //             textAlign: TextAlign.right,
                                //             style: poppinsMedium.copyWith(
                                //                 fontSize: MediaQuery.of(
                                //                                 context)
                                //                             .size
                                //                             .shortestSide >
                                //                         570
                                //                     ? 15
                                //                     : 11)),
                                //         Text(
                                //             ' :   ' +
                                //                 PriceConverter.convertPrice(
                                //                     coummunityDiscount,
                                //                     isHideCurrency: true,
                                //                     asFixed: 2),
                                //             style: poppinsMedium.copyWith(
                                //                 fontSize: MediaQuery.of(
                                //                                 context)
                                //                             .size
                                //                             .shortestSide >
                                //                         570
                                //                     ? 15
                                //                     : 11)),
                                //       ]),
                                // ),
                                if (posController
                                            .getCollectBillDetailResponse
                                            ?.orders
                                            ?.restaurantDetails
                                            ?.restaurantOrderFor ==
                                        'ROOM' &&
                                    (posController.getCollectBillDetailResponse
                                                ?.orders?.roomInfo !=
                                            null &&
                                        posController
                                                .getCollectBillDetailResponse
                                                ?.orders
                                                ?.roomInfo
                                                ?.advancePay !=
                                            0))
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15, top: 10),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('Room Advance'.tr,
                                              textAlign: TextAlign.right,
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11)),
                                          Text(
                                              ' :   ' +
                                                  PriceConverter.convertPrice(
                                                      posController
                                                          .getCollectBillDetailResponse!
                                                          .orders!
                                                          .roomInfo!
                                                          .advancePay,
                                                      isHideCurrency: true,
                                                      asFixed: 2),
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11)),
                                        ]),
                                  ),
                                if (posController
                                            .getCollectBillDetailResponse
                                            ?.orders
                                            ?.restaurantDetails
                                            ?.restaurantOrderFor ==
                                        'ROOM' &&
                                    (posController.getCollectBillDetailResponse
                                                ?.orders?.roomInfo !=
                                            null &&
                                        posController
                                                .getCollectBillDetailResponse
                                                ?.orders
                                                ?.roomInfo
                                                ?.gstTaxAmount !=
                                            0))
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15, top: 10),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('Room GST'.tr,
                                              textAlign: TextAlign.right,
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11)),
                                          Text(
                                              ' :   ' +
                                                  PriceConverter.convertPrice(
                                                      posController
                                                          .getCollectBillDetailResponse!
                                                          .orders!
                                                          .roomInfo!
                                                          .gstTaxAmount,
                                                      isHideCurrency: true,
                                                      asFixed: 2),
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11)),
                                        ]),
                                  ),
                                if (posController
                                            .getCollectBillDetailResponse
                                            ?.orders
                                            ?.restaurantDetails
                                            ?.restaurantOrderFor ==
                                        'ROOM' &&
                                    (posController.getCollectBillDetailResponse
                                                ?.orders?.roomInfo !=
                                            null &&
                                        posController
                                                .getCollectBillDetailResponse
                                                ?.orders
                                                ?.roomInfo
                                                ?.remainingPay !=
                                            0))
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15, top: 10),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('Room Pending'.tr,
                                              textAlign: TextAlign.right,
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11)),
                                          Text(
                                              ' :   ' +
                                                  PriceConverter.convertPrice(
                                                      posController
                                                          .getCollectBillDetailResponse!
                                                          .orders!
                                                          .roomInfo!
                                                          .remainingPay,
                                                      isHideCurrency: true,
                                                      asFixed: 2),
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11)),
                                        ]),
                                  ),

                                if ((selectedDiscountType == 'Percent' &&
                                        Get.find<AuthController>()
                                                .profileModel!
                                                .discountList !=
                                            null &&
                                        !isCouponValidate &&
                                        Get.find<AuthController>()
                                            .profileModel!
                                            .discountList!
                                            .isNotEmpty) &&
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
                                    padding: const EdgeInsets.only(
                                        right: 15, top: 10),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                              'Discount Category'
                                              ' : ',
                                              textAlign: TextAlign.right,
                                              style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 15
                                                    : 11,
                                              )),
                                          Container(
                                            margin: EdgeInsets.only(left: 10),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 7),
                                            width: Get.width * 0.35,
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .shortestSide >
                                                    570
                                                ? 40
                                                : 25,
                                            child: DropdownButton<
                                                DiscountCategoryListModel>(
                                              isExpanded: true,
                                              underline: SizedBox.shrink(),
                                              style: poppinsMedium.copyWith(
                                                color: Colors.black,
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 15
                                                    : 11,
                                              ),
                                              value: selectedDiscount,
                                              hint: Text("Discount"),
                                              onChanged:
                                                  (DiscountCategoryListModel?
                                                      newValue) {
                                                selectedDiscount = newValue;
                                                if (newValue == null) {
                                                  _discountController.text =
                                                      '0';

                                                  // remove discount category
                                                  selectedDiscount = null;

                                                  amountCalculation();
                                                  Get.find<PosController>()
                                                      .update();
                                                  return;
                                                }
                                                _discountController.text =
                                                    newValue!.discount!;
                                                amountCalculation();
                                                posController.update();
                                                // setState(() {
                                                //   selectedCategory = newValue;
                                                // });
                                              },
                                              // items: Get.find<AuthController>()
                                              //     .profileModel!
                                              //     .discountList!
                                              //     .map<
                                              //         DropdownMenuItem<
                                              //             DiscountCategoryListModel>>(
                                              //   (DiscountCategoryListModel
                                              //       category) {
                                              //     return DropdownMenuItem<
                                              //         DiscountCategoryListModel>(
                                              //       value: category,
                                              //       child: Text(
                                              //           category.discountType!),
                                              //     );
                                              //   },
                                              // ).toList(),
                                              items: [
                                                DropdownMenuItem<
                                                    DiscountCategoryListModel>(
                                                  value: null,
                                                  child: Text(
                                                      'Select Discount Category'),
                                                ),
                                                ...Get.find<AuthController>()
                                                    .profileModel!
                                                    .discountList!
                                                    .map<
                                                        DropdownMenuItem<
                                                            DiscountCategoryListModel>>(
                                                  (DiscountCategoryListModel
                                                      category) {
                                                    return DropdownMenuItem<
                                                        DiscountCategoryListModel>(
                                                      value: category,
                                                      child: Text(category
                                                          .discountType!),
                                                    );
                                                  },
                                                ).toList(),
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                border: Border.all(
                                                    color:
                                                        ColorTheme.borderGrey)),
                                          ),
                                        ]),
                                  ),

                                // SizedBox(height: 10),

                                if ((Get.find<AuthController>()
                                                .profileModel!
                                                .restaurants!
                                                .first
                                                .discountType !=
                                            'No' &&
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
                                    padding: const EdgeInsets.only(
                                        right: 15, top: 10),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                              'Discount Type'
                                              ' : ',
                                              textAlign: TextAlign.right,
                                              style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 15
                                                    : 11,
                                              )),
                                          Container(
                                            margin: EdgeInsets.only(left: 10),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 7),
                                            width: Get.width * 0.35,
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .shortestSide >
                                                    570
                                                ? 40
                                                : 25,
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              underline: SizedBox.shrink(),
                                              style: poppinsMedium.copyWith(
                                                color: Colors.black,
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 15
                                                    : 11,
                                              ),
                                              value: selectedDiscountType,
                                              hint: Text("Discount"),
                                              onChanged: (String? newValue) {
                                                selectedDiscountType =
                                                    newValue!;
                                                _discountController.text = '0';
                                                usedLoyaltyPoint = 0;
                                                if (posController
                                                    .isApplyLoyalty)
                                                  posController
                                                      .applyLoyaltyValue(false);
                                                amountCalculation();
                                                posController.update();
                                                // setState(() {
                                                //   selectedCategory = newValue;
                                                // });
                                              },
                                              items: discountType.map<
                                                  DropdownMenuItem<String>>(
                                                (String category) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: category,
                                                    child: Text(category),
                                                  );
                                                },
                                              ).toList(),
                                            ),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                border: Border.all(
                                                    color:
                                                        ColorTheme.borderGrey)),
                                          ),
                                        ]),
                                  ),
                                if ((Get.find<AuthController>()
                                                .profileModel!
                                                .restaurants!
                                                .first
                                                .discountType !=
                                            'No' &&
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
                                    padding: const EdgeInsets.only(
                                        right: 15, top: 10),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                              Get.find<AuthController>()
                                                      .profileModel!
                                                      .restaurants!
                                                      .first
                                                      .discountText! +
                                                  ' : ',
                                              textAlign: TextAlign.right,
                                              style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 15
                                                    : 11,
                                              )),
                                          Container(
                                            margin: EdgeInsets.only(left: 10),
                                            width: Get.width * 0.2,
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .shortestSide >
                                                    570
                                                ? 40
                                                : 25,
                                            child: TextField(
                                              controller: _discountController,
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      signed: true),
                                              autofocus: false,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(
                                                        r'^\d*\.?\d{0,4}')),
                                              ],
                                              decoration: InputDecoration(
                                                // hintText: 'phone'.tr,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: Dimensions
                                                            .PADDING_SIZE_EXTRA_SMALL),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  borderSide: BorderSide(
                                                      style: BorderStyle.none,
                                                      width: 0),
                                                ),
                                                hintStyle: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 11,
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
                                                    : 11,
                                              ),
                                              onChanged: (value) async {
                                                usedLoyaltyPoint = 0;
                                                if (isApplyDiscountForRoleBase) {
                                                  isApplyDiscountForRoleBase =
                                                      false;
                                                  var jsonData = {
                                                    "order_id": widget.orderId,
                                                    "discount_amount": 0,
                                                    "discount_type": 'percent',
                                                    "discount_note": ""
                                                  };
                                                  await posController
                                                      .applyDiscountForRoleBase(
                                                          jsonData: jsonData);
                                                }

                                                if (posController
                                                    .isApplyLoyalty)
                                                  posController
                                                      .applyLoyaltyValue(false);

                                                amountCalculation();
                                              },
                                            ),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                border: Border.all(
                                                    color:
                                                        ColorTheme.borderGrey)),
                                          ),
                                        ]),
                                  ),

                                if (isCouponValidate)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15, top: 10),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                              // 'Coupon Discount ${(selectedDiscountType == 'Percent') ? '(${_discountController.text}%)' : ''} ',
                                              crmCouponTitle.isEmpty
                                                  ? 'Coupon Discount'
                                                  : crmCouponTitle,
                                              textAlign: TextAlign.right,
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11)),
                                          Text(
                                              ' :   ' +
                                                  PriceConverter.convertPrice(
                                                      // couponDiscount,
                                                      crmCouponRupee,
                                                      isHideCurrency: true,
                                                      asFixed: 2),
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11)),
                                        ]),
                                  ),
                                if (Get.find<AuthController>()
                                            .profileModel!
                                            .restaurants!
                                            .first
                                            .settings!
                                            .isRoleBaseDiscount ==
                                        'Yes' &&
                                    !Get.find<AuthController>()
                                        .profileModel!
                                        .role!
                                        .contains('discount'))
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15, top: 10),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                              'Order Discount Applied${(selectedDiscountType == 'Percent') ? '(${_discountController.text}%)' : ''} ',
                                              textAlign: TextAlign.right,
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11)),
                                          Text(
                                              ' :   ' +
                                                  PriceConverter.convertPrice(
                                                      orderDiscount,
                                                      isHideCurrency: true,
                                                      asFixed: 2),
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11)),
                                        ]),
                                  ),
                                if (Get.find<AuthController>()
                                            .profileModel!
                                            .restaurants!
                                            .first
                                            .settings!
                                            .isRoleBaseDiscount ==
                                        'Yes' &&
                                    !Get.find<AuthController>()
                                        .profileModel!
                                        .role!
                                        .contains('discount'))
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 15, top: 10),
                                      child: Text(
                                          'Order Discount Note :  ${_discountNoteController.text}',
                                          textAlign: TextAlign.right,
                                          style: poppinsMedium.copyWith(
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .shortestSide >
                                                      570
                                                  ? 15
                                                  : 11)),
                                    ),
                                  ),

                                if (Get.find<AuthController>()
                                            .profileModel!
                                            .restaurants!
                                            .first
                                            .isShowTips ==
                                        'Yes' &&
                                    Get.find<PosController>()
                                            .getCollectBillDetailResponse!
                                            .orders
                                            ?.orderDetailsOrder
                                            ?.orderType !=
                                        'delivery' &&
                                    Get.find<PosController>()
                                            .getCollectBillDetailResponse!
                                            .orders
                                            ?.orderDetailsOrder
                                            ?.orderType !=
                                        'take_away')
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15, top: 10),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('Add tips : ',
                                              textAlign: TextAlign.right,
                                              style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 15
                                                    : 11,
                                              )),
                                          Container(
                                            margin: EdgeInsets.only(left: 10),
                                            width: Get.width * 0.2,
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .shortestSide >
                                                    570
                                                ? 40
                                                : 25,
                                            child: TextField(
                                              controller: _addTips,
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      signed: true),
                                              autofocus: false,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly, // Allow only digits
                                              ],
                                              decoration: InputDecoration(
                                                // hintText: 'phone'.tr,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: Dimensions
                                                            .PADDING_SIZE_EXTRA_SMALL),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  borderSide: BorderSide(
                                                      style: BorderStyle.none,
                                                      width: 0),
                                                ),
                                                hintStyle: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 11,
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
                                                    : 11,
                                              ),
                                              onChanged: (value) async {
                                                usedLoyaltyPoint = 0;
                                                if (posController
                                                    .isApplyLoyalty)
                                                  posController
                                                      .applyLoyaltyValue(false);

                                                amountCalculation();
                                              },
                                            ),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                border: Border.all(
                                                    color:
                                                        ColorTheme.borderGrey)),
                                          ),
                                        ]),
                                  ),

                                if (Get.find<AuthController>()
                                        .profileModel!
                                        .role!
                                        .contains('discount') &&
                                    Get.find<AuthController>()
                                            .profileModel!
                                            .restaurants!
                                            .first
                                            .settings!
                                            .isRoleBaseDiscount ==
                                        'Yes')
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15, top: 10),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('Discount Note :  ',
                                              textAlign: TextAlign.right,
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11)),
                                          Container(
                                            margin: EdgeInsets.only(left: 10),
                                            width: Get.width * 0.35,
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .shortestSide >
                                                    570
                                                ? 40
                                                : 25,
                                            child: TextField(
                                                controller:
                                                    _discountNoteController,
                                                autofocus: false,
                                                decoration: InputDecoration(
                                                  // hintText: 'phone'.tr,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: Dimensions
                                                              .PADDING_SIZE_EXTRA_SMALL),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    borderSide: BorderSide(
                                                        style: BorderStyle.none,
                                                        width: 0),
                                                  ),
                                                  hintStyle: poppinsMedium.copyWith(
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .shortestSide >
                                                              570
                                                          ? 15
                                                          : 11,
                                                      color:
                                                          ColorTheme.hintText),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                                style: poppinsMedium.copyWith(
                                                  color: Colors.black,
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11,
                                                ),
                                                onChanged: (s) async {}),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                border: Border.all(
                                                    color:
                                                        ColorTheme.borderGrey)),
                                          ),
                                        ]),
                                  ),

                                if (Get.find<AuthController>()
                                        .profileModel!
                                        .role!
                                        .contains('discount') &&
                                    Get.find<AuthController>()
                                            .profileModel!
                                            .restaurants!
                                            .first
                                            .settings!
                                            .isRoleBaseDiscount ==
                                        'Yes')
                                  InkWell(
                                    onTap: () async {
                                      amountCalculation();
                                      if (_discountController.text == '') {
                                        showErrorToast(
                                            'Please enter discount amount');
                                      } else if (double.parse(
                                              _discountController.text) ==
                                          0) {
                                        showErrorToast(
                                            'Please enter discount amount');
                                      } else if (selectedDiscountType ==
                                              'Percent' &&
                                          _discountController.text.isNotEmpty &&
                                          double.parse(
                                                  _discountController.text) >
                                              100) {
                                        showErrorToast(
                                            'Please enter valid discount');
                                      } else {
                                        isApplyDiscountForRoleBase =
                                            isApplyDiscountForRoleBase
                                                ? false
                                                : true;
                                        var jsonData = {
                                          "order_id": widget.orderId,
                                          "discount_amount":
                                              !isApplyDiscountForRoleBase
                                                  ? 0
                                                  : double.parse(
                                                      _discountController.text),
                                          // "discount_amount":
                                          //     selectedDiscountType == 'Percent'
                                          //         ? double.parse(
                                          //             _discountController.text)
                                          //         : double.parse(((double.parse(
                                          //                         _discountController
                                          //                             .text) /
                                          //                     orderSubTotal) *
                                          //                 100)
                                          //             .toStringAsFixed(2)),
                                          "discount_type":
                                              selectedDiscountType == 'Percent'
                                                  ? 'percent'
                                                  : 'fixed',
                                          "discount_note":
                                              !isApplyDiscountForRoleBase
                                                  ? ''
                                                  : _discountNoteController.text
                                        };
                                        await posController
                                            .applyDiscountForRoleBase(
                                                jsonData: jsonData);
                                        if (mounted) setState(() {});
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Checkbox(
                                                value:
                                                    isApplyDiscountForRoleBase,
                                                onChanged: (val) async {
                                                  amountCalculation();
                                                  if (_discountController
                                                          .text ==
                                                      '') {
                                                    showErrorToast(
                                                        'Please enter discount amount');
                                                  } else if (double.parse(
                                                          _discountController
                                                              .text) ==
                                                      0) {
                                                    showErrorToast(
                                                        'Please enter discount amount');
                                                  } else if (selectedDiscountType ==
                                                          'Percent' &&
                                                      _discountController
                                                          .text.isNotEmpty &&
                                                      double.parse(
                                                              _discountController
                                                                  .text) >
                                                          100) {
                                                    showErrorToast(
                                                        'Please enter valid discount');
                                                  } else {
                                                    isApplyDiscountForRoleBase =
                                                        isApplyDiscountForRoleBase
                                                            ? false
                                                            : true;
                                                    var jsonData = {
                                                      "order_id":
                                                          widget.orderId,
                                                      "discount_amount":
                                                          !isApplyDiscountForRoleBase
                                                              ? 0
                                                              : double.parse(
                                                                  _discountController
                                                                      .text),
                                                      // "discount_amount": selectedDiscountType ==
                                                      //         'Percent'
                                                      //     ? double.parse(
                                                      //         _discountController
                                                      //             .text)
                                                      //     : double.parse(((double.parse(
                                                      //                     _discountController
                                                      //                         .text) /
                                                      //                 orderSubTotal) *
                                                      //             100)
                                                      //         .toStringAsFixed(
                                                      //             2)),
                                                      "discount_type":
                                                          selectedDiscountType ==
                                                                  'Percent'
                                                              ? 'percent'
                                                              : 'fixed',
                                                      "discount_note":
                                                          !isApplyDiscountForRoleBase
                                                              ? ''
                                                              : _discountNoteController
                                                                  .text
                                                    };
                                                    await posController
                                                        .applyDiscountForRoleBase(
                                                            jsonData: jsonData);
                                                    if (mounted)
                                                      setState(() {});
                                                  }
                                                }),
                                            Text('Apply Discount',
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11,
                                                )),
                                          ]),
                                    ),
                                  ),
                                if (Get.find<AuthController>()
                                        .profileModel!
                                        .restaurants!
                                        .first
                                        .serviceCharge ==
                                    'Yes')
                                  if (Get.find<PosController>()
                                              .getCollectBillDetailResponse!
                                              .orders
                                              ?.orderDetailsOrder
                                              ?.orderType !=
                                          'delivery' &&
                                      Get.find<PosController>()
                                              .getCollectBillDetailResponse!
                                              .orders
                                              ?.orderDetailsOrder
                                              ?.orderType !=
                                          'take_away')
                                    Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Checkbox(
                                                value: posController
                                                    .isAddServiceCharge,
                                                onChanged: (val) {
                                                  posController
                                                      .changeServeiceChargeValue(
                                                          val!);
                                                  usedLoyaltyPoint = 0;
                                                  if (posController
                                                      .isApplyLoyalty)
                                                    posController
                                                        .applyLoyaltyValue(
                                                            false);

                                                  amountCalculation();
                                                }),
                                            Text(
                                                '${Get.find<AuthController>().profileModel!.restaurants!.first.settings?.serviceChrgTaxt}',
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11,
                                                )),
                                            Text(
                                                ' :  ${showServiceChargeValue.toStringAsFixed(2)}',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 11)),
                                          ]),
                                    ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Checkbox(
                                            value: isAutoBillPrint,
                                            onChanged: (val) {
                                              isAutoBillPrint = val!;
                                              if (mounted) setState(() {});
                                            }),
                                        Text('Auto Bill Print',
                                            textAlign: TextAlign.right,
                                            style: poppinsMedium.copyWith(
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .shortestSide >
                                                      570
                                                  ? 15
                                                  : 11,
                                            )),
                                      ]),
                                ),
                                // if (Get.find<PosController>()
                                //             ?.getCollectBillDetailResponse
                                //             ?.orders
                                //             ?.orderDetailsOrder
                                //             ?.orderType !=
                                //         'delivery' &&
                                //     Get.find<PosController>()
                                //             ?.getCollectBillDetailResponse
                                //             ?.orders
                                //             ?.orderDetailsOrder
                                //             ?.orderType !=
                                //         'take_away')

                                if (Get.find<PosController>()
                                        .getCollectBillDetailResponse!
                                        .orders
                                        ?.orderDetailsOrder
                                        ?.orderType ==
                                    'delivery')
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15, top: 10, bottom: 10),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('Delivery Charge',
                                              textAlign: TextAlign.right,
                                              style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 15
                                                    : 11,
                                              )),
                                          Text(
                                              ' :   ${Get.find<PosController>().getCollectBillDetailResponse?.orders?.orderDetailsOrder?.deliveryCharge}',
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11)),
                                        ]),
                                  ),
                                // if (posController.getCollectBillDetailResponse !=
                                //         null &&
                                //     posController
                                //             .getCollectBillDetailResponse
                                //             .orders
                                //             .restaurantDetails
                                //             .restaurantOrderFor ==
                                //         'ROOM' &&
                                //     (posController.getCollectBillDetailResponse
                                //                 .orders.roomInfo !=
                                //             null &&
                                //         posController.getCollectBillDetailResponse
                                //                 .orders.roomInfo.gstTaxAmount !=
                                //             0))
                                //   Padding(
                                //     padding: const EdgeInsets.only(
                                //         right: 15, top: 5, bottom: 10),
                                //     child: Row(
                                //         mainAxisAlignment: MainAxisAlignment.end,
                                //         children: [
                                //           Text('Room GST'.tr,
                                //               textAlign: TextAlign.right,
                                //               style: poppinsMedium.copyWith(
                                //                   fontSize: MediaQuery.of(context)
                                //                               .size
                                //                               .shortestSide >
                                //                           570
                                //                       ? 15
                                //                       : 11)),
                                //           Text(
                                //               ' :   ' +
                                //                   PriceConverter.convertPrice(
                                //                       posController
                                //                           .getCollectBillDetailResponse
                                //                           .orders
                                //                           .roomInfo
                                //                           .gstTaxAmount,
                                //                       isHideCurrency: true,
                                //                       asFixed: 2),
                                //               style: poppinsMedium.copyWith(
                                //                   fontSize: MediaQuery.of(context)
                                //                               .size
                                //                               .shortestSide >
                                //                           570
                                //                       ? 15
                                //                       : 11)),
                                //         ]),
                                //   ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text('Sub Total',
                                            textAlign: TextAlign.right,
                                            style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 15
                                                    : 11)),
                                        Text(
                                            ' :   ' +
                                                PriceConverter.convertPrice(
                                                    orderSubTotal +
                                                        showServiceChargeValue +
                                                        (double.parse(_addTips
                                                                .text.isEmpty
                                                            ? "0"
                                                            : _addTips.text)) +
                                                        (posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.orderDetailsOrder
                                                                ?.deliveryCharge ??
                                                            0) +
                                                        (posController
                                                                .getCollectBillDetailResponse
                                                                ?.orders
                                                                ?.roomInfo
                                                                ?.roomPrice ??
                                                            0) -
                                                        ((posController
                                                                    .isApplyLoyalty &&
                                                                !crmLoyaltyBelowMin &&
                                                                crmLoyaltyDiscount >
                                                                    0)
                                                            ? crmLoyaltyDiscount
                                                            : 0) -
                                                        ((isCouponValidate &&
                                                                crmCouponRupee >
                                                                    0)
                                                            ? crmCouponRupee
                                                            : 0),
                                                    isHideCurrency: true,
                                                    asFixed: 2),
                                            style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 15
                                                    : 11)),
                                      ]),
                                ),
                                if ((gstAmount +
                                        gstServiceChargeTax +
                                        tipTaxAmount) !=
                                    0)
                                  Padding(
                                    padding:
                                        EdgeInsets.only(right: 15, top: 10),
                                    child: Column(
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text('CGST(2.5%)',
                                                  textAlign: TextAlign.right,
                                                  style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 11,
                                                  )),
                                              Text(
                                                  ' :   ${((gstAmount + gstServiceChargeTax + tipTaxAmount) / 2).toStringAsFixed(2)}',
                                                  style: poppinsMedium.copyWith(
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .shortestSide >
                                                              570
                                                          ? 15
                                                          : 11)),
                                            ]),
                                        SizedBox(height: 10),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text('SGST(2.5%)',
                                                  textAlign: TextAlign.right,
                                                  style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 11,
                                                  )),
                                              Text(
                                                  ' :   ${((gstAmount + gstServiceChargeTax + tipTaxAmount) / 2).toStringAsFixed(2)}',
                                                  style: poppinsMedium.copyWith(
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .shortestSide >
                                                              570
                                                          ? 15
                                                          : 11)),
                                            ]),
                                      ],
                                    ),
                                  ),
                                // SizedBox(
                                //     height: Dimensions
                                //         .PADDING_SIZE_SMALL),
                                if (vatAmount != 0)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15, top: 10),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('VAT'.tr,
                                              textAlign: TextAlign.right,
                                              style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 15
                                                    : 11,
                                              )),
                                          Text(' :   $vatAmount',
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11)),
                                        ]),
                                  ),
                                // if (availableLoyaltyPoint != 0)
                                if (false && availableLoyaltyPoint != 0)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15, top: 0),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('(Available loyalty points',
                                              textAlign: TextAlign.right,
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11)),
                                          Text(
                                              ' :  ${availableLoyaltyPoint.toStringAsFixed(2)})',
                                              style: poppinsMedium.copyWith(
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 15
                                                      : 11)),
                                        ]),
                                  ),

                                Padding(
                                  padding:
                                      const EdgeInsets.only(right: 15, top: 20),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text('Total'.tr,
                                            textAlign: TextAlign.right,
                                            style: poppinsBold.copyWith(
                                              color: ColorTheme.green,
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .shortestSide >
                                                      570
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
                                                    ? '${getRoundUpValue(value: (posController.collectItemPrice))} (${PriceConverter.convertPrice((posController.collectItemPrice), isHideCurrency: true, asFixed: 2)})'
                                                    : PriceConverter.convertPrice(
                                                        (posController
                                                            .collectItemPrice),
                                                        isHideCurrency: true,
                                                        asFixed: 2)),
                                            style: poppinsBold.copyWith(
                                                color: ColorTheme.green,
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 17
                                                    : 14)),
                                      ]),
                                ),
                                if (roomTotalPaymnet != 0)
                                  Padding(
                                    padding:
                                        EdgeInsets.only(right: 15, top: 10),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('Grand Total'.tr,
                                              textAlign: TextAlign.right,
                                              style: poppinsBold.copyWith(
                                                color: ColorTheme.green,
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 17
                                                    : 14,
                                              )),
                                          Text(
                                              ' :  ' +
                                                  PriceConverter.convertPrice(
                                                      (posController
                                                              .collectItemPrice +
                                                          roomTotalPaymnet),
                                                      isHideCurrency: true,
                                                      asFixed: 2),
                                              style: poppinsBold.copyWith(
                                                  color: ColorTheme.green,
                                                  fontSize: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 17
                                                      : 14)),
                                        ]),
                                  ),
                              ],
                            ),
                          ),

                          MediaQuery.of(context).size.shortestSide > 570
                              ? TabletSelectPaymentMethodTab(
                                  printCallbak: (data) async {
                                    if (data != null && data) {
                                      await Get.bottomSheet(
                                          printSummaryDialog(),
                                          isDismissible: false,
                                          backgroundColor: Colors.transparent,
                                          isScrollControlled: true,
                                          ignoreSafeArea: false);
                                    }
                                  },
                                  discountType: selectedDiscountType,
                                  orderSubTotal: orderSubTotal +
                                      showServiceChargeValue +
                                      (double.parse(_addTips.text.isEmpty
                                          ? "0"
                                          : _addTips.text)) +
                                      (posController
                                              .getCollectBillDetailResponse
                                              ?.orders
                                              ?.orderDetailsOrder
                                              ?.deliveryCharge ??
                                          0) +
                                      (posController
                                              .getCollectBillDetailResponse
                                              ?.orders
                                              ?.roomInfo
                                              ?.roomPrice ??
                                          0) -
                                      ((posController.isApplyLoyalty &&
                                              !crmLoyaltyBelowMin &&
                                              crmLoyaltyDiscount > 0)
                                          ? crmLoyaltyDiscount
                                          : 0) -
                                      ((isCouponValidate && crmCouponRupee > 0)
                                          ? crmCouponRupee
                                          : 0),
                                  couponDiscountType: couponDiscountType,
                                  ispayRoom: Get.find<PosController>()
                                          .getCollectBillDetailResponse!
                                          .orders!
                                          .restaurantDetails!
                                          .restaurantOrderFor ==
                                      'ROOM',
                                  isLoyaltyApply: posController.isApplyLoyalty,
                                  // loyltyDiscountAmount:
                                  //     posController.isApplyLoyalty ? usedLoyaltyPoint : 0,
                                  loyltyDiscountAmount:
                                      posController.isApplyLoyalty
                                          ? crmLoyaltyDiscount
                                          : 0,
                                  crmLoyaltyPoints: posController.isApplyLoyalty
                                      ? crmMaxPoints
                                      : 0,
                                  crmCouponCode:
                                      isCouponValidate ? crmCouponCode : '',
                                  crmCouponTitle:
                                      isCouponValidate ? crmCouponTitle : '',
                                  crmCouponScope:
                                      isCouponValidate ? crmCouponScope : '',
                                  crmCouponRupee:
                                      isCouponValidate ? crmCouponRupee : 0,
                                  couponUserId: userId,
                                  tipTaxAmount: tipTaxAmount,
                                  couponController: _couponController,
                                  isCouponValid: isCouponValidate,
                                  cGstNameController: _cGSTNameController,
                                  jsonCartList: jsonCartList,
                                  roomTotalPayment: roomTotalPaymnet,
                                  emailController: emailController,
                                  tipsController: _addTips,
                                  coummunityDiscount: coummunityDiscount,
                                  printerManager: individualPrinter,
                                  orderId: widget.orderId!,
                                  usedWalletAmount: walletUsed,
                                  isPrint: isPrint,
                                  discountPercent: _discountController
                                          .text.isNotEmpty
                                      ? double.parse(_discountController.text)
                                      : 0,
                                  cGstNoController: _cGSTController,
                                  posController: posController,
                                  discountController:
                                      _discountController.text.isEmpty
                                          ? TextEditingController(text: '0')
                                          : _discountController,
                                  gstAmount: gstAmount,
                                  isFromPaylater: true,
                                  selectedDiscountType: selectedDiscountType,
                                  nameController: _nameController,
                                  orderDiscount: orderDiscount,
                                  selectedDiscount: selectedDiscount,
                                  orderItemTotal: orderItemTotal,
                                  orderTotal: discountedOrderSubTotal,
                                  phoneController: _phoneController,
                                  changeController: changeController,
                                  paidController: paidController,
                                  serviceValue: showServiceChargeValue,
                                  coummunityDiscountPercentage:
                                      coummunityDiscountPercentage,
                                  transactionNoController:
                                      _transactionNoController,
                                  vatAmount: vatAmount,
                                  isAutoBillPrint: isAutoBillPrint,
                                  pendingTask: pendingTask ?? [],
                                )
                              : SelectPaymentMethodTab(
                                  printCallbak: (data) async {
                                    if (data != null && data) {
                                      await Get.bottomSheet(
                                          printSummaryDialog(),
                                          isDismissible: false,
                                          backgroundColor: Colors.transparent,
                                          isScrollControlled: true,
                                          ignoreSafeArea: false);
                                    }
                                  },
                                  discountType: selectedDiscountType,
                                  isFromPaylater: true,
                                  couponDiscountType: couponDiscountType,
                                  usedWalletAmount: walletUsed,
                                  jsonCartList: jsonCartList,
                                  ispayRoom: Get.find<PosController>()
                                          .getCollectBillDetailResponse!
                                          .orders!
                                          .restaurantDetails!
                                          .restaurantOrderFor ==
                                      'ROOM',
                                  couponUserId: userId,
                                  isLoyaltyApply: posController.isApplyLoyalty,
                                  // loyltyDiscountAmount:
                                  //     posController.isApplyLoyalty ? usedLoyaltyPoint : 0,
                                  loyltyDiscountAmount:
                                      posController.isApplyLoyalty
                                          ? crmLoyaltyDiscount
                                          : 0,
                                  crmLoyaltyPoints: posController.isApplyLoyalty
                                      ? crmMaxPoints
                                      : 0,
                                  crmCouponCode:
                                      isCouponValidate ? crmCouponCode : '',
                                  crmCouponTitle:
                                      isCouponValidate ? crmCouponTitle : '',
                                  crmCouponScope:
                                      isCouponValidate ? crmCouponScope : '',
                                  crmCouponRupee:
                                      isCouponValidate ? crmCouponRupee : 0,
                                  couponController: _couponController,
                                  isCouponValid: isCouponValidate,
                                  cGstNoController: _cGSTController,
                                  tipTaxAmount: tipTaxAmount,
                                  isAutoBillPrint: isAutoBillPrint,
                                  roomTotalPayment: roomTotalPaymnet,
                                  emailController: emailController,
                                  tipsController: _addTips,
                                  coummunityDiscount: coummunityDiscount,
                                  printerManager: individualPrinter,
                                  orderId: widget.orderId,
                                  discountPercent: _discountController
                                          .text.isNotEmpty
                                      ? double.parse(_discountController.text)
                                      : 0,
                                  isPrint: isPrint,
                                  selectedDiscountType: selectedDiscountType,
                                  posController: posController,
                                  discountController:
                                      _discountController.text.isEmpty
                                          ? TextEditingController(text: '0')
                                          : _discountController,
                                  gstAmount: gstAmount,
                                  nameController: _nameController,
                                  orderDiscount: orderDiscount,
                                  selectedDiscount: selectedDiscount,
                                  orderItemTotal: orderItemTotal,
                                  orderTotal: discountedOrderSubTotal,
                                  phoneController: _phoneController,
                                  changeController: changeController,
                                  paidController: paidController,
                                  serviceValue: showServiceChargeValue,
                                  coummunityDiscountPercentage:
                                      coummunityDiscountPercentage,
                                  transactionNoController:
                                      _transactionNoController,
                                  vatAmount: vatAmount,
                                  orderSubTotal: orderSubTotal +
                                      showServiceChargeValue +
                                      (double.parse(_addTips.text.isEmpty
                                          ? "0"
                                          : _addTips.text)) +
                                      (posController
                                              .getCollectBillDetailResponse
                                              ?.orders
                                              ?.orderDetailsOrder
                                              ?.deliveryCharge ??
                                          0) +
                                      (posController
                                              .getCollectBillDetailResponse
                                              ?.orders
                                              ?.roomInfo
                                              ?.roomPrice ??
                                          0) -
                                      ((posController.isApplyLoyalty &&
                                              !crmLoyaltyBelowMin &&
                                              crmLoyaltyDiscount > 0)
                                          ? crmLoyaltyDiscount
                                          : 0) -
                                      ((isCouponValidate && crmCouponRupee > 0)
                                          ? crmCouponRupee
                                          : 0),
                                  pendingTask: pendingTask,
                                ),
                        ]);
                });
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget previousBill() {
    // print('calling previous ....................');

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: 15, right: 15),
          padding: EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: ColorTheme.bgSettleCardGreyColor),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.shortestSide > 570
                          ? Get.width * 0.2
                          : 15),
                  child: Text(
                    'Previous Bills',
                    style: poppinsSemiBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 17
                            : 15,
                        color: ColorTheme.appColor),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.shortestSide > 570
                        ? Get.width * 0.2
                        : 15,
                    bottom: 10,
                    right: MediaQuery.of(context).size.shortestSide > 570
                        ? Get.width * 0.2
                        : 15),
                child: ListView.builder(
                    itemCount:
                        Get.find<PosController>().roomBillsList.length ?? 0,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int i) {
                      GetRoomBillsResponseModel? customerData =
                          Get.find<PosController>().roomBillsList[i];
                      return customerData.orderId ==
                              Get.find<PosController>()
                                  .getCollectBillDetailResponse!
                                  .orders!
                                  .orderDetailsOrder!
                                  .id!
                          ? SizedBox.shrink()
                          : Padding(
                              padding: EdgeInsets.only(top: i == 0 ? 11 : 15),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    child: Text(
                                      '${i + 1}',
                                      style: poppinsMedium.copyWith(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .shortestSide >
                                                  570
                                              ? 16
                                              : 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${customerData.restaurantOrderId == '0' ? customerData.orderId : customerData.restaurantOrderId}',
                                      style: poppinsMedium.copyWith(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .shortestSide >
                                                  570
                                              ? 16
                                              : 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      double.parse(customerData.orderAmount!)
                                          .toStringAsFixed(2),
                                      style: poppinsMedium.copyWith(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .shortestSide >
                                                  570
                                              ? 16
                                              : 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      customerData.createdAt == ''
                                          ? ''
                                          : '${DateFormat('dd-MMM').format(DateTime.parse(customerData.createdAt!))}',
                                      style: poppinsMedium.copyWith(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .shortestSide >
                                                  570
                                              ? 16
                                              : 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    flex: 2,
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        // MediaQuery.of(context)
                                        //             .size
                                        //             .shortestSide >
                                        //         570
                                        //     ?
                                        //      Get.toNamed(RouteHelper
                                        //         .getTabletTabBillDetail(
                                        //             '${customerData.orederId}',
                                        //             '',
                                        //             ''))
                                        //     :
                                        Get.toNamed(
                                            RouteHelper.getTabBillDetail(
                                                '${customerData.orderId}',
                                                '',
                                                ''));
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: Dimensions
                                                .PADDING_SIZE_EXTRA_SMALL,
                                            horizontal: 13),
                                        decoration: BoxDecoration(
                                            color: ColorTheme.appColor,
                                            // border:
                                            //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                        child: Center(
                                          child: Text(
                                            'Detail',
                                            style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 16
                                                    : 12,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                    }),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: DottedLine(
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            lineThickness: 1.0,
            dashLength: 2.5,
            dashColor: ColorTheme.hintText,
          ),
        )
      ],
    );
  }

  String _collectCrmChannel() {
    final type = Get.find<PosController>()
            .getCollectBillDetailResponse
            ?.orders
            ?.orderDetailsOrder
            ?.orderType ??
        '';
    return LoyaltyController.crmOrderChannel(type.toString());
  }

  double _crmBillBase() {
    final manual = orderDiscount < 0 ? 0.0 : orderDiscount;
    final base = orderItemTotal - manual;
    return base < 0 ? 0 : base;
  }

  List<Map<String, dynamic>> _crmBillItems() {
    final orders =
        Get.find<PosController>().getCollectBillDetailResponse?.orders;
    final foods = ((orders?.mergeFoodList ?? []).isNotEmpty)
        ? orders!.mergeFoodList
        : (orders?.orderDetailsBar ?? []);
    return foods.map((food) {
      final qty = (food.quantity ?? 0).toDouble();
      final price = food.unitPrice ?? 0;
      return {
        'food_id': '${food.foodId ?? ''}',
        'item_id': '${food.id ?? food.foodId ?? ''}',
        'name': food.foodDetails?['name']?.toString() ?? '',
        'quantity': qty,
        'unit_price': price,
        'line_total': price * qty,
        'category_name': food.foodDetails?['category_name']?.toString() ?? '',
        'give_discount': food.foodDetails?['give_discount']?.toString() ?? 'Yes',
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
        final loyaltyOn = Get.find<PosController>().isApplyLoyalty;
        if (loyaltyOn &&
            (crmLoyaltyHidden || crmLoyaltyBelowMin || crmLoyaltyDiscount <= 0)) {
          Get.find<PosController>().applyLoyaltyValue(false);
          amountCalculation();
          return;
        }
        if (loyaltyOn && previousDiscount != crmLoyaltyDiscount) {
          amountCalculation();
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
      //     channel: _collectCrmChannel(),
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
    final items = _crmBillItems();
    final result = await Get.find<LoyaltyController>().validateCrmCoupon(
      code: _couponController.text,
      customerId: userId,
      orderTotal: _crmBillBase(),
      channel: _collectCrmChannel(),
      loyaltyPointsUsed:
          Get.find<PosController>().isApplyLoyalty ? crmMaxPoints.round() : 0,
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
          Get.find<PosController>().isApplyLoyalty) {
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
      amountCalculation();
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
    final pos = Get.find<PosController>();
    if (crmLoyaltyBelowMin || crmLoyaltyDiscount <= 0) {
      pos.applyLoyaltyValue(false);
      if (crmLoyaltyHint.isNotEmpty) showErrorToast(crmLoyaltyHint);
      amountCalculation();
      return;
    }
    pos.applyLoyaltyValue(!pos.isApplyLoyalty);
    if (pos.isApplyLoyalty && !crmCouponStackable && isCouponValidate) {
      isCouponValidate = false;
      crmCouponRupee = 0;
      crmCouponCode = '';
      crmCouponTitle = '';
      crmCouponBenefit = '';
      showErrorToast('Cannot combine coupon with loyalty points');
    }
    amountCalculation();
  }

  void amountCalculation() {
    jsonCartList = [];
    orderItemTotal = 0;
    double discountableItemTotal = 0;
    orderSubTotal = 0;
    discountedOrderSubTotal = 0;
    orderDiscount = 0;
    coummunityDiscount = 0;
    couponDiscount = 0;
    gstAmount = 0;
    vatAmount = 0;
    showServiceChargeValue = 0;
    gstServiceChargeTax = 0;

    profile.Restaurant restaurant =
        Get.find<AuthController>().profileModel?.restaurants?.first ??
            profile.Restaurant();

    if (selectedDiscountType == 'Percent' &&
        _discountController.text.isNotEmpty &&
        double.parse(_discountController.text) > 100) {
      showErrorToast('Please enter valid discount');
    } else {
      final billDetailResponse =
          Get.find<PosController>().getSimpleCollectBillDetail;
      final orders = billDetailResponse?.orders;
      List<OrderDetailsBar> mergeFoodList = [];
      mergeFoodList.addAll(orders?.orderDetailsFood ?? []);
      mergeFoodList.addAll(orders?.orderDetailsBar ?? []);
      for (var i = 0; i < mergeFoodList.length; i++) {
        if (mergeFoodList[i].foodStatus != 3) {
          OrderDetailsBar food = mergeFoodList[i];

          double variationTotal = 0;
          double addonsTotal = 0;
          double foodAmount = 0;
          double apiFoodAmount = 0;
          double complementaryTotal = 0;
          double halfVariationPrice = 0;
          double foodGstAmount = 0;
          double foodVatAmount = 0;
          double discountFood = 0;

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
                  (((addOn.price ?? 0) * (addOn.quantity ?? 0)) *
                      (food.quantity ?? 0));
            }
          }
          if (food.foodDetails!['name'].toString().toLowerCase() !=
              'check in') {
            orderItemTotal = orderItemTotal +
                (mergeFoodList[i].isComplementary!
                    ? 0
                    : (food.unitPrice ?? 0) * (food.quantity ?? 0) +
                        variationTotal +
                        addonsTotal);
            foodAmount = (mergeFoodList[i].isComplementary!
                ? 0
                : (food.unitPrice ?? 0) * (food.quantity ?? 0) +
                    variationTotal +
                    addonsTotal);
            apiFoodAmount = (mergeFoodList[i].isComplementary!
                ? 0
                : (food.unitPrice ?? 0) * (food.quantity ?? 0));
            if ((food.foodDetails?['give_discount']?.toString() ?? '') ==
                    'Yes' &&
                mergeFoodList[i].isComplementary != true) {
              discountableItemTotal = discountableItemTotal + foodAmount;
            }
            if (mergeFoodList[i].isComplementary == true) {
              complementaryTotal = (mergeFoodList[i].isComplementary!
                      ? 0
                      : (food.unitPrice ?? 0) * (food.quantity ?? 0)) +
                  addonsTotal +
                  variationTotal;
            }
          }

          if (selectedDiscountType == 'Percent' ||
              selectedDiscountType == 'No') {
            double tempDiscountPercent = selectedDiscountType == 'No'
                ? 0
                : _discountController.text.isEmpty
                    ? 0
                    : double.parse(_discountController.text);
            double tempAmount = 0;
            if ((food.foodDetails?['give_discount']?.toString() ?? '') ==
                'Yes') {
              tempAmount = foodAmount -
                  (foodAmount *
                      (coummunityDiscountPercentage + tempDiscountPercent) /
                      100);
              orderDiscount = orderDiscount +
                  (foodAmount *
                      (coummunityDiscountPercentage + tempDiscountPercent) /
                      100);
              couponDiscount =
                  couponDiscount + (foodAmount * (tempDiscountPercent) / 100);
              coummunityDiscount = coummunityDiscount +
                  (foodAmount * (coummunityDiscountPercentage) / 100);
              discountFood = (foodAmount *
                  (coummunityDiscountPercentage + tempDiscountPercent) /
                  100);
              orderSubTotal = orderSubTotal + tempAmount;
            } else {
              tempAmount = foodAmount;
              orderSubTotal = orderSubTotal + tempAmount;
            }
            if ((food.foodDetails?['tax_type']?.toString() ?? '') == 'GST') {
              if (restaurant.gstStatus == 'true') {
                if (Get.find<PosController>().isAddServiceCharge) {
                  gstAmount = gstAmount +
                      (((tempAmount) *
                              double.parse(
                                  food.foodDetails?['tax']?.toString() ??
                                      '0')) /
                          100);
                  foodGstAmount = (((tempAmount) *
                          double.parse(
                              food.foodDetails?['tax']?.toString() ?? '0')) /
                      100);
                  showServiceChargeValue = showServiceChargeValue +
                      ((tempAmount * serviceChargePercentage) / 100);
                } else {
                  gstAmount = gstAmount +
                      ((tempAmount *
                              double.parse(
                                  food.foodDetails?['tax']?.toString() ??
                                      '0')) /
                          100);
                  foodGstAmount = ((tempAmount *
                          double.parse(
                              food.foodDetails?['tax']?.toString() ?? '0')) /
                      100);
                }
              } else {
                if (Get.find<PosController>().isAddServiceCharge) {
                  showServiceChargeValue = showServiceChargeValue +
                      ((tempAmount * serviceChargePercentage) / 100);
                }
              }
              discountedOrderSubTotal = discountedOrderSubTotal + tempAmount;
            } else if ((food.foodDetails?['tax_type']?.toString() ?? '') ==
                'VAT') {
              if (Get.find<AuthController>().profileModel?.vatInfo?.status ==
                  'true') {
                if (Get.find<PosController>().isAddServiceCharge) {
                  vatAmount = vatAmount +
                      (((tempAmount) *
                              double.parse(
                                  food.foodDetails?['tax']?.toString() ??
                                      '0')) /
                          100);
                  foodVatAmount = (((tempAmount) *
                          double.parse(
                              food.foodDetails?['tax']?.toString() ?? '0')) /
                      100);
                  showServiceChargeValue = showServiceChargeValue +
                      ((tempAmount * serviceChargePercentage) / 100);
                } else {
                  vatAmount = vatAmount +
                      ((tempAmount *
                              double.parse(
                                  food.foodDetails?['tax']?.toString() ??
                                      '0')) /
                          100);
                  foodVatAmount = ((tempAmount *
                          double.parse(
                              food.foodDetails?['tax']?.toString() ?? '0')) /
                      100);
                }
              } else {
                if (Get.find<PosController>().isAddServiceCharge) {
                  showServiceChargeValue = showServiceChargeValue +
                      ((tempAmount * serviceChargePercentage) / 100);
                }
              }
              discountedOrderSubTotal = discountedOrderSubTotal + tempAmount;
            }

            var jsonData = {
              "food_id": food.foodId,
              "quantity": food.quantity,
              "item_id": food.id,
              'unit_price': food.isComplementary == true ? 0 : food.unitPrice,
              'is_complementary': food.isComplementary == true ? 'Yes' : 'No',
              "food_amount":
                  mergeFoodList[i].isComplementary! ? 0 : apiFoodAmount,
              "variation_amount":
                  mergeFoodList[i].isComplementary! ? 0 : variationTotal,
              "addon_amount":
                  mergeFoodList[i].isComplementary! ? 0 : addonsTotal,
              "gst_amount": mergeFoodList[i].isComplementary!
                  ? 0
                  : foodGstAmount.toStringAsFixed(2),
              "vat_amount": mergeFoodList[i].isComplementary!
                  ? 0
                  : foodVatAmount.toStringAsFixed(2),
              "discount_amount": mergeFoodList[i].isComplementary!
                  ? 0
                  : discountFood.toStringAsFixed(2),
              "complementary_total": complementaryTotal,
              // "service_charge": foodServiceCharge.toStringAsFixed(2),
            };
            jsonCartList.add(jsonData);
          }

          // print(  'Json data food : $jsonData');
        }
      }
      if (selectedDiscountType == 'Fixed') {
        for (var i = 0; i < mergeFoodList.length; i++) {
          if (mergeFoodList[i].foodStatus != 3) {
            OrderDetailsBar food = mergeFoodList[i];

            double variationTotal = 0;
            double addonsTotal = 0;
            double foodAmount = 0;
            double apiFoodAmount = 0;
            double complementaryTotal = 0;
            double halfVariationPrice = 0;
            double foodGstAmount = 0;
            double foodVatAmount = 0;
            double discountFood = 0;
            // double foodServiceCharge = 0;

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
                    (((addOn.price ?? 0) * (addOn.quantity ?? 0)) *
                        (food.quantity ?? 0));
              }
            }
            if (food.foodDetails!['name'].toString().toLowerCase() !=
                'check in') {
              foodAmount = (mergeFoodList[i].isComplementary!
                  ? 0
                  : (food.unitPrice ?? 0) * (food.quantity ?? 0) +
                      variationTotal +
                      addonsTotal);
              apiFoodAmount = (mergeFoodList[i].isComplementary!
                  ? 0
                  : (food.unitPrice ?? 0) * (food.quantity ?? 0));
              if (mergeFoodList[i].isComplementary == true) {
                complementaryTotal = (mergeFoodList[i].isComplementary!
                        ? 0
                        : (food.unitPrice ?? 0) * (food.quantity ?? 0)) +
                    addonsTotal +
                    variationTotal;
              }
            }

            double enteredDiscount = _discountController.text.isEmpty
                ? 0
                : double.parse(_discountController.text);
            if (enteredDiscount > discountableItemTotal) {
              enteredDiscount = discountableItemTotal;
            }
            double tempDiscountPercent = _discountController.text.isEmpty ||
                    discountableItemTotal == 0
                ? 0
                : double.parse(((enteredDiscount / discountableItemTotal) * 100)
                    .toStringAsFixed(2));
            double tempAmount = 0;
            if ((food.foodDetails?['give_discount']?.toString() ?? '') ==
                'Yes') {
              tempAmount = foodAmount -
                  (foodAmount *
                      (coummunityDiscountPercentage + tempDiscountPercent) /
                      100);
              orderDiscount = orderDiscount +
                  (foodAmount *
                      (coummunityDiscountPercentage + tempDiscountPercent) /
                      100);
              couponDiscount =
                  couponDiscount + (foodAmount * (tempDiscountPercent) / 100);
              coummunityDiscount = coummunityDiscount +
                  (foodAmount * (coummunityDiscountPercentage) / 100);

              discountFood = (foodAmount *
                  (coummunityDiscountPercentage + tempDiscountPercent) /
                  100);
              orderSubTotal = orderSubTotal + tempAmount;
            } else {
              tempAmount = foodAmount;
              orderSubTotal = orderSubTotal + tempAmount;
            }
            if ((food.foodDetails?['tax_type']?.toString() ?? '') == 'GST') {
              if (restaurant.gstStatus == 'true') {
                if (Get.find<PosController>().isAddServiceCharge) {
                  gstAmount = gstAmount +
                      (((tempAmount) *
                              double.parse(
                                  food.foodDetails?['tax']?.toString() ??
                                      '0')) /
                          100);
                  foodGstAmount = (((tempAmount) *
                          double.parse(
                              food.foodDetails?['tax']?.toString() ?? '0')) /
                      100);
                  showServiceChargeValue = showServiceChargeValue +
                      ((tempAmount * serviceChargePercentage) / 100);
                } else {
                  gstAmount = gstAmount +
                      ((tempAmount *
                              double.parse(
                                  food.foodDetails?['tax']?.toString() ??
                                      '0')) /
                          100);
                  foodGstAmount = ((tempAmount *
                          double.parse(
                              food.foodDetails?['tax']?.toString() ?? '0')) /
                      100);
                }
              } else {
                if (Get.find<PosController>().isAddServiceCharge) {
                  showServiceChargeValue = showServiceChargeValue +
                      ((tempAmount * serviceChargePercentage) / 100);
                }
              }
              discountedOrderSubTotal = discountedOrderSubTotal + tempAmount;
            } else if ((food.foodDetails?['tax_type']?.toString() ?? '') ==
                'VAT') {
              if (Get.find<AuthController>().profileModel?.vatInfo?.status ==
                  'true') {
                if (Get.find<PosController>().isAddServiceCharge) {
                  vatAmount = vatAmount +
                      (((tempAmount) *
                              double.parse(
                                  food.foodDetails?['tax']?.toString() ??
                                      '0')) /
                          100);
                  foodVatAmount = (((tempAmount) *
                          double.parse(
                              food.foodDetails?['tax']?.toString() ?? '0')) /
                      100);
                  showServiceChargeValue = showServiceChargeValue +
                      ((tempAmount * serviceChargePercentage) / 100);
                } else {
                  vatAmount = vatAmount +
                      ((tempAmount *
                              double.parse(
                                  food.foodDetails?['tax']?.toString() ??
                                      '0')) /
                          100);
                  foodVatAmount = ((tempAmount *
                          double.parse(
                              food.foodDetails?['tax']?.toString() ?? '0')) /
                      100);
                }
              } else {
                if (Get.find<PosController>().isAddServiceCharge) {
                  showServiceChargeValue = showServiceChargeValue +
                      ((tempAmount * serviceChargePercentage) / 100);
                }
              }
              discountedOrderSubTotal = discountedOrderSubTotal + tempAmount;
            }

            // else {
            //   if ((food.foodDetails?['tax_type']?.toString() ?? '') == 'GST') {
            //     gstTypeFood = gstTypeFood + foodAmount;
            //   } else if ((food.foodDetails?['tax_type']?.toString() ?? '') ==
            //       'VAT') {
            //     vatTypeFood = vatTypeFood + foodAmount;
            //   }
            // }

            var jsonData = {
              "food_id": food.foodId,
              "item_id": food.id,
              "quantity": food.quantity,
              "food_amount":
                  mergeFoodList[i].isComplementary! ? 0 : apiFoodAmount,
              "variation_amount":
                  mergeFoodList[i].isComplementary! ? 0 : variationTotal,
              "addon_amount":
                  mergeFoodList[i].isComplementary! ? 0 : addonsTotal,
              'is_complementary': food.isComplementary == true ? 'Yes' : 'No',
              'unit_price': food.isComplementary == true ? 0 : food.unitPrice,
              "complementary_total": complementaryTotal,
              "gst_amount": mergeFoodList[i].isComplementary!
                  ? 0
                  : foodGstAmount.toStringAsFixed(2),
              "vat_amount": mergeFoodList[i].isComplementary!
                  ? 0
                  : foodVatAmount.toStringAsFixed(2),
              "discount_amount": mergeFoodList[i].isComplementary!
                  ? 0
                  : discountFood.toStringAsFixed(2)
            };
            jsonCartList.add(jsonData);
          }
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
      //           : ((double.parse(_discountController.text) /
      //                   (gstTypeFood + vatTypeFood)) *
      //               100);
      //   tempBarAmount =
      //       vatTypeFood - ((vatTypeFood * tempDiscountPercent) / 100);
      //   tempFoodAmount =
      //       gstTypeFood - ((gstTypeFood * tempDiscountPercent) / 100);
      //   orderDiscount = ((gstTypeFood * tempDiscountPercent) / 100) +
      //       ((vatTypeFood * tempDiscountPercent) / 100);
      //   discountedOrderSubTotal = tempBarAmount + tempFoodAmount;
      //   if (restaurant.gstStatus == 'true') {
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
      //     //     vatAmount + (((tempBarAmount) * (restaurant.tax ?? 0)) / 100);
      //   } else {
      //     if (Get.find<PosController>().isAddServiceCharge)
      //       showServiceChargeValue = showServiceChargeValue +
      //           ((tempBarAmount * serviceChargePercentage) / 100);
      //   }
      // }

      if (discountedOrderSubTotal >= 0) {
        final pos = Get.find<PosController>();
        Orders order = pos.getCollectBillDetailResponse!.orders!;
        double crmOffer = 0;
        if (pos.isApplyLoyalty && !crmLoyaltyBelowMin && crmLoyaltyDiscount > 0) {
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
          gstAmount = gstAmount * ratio;
          vatAmount = vatAmount * ratio;
          showServiceChargeValue = showServiceChargeValue * ratio;
          for (final line in jsonCartList) {
            final lineGst = double.tryParse('${line['gst_amount'] ?? 0}') ?? 0;
            final lineVat = double.tryParse('${line['vat_amount'] ?? 0}') ?? 0;
            line['gst_amount'] = (lineGst * ratio).toStringAsFixed(2);
            line['vat_amount'] = (lineVat * ratio).toStringAsFixed(2);
          }
        }
        tipTaxAmount = 0;
        if (_addTips.text.isNotEmpty) {
          tipTaxAmount = (double.parse(_addTips.text) *
                  restaurant.serviceChargeTaxPercent!) /
              100; //<-------------here we take serive charge gst on tip restaurant.tipTaxPercent! ---> restaurant.serviceChargeTaxPercent!
        }

        if (pos.isAddServiceCharge) {
          gstServiceChargeTax =
              ((showServiceChargeValue * restaurant.serviceChargeTaxPercent!) /
                  100);
        }
        if (order.orderDetailsOrder!.deliveryCharge != 0 &&
            restaurant.settings!.gstDeliveryCharge != 0)
          gstAmount = gstAmount +
              ((order.orderDetailsOrder!.deliveryCharge! *
                      restaurant.settings!.gstDeliveryCharge!) /
                  100);

        double addOrderAmount = ((order.roomInfo?.gstTaxAmount) ?? 0) +
            (((order.roomInfo?.remainingPay ?? 0)) +
                order.orderDetailsOrder!.deliveryCharge!) +
            gstServiceChargeTax +
            (discountedOrderSubTotal - crmOffer) +
            showServiceChargeValue +
            tipTaxAmount +
            gstAmount +
            vatAmount +
            (_addTips.text.isEmpty ? 0 : double.parse(_addTips.text));
        // if (pos.isApplyLoyalty) {
        //   addOrderAmount = addOrderAmount - usedLoyaltyPoint;
        // }
        // if (pos.isApplyLoyalty && !crmLoyaltyBelowMin && crmLoyaltyDiscount > 0) {
        //   addOrderAmount = addOrderAmount - crmLoyaltyDiscount;
        // }
        // if (isCouponValidate && crmCouponRupee > 0) {
        //   addOrderAmount = addOrderAmount - crmCouponRupee;
        // }

        //// wallet used
        double tempWalletUsed = 0;
        double payable = addOrderAmount;

        if (pos.isApplyWallet) {
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
            ? '${getRoundUpValue(value: (payable + roomTotalPaymnet))}'
            : (payable + roomTotalPaymnet).toStringAsFixed(2);
        pos.setcollectItemPrice(
            twoDecimal(payable)); // existing method you already call
        // }
      } else {
        showErrorToast('Please enter valid discount');
      }
    }
    _scheduleCrmOffers();
    if (mounted) setState(() {});
  }

  Widget printSummaryDialog() {
    return StatefulBuilder(builder: (context, setState) {
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
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select option for print',
                    textAlign: TextAlign.center,
                    style: poppinsMedium.copyWith(
                        fontSize:
                            MediaQuery.of(context).size.width > 1600 ? 20 : 18,
                        color: Colors.black),
                  ),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(Icons.close, color: Colors.red, size: 27),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount:
                        Get.find<PosController>().roomBillsList.length + 2,
                    itemBuilder: (BuildContext context, int index) {
                      GetRoomBillsResponseModel? customerData;
                      if (index > 1)
                        customerData =
                            Get.find<PosController>().roomBillsList[index - 2];
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          width: Get.width,
                          child: InkWell(
                            onTap: () {
                              isSelectPrinterList[index] =
                                  !isSelectPrinterList[index];
                              // isPrintKitchen = !isPrintKitchen;
                              setState(() {});
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height:
                                      MediaQuery.of(context).size.width > 1600
                                          ? 70
                                          : 30,
                                  child: Checkbox(
                                    activeColor: ColorTheme.appColor,
                                    // value: true,
                                    value: isSelectPrinterList[index],
                                    onChanged: (bool? isChecked) {
                                      isSelectPrinterList[index] = isChecked!;
                                      setState(() {});
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: Get.width,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                index == 0
                                                    ? 'Summary'
                                                    : index == 1
                                                        ? 'Order Id : ' +
                                                            (((Get.find<PosController>()
                                                                                .getCollectBillDetailResponse
                                                                                ?.orders
                                                                                ?.orderDetailsOrder
                                                                                ?.restaurantOrderId ??
                                                                            '0')
                                                                        .toString() ==
                                                                    '0')
                                                                ? (Get.find<PosController>()
                                                                            .getCollectBillDetailResponse
                                                                            ?.orders
                                                                            ?.orderDetailsOrder
                                                                            ?.id ??
                                                                        '')
                                                                    .toString()
                                                                : (Get.find<PosController>()
                                                                            .getCollectBillDetailResponse
                                                                            ?.orders
                                                                            ?.orderDetailsOrder
                                                                            ?.restaurantOrderId ??
                                                                        '')
                                                                    .toString())
                                                        : (customerData!
                                                                    .restaurantOrderId ==
                                                                '0'
                                                            ? (customerData
                                                                        .orderId ??
                                                                    '')
                                                                .toString()
                                                            : (customerData
                                                                        .restaurantOrderId ??
                                                                    '')
                                                                .toString()),
                                                style: poppinsMedium.copyWith(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            if (index != 0)
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10, right: 25),
                                                  child: Text(
                                                      'Rs. ${index == 1 ? PriceConverter.convertPrice(Get.find<PosController>().collectItemPrice, isHideCurrency: true, asFixed: 2) : double.parse(customerData!.orderAmount!).toStringAsFixed(2)}',
                                                      style: poppinsMedium.copyWith(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width >
                                                                  1600
                                                              ? 17
                                                              : 14)),
                                                ),
                                              ),
                                            // Spacer(),
                                          ],
                                        ),
                                      ),
                                      if (index != 0)
                                        Text(
                                            index == 1
                                                ? 'Date: ${DateFormat('dd-MMM').format(DateTime.parse(Get.find<PosController>().getCollectBillDetailResponse!.orders!.orderDetailsOrder!.createdAt!))}'
                                                : (customerData?.createdAt ==
                                                            null ||
                                                        customerData!
                                                            .createdAt!.isEmpty)
                                                    ? ''
                                                    : 'Date: ${DateFormat('dd-MMM').format(DateTime.parse(index == 1 ? Get.find<PosController>().getCollectBillDetailResponse!.orders!.orderDetailsOrder!.createdAt! : customerData.createdAt!))}',
                                            style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1600
                                                    ? 17
                                                    : 10)),
                                      Text(
                                          isPrinterProccessingList[index]
                                              ? 'Status: Proccessing'
                                              : isPrintedList[index]
                                                  ? 'Status: Printed'
                                                  : 'Status: Not Printed',
                                          style: poppinsMedium.copyWith(
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      1600
                                                  ? 15
                                                  : 10,
                                              color: ColorTheme.blue

                                              // color: isPrintedList[index]
                                              //     ? ColorTheme.green
                                              //     : Colors.red
                                              )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
              GetBuilder<KdsController>(builder: (kdsController) {
                return InkWell(
                  onTap: () async {
                    // if (!kdsController.isProcessing) {
                    currentPrintIndex = 0;
                    print(currentPrintIndex);
                    // print('currentPrintIndex......$currentPrintIndex');
                    // kdsController.setProcessing(true);
                    await dataCheck(setState);
                    // }
                  },
                  child: SvgPicture.asset(
                    Images.ic_print_kot,
                    height: 26,
                  ),
                  //  Container(
                  //   padding: EdgeInsets.symmetric(
                  //       horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                  //       vertical: Dimensions.PADDING_SIZE_SMALL),
                  //   decoration: BoxDecoration(
                  //       color: ColorTheme.appColor,
                  //       borderRadius:
                  //           BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
                  //   child: Text(
                  //     kdsController.isProcessing ? 'Processing' : 'Print',
                  //     style: poppinsMedium.copyWith(
                  //         fontSize: MediaQuery.of(context).size.width > 1600
                  //             ? 19
                  //             : Dimensions.FONT_SIZE_LARGE,
                  //         color: Colors.white),
                  //   ),
                  // ),
                );
              }),
            ]),
          ));
    });
  }

  dataCheck(setState) async {
    try {
      if (currentPrintIndex <=
          Get.find<PosController>().roomBillsList.length + 1) {
        if (isSelectPrinterList[currentPrintIndex] == false) {
          for (var i = currentPrintIndex;
              i < Get.find<PosController>().roomBillsList.length + 2;
              i++) {
            if (isSelectPrinterList[currentPrintIndex] == false) {
              currentPrintIndex = currentPrintIndex + 1;
              await dataCheck(setState);
              break;
            } else {
              if (currentPrintIndex == 0) {
                if (GetPlatform.isWindows) {
                  final printers = await Printing.listPrinters();
                  for (var element in printers) {
                    if (element.isAvailable &&
                        (element.name.toLowerCase() ==
                            Get.find<AuthController>()
                                .profileModel!
                                .wifiBillPrinterName!
                                .toLowerCase())) {
                      await Printing.directPrintPdf(
                        printer: element,
                        onLayout: (_) => summaryBillPdf(),
                      );
                      break;
                    }
                  }
                  currentPrintIndex = currentPrintIndex + 1;
                  await dataCheck(setState);
                } else {
                  await summaryBytesConvert(setState);
                }
              } else if (currentPrintIndex == 1) {
                Future.delayed(Duration(seconds: 2), () async {
                  if (GetPlatform.isWindows) {
                    final printers = await Printing.listPrinters();
                    for (var element in printers) {
                      if (element.isAvailable &&
                          (element.name.toLowerCase() ==
                              Get.find<AuthController>()
                                  .profileModel!
                                  .wifiBillPrinterName!
                                  .toLowerCase())) {
                        await Printing.directPrintPdf(
                          printer: element,
                          onLayout: (_) => WindowsPrintByteConvert()
                              .byteConvert(
                                  printType: 'bill',
                                  paperRoll:
                                      Get.find<AuthController>().profileModel!.billPrinterPaperRoll == 58
                                          ? 58
                                          : 80,
                                  orderId: Get.find<PosController>()
                                      .getCollectBillDetailResponse!
                                      .orders!
                                      .orderDetailsOrder!
                                      .restaurantOrderId,
                                  date:
                                      '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.parse(Get.find<PosController>().getCollectBillDetailResponse!.orders!.orderDetailsOrder!.createdAt!))}',
                                  waiterName:
                                      '${Get.find<PosController>().getCollectBillDetailResponse!.orders!.restaurantDetails!.waiterName}',
                                  tablename: Get.find<PosController>()
                                              .getCollectBillDetailResponse!
                                              .orders!
                                              .restaurantDetails!
                                              .tableNo ==
                                          ''
                                      ? Get.find<PosController>()
                                                  .getCollectBillDetailResponse!
                                                  .orders!
                                                  .orderDetailsOrder
                                                  ?.orderType ==
                                              'delivery'
                                          ? 'Delivery'
                                          : Get.find<PosController>()
                                                      .getCollectBillDetailResponse!
                                                      .orders!
                                                      .orderDetailsOrder
                                                      ?.orderType ==
                                                  'take_away'
                                              ? 'Take Away'
                                              : 'WC'
                                      : Get.find<PosController>()
                                                  .getCollectBillDetailResponse!
                                                  .orders!
                                                  .restaurantDetails!
                                                  .tableArea ==
                                              ''
                                          ? '${Get.find<PosController>().getCollectBillDetailResponse!.orders!.restaurantDetails!.tableNo}'
                                          : '${Get.find<PosController>().getCollectBillDetailResponse!.orders!.restaurantDetails!.tableArea}:${Get.find<PosController>().getCollectBillDetailResponse!.orders!.restaurantDetails!.tableNo}',
                                  custName: '${_nameController.text ?? ''}',
                                  custPhone: '${_phoneController.text ?? ''}',
                                  billFoodList: Get.find<PosController>()
                                          .getCollectBillDetailResponse!
                                          .orders!
                                          .mergeFoodListWithDate ??
                                      [],
                                  orderNote: Get.find<PosController>()
                                          .getCollectBillDetailResponse
                                          ?.orders
                                          ?.orderDetailsOrder
                                          ?.orderNote ??
                                      '',
                                  orderSubTotal: orderItemTotal,
                                  gstName: Get.find<PosController>().getCollectBillDetailResponse?.orders?.roomInfo?.gstName ?? '',
                                  gstNo: double.tryParse(Get.find<PosController>().getCollectBillDetailResponse?.orders?.roomInfo?.gstNo ?? ''),
                                  discount: orderDiscount,
                                  serviceChargeAmount: showServiceChargeValue,
                                  deliveryCharge: Get.find<PosController>().getCollectBillDetailResponse?.orders?.orderDetailsOrder?.deliveryCharge ?? 0,
                                  gstAmount: gstAmount,
                                  vatAmount: vatAmount,
                                  grandTotal: Get.find<PosController>().collectItemPrice,
                                  deliveryCustName: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.name ?? '',
                                  deliveryCustPhone: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.phone ?? '',
                                  deliveryAddressType: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.addressType ?? '',
                                  deliveryCustAddress: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.address ?? '',
                                  deliveryCustPincode: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.pincode ?? '',
                                  tips: double.parse(_addTips.text ?? '0'),
                                  orderType: Get.find<PosController>().getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderType),
                        );
                        break;
                      }
                    }
                    currentPrintIndex = currentPrintIndex + 1;
                    await dataCheck(setState);
                  } else {
                    await currentBillBytesConvert(setState);
                  }
                });
              } else {
                Future.delayed(Duration(seconds: 5), () async {
                  if (GetPlatform.isWindows) {
                    final printers = await Printing.listPrinters();
                    for (var element in printers) {
                      if (element.isAvailable &&
                          (element.name.toLowerCase() ==
                              Get.find<AuthController>()
                                  .profileModel!
                                  .wifiBillPrinterName!
                                  .toLowerCase())) {
                        await Printing.directPrintPdf(
                          printer: element,
                          onLayout: (_) => generateRoomBillPdf()!,
                        );
                        break;
                      }
                    }
                    currentPrintIndex = currentPrintIndex + 1;
                    await dataCheck(setState);

                    // await Printing.directPrintPdf(
                    //   printer: printers.first,
                    //   onLayout: (_) => generateRoomBillPdf(),
                    // );
                  } else {
                    await roomBillBytesConvert(setState);
                  }
                });
              }
              break;
            }
          }
        } else {
          if (currentPrintIndex == 0) {
            if (GetPlatform.isWindows) {
              final printers = await Printing.listPrinters();
              for (var element in printers) {
                if (element.isAvailable &&
                    (element.name.toLowerCase() ==
                        Get.find<AuthController>()
                            .profileModel!
                            .wifiBillPrinterName!
                            .toLowerCase())) {
                  await Printing.directPrintPdf(
                    printer: element,
                    onLayout: (_) => summaryBillPdf(),
                  );
                  break;
                }
              }
              currentPrintIndex = currentPrintIndex + 1;
              await dataCheck(setState);
            } else {
              await summaryBytesConvert(setState);
            }
          } else if (currentPrintIndex == 1) {
            Future.delayed(Duration(seconds: 2), () async {
              if (GetPlatform.isWindows) {
                final printers = await Printing.listPrinters();
                for (var element in printers) {
                  if (element.isAvailable &&
                      (element.name.toLowerCase() ==
                          Get.find<AuthController>()
                              .profileModel!
                              .wifiBillPrinterName!
                              .toLowerCase())) {
                    await Printing.directPrintPdf(
                      printer: element,
                      onLayout: (_) => WindowsPrintByteConvert().byteConvert(
                          printType: 'bill',
                          paperRoll: Get.find<AuthController>().profileModel!.billPrinterPaperRoll == 58
                              ? 58
                              : 80,
                          orderId: Get.find<PosController>()
                              .getCollectBillDetailResponse!
                              .orders!
                              .orderDetailsOrder!
                              .restaurantOrderId,
                          date:
                              '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.parse(Get.find<PosController>().getCollectBillDetailResponse!.orders!.orderDetailsOrder!.createdAt!))}',
                          waiterName:
                              '${Get.find<PosController>().getCollectBillDetailResponse!.orders!.restaurantDetails!.waiterName}',
                          tablename: Get.find<PosController>()
                                      .getCollectBillDetailResponse!
                                      .orders!
                                      .restaurantDetails!
                                      .tableNo ==
                                  ''
                              ? Get.find<PosController>()
                                          .getCollectBillDetailResponse!
                                          .orders!
                                          .orderDetailsOrder
                                          ?.orderType ==
                                      'delivery'
                                  ? 'Delivery'
                                  : Get.find<PosController>()
                                              .getCollectBillDetailResponse!
                                              .orders!
                                              .orderDetailsOrder
                                              ?.orderType ==
                                          'take_away'
                                      ? 'Take Away'
                                      : 'WC'
                              : Get.find<PosController>()
                                          .getCollectBillDetailResponse!
                                          .orders!
                                          .restaurantDetails!
                                          .tableArea ==
                                      ''
                                  ? '${Get.find<PosController>().getCollectBillDetailResponse!.orders!.restaurantDetails!.tableNo}'
                                  : '${Get.find<PosController>().getCollectBillDetailResponse!.orders!.restaurantDetails!.tableArea}:${Get.find<PosController>().getCollectBillDetailResponse!.orders!.restaurantDetails!.tableNo}',
                          custName: '${_nameController.text ?? ''}',
                          custPhone: '${_phoneController.text ?? ''}',
                          billFoodList: Get.find<PosController>()
                                  .getCollectBillDetailResponse!
                                  .orders!
                                  .mergeFoodListWithDate ??
                              [],
                          orderNote: Get.find<PosController>()
                                  .getCollectBillDetailResponse
                                  ?.orders
                                  ?.orderDetailsOrder
                                  ?.orderNote ??
                              '',
                          orderSubTotal: orderItemTotal,
                          discount: orderDiscount,
                          serviceChargeAmount: showServiceChargeValue,
                          deliveryCharge: Get.find<PosController>().getCollectBillDetailResponse?.orders?.orderDetailsOrder?.deliveryCharge ?? 0,
                          gstAmount: gstAmount,
                          vatAmount: vatAmount,
                          gstName: Get.find<PosController>().getCollectBillDetailResponse?.orders?.roomInfo?.gstName ?? '',
                          gstNo: double.tryParse(Get.find<PosController>().getCollectBillDetailResponse?.orders?.roomInfo?.gstNo ?? ''),
                          grandTotal: Get.find<PosController>().collectItemPrice,
                          deliveryCustName: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.name ?? '',
                          deliveryCustPhone: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.phone ?? '',
                          deliveryAddressType: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.addressType ?? '',
                          deliveryCustAddress: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.address ?? '',
                          deliveryCustPincode: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.pincode ?? '',
                          tips: double.parse(_addTips.text ?? '0'),
                          orderType: Get.find<PosController>().getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderType),
                    );
                    break;
                  }
                }
                currentPrintIndex = currentPrintIndex + 1;
                await dataCheck(setState);
              } else {
                await currentBillBytesConvert(setState);
              }
            });
          } else {
            Future.delayed(Duration(seconds: 5), () async {
              if (GetPlatform.isWindows) {
                final printers = await Printing.listPrinters();
                for (var element in printers) {
                  if (element.isAvailable &&
                      (element.name.toLowerCase() ==
                          Get.find<AuthController>()
                              .profileModel!
                              .wifiBillPrinterName!
                              .toLowerCase())) {
                    await Printing.directPrintPdf(
                      printer: element,
                      onLayout: (_) => generateRoomBillPdf()!,
                    );
                    break;
                  }
                }
                currentPrintIndex = currentPrintIndex + 1;
                await dataCheck(setState);

                // await Printing.directPrintPdf(
                //   printer: printers.first,
                //   onLayout: (_) => generateRoomBillPdf(),
                // );
              } else {
                await roomBillBytesConvert(setState);
              }
            });
          }
        }
      } else {
        Future.delayed(Duration(seconds: 10), () async {
          if (Platform.isIOS) {
          } else {
            if (!GetPlatform.isWindows)
              await PrinterManager.instance.disconnect(
                  type:
                      Get.find<AuthController>().profileModel!.billWifiIp != ''
                          ? PrinterType.network
                          : PrinterType.bluetooth);
          }
          Get.find<KdsController>().setProcessing(false);
        });
        // Execute function After last bill printed
      }
    } catch (e) {}
  }

  Future summaryBytesConvert(setState) async {
    pendingTask = [];
    List<int> bytes = [];
    ProfileModel profileModel = Get.find<AuthController>().profileModel!;

    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(
        profileModel.billPrinterPaperRoll == 58
            ? PaperSize.mm58
            : PaperSize.mm80,
        profile);
    bytes += generator.setGlobalCodeTable('CP1252');

    if (logoHelper.logoUrlPrint != null) {
      try {
        bytes += generator.feed(1);
        if (logoHelper.logoUrlPrint != null) {
          bytes += generator.image(logoHelper.logoUrlPrint!);
        }
      } catch (e) {
        print(e);
      }
    }
    final restaurant = (profileModel.restaurants != null &&
            profileModel.restaurants!.isNotEmpty)
        ? profileModel.restaurants!.first
        : null;
    bytes += generator.text(restaurant?.name ?? '',
        styles: PrinterConfig().titleStyle());
    bytes += generator.text(restaurant?.address ?? '',
        styles: PrinterConfig().addressStyle());
    if ((restaurant?.gstCode ?? '').isNotEmpty)
      bytes += generator.text('GST no. ${restaurant?.gstCode ?? ''}',
          styles: PrinterConfig().gstStyle());
    if ((restaurant?.fssai ?? '').isNotEmpty)
      bytes += generator.text('FSI no. ${restaurant?.fssai ?? ''}',
          styles: PrinterConfig().gstStyle());
    bytes += generator.row([
      PosColumn(
          text: _nameController.text,
          width: 6,
          styles: PrinterConfig().waiterNameStyle(align: PosAlign.left)),
      PosColumn(
          text:
              '${DateFormat('${restaurant?.billDateFormat ?? 'dd-MM-yyyy'}').format(DateTime.now())}',
          // '${DateFormat('${Get.find<AuthController>().profileModel.restaurants.first.billDateFormat}').format(DateTime.parse(Get.find<PosController>().getCollectBillDetailResponse.orders.orderDetailsOrder.createdAt))}',
          width: 6,
          styles: PrinterConfig().orderCreateDateStyle()),
    ]);
    bytes += generator.row([
      PosColumn(
          text: '${_phoneController.text ?? ''}',
          width: 5,
          styles: PrinterConfig().waiterNameStyle(align: PosAlign.left)),
      PosColumn(
        text: '',
        width: 1,
        styles: PosStyles(align: PosAlign.center),
      ),
      PosColumn(
          text: '${Get.find<AuthController>().profileModel?.empFname ?? ''}',
          width: 6,
          styles: PrinterConfig().waiterNameStyle()),
    ]);

    bytes += generator.row([
      PosColumn(
        text: '',
        width: 2,
        styles: PosStyles(
          align: PosAlign.center,
          // fontType: PosFontType.fontB,
        ),
      ),
      PosColumn(
          text: Get.find<PosController>()
                      .getCollectBillDetailResponse
                      ?.orders
                      ?.restaurantDetails
                      ?.tableNo ==
                  ''
              ? 'WC'
              : Get.find<PosController>()
                          .getCollectBillDetailResponse
                          ?.orders
                          ?.restaurantDetails
                          ?.tableArea ==
                      ''
                  ? '${Get.find<PosController>().getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo}'
                  : '${Get.find<PosController>().getCollectBillDetailResponse?.orders?.restaurantDetails?.tableArea}:${Get.find<PosController>().getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo}',
          width: 8,
          styles: PrinterConfig().tableNoStyle()),
      PosColumn(
        text: '',
        width: 2,
        styles: PosStyles(
          align: PosAlign.center,
          fontType: PosFontType.fontB,
        ),
      ),
    ]);
    if (Get.find<PosController>()
                .getCollectBillDetailResponse!
                .orders!
                .restaurantDetails!
                .restaurantOrderFor ==
            'ROOM' &&
        Get.find<PosController>().roomBillsList.isNotEmpty) {
      bytes += generator.hr();
      bytes += generator.text('Bill Summary',
          styles: PrinterConfig().summryTitleStyle(isBold: true));
      bytes += generator.hr(ch: '--');
      bytes += generator.row([
        PosColumn(text: 'SL', width: 2, styles: PrinterConfig().foodStyle()),
        PosColumn(
            text: 'Order Id', width: 3, styles: PrinterConfig().foodStyle()),
        PosColumn(
            text: 'Amount', width: 4, styles: PrinterConfig().foodStyle()),
        PosColumn(text: 'Date', width: 3, styles: PrinterConfig().foodStyle()),
      ]);
      bytes += generator.hr(ch: '--');
      for (var i = 0;
          i < Get.find<PosController>().roomBillsList.length + 1;
          i++) {
        GetRoomBillsResponseModel? customerData;
        if (i != 0) {
          customerData = Get.find<PosController>().roomBillsList[i - 1];
        }

        bytes += generator.row([
          PosColumn(
              text: '${i + 1}', width: 2, styles: PrinterConfig().foodStyle()),
          PosColumn(
              text: i == 0
                  ? '${(Get.find<PosController>().getCollectBillDetailResponse?.orders?.orderDetailsOrder?.restaurantOrderId ?? '') == '0' ? (Get.find<PosController>().getCollectBillDetailResponse?.orders?.orderDetailsOrder?.id?.toString() ?? '') : (Get.find<PosController>().getCollectBillDetailResponse?.orders?.orderDetailsOrder?.restaurantOrderId ?? '')} '
                  : (customerData?.restaurantOrderId ?? '') == '0'
                      ? (customerData?.orderId?.toString() ?? '')
                      : (customerData?.restaurantOrderId ?? ''),
              width: 3,
              styles: PrinterConfig().foodStyle()),
          PosColumn(
              text: i == 0
                  ? PriceConverter.convertPrice(
                      (Get.find<PosController>().collectItemPrice),
                      isHideCurrency: true,
                      asFixed: 2)
                  : double.parse(customerData?.orderAmount ?? '0')
                      .toStringAsFixed(2),
              width: 4,
              styles: PrinterConfig().foodStyle()),
          PosColumn(
              text: i == 0
                  ? (Get.find<PosController>()
                              .getCollectBillDetailResponse
                              ?.orders
                              ?.orderDetailsOrder
                              ?.createdAt !=
                          null
                      ? '${DateFormat('dd-MMM').format(DateTime.parse(Get.find<PosController>().getCollectBillDetailResponse!.orders!.orderDetailsOrder!.createdAt!))}'
                      : '')
                  : (customerData?.createdAt == null ||
                          customerData!.createdAt!.isEmpty)
                      ? ''
                      : '${DateFormat('dd-MMM').format(DateTime.parse(customerData.createdAt!))}',
              width: 3,
              styles: PrinterConfig().foodStyle()),
        ]);
        bytes += generator.hr(ch: '....');
      }
      bytes += generator.hr(ch: '....');
    }
    bytes += generator.hr(ch: '--');

    bytes += generator.text(
        'Total: ' +
            '${PriceConverter.convertPrice((Get.find<PosController>().collectItemPrice + roomTotalPaymnet), isHideCurrency: true, asFixed: 2)} ${profileModel.restaurants?.first.currency ?? ''}',
        styles: PrinterConfig().totalStyle());

    bytes += generator.hr(ch: '....');
    if (Get.find<PosController>()
                .getCollectBillDetailResponse!
                .orders!
                .paymentUrl !=
            '' &&
        GetPlatform.isAndroid) {
      const double qrSize = 170;
      try {
        final uiImg = await QrPainter(
          data: profileModel.restaurants!.first.dynamicUpiValue == 'No'
              ? 'upi://pay?pa=${profileModel.restaurants!.first.upiId}&pn=&am=0&tn='
              : 'upi://pay?pa=${Get.find<PosController>().getCollectBillDetailResponse!.orders!.paymentUrl.split('=').last}&pn=&am=${Get.find<PosController>().collectItemPrice + roomTotalPaymnet}&tn=',
          version: QrVersions.auto,
          gapless: false,
        ).toImageData(qrSize);
        final dir = await getTemporaryDirectory();
        final pathName = '${dir.path}/qr_tmp.png';
        final qrFile = File(pathName);
        final imgFile = await qrFile.writeAsBytes(uiImg!.buffer.asUint8List());
        final img = prefix.decodeImage(imgFile.readAsBytesSync());

        bytes += generator.text('Scan to pay',
            styles: const PosStyles(
                align: PosAlign.center,
                height: PosTextSize.size1,
                width: PosTextSize.size1,
                bold: true,
                fontType: PosFontType.fontA));

        bytes += generator.feed(1);
        bytes += generator.image(img!);
        bytes += generator.feed(1);

        // bytes += generator.feed(1);
      } catch (e) {
        print(e);
      }
    }
    if (Get.find<AuthController>()
            .profileModel!
            .restaurants!
            .first
            .footerTextBill !=
        '') {
      bytes += generator.text(
          Get.find<AuthController>()
              .profileModel!
              .restaurants!
              .first
              .footerTextBill!,
          styles: const PosStyles(
              align: PosAlign.center,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              // bold: true,
              fontType: PosFontType.fontB));
    }
    bytes += generator.text('Powered by MyGenie',
        styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            // bold: true,
            fontType: PosFontType.fontB));
    bytes += generator.cut();

    if (Platform.isAndroid) {
      await _kdsPrintEscPos(bytes, setState); //kitchen
    } else {
      await _iosPrintEscPos(bytes, setState); //kitchen
    }
  }

  Future currentBillBytesConvert(setState) async {
    if (Platform.isIOS) {
      await _iosPrintEscPos(
          await PrintByteConvert().byteConvert(
              roomAdvancePay:
                  Get.find<PosController>().getCollectBillDetailResponse?.orders?.roomInfo?.advancePay ??
                      0,
              roomRemainingPay: Get.find<PosController>()
                      .getCollectBillDetailResponse
                      ?.orders
                      ?.roomInfo
                      ?.remainingPay ??
                  0,
              printType: 'bill',
              paperRoll: Get.find<AuthController>().profileModel?.billPrinterPaperRoll == 58
                  ? 58
                  : 80,
              orderId: Get.find<PosController>()
                      .getCollectBillDetailResponse
                      ?.orders
                      ?.orderDetailsOrder
                      ?.restaurantOrderId ??
                  '',
              date: (Get.find<AuthController>().profileModel?.restaurants != null &&
                      Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .isNotEmpty &&
                      Get.find<PosController>()
                              .getCollectBillDetailResponse
                              ?.orders
                              ?.orderDetailsOrder
                              ?.createdAt !=
                          null)
                  ? DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}')
                      .format(DateTime.parse(Get.find<PosController>().getCollectBillDetailResponse!.orders!.orderDetailsOrder!.createdAt!))
                  : '',
              waiterName: Get.find<PosController>().getCollectBillDetailResponse?.orders?.restaurantDetails?.waiterName ?? '',
              tablename: Get.find<PosController>().getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo == ''
                  ? (Get.find<PosController>().getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderType == 'delivery'
                      ? 'Delivery'
                      : Get.find<PosController>().getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderType == 'take_away'
                          ? 'Take Away'
                          : 'WC')
                  : (Get.find<PosController>().getCollectBillDetailResponse?.orders?.restaurantDetails?.tableArea == '' ? '${Get.find<PosController>().getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo ?? ''}' : '${Get.find<PosController>().getCollectBillDetailResponse?.orders?.restaurantDetails?.tableArea ?? ''}:${Get.find<PosController>().getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo ?? ''}'),
              custName: _nameController.text,
              custPhone: _phoneController.text,
              billFoodList: Get.find<PosController>().getCollectBillDetailResponse?.orders?.mergeFoodListWithDate ?? [],
              orderNote: Get.find<PosController>().getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderNote ?? '',
              orderSubTotal: orderItemTotal,
              discount: orderDiscount,
              serviceChargeAmount: showServiceChargeValue,
              deliveryCharge: Get.find<PosController>().getCollectBillDetailResponse?.orders?.orderDetailsOrder?.deliveryCharge ?? 0,
              gstAmount: gstAmount,
              vatAmount: vatAmount,
              grandTotal: Get.find<PosController>().collectItemPrice,
              deliveryCustName: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.name ?? '',
              deliveryCustPhone: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.phone ?? '',
              deliveryAddressType: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.addressType ?? '',
              deliveryCustAddress: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.address ?? '',
              deliveryCustPincode: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.pincode ?? '',
              tips: double.tryParse(_addTips.text) ?? 0,
              orderType: Get.find<PosController>().getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderType ?? ''),
          setState);
    } else {
      await _kdsPrintEscPos(
          await PrintByteConvert().byteConvert(
              roomAdvancePay:
                  Get.find<PosController>().getCollectBillDetailResponse?.orders?.roomInfo?.advancePay ??
                      0,
              roomRemainingPay: Get.find<PosController>()
                      .getCollectBillDetailResponse
                      ?.orders
                      ?.roomInfo
                      ?.remainingPay ??
                  0,
              printType: 'bill',
              paperRoll: Get.find<AuthController>().profileModel?.billPrinterPaperRoll == 58
                  ? 58
                  : 80,
              orderId: Get.find<PosController>()
                      .getCollectBillDetailResponse
                      ?.orders
                      ?.orderDetailsOrder
                      ?.restaurantOrderId ??
                  '',
              date: (Get.find<AuthController>().profileModel?.restaurants != null &&
                      Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .isNotEmpty &&
                      Get.find<PosController>()
                              .getCollectBillDetailResponse
                              ?.orders
                              ?.orderDetailsOrder
                              ?.createdAt !=
                          null)
                  ? DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}')
                      .format(DateTime.parse(Get.find<PosController>().getCollectBillDetailResponse!.orders!.orderDetailsOrder!.createdAt!))
                  : '',
              waiterName: Get.find<PosController>().getCollectBillDetailResponse?.orders?.restaurantDetails?.waiterName ?? '',
              tablename: Get.find<PosController>().getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo == ''
                  ? (Get.find<PosController>().getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderType == 'delivery'
                      ? 'Delivery'
                      : Get.find<PosController>().getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderType == 'take_away'
                          ? 'Take Away'
                          : 'WC')
                  : (Get.find<PosController>().getCollectBillDetailResponse?.orders?.restaurantDetails?.tableArea == '' ? '${Get.find<PosController>().getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo ?? ''}' : '${Get.find<PosController>().getCollectBillDetailResponse?.orders?.restaurantDetails?.tableArea ?? ''}:${Get.find<PosController>().getCollectBillDetailResponse?.orders?.restaurantDetails?.tableNo ?? ''}'),
              custName: _nameController.text,
              custPhone: _phoneController.text,
              billFoodList: Get.find<PosController>().getCollectBillDetailResponse?.orders?.mergeFoodListWithDate ?? [],
              orderNote: Get.find<PosController>().getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderNote ?? '',
              orderSubTotal: orderItemTotal,
              discount: orderDiscount,
              serviceChargeAmount: showServiceChargeValue,
              deliveryCharge: Get.find<PosController>().getCollectBillDetailResponse?.orders?.orderDetailsOrder?.deliveryCharge ?? 0,
              gstAmount: gstAmount,
              vatAmount: vatAmount,
              grandTotal: Get.find<PosController>().collectItemPrice,
              deliveryCustName: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.name ?? '',
              deliveryCustPhone: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.phone ?? '',
              deliveryAddressType: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.addressType ?? '',
              deliveryCustAddress: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.address ?? '',
              deliveryCustPincode: Get.find<PosController>().getCollectBillDetailResponse?.orders?.deliveryAddress?.pincode ?? '',
              tips: double.tryParse(_addTips.text) ?? 0,
              orderType: Get.find<PosController>().getCollectBillDetailResponse?.orders?.orderDetailsOrder?.orderType ?? ''),
          setState);
    }
  }

  Future roomBillBytesConvert(setState) async {
    await Get.find<KdsController>().getPaidOrderDetail(
        '${Get.find<PosController>().roomBillsList[currentPrintIndex - 2].orderId}');

    paid.Orders order =
        Get.find<KdsController>().paidOrderDetailResponse!.orders!;

    if (Platform.isAndroid) {
      await _kdsPrintEscPos(
          await PrintByteConvert().byteConvert(
            printType: 'paid_bill',
            paperRoll:
                Get.find<AuthController>().profileModel!.billPrinterPaperRoll ==
                        58
                    ? 58
                    : 80,
            orderId: order.orderDetailsOrder?.restaurantOrderId ?? '',
            date:
                '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'dd-MM-yyyy'}').format(DateTime.parse(order.orderDetailsOrder?.createdAt ?? DateTime.now().toIso8601String()))}',
            waiterName:
                '${order.restaurantDetails?.restaurantWaiterName ?? ''}',
            tablename: (order.restaurantDetails?.restaurantTableNo ?? '') == ''
                ? (order.orderDetailsOrder?.orderType == 'delivery'
                    ? 'Delivery'
                    : order.orderDetailsOrder?.orderType == 'take_away'
                        ? 'Take Away'
                        : 'WC')
                : (order.restaurantDetails?.restaurantTableArea ?? '') == ''
                    ? '${order.restaurantDetails?.restaurantTableNo ?? ''}'
                    : '${order.restaurantDetails?.restaurantTableArea ?? ''}:${order.restaurantDetails?.restaurantTableNo ?? ''}',
            custName: order.orderDetailsOrder?.username ?? '',
            custPhone: '${order.orderUser?.phone ?? ''}',
            paidFoodList: order.orderDetailsFood ?? [],
            orderNote: order.orderDetailsOrder?.orderNote ?? '',
            orderSubTotal: (order.orderTotalAmount ?? 0) +
                (order.orderTotalAddonAmt ?? 0) +
                (order.orderTotalVariantAmt ?? 0),
            discount: order.orderDetailsOrder?.restaurantDiscountAmount ?? 0,
            serviceChargeAmount: double.parse(
                order.orderDetailsOrder?.totalServiceTaxAmount ?? '0'),
            deliveryCharge: order.orderDetailsOrder?.deliveryCharge ?? 0,
            gstAmount:
                double.parse(order.orderDetailsOrder?.totalGstTaxAmount ?? '0'),
            vatAmount:
                double.parse(order.orderDetailsOrder?.totalVatTaxAmount ?? '0'),
            grandTotal: order.orderDetailsOrder?.orderAmount ?? 0,
            tips: order.orderDetailsOrder?.tipAmount ?? 0,
            orderType: order.orderDetailsOrder?.orderType ?? '',
          ),
          setState); //kitchen
    } else {
      await _iosPrintEscPos(
          await PrintByteConvert().byteConvert(
            printType: 'paid_bill',
            paperRoll:
                Get.find<AuthController>().profileModel!.billPrinterPaperRoll ==
                        58
                    ? 58
                    : 80,
            orderId: order.orderDetailsOrder?.restaurantOrderId ?? '',
            date:
                '${DateFormat('${Get.find<AuthController>().profileModel?.restaurants?.first.billDateFormat ?? 'dd-MM-yyyy'}').format(DateTime.parse(order.orderDetailsOrder?.createdAt ?? DateTime.now().toIso8601String()))}',
            waiterName:
                '${order.restaurantDetails?.restaurantWaiterName ?? ''}',
            tablename: (order.restaurantDetails?.restaurantTableNo ?? '') == ''
                ? (order.orderDetailsOrder?.orderType == 'delivery'
                    ? 'Delivery'
                    : order.orderDetailsOrder?.orderType == 'take_away'
                        ? 'Take Away'
                        : 'WC')
                : (order.restaurantDetails?.restaurantTableArea ?? '') == ''
                    ? '${order.restaurantDetails?.restaurantTableNo ?? ''}'
                    : '${order.restaurantDetails?.restaurantTableArea ?? ''}:${order.restaurantDetails?.restaurantTableNo ?? ''}',
            custName: order.orderDetailsOrder?.username ?? '',
            custPhone: '${order.orderUser?.phone ?? ''}',
            paidFoodList: order.orderDetailsFood ?? [],
            orderNote: order.orderDetailsOrder?.orderNote ?? '',
            orderSubTotal: (order.orderTotalAmount ?? 0) +
                (order.orderTotalAddonAmt ?? 0) +
                (order.orderTotalVariantAmt ?? 0),
            discount: order.orderDetailsOrder?.restaurantDiscountAmount ?? 0,
            serviceChargeAmount: double.parse(
                order.orderDetailsOrder?.totalServiceTaxAmount ?? '0'),
            deliveryCharge: order.orderDetailsOrder?.deliveryCharge ?? 0,
            gstAmount:
                double.parse(order.orderDetailsOrder?.totalGstTaxAmount ?? '0'),
            vatAmount:
                double.parse(order.orderDetailsOrder?.totalVatTaxAmount ?? '0'),
            grandTotal: order.orderDetailsOrder?.orderAmount ?? 0,
            tips: order.orderDetailsOrder?.tipAmount ?? 0,
            orderType: order.orderDetailsOrder?.orderType ?? '',
          ),
          setState); //kitchen
    }
  }

  Future _kdsPrintEscPos(List<int> bytes, setState) async {
    // await printerManager.disconnect(type: PrinterType.bluetooth);
    BluetoothPrinter bluetoothPrinter;
    if (Get.find<AuthController>().profileModel!.billPrinterType == 'usb') {
      bluetoothPrinter = await BluetoothPrinter(
          productId: Get.find<AuthController>().profileModel!.billProductId,
          vendorId: Get.find<AuthController>().profileModel!.billVendorId,
          typePrinter: PrinterType.usb);
    } else {
      bluetoothPrinter = await BluetoothPrinter(
          typePrinter: Get.find<AuthController>().profileModel!.billWifiIp != ''
              ? PrinterType.network
              : PrinterType.bluetooth,
          port: '9100',
          address: Get.find<AuthController>().profileModel!.billWifiIp != ''
              ? Get.find<AuthController>().profileModel!.billWifiIp
              : Get.find<AuthController>().profileModel!.billPrinterIp,
          deviceName: Get.find<AuthController>()
              .profileModel!
              .billPrinterName); // ip was mandadory
    }

    var data;
    // if (Get.find<AuthController>().profileModel!.billPrinterType == 'usb') {
    //   data = await printerManager.connect(
    //     type: PrinterType.usb,
    //     model: UsbPrinterInput(
    //       productId: Get.find<AuthController>().profileModel!.billProductId,
    //       vendorId: Get.find<AuthController>().profileModel!.billVendorId,
    //     ),
    //   );
    // } else {
    //   data = await printerManager.connect(
    //     type: bluetoothPrinter.typePrinter,
    //     model: BluetoothPrinterInput(
    //       name: bluetoothPrinter.deviceName,
    //       address: bluetoothPrinter.address!,
    //     ),
    //   );
    // }
    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb:
        // bytes += generator.feed(2);
        await printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: UsbPrinterInput(
            name: bluetoothPrinter.deviceName,
            productId: bluetoothPrinter.productId,
            vendorId: bluetoothPrinter.vendorId,
          ),
        );
        break;
      case PrinterType.bluetooth:
        await printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: BluetoothPrinterInput(
            name: bluetoothPrinter.deviceName,
            address: bluetoothPrinter.address!,
            isBle: bluetoothPrinter.isBle ?? false,
          ),
        );
        pendingTask = null;
        if (Platform.isIOS || Platform.isAndroid) pendingTask = bytes;
        break;
      case PrinterType.network:
        // bytes += generator.feed(2);
        await printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!),
        );
        break;
      default:
    }
    print(data);

    try {
      await printerManager.send(
          type: bluetoothPrinter.typePrinter, bytes: bytes);
      isPrintedList[currentPrintIndex] = true; //It show status of start print
      isPrinterProccessingList[currentPrintIndex] = false;
      pendingTask = null;
      currentPrintIndex = currentPrintIndex + 1;
      setState(() {});
      dataCheck(setState);
      // await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
    } catch (e) {}
    if (data != null && !data) {
      // await Get.find<LoadingController>().changeText(
      //     data: Get.find<AuthController>().profileModel.billPrinterType == 'usb'
      //         ? 'Failed to usb connect!!'
      //         : 'Failed to bluetooth connect!!',
      //     error: true);
      // await Get.find<LoadingController>().changeStatus(data: true);
    }
  }

  // Future _iosPrintEscPos(List<int> bytes, setState) async {
  //   print('########## bytes length ${bytes.length}');
  //   // bytes += generator.feed(2);
  //   try {
  //     if (Get.find<AuthController>().profileModel!.macBillPrinterIp == '') {
  //       showErrorToast('Failed to bluetooth connect');
  //       isPrinterProccessingList[currentPrintIndex] = false;
  //       pendingTask = null;
  //       currentPrintIndex = currentPrintIndex + 1;
  //       setState(() {});
  //       dataCheck(setState);
  //     } else {
  //       await PrintBluetoothThermal.pairedBluetooths;

  //       // Future.delayed(Duration(seconds: 5), () async {
  //       final bool result = await PrintBluetoothThermal.connect(
  //           macPrinterAddress:
  //               Get.find<AuthController>().profileModel!.macBillPrinterIp!);

  //       Future.delayed(Duration(seconds: 2), () async {
  //         if (result) {
  //           // List<int> ticket = await testTicket();
  //           await PrintBluetoothThermal.writeBytes(bytes);

  //           isPrintedList[currentPrintIndex] =
  //               true; //It show status of start print
  //           isPrinterProccessingList[currentPrintIndex] = false;
  //           pendingTask = null;
  //           currentPrintIndex = currentPrintIndex + 1;
  //           setState(() {});
  //           dataCheck(setState);
  //         } else {
  //           Get.find<KdsController>().setProcessing(false);

  //           //no conectado, reconecte
  //           showErrorToast('Failed to bluetooth connect');
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     Get.find<KdsController>().setProcessing(false);
  //     showErrorToast('Failed to bluetooth connect');
  //   }

  //   // });
  // }
  Future _iosPrintEscPos(List<int> bytes, Function setState) async {
    print('########## bytes length ${bytes.length}');

    try {
      final String macAddress =
          Get.find<AuthController>().profileModel!.macBillPrinterIp ?? '';

      if (macAddress.isEmpty && NetworkPrinterResolver.billPrinter() == null) {
        showErrorToast('Failed to bluetooth connect');

        isPrinterProccessingList[currentPrintIndex] = false;
        pendingTask = null;
        currentPrintIndex++;

        setState(() {});
        dataCheck(setState);
        return;
      }

      if (NetworkPrinterResolver.billPrinter() == null)
        await PrintBluetoothThermal.pairedBluetooths;

      final bool result = await IosPrintTransport.connect(wifiPrinter: NetworkPrinterResolver.billPrinter(), 
        macPrinterAddress: macAddress,
      );

      // ✅ iPad needs settle time after connect
      await Future.delayed(const Duration(seconds: 2));

      if (!result) {
        Get.find<KdsController>().setProcessing(false);
        showErrorToast('Failed to bluetooth connect');
        return;
      }

      try {
        // 🔥 SAME SAFE LOGIC AS YOUR PERFECT FUNCTION
        if (Get.find<AuthController>().profileModel!.billPrinterPaperRoll ==
                58 ||
            MediaQuery.of(context).size.shortestSide < 570) {
          // 58mm OR phone → direct write
          await IosPrintTransport.writeBytes(bytes);
        } else {
          // 80mm + iPad → chunked write
          await _writeBytesForIPad(bytes);
        }

        // Small buffer flush delay
        await Future.delayed(const Duration(seconds: 2));

        isPrintedList[currentPrintIndex] = true;
        isPrinterProccessingList[currentPrintIndex] = false;
        pendingTask = null;
        currentPrintIndex++;

        setState(() {});
        dataCheck(setState);
      } catch (e) {
        print('Print error: $e');
        Get.find<KdsController>().setProcessing(false);
        showErrorToast('Failed to bluetooth connect');
      } finally {
      }
    } catch (e) {
      print('Outer print error: $e');
      Get.find<KdsController>().setProcessing(false);
      showErrorToast('Failed to bluetooth connect');
    }
  }

  Future<void> _writeBytesForIPad(List<int> bytes) async {
    const int chunkSize = 255; // iPad safe
    const int delayMs = 60;

    for (int i = 0; i < bytes.length; i += chunkSize) {
      final chunk = bytes.sublist(
        i,
        (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize,
      );

      await IosPrintTransport.writeBytes(chunk);
      await Future.delayed(const Duration(milliseconds: delayMs));
    }
  }

  Widget editUserBottomSheet() {
    return GetBuilder<CartController>(builder: (cartController) {
      return cartController.isLoading
          ? CircularProgressIndicator()
          : Container(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Customer Detail',
                              style: poppinsMedium.copyWith(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                Get.back();
                              },
                              child: Icon(
                                Icons.close,
                                size: 30,
                                color: ColorTheme.appColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: ColorTheme.borderGrey),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 40,
                        child: cartController.customerList == null
                            ? TextField(
                                controller: _nameController,
                                autofocus: false,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  hintText: 'Name',
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
                                          color: ColorTheme.borderGrey)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide(
                                        color: ColorTheme.borderGrey),
                                  ),
                                  hintStyle: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
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
                                textFieldConfiguration: TextFieldConfiguration(
                                  onChanged: (value) {
                                    if (userId != '') {
                                      _phoneController.text = '';
                                      userId = '';
                                      if (mounted) setState(() {});
                                    }
                                    if (isCouponValidate) {
                                      _couponController.text = '';
                                      isCouponValidate = false;
                                      userId = '';
                                      if (mounted) setState(() {});
                                    }
                                    walletBalance = 0;
                                    walletUsed = 0;
                                    if (Get.find<PosController>()
                                        .isApplyWallet) {
                                      Get.find<PosController>()
                                          .applyWalletBalance(false);
                                    }
                                  },
                                  controller: _nameController,
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
                                    hintText: 'Name',
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
                                      .customerList!.customerList
                                      .where((item) =>
                                          item.customerName != '' &&
                                          item.customerName
                                              .toString()
                                              .trim()
                                              .toLowerCase()
                                              .contains(
                                                  pattern.toLowerCase().trim()))
                                      .toList();
                                },
                                itemBuilder:
                                    (context, CustomerList suggestion) {
                                  return Padding(
                                    padding: EdgeInsets.all(
                                        Dimensions.PADDING_SIZE_SMALL),
                                    child: Row(children: [
                                      SizedBox(
                                          width: Dimensions.PADDING_SIZE_SMALL),
                                      Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${suggestion.customerName ?? ''}',
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
                                    (CustomerList suggestion) {
                                  _phoneController.text =
                                      suggestion.phone.toString();
                                  _nameController.text =
                                      suggestion.customerName;
                                  _cGSTController.text = suggestion.gstNo;
                                  _cGSTNameController.text = suggestion.gstName;
                                  _dobController.text = suggestion.dateOfBirth;
                                  _anniversaryController.text =
                                      suggestion.dateOfAnniversary;
                                  _memberIdController.text =
                                      suggestion.membershipId;

                                  // Set dropdown based on membershipId
                                  print(
                                      'DEBUG Name Field: membershipId from API = "${suggestion.membershipId}"');

                                  _selectedDropdownOption =
                                      suggestion.membershipId;

                                  print(
                                      'DEBUG Name Field: _selectedDropdownOption set to = "$_selectedDropdownOption"');
                                  // setState(() {});
                                  // emailController.text = suggestion.email;
                                  Get.find<CartController>().update();
                                },
                              ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: 40,
                        child: cartController.customerList == null
                            ? TextField(
                                controller: _phoneController,
                                textInputAction: TextInputAction.search,
                                autofocus: false,
                                textCapitalization: TextCapitalization.words,
                                keyboardType: TextInputType.numberWithOptions(
                                    signed: true),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9,+]")),
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Mobile Number',
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
                                      fontSize: 13, color: ColorTheme.hintText),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (String d) async {
                                  if (_phoneController.text.isNotEmpty &&
                                      GetUtils.isPhoneNumber(
                                          _phoneController.text)) {
                                    List<SearchCustomerResponseModel>
                                        searchData =
                                        await Get.find<CartController>()
                                            .searchWaiterPOSCustomer(
                                                _phoneController.text);
                                    if (searchData.isNotEmpty &&
                                        searchData.first.id != 'false') {
                                      if (searchData.first.name != '')
                                        _nameController.text =
                                            searchData.first.name;
                                    }
                                  }
                                },
                                style: poppinsMedium.copyWith(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              )
                            : TypeAheadField(
                                getImmediateSuggestions: true,
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: _phoneController,
                                  onChanged: (value) {
                                    if (userId != '') {
                                      _nameController.text = '';
                                      userId = '';
                                      if (mounted) setState(() {});
                                    }
                                    if (isCouponValidate) {
                                      _couponController.text = '';
                                      isCouponValidate = false;
                                      userId = '';
                                      if (mounted) setState(() {});
                                    }
                                    walletBalance = 0;
                                    walletUsed = 0;
                                    if (Get.find<PosController>()
                                        .isApplyWallet) {
                                      Get.find<PosController>()
                                          .applyWalletBalance(false);
                                    }
                                  },
                                  textInputAction: TextInputAction.search,
                                  autofocus: false,
                                  textCapitalization: TextCapitalization.words,
                                  keyboardType: TextInputType.numberWithOptions(
                                      signed: true),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9,+]")),
                                  ],
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
                                    hintText: 'Phone Number',
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
                                      .customerList!.customerList
                                      .where((item) =>
                                          item.phone != '' &&
                                          item.phone
                                              .toString()
                                              .trim()
                                              .toLowerCase()
                                              .contains(
                                                  pattern.toLowerCase().trim()))
                                      .toList();
                                },
                                itemBuilder:
                                    (context, CustomerList suggestion) {
                                  return Padding(
                                    padding: EdgeInsets.all(
                                        Dimensions.PADDING_SIZE_SMALL),
                                    child: Row(children: [
                                      SizedBox(
                                          width: Dimensions.PADDING_SIZE_SMALL),
                                      Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('${suggestion.phone ?? ''}',
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
                                    (CustomerList suggestion) {
                                  _cGSTController.text = suggestion.gstNo;
                                  _cGSTNameController.text = suggestion.gstName;

                                  _phoneController.text =
                                      suggestion.phone.toString();
                                  _nameController.text =
                                      suggestion.customerName;
                                  _dobController.text = suggestion.dateOfBirth;
                                  _anniversaryController.text =
                                      suggestion.dateOfAnniversary;
                                  _memberIdController.text =
                                      suggestion.membershipId;

                                  // Set dropdown based on membershipId

                                  _selectedDropdownOption =
                                      suggestion.membershipId;

                                  // setState(() {});
                                  // emailController.text = suggestion.email;
                                  Get.find<CartController>().update();
                                },
                              ),
                      ),
                      if (Get.find<AuthController>()
                              .profileModel!
                              .restaurants!
                              .first
                              .showUserGst ==
                          'Yes')
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          height: 40,
                          child: cartController.customerList == null
                              ? TextField(
                                  controller: _cGSTNameController,
                                  autofocus: false,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    hintText: 'GST Name',
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
                                            color: ColorTheme.borderGrey)),
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
                                    controller: _cGSTNameController,
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
                                      hintText: 'GST Name',
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
                                        .customerList!.customerList
                                        .where((item) =>
                                            item.gstName != '' &&
                                            item.gstName
                                                .toString()
                                                .trim()
                                                .toLowerCase()
                                                .contains(pattern
                                                    .toLowerCase()
                                                    .trim()))
                                        .toList();
                                  },
                                  itemBuilder:
                                      (context, CustomerList suggestion) {
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
                                                    '${suggestion.gstName ?? ''}',
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
                                      (CustomerList suggestion) {
                                    _cGSTController.text = suggestion.gstNo;
                                    _cGSTNameController.text =
                                        suggestion.gstName;
                                    _phoneController.text =
                                        suggestion.phone.toString();
                                    _nameController.text =
                                        suggestion.customerName;
                                    _dobController.text =
                                        suggestion.dateOfBirth;
                                    _anniversaryController.text =
                                        suggestion.dateOfAnniversary;
                                    _memberIdController.text =
                                        suggestion.membershipId;

                                    // Set dropdown based on membershipId

                                    _selectedDropdownOption =
                                        suggestion.membershipId;

                                    // setState(() {});
                                    // emailController.text = suggestion.email;
                                    Get.find<CartController>().update();
                                  },
                                ),
                        ),
                      if (Get.find<AuthController>()
                              .profileModel!
                              .restaurants!
                              .first
                              .showUserGst ==
                          'Yes')
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          height: 40,
                          child: TextField(
                            controller: _cGSTController,
                            autofocus: false,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              hintText: 'GST No',
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
                                      BorderSide(color: ColorTheme.borderGrey)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7),
                                borderSide:
                                    BorderSide(color: ColorTheme.borderGrey),
                              ),
                              hintStyle: poppinsMedium.copyWith(
                                  fontSize: 13, color: ColorTheme.hintText),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: poppinsMedium.copyWith(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),

                      // Date of Birth Field
                      Container(
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

                      // Date of Anniversary Field
                      Container(
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

                      // Member ID Field
                      // Container(
                      //   margin: EdgeInsets.only(top: 15),
                      //   height: 40,
                      //   child: TextField(
                      //     controller: _memberIdController,
                      //     autofocus: false,
                      //     textCapitalization: TextCapitalization.characters,
                      //     decoration: InputDecoration(
                      //       hintText: 'Member ID',
                      //       contentPadding: EdgeInsets.symmetric(
                      //           vertical: 0, horizontal: 15),
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
                      //     ),
                      //     style: poppinsMedium.copyWith(
                      //       color: Colors.black,
                      //       fontSize: 13,
                      //     ),
                      //   ),
                      // ),

                      // Dropdown Field
                      GetBuilder<CustomerManagementController>(
                        builder: (customerController) {
                          // Filter active designations (status == 1)
                          final activeDesignations = customerController
                              .customerDesignationList
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
                                child: customerController
                                        .isCustomerDesignationLoading.value
                                    ? Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          // child: CircularProgressIndicator(
                                          //   strokeWidth: 2,
                                          //   color: ColorTheme.appColor,
                                          // ),
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

                      SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: () async {
                                if (_nameController.text.isEmpty) {
                                  showErrorToast('Please enter customer name');
                                } else if (_phoneController.text.isEmpty ||
                                    _phoneController.text.isNotEmpty &&
                                        _phoneController.text.length < 10) {
                                  showErrorToast(
                                      'Please enter valid phone number');
                                } else {
                                  String id = await cartController
                                      .changeCustomerDetail({
                                    "phone": _phoneController.text,
                                    "f_name": _nameController.text,
                                    "l_name": "",
                                    "email": "",
                                    "gst_number": _cGSTController.text ?? '',
                                    "gst_name": _cGSTNameController.text ?? '',
                                    "date_of_birth": _dobController.text ?? '',
                                    "date_of_anniversary":
                                        _anniversaryController.text ?? '',
                                    "membership_id":
                                        _selectedDropdownOption ?? '',
                                    "order_id": widget.orderId
                                  }, (bool value) {
                                    Get.back();
                                  });
                                  //     .then((value) {

                                  // });
                                  userId = id;
                                  walletBalance = 0;
                                  walletUsed = 0;
                                  if (Get.find<PosController>().isApplyWallet) {
                                    Get.find<PosController>()
                                        .applyWalletBalance(false);
                                  }
                                  if (userId != '') {
                                    var data = await Get.find<CartController>()
                                        .getWalletBalanceOfCustomer('$userId');
                                    if (data != {} &&
                                        data.containsKey('balance')) {
                                      // usedLoyaltyPoint = double.parse('${data['pointsToRedeem'] ?? 0}');
                                      walletBalance = double.parse(
                                          '${data['balance'] ?? 0}');
                                    }
                                  }
                                  if (userId != '' &&
                                      (Get.find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .settings!
                                              .isLoyality ==
                                          'Yes')) {
                                    usedLoyaltyPoint = 0;
                                    // if (Get.find<PosController>().isApplyLoyalty) {
                                    Get.find<PosController>()
                                        .applyLoyaltyValue(false);
                                    // var data = await Get.find<LoyaltyController>()
                                    //     .checkValidLoyaltyPoint('$userId',
                                    //         Get.find<PosController>().collectItemPrice,
                                    //         isLoading: false);
                                    // if (data != {} && data.containsKey('pointsToRedeem')) {
                                    //   availableLoyaltyPoint = double.parse('${data['availablePoints'] ?? 0}');
                                    // }
                                    _crmOfferKey = '';
                                    _scheduleCrmOffers();
                                    // }
                                  }
                                }
                              },
                              child: Container(
                                height: 35,
                                width: 110,
                                decoration: BoxDecoration(
                                  color: ColorTheme.appColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'Submit',
                                    style: poppinsMedium.copyWith(
                                      fontSize:
                                          MediaQuery.of(context).size.width >
                                                  1600
                                              ? 18
                                              : 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () async {
                                double orderPay = (Get.find<PosController>()
                                    .collectItemPrice);

                                if (_nameController.text.isEmpty) {
                                  showErrorToast('Please enter customer name');
                                } else if (_phoneController.text.isEmpty ||
                                    _phoneController.text.isNotEmpty &&
                                        _phoneController.text.length < 10) {
                                  showErrorToast(
                                      'Please enter valid phone number');
                                } else {
                                  final data = {
                                    'payment_amount': Get.find<AuthController>()
                                                .profileModel
                                                ?.restaurants
                                                ?.first
                                                .isTotalRound ==
                                            'Yes'
                                        ? getRoundUpValue(value: orderPay)
                                        : orderPay.toStringAsFixed(2),
                                    "grant_amount": Get.find<AuthController>()
                                                .profileModel
                                                ?.restaurants
                                                ?.first
                                                .isTotalRound ==
                                            'Yes'
                                        ? getRoundUpValue(
                                            value:
                                                (orderPay + roomTotalPaymnet))
                                        : (orderPay + roomTotalPaymnet)
                                            .toStringAsFixed(2),
                                    "vat_tax": vatAmount,
                                    "gst_tax": gstAmount,
                                    "self_discount": 0.0,
                                    "comm_discount": coummunityDiscount,
                                    "tip_amount": _addTips.text.isEmpty
                                        ? 0
                                        : double.parse(_addTips.text),
                                    "order_discount": orderDiscount,
                                    "mobile": _phoneController.text,
                                    "name": _nameController.text,
                                    "restaurant_name":
                                        Get.find<AuthController>()
                                                .profileModel
                                                ?.restaurants
                                                ?.first
                                                .name ??
                                            '',
                                    "service_tax": showServiceChargeValue,
                                    "order_id": widget.orderId
                                  };
                                  await cartController.whatsappBill(data);

                                  final billData = {
                                    "payment_amount": Get.find<AuthController>()
                                                .profileModel
                                                ?.restaurants
                                                ?.first
                                                .isTotalRound ==
                                            'Yes'
                                        ? getRoundUpValue(value: (orderPay))
                                        : orderPay.toStringAsFixed(2),
                                    "customer_name": _nameController.text,
                                    "customer_phone": _phoneController.text,
                                    "restaurant_name":
                                        Get.find<AuthController>()
                                                .profileModel
                                                ?.restaurants
                                                ?.first
                                                .name ??
                                            '',
                                    "order_id": widget.orderId
                                  };
                                  await cartController
                                      .sendWhatsappPaymentLink(billData);

                                  Get.back();
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                height: 35,
                                decoration: BoxDecoration(
                                  color: ColorTheme.appColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'Send Payment Link',
                                    style: poppinsMedium.copyWith(
                                      fontSize:
                                          MediaQuery.of(context).size.width >
                                                  1600
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
                    ],
                  ),
                ),
              ),
            );
    });
  }

  Widget complementryFoodBottomSheet(
      PosController posController, List<OrderDetailsBar> complementryFoodList) {
    return StatefulBuilder(builder: (context, setModalState) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Complementary Food',
                        style: poppinsMedium.copyWith(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(
                          Icons.close,
                          size: 30,
                          color: ColorTheme.appColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: ColorTheme.borderGrey),
                ),
                Flexible(
                  child: ListView.builder(
                    itemCount: complementryFoodList.length,
                    padding: EdgeInsets.all(0),
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int i) {
                      OrderDetailsBar orderDetailsFood =
                          complementryFoodList[i];
                      String variationText = '';
                      double variationTotal = 0;
                      double addonsTotal = 0;
                      double halfVariationPrice = 0;

                      if (orderDetailsFood.variation != null &&
                          orderDetailsFood.variation!.isNotEmpty) {
                        for (int j = 0;
                            j < orderDetailsFood.variation!.length;
                            j++) {
                          variationText +=
                              '${variationText.isNotEmpty ? ', ' : ''}${orderDetailsFood.variation![j].name} (';

                          if (orderDetailsFood.variation![j].values != null) {
                            List<String> labelList = [];
                            if (orderDetailsFood.variation![j].values != null) {
                              for (var element
                                  in orderDetailsFood.variation![j].values!) {
                                labelList.add(element.level ?? '');
                                // variationTotal += (int.parse(
                                //         element.optionPrice) *
                                //     orderDetailsFood.quantity);
                                final variationName =
                                    orderDetailsFood.variation![j].name ?? '';
                                final optionPrice = double.tryParse(
                                        element.optionPrice ?? '0') ??
                                    0.0;
                                final quantity = orderDetailsFood.quantity ?? 0;
                                if (variationName.toUpperCase() ==
                                    'HALFNHALF') {
                                  if (halfVariationPrice <
                                      optionPrice * quantity) {
                                    halfVariationPrice = optionPrice * quantity;
                                  }
                                } else {
                                  variationTotal =
                                      variationTotal + optionPrice * quantity;
                                }
                              }
                            }
                            variationText +=
                                '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                          }

                          variationText += ')';
                          variationTotal = variationTotal + halfVariationPrice;
                        }
                      }

                      String addons = '';
                      if (orderDetailsFood.addOns != null) {
                        for (var i = 0;
                            i < (orderDetailsFood.addOns?.length ?? 0);
                            i++) {
                          final addOn = orderDetailsFood.addOns![i];
                          final addOnPrice = addOn.price ?? 0;
                          final addOnQuantity = addOn.quantity ?? 0;
                          final foodQuantity = orderDetailsFood.quantity ?? 0;
                          addonsTotal = addonsTotal +
                              ((addOnPrice * addOnQuantity) * foodQuantity);
                          addons += '${addOn.name ?? ''} (${addOnQuantity})';
                        }
                      }
                      return (orderDetailsFood.foodDetails!['name']
                                      .toString()
                                      .toLowerCase() ==
                                  'check in' ||
                              orderDetailsFood.foodStatus == 3)
                          ? SizedBox.shrink()
                          : InkWell(
                              onTap: () {
                                orderDetailsFood.isSelectComplementary =
                                    !orderDetailsFood.isSelectComplementary!;
                                if (mounted) setModalState(() {});
                              },
                              child: Padding(
                                padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      width: 30,
                                      child: Checkbox(
                                          value: orderDetailsFood
                                              .isSelectComplementary,
                                          onChanged: (val) {
                                            orderDetailsFood
                                                .isSelectComplementary = val!;
                                            if (mounted)
                                              setModalState(
                                                  () {}); // <-- THIS rebuilds bottom sheet
                                          }),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${orderDetailsFood.foodDetails!['name'] ?? ''} (${orderDetailsFood.quantity ?? ''})',
                                            style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 17
                                                    : 11),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (addons != '')
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Add-Ons :',
                                                    style: poppinsMedium.copyWith(
                                                        fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .shortestSide >
                                                                570
                                                            ? 14
                                                            : 10,
                                                        color: ColorTheme.blue),
                                                  ),
                                                  TextSpan(
                                                    text: ' $addons',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .shortestSide >
                                                              570
                                                          ? 13
                                                          : 10,
                                                      color: ColorTheme.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          variationText == ''
                                              ? SizedBox.shrink()
                                              : Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'Variants  :',
                                                        style: poppinsMedium.copyWith(
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .shortestSide >
                                                                    570
                                                                ? 14
                                                                : 10,
                                                            color: ColorTheme
                                                                .blue),
                                                      ),
                                                      TextSpan(
                                                        text: ' $variationText',
                                                        style: poppinsMedium.copyWith(
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .shortestSide >
                                                                    570
                                                                ? 13
                                                                : 10,
                                                            color: ColorTheme
                                                                .green),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    SizedBox(
                                      width: 50,
                                      child: Text(
                                          '${((orderDetailsFood.unitPrice ?? 0) * (orderDetailsFood.quantity ?? 0) + variationTotal + addonsTotal)}',
                                          style: poppinsSemiBold.copyWith(
                                              decoration: orderDetailsFood
                                                          .foodStatus ==
                                                      3
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .shortestSide >
                                                      570
                                                  ? 16
                                                  : 11),
                                          textAlign: TextAlign.right),
                                    ),
                                  ],
                                ),
                              ),
                            );
                    }),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () async {
                      for (var element in complementryFoodList) {
                        if (element.isSelectComplementary!) {
                          element.isComplementary = true;
                        } else {
                          element.isComplementary = false;
                        }
                      }
                      posController.convertMergeAfterApplyComplement(
                          complementryFoodList);
                      amountCalculation();
                      Get.back();
                    },
                    child: Container(
                      height: 35,
                      width: 110,
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
    });
  }

  Future<Uint8List> summaryBillPdf() async {
    print('s...............summary bill pdf');
    p.Orders? order =
        Get.find<PosController>().getCollectBillDetailResponse!.orders;
    ProfileModel? profileModel = Get.find<AuthController>().profileModel;
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final font = await PdfGoogleFonts.poppinsMedium();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat(
          profileModel!.billPrinterPaperRoll == 58
              ? 48 * PdfPageFormat.mm
              : 72 * PdfPageFormat.mm,
          850,
          marginLeft: 0,
          marginRight: 0,
        ), // 58mm width
        build: (context) {
          return [
            pw.Column(
              children: [
                pw.Text(profileModel.restaurants!.first.name!,
                    style: pw.TextStyle(font: font, fontSize: 10)),
                pw.SizedBox(height: 5),
                pw.Text(profileModel.restaurants!.first.address!,
                    style: pw.TextStyle(font: font, fontSize: 8)),
                if (profileModel.restaurants![0].gstCode != '')
                  pw.SizedBox(height: 5),
                if (profileModel.restaurants![0].gstCode != '')
                  pw.Text('GST no. ${profileModel.restaurants!.first.gstCode}',
                      style: pw.TextStyle(font: font, fontSize: 8)),
                if (profileModel.restaurants![0].fssai != '')
                  pw.SizedBox(height: 5),
                if (profileModel.restaurants![0].fssai != '')
                  pw.Text('FSI no. ${profileModel.restaurants!.first.fssai}',
                      style: pw.TextStyle(font: font, fontSize: 8)),

// ////////////////   ORDER DETAIL    /////////////////

                pw.Row(children: [
                  pw.Expanded(
                      child: pw.Align(
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(
                        'Order ID. ${order!.orderDetailsOrder!.restaurantOrderId}',
                        style: pw.TextStyle(font: font, fontSize: 6)),
                  )),
                  pw.SizedBox(width: 4),
                  pw.Expanded(
                      child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                        '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.parse(order.orderDetailsOrder!.createdAt!))}',
                        style: pw.TextStyle(font: font, fontSize: 6)),
                  ))
                ]),
                if (order.orderDetailsOrder!.orderType != 'delivery' &&
                    order.orderDetailsOrder!.orderType != 'take_away')
                  pw.Row(children: [
                    pw.Expanded(
                        child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text('Dine In',
                          style: pw.TextStyle(font: font, fontSize: 6)),
                    )),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                        child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text('${order.restaurantDetails!.waiterName}',
                          style: pw.TextStyle(font: font, fontSize: 6)),
                    ))
                  ]),
                pw.Row(children: [
                  pw.Expanded(
                      child: pw.Align(
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(_nameController.text ?? '',
                        style: pw.TextStyle(font: font, fontSize: 6)),
                  )),
                  pw.SizedBox(width: 5),
                  pw.Expanded(
                      child: pw.Align(
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(_phoneController.text ?? '',
                        style: pw.TextStyle(font: font, fontSize: 6)),
                  ))
                ]),
                if (order.roomInfo?.gstName != null &&
                    order.roomInfo?.gstNo != null)
                  pw.Column(children: [
                    pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(order.roomInfo?.gstName ?? '',
                          style: pw.TextStyle(font: font, fontSize: 6)),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(order.roomInfo?.gstNo ?? '',
                          style: pw.TextStyle(font: font, fontSize: 6)),
                    )
                  ]),
                pw.Text(
                    order.restaurantDetails!.tableNo == ''
                        ? order.orderDetailsOrder?.orderType == 'delivery'
                            ? 'Delivery'
                            : order.orderDetailsOrder!.orderType == 'take_away'
                                ? 'Take Away'
                                : 'WC'
                        : order.restaurantDetails!.tableArea == ''
                            ? '${order.restaurantDetails!.tableNo}'
                            : '${order.restaurantDetails!.tableArea}:${order.restaurantDetails!.tableNo}',
                    style: pw.TextStyle(font: font, fontSize: 6)),
                pw.Divider(),

                if (Get.find<PosController>()
                            .getCollectBillDetailResponse!
                            .orders!
                            .restaurantDetails!
                            .restaurantOrderFor ==
                        'ROOM' &&
                    Get.find<PosController>().roomBillsList.isNotEmpty)
                  pw.Column(children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(vertical: 7),
                      child: buildDottedLine(180),
                    ),
                    pw.Text('Bill Summary',
                        style: pw.TextStyle(font: font, fontSize: 6)),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(vertical: 7),
                      child: buildDottedLine(180),
                    ),
                  ]),
// //////////////////   FOOD DETAIL   ///////////////////

                pw.Row(children: [
                  pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                        child: pw.Text('SL',
                            style: pw.TextStyle(font: font, fontSize: 6)),
                      )),
                  pw.SizedBox(width: 3),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Center(
                        child: pw.Text('Order Id',
                            style: pw.TextStyle(font: font, fontSize: 6)),
                      )),
                  pw.SizedBox(width: 3),
                  pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                        child: pw.Text('Amount',
                            style: pw.TextStyle(font: font, fontSize: 6)),
                      )),
                  pw.SizedBox(width: 3),
                  pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                        child: pw.Text('Date'.tr,
                            style: pw.TextStyle(font: font, fontSize: 6)),
                      )),
                ]),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(vertical: 7),
                  child: buildDottedLine(180),
                ),
                ...List.generate(
                    Get.find<PosController>().roomBillsList.length + 1, (i) {
                  GetRoomBillsResponseModel? customerData;
                  if (i != 0)
                    customerData =
                        Get.find<PosController>().roomBillsList[i - 1];
                  return pw.Column(children: [
                    pw.Row(children: [
                      pw.Expanded(
                          flex: 1,
                          child: pw.Center(
                            child: pw.Text('${i + 1}.',
                                style: pw.TextStyle(font: font, fontSize: 6)),
                          )),
                      pw.Expanded(
                          flex: 2,
                          child: pw.Center(
                            child: pw.Text(
                                i == 0
                                    ? '${Get.find<PosController>().getCollectBillDetailResponse!.orders!.orderDetailsOrder!.restaurantOrderId} '
                                    : customerData!.restaurantOrderId == '0'
                                        ? customerData.orderId.toString()
                                        : customerData.restaurantOrderId!,
                                style: pw.TextStyle(font: font, fontSize: 6)),
                          )),
                      pw.Expanded(
                          flex: 2,
                          child: pw.Center(
                            child: pw.Text(
                                i == 0
                                    ? PriceConverter.convertPrice(
                                        (Get.find<PosController>()
                                            .collectItemPrice),
                                        isHideCurrency: true,
                                        asFixed: 2)
                                    : double.parse(customerData!.orderAmount!)
                                        .toStringAsFixed(2),
                                style: pw.TextStyle(font: font, fontSize: 6)),
                          )),
                      pw.SizedBox(width: 3),
                      pw.Expanded(
                          flex: 1,
                          child: pw.Center(
                            child: pw.Text(
                                i == 0
                                    ? '${DateFormat('dd-MMM').format(DateTime.parse(Get.find<PosController>().getCollectBillDetailResponse!.orders!.orderDetailsOrder!.createdAt!))}'
                                    : customerData!.createdAt == ''
                                        ? ''
                                        : '${DateFormat('dd-MMM').format(DateTime.parse(customerData.createdAt!))}',
                                style: pw.TextStyle(font: font, fontSize: 6)),
                          )),
                    ]),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(vertical: 7),
                      child: buildDottedLine(180),
                    ),
                  ]);
                }),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(vertical: 7),
                  child: buildDottedLine(180),
                ),

                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                      '${PriceConverter.convertPrice((Get.find<PosController>().collectItemPrice + roomTotalPaymnet), isHideCurrency: true, asFixed: 2)} ${profileModel.restaurants?.first.currency ?? ''}',
                      style: pw.TextStyle(font: font, fontSize: 8)),
                ),

                pw.SizedBox(height: 20),
                pw.SizedBox(height: 8),
                if (Get.find<AuthController>()
                        .profileModel!
                        .restaurants!
                        .first
                        .footerTextBill !=
                    '')
                  pw.Text(
                      Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .footerTextBill!,
                      style: pw.TextStyle(font: font, fontSize: 8)),
                pw.SizedBox(height: 8),
                pw.Text('Powered by MyGenie',
                    style: pw.TextStyle(font: font, fontSize: 8)),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List>? generateRoomBillPdf() async {
    print('room bill pdf....................');
    await Get.find<KdsController>().getPaidOrderDetail(
        '${Get.find<PosController>().roomBillsList[currentPrintIndex - 2].orderId}');

    paid.Orders? order =
        Get.find<KdsController>().paidOrderDetailResponse!.orders;
    return WindowsPrintByteConvert().byteConvert(
        printType: 'paid_bill',
        paperRoll:
            Get.find<AuthController>().profileModel!.billPrinterPaperRoll == 58
                ? 58
                : 80,
        orderId: order!.orderDetailsOrder!.restaurantOrderId,
        date:
            '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.parse(order.orderDetailsOrder!.createdAt!))}',
        waiterName: '${order.restaurantDetails!.restaurantWaiterName}',
        tablename: order.restaurantDetails!.restaurantTableNo == ''
            ? order.orderDetailsOrder?.orderType == 'delivery'
                ? 'Delivery'
                : order.orderDetailsOrder?.orderType == 'take_away'
                    ? 'Take Away'
                    : 'WC'
            : order.restaurantDetails!.restaurantTableArea == ''
                ? '${order.restaurantDetails!.restaurantTableNo}'
                : '${order.restaurantDetails!.restaurantTableArea}:${order.restaurantDetails!.restaurantTableNo}',
        custName: order.orderDetailsOrder?.username ?? '',
        custPhone: '${order.orderUser?.phone ?? ''}',
        paidFoodList: order.orderDetailsFood ?? [],
        orderNote: order.orderDetailsOrder?.orderNote ?? '',
        orderSubTotal: order.orderTotalAmount! +
            order.orderTotalAddonAmt! +
            order.orderTotalVariantAmt!,
        discount: order.orderDetailsOrder?.restaurantDiscountAmount ?? 0,
        serviceChargeAmount:
            double.parse(order.orderDetailsOrder?.totalServiceTaxAmount ?? '0'),
        deliveryCharge: order.orderDetailsOrder!.deliveryCharge ?? 0,
        gstAmount:
            double.parse(order.orderDetailsOrder?.totalGstTaxAmount ?? '0'),
        vatAmount:
            double.parse(order.orderDetailsOrder?.totalVatTaxAmount ?? '0'),
        gstName: Get.find<PosController>()
                .getCollectBillDetailResponse
                ?.orders
                ?.roomInfo
                ?.gstName ??
            '',
        gstNo: double.tryParse(Get.find<PosController>()
                .getCollectBillDetailResponse
                ?.orders
                ?.roomInfo
                ?.gstNo ??
            ''),
        grandTotal: order.orderDetailsOrder?.orderAmount ?? 0,
        tips: order.orderDetailsOrder?.tipAmount ?? 0,
        orderType: order.orderDetailsOrder?.orderType);
  }
}
