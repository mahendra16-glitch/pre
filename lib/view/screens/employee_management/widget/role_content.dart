import 'dart:io';

import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/controller/role_management_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
// import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/widget/add_edit_role_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:get/get.dart';

class RoleList extends StatefulWidget {
  final Key? key;
  const RoleList({this.key}) : super(key: key);

  @override
  _RoleListState createState() => _RoleListState();
}

class _RoleListState extends State<RoleList> {
  bool _isTooltipVisible = false;
  SuperTooltipController? _tooltipController;

  @override
  void initState() {
    super.initState();
    _tooltipController = SuperTooltipController();
    final roleMngmtController = Get.find<RoleManagementController>();
    roleMngmtController.getRoleMngmtList();
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
    return GetBuilder<RoleManagementController>(builder: (roleMngmtController) {
      final roleList = roleMngmtController.filteredRoleMngmtList;
      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: roleMngmtController.roleSearchController,
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
                    roleMngmtController.filterRoles();
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            roleMngmtController.isLoading
                ? Center(
                    child: SpinKitFadingCircle(
                    color: Colors.white,
                    size: 25.0,
                  ))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      // width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: ColorTheme.borderGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'System Role : ${roleMngmtController.systemRoleMngmtList.map((role) => role.name ?? 'No Name').join(', ')}',
                        style: montserratMedium.copyWith(
                            fontSize: 14, color: ColorTheme.grey1),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: SizedBox(
                width: double.infinity,
                child: roleMngmtController.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : roleList.isEmpty
                        ? Center(
                            child: Text('No Data Found'),
                          )
                        : DataTable(
                            columnSpacing: 15,
                            dataRowHeight: 70,
                            horizontalMargin: 0,
                            border: TableBorder(
                                top: BorderSide(
                                    color: ColorTheme.borderGrey3
                                        .withOpacity(0.5)),
                                verticalInside: BorderSide(
                                    color: ColorTheme.borderGrey3
                                        .withOpacity(0.5))),
                            showBottomBorder: true,
                            columns: [
                              DataColumn(
                                columnWidth: const FixedColumnWidth(130),
                                label: Expanded(
                                  flex: 7,
                                  child: Text(
                                    "Details",
                                    style: montserratSemiBold.copyWith(
                                      color: ColorTheme.blueColor,
                                      fontSize: 15,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Modules",
                                          style: montserratSemiBold.copyWith(
                                            color: ColorTheme.blueColor,
                                            fontSize: 15,
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
                                        //           child: Column(
                                        //             mainAxisSize:
                                        //                 MainAxisSize.min,
                                        //             crossAxisAlignment:
                                        //                 CrossAxisAlignment
                                        //                     .start,
                                        //             children: [
                                        //               Text(
                                        //                 "Setting a Password",
                                        //                 style: TextStyle(
                                        //                   fontSize: 16,
                                        //                   fontWeight:
                                        //                       FontWeight.bold,
                                        //                   color: Colors.blue,
                                        //                 ),
                                        //               ),
                                        //               SizedBox(height: 8),
                                        //               _buildBulletPoint(
                                        //                   "It is a long established fact that a reader will be distracted by the readable content."),
                                        //               _buildBulletPoint(
                                        //                   "It is a long established fact that a reader will be distracted by the readable content."),
                                        //             ],
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
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            rows:
                                roleList.asMap().entries.map<DataRow>((entry) {
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
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxWidth: Platform.isWindows
                                                      ? 200
                                                      : 70,
                                                  minWidth: 0),
                                              child: Text(
                                                item.name ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style:
                                                    montserratSemiBold.copyWith(
                                                        color:
                                                            Color(0xFF828282),
                                                        fontSize: 15),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              // item.id.toString(),
                                              DateFormat('dd/MM/yyyy')
                                                  .format(item.updatedAt!),
                                              // item.updatedAt.toString(),
                                              style:
                                                  montserratSemiBold.copyWith(
                                                fontSize: 11,
                                                color: ColorTheme.blueColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Spacer(),
                                        Column(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons
                                                      .arrow_forward_ios_outlined,
                                                  color: ColorTheme.blueColor,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                            // Expanded(
                                            //     flex: 2,
                                            //     child: IconButton(
                                            //         onPressed: () {},
                                            //         icon: SvgPicture.asset(
                                            //           Images.Phone_icon,
                                            //           width: 30,
                                            //         )))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth:
                                              Platform.isWindows ? 600 : 90,
                                        ),
                                        child: Text(
                                          item.modules.join(', '),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                          style: montserratSemiBold.copyWith(
                                            color: ColorTheme.grey1,
                                            // fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
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
                                          InkWell(
                                            onTap: () {
                                              (item.isSystemRole ?? false)
                                                  ? ((Platform.isAndroid ||
                                                          Platform.isIOS)
                                                      ? appToast(
                                                          item.protectionLevel ??
                                                              '')
                                                      : Get.snackbar(
                                                          item.protectionLevel ??
                                                              '',
                                                          'This Role Is Not Editable.',
                                                          backgroundColor:
                                                              ColorTheme.green,
                                                          colorText:
                                                              Colors.white))
                                                  : Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              AddEditRoleScreen(
                                                                isEdit: true,
                                                                roleData: roleList[
                                                                        index]
                                                                    .toJson(),
                                                                id: item.id,
                                                              )));
                                            },
                                            child: CircleAvatar(
                                                backgroundColor:
                                                    ColorTheme.white,
                                                radius: 17,
                                                child: const Icon(
                                                  Icons.edit_outlined,
                                                  color: Colors.blue,
                                                  size: 20,
                                                )),
                                          ),
                                          // SizedBox(
                                          //   width: 3,
                                          // ),
                                          // CircleAvatar(
                                          //     backgroundColor: ColorTheme.white,
                                          //     radius: 17,
                                          //     child: const Icon(
                                          //       Icons.delete,
                                          //       color: Colors.blue,
                                          //       size: 20,
                                          //     )),
                                          Transform.scale(
                                            scale: 0.6,
                                            child: Switch(
                                              value: item.status == 1
                                                  ? true
                                                  : false,
                                              // value:
                                              //     roleMngmtController.isSubmitting,
                                              onChanged: (value) {
                                                final data = {
                                                  "status": value ? 1 : 0
                                                };
                                                roleMngmtController
                                                    .updateStatus(
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
