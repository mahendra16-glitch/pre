import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/admin/widget/upload_icon/upload_icon.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_bulk_import.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/table_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/view/table_management/add_edit_table_management_screen.dart';

class TableManagementScreen extends StatefulWidget {
  const TableManagementScreen({Key? key}) : super(key: key);

  @override
  State<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch all table data on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<TableManagementController>();
      controller.getTableList();
      controller.getAreaOptions();
      controller.getWaiterList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.manageBgColor,
      appBar: AppBar(
        backgroundColor: ColorTheme.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: ColorTheme.green),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Text(
          'Table Management',
          style: montserratSemiBold.copyWith(
            color: ColorTheme.black2E,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          // Refresh Button
          GetBuilder<TableManagementController>(
            builder: (controller) {
              return IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: ColorTheme.appColor,
                ),
                tooltip: 'Refresh',
                onPressed: controller.isLoading
                    ? null
                    : () {
                        controller.getTableList();
                        controller.getAreaOptions();
                        controller.getWaiterList();
                      },
              );
            },
          ),

          // Download QR Codes Button
          Obx(() {
            final controller = Get.find<TableManagementController>();
            return IconButton(
              icon: controller.isQRCodesLoader.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: SpinKitFadingGrid(
                        color: ColorTheme.appColor,
                        size: 20,
                      ),
                    )
                  : Icon(
                      Icons.file_download_outlined,
                      color: ColorTheme.appColor,
                    ),
              tooltip: 'Download QR Codes',
              onPressed: controller.isQRCodesLoader.value
                  ? null
                  : () {
                      controller.downloadTableQRCodes();
                    },
            );
          }),

          // Add Table Button
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: ColorTheme.appColor,
            ),
            tooltip: 'Add Table',
            onPressed: () {
              Get.find<TableManagementController>().clearForm();
              Get.to(() => AddEditTableManagementScreen(isEdit: false));
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      body: GetBuilder<TableManagementController>(
        init: Get.find<TableManagementController>(),
        builder: (controller) {
          if (controller.isLoading && controller.tableList.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: ColorTheme.appColor,
              ),
            );
          }

          return Column(
            children: [
              // Search Bar with Upload/Download Icons
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 23),
                child: Row(
                  children: [
                    // Search TextField
                    Expanded(
                      child: TextField(
                        controller: controller.searchCtrl,
                        onChanged: (value) => controller.searchTable(value),
                        style: montserratMedium.copyWith(
                          color: ColorTheme.black,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by title or table number...',
                          hintStyle: montserratRegular.copyWith(
                            color: ColorTheme.grey1,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: ColorTheme.grey1,
                          ),
                          suffixIcon: controller.searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: ColorTheme.grey1,
                                  ),
                                  onPressed: () {
                                    controller.searchCtrl.clear();
                                    controller.searchTable('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: ColorTheme.whiteColor,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: ColorTheme.borderGrey2,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: ColorTheme.borderGrey2,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: ColorTheme.borderGrey2,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12),

                    // Bulk Import/Export Icon Buttons
                    uploadIconWidget(
                      onDownLoadTap: () async {
                        // Navigate to Bulk Import Screen for download operations
                        Get.to(() => BulkImportScreen(
                              tittleName: 'Table Management',
                              isFunction: true,
                              onuploadTap: () {
                                // Import table configuration from Excel
                                Get.find<TableManagementController>()
                                    .bulkTableImport();
                              },
                              onDownloadExistingDataTap: () {
                                // Export existing table data
                                Get.find<TableManagementController>()
                                    .exportExistingData();
                              },
                              onDownloadSampleDataTap: () {
                                // Download sample template
                                Get.find<TableManagementController>()
                                    .exportSampleTemplate();
                              },
                              controller: Get.find<TableManagementController>(),
                            ));
                      },
                      onUploadTap: () async {
                        // Navigate to Bulk Import Screen for upload operations
                        Get.to(() => BulkImportScreen(
                              tittleName: 'Table Management',
                              isFunction: true,
                              onuploadTap: () {
                                // Import table configuration from Excel
                                Get.find<TableManagementController>()
                                    .bulkTableImport();
                              },
                              onDownloadExistingDataTap: () {
                                // Export existing table data
                                Get.find<TableManagementController>()
                                    .exportExistingData();
                              },
                              onDownloadSampleDataTap: () {
                                // Download sample template
                                Get.find<TableManagementController>()
                                    .exportSampleTemplate();
                              },
                              controller: Get.find<TableManagementController>(),
                            ));
                      },
                      isPLusShow: false,
                      onPlusTap: () {},
                    ),
                  ],
                ),
              ),

              // Table Header
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: ColorTheme.whiteColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  border: Border.all(color: ColorTheme.borderGrey2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(11),
                      topRight: Radius.circular(11),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.only(right: 12, left: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: ColorTheme.borderGrey2,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            'Title',
                            style: montserratBold.copyWith(
                              color: ColorTheme.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: ColorTheme.borderGrey2,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Table No',
                              style: montserratBold.copyWith(
                                color: ColorTheme.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: ColorTheme.borderGrey2,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Type',
                              style: montserratBold.copyWith(
                                color: ColorTheme.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            'Actions',
                            style: montserratBold.copyWith(
                              color: ColorTheme.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Table Body
              controller.filteredTableList.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.table_restaurant,
                              size: 80,
                              color: ColorTheme.grey1.withOpacity(0.3),
                            ),
                            SizedBox(height: 16),
                            Text(
                              controller.searchCtrl.text.isNotEmpty
                                  ? 'No tables found'
                                  : 'No tables configured',
                              style: montserratMedium.copyWith(
                                color: ColorTheme.grey1,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              controller.searchCtrl.text.isNotEmpty
                                  ? 'Try a different search term'
                                  : 'Add a table to get started',
                              style: montserratRegular.copyWith(
                                color: ColorTheme.grey1.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : controller.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                          color: ColorTheme.appColor,
                        ))
                      : Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                                left: 10, right: 10, bottom: 20),
                            decoration: BoxDecoration(
                              color: ColorTheme.whiteColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              border: Border(
                                left: BorderSide(color: ColorTheme.borderGrey2),
                                right:
                                    BorderSide(color: ColorTheme.borderGrey2),
                                bottom:
                                    BorderSide(color: ColorTheme.borderGrey2),
                              ),
                            ),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: controller.filteredTableList.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                thickness: 1,
                                color: ColorTheme.borderGrey2,
                              ),
                              itemBuilder: (context, index) {
                                final table =
                                    controller.filteredTableList[index];
                                final isLast = index ==
                                    controller.filteredTableList.length - 1;

                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: index.isEven
                                        ? ColorTheme.whiteColor
                                        : ColorTheme.addressBoxGrey
                                            .withOpacity(0.3),
                                    borderRadius: isLast
                                        ? BorderRadius.only(
                                            bottomLeft: Radius.circular(11),
                                            bottomRight: Radius.circular(11),
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      // Title
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              right: 12, left: 12),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color: ColorTheme.borderGrey2,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            table['title'] ?? '',
                                            style: montserratMedium.copyWith(
                                              color: ColorTheme.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Table Number
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color: ColorTheme.borderGrey2,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              table['table_no'] ?? '',
                                              textAlign: TextAlign.center,
                                              style: montserratMedium.copyWith(
                                                color: ColorTheme.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Type (Table/Room)
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color: ColorTheme.borderGrey2,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              (table['rtype'] ?? 'TB') == 'TB'
                                                  ? 'Table'
                                                  : 'Room',
                                              textAlign: TextAlign.center,
                                              style: montserratMedium.copyWith(
                                                color:
                                                    (table['rtype'] ?? 'TB') ==
                                                            'TB'
                                                        ? ColorTheme.greenColor
                                                        : ColorTheme.blue,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Actions
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Edit Button
                                            InkWell(
                                              onTap: () {
                                                controller
                                                    .setEditingTable(table);
                                                Get.to(() =>
                                                    AddEditTableManagementScreen(
                                                      isEdit: true,
                                                    ));
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: ColorTheme.blueColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.edit,
                                                  color: ColorTheme.blueColor,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            // Delete Button
                                            InkWell(
                                              onTap: () {
                                                _showDeleteConfirmationBottomSheet(
                                                    context, table, controller);
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: ColorTheme.redColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.delete_outline,
                                                  color: ColorTheme.redColor,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationBottomSheet(BuildContext context,
      Map<String, dynamic> table, TableManagementController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorTheme.redColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 40,
                  color: ColorTheme.redColor,
                ),
              ),
              SizedBox(height: 20),

              // Title
              Text(
                'Delete Table',
                style: montserratSemiBold.copyWith(
                  color: ColorTheme.black,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 12),

              // Description
              Text(
                'Are you sure you want to delete "${table['table_no']}"?',
                textAlign: TextAlign.center,
                style: montserratRegular.copyWith(
                  color: ColorTheme.grey1,
                  fontSize: 14,
                ),
              ),
              // SizedBox(height: 8),
              // Text(
              //   'This action cannot be undone.',
              //   textAlign: TextAlign.center,
              //   style: montserratMedium.copyWith(
              //     color: ColorTheme.redColor,
              //     fontSize: 12,
              //   ),
              // ),
              SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent,
                        backgroundColor: ColorTheme.whiteColor,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: ColorTheme.borderGrey2),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Cancel',
                        style: montserratSemiBold.copyWith(
                          color: ColorTheme.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),

                  // Delete Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.deleteTable(table['id']);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent,
                        backgroundColor: ColorTheme.redColor,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Delete',
                        style: montserratSemiBold.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
