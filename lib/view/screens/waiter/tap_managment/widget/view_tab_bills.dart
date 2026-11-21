import 'dart:async';
import 'dart:io';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/tab_management_controller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/data/model/response/get_paid_order_detail_response.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_view_tab_bill_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/util/windows_byte_convert.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../../util/print_byte_convert.dart';

class ViewTabBills extends StatefulWidget {
  final String? customerId;
  final String? name;
  final String? phone;
  ViewTabBills({this.customerId, this.name, this.phone});

  @override
  State<ViewTabBills> createState() => _ViewTabBillsState();
}

class _ViewTabBillsState extends State<ViewTabBills> {
  List<String> filterList = ['Select Date', 'All'];
  String selectedFilter = 'All';
  List<CustomerTransactionList> orderList = [];

  String selectedDateRange = '';
  DateTime? startDate;
  DateTime? endDate;
  PrinterManager printerManager = PrinterManager.instance;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  List<int>? pendingTask;
  List<bool> isSelectPrinterList = [];
  List<bool> isPrinterProccessingList = [];
  List<bool> isPrintedList = [];
  bool isPrint = true;
  int currentPrintIndex = 0;
  bool isConnect = true;

  @override
  void initState() {
    super.initState();
    initCall();
  }

  initCall() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Get.find<TabManagementController>()
          .getViewTabBills(widget.customerId!);
      orderList = Get.find<TabManagementController>()
              .getViewTabBillsResponseModel
              ?.customerTransactionList ??
          [];
      await listenBluetooth();
    });
  }

  listenBluetooth() async {
    if (Platform.isAndroid) {
      _subscriptionBtStatus =
          PrinterManager.instance.stateBluetooth.listen((status) {
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
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask!);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.chevron_left, color: ColorTheme.green, size: 40),
            color: ColorTheme.appColor,
            onPressed: () {
              Get.back();
            }),
        titleSpacing: 0,
        centerTitle: false,
        elevation: 0,
        title: Image.asset(logoHelper.appLogo!, width: Get.width * 0.3),
      ),
      body: SafeArea(
        child: GetBuilder<TabManagementController>(builder: (tabController) {
          return tabController.isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          'Name: ${widget.name}',
                          style: poppinsSemiBold.copyWith(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'Phone: ${widget.phone}',
                          style: poppinsSemiBold.copyWith(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: ColorTheme.borderGrey),
                      ),
                      Row(
                        children: [
                          selectFilterType(tabController),
                          SizedBox(width: 10),
                          if (selectedFilter != 'All')
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  showDateDialog(tabController);
                                },
                                child: Container(
                                    height: 36,
                                    padding: EdgeInsets.only(left: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: ColorTheme.borderGrey),
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            selectedDateRange == ''
                                                ? 'Select Date'
                                                : selectedDateRange,
                                            style: poppinsMedium.copyWith(
                                                color: ColorTheme.hintText,
                                                fontSize: 13),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: Container(
                                              width: 1,
                                              height: 36,
                                              color: ColorTheme.borderGrey),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Icon(
                                            CupertinoIcons.calendar,
                                            size: 20,
                                            color: ColorTheme.appColor,
                                          ),
                                        )
                                      ],
                                    )),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: ColorTheme.bgSettleCardGreyColor),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'No.',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 11,
                                          color: ColorTheme.appColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Order Id',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 11,
                                          color: ColorTheme.appColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Amount',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 11,
                                          color: ColorTheme.appColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Order Date',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 11,
                                          color: ColorTheme.appColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Expanded(
                                  //   flex: 2,
                                  //   child: Text(
                                  //     'Tab Date',
                                  //     style: poppinsMedium.copyWith(
                                  //         fontSize: 12,
                                  //         color: ColorTheme.appColor),
                                  //     maxLines: 1,
                                  //     overflow: TextOverflow.ellipsis,
                                  //   ),
                                  // ),
                                  Expanded(flex: 2, child: SizedBox())
                                ],
                              ),
                              Expanded(
                                child: ListView.builder(
                                    padding: EdgeInsets.only(top: 13),
                                    itemCount: orderList.length ?? 0,
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    itemBuilder: (BuildContext context, int i) {
                                      CustomerTransactionList customerData =
                                          orderList[i];
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            top: i == 0 ? 0 : 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                '${i + 1}',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: 10),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                '${customerData.restaurantOrderId == '0' ? customerData.orderId : customerData.restaurantOrderId}',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: 10),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                double.parse(customerData
                                                        .creditOrderAmount!)
                                                    .toStringAsFixed(2),
                                                style: poppinsMedium.copyWith(
                                                    fontSize: 10),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                customerData.orderDate == ''
                                                    ? ''
                                                    : '${DateFormat('dd MMM').format(DateTime.parse(customerData.orderDate!))}',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: 10),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            // Expanded(
                                            //   flex: 2,
                                            //   child: Text(
                                            //     '${DateFormat('dd-MMM').format(DateTime.parse(customerData.createdAt))}',
                                            //     style: poppinsMedium.copyWith(
                                            //         fontSize: 12),
                                            //     maxLines: 1,
                                            //     overflow: TextOverflow.ellipsis,
                                            //   ),
                                            // ),
                                            SizedBox(width: 6),
                                            Expanded(
                                              flex: 2,
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  Get.toNamed(RouteHelper
                                                      .getTabBillDetail(
                                                          '${customerData.orderId}',
                                                          '${widget.name ?? ''}',
                                                          '${widget.phone ?? ''}'));
                                                  // await Get.find<
                                                  //         KdsController>()
                                                  //     .clearPaidOrderDetail();
                                                  // await Get.find<
                                                  //         KdsController>()
                                                  //     .getPaidOrderDetail(
                                                  //         '${customerData.orderId}');
                                                  // if (Get.find<KdsController>()
                                                  //         .paidOrderDetailResponse !=
                                                  //     null) {
                                                  //   kdsBytesConvert();
                                                  // }
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: Dimensions
                                                          .PADDING_SIZE_EXTRA_SMALL,
                                                      horizontal: 7),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors
                                                              .transparent),
                                                      color:
                                                          ColorTheme.appColor,
                                                      // border:
                                                      //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7)),
                                                  child: Center(
                                                    child: Text(
                                                      'Details',
                                                      style: poppinsMedium
                                                          .copyWith(
                                                              fontSize: 10,
                                                              color:
                                                                  Colors.white),
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
                              if (Get.find<AuthController>()
                                  .profileModel!
                                  .role!
                                  .contains('printer'))
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 30, bottom: 10),
                                  child: InkWell(
                                    onTap: () async {
                                      if (orderList.isNotEmpty) {
                                        // searchOrder.clear();
                                        currentPrintIndex = 0;
                                        isSelectPrinterList.clear();
                                        isPrintedList.clear();
                                        isPrinterProccessingList.clear();
                                        for (var i = 0;
                                            i < orderList.length;
                                            i++) {
                                          isSelectPrinterList
                                              .add(i == 0 ? true : false);
                                          isPrintedList.add(false);
                                          isPrinterProccessingList.add(false);
                                        }
                                        await Get.bottomSheet(
                                            printSummaryDialog(),
                                            ignoreSafeArea: false);
                                      }
                                    },
                                    child: SvgPicture.asset(
                                      Images.ic_print_kot,
                                      height: 26,
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
        }),
      ),
    );
  }

  Widget selectFilterType(TabManagementController tabController) {
    return Container(
      height: 36,
      width: Get.width * 0.3,
      padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
      decoration: BoxDecoration(
        border: Border.all(color: ColorTheme.borderGrey),
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: selectedFilter,
        icon: Icon(Icons.keyboard_arrow_down_outlined,
            color: ColorTheme.appColor),
        items: filterList.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              '$value',
              maxLines: 1,
              style: poppinsMedium.copyWith(
                  fontSize: 13, color: ColorTheme.hintText),
            ),
          );
        }).toList(),
        onChanged: (String? value) {
          selectedFilter = value ?? '';
          filterOrderRecord(tabController);
          print('....$value');
        },
        underline: SizedBox(),
      ),
    );
  }

  void showDateDialog(TabManagementController tabController) {
    DateTime? tempStartDate;
    DateTime? tempEndDate;
    String? tempdateRange;
    Get.bottomSheet(StatefulBuilder(builder: (context, setState) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
            color: Colors.white),
        child: Padding(
          padding: EdgeInsets.only(
              left: 25,
              right: 25,
              top: 25,
              bottom: Dimensions.PADDING_SIZE_DEFAULT),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text('Select Date',
                            style: poppinsMedium.copyWith(
                                fontSize: 18, color: Colors.black)),
                      ),
                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(Icons.close,
                            color: ColorTheme.appColor, size: 35),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SfDateRangePicker(
                    selectionColor: ColorTheme.appColor,
                    rangeTextStyle: poppinsMedium.copyWith(
                        fontSize: 14, color: ColorTheme.appColor),
                    selectionTextStyle: poppinsMedium.copyWith(fontSize: 14),
                    headerStyle: DateRangePickerHeaderStyle(
                        textStyle: poppinsMedium.copyWith(
                            fontSize: 14, color: Colors.black)),
                    onSelectionChanged: (d) {
                      setState(() {
                        if (d.value is PickerDateRange) {
                          tempdateRange =
                              '${DateFormat('dd/MM/yyyy').format(d.value.startDate)} -'
                              ' ${DateFormat('dd/MM/yyyy').format(d.value.endDate ?? d.value.startDate)}';
                          tempStartDate = d.value.startDate;
                          tempEndDate = d.value.endDate ?? d.value.startDate;
                        }
                      });
                    },
                    selectionMode: DateRangePickerSelectionMode.range,
                    initialSelectedRange: PickerDateRange(
                        startDate ??
                            DateTime.now().subtract(const Duration(days: 4)),
                        endDate ?? DateTime.now()),
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     InkWell(
                  //       splashColor: Colors.transparent,
                  //       hoverColor: Colors.transparent,
                  //       highlightColor: Colors.transparent,
                  //       onTap: () async {
                  //         Get.back();
                  //       },
                  //       child: Container(
                  //         padding:
                  //             EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  //         decoration: BoxDecoration(
                  //             border: Border.all(color: Colors.transparent),
                  //             color: ColorTheme.appColor,
                  //             // border:
                  //             //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                  //             borderRadius: BorderRadius.circular(
                  //                 Dimensions.RADIUS_DEFAULT)),
                  //         child: Center(
                  //           child: Text(
                  //             'Cancel',
                  //             style: poppinsMedium.copyWith(
                  //                 fontSize: Dimensions.FONT_SIZE_DEFAULT,
                  //                 color: Colors.white),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     SizedBox(width: 15),
                  //     InkWell(
                  //       splashColor: Colors.transparent,
                  //       hoverColor: Colors.transparent,
                  //       highlightColor: Colors.transparent,
                  //       onTap: () async {
                  //         startDate = tempStartDate ??
                  //             DateTime.now().subtract(const Duration(days: 4));
                  //         endDate = tempEndDate ?? DateTime.now();
                  //         selectedDateRange = tempdateRange ??
                  //             '${DateFormat('dd/MM/yyyy').format(DateTime.now().subtract(const Duration(days: 4)))} -'
                  //                 ' ${DateFormat('dd/MM/yyyy').format(DateTime.now())}';

                  //         filterOrderRecord(tabController);
                  //         Get.back();
                  //       },
                  //       child: Container(
                  //         padding:
                  //             EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  //         decoration: BoxDecoration(
                  //             border: Border.all(color: Colors.transparent),
                  //             color: ColorTheme.appColor,
                  //             borderRadius: BorderRadius.circular(
                  //                 Dimensions.RADIUS_DEFAULT)),
                  //         child: Center(
                  //           child: Text(
                  //             'Apply',
                  //             style: poppinsMedium.copyWith(
                  //                 fontSize: Dimensions.FONT_SIZE_DEFAULT,
                  //                 color: Colors.white),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  InkWell(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      startDate = tempStartDate ??
                          DateTime.now().subtract(const Duration(days: 4));
                      endDate = tempEndDate ?? DateTime.now();
                      selectedDateRange = tempdateRange ??
                          '${DateFormat('dd/MM/yyyy').format(DateTime.now().subtract(const Duration(days: 4)))} -'
                              ' ${DateFormat('dd/MM/yyyy').format(DateTime.now())}';

                      filterOrderRecord(tabController);
                      Get.back();
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        width: 60,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.transparent),
                            color: ColorTheme.appColor,
                            borderRadius: BorderRadius.circular(7)),
                        child: Center(
                          child: Text(
                            'Apply',
                            style: poppinsMedium.copyWith(
                                fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
    }),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        ignoreSafeArea: false);
  }

  filterOrderRecord(TabManagementController tabController) {
    orderList = [];
    if (selectedFilter == 'All') {
      orderList =
          tabController.getViewTabBillsResponseModel?.customerTransactionList ??
              [];
    } else {
      // Remove the always-false null check for startDate and endDate
      if (startDate == endDate) {
        final customerList =
            tabController.getViewTabBillsResponseModel?.customerTransactionList;
        if (customerList != null) {
          for (var e in customerList) {
            var orderDateStr = e.orderDate ?? '';
            var orderDate = orderDateStr.isNotEmpty
                ? DateFormat('dd/MM/yyyy').format(DateTime.parse(orderDateStr))
                : '';
            var selectDate =
                DateFormat('dd/MM/yyyy').format(startDate ?? DateTime.now());
            if (orderDate == selectDate) {
              orderList.add(e);
            }
          }
        }
      } else {
        final customerList =
            tabController.getViewTabBillsResponseModel?.customerTransactionList;
        if (customerList != null) {
          for (var e in customerList) {
            var orderDateStr = e.orderDate ?? '';
            if (orderDateStr.isNotEmpty) {
              var orderDate = DateTime.parse(orderDateStr);
              if (orderDate.isAfter(startDate!.subtract(Duration(days: 1))) &&
                  orderDate.isBefore(endDate!.add(Duration(days: 1)))) {
                orderList.add(e);
              }
            }
          }
        }
      }
    }
    tabController.update();
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
                    child: Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: orderList.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          isSelectPrinterList[index] =
                              !isSelectPrinterList[index];
                          setState(() {});
                        },
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width > 1600
                                          ? 70
                                          : 30,
                                  child: Checkbox(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    activeColor: ColorTheme.appColor,
                                    value: isSelectPrinterList[index],
                                    onChanged: (bool? isChecked) {
                                      isSelectPrinterList[index] =
                                          isChecked ?? false;
                                      setState(() {});
                                    },
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Order Id: ${orderList[index].restaurantOrderId == '0' ? orderList[index].orderId : orderList[index].restaurantOrderId}',
                                            style: poppinsMedium.copyWith(
                                                color: ColorTheme.appColor,
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1600
                                                    ? 17
                                                    : 15)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Date: ${DateFormat('dd-MMM').format(DateTime.parse(orderList[index].orderDate!))}',
                                            style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1600
                                                    ? 17
                                                    : 13)),
                                      ],
                                    ),
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
                                                : 13,
                                            color: Colors.blue)),
                                  ],
                                ),
                              ],
                            ),
                            Divider(),
                          ],
                        ),
                      );
                    }),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
              if (Get.find<AuthController>()
                  .profileModel!
                  .role!
                  .contains('printer'))
                GetBuilder<TabManagementController>(builder: (tabController) {
                  return InkWell(
                    onTap: () async {
                      currentPrintIndex = 0;
                      await dataCheck(setState);
                    },
                    child: SvgPicture.asset(
                      Images.ic_print_kot,
                      height: 26,
                    ),
                  );
                }),
            ]),
          ));
    });
  }

  dataCheck(setState) async {
    try {
      if (currentPrintIndex < orderList.length) {
        if (isSelectPrinterList[currentPrintIndex] == false) {
          for (var i = currentPrintIndex; i < orderList.length; i++) {
            if (isSelectPrinterList[currentPrintIndex] == false) {
              currentPrintIndex = currentPrintIndex + 1;
              await dataCheck(setState);
              break;
            } else {
              if (currentPrintIndex == 0) {
                await currentBillBytesConvert(setState);
              } else
                Future.delayed(Duration(seconds: 4), () async {
                  await currentBillBytesConvert(setState);
                });

              break;
            }
          }
        } else {
          if (currentPrintIndex == 0) {
            await currentBillBytesConvert(setState);
          } else
            Future.delayed(Duration(seconds: 4), () async {
              await currentBillBytesConvert(setState);
            });
        }
      } else {
        Future.delayed(Duration(seconds: 10), () async {
          if (Platform.isIOS) {
            await IosPrintTransport.disconnect;
          } else {
            await PrinterManager.instance.disconnect(
                type: Get.find<AuthController>().profileModel!.billWifiIp != ''
                    ? PrinterType.network
                    : PrinterType.bluetooth);
          }
          Get.find<TabManagementController>().setProcessing(false);
        });
        // Execute function After last bill printed
      }
    } catch (e) {}
  }

  Future currentBillBytesConvert(setState) async {
    // pendingTask = [];
    // List<int> bytes = [];
    await Get.find<KdsController>()
        .getPaidOrderDetail('${orderList[currentPrintIndex].orderId}');
    Orders order = Get.find<KdsController>().paidOrderDetailResponse!.orders!;
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
                printType: 'paid_bill',
                paymentType: order!.orderDetailsOrder?.paymentMethod ?? '',
                paperRoll: Get.find<AuthController>()
                            .profileModel!
                            .billPrinterPaperRoll ==
                        58
                    ? 58
                    : 80,
                orderId: order.orderDetailsOrder!.restaurantOrderId,
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
                custName: order?.orderDetailsOrder?.username ?? '',
                custPhone: '${order?.orderUser?.phone ?? ''}',
                paidFoodList: order?.orderDetailsFood ?? [],
                orderNote: order.orderDetailsOrder!.orderNote ?? '',
                orderSubTotal: order.orderTotalAmount! +
                    order.orderTotalAddonAmt! +
                    order.orderTotalVariantAmt!,
                discount:
                    order?.orderDetailsOrder?.restaurantDiscountAmount ?? 0,
                serviceChargeAmount: double.parse(
                    order?.orderDetailsOrder?.totalServiceTaxAmount ?? '0'),
                deliveryCharge: order.orderDetailsOrder?.deliveryCharge ?? 0,
                gstAmount: double.parse(
                    order?.orderDetailsOrder?.totalGstTaxAmount ?? '0'),
                vatAmount: double.parse(
                    order?.orderDetailsOrder?.totalVatTaxAmount ?? '0'),
                grandTotal: order.orderDetailsOrder?.orderAmount ?? 0,
                tips: order.orderDetailsOrder?.tipAmount ?? 0,
                orderType: order.orderDetailsOrder?.orderType),
          );
          break;
        }
      }
    } else {
      if (Platform.isIOS) {
        await _iosPrintEscPos(
          await PrintByteConvert().byteConvert(
            printType: 'paid_bill',
            paymentType: order?.orderDetailsOrder?.paymentMethod ?? '',
            paperRoll: (Get.find<AuthController>()
                            .profileModel
                            ?.billPrinterPaperRoll ??
                        80) ==
                    58
                ? 58
                : 80,
            orderId: order.orderDetailsOrder?.restaurantOrderId ?? '',
            date: DateFormat(Get.find<AuthController>()
                        .profileModel
                        ?.restaurants
                        ?.first
                        .billDateFormat ??
                    'dd/MM/yyyy')
                .format(DateTime.parse(order.orderDetailsOrder?.createdAt ??
                    DateTime.now().toString())),
            waiterName: order.restaurantDetails?.restaurantWaiterName ?? '',
            tablename: (order.restaurantDetails?.restaurantTableNo?.isEmpty ??
                    true)
                ? (order.orderDetailsOrder?.orderType == 'delivery'
                    ? 'Delivery'
                    : order.orderDetailsOrder?.orderType == 'take_away'
                        ? 'Take Away'
                        : 'WC')
                : (order.restaurantDetails?.restaurantTableArea?.isEmpty ??
                        true)
                    ? (order.restaurantDetails?.restaurantTableNo ?? '')
                    : '${order.restaurantDetails?.restaurantTableArea ?? ''}:${order.restaurantDetails?.restaurantTableNo ?? ''}',
            custName: order.orderDetailsOrder?.username ?? '',
            custPhone: order.orderUser?.phone ?? '',
            paidFoodList: order.orderDetailsFood ?? [],
            orderNote: order.orderDetailsOrder?.orderNote ?? '',
            orderSubTotal: (order.orderTotalAmount ?? 0) +
                (order.orderTotalAddonAmt ?? 0) +
                (order.orderTotalVariantAmt ?? 0),
            discount: order.orderDetailsOrder?.restaurantDiscountAmount ?? 0,
            serviceChargeAmount: double.tryParse(
                    order.orderDetailsOrder?.totalServiceTaxAmount ?? '0') ??
                0,
            deliveryCharge: order.orderDetailsOrder?.deliveryCharge ?? 0,
            gstAmount: double.tryParse(
                    order.orderDetailsOrder?.totalGstTaxAmount ?? '0') ??
                0,
            vatAmount: double.tryParse(
                    order.orderDetailsOrder?.totalVatTaxAmount ?? '0') ??
                0,
            grandTotal: order.orderDetailsOrder?.orderAmount ?? 0,
            tips: order.orderDetailsOrder?.tipAmount ?? 0,
            orderType: order.orderDetailsOrder?.orderType ?? '',
          ),
          setState,
        );
      } else {
        await _kdsPrintEscPos(
            await PrintByteConvert().byteConvert(
              printType: 'paid_bill',
              paymentType: order!.orderDetailsOrder?.paymentMethod ?? '',
              paperRoll: (Get.find<AuthController>()
                              .profileModel
                              ?.billPrinterPaperRoll ??
                          80) ==
                      58
                  ? 58
                  : 80,
              orderId: order.orderDetailsOrder?.restaurantOrderId ?? '',
              date: DateFormat(Get.find<AuthController>()
                          .profileModel
                          ?.restaurants
                          ?.first
                          .billDateFormat ??
                      'dd/MM/yyyy')
                  .format(DateTime.parse(order.orderDetailsOrder?.createdAt ??
                      DateTime.now().toString())),
              waiterName: order.restaurantDetails?.restaurantWaiterName ?? '',
              tablename: (order.restaurantDetails?.restaurantTableNo?.isEmpty ??
                      true)
                  ? (order.orderDetailsOrder?.orderType == 'delivery'
                      ? 'Delivery'
                      : order.orderDetailsOrder?.orderType == 'take_away'
                          ? 'Take Away'
                          : 'WC')
                  : (order.restaurantDetails?.restaurantTableArea?.isEmpty ??
                          true)
                      ? (order.restaurantDetails?.restaurantTableNo ?? '')
                      : '${order.restaurantDetails?.restaurantTableArea ?? ''}:${order.restaurantDetails?.restaurantTableNo ?? ''}',
              custName: order.orderDetailsOrder?.username ?? '',
              custPhone: order.orderUser?.phone ?? '',
              paidFoodList: order.orderDetailsFood ?? [],
              orderNote: order.orderDetailsOrder?.orderNote ?? '',
              orderSubTotal: (order.orderTotalAmount ?? 0) +
                  (order.orderTotalAddonAmt ?? 0) +
                  (order.orderTotalVariantAmt ?? 0),
              discount: order.orderDetailsOrder?.restaurantDiscountAmount ?? 0,
              serviceChargeAmount: double.tryParse(
                      order.orderDetailsOrder?.totalServiceTaxAmount ?? '0') ??
                  0,
              deliveryCharge: order.orderDetailsOrder?.deliveryCharge ?? 0,
              gstAmount: double.tryParse(
                      order.orderDetailsOrder?.totalGstTaxAmount ?? '0') ??
                  0,
              vatAmount: double.tryParse(
                      order.orderDetailsOrder?.totalVatTaxAmount ?? '0') ??
                  0,
              grandTotal: order.orderDetailsOrder?.orderAmount ?? 0,
              tips: order.orderDetailsOrder?.tipAmount ?? 0,
              orderType: order.orderDetailsOrder?.orderType ?? '',
            ),
            setState);
      }
    }
    // List<OrderDetailsFood> foodOrderList = [];

    // foodOrderList.addAll(Get.find<KdsController>()
    //     .paidOrderDetailResponse
    //     .orders
    //     .orderDetailsFood);

    // final profile = await CapabilityProfile.load(name: 'XP-N160I');
    // final generator = Generator(
    //     Get.find<AuthController>().profileModel.billPrinterPaperRoll == 58
    //         ? PaperSize.mm58
    //         : PaperSize.mm80,
    //     profile);
    // bytes += generator.setGlobalCodeTable('CP1252');

    // if (logoHelper.logoUrlPrint != null) {
    //   try {
    //     bytes += generator.feed(1);
    //     bytes += generator.image(logoHelper.logoUrlPrint);
    //   } catch (e) {
    //     print(e);
    //   }
    // }
    // bytes += generator.text(
    //     Get.find<AuthController>().profileModel.restaurants[0].name,
    //     styles: PrinterConfig().titleStyle());
    // bytes += generator.text(
    //     Get.find<AuthController>().profileModel.restaurants[0].address,
    //     styles: PrinterConfig().addressStyle());

    // if (Get.find<AuthController>().profileModel.restaurants[0].gstCode != '')
    //   bytes += generator.text(
    //       'GST no. ${Get.find<AuthController>().profileModel.restaurants[0].gstCode}',
    //       styles: PrinterConfig().gstStyle());
    // if (Get.find<AuthController>().profileModel.restaurants[0].fssai != '')
    //   bytes += generator.text(
    //       'FSI no. ${Get.find<AuthController>().profileModel.restaurants[0].fssai}',
    //       styles: PrinterConfig().gstStyle());
    // bool isShowDate = Get.find<AuthController>()
    //             .profileModel
    //             .restaurants
    //             .first
    //             .showFoodDate ==
    //         'Yes'
    //     ? true
    //     : false;
    // bytes += generator.row([
    //   PosColumn(
    //       text: 'order_id'.tr +
    //           ':' +
    //           ' ${Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.restaurantOrderId == '0' ? Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.id : Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.restaurantOrderId}',
    //       width: 6,
    //       styles: PrinterConfig().orderIdStyle()),
    //   PosColumn(
    //       text:
    //           '${DateFormat('${Get.find<AuthController>().profileModel.restaurants.first.billDateFormat}').format(DateTime.parse(Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.createdAt))}',
    //       // DateConverter.dateTimeStringToMonthAndTime(
    //       //     DateTime.now().toString()),
    //       width: 6,
    //       styles: PrinterConfig().orderCreateDateStyle()),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //       text: 'Dine In', width: 5, styles: PrinterConfig().dineInStyle()),
    //   PosColumn(
    //     text: '',
    //     width: 1,
    //     styles: PosStyles(align: PosAlign.center),
    //   ),
    //   PosColumn(
    //       text:
    //           '${Get.find<KdsController>().paidOrderDetailResponse.orders.restaurantDetails.restaurantWaiterName}',
    //       // text:
    //       //     '${Get.find<AuthController>().profileModel.empFname} ${Get.find<AuthController>().profileModel.empLname}',
    //       width: 6,
    //       styles: PrinterConfig().waiterNameStyle()),
    // ]);

    // bytes += generator.row([
    //   PosColumn(
    //     text: '${widget.name ?? ''}',
    //     width: 5,
    //     styles: PosStyles(
    //       height: Get.find<AuthController>().profileModel.printConfig == null ||
    //               Get.find<AuthController>()
    //                       .profileModel
    //                       .printConfig
    //                       .restaurantFoodList ==
    //                   null
    //           ? PosTextSize.size1
    //           : PrinterConfig().fonstSize(Get.find<AuthController>()
    //               .profileModel
    //               .printConfig
    //               .restaurantFoodList
    //               .split(',')
    //               .first),
    //       width: Get.find<AuthController>().profileModel.printConfig == null ||
    //               Get.find<AuthController>()
    //                       .profileModel
    //                       .printConfig
    //                       .restaurantFoodList ==
    //                   null
    //           ? PosTextSize.size1
    //           : PrinterConfig().fonstSize(Get.find<AuthController>()
    //               .profileModel
    //               .printConfig
    //               .restaurantFoodList
    //               .split(',')[1]),
    //       bold: Get.find<AuthController>().profileModel.printConfig == null ||
    //               Get.find<AuthController>()
    //                       .profileModel
    //                       .printConfig
    //                       .restaurantFoodList ==
    //                   null
    //           ? false
    //           : Get.find<AuthController>()
    //                       .profileModel
    //                       .printConfig
    //                       .restaurantFoodList
    //                       .split(',')
    //                       .last ==
    //                   'true'
    //               ? true
    //               : false,
    //       align: PosAlign.left,
    //       // fontType: PosFontType.fontB,
    //     ),
    //   ),
    //   PosColumn(
    //     text: '',
    //     width: 2,
    //     styles: PosStyles(align: PosAlign.center, underline: true),
    //   ),
    //   PosColumn(
    //     text: '${widget.phone ?? ''}',
    //     width: 5,
    //     styles: PosStyles(
    //       height: Get.find<AuthController>().profileModel.printConfig == null ||
    //               Get.find<AuthController>()
    //                       .profileModel
    //                       .printConfig
    //                       .restaurantFoodList ==
    //                   null
    //           ? PosTextSize.size1
    //           : PrinterConfig().fonstSize(Get.find<AuthController>()
    //               .profileModel
    //               .printConfig
    //               .restaurantFoodList
    //               .split(',')
    //               .first),
    //       width: Get.find<AuthController>().profileModel.printConfig == null ||
    //               Get.find<AuthController>()
    //                       .profileModel
    //                       .printConfig
    //                       .restaurantFoodList ==
    //                   null
    //           ? PosTextSize.size1
    //           : PrinterConfig().fonstSize(Get.find<AuthController>()
    //               .profileModel
    //               .printConfig
    //               .restaurantFoodList
    //               .split(',')[1]),
    //       bold: Get.find<AuthController>().profileModel.printConfig == null ||
    //               Get.find<AuthController>()
    //                       .profileModel
    //                       .printConfig
    //                       .restaurantFoodList ==
    //                   null
    //           ? false
    //           : Get.find<AuthController>()
    //                       .profileModel
    //                       .printConfig
    //                       .restaurantFoodList
    //                       .split(',')
    //                       .last ==
    //                   'true'
    //               ? true
    //               : false,
    //       align: PosAlign.right,
    //       fontType: PosFontType.fontB,
    //     ),
    //   ),
    // ]);

    // bytes += generator.hr(ch: '--');

    // bytes += generator.row([
    //   PosColumn(
    //       text: 'SL',
    //       width: isShowDate ? 1 : 2,
    //       styles: PrinterConfig().foodStyle()),
    //   PosColumn(
    //     text: 'item_info'.tr,
    //     width: isShowDate ? 4 : 5,
    //     styles: PrinterConfig().foodStyle(),
    //   ),
    //   PosColumn(
    //     text: 'qty'.tr,
    //     width: isShowDate ? 3 : 2,
    //     styles: PrinterConfig().foodStyle(),
    //   ),
    //   PosColumn(
    //     text: 'Price',
    //     width: isShowDate ? 2 : 3,
    //     styles: PrinterConfig().foodStyle(),
    //   ),
    //   if (isShowDate)
    //     PosColumn(
    //       text: 'Date',
    //       width: 2,
    //       styles: PosStyles(align: PosAlign.center),
    //     ),
    // ]);
    // bytes += generator.hr(ch: '--');
    // bytes += generator.hr(ch: '--');
    // for (var i = 0; i < foodOrderList.length; i++) {
    //   OrderDetailsFood food = foodOrderList[i];
    //   String variationText = '';
    //   String addons = '';

    //   int variationTotal = 0;
    //   double addonsTotal = 0;

    //   if (food.variation != null && food.variation.isNotEmpty) {
    //     variationText += '(';
    //     List<String> labelList = [];
    //     for (int j = 0; j < food.variation.length; j++) {
    //       // variationText +=
    //       //     '${variationText.isNotEmpty ? ', ' : ''}${food.variation[j].name} (';

    //       if (food.variation[j].values != null) {
    //         for (var element in food.variation[j].values) {
    //           labelList.add(element.label);
    //           variationTotal +=
    //               (int.parse(element.optionPrice) * food.quantity);
    //         }
    //         // variationText +=
    //         //     '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
    //       }

    //       // variationText += ')';
    //     }
    //     variationText += '${labelList.join(',')}';
    //     variationText += ')';
    //   }

    //   for (var i = 0; i < food.addOns.length; i++) {
    //     addons += '${food.addOns[i].name} (${food.addOns[i].quantity})';
    //     addonsTotal =
    //         addonsTotal + (food.addOns[i].price * food.addOns[i].quantity);
    //   }

    //   bytes += generator.row([
    //     PosColumn(
    //         text: '${i + 1}.',
    //         width: isShowDate ? 1 : 2,
    //         styles: PrinterConfig().foodStyle()),
    //     PosColumn(
    //       text: '${food.foodDetails.name} $variationText',
    //       width: 5,
    //       styles: PrinterConfig().foodStyle(),
    //     ),
    //     PosColumn(
    //       text: '${food.quantity}',
    //       width: isShowDate ? 1 : 2,
    //       styles: PrinterConfig().foodStyle(),
    //     ),
    //     PosColumn(
    //       text: '${(food.price + variationTotal).toStringAsFixed(2)}',
    //       width: 3,
    //       styles: PrinterConfig().foodStyle(),
    //     ),
    //     if (isShowDate)
    //       PosColumn(
    //         text:
    //             '${DateFormat('dd-MMM').format(DateTime.parse(food.createdAt))}',
    //         width: 2,
    //         styles: PrinterConfig().foodStyle(),
    //       ),
    //   ]);
    //   if (addons != '' && addonsTotal != 0) {
    //     bytes += generator.hr(ch: '....');
    //     bytes += generator.row([
    //       PosColumn(
    //         text: '',
    //         width: isShowDate ? 1 : 2,
    //         styles: PosStyles(
    //           align: PosAlign.center,
    //         ),
    //       ),
    //       PosColumn(
    //         text: 'Add-Ons :$addons',
    //         width: 5,
    //         styles: PrinterConfig().foodStyle(),
    //       ),
    //       PosColumn(
    //         text: '',
    //         width: isShowDate ? 1 : 2,
    //         styles: PosStyles(align: PosAlign.center),
    //       ),
    //       PosColumn(
    //         text: '${addonsTotal.toStringAsFixed(2)}',
    //         width: 3,
    //         styles: PrinterConfig().foodStyle(),
    //       ),
    //       if (isShowDate)
    //         PosColumn(
    //           text: '',
    //           width: 2,
    //           styles: PosStyles(align: PosAlign.center),
    //         ),
    //     ]);
    //   }
    //   // if (variationText != '' && variationTotal != 0) {
    //   //   bytes += generator.hr(ch: '....');
    //   //   bytes += generator.row([
    //   //     PosColumn(
    //   //       text: '',
    //   //       width: isShowDate ? 1 : 2,
    //   //       styles: PosStyles(
    //   //         align: PosAlign.center,
    //   //       ),
    //   //     ),
    //   //     PosColumn(
    //   //       text: 'Variants  :$variationText',
    //   //       width: 5,
    //   //       styles: PrinterConfig().foodStyle(),
    //   //     ),
    //   //     PosColumn(
    //   //       text: '',
    //   //       width: isShowDate ? 1 : 2,
    //   //       styles: PosStyles(align: PosAlign.center),
    //   //     ),
    //   //     PosColumn(
    //   //       text: '$variationTotal',
    //   //       width: 3,
    //   //       styles: PosStyles(align: PosAlign.center),
    //   //     ),
    //   //     if (isShowDate)
    //   //       PosColumn(
    //   //         text: '',
    //   //         width: 2,
    //   //         styles: PosStyles(align: PosAlign.center),
    //   //       ),
    //   //   ]);
    //   // }

    //   bytes += generator.hr(ch: '....');
    // }

    // bytes += generator.hr(ch: '....');

    // bytes += generator.row([
    //   PosColumn(
    //     text: '',
    //     width: 2,
    //     styles: PosStyles(
    //       align: PosAlign.center,
    //     ),
    //   ),
    //   PosColumn(
    //     text: 'Sub Total ',
    //     width: 5,
    //     styles: PrinterConfig().subtotalStyle(),
    //   ),
    //   PosColumn(
    //     text: '',
    //     width: 2,
    //     styles: PrinterConfig().subtotalStyle(),
    //   ),
    //   PosColumn(
    //     text: PriceConverter.convertPrice(
    //         Get.find<KdsController>()
    //                 .paidOrderDetailResponse
    //                 .orders
    //                 .orderTotalAmount +
    //             Get.find<KdsController>()
    //                 .paidOrderDetailResponse
    //                 .orders
    //                 .orderTotalAddonAmt +
    //             Get.find<KdsController>()
    //                 .paidOrderDetailResponse
    //                 .orders
    //                 .orderTotalVariantAmt,
    //         isHideCurrency: true,
    //         asFixed: 2),
    //     width: 3,
    //     styles: PrinterConfig().subtotalStyle(),
    //   ),
    // ]);
    // if (Get.find<KdsController>()
    //         .paidOrderDetailResponse
    //         .orders
    //         .orderDetailsOrder
    //         .restaurantDiscountAmount !=
    //     0)
    //   bytes += generator.row([
    //     PosColumn(
    //       text: '',
    //       width: 2,
    //       styles: PosStyles(
    //         align: PosAlign.center,
    //       ),
    //     ),
    //     PosColumn(
    //       text: 'Add Discount ',
    //       width: 5,
    //       styles: PrinterConfig().subtotalStyle(),
    //     ),
    //     PosColumn(
    //       text: '',
    //       width: 2,
    //       styles: PosStyles(align: PosAlign.center),
    //     ),
    //     PosColumn(
    //       text: PriceConverter.convertPrice(
    //           Get.find<KdsController>()
    //               .paidOrderDetailResponse
    //               .orders
    //               .orderDetailsOrder
    //               .restaurantDiscountAmount,
    //           isHideCurrency: true,
    //           asFixed: 2),
    //       width: 3,
    //       styles: PrinterConfig().subtotalStyle(),
    //     ),
    //   ]);
    // // if (tipsController.text.isNotEmpty && tipsController.text != '0')
    // //   bytes += generator.row([
    // //     PosColumn(
    // //       text: '',
    // //       width: 2,
    // //       styles: PosStyles(
    // //         align: PosAlign.center,
    // //       ),
    // //     ),
    // //     PosColumn(
    // //       text: 'Add Tips ',
    // //       width: 5,
    // //       styles: PosStyles(align: PosAlign.center),
    // //     ),
    // //     PosColumn(
    // //       text: '',
    // //       width: 2,
    // //       styles: PosStyles(align: PosAlign.center),
    // //     ),
    // //     PosColumn(
    // //       text: PriceConverter.convertPrice(double.parse(tipsController.text),
    // //           isHideCurrency: true, asFixed: 2),
    // //       width: 3,
    // //       styles: PosStyles(align: PosAlign.center),
    // //     ),
    // //   ]);
    // if (Get.find<KdsController>()
    //         .paidOrderDetailResponse
    //         .orders
    //         .orderDetailsOrder
    //         .tipAmount !=
    //     0)
    //   bytes += generator.row([
    //     PosColumn(
    //       text: '',
    //       width: 2,
    //       styles: PosStyles(
    //         align: PosAlign.center,
    //       ),
    //     ),
    //     PosColumn(
    //       text: 'Add tips',
    //       width: 5,
    //       styles: PrinterConfig().subtotalStyle(),
    //     ),
    //     PosColumn(
    //       text: '',
    //       width: 2,
    //       styles: PosStyles(align: PosAlign.center),
    //     ),
    //     PosColumn(
    //       text: PriceConverter.convertPrice(
    //           double.parse(Get.find<KdsController>()
    //               .paidOrderDetailResponse
    //               .orders
    //               .orderDetailsOrder
    //               .tipAmount
    //               .toString()),
    //           isHideCurrency: true,
    //           asFixed: 2),
    //       width: 3,
    //       styles: PrinterConfig().subtotalStyle(),
    //     ),
    //   ]);

    // if (double.parse(Get.find<KdsController>()
    //         .paidOrderDetailResponse
    //         .orders
    //         .orderDetailsOrder
    //         .totalServiceTaxAmount) !=
    //     0)
    //   bytes += generator.row([
    //     PosColumn(
    //       text: '',
    //       width: 2,
    //       styles: PosStyles(
    //         align: PosAlign.center,
    //       ),
    //     ),
    //     PosColumn(
    //       text: 'Service Charge',
    //       width: 5,
    //       styles: PrinterConfig().subtotalStyle(),
    //     ),
    //     PosColumn(
    //       text: '',
    //       width: 2,
    //       styles: PosStyles(align: PosAlign.center),
    //     ),
    //     PosColumn(
    //       text: PriceConverter.convertPrice(
    //           double.parse(Get.find<KdsController>()
    //               .paidOrderDetailResponse
    //               .orders
    //               .orderDetailsOrder
    //               .totalServiceTaxAmount),
    //           isHideCurrency: true,
    //           asFixed: 2),
    //       width: 3,
    //       styles: PrinterConfig().subtotalStyle(),
    //     ),
    //   ]);
    // if (Get.find<KdsController>()
    //         .paidOrderDetailResponse
    //         .orders
    //         .orderDetailsOrder
    //         .deliveryCharge !=
    //     0)
    //   bytes += generator.row([
    //     PosColumn(
    //       text: '',
    //       width: 2,
    //       styles: PosStyles(
    //         align: PosAlign.center,
    //       ),
    //     ),
    //     PosColumn(
    //       text: 'Delivery Charge',
    //       width: 5,
    //       styles: PrinterConfig().subtotalStyle(),
    //     ),
    //     PosColumn(
    //       text: '',
    //       width: 2,
    //       styles: PosStyles(align: PosAlign.center),
    //     ),
    //     PosColumn(
    //       text: PriceConverter.convertPrice(
    //           Get.find<KdsController>()
    //               .paidOrderDetailResponse
    //               .orders
    //               .orderDetailsOrder
    //               .deliveryCharge,
    //           isHideCurrency: true,
    //           asFixed: 2),
    //       width: 3,
    //       styles: PrinterConfig().subtotalStyle(),
    //     ),
    //   ]);
    // if (double.parse(Get.find<KdsController>()
    //         .paidOrderDetailResponse
    //         .orders
    //         .orderDetailsOrder
    //         .totalGstTaxAmount) !=
    //     0) {
    //   bytes += generator.row([
    //     PosColumn(
    //       text: '',
    //       width: 2,
    //       styles: PosStyles(
    //         align: PosAlign.center,
    //       ),
    //     ),
    //     PosColumn(
    //       text: 'CGST ',
    //       width: 5,
    //       styles: PrinterConfig().subtotalStyle(),
    //     ),
    //     PosColumn(
    //       text: '',
    //       width: 2,
    //       styles: PosStyles(align: PosAlign.center),
    //     ),
    //     PosColumn(
    //       text: PriceConverter.convertPrice(
    //           double.parse(Get.find<KdsController>()
    //                   .paidOrderDetailResponse
    //                   .orders
    //                   .orderDetailsOrder
    //                   .totalGstTaxAmount) /
    //               2,
    //           isHideCurrency: true,
    //           asFixed: 2),
    //       width: 3,
    //       styles: PrinterConfig().subtotalStyle(),
    //     ),
    //   ]);
    // }
    // if (double.parse(Get.find<KdsController>()
    //         .paidOrderDetailResponse
    //         .orders
    //         .orderDetailsOrder
    //         .totalGstTaxAmount) !=
    //     0) {
    //   bytes += generator.row([
    //     PosColumn(
    //       text: '',
    //       width: 2,
    //       styles: PosStyles(
    //         align: PosAlign.center,
    //       ),
    //     ),
    //     PosColumn(
    //       text: 'SGST ',
    //       width: 5,
    //       styles: PrinterConfig().subtotalStyle(),
    //     ),
    //     PosColumn(
    //       text: '',
    //       width: 2,
    //       styles: PosStyles(align: PosAlign.center),
    //     ),
    //     PosColumn(
    //       text: PriceConverter.convertPrice(
    //           double.parse(Get.find<KdsController>()
    //                   .paidOrderDetailResponse
    //                   .orders
    //                   .orderDetailsOrder
    //                   .totalGstTaxAmount) /
    //               2,
    //           isHideCurrency: true,
    //           asFixed: 2),
    //       width: 3,
    //       styles: PrinterConfig().subtotalStyle(),
    //     ),
    //   ]);
    // }
    // if (double.parse(Get.find<KdsController>()
    //         .paidOrderDetailResponse
    //         .orders
    //         .orderDetailsOrder
    //         .totalVatTaxAmount) !=
    //     0) {
    //   bytes += generator.row([
    //     PosColumn(
    //       text: '',
    //       width: 2,
    //       styles: PosStyles(
    //         align: PosAlign.center,
    //       ),
    //     ),
    //     PosColumn(
    //       text: 'VAT ',
    //       width: 5,
    //       styles: PrinterConfig().subtotalStyle(),
    //     ),
    //     PosColumn(
    //       text: '',
    //       width: 2,
    //       styles: PosStyles(align: PosAlign.center),
    //     ),
    //     PosColumn(
    //       text: PriceConverter.convertPrice(
    //           double.parse(Get.find<KdsController>()
    //               .paidOrderDetailResponse
    //               .orders
    //               .orderDetailsOrder
    //               .totalVatTaxAmount),
    //           isHideCurrency: true,
    //           asFixed: 2),
    //       width: 3,
    //       styles: PrinterConfig().subtotalStyle(),
    //     ),
    //   ]);
    // }

    // bytes += generator.hr(ch: '....');
    // bytes += generator.text(
    //   'Total: ' +
    //       PriceConverter.convertPrice(
    //           Get.find<KdsController>()
    //               .paidOrderDetailResponse
    //               .orders
    //               .orderDetailsOrder
    //               .orderAmount,
    //           isHideCurrency: true,
    //           asFixed: 2) +
    //       ' ${Get.find<AuthController>().profileModel?.restaurants?.first?.currency ?? ''}',
    //   styles: PrinterConfig().totalStyle(),
    // );
    // bytes += generator.hr(ch: '....');

    // // if (Get.find<AuthController>().profileModel.restaurants.first.feedback ==
    // //     'Yes') {
    // //   try {
    // //     const double qrSize = 170;
    // //     final uiImg = await QrPainter(
    // //       data:
    // //           '${AppConstants.FEEDBACK_BASE_URL}?orderId=${Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.id}',
    // //       version: QrVersions.auto,
    // //       gapless: false,
    // //     ).toImageData(qrSize);
    // //     final dir = await getTemporaryDirectory();
    // //     final pathName = '${dir.path}/qr_tmp.png';
    // //     final qrFile = File(pathName);
    // //     final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
    // //     final img = prefix.decodeImage(imgFile.readAsBytesSync());
    // //     bytes += generator.text('Scan to provide feedback',
    // //         styles: const PosStyles(
    // //             align: PosAlign.center,
    // //             height: PosTextSize.size1,
    // //             width: PosTextSize.size1,
    // //             bold: true,
    // //             fontType: PosFontType.fontA));

    // //     bytes += generator.feed(1);
    // //     bytes += generator.image(img);
    // //     bytes += generator.feed(1);
    // //   } catch (e) {
    // //     print(e);
    // //   }
    // // }

    // // if (Get.find<AuthController>().profileModel.restaurants.first.feedback ==
    // //     'Yes') {
    // //   try {
    // //     const double qrSize = 170;
    // //     final uiImg = await QrPainter(
    // //       data:
    // //           '${AppConstants.FEEDBACK_BASE_URL}?orderId=${Get.find<KdsController>().paidOrderDetailResponse.orders.orderDetailsOrder.id}',
    // //       version: QrVersions.auto,
    // //       gapless: false,
    // //     ).toImageData(qrSize);
    // //     final dir = await getTemporaryDirectory();
    // //     final pathName = '${dir.path}/qr_tmp.png';
    // //     final qrFile = File(pathName);
    // //     final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
    // //     final img = prefix.decodeImage(imgFile.readAsBytesSync());
    // //     bytes += generator.text('Scan to provide feedback',
    // //         styles: const PosStyles(
    // //             align: PosAlign.center,
    // //             height: PosTextSize.size1,
    // //             width: PosTextSize.size1,
    // //             bold: true,
    // //             fontType: PosFontType.fontA));

    // //     bytes += generator.feed(1);
    // //     bytes += generator.image(img);
    // //     bytes += generator.feed(1);
    // //   } catch (e) {
    // //     print(e);
    // //   }
    // // }
    // if (Get.find<AuthController>()
    //         .profileModel
    //         .restaurants
    //         .first
    //         .footerTextBill !=
    //     '') {
    //   bytes += generator.text(
    //       Get.find<AuthController>()
    //           .profileModel
    //           .restaurants
    //           .first
    //           .footerTextBill,
    //       styles: const PosStyles(
    //           align: PosAlign.center,
    //           height: PosTextSize.size1,
    //           width: PosTextSize.size1,
    //           // bold: true,
    //           fontType: PosFontType.fontB));
    // }
    // bytes += generator.text('Powered by MyGenie',
    //     styles: const PosStyles(
    //         align: PosAlign.center,
    //         height: PosTextSize.size1,
    //         width: PosTextSize.size1,
    //         // bold: true,
    //         fontType: PosFontType.fontB));
    // bytes += generator.cut();

    // if (Platform.isAndroid) {
    //   await _kdsPrintEscPos(bytes, generator, setState); //kitchen
    // } else {
    //   await _iosPrintEscPos(bytes, generator, setState); //kitchen
    // }
  }

  /// print ticket
  Future _kdsPrintEscPos(List<int> bytes, setState) async {
    // await printerManager.disconnect(type: PrinterType.bluetooth);
    BluetoothPrinter bluetoothPrinter;
    final profileModel = Get.find<AuthController>().profileModel;
    if (profileModel?.billPrinterType == 'usb') {
      bluetoothPrinter = await BluetoothPrinter(
          productId: profileModel?.billProductId,
          vendorId: profileModel?.billVendorId,
          typePrinter: PrinterType.usb);
    } else {
      bluetoothPrinter = await BluetoothPrinter(
          port: '9100',
          typePrinter: Get.find<AuthController>().profileModel!.billWifiIp != ''
              ? PrinterType.network
              : PrinterType.bluetooth,
          address: Get.find<AuthController>().profileModel!.billWifiIp != ''
              ? profileModel?.billWifiIp
              : profileModel?.billPrinterIp,
          deviceName: profileModel?.billPrinterName); // ip was mandadory
    }

    // if (profileModel?.billPrinterType == 'usb') {
    //   await printerManager.connect(
    //     type: PrinterType.usb,
    //     model: UsbPrinterInput(
    //       productId: profileModel?.billProductId,
    //       vendorId: profileModel?.billVendorId,
    //     ),
    //   );
    // } else {
    //   await printerManager.connect(
    //     type: bluetoothPrinter.typePrinter,
    //     model: BluetoothPrinterInput(
    //       name: bluetoothPrinter.deviceName,
    //       address: bluetoothPrinter.address ?? '',
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
    try {
      await printerManager.send(
          type: bluetoothPrinter.typePrinter, bytes: bytes);
      isPrintedList[currentPrintIndex] = true; //It show status of start print
      isPrinterProccessingList[currentPrintIndex] = false;
      currentPrintIndex = currentPrintIndex + 1;
      setState(() {});
      if (setState != null) dataCheck(setState);
    } catch (e) {}
    // } else {}
  }

  Future _iosPrintEscPos(List<int> bytes, setState) async {
    print('########## bytes length ${bytes.length}');
    // bytes += generator.feed(2);
    try {
      if (Get.find<AuthController>().profileModel!.macBillPrinterIp == '' &&
          NetworkPrinterResolver.billPrinter() == null) {
        showErrorToast('Failed to bluetooth connect');
        Get.find<TabManagementController>().setProcessing(false);

        //no conectado, reconecte
      } else {
        // await PrintBluetoothThermal.pairedBluetooths;

        // Future.delayed(Duration(seconds: 5), () async {
        final bool result = await IosPrintTransport.connect(wifiPrinter: NetworkPrinterResolver.billPrinter(), 
            macPrinterAddress:
                Get.find<AuthController>().profileModel!.macBillPrinterIp!);

        Future.delayed(Duration(seconds: 4), () async {
          if (result) {
            // List<int> ticket = await testTicket();
            await IosPrintTransport.writeBytes(bytes);

            isPrintedList[currentPrintIndex] =
                true; //It show status of start print
            isPrinterProccessingList[currentPrintIndex] = false;
            currentPrintIndex = currentPrintIndex + 1;
            setState(() {});
            dataCheck(setState);
          } else {
            Get.find<TabManagementController>().setProcessing(false);

            //no conectado, reconecte
            showErrorToast('Failed to bluetooth connect');
          }
        });
      }
    } catch (e) {
      Get.find<TabManagementController>().setProcessing(false);
      showErrorToast('Failed to bluetooth connect');
    }

    // });
  }
}
