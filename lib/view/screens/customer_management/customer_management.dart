import 'dart:io';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_customer_list_response.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/view/screens/custome%20management/controller/customer_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/widget/custom_textform_field.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CustomerManagement extends StatefulWidget {
  @override
  State<CustomerManagement> createState() => _CustomerManagementState();
}

class _CustomerManagementState extends State<CustomerManagement> {
  final TextEditingController _searchController = TextEditingController();
  TextEditingController _transactionNoController = TextEditingController();
  TextEditingController _paidController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController aniversaryDateController = TextEditingController();
  TextEditingController customerSuggestion = TextEditingController();
  TextEditingController customerPhoneSuggestion = TextEditingController();
  TextEditingController gstNameController = TextEditingController();
  TextEditingController gstNumberController = TextEditingController();
  TextEditingController walletAmount = TextEditingController();
  bool isEdit = false;
  String? _selectedDropdownOption;

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    Get.find<PosController>().setPaymentTabIndex(0);
    await Get.find<CustomerManagementController>().getCustomerFromApiModel();
    await Get.find<CustomerManagementController>().getCustomerDesignationList();
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
              icon: Icon(Icons.chevron_left, size: 35, color: ColorTheme.green),
              color: ColorTheme.appColor,
              onPressed: () {
                Get.find<PosController>().clearTapCustomerData();
                Get.back();
              }),
          titleSpacing: 0,
          elevation: 0,
          centerTitle: false,
          title: Text(
            'Wallet Management', //'Customer Management'
            style: AppStyle.stockListStyle
                .copyWith(color: ColorTheme.blackColor, fontSize: 16),
          ),
        ),
        body: SafeArea(
          child: GetBuilder<PosController>(builder: (posController) {
            return GetBuilder<CustomerManagementController>(
                builder: (custController) {
              return Column(
                children: [
                  Divider(color: ColorTheme.grey, height: 1),
                  Row(
                    children: [
                      9.width,
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            isEdit = false;
                            custController.updateTapIndex(0);
                          },
                          child: Container(
                            color: custController.selectedTab == 0
                                ? ColorTheme.whiteColor
                                : ColorTheme.transparent,
                            margin: EdgeInsets.symmetric(vertical: 5),
                            alignment: Alignment.center,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14.0),
                              child: Text(
                                "Add Customer",
                                style: TextStyle(
                                  color: custController.selectedTab == 0
                                      ? ColorTheme.greenColor
                                      : ColorTheme.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      9.width,
                      Container(width: 0.5, height: 60, color: ColorTheme.grey),
                      9.width,
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            isEdit = false;
                            custController.updateTapIndex(1);
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            color: custController.selectedTab == 1
                                ? ColorTheme.whiteColor
                                : ColorTheme.transparent,
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                'Manage Wallet', //'Manage Customer'
                                style: TextStyle(
                                    color: custController.selectedTab == 1
                                        ? ColorTheme.greenColor
                                        : ColorTheme.grey),
                              ),
                            ),
                          ),
                        ),
                      ),
                      9.width,
                    ],
                  ),
                  Divider(color: ColorTheme.grey, height: 1),
                  Expanded(
                    child: custController.selectedTab == 0
                        ? addCustomer(custController, posController)
                        : manageCustomer(custController, posController),
                  ),
                ],
              );
            });
          }),

          //  SingleChildScrollView(
          //   physics: BouncingScrollPhysics(),
          //   child: GetBuilder<CartController>(builder: (cartController) {
          //     return GetBuilder<PosController>(builder: (posController) {
          //       return Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               crossAxisAlignment: CrossAxisAlignment.center,
          //               children: [
          //                 Padding(
          //                   padding: const EdgeInsets.only(left: 20, top: 15),
          //                   child: Text(
          //                     'Virtual Wallet',
          //                     style: poppinsSemiBold.copyWith(fontSize: 15),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //             Padding(
          //               padding: const EdgeInsets.only(top: 15, bottom: 15),
          //               child: Divider(
          //                 color: Color(0xFFE6E6E6),
          //               ),
          //             ),
          //             Padding(
          //               padding: const EdgeInsets.symmetric(horizontal: 20),
          //               child: Container(
          //                 height: 36,
          //                 child: TextField(
          //                   controller: _searchController,
          //                   textInputAction: TextInputAction.search,
          //                   autofocus: false,
          //                   textCapitalization: TextCapitalization.words,
          //                   keyboardType: TextInputType.name,
          //                   decoration: InputDecoration(
          //                     contentPadding: EdgeInsets.symmetric(
          //                         horizontal: Dimensions.PADDING_SIZE_DEFAULT),
          //                     suffixIcon: Icon(Icons.search,
          //                         size: 22, color: ColorTheme.appColor),
          //                     hintText: 'Search by phone / name ',
          //                     enabledBorder: OutlineInputBorder(
          //                       borderRadius: BorderRadius.circular(7),
          //                       borderSide:
          //                           BorderSide(color: ColorTheme.borderGrey),
          //                     ),
          //                     focusedBorder: OutlineInputBorder(
          //                       borderRadius: BorderRadius.circular(7),
          //                       borderSide:
          //                           BorderSide(color: ColorTheme.borderGrey),
          //                     ),
          //                     border: OutlineInputBorder(
          //                       borderRadius: BorderRadius.circular(7),
          //                       borderSide:
          //                           BorderSide(color: ColorTheme.borderGrey),
          //                     ),
          //                     hintStyle: poppinsMedium.copyWith(
          //                         fontSize: 13, color: ColorTheme.hintText),
          //                     filled: true,
          //                     fillColor: Colors.white,
          //                   ),
          //                   style: poppinsRegular.copyWith(
          //                     color: Colors.black,
          //                     fontSize: 13,
          //                   ),
          //                   onChanged: (value) async {
          //                     if (_searchController.text.isEmpty) {
          //                       posController.clearTapCustomerData();
          //                     }
          //                     posController.update();
          //                   },
          //                 ),
          //               ),
          //             ),
          //             SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
          //             cartController.customerList == null
          //                 ? SizedBox.shrink()
          //                 : Padding(
          //                     padding:
          //                         const EdgeInsets.symmetric(horizontal: 20),
          //                     child: ListView.builder(
          //                         itemCount: cartController
          //                                 .customerList?.customerList?.length ??
          //                             0,
          //                         shrinkWrap: true,
          //                         physics: BouncingScrollPhysics(),
          //                         itemBuilder: (BuildContext context, int i) {
          //                           CustomerList customer = cartController
          //                               .customerList!.customerList[i];
          //                           double balance = customer.virtualWalletBal;

          //                           return Column(
          //                             children: [
          //                               _searchController.text.isEmpty
          //                                   ? customerItem(customer, i)
          //                                   : (customer.customerName
          //                                               .toLowerCase()
          //                                               .contains(_searchController
          //                                                   .text
          //                                                   .toLowerCase())) ||
          //                                           customer.phone
          //                                               .toString()
          //                                               .toLowerCase()
          //                                               .contains(
          //                                                   _searchController
          //                                                       .text
          //                                                       .toLowerCase())
          //                                       ? customerItem(customer, i)
          //                                       : SizedBox.shrink(),
          //                               posController.isShowCustomerData &&
          //                                       posController
          //                                               .selectedCustomerIndex ==
          //                                           i
          //                                   ? Column(
          //                                       children: [
          //                                         Padding(
          //                                           padding: EdgeInsets.only(
          //                                               left: 7,
          //                                               right: 7,
          //                                               top: 15),
          //                                           child: DottedLine(
          //                                             direction:
          //                                                 Axis.horizontal,
          //                                             alignment:
          //                                                 WrapAlignment.center,
          //                                             lineThickness: 1.0,
          //                                             dashLength: 2.5,
          //                                             dashColor:
          //                                                 ColorTheme.hintText,
          //                                           ),
          //                                         ),
          //                                         Padding(
          //                                           padding: EdgeInsets.only(
          //                                             top: Dimensions
          //                                                 .PADDING_SIZE_DEFAULT,
          //                                             bottom: Dimensions
          //                                                 .PADDING_SIZE_SMALL,
          //                                             left: 7,
          //                                           ),
          //                                           child: Align(
          //                                             alignment:
          //                                                 Alignment.centerLeft,
          //                                             child: Text(
          //                                               'Select Payment Method',
          //                                               textAlign:
          //                                                   TextAlign.right,
          //                                               style: poppinsSemiBold
          //                                                   .copyWith(
          //                                                 fontSize: 15,
          //                                                 // color: Color.fromRGBO(112, 112, 112, 1.0),
          //                                               ),
          //                                             ),
          //                                           ),
          //                                         ),
          //                                         SizedBox(height: 15),
          //                                         Padding(
          //                                           padding: EdgeInsets.symmetric(
          //                                               horizontal: Dimensions
          //                                                   .PADDING_SIZE_DEFAULT),
          //                                           child: GetBuilder<
          //                                                   PosController>(
          //                                               builder:
          //                                                   (posController) {
          //                                             return Container(
          //                                               padding: EdgeInsets
          //                                                   .symmetric(
          //                                                       vertical: 20),
          //                                               decoration: BoxDecoration(
          //                                                   color: Color(
          //                                                       0xFFF8F8F8),
          //                                                   borderRadius:
          //                                                       BorderRadius
          //                                                           .circular(
          //                                                               10)),
          //                                               child: Column(
          //                                                 children: [
          //                                                   Padding(
          //                                                     padding:
          //                                                         const EdgeInsets
          //                                                             .symmetric(
          //                                                             horizontal:
          //                                                                 15),
          //                                                     child: Row(
          //                                                       mainAxisAlignment:
          //                                                           MainAxisAlignment
          //                                                               .spaceBetween,
          //                                                       children: [
          //                                                         Expanded(
          //                                                           child:
          //                                                               InkWell(
          //                                                             splashColor:
          //                                                                 Colors
          //                                                                     .transparent,
          //                                                             hoverColor:
          //                                                                 Colors
          //                                                                     .transparent,
          //                                                             highlightColor:
          //                                                                 Colors
          //                                                                     .transparent,
          //                                                             onTap:
          //                                                                 () {
          //                                                               FocusManager
          //                                                                   .instance
          //                                                                   .primaryFocus
          //                                                                   ?.unfocus();

          //                                                               posController
          //                                                                   .setPaymentTabIndex(0);
          //                                                             },
          //                                                             child:
          //                                                                 Container(
          //                                                               width: Get
          //                                                                   .width,
          //                                                               margin: EdgeInsets.only(
          //                                                                   right:
          //                                                                       10),
          //                                                               padding:
          //                                                                   EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
          //                                                               decoration: BoxDecoration(
          //                                                                   border: Border.all(color: posController.selectedPaymentTab == 0 ? Colors.transparent : ColorTheme.borderGrey),
          //                                                                   color: posController.selectedPaymentTab == 0 ? ColorTheme.appColor : Colors.white,
          //                                                                   // border:
          //                                                                   //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
          //                                                                   borderRadius: BorderRadius.circular(7)),
          //                                                               child:
          //                                                                   Center(
          //                                                                 child:
          //                                                                     Text(
          //                                                                   'Cash'.tr,
          //                                                                   style:
          //                                                                       poppinsMedium.copyWith(fontSize: 13, color: posController.selectedPaymentTab == 0 ? Colors.white : ColorTheme.appColor),
          //                                                                 ),
          //                                                               ),
          //                                                             ),
          //                                                           ),
          //                                                         ),
          //                                                         Expanded(
          //                                                           child:
          //                                                               InkWell(
          //                                                             splashColor:
          //                                                                 Colors
          //                                                                     .transparent,
          //                                                             hoverColor:
          //                                                                 Colors
          //                                                                     .transparent,
          //                                                             highlightColor:
          //                                                                 Colors
          //                                                                     .transparent,
          //                                                             onTap:
          //                                                                 () {
          //                                                               FocusManager
          //                                                                   .instance
          //                                                                   .primaryFocus
          //                                                                   ?.unfocus();

          //                                                               posController
          //                                                                   .setPaymentTabIndex(1);
          //                                                             },
          //                                                             child:
          //                                                                 Container(
          //                                                               width: Get
          //                                                                   .width,
          //                                                               margin: EdgeInsets.only(
          //                                                                   right:
          //                                                                       10),
          //                                                               padding:
          //                                                                   EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
          //                                                               decoration: BoxDecoration(
          //                                                                   border:
          //                                                                       Border.all(color: posController.selectedPaymentTab == 1 ? Colors.transparent : ColorTheme.borderGrey),
          //                                                                   color: posController.selectedPaymentTab == 1 ? ColorTheme.appColor : Colors.white,
          //                                                                   borderRadius: BorderRadius.circular(7)),
          //                                                               child:
          //                                                                   Center(
          //                                                                 child:
          //                                                                     Text(
          //                                                                   'Card'.tr,
          //                                                                   style:
          //                                                                       poppinsMedium.copyWith(fontSize: 13, color: posController.selectedPaymentTab == 1 ? Colors.white : ColorTheme.appColor),
          //                                                                 ),
          //                                                               ),
          //                                                             ),
          //                                                           ),
          //                                                         ),
          //                                                         Expanded(
          //                                                           child:
          //                                                               InkWell(
          //                                                             splashColor:
          //                                                                 Colors
          //                                                                     .transparent,
          //                                                             hoverColor:
          //                                                                 Colors
          //                                                                     .transparent,
          //                                                             highlightColor:
          //                                                                 Colors
          //                                                                     .transparent,
          //                                                             onTap:
          //                                                                 () {
          //                                                               FocusManager
          //                                                                   .instance
          //                                                                   .primaryFocus
          //                                                                   ?.unfocus();

          //                                                               posController
          //                                                                   .setPaymentTabIndex(2);
          //                                                             },
          //                                                             child:
          //                                                                 Container(
          //                                                               width: Get
          //                                                                   .width,
          //                                                               margin: EdgeInsets.only(
          //                                                                   right:
          //                                                                       10),
          //                                                               padding:
          //                                                                   EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
          //                                                               decoration: BoxDecoration(
          //                                                                   border: Border.all(color: posController.selectedPaymentTab == 2 ? Colors.transparent : ColorTheme.borderGrey),
          //                                                                   color: posController.selectedPaymentTab == 2 ? ColorTheme.appColor : Colors.white,

          //                                                                   // border:
          //                                                                   //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
          //                                                                   borderRadius: BorderRadius.circular(7)),
          //                                                               child:
          //                                                                   Center(
          //                                                                 child:
          //                                                                     Text(
          //                                                                   'UPI'.tr,
          //                                                                   style:
          //                                                                       poppinsMedium.copyWith(fontSize: 13, color: posController.selectedPaymentTab == 2 ? Colors.white : ColorTheme.appColor),
          //                                                                 ),
          //                                                               ),
          //                                                             ),
          //                                                           ),
          //                                                         ),
          //                                                         Expanded(
          //                                                             child:
          //                                                                 SizedBox()),
          //                                                       ],
          //                                                     ),
          //                                                   ),
          //                                                   Padding(
          //                                                     padding:
          //                                                         const EdgeInsets
          //                                                             .symmetric(
          //                                                             vertical:
          //                                                                 15),
          //                                                     child: DottedLine(
          //                                                       direction: Axis
          //                                                           .horizontal,
          //                                                       alignment:
          //                                                           WrapAlignment
          //                                                               .center,
          //                                                       lineThickness:
          //                                                           1.0,
          //                                                       dashLength: 2.5,
          //                                                       dashColor:
          //                                                           ColorTheme
          //                                                               .hintText,
          //                                                     ),
          //                                                   ),
          //                                                   Container(
          //                                                     padding: EdgeInsets
          //                                                         .symmetric(
          //                                                             horizontal:
          //                                                                 15),
          //                                                     margin: EdgeInsets
          //                                                         .only(
          //                                                             top: 10,
          //                                                             bottom:
          //                                                                 10),
          //                                                     child: Row(
          //                                                       children: [
          //                                                         Expanded(
          //                                                           child:
          //                                                               Align(
          //                                                             alignment:
          //                                                                 Alignment
          //                                                                     .centerLeft,
          //                                                             child:
          //                                                                 Text(
          //                                                               'Add money: ',
          //                                                               // textAlign: TextAlign.right,
          //                                                               style: poppinsMedium
          //                                                                   .copyWith(
          //                                                                 fontSize:
          //                                                                     14,
          //                                                               ),
          //                                                             ),
          //                                                           ),
          //                                                         ),
          //                                                         Expanded(
          //                                                           child:
          //                                                               Container(
          //                                                             height:
          //                                                                 36,
          //                                                             decoration: BoxDecoration(
          //                                                                 borderRadius: BorderRadius.circular(
          //                                                                     7),
          //                                                                 border:
          //                                                                     Border.all(color: ColorTheme.borderGrey)),
          //                                                             child:
          //                                                                 TextField(
          //                                                               controller:
          //                                                                   _paidController,
          //                                                               autofocus:
          //                                                                   false,
          //                                                               keyboardType:
          //                                                                   TextInputType.numberWithOptions(signed: true),
          //                                                               decoration:
          //                                                                   InputDecoration(
          //                                                                 // hintText: 'phone'.tr,
          //                                                                 contentPadding:
          //                                                                     EdgeInsets.symmetric(horizontal: 10),
          //                                                                 border:
          //                                                                     OutlineInputBorder(
          //                                                                   borderRadius:
          //                                                                       BorderRadius.circular(7),
          //                                                                   borderSide:
          //                                                                       BorderSide(style: BorderStyle.none, width: 0),
          //                                                                 ),
          //                                                                 hintStyle: poppinsMedium.copyWith(
          //                                                                     fontSize: 13,
          //                                                                     color: ColorTheme.hintText),
          //                                                                 filled:
          //                                                                     true,
          //                                                                 fillColor:
          //                                                                     Colors.white,
          //                                                               ),
          //                                                               style: poppinsMedium
          //                                                                   .copyWith(
          //                                                                 color:
          //                                                                     Colors.black,
          //                                                                 fontSize:
          //                                                                     13,
          //                                                               ),
          //                                                               onChanged:
          //                                                                   (value) async {
          //                                                                 posController
          //                                                                     .update();
          //                                                               },
          //                                                             ),
          //                                                           ),
          //                                                         ),
          //                                                       ],
          //                                                     ),
          //                                                   ),
          //                                                   Container(
          //                                                     padding: EdgeInsets
          //                                                         .symmetric(
          //                                                             horizontal:
          //                                                                 15),
          //                                                     margin: EdgeInsets
          //                                                         .only(
          //                                                             top: 10,
          //                                                             bottom:
          //                                                                 10),
          //                                                     child: Row(
          //                                                       children: [
          //                                                         Expanded(
          //                                                           child:
          //                                                               Align(
          //                                                             alignment:
          //                                                                 Alignment
          //                                                                     .centerLeft,
          //                                                             child:
          //                                                                 Text(
          //                                                               'Balance: ',
          //                                                               // textAlign: TextAlign.right,
          //                                                               style: poppinsMedium.copyWith(
          //                                                                   fontSize:
          //                                                                       14),
          //                                                             ),
          //                                                           ),
          //                                                         ),
          //                                                         Expanded(
          //                                                           child: Container(
          //                                                               height: 36,
          //                                                               decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), border: Border.all(color: ColorTheme.borderGrey)),
          //                                                               child: Align(
          //                                                                 alignment:
          //                                                                     Alignment.centerLeft,
          //                                                                 child:
          //                                                                     Text(
          //                                                                   '   ' +
          //                                                                       (balance.toStringAsFixed(2)),
          //                                                                   style:
          //                                                                       poppinsMedium.copyWith(
          //                                                                     color: ColorTheme.hintText,
          //                                                                     fontSize: 13,
          //                                                                   ),
          //                                                                 ),
          //                                                               )),
          //                                                         ),
          //                                                       ],
          //                                                     ),
          //                                                   ),
          //                                                   posController.selectedPaymentTab ==
          //                                                               0 ||
          //                                                           posController
          //                                                                   .selectedPaymentTab ==
          //                                                               2
          //                                                       ? SizedBox
          //                                                           .shrink()
          //                                                       : Container(
          //                                                           padding: EdgeInsets.symmetric(
          //                                                               horizontal:
          //                                                                   15),
          //                                                           margin:
          //                                                               EdgeInsets
          //                                                                   .only(
          //                                                             top: Dimensions
          //                                                                 .PADDING_SIZE_LARGE,
          //                                                           ),
          //                                                           child: Row(
          //                                                             children: [
          //                                                               Expanded(
          //                                                                 child:
          //                                                                     Align(
          //                                                                   alignment:
          //                                                                       Alignment.centerLeft,
          //                                                                   child:
          //                                                                       Text(
          //                                                                     'Transaction No: ',
          //                                                                     // textAlign: TextAlign.right,
          //                                                                     style: poppinsMedium.copyWith(
          //                                                                       fontSize: 14,
          //                                                                     ),
          //                                                                   ),
          //                                                                 ),
          //                                                               ),
          //                                                               Expanded(
          //                                                                 child:
          //                                                                     Container(
          //                                                                   height:
          //                                                                       36,
          //                                                                   decoration:
          //                                                                       BoxDecoration(borderRadius: BorderRadius.circular(7), border: Border.all(color: ColorTheme.borderGrey)),
          //                                                                   child:
          //                                                                       TextField(
          //                                                                     controller: _transactionNoController,
          //                                                                     autofocus: false,
          //                                                                     decoration: InputDecoration(
          //                                                                       // hintText: 'phone'.tr,
          //                                                                       contentPadding: EdgeInsets.symmetric(horizontal: 10),
          //                                                                       border: OutlineInputBorder(
          //                                                                         borderRadius: BorderRadius.circular(7),
          //                                                                         borderSide: BorderSide(style: BorderStyle.none, width: 0),
          //                                                                       ),
          //                                                                       hintStyle: poppinsMedium.copyWith(fontSize: 13, color: ColorTheme.hintText),
          //                                                                       fillColor: Colors.white,
          //                                                                     ),
          //                                                                     style: poppinsMedium.copyWith(
          //                                                                       color: Colors.black,
          //                                                                       fontSize: 13,
          //                                                                     ),
          //                                                                     onChanged: (value) async {},
          //                                                                   ),
          //                                                                 ),
          //                                                               ),
          //                                                             ],
          //                                                           ),
          //                                                         ),
          //                                                   posController
          //                                                               .selectedPaymentTab ==
          //                                                           2
          //                                                       ? Get.find<AuthController>()
          //                                                                   .profileModel!
          //                                                                   .restaurants!
          //                                                                   .first
          //                                                                   .upiId ==
          //                                                               ''
          //                                                           ? SizedBox
          //                                                               .shrink()
          //                                                           : Container(
          //                                                               margin: EdgeInsets.only(
          //                                                                   bottom:
          //                                                                       30),
          //                                                               child:
          //                                                                   QrImageView(
          //                                                                 data:
          //                                                                     'upi://pay?pa=${Get.find<AuthController>().profileModel!.restaurants!.first.upiId}&pn=&am=&tn=',
          //                                                                 version:
          //                                                                     QrVersions.auto,
          //                                                                 size:
          //                                                                     120,
          //                                                                 gapless:
          //                                                                     false,
          //                                                               ),
          //                                                             )
          //                                                       : SizedBox
          //                                                           .shrink(),
          //                                                   posController
          //                                                           .isLoading
          //                                                       ? CircularProgressIndicator()
          //                                                       : Align(
          //                                                           alignment:
          //                                                               Alignment
          //                                                                   .centerRight,
          //                                                           child:
          //                                                               InkWell(
          //                                                             onTap:
          //                                                                 () async {
          //                                                               FocusManager
          //                                                                   .instance
          //                                                                   .primaryFocus
          //                                                                   ?.unfocus();

          //                                                               if (_paidController
          //                                                                   .text
          //                                                                   .isEmpty) {
          //                                                                 showCustomSnackBar(
          //                                                                     'Please enter paid amount');
          //                                                               } else if (Get.find<PosController>().selectedPaymentTab ==
          //                                                                       1 &&
          //                                                                   _transactionNoController.text.isEmpty) {
          //                                                                 showErrorToast(
          //                                                                     'Please enter transaction number');
          //                                                               } else {
          //                                                                 Map<String, dynamic>
          //                                                                     jsonData =
          //                                                                     {
          //                                                                   'user_id':
          //                                                                       customer.id,
          //                                                                   'amount':
          //                                                                       double.parse(_paidController.text),
          //                                                                   'credit_mode': Get.find<PosController>().selectedPaymentTab == 0
          //                                                                       ? 'cash'
          //                                                                       : Get.find<PosController>().selectedPaymentTab == 1
          //                                                                           ? 'card'
          //                                                                           : 'upi',
          //                                                                 };

          //                                                                 await Get.find<CartController>().addMoneyWallet(
          //                                                                     jsonData,
          //                                                                     customer);
          //                                                                 Get.find<PosController>().setTapCustomerData(
          //                                                                     null,
          //                                                                     false);
          //                                                               }
          //                                                             },
          //                                                             child:
          //                                                                 Container(
          //                                                               margin: EdgeInsets.only(
          //                                                                   top:
          //                                                                       20,
          //                                                                   right:
          //                                                                       20),
          //                                                               padding: EdgeInsets.symmetric(
          //                                                                   vertical:
          //                                                                       8,
          //                                                                   horizontal:
          //                                                                       12),
          //                                                               decoration: BoxDecoration(
          //                                                                   borderRadius:
          //                                                                       BorderRadius.circular(7),
          //                                                                   color: ColorTheme.appColor),
          //                                                               child:
          //                                                                   Text(
          //                                                                 'Add Money',
          //                                                                 style: poppinsMedium.copyWith(
          //                                                                     fontSize: 13,
          //                                                                     color: Colors.white),
          //                                                               ),
          //                                                             ),
          //                                                           ),
          //                                                         ),
          //                                                 ],
          //                                               ),
          //                                             );
          //                                           }),
          //                                         ),
          //                                       ],
          //                                     )
          //                                   : SizedBox.shrink(),
          //                             ],
          //                           );
          //                         }),
          //                   ),
          //             // SizedBox(height: 10),
          //           ]);
          //     });
          //   }),
          // ),
        ),
      ),
    );
  }

  Widget manageCustomer(CustomerManagementController custController,
      PosController posController) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Container(
          height: 36,
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            autofocus: false,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  horizontal: Dimensions.PADDING_SIZE_DEFAULT),
              suffixIcon:
                  Icon(Icons.search, size: 22, color: ColorTheme.appColor),
              hintText: 'Search by phone / name ',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: ColorTheme.borderGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: ColorTheme.borderGrey),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: ColorTheme.borderGrey),
              ),
              hintStyle: poppinsMedium.copyWith(
                  fontSize: 13, color: ColorTheme.hintText),
              filled: true,
              fillColor: Colors.white,
            ),
            style: poppinsRegular.copyWith(
              color: Colors.black,
              fontSize: 13,
            ),
            onChanged: (value) async {
              if (_searchController.text.isEmpty) {
                posController.clearTapCustomerData();
              }
              posController.update();
            },
          ),
        ),
      ),
      SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Phone',
                style: poppinsSemiBold.copyWith(
                  color: ColorTheme.appColor,
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 14 : 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Name',
                style: poppinsSemiBold.copyWith(
                  color: ColorTheme.appColor,
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 14 : 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Wallet Balance',
                style: poppinsSemiBold.copyWith(
                  color: ColorTheme.appColor,
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 14 : 10,
                ),
              ),
            ),
            SizedBox(width: 36),
            if (Get.find<AuthController>()
                .profileModel!
                .role!
                .contains('virtual_wallet'))
              SizedBox(width: 36),
          ],
        ),
      ),
      SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
      custController.customerListModel == null
          ? SizedBox.shrink()
          : Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                    itemCount:
                        custController.customerListModel?.customerList.length ??
                            0,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int i) {
                      CustomerList customer =
                          custController.customerListModel!.customerList[i];
                      double balance = customer.virtualWalletBal;

                      return Column(
                        children: [
                          _searchController.text.isEmpty
                              ? customerItem(customer, i)
                              : (customer.customerName.toLowerCase().contains(
                                          _searchController.text
                                              .toLowerCase())) ||
                                      customer.phone
                                          .toString()
                                          .toLowerCase()
                                          .contains(_searchController.text
                                              .toLowerCase())
                                  ? customerItem(customer, i)
                                  : SizedBox.shrink(),
                          posController.isShowCustomerData &&
                                  posController.selectedCustomerIndex == i
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 7, right: 7, top: 15),
                                      child: DottedLine(
                                        direction: Axis.horizontal,
                                        alignment: WrapAlignment.center,
                                        lineThickness: 1.0,
                                        dashLength: 2.5,
                                        dashColor: ColorTheme.hintText,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: Dimensions.PADDING_SIZE_DEFAULT,
                                        bottom: Dimensions.PADDING_SIZE_SMALL,
                                        left: 7,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Select Payment Method',
                                          textAlign: TextAlign.right,
                                          style: poppinsSemiBold.copyWith(
                                            fontSize: 15,
                                            // color: Color.fromRGBO(112, 112, 112, 1.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.PADDING_SIZE_DEFAULT),
                                      child: GetBuilder<PosController>(
                                          builder: (posController) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20),
                                          decoration: BoxDecoration(
                                              color: Color(0xFFF8F8F8),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () {
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();

                                                          posController
                                                              .setPaymentTabIndex(
                                                                  0);
                                                        },
                                                        child: Container(
                                                          width: Get.width,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      Dimensions
                                                                          .PADDING_SIZE_EXTRA_SMALL),
                                                          decoration:
                                                              BoxDecoration(
                                                                  border: Border.all(
                                                                      color: posController.selectedPaymentTab == 0
                                                                          ? Colors
                                                                              .transparent
                                                                          : ColorTheme
                                                                              .borderGrey),
                                                                  color: posController
                                                                              .selectedPaymentTab ==
                                                                          0
                                                                      ? ColorTheme
                                                                          .appColor
                                                                      : Colors
                                                                          .white,
                                                                  // border:
                                                                  //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              7)),
                                                          child: Center(
                                                            child: Text(
                                                              'Cash'.tr,
                                                              style: poppinsMedium.copyWith(
                                                                  fontSize: 13,
                                                                  color: posController
                                                                              .selectedPaymentTab ==
                                                                          0
                                                                      ? Colors
                                                                          .white
                                                                      : ColorTheme
                                                                          .appColor),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () {
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();

                                                          posController
                                                              .setPaymentTabIndex(
                                                                  1);
                                                        },
                                                        child: Container(
                                                          width: Get.width,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      Dimensions
                                                                          .PADDING_SIZE_EXTRA_SMALL),
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: posController
                                                                              .selectedPaymentTab ==
                                                                          1
                                                                      ? Colors
                                                                          .transparent
                                                                      : ColorTheme
                                                                          .borderGrey),
                                                              color: posController
                                                                          .selectedPaymentTab ==
                                                                      1
                                                                  ? ColorTheme
                                                                      .appColor
                                                                  : Colors
                                                                      .white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7)),
                                                          child: Center(
                                                            child: Text(
                                                              'Card'.tr,
                                                              style: poppinsMedium.copyWith(
                                                                  fontSize: 13,
                                                                  color: posController
                                                                              .selectedPaymentTab ==
                                                                          1
                                                                      ? Colors
                                                                          .white
                                                                      : ColorTheme
                                                                          .appColor),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () {
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();

                                                          posController
                                                              .setPaymentTabIndex(
                                                                  2);
                                                        },
                                                        child: Container(
                                                          width: Get.width,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      Dimensions
                                                                          .PADDING_SIZE_EXTRA_SMALL),
                                                          decoration:
                                                              BoxDecoration(
                                                                  border: Border.all(
                                                                      color: posController.selectedPaymentTab == 2
                                                                          ? Colors
                                                                              .transparent
                                                                          : ColorTheme
                                                                              .borderGrey),
                                                                  color: posController
                                                                              .selectedPaymentTab ==
                                                                          2
                                                                      ? ColorTheme
                                                                          .appColor
                                                                      : Colors
                                                                          .white,

                                                                  // border:
                                                                  //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              7)),
                                                          child: Center(
                                                            child: Text(
                                                              'UPI'.tr,
                                                              style: poppinsMedium.copyWith(
                                                                  fontSize: 13,
                                                                  color: posController
                                                                              .selectedPaymentTab ==
                                                                          2
                                                                      ? Colors
                                                                          .white
                                                                      : ColorTheme
                                                                          .appColor),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(child: SizedBox()),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15),
                                                child: DottedLine(
                                                  direction: Axis.horizontal,
                                                  alignment:
                                                      WrapAlignment.center,
                                                  lineThickness: 1.0,
                                                  dashLength: 2.5,
                                                  dashColor:
                                                      ColorTheme.hintText,
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15),
                                                margin: EdgeInsets.only(
                                                    top: 10, bottom: 10),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'Add money: ',
                                                          // textAlign: TextAlign.right,
                                                          style: poppinsMedium
                                                              .copyWith(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        height: 36,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7),
                                                            border: Border.all(
                                                                color: ColorTheme
                                                                    .borderGrey)),
                                                        child: TextField(
                                                          controller:
                                                              _paidController,
                                                          autofocus: false,
                                                          keyboardType:
                                                              TextInputType
                                                                  .numberWithOptions(
                                                                      signed:
                                                                          true),
                                                          decoration:
                                                              InputDecoration(
                                                            // hintText: 'phone'.tr,
                                                            contentPadding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            10),
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7),
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
                                                                    color: ColorTheme
                                                                        .hintText),
                                                            filled: true,
                                                            fillColor:
                                                                Colors.white,
                                                          ),
                                                          style: poppinsMedium
                                                              .copyWith(
                                                            color: Colors.black,
                                                            fontSize: 13,
                                                          ),
                                                          onChanged:
                                                              (value) async {
                                                            posController
                                                                .update();
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15),
                                                margin: EdgeInsets.only(
                                                    top: 10, bottom: 10),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'Balance: ',
                                                          // textAlign: TextAlign.right,
                                                          style: poppinsMedium
                                                              .copyWith(
                                                                  fontSize: 14),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                          height: 36,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7),
                                                              border: Border.all(
                                                                  color: ColorTheme
                                                                      .borderGrey)),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              '   ' +
                                                                  (balance
                                                                      .toStringAsFixed(
                                                                          2)),
                                                              style:
                                                                  poppinsMedium
                                                                      .copyWith(
                                                                color: ColorTheme
                                                                    .hintText,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              posController.selectedPaymentTab ==
                                                          0 ||
                                                      posController
                                                              .selectedPaymentTab ==
                                                          2
                                                  ? SizedBox.shrink()
                                                  : Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 15),
                                                      margin: EdgeInsets.only(
                                                        top: Dimensions
                                                            .PADDING_SIZE_LARGE,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                'Transaction No: ',
                                                                // textAlign: TextAlign.right,
                                                                style:
                                                                    poppinsMedium
                                                                        .copyWith(
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              height: 36,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              7),
                                                                  border: Border.all(
                                                                      color: ColorTheme
                                                                          .borderGrey)),
                                                              child: TextField(
                                                                controller:
                                                                    _transactionNoController,
                                                                autofocus:
                                                                    false,
                                                                decoration:
                                                                    InputDecoration(
                                                                  // hintText: 'phone'.tr,
                                                                  contentPadding:
                                                                      EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              10),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(7),
                                                                    borderSide: BorderSide(
                                                                        style: BorderStyle
                                                                            .none,
                                                                        width:
                                                                            0),
                                                                  ),
                                                                  hintStyle: poppinsMedium.copyWith(
                                                                      fontSize:
                                                                          13,
                                                                      color: ColorTheme
                                                                          .hintText),
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                                style:
                                                                    poppinsMedium
                                                                        .copyWith(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 13,
                                                                ),
                                                                onChanged:
                                                                    (value) async {},
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                              posController
                                                          .selectedPaymentTab ==
                                                      2
                                                  ? Get.find<AuthController>()
                                                              .profileModel!
                                                              .restaurants!
                                                              .first
                                                              .upiId ==
                                                          ''
                                                      ? SizedBox.shrink()
                                                      : Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  bottom: 30),
                                                          child: QrImageView(
                                                            data:
                                                                'upi://pay?pa=${Get.find<AuthController>().profileModel!.restaurants!.first.upiId}&pn=&am=&tn=',
                                                            version:
                                                                QrVersions.auto,
                                                            size: 120,
                                                            gapless: false,
                                                          ),
                                                        )
                                                  : SizedBox.shrink(),
                                              posController.isLoading
                                                  ? CircularProgressIndicator()
                                                  : Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: InkWell(
                                                        onTap: () async {
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();

                                                          if (_paidController
                                                              .text.isEmpty) {
                                                            showCustomSnackBar(
                                                                'Please enter paid amount');
                                                          } else if (Get.find<
                                                                          PosController>()
                                                                      .selectedPaymentTab ==
                                                                  1 &&
                                                              _transactionNoController
                                                                  .text
                                                                  .isEmpty) {
                                                            showErrorToast(
                                                                'Please enter transaction number');
                                                          } else {
                                                            Map<String, dynamic>
                                                                jsonData = {
                                                              'user_id':
                                                                  customer.id,
                                                              'amount': double.parse(
                                                                  _paidController
                                                                      .text),
                                                              'credit_mode': Get.find<
                                                                              PosController>()
                                                                          .selectedPaymentTab ==
                                                                      0
                                                                  ? 'cash'
                                                                  : Get.find<PosController>()
                                                                              .selectedPaymentTab ==
                                                                          1
                                                                      ? 'card'
                                                                      : 'upi',
                                                            };

                                                            await Get.find<
                                                                    CartController>()
                                                                .addMoneyWallet(
                                                                    jsonData,
                                                                    customer);
                                                            Get.find<
                                                                    PosController>()
                                                                .setTapCustomerData(
                                                                    null,
                                                                    false);
                                                          }
                                                        },
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 20,
                                                                  right: 20),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 8,
                                                                  horizontal:
                                                                      12),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7),
                                                              color: ColorTheme
                                                                  .appColor),
                                                          child: Text(
                                                            'Add Money',
                                                            style: poppinsMedium
                                                                .copyWith(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .white),
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
                                )
                              : SizedBox.shrink(),
                        ],
                      );
                    }),
              ),
            ),
      // SizedBox(height: 10),
    ]);
  }

  void callback(bool isSuccess, String message) async {
    if (isSuccess) {
      Get.back();

      showErrorToast(message, isError: false);
      Get.find<PosController>().clearTapCustomerData();
      Get.find<PosController>().getTapManageMentCustomerList();
    } else {
      showErrorToast(message);
    }
  }

  Widget customerItem(CustomerList customer, int i) {
    return Padding(
      padding: EdgeInsets.only(top: i == 0 ? 0 : 13),
      child: Container(
        padding: const EdgeInsets.only(top: 7, bottom: 7, left: 12, right: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: const Color(0xFFF8F8F8),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                '${customer.phone}',
                style: poppinsMedium.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 13 : 10,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${customer.customerName}',
                style: poppinsMedium.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 13 : 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                customer.virtualWalletBal.toStringAsFixed(2),
                style: poppinsMedium.copyWith(
                  color: Colors.black,
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 14 : 10,
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                customerSuggestion.text = customer.customerName;
                customerPhoneSuggestion.text = customer.phone;
                gstNameController.text = customer.gstName;
                gstNumberController.text = customer.gstNo;
                dateController.text = customer.dateOfBirth;
                aniversaryDateController.text = customer.dateOfAnniversary;
                _selectedDropdownOption = customer.membershipId;
                isEdit = true;
                Get.find<CustomerManagementController>().updateTapIndex(0);
              },
              child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 10),
                  child: Icon(
                    Icons.edit_rounded,
                    color: ColorTheme.appColor,
                  )),
            ),
            if (Get.find<AuthController>()
                .profileModel!
                .role!
                .contains('virtual_wallet'))
              InkWell(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Get.find<PosController>().setTapCustomerData(i, true);
                  _paidController.text = '0';
                },
                child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 10),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: ColorTheme.appColor,
                    )),
              ),
          ],
        ),
      ),
    );
  }

  Widget addCustomer(CustomerManagementController custController,
      PosController posController) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TypeAheadField<String>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: customerSuggestion,
                style: montserratMedium.copyWith(
                  color: ColorTheme.grey74,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  labelStyle: montserratMedium.copyWith(
                    color: ColorTheme.grey74,
                    fontSize: 14,
                  ),
                  // Border styling
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: Color(0xFFDCDCDC)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: Color(0xFFDCDCDC)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      borderSide: BorderSide(color: Color(0xFFDCDCDC))),

                  // contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: ColorTheme.whiteColor, // Background color
                ),
                onChanged: (value) {
                  custController.update(); // Rebuild suggestions
                },
              ),
              suggestionsCallback: (pattern) {
                if (pattern.isEmpty) {
                  return [];
                }

                final suggestions = custController
                    .customerListModel!.customerList
                    .where((element) => element.customerName
                        .toLowerCase()
                        .contains(pattern.toLowerCase()))
                    .map((e) => e.customerName.toString())
                    .toSet()
                    .toList();

                // Agar kuch match nahi mila toh "Add" option show karo
                if (suggestions.isEmpty) {
                  return ["Add $pattern"];
                }

                return suggestions;
              },
              noItemsFoundBuilder: (context) {
                return Container(
                  padding: EdgeInsets.all(8),
                  child: Text("No results found"),
                );
              },
              loadingBuilder: (context) {
                return Container(
                  padding: EdgeInsets.all(8),
                  child: Text("Loading..."),
                );
              },
              debounceDuration: Duration(milliseconds: 300),
              hideOnEmpty: true,
              hideOnLoading: false,
              itemBuilder: (context, String suggestion) {
                final isAddOption = suggestion.startsWith("Add ");

                return ListTile(
                  leading: isAddOption
                      ? Icon(Icons.add_circle_outline,
                          size: 18, color: ColorTheme.grey8C)
                      : SizedBox.shrink(),
                  title: Text(
                    suggestion,
                    style: montserratMedium.copyWith(
                      fontSize: 14,
                      color: ColorTheme.grey74,
                      fontWeight:
                          isAddOption ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  tileColor: isAddOption
                      ? ColorTheme.white.withOpacity(0.1)
                      : Colors.transparent,
                  dense: true,
                );
              },
              onSuggestionSelected: (String suggestion) {
                if (suggestion.startsWith("Add ")) {
                  final customValue = suggestion.replaceFirst("Add ", "");
                  customerSuggestion.text = customValue;
                } else {
                  customerSuggestion.text = suggestion;
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  enabled: !isEdit,
                  controller: customerPhoneSuggestion,
                  style: montserratMedium.copyWith(
                    color: ColorTheme.grey74,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: montserratMedium.copyWith(
                      color: ColorTheme.grey74,
                      fontSize: 14,
                    ),
                    // Border styling
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      borderSide: BorderSide(color: Color(0xFFDCDCDC)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      borderSide: BorderSide(color: Color(0xFFDCDCDC)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        borderSide: BorderSide(color: Color(0xFFDCDCDC))),

                    // contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: ColorTheme.whiteColor, // Background color
                  ),
                  onChanged: (value) {
                    custController.update(); // Rebuild suggestions
                  },
                ),
                suggestionsCallback: (pattern) {
                  return custController.customerListModel!.customerList
                      .where((item) => item.phone
                          .toString()
                          .trim()
                          .toLowerCase()
                          .contains(pattern.toLowerCase().trim()))
                      .toList();
                },
                noItemsFoundBuilder: (context) => SizedBox.shrink(),
                getImmediateSuggestions: true,
                itemBuilder: (context, CustomerList suggestion) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12, left: 20),
                    child: Text(
                      suggestion.phone,
                      style: montserratMedium.copyWith(
                        fontSize: 14,
                        color: ColorTheme.grey74,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  );
                },
                onSuggestionSelected: (CustomerList suggestion) {
                  customerPhoneSuggestion.text = suggestion.phone;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: CustomTextformField(
                controller: dateController,
                labelText: 'DOB',
                keyboardType: TextInputType.none,
                readOnly: true,
                suffixIcon: Icon(
                  Icons.calendar_today,
                  color: ColorTheme.greyColor.withOpacity(0.5),
                  size: 17,
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate:
                        // widget.isEdit
                        //     ? DateFormat('dd/MM/yyyy')
                        //         .parse(widget.expense!['Date & Time'])
                        //     :
                        DateTime.now(),
                    firstDate: DateTime(1800),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    dateController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: CustomTextformField(
                controller: aniversaryDateController,
                labelText: 'Date of Anniversary',
                keyboardType: TextInputType.none,
                readOnly: true,
                suffixIcon: Icon(
                  Icons.calendar_today,
                  color: ColorTheme.greyColor.withOpacity(0.5),
                  size: 17,
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate:
                        // widget.isEdit
                        //     ? DateFormat('dd/MM/yyyy')
                        //         .parse(widget.expense!['Date & Time'])
                        //     :
                        DateTime.now(),
                    firstDate: DateTime(1800),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    aniversaryDateController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: CustomTextformField(
                controller: gstNameController,
                labelText: 'GST Name',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: CustomTextformField(
                controller: gstNumberController,
                labelText: 'GST Number',
              ),
            ),
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
                      // height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(70),
                        border: Border.all(color: ColorTheme.borderGrey),
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
                                value: _selectedDropdownOption,
                                hint: Text(
                                  'Select', //Select Designation
                                  style: montserratMedium.copyWith(
                                    fontSize: 14,
                                    color: ColorTheme.grey74,
                                  ),
                                ),
                                isExpanded: true,
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: ColorTheme.grey74,
                                ),
                                style: montserratMedium.copyWith(
                                  color: ColorTheme.grey74,
                                  fontSize: 14,
                                ),
                                items: activeDesignations.isEmpty
                                    ? [
                                        DropdownMenuItem(
                                          value: null,
                                          enabled: false,
                                          child: Text(
                                            'No designation available',
                                            style: montserratMedium.copyWith(
                                              fontSize: 14,
                                              color: ColorTheme.grey74,
                                            ),
                                          ),
                                        ),
                                      ]
                                    : activeDesignations
                                        .map<DropdownMenuItem<String>>(
                                        (designation) {
                                          final designationName =
                                              designation['designation']
                                                      as String? ??
                                                  '';
                                          return DropdownMenuItem(
                                            value: designationName,
                                            child: Text(
                                              designationName,
                                              style: montserratMedium.copyWith(
                                                fontSize: 14,
                                                color: ColorTheme.grey74,
                                              ),
                                            ),
                                          );
                                        },
                                      ).toList(),
                                onChanged: activeDesignations.isEmpty
                                    ? null
                                    : (value) {
                                        setDropdownState(() {
                                          _selectedDropdownOption = value;
                                        });
                                      },
                              ),
                            ),
                    );
                  },
                );
              },
            ),

            // if (!isEdit)
            // Padding(
            //   padding: const EdgeInsets.only(top: 15),
            //   child: CustomTextformField(
            //     controller: walletAmount,
            //     labelText: 'Add Wallet Amount',
            //     keyboardType: TextInputType.number,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: GestureDetector(
                onTap: () async {
                  if (customerPhoneSuggestion.text.isEmpty) {
                    showErrorToast('Please enter customer phone number');
                  } else if (customerPhoneSuggestion.text.length < 10) {
                    showErrorToast('Minimum required 10 digit phone number');
                  } else {
                    var userId = await custController.changeCustomerDetail({
                      "phone": customerPhoneSuggestion.text ?? '',
                      "f_name": customerSuggestion.text ?? '',
                      "l_name": "",
                      "email": "",
                      "gst_number": gstNumberController.text ?? '',
                      "gst_name": gstNameController.text ?? '',
                      "date_of_birth": dateController.text ?? '',
                      "date_of_anniversary":
                          aniversaryDateController.text ?? '',
                      "membership_id": _selectedDropdownOption ?? '',
                    }, (bool value) async {
                      Get.back();
                      if (value) {
                        customerPhoneSuggestion.clear();
                        walletAmount.clear();
                        customerSuggestion.clear();
                        gstNumberController.clear();
                        gstNameController.clear();
                        dateController.clear();
                        _selectedDropdownOption = null;
                        aniversaryDateController.clear();
                        custController.updateTapIndex(1);
                        posController.clearTapCustomerData();

                        // if (isEdit
                        // ||
                        //     (!Get.find<AuthController>()
                        //         .profileModel!
                        //         .role!
                        //         .contains('virtual_wallet'))
                        // )
                        await custController.getCustomerFromApiModel();
                      }
                    });
                    // if (userId != '' &&
                    //     !isEdit &&
                    //     Get.find<AuthController>()
                    //         .profileModel!
                    //         .role!
                    //         .contains('virtual_wallet')) {
                    //   Map<String, dynamic> jsonData = {
                    //     'user_id': userId,
                    //     'amount': walletAmount.text,
                    //     'credit_mode': 'cash'
                    //   };

                    //   await Get.find<CartController>()
                    //       .addMoneyWallet(jsonData, null);
                    //   await custController.getCustomerFromApiModel();
                    // }
                  }
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: ColorTheme.greenColor,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Submit',
                    style: montserratMedium.copyWith(
                      fontSize: 14,
                      color: ColorTheme.whiteColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
