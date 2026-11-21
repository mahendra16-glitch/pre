import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_room_bills_response_model.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ViewRoomBills extends StatefulWidget {
  final String roomId;
  final String roomName;
  const ViewRoomBills(
      {super.key, required this.roomId, required this.roomName});

  @override
  State<ViewRoomBills> createState() => _ViewRoomBillsState();
}

class _ViewRoomBillsState extends State<ViewRoomBills> {
  @override
  void initState() {
    super.initState();
    initCall();
  }

  initCall() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Get.find<PosController>()
          .getRoomBillsList(widget.roomId, (Response response) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Image.asset(Images.ic_arrow_back, height: 20),
            color: ColorTheme.appColor,
            onPressed: () {
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
        child: GetBuilder<PosController>(builder: (posController) {
          return posController.isLoading
              ? Center(child: CircularProgressIndicator())
              : GetBuilder<KdsController>(builder: (kdsController) {
                  return kdsController.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Text(
                                  'Room Name: ${widget.roomName}',
                                  style: poppinsMedium.copyWith(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.only(top: 10),
                              //   child: Text(
                              //     'Phone: ${widget.phone}',
                              //     style: poppinsMedium.copyWith(fontSize: 14),
                              //     maxLines: 1,
                              //     overflow: TextOverflow.ellipsis,
                              //   ),
                              // ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'No.',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 14,
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
                                          fontSize: 12,
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
                                          fontSize: 12,
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
                                          fontSize: 12,
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
                                    itemCount:
                                        posController.roomBillsList.length ?? 0,
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    itemBuilder: (BuildContext context, int i) {
                                      GetRoomBillsResponseModel customerData =
                                          posController.roomBillsList[i];
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
                                                    fontSize: 12),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                '${customerData.orderId}',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: 12),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                double.parse(customerData
                                                        .orderAmount!)
                                                    .toStringAsFixed(2),
                                                style: poppinsMedium.copyWith(
                                                    fontSize: 12),
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
                                                    fontSize: 12),
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
                                                          '',
                                                          ''));
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
                                                  margin:
                                                      EdgeInsets.only(left: 7),
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: Dimensions
                                                          .PADDING_SIZE_EXTRA_SMALL,
                                                      horizontal: 13),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors
                                                              .transparent),
                                                      color:
                                                          ColorTheme.appColor,
                                                      // border:
                                                      //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                                      borderRadius: BorderRadius
                                                          .circular(Dimensions
                                                              .RADIUS_DEFAULT)),
                                                  child: Center(
                                                    child: Text(
                                                      'Detail',
                                                      style: poppinsRegular
                                                          .copyWith(
                                                              fontSize: 12,
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
                            ],
                          ),
                        );
                });
        }),
      ),
    );
  }
}
