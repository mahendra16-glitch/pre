import 'dart:io';

import 'package:mygenie_restaurant/view/screens/employee_management/controller/employee_management_controller.dart';
// import 'package:mygenie_restaurant/data/model/response/get_employee_management_list_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/widget/add_edit_employee_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
// import 'package:mygenie_ui/screens/employee_management/widget/add_employee.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/super_tooltip.dart';
import 'package:get/get.dart';

class EmployeeList extends StatefulWidget {
  final Key? key;
  const EmployeeList({this.key}) : super(key: key);

  @override
  _EmployeeListState createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {
  bool _isTooltipVisible = false;
  SuperTooltipController? _tooltipController;

  @override
  void initState() {
    super.initState();
    _tooltipController = SuperTooltipController();
    final employeeManagementController =
        Get.find<EmployeeManagementController>();
    employeeManagementController.getEmployeeMnmgtList();
  }

  void _toggleTooltip() {
    setState(() {
      // _isTooltipVisible = !_isTooltipVisible;
      if (_isTooltipVisible) {
        _tooltipController!.showTooltip();
      } else {
        _tooltipController!.hideTooltip();
      }
    });
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(fontSize: 16, color: Colors.blue),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tooltipController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EmployeeManagementController>(
        builder: (employeeManagementController) {
      // if (employeeManagementController.filteredEmployeeMnmgtList!.isEmpty &&
      //     employeeManagementController.employeeSearchController.text.isEmpty) {
      //   employeeManagementController.filteredEmployeeMnmgtList =
      //       employeeManagementController.employeeMnmgtList;
      // }
      final filterList = employeeManagementController.filteredEmployeeMnmgtList;

      // if (employeeManagementController.isLoading) {
      //   return Center(child: const CircularProgressIndicator());
      // }
      // if (filterList!.isEmpty) {
      //   return Center(child: const Text('No Data is Found'));
      // }
      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller:
                    employeeManagementController.employeeSearchController,
                style: TextStyle(decoration: TextDecoration.none),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle:
                      montserratSemiBold.copyWith(color: Color(0xFFC6C6C6)),
                  suffixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFC6C6C6),
                  ),
                  filled: true,
                  fillColor: ColorTheme.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      borderSide: BorderSide(color: ColorTheme.white)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      borderSide: BorderSide(color: ColorTheme.white)),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      borderSide: BorderSide(color: ColorTheme.white)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      borderSide: BorderSide(color: ColorTheme.white)),
                ),
                onChanged: (_) {
                  setState(() {
                    employeeManagementController.filterEmployees();
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            //  Center(
            //             child: SpinKitSpinningLines(
            //             color: ColorTheme.appColor,
            //           ))
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: SizedBox(
                width: double.infinity,
                child: employeeManagementController.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : (filterList!.isEmpty)
                        ? Center(child: const Text('No Data is Found'))
                        : DataTable(
                            columnSpacing: 15,
                            dataRowHeight: 70,
                            horizontalMargin: 0,
                            border: TableBorder(
                                bottom: BorderSide(
                                    color: ColorTheme.borderGrey3
                                        .withOpacity(0.5)),
                                horizontalInside: BorderSide(
                                    color: ColorTheme.borderGrey3
                                        .withOpacity(0.5)),
                                top: BorderSide(
                                    color: ColorTheme.borderGrey3
                                        .withOpacity(0.5)),
                                verticalInside: BorderSide(
                                    color: ColorTheme.borderGrey3
                                        .withOpacity(0.5))),
                            showBottomBorder: true,
                            columns: [
                              DataColumn(
                                columnWidth: const FixedColumnWidth(140),
                                label: Expanded(
                                  flex: 7,
                                  child: Text(
                                    "Details",
                                    style: montserratSemiBold.copyWith(
                                      color: ColorTheme.blueColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: Platform.isWindows
                                          ? MainAxisAlignment.center
                                          : MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Role",
                                          style: montserratSemiBold.copyWith(
                                            color: ColorTheme.blueColor,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        // Builder(
                                        //   builder: (context) {
                                        //     return SuperTooltip(
                                        //       controller: _tooltipController,
                                        //       popupDirection:
                                        //           TooltipDirection.down,
                                        //       arrowLength: 10,
                                        //       arrowBaseWidth: 20,
                                        //       borderColor: Colors.transparent,
                                        //       borderWidth: 1,
                                        //       shadowColor: Colors.transparent,
                                        //       shadowBlurRadius: 0,
                                        //       shadowSpreadRadius: 0,
                                        //       content: Material(
                                        //         child: Container(
                                        //           width: MediaQuery.of(context)
                                        //                   .size
                                        //                   .width *
                                        //               0.7,
                                        //           padding:
                                        //               const EdgeInsets.all(12),
                                        //           child: SingleChildScrollView(
                                        //             child: Column(
                                        //               mainAxisSize:
                                        //                   MainAxisSize.min,
                                        //               crossAxisAlignment:
                                        //                   CrossAxisAlignment
                                        //                       .start,
                                        //               children: [
                                        //                 Text(
                                        //                   "Setting a Password",
                                        //                   style: TextStyle(
                                        //                     fontSize: 16,
                                        //                     fontWeight:
                                        //                         FontWeight.bold,
                                        //                     color: Colors.blue,
                                        //                   ),
                                        //                 ),
                                        //                 SizedBox(height: 8),
                                        //                 _buildBulletPoint(
                                        //                     "It is a long established fact that a reader will be distracted by the readable content."),
                                        //                 _buildBulletPoint(
                                        //                     "It is a long established fact that a reader will be distracted by the readable content."),
                                        //                 _buildBulletPoint(
                                        //                     "It is a long established fact that a reader will be distracted by the readable content."),
                                        //               ],
                                        //             ),
                                        //           ),
                                        //         ),
                                        //       ),
                                        //       child: InkWell(
                                        //         onTap: () {
                                        //           setState(() {
                                        //             _isTooltipVisible =
                                        //                 !_isTooltipVisible;
                                        //           });
                                        //           _toggleTooltip();
                                        //         },
                                        //         child: Icon(
                                        //           Icons.help_outline,
                                        //           color: ColorTheme.borderGrey3,
                                        //         ),
                                        //       ),
                                        //     );
                                        //   },
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  flex: 3,
                                  child: Center(
                                    child: Text(
                                      "Action",
                                      style: montserratSemiBold.copyWith(
                                        color: ColorTheme.blueColor,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            rows: filterList
                                .asMap()
                                .entries
                                .map<DataRow>((entry) {
                              // print(item.fName);
                              final index = entry.key;
                              final item = entry.value;

                              return DataRow(
                                cells: [
                                  DataCell(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxWidth: Platform.isWindows
                                                      ? 200
                                                      : 90),
                                              child: Text(
                                                item.fName ?? 'Employee Name',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style:
                                                    montserratSemiBold.copyWith(
                                                        color:
                                                            Color(0xFF828282),
                                                        fontSize: 15),
                                              ),
                                            ),
                                            SizedBox(height: 3),
                                            Text(
                                              item.id.toString(),
                                              style:
                                                  montserratSemiBold.copyWith(
                                                fontSize: 11,
                                                color: ColorTheme.blueColor,
                                              ),
                                            ),
                                            SizedBox(height: 3),
                                            Text(
                                              employeeManagementController
                                                  .sanitizePhoneNumber(
                                                      item.phone ??
                                                          '818197xxxx'),
                                              style:
                                                  montserratSemiBold.copyWith(
                                                fontSize: 14,
                                                color: ColorTheme.black5F6368,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        Column(
                                          // crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: IconButton(
                                                onPressed: () {
                                                  // Navigator.push(
                                                  //     context,
                                                  //     MaterialPageRoute(
                                                  //       builder: (context) =>
                                                  //           DailySalesOrderDetails(
                                                  //         orderId:
                                                  //             item.orderId.toString(),
                                                  //         controller: controller!,
                                                  //       ),
                                                  //     ));
                                                },
                                                icon: Icon(
                                                  Icons
                                                      .arrow_forward_ios_outlined,
                                                  color: ColorTheme.blueColor,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                flex: 2,
                                                child: IconButton(
                                                    onPressed: () {},
                                                    icon: SvgPicture.asset(
                                                      Images.Phone_icon,
                                                      width: 30,
                                                    )))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth:
                                              Platform.isWindows ? 500 : 80),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          item.role?.name ?? ' ',
                                          style: montserratSemiBold.copyWith(
                                            color: ColorTheme.grey1,
                                            // fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          // textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: ColorTheme.white,
                                            radius: 17,
                                            child: IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              AddEditEmployeeRoleScreen(
                                                                employeeRoleData:
                                                                    filterList[
                                                                            index]
                                                                        .toJson(),
                                                                isEdit: true,
                                                                id: item.id,
                                                              )));
                                                },
                                                icon: Icon(
                                                  Icons.edit_outlined,
                                                  color: Colors.blue,
                                                  size: 20,
                                                )),
                                          ),
                                          SizedBox(
                                            width: 3,
                                          ),
                                          // CircleAvatar(
                                          //     backgroundColor: ColorTheme.white,
                                          //     radius: 17,
                                          //     child: IconButton(
                                          //         onPressed: () {
                                          //           employeeManagementController
                                          //               .deleteEmployeeMnmgtList(
                                          //                   item.id);
                                          //         },
                                          //         icon: Icon(
                                          //           Icons.delete,
                                          //           color: Colors.blue,
                                          //           size: 20,
                                          //         ))),
                                          Transform.scale(
                                            scale: 0.6,
                                            child: Switch(
                                              value: item.status == 1
                                                  ? true
                                                  : false,
                                              onChanged: (value) {
                                                final data = {
                                                  "status": value ? 1 : 0
                                                };
                                                employeeManagementController
                                                    .updateEmployeeStatus(
                                                        item.id!, data);
                                              },
                                              activeColor: ColorTheme.blue,
                                              activeTrackColor:
                                                  Colors.transparent,
                                              inactiveTrackColor:
                                                  Colors.transparent,
                                              trackOutlineWidth:
                                                  const WidgetStatePropertyAll(
                                                      3),
                                              thumbColor: item.status == 1
                                                  ? WidgetStatePropertyAll(
                                                      ColorTheme.blue)
                                                  : const WidgetStatePropertyAll(
                                                      Color(0xFFCACACA)),
                                              inactiveThumbColor:
                                                  const Color(0xFFCACACA),
                                              trackOutlineColor: item.status ==
                                                      1
                                                  ? WidgetStatePropertyAll(
                                                      ColorTheme.blue)
                                                  : const WidgetStatePropertyAll(
                                                      Color(0xFFCACACA)),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
