import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../util/styles.dart';

class CancelledOrders extends StatefulWidget {
  const CancelledOrders({Key? key}) : super(key: key);

  @override
  State<CancelledOrders> createState() => _CancelledOrdersState();
}

class _CancelledOrdersState extends State<CancelledOrders> {
  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await Get.find<KdsController>().getCancelledOrderList('');
  }

  final TextEditingController paidController = TextEditingController();
  final TextEditingController searchTable = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              size: 40,
              color: ColorTheme.green,
            ),
            color: ColorTheme.appColor,
            onPressed: () {
              Get.back();
            }),
        titleSpacing: 0,
        elevation: 0,
        centerTitle: false,
        title: MediaQuery.of(context).size.shortestSide > 570
            ? Image.asset(
                logoHelper.appLogo!,
                width: Get.width * 0.13,
              )
            : Image.asset(
                logoHelper.appLogo!,
                width: Get.width * 0.3,
              ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(children: [
          const SizedBox(height: 20),
          GetBuilder<KdsController>(builder: (kdsController) {
            return kdsController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.PADDING_SIZE_LARGE),
                    child: cancelOrderList());
          }),
        ]),
      ),
    );
  }

  Widget cancelOrderList() {
    return SafeArea(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height:
                      MediaQuery.of(context).size.shortestSide > 570 ? 50 : 36,
                  child: TextField(
                    controller: paidController,
                    textInputAction: TextInputAction.search,
                    autofocus: false,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                      suffixIcon:
                          Icon(Icons.search, color: ColorTheme.appColor),
                      hintText: 'Order id or name or mobile',
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
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 13,
                          color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: poppinsMedium.copyWith(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.shortestSide > 570
                          ? 15
                          : 13,
                    ),
                    onChanged: (value) async {
                      Get.find<KdsController>().update();
                    },
                  ),
                ),
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: () {
                  paidController.clear();
                  _selectDate(context);
                },
                child: Container(
                  height:
                      MediaQuery.of(context).size.shortestSide > 570 ? 50 : 36,
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: Colors.white,
                      border: Border.all(color: ColorTheme.borderGrey)),
                  child: Center(
                    child: Text(
                      selectedDate == null
                          ? 'Filter by date'
                          : DateFormat('yyyy-MM-dd').format(selectedDate!),
                      style: poppinsMedium.copyWith(
                        color: Colors.grey,
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ListView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              // itemCount: 10,
              itemCount: Get.find<KdsController>()
                      .getCancelledOrders
                      ?.orders
                      ?.length ??
                  0,
              itemBuilder: (BuildContext context, int i) {
                var order =
                    Get.find<KdsController>().getCancelledOrders?.orders?[i];

                final auth = Get.find<AuthController>();
                final restaurant = auth.profileModel!.restaurants!.first;

                final searchBy = restaurant.searchBy ?? [];

                bool tableMatch = searchBy.contains('table no') &&
                    (order!.tableNo!
                        .toUpperCase()
                        .contains(paidController.text.toUpperCase()));

                bool orderIdMatch = searchBy.contains('order id') &&
                    (order!.restaurantOrderId
                        .toString()
                        .toUpperCase()
                        .contains(paidController.text.toUpperCase()));

                bool userMatch = searchBy.contains('user id') &&
                    ((order!.userName
                        .toString()
                        .toUpperCase()
                        .contains(paidController.text.toUpperCase())));

                bool phoneMatch = searchBy.contains('phone no') &&
                    ((order!.phone
                        .toString()
                        .toUpperCase()
                        .contains(paidController.text.toUpperCase())));
                bool isSearchTextMatched = paidController.text.isEmpty ||
                    orderIdMatch ||
                    phoneMatch ||
                    userMatch ||
                    tableMatch;

                // Check if both conditions are matched
                return isSearchTextMatched
                    ? orderBox(i)
                    : const SizedBox.shrink();
              }),
        ],
      ),
    );
  }

  Widget orderBox(int i) {
    var order = Get.find<KdsController>().getCancelledOrders?.orders?[i];

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_EXTRA_LARGE),
          color: Color.fromRGBO(254, 245, 208, 1)),
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Id',
                style: poppinsSemiBold.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
                ),
              ),
              Text(
                '${order!.restaurantOrderId}',
                style: poppinsSemiBold.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
                ),
              )
            ],
          ),

          SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Waiter Name',
                style: poppinsSemiBold.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
                ),
              ),
              Text(
                '${order.waiterName}',
                style: poppinsSemiBold.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
                ),
              )
            ],
          ),
          if (order.tableNo != '')
            SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
          if (order.tableNo != '')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Table No',
                  style: poppinsSemiBold.copyWith(
                    fontSize: MediaQuery.of(context).size.shortestSide > 570
                        ? 15
                        : 13,
                  ),
                ),
                Text(
                  '${order.tableNo}',
                  style: poppinsSemiBold.copyWith(
                    fontSize: MediaQuery.of(context).size.shortestSide > 570
                        ? 15
                        : 13,
                  ),
                )
              ],
            ),
          if (Get.find<AuthController>()
                  .profileModel!
                  .restaurants!
                  .first
                  .isComplementry !=
              'Yes')
            Column(
              children: [
                if (order.userName != '')
                  SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                if (order.userName != '')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Name',
                        style: poppinsSemiBold.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 13,
                        ),
                      ),
                      Text(
                        '${order.userName}',
                        style: poppinsSemiBold.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 13,
                        ),
                      )
                    ],
                  ),
                if (order.phone != '')
                  SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                if (order.phone != '')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Phone',
                        style: poppinsSemiBold.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 13,
                        ),
                      ),
                      Text(
                        '${order.phone}',
                        style: poppinsSemiBold.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 13,
                        ),
                      )
                    ],
                  ),
                SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Amount',
                      style: poppinsSemiBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 13,
                      ),
                    ),
                    Text(
                      '${order.orderAmount} ₹',
                      style: poppinsSemiBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 13,
                      ),
                    )
                  ],
                ),

                SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment Method',
                      style: poppinsSemiBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 13,
                      ),
                    ),
                    Text(
                      '${order.paymentMethod}',
                      style: poppinsSemiBold.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 13,
                      ),
                    )
                  ],
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text(
                //       'Time',
                //       style: poppinsSemiBold.copyWith(
                //         fontSize: MediaQuery.of(context).size.shortestSide > 570
                //             ? 15
                //             : 13,
                //       ),
                //     ),
                //     Text(
                //       DateFormat('yyyy-MM-dd HH:mm')
                //           .format(DateTime.parse(order.cancelAt!)),
                //       style: poppinsSemiBold.copyWith(
                //         fontSize: MediaQuery.of(context).size.shortestSide > 570
                //             ? 15
                //             : 13,
                //       ),
                //     )
                // ],
                // ),
                ExpansionTile(
                  title: Row(
                    children: [
                      Text(
                        'Food Details',
                        style: poppinsSemiBold.copyWith(
                          fontSize: 15,
                          color: ColorTheme.disableButtonText,
                        ),
                      ),
                    ],
                  ),
                  children: order.orderDetails!.map(
                    (orderItemList) {
                      String variationText = '';
                      if (orderItemList.variation != null &&
                          (orderItemList.variation?.isNotEmpty ?? false) &&
                          (Get.find<AuthController>()
                                  .profileModel
                                  ?.restaurants
                                  ?.isNotEmpty ??
                              false) &&
                          (Get.find<AuthController>()
                                  .profileModel
                                  ?.restaurants
                                  ?.first
                                  .foodWithVariance ==
                              'Yes')) {
                        variationText += '';
                        List<String> labelList = [];

                        for (int j = 0;
                            j < (orderItemList.variation?.length ?? 0);
                            j++) {
                          final variationJ = orderItemList.variation?[j];
                          if (variationJ?.values != null) {
                            for (var element in (variationJ!.values ?? [])) {
                              labelList.add(element.level ?? '');
                            }
                          }
                        }
                        variationText += '${labelList.join(',')}';
                        variationText += '';
                      } else if (orderItemList.variation != null &&
                          (orderItemList.variation?.isNotEmpty ?? false) &&
                          (Get.find<AuthController>()
                                  .profileModel
                                  ?.restaurants
                                  ?.isNotEmpty ??
                              false) &&
                          (Get.find<AuthController>()
                                  .profileModel
                                  ?.restaurants
                                  ?.first
                                  .foodWithVariance !=
                              'Yes')) {
                        for (int j = 0;
                            j < (orderItemList.variation?.length ?? 0);
                            j++) {
                          final variationJ = orderItemList.variation?[j];
                          variationText +=
                              '${variationText.isNotEmpty ? ', ' : ''}${variationJ?.name ?? ''} (';

                          if (variationJ?.values != null) {
                            List<String> labelList = [];
                            for (var element in (variationJ!.values ?? [])) {
                              labelList.add(element.level ?? '');
                            }
                            variationText +=
                                '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                          }

                          variationText += ')';
                        }
                      }

                      String addons = '';
                      for (var i = 0;
                          i < (orderItemList.addOns?.length ?? 0);
                          i++) {
                        if (addons != '') {
                          addons += ', ';
                        }
                        addons +=
                            '${orderItemList.addOns?[i].name ?? ''} (${orderItemList.addOns?[i].qty ?? ''})';
                      }
                      return Column(
                        children: [
                          SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (Get.find<AuthController>()
                                            .profileModel!
                                            .restaurants!
                                            .first
                                            .foodWithVariance ==
                                        'Yes')
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        '${orderItemList.foodDetails?.name ?? ''} (${orderItemList.quantity})',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' $variationText',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize: 11,
                                                      color: ColorTheme.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (Get.find<AuthController>()
                                            .profileModel!
                                            .restaurants!
                                            .first
                                            .foodWithVariance !=
                                        'Yes')
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              '${orderItemList.foodDetails?.name ?? ''} (${orderItemList.quantity})',
                                              style: poppinsSemiBold.copyWith(
                                                fontSize: 15,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    addons == ''
                                        ? SizedBox.shrink()
                                        : Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Add-Ons :',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 11,
                                                            color: const Color
                                                                .fromARGB(255,
                                                                49, 61, 70)),
                                                  ),
                                                  TextSpan(
                                                    text: ' $addons',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize: 11,
                                                      color: ColorTheme.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    if (Get.find<AuthController>()
                                            .profileModel!
                                            .restaurants!
                                            .first
                                            .foodWithVariance !=
                                        'Yes')
                                      variationText == ''
                                          ? SizedBox.shrink()
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'Variants  :',
                                                      style: poppinsMedium
                                                          .copyWith(
                                                              fontSize: 11,
                                                              color: ColorTheme
                                                                  .blue),
                                                    ),
                                                    TextSpan(
                                                      text: ' $variationText',
                                                      style: poppinsMedium
                                                          .copyWith(
                                                              fontSize: 11,
                                                              color: ColorTheme
                                                                  .green),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                    orderItemList.foodLevelNotes == '' ||
                                            orderItemList.foodLevelNotes == null
                                        ? SizedBox.shrink()
                                        : Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Notes  :',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 11,
                                                            color: ColorTheme
                                                                .blue),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        ' ${orderItemList.foodLevelNotes}',
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 11,
                                                            color: ColorTheme
                                                                .green),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                              // Image.asset(Images.ic_theme_show_addOn, height: 30),
                            ],
                          ),
                        ],
                      );
                    },
                  ).toList(),
                ),
              ],
            ),
          // SizedBox(height: 30),
        ],
      ),
    );
  }

  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2023, 6),
        lastDate: DateTime.now());
    if (picked != selectedDate) {
      selectedDate = picked;

      await Get.find<KdsController>().getCancelledOrderList(
          DateFormat('yyyy-MM-dd').format(selectedDate!));
    }
  }
}
