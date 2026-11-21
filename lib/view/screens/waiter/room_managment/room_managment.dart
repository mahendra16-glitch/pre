import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_room_list_with_amount_response_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/pos/widget/bottom_cart_widget.dart';
import 'package:mygenie_restaurant/view/screens/waiter/room_managment/widget/customer_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RoomManagementPage extends StatefulWidget {
  @override
  State<RoomManagementPage> createState() => _RoomManagementPageState();
}

class _RoomManagementPageState extends State<RoomManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  TextEditingController _transactionNoController = TextEditingController();
  TextEditingController _paidController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    Get.find<PosController>().setPaymentTabIndex(0);
    await Get.find<PosController>().getRoomListWithAmount();
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
              icon: Image.asset(Images.ic_arrow_back, height: 20),
              color: ColorTheme.appColor,
              onPressed: () {
                Get.find<PosController>().clearTapCustomerData();
                Get.back();
              }),
          titleSpacing: 0,
          elevation: 0,
          centerTitle: true,
          title: Column(
            children: [
              Image.asset(logoHelper.appLogo!, width: Get.width * 0.5),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                    physics: BouncingScrollPhysics(),
                    child: Center(
                      child: SizedBox(
                        child:
                            GetBuilder<PosController>(builder: (posController) {
                          return Column(children: [
                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                            Text(
                              'Room Management',
                              style: poppinsMedium.copyWith(
                                  fontSize: Dimensions.FONT_SIZE_OVER_LARGE),
                            ),

                            SizedBox(height: Get.height * 0.05),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    textInputAction: TextInputAction.search,
                                    autofocus: false,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.PADDING_SIZE_DEFAULT),
                                      suffixIcon: Icon(Icons.search,
                                          color: ColorTheme.appColor),
                                      hintText: 'Search room',
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.RADIUS_LARGE),
                                        borderSide: BorderSide(
                                            color: Color.fromRGBO(
                                                229, 229, 229, 1.0)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.RADIUS_LARGE),
                                        borderSide: BorderSide(
                                            color: Color.fromRGBO(
                                                229, 229, 229, 1.0)),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.RADIUS_LARGE),
                                        borderSide: BorderSide(
                                            color: Color.fromRGBO(
                                                229, 229, 229, 1.0)),
                                      ),
                                      hintStyle: poppinsRegular.copyWith(
                                          fontSize: 11,
                                          color: Theme.of(context).hintColor),
                                      filled: true,
                                      fillColor: Theme.of(context).cardColor,
                                    ),
                                    style: poppinsRegular.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color,
                                      fontSize: 11,
                                    ),
                                    onChanged: (value) async {
                                      if (_searchController.text.isEmpty) {
                                        posController.clearTapCustomerData();
                                      }
                                      posController.update();
                                    },
                                  ),
                                ),
                                // SizedBox(width: 10),
                                // Container(
                                //   // height: 30,
                                //   width: Get.width * 0.3,
                                //   padding: EdgeInsets.symmetric(
                                //       horizontal:
                                //           Dimensions.PADDING_SIZE_SMALL),
                                //   decoration: BoxDecoration(
                                //     border: Border.all(
                                //         color:
                                //             Color.fromRGBO(229, 229, 229, 1.0)),
                                //     color: Theme.of(context).cardColor,
                                //     borderRadius: BorderRadius.circular(15),
                                //   ),
                                //   child: DropdownButton<String>(
                                //     isExpanded: true,
                                //     value: selectedFilter,
                                //     items: filterList.map((String value) {
                                //       return DropdownMenuItem<String>(
                                //         value: value,
                                //         child: Text(
                                //           '$value',
                                //           maxLines: 1,
                                //           style: poppinsRegular.copyWith(
                                //             fontSize:
                                //                 Dimensions.FONT_SIZE_SMALL,
                                //           ),
                                //         ),
                                //       );
                                //     }).toList(),
                                //     onChanged: (String value) {
                                //       selectedFilter = value;
                                //       posController.update();
                                //     },
                                //     underline: SizedBox(),
                                //   ),
                                // )
                              ],
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                            ListView.builder(
                                itemCount:
                                    posController.roomListWithAmount.length ??
                                        0,
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (BuildContext context, int i) {
                                  RoomListWithAmountResponseModel room =
                                      posController.roomListWithAmount[i];

                                  return Column(
                                    children: [
                                      _searchController.text.isEmpty
                                          ? RoomCustomerItem(
                                              i: i, controller: _paidController)
                                          : (room.roomName
                                                  .toLowerCase()
                                                  .contains(_searchController
                                                      .text
                                                      .toLowerCase()))
                                              ? RoomCustomerItem(
                                                  i: i,
                                                  controller: _paidController)
                                              : SizedBox.shrink(),
                                      posController.isShowCustomerData &&
                                              posController
                                                      .selectedCustomerIndex ==
                                                  i
                                          ? Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 7,
                                                      right: 7,
                                                      top: 15),
                                                  child: Divider(
                                                      color: Colors.grey),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    top: Dimensions
                                                        .PADDING_SIZE_DEFAULT,
                                                    bottom: Dimensions
                                                        .PADDING_SIZE_SMALL,
                                                    left: 7,
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Select Payment Method',
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: poppinsMedium
                                                          .copyWith(
                                                        fontSize: Dimensions
                                                            .FONT_SIZE_SMALL,
                                                        // color: Color.fromRGBO(112, 112, 112, 1.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: Dimensions
                                                          .PADDING_SIZE_DEFAULT),
                                                  child:
                                                      GetBuilder<PosController>(
                                                          builder:
                                                              (posController) {
                                                    return Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: InkWell(
                                                                splashColor: Colors
                                                                    .transparent,
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                onTap: () {
                                                                  FocusManager
                                                                      .instance
                                                                      .primaryFocus
                                                                      ?.unfocus();

                                                                  posController
                                                                      .setPaymentTabIndex(
                                                                          0);
                                                                },
                                                                child:
                                                                    Container(
                                                                  width:
                                                                      Get.width,
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              10),
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(color: posController.selectedPaymentTab == 0 ? Colors.transparent : Theme.of(context).hintColor),
                                                                      color: posController.selectedPaymentTab == 0 ? ColorTheme.appColor : Colors.white,
                                                                      // border:
                                                                      //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                                                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
                                                                  child: Center(
                                                                    child: Text(
                                                                      'Cash'.tr,
                                                                      style: poppinsRegular.copyWith(
                                                                          fontSize: Dimensions
                                                                              .FONT_SIZE_EXTRA_SMALL,
                                                                          color: posController.selectedPaymentTab == 0
                                                                              ? Colors.white
                                                                              : Colors.black),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: InkWell(
                                                                splashColor: Colors
                                                                    .transparent,
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                onTap: () {
                                                                  FocusManager
                                                                      .instance
                                                                      .primaryFocus
                                                                      ?.unfocus();

                                                                  posController
                                                                      .setPaymentTabIndex(
                                                                          1);
                                                                },
                                                                child:
                                                                    Container(
                                                                  width:
                                                                      Get.width,
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              10),
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: posController.selectedPaymentTab == 1
                                                                              ? Colors
                                                                                  .transparent
                                                                              : Theme.of(context)
                                                                                  .hintColor),
                                                                      color: posController.selectedPaymentTab == 1
                                                                          ? ColorTheme
                                                                              .appColor
                                                                          : Colors
                                                                              .white,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              Dimensions.RADIUS_DEFAULT)),
                                                                  child: Center(
                                                                    child: Text(
                                                                      'Card'.tr,
                                                                      style: poppinsRegular.copyWith(
                                                                          fontSize: Dimensions
                                                                              .FONT_SIZE_EXTRA_SMALL,
                                                                          color: posController.selectedPaymentTab == 1
                                                                              ? Colors.white
                                                                              : Colors.black),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: InkWell(
                                                                splashColor: Colors
                                                                    .transparent,
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                onTap: () {
                                                                  FocusManager
                                                                      .instance
                                                                      .primaryFocus
                                                                      ?.unfocus();

                                                                  posController
                                                                      .setPaymentTabIndex(
                                                                          2);
                                                                },
                                                                child:
                                                                    Container(
                                                                  width:
                                                                      Get.width,
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              10),
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(color: posController.selectedPaymentTab == 2 ? Colors.transparent : Theme.of(context).hintColor),
                                                                      color: posController.selectedPaymentTab == 2 ? ColorTheme.appColor : Colors.white,

                                                                      // border:
                                                                      //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                                                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
                                                                  child: Center(
                                                                    child: Text(
                                                                      'UPI'.tr,
                                                                      style: poppinsRegular.copyWith(
                                                                          fontSize: Dimensions
                                                                              .FONT_SIZE_EXTRA_SMALL,
                                                                          color: posController.selectedPaymentTab == 2
                                                                              ? Colors.white
                                                                              : Colors.black),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                                child:
                                                                    SizedBox()),
                                                          ],
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets.only(
                                                              top: Dimensions
                                                                  .PADDING_SIZE_LARGE,
                                                              bottom: 10),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 2,
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerRight,
                                                                  child: Text(
                                                                    'Total payable:    ',
                                                                    // textAlign: TextAlign.right,
                                                                    style: poppinsMedium
                                                                        .copyWith(
                                                                      fontSize:
                                                                          10,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 3,
                                                                child:
                                                                    Container(
                                                                        height:
                                                                            30,
                                                                        margin: EdgeInsets.only(
                                                                            right: Get.width *
                                                                                0.25),
                                                                        decoration: BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                            border: Border.all(color: Color.fromRGBO(229, 229, 229, 1.0))),
                                                                        child: Align(
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          child:
                                                                              Text(
                                                                            '  ${Get.find<PosController>().roomListWithAmount[i].orderAmount}',
                                                                            style:
                                                                                poppinsRegular.copyWith(
                                                                              color: Theme.of(context).textTheme.bodyLarge!.color,
                                                                              fontSize: Dimensions.FONT_SIZE_SMALL,
                                                                            ),
                                                                          ),
                                                                        )),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        // Container(
                                                        //   margin:
                                                        //       EdgeInsets.only(
                                                        //           top: 10,
                                                        //           bottom: 10),
                                                        //   child: Row(
                                                        //     children: [
                                                        //       Expanded(
                                                        //         flex: 2,
                                                        //         child: Align(
                                                        //           alignment:
                                                        //               Alignment
                                                        //                   .centerRight,
                                                        //           child: Text(
                                                        //             'Paid:    ',
                                                        //             // textAlign: TextAlign.right,
                                                        //             style: poppinsMedium
                                                        //                 .copyWith(
                                                        //               fontSize:
                                                        //                   10,
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //       ),
                                                        //       Expanded(
                                                        //         flex: 3,
                                                        //         child:
                                                        //             Container(
                                                        //           height: 30,
                                                        //           margin: EdgeInsets.only(
                                                        //               right: Get
                                                        //                       .width *
                                                        //                   0.25),
                                                        //           decoration: BoxDecoration(
                                                        //               borderRadius:
                                                        //                   BorderRadius.circular(
                                                        //                       10),
                                                        //               border: Border.all(
                                                        //                   color: Color.fromRGBO(
                                                        //                       229,
                                                        //                       229,
                                                        //                       229,
                                                        //                       1.0))),
                                                        //           child:
                                                        //               TextField(
                                                        //             controller:
                                                        //                 _paidController,
                                                        //             autofocus:
                                                        //                 false,
                                                        //             keyboardType:
                                                        //                 TextInputType
                                                        //                     .number,
                                                        //             decoration:
                                                        //                 InputDecoration(
                                                        //               // hintText: 'phone'.tr,
                                                        //               contentPadding:
                                                        //                   EdgeInsets.symmetric(
                                                        //                       horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                        //               border:
                                                        //                   OutlineInputBorder(
                                                        //                 borderRadius:
                                                        //                     BorderRadius.circular(10),
                                                        //                 borderSide: BorderSide(
                                                        //                     style:
                                                        //                         BorderStyle.none,
                                                        //                     width: 0),
                                                        //               ),
                                                        //               hintStyle: poppinsRegular.copyWith(
                                                        //                   fontSize: Dimensions
                                                        //                       .FONT_SIZE_SMALL,
                                                        //                   color:
                                                        //                       Theme.of(context).hintColor),
                                                        //               filled:
                                                        //                   true,
                                                        //               fillColor:
                                                        //                   Theme.of(context)
                                                        //                       .cardColor,
                                                        //             ),
                                                        //             style: poppinsRegular
                                                        //                 .copyWith(
                                                        //               color: Theme.of(
                                                        //                       context)
                                                        //                   .textTheme
                                                        //                   .bodyLarge
                                                        //                   .color,
                                                        //               fontSize:
                                                        //                   Dimensions
                                                        //                       .FONT_SIZE_SMALL,
                                                        //             ),
                                                        //             onChanged:
                                                        //                 (value) async {
                                                        //               posController
                                                        //                   .update();
                                                        //             },
                                                        //           ),
                                                        //         ),
                                                        //       ),
                                                        //     ],
                                                        //   ),
                                                        // ),
                                                        // Container(
                                                        //   margin:
                                                        //       EdgeInsets.only(
                                                        //           top: 10,
                                                        //           bottom: 10),
                                                        //   child: Row(
                                                        //     children: [
                                                        //       Expanded(
                                                        //         flex: 2,
                                                        //         child: Align(
                                                        //           alignment:
                                                        //               Alignment
                                                        //                   .centerRight,
                                                        //           child: Text(
                                                        //             'Balance:    ',
                                                        //             // textAlign: TextAlign.right,
                                                        //             style: poppinsMedium
                                                        //                 .copyWith(
                                                        //               fontSize:
                                                        //                   10,
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //       ),
                                                        //       Expanded(
                                                        //         flex: 3,
                                                        //         child:
                                                        //             Container(
                                                        //                 margin: EdgeInsets.only(
                                                        //                     right: Get.width *
                                                        //                         0.25),
                                                        //                 height:
                                                        //                     30,
                                                        //                 decoration: BoxDecoration(
                                                        //                     borderRadius:
                                                        //                         BorderRadius.circular(10),
                                                        //                     border: Border.all(color: Color.fromRGBO(229, 229, 229, 1.0))),
                                                        //                 child: Align(
                                                        //                   alignment:
                                                        //                       Alignment.centerLeft,
                                                        //                   child:
                                                        //                       Text(
                                                        //                     double.parse('  ${(double.parse(Get.find<PosController>().roomListWithAmount[i].orderAmount) - (double.parse(_paidController.text.isEmpty ? '0' : _paidController.text)))}').toStringAsFixed(2),
                                                        //                     style:
                                                        //                         poppinsRegular.copyWith(
                                                        //                       color: Theme.of(context).textTheme.bodyLarge.color,
                                                        //                       fontSize: Dimensions.FONT_SIZE_SMALL,
                                                        //                     ),
                                                        //                   ),
                                                        //                 )),
                                                        //       ),
                                                        //     ],
                                                        //   ),
                                                        // ),
                                                        Container(
                                                          margin: EdgeInsets.only(
                                                              top: Dimensions
                                                                  .PADDING_SIZE_LARGE,
                                                              bottom: posController
                                                                          .selectedPaymentTab ==
                                                                      2
                                                                  ? 10
                                                                  : Get.height *
                                                                      0.1),
                                                          child: posController
                                                                      .selectedPaymentTab ==
                                                                  0
                                                              ? SizedBox
                                                                  .shrink()
                                                              : Row(
                                                                  children: [
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child:
                                                                          Align(
                                                                        alignment:
                                                                            Alignment.centerRight,
                                                                        child:
                                                                            Text(
                                                                          'Transaction No:    ',
                                                                          // textAlign: TextAlign.right,
                                                                          style:
                                                                              poppinsMedium.copyWith(
                                                                            fontSize:
                                                                                10,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 3,
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            30,
                                                                        decoration: BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(12),
                                                                            border: Border.all(color: Color.fromRGBO(229, 229, 229, 1.0))),
                                                                        child:
                                                                            TextField(
                                                                          controller:
                                                                              _transactionNoController,
                                                                          autofocus:
                                                                              false,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            // hintText: 'phone'.tr,
                                                                            contentPadding:
                                                                                EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                                            border:
                                                                                OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              borderSide: BorderSide(style: BorderStyle.none, width: 0),
                                                                            ),
                                                                            hintStyle:
                                                                                poppinsRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).hintColor),
                                                                            filled:
                                                                                true,
                                                                            fillColor:
                                                                                Theme.of(context).cardColor,
                                                                          ),
                                                                          style:
                                                                              poppinsRegular.copyWith(
                                                                            color:
                                                                                Theme.of(context).textTheme.bodyLarge!.color,
                                                                            fontSize:
                                                                                Dimensions.FONT_SIZE_SMALL,
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
                                                                ? SizedBox
                                                                    .shrink()
                                                                : Container(
                                                                    margin: EdgeInsets.only(
                                                                        bottom:
                                                                            30),
                                                                    child:
                                                                        QrImageView(
                                                                      data:
                                                                          'upi://pay?pa=${Get.find<AuthController>().profileModel!.restaurants!.first.upiId}&pn=&am=&tn=',
                                                                      version:
                                                                          QrVersions
                                                                              .auto,
                                                                      size: 120,
                                                                      gapless:
                                                                          false,
                                                                    ),
                                                                  )
                                                            : SizedBox.shrink(),
                                                        posController.isLoading
                                                            ? CircularProgressIndicator()
                                                            : BottomCartWidget(
                                                                title:
                                                                    'Checkout',
                                                                isShowNote:
                                                                    false,
                                                                callNotesFunction:
                                                                    () {},
                                                                callFunction:
                                                                    () async {
                                                                  FocusManager
                                                                      .instance
                                                                      .primaryFocus
                                                                      ?.unfocus();

                                                                  // if (posController
                                                                  //         .selectedPaymentTab ==
                                                                  //     3) {
                                                                  // if (_paidController
                                                                  //     .text
                                                                  //     .isEmpty) {
                                                                  //   showCustomSnackBar(
                                                                  //       'Please enter paid amount');
                                                                  // } else
                                                                  if ((Get.find<PosController>().selectedPaymentTab ==
                                                                              1 ||
                                                                          Get.find<PosController>().selectedPaymentTab ==
                                                                              2) &&
                                                                      _transactionNoController
                                                                          .text
                                                                          .isEmpty) {
                                                                    showCustomSnackBar(
                                                                        'Please enter transaction number');
                                                                  } else {
                                                                    // if (double.parse(_paidController
                                                                    //         .text) >
                                                                    //     double.parse(Get.find<PosController>()
                                                                    //         .roomListWithAmount[i]
                                                                    //         .orderAmount)) {
                                                                    //   showCustomSnackBar(
                                                                    //       'You can not extra pay amount more than total payable amount');
                                                                    // } else {

                                                                    // Map<String,
                                                                    //         dynamic>
                                                                    //     jsonData =
                                                                    //     {
                                                                    //   'room_id': Get.find<
                                                                    //           PosController>()
                                                                    //       .roomListWithAmount[
                                                                    //           i]
                                                                    //       .roomId,
                                                                    //   'total_amount': Get.find<
                                                                    //           PosController>()
                                                                    //       .roomListWithAmount[
                                                                    //           i]
                                                                    //       .orderAmount,
                                                                    //   'payment_mode': Get.find<PosController>().selectedPaymentTab ==
                                                                    //           0
                                                                    //       ? 'cash'
                                                                    //       : Get.find<PosController>().selectedPaymentTab == 1
                                                                    //           ? 'card'
                                                                    //           : 'upi'
                                                                    // };

                                                                    // Get.find<PosController>().collectRoomPayment(
                                                                    //     callback,
                                                                    //     jsonData:
                                                                    //         jsonData);
                                                                  }
                                                                  // }
                                                                },
                                                              )
                                                      ],
                                                    );
                                                  }),
                                                ),
                                              ],
                                            )
                                          : SizedBox.shrink(),
                                    ],
                                  );
                                }),
                            // SizedBox(height: 10),
                          ]);
                        }),
                      ),
                    ),
                  ),
                ),
              ),

              // Container(
              //   width: 1170,
              //   padding:
              //       EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              //   child: CustomButton(
              //       buttonText: 'order_now'.tr,
              //       onPressed: () async {
              //         if (_availableList.contains(false)) {
              //           showCustomSnackBar(
              //               'one_or_more_product_unavailable'.tr);
              //         } else {
              //           Get.find<PosController>().placeOrder(
              //               _nameController.text.isEmpty
              //                   ? ''
              //                   : _nameController.text,
              //               _orderAmount.toString(),
              //               userType,
              //               callback);
              //         }
              //       }),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void callback(bool isSuccess, String message) async {
    if (isSuccess) {
      Get.back();

      showCustomSnackBar(message, isError: false);
      Get.find<PosController>().clearTapCustomerData();
      Get.find<PosController>().getTapManageMentCustomerList();
    } else {
      showCustomSnackBar(message);
    }
  }
}
