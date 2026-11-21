import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/custome management/controller/customer_management_controller.dart';

/// Customer Report Screen
/// Displays customer list with their details including:
/// - Name and Phone
/// - Total Amount Spent
/// - Lifetime Loyalty Points
/// - Current Loyalty Points
class CustomerReportScreen extends StatefulWidget {
  const CustomerReportScreen({Key? key}) : super(key: key);

  @override
  State<CustomerReportScreen> createState() => _CustomerReportScreenState();
}

class _CustomerReportScreenState extends State<CustomerReportScreen> {
  CustomerManagementController? customerController;

  @override
  void initState() {
    super.initState();
    // Get the controller instance (will be created by Get.lazyPut if not exists)
    customerController = Get.find<CustomerManagementController>();
    customerController?.getRestaurantCustomerList();
  }

  /// Refresh customer list
  void _refreshCustomerList() {
    customerController?.getRestaurantCustomerList();
  }

  /// Export customer list to Excel
  Future<void> _exportCustomerListToExcel() async {
    await customerController?.exportCustomerListExcel();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        backgroundColor: ColorTheme.grey200Color,
        appBar: CustomAppBar(
          titleWidget: Text(
            'Customer Data',
            style: montserratMedium.copyWith(
                color: ColorTheme.blackColor, fontSize: 16),
          ),
          titleText: 'Customer Data',
          actions: [
            // Download/Export Icon Button
            IconButton(
              tooltip: 'Export to Excel',
              onPressed: _exportCustomerListToExcel,
              icon: Icon(
                Icons.file_download_outlined,
                color: ColorTheme.greyBE,
                size: 30,
              ),
            ),
            // Refresh Icon Button
            IconButton(
              tooltip: 'Refresh',
              onPressed: _refreshCustomerList,
              icon: Icon(
                Icons.refresh,
                color: ColorTheme.greyBE,
                size: 25,
              ),
            ),
          ],
        ),
        body: GetBuilder<CustomerManagementController>(
          builder: (controller) => Column(
            children: [
              SizedBox(height: 10),
              // Search Bar
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

  /// Build search bar widget
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: TextField(
        controller: customerController?.searchCustomerController,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: "Search by name or phone ...",
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
          customerController?.update();
        },
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
          // Name Column
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.only(left: 15),
              alignment: Alignment.centerLeft,
              child: Text(
                'Name',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Total Amount Spent Column
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
                'Total Amount Spent',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Lifetime Loyalty Points Column
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
                // 'Lifetime Loyalty Points',
                'Wallet Balance', //'Virtual Wallet'
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: ColorTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Current Loyalty Column
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(right: 15),
              alignment: Alignment.center,
              child: Text(
                'Loyalty Balance', //'Current Loyalty Points'
                textAlign: TextAlign.center,
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
    if (customerController?.isLoading ?? false) {
      return AppLoader();
    }

    final filteredList = customerController?.getFilteredCustomerList() ?? [];

    if (filteredList.isEmpty) {
      return Center(
        child: Text(
          'No customers found',
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
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final customer = filteredList[index];
          return _buildTableRow(customer);
        },
      ),
    );
  }

  /// Build individual table row
  Widget _buildTableRow(Map<String, dynamic> customer) {
    // Get customer data with null safety
    final customerName = customer['customer_name']?.toString() ?? 'N/A';
    final phone = customer['phone']?.toString() ?? 'N/A';
    final totalOrderAmount =
        customer['total_order_amount']?.toString() ?? '0.00';
    final lifetimeEarned = customer['lifetime_earned']?.toString() ?? '0';
    final loyaltyPoint = customer['loyalty_point']?.toString() ?? '0';
    final virtualWallet = customer['wallet_balance']?.toString() ?? '0';

    // Format currency
    final formattedAmount = _formatCurrency(totalOrderAmount);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: ColorTheme.whiteE7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Column - customer_name and phone
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      color: ColorTheme.foodValue,
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  ),
                  4.height,
                  Text(
                    phone,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      color: ColorTheme.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Total Amount Spent Column
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
                formattedAmount,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: ColorTheme.foodValue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Virtual Wallet Column
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
                virtualWallet,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: ColorTheme.foodValue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Current Loyalty Column
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(right: 15),
              alignment: Alignment.center,
              child: Text(
                loyaltyPoint,
                textAlign: TextAlign.center,
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
    );
  }

  /// Format currency string
  String _formatCurrency(String amount) {
    try {
      final doubleValue = double.parse(amount);
      return doubleValue.toStringAsFixed(2);
    } catch (e) {
      return amount;
    }
  }
}
