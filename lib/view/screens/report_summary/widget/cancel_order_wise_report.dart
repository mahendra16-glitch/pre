import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/settlement/date_picker/date_picker.dart';
import 'package:mygenie_restaurant/controller/report_summary_controller.dart';

class CancelOrderWiseReportScreen extends StatefulWidget {
  const CancelOrderWiseReportScreen({Key? key}) : super(key: key);

  @override
  State<CancelOrderWiseReportScreen> createState() =>
      _CancelOrderWiseReportScreenState();
}

class _CancelOrderWiseReportScreenState
    extends State<CancelOrderWiseReportScreen> {
  ReportSummeryController? reportController;

  @override
  void initState() {
    super.initState();
    reportController = Get.find<ReportSummeryController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDatesAndData();
      _fetchOrderCancelReport();
    });
  }

  /// Initialize default date range (current date)
  void _initializeDatesAndData() {
    reportController?.orderCancelReportList.clear();
    reportController?.filteredOrderCancelReportList.clear();
    reportController?.orderCancelSearchController.clear();
    reportController?.update();
    final now = DateTime.now();
    reportController?.orderCancelStartDate =
        DateFormat('dd-MM-yyyy').format(now);
    reportController?.orderCancelEndDate = DateFormat('dd-MM-yyyy').format(now);
  }

  /// Fetch order cancel report data
  void _fetchOrderCancelReport() async {
    if (reportController?.orderCancelStartDate != null &&
        reportController?.orderCancelEndDate != null) {
      await reportController?.getOrderCancelReport(
        startDate: reportController!.orderCancelStartDate!,
        endDate: reportController!.orderCancelEndDate!,
      );
    }
  }

  /// Download order cancel report
  Future<void> _downloadOrderCancelReport() async {
    if (reportController?.orderCancelStartDate != null &&
        reportController?.orderCancelEndDate != null) {
      await reportController?.downloadOrderCancelReport(
        startDate: reportController!.orderCancelStartDate!,
        endDate: reportController!.orderCancelEndDate!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        backgroundColor: ColorTheme.grey200Color,
        appBar: CustomAppBar(
          titleWidget: Text(
            'Order Cancel Report',
            style: montserratMedium.copyWith(
                color: ColorTheme.blackColor, fontSize: 16),
          ),
          titleText: 'Order Cancel Report',
          actions: [
           Obx(() => IconButton(
              tooltip: 'Download Excel',
              onPressed: reportController?.isLoadingOrderCancelReport.value ?? false ? null : _downloadOrderCancelReport,
              mouseCursor: reportController?.isLoadingOrderCancelReport.value ?? false ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
              icon: Icon(
                Icons.file_download_outlined,
                color: ColorTheme.greyBE,
                size: 30,
              ),
            )),
            IconButton(
              tooltip: 'Refresh',
              onPressed: _fetchOrderCancelReport,
              icon: Icon(
                Icons.refresh,
                color: ColorTheme.greyBE,
                size: 25,
              ),
            ),
          ],
        ),
        body: GetBuilder<ReportSummeryController>(
          builder: (controller) => Column(
            children: [
              SizedBox(height: 10),
              // Date Filter Section
              _buildDateFilterSection(),

              _buildSearchBar(),

              // Table Headers
              _buildTableHeaders(),

              // Table Data
              Expanded(
                child: _buildTableData(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build date filter section with start and end date pickers
  Widget _buildDateFilterSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      child: Row(
        children: [
          // Start Date
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await pickedDate(
                  reportController?.orderCancelStartDate,
                );
                if (picked != null) {
                  reportController?.orderCancelStartDate =
                      DateFormat('dd-MM-yyyy').format(picked);
                  reportController?.update();
                  _fetchOrderCancelReport();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorTheme.grey8C.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reportController?.orderCancelStartDate ?? 'DD-MM-YYYY',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: ColorTheme.black5F6368,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: ColorTheme.black5F6368,
                    ),
                  ],
                ),
              ),
            ),
          ),
          10.width,
          Text(
            'to',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              color: ColorTheme.black5F6368,
              fontWeight: FontWeight.w400,
            ),
          ),
          10.width,
          // End Date
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await pickedDate(
                  reportController?.orderCancelEndDate,
                );
                if (picked != null) {
                  reportController?.orderCancelEndDate =
                      DateFormat('dd-MM-yyyy').format(picked);
                  reportController?.update();
                  _fetchOrderCancelReport();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorTheme.grey8C.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reportController?.orderCancelEndDate ?? 'DD-MM-YYYY',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: ColorTheme.black5F6368,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: ColorTheme.black5F6368,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build table headers
  Widget _buildTableHeaders() {
    return Container(
      height: 45,
      color: ColorTheme.whiteColor,
      child: Row(
        children: [
          // Order ID Column
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(left: 15),
              alignment: Alignment.centerLeft,
              child: Text(
                'Order ID',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Cancelled Time Column
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: ColorTheme.whiteE7),
                ),
              ),
              child: Text(
                'Cancelled Time',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Cancelled By Column
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: ColorTheme.whiteE7),
                ),
              ),
              child: Text(
                'Cancelled By',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Amount Column
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(right: 15),
              alignment: Alignment.center,
              child: Text(
                'Amount',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build table data rows
  Widget _buildTableData() {
    if (reportController?.isLoadingOrderCancelReport.value ?? false) {
      return AppLoader();
    }

    final orderCancelRecords =
        reportController?.filteredOrderCancelReportList ?? [];

    if (orderCancelRecords.isEmpty) {
      return Center(
        child: Text(
          'No order cancel records found',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: ColorTheme.black5F6368.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      color: ColorTheme.whiteColor,
      child: ListView.builder(
        itemCount: orderCancelRecords.length,
        itemBuilder: (context, index) {
          final record = orderCancelRecords[index];
          return _buildTableRow(record);
        },
      ),
    );
  }

  /// Build individual table row
  Widget _buildTableRow(Map<String, dynamic> record) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: ColorTheme.whiteE7),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order ID Column - order_id, order_date, order_time
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.only(left: 15, top: 12, bottom: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${record['order_id']?.toString() ?? ''}',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: ColorTheme.foodValue,
                        fontWeight: FontWeight.w600,
                      ),
                      softWrap: true,
                    ),
                    4.height,
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: ColorTheme.black5F6368,
                        ),
                        4.width,
                        Text(
                          record['order_time']?.toString() ?? '',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            color: ColorTheme.black5F6368,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    2.height,
                    Row(
                      children: [
                        Icon(
                          Icons.event,
                          size: 12,
                          color: ColorTheme.black5F6368,
                        ),
                        4.width,
                        Text(
                          record['order_date']?.toString() ?? '',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            color: ColorTheme.black5F6368,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Cancelled Time Column - cancel_time, cancel_date
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    vertical: BorderSide(color: ColorTheme.whiteE7),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 13,
                            color: ColorTheme.foodValue,
                          ),
                          4.width,
                          Text(
                            record['cancel_time']?.toString() ?? '',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13,
                              color: ColorTheme.foodValue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ]),
                    4.height,
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event,
                            size: 12,
                            color: ColorTheme.black5F6368,
                          ),
                          4.width,
                          Text(
                            record['cancel_date']?.toString() ?? '',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11,
                              color: ColorTheme.black5F6368,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ]),
                  ],
                ),
              ),
            ),
            // Cancelled By Column - cancelled_by
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    vertical: BorderSide(color: ColorTheme.whiteE7),
                  ),
                ),
                child: Text(
                  record['cancelled_by']?.toString() ?? '',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    color: ColorTheme.black5F6368,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
            ),
            // Amount Column - order_value
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.only(right: 15, top: 12, bottom: 12),
                alignment: Alignment.center,
                child: Text(
                  '₹${record['order_value']?.toString() ?? '0'}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    color: ColorTheme.foodValue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: TextField(
        controller: reportController?.orderCancelSearchController,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: "Search by order ID or cancelled by ...",
          hintStyle:
              montserratMedium.copyWith(fontSize: 15, color: ColorTheme.grey8C),
          prefixIcon: Icon(
            Icons.search,
            color: ColorTheme.grey8C.withOpacity(0.3),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ColorTheme.grey8C.withOpacity(0.3)),
          ),
        ),
        style: montserratMedium.copyWith(fontSize: 15, color: ColorTheme.black),
        onChanged: (value) {
          reportController?.filterOrderCancelReport(value);
        },
      ),
    );
  }
}
