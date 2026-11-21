import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaiterSelectOrdeItem extends StatelessWidget {
  final List<OrderDetails> orderItemList;
  final OrderList order;

  WaiterSelectOrdeItem({
    Key? key,
    required this.orderItemList,
    required this.order,
  }) : super(key: key);

  final TextEditingController cancelReason = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double foodTotal = 0;
    return Column(
      children: [
        ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: orderItemList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              double itemPrice = 0;
              String variationText = '';
              String addons = '';
              double gstCharge = 0;
              double vatCharge = 0;
              if (orderItemList.length != index &&
                  orderItemList[index].foodStatus != 3) {
                itemPrice = itemPrice + (orderItemList[index].price ?? 0);
                if (orderItemList[index].variation != null &&
                    (orderItemList[index].variation?.isNotEmpty ?? false)) {
                  for (int j = 0;
                      j < (orderItemList[index].variation?.length ?? 0);
                      j++) {
                    variationText +=
                        '${variationText.isNotEmpty ? ', ' : ''}${orderItemList[index].variation?[j].name ?? ''} (';

                    if (orderItemList[index].variation?[j].values != null) {
                      List<String> labelList = [];
                      for (var element
                          in orderItemList[index].variation?[j].values ?? []) {
                        labelList.add(element.level ?? '');
                        itemPrice = itemPrice +
                            ((double.tryParse(element.optionPrice ?? '0') ??
                                    0) *
                                (orderItemList[index].quantity ?? 0));
                      }
                      variationText +=
                          '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                    }

                    variationText += ')';
                  }
                }

                for (var i = 0;
                    i < (orderItemList[index].addOns?.length ?? 0);
                    i++) {
                  itemPrice = itemPrice +
                      (((orderItemList[index].addOns?[i].qty ?? 0) *
                              (orderItemList[index].addOns?[i].price ?? 0))
                          .toDouble());

                  addons +=
                      '${orderItemList[index].addOns?[i].name ?? ''} (${orderItemList[index].addOns?[i].qty ?? 0})';
                }

               

                itemPrice = itemPrice +
                    ((Get.find<AuthController>()
                                    .profileModel!
                                    .restaurants!
                                    .first
                                    .serviceCharge ==
                                'Yes' &&
                            Get.find<AuthController>()
                                    .profileModel!
                                    .restaurants!
                                    .first
                                    .autoServiceCharge ==
                                'Yes'
                        ? ((itemPrice * 10) / 100)
                        : 0)) +
                    gstCharge +
                    vatCharge;
                foodTotal = foodTotal + itemPrice;
              }

              return orderItemList.length == index
                  ? order.isShowCheckbox
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(left: 18, right: 18),
                          child: Column(
                            children: [
                              const SizedBox(
                                  height: Dimensions.PADDING_SIZE_DEFAULT),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Amount',
                                    style: poppinsSemiBold.copyWith(
                                        fontSize: 15, color: Colors.black),
                                  ),
                                  Text(
                                    '${foodTotal.toStringAsFixed(2)}',
                                    style: poppinsSemiBold.copyWith(
                                        fontSize: 15, color: Colors.black),
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                  : orderItemList[index].foodStatus == 3
                      ? const SizedBox.shrink()
                      : orderItemList[index].isSplited &&
                              order.isSplitTable == false
                          ? const SizedBox.shrink()
                          : Column(
                              children: [
                                const SizedBox(
                                    height: Dimensions.PADDING_SIZE_SMALL),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 17),
                                  child: InkWell(
                                    onTap: () {
                                      Get.find<KdsController>()
                                          .selectFoodItem(foodIndex: index);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${orderItemList[index].foodDetails?.name ?? ''} (${formatQty(orderItemList[index].quantity)})',
                                                style: poppinsSemiBold.copyWith(
                                                    fontSize: 15,
                                                    color: Colors.black),
                                              ),
                                              addons == ''
                                                  ? const SizedBox.shrink()
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 4),
                                                      child: Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: 'Add-Ons :',
                                                              style: poppinsMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          11,
                                                                      color: ColorTheme
                                                                          .blue),
                                                            ),
                                                            TextSpan(
                                                              text: ' $addons',
                                                              style:
                                                                  poppinsMedium
                                                                      .copyWith(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontSize: 11,
                                                                color:
                                                                    ColorTheme
                                                                        .green,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                              variationText == ''
                                                  ? const SizedBox.shrink()
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 4),
                                                      child: Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  'Variants  :',
                                                              style: poppinsMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          11,
                                                                      color: ColorTheme
                                                                          .blue),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  ' $variationText',
                                                              style: poppinsMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          11,
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
                                        const SizedBox(width: 20),
                                        order.isSplitTable
                                            ? Text(
                                                '${itemPrice.toStringAsFixed(2)}',
                                                style: poppinsSemiBold.copyWith(
                                                    fontSize: 15,
                                                    color: Colors.black),
                                              )
                                            : SizedBox(
                                                height: 10,
                                                child: Checkbox(
                                                    value: orderItemList[index]
                                                        .isSelected,
                                                    onChanged: (v) {
                                                      Get.find<KdsController>()
                                                          .selectFoodItem(
                                                              foodIndex: index);
                                                    }),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                    height: Dimensions.PADDING_SIZE_SMALL),
                                DottedLine(
                                  direction: Axis.horizontal,
                                  alignment: WrapAlignment.center,
                                  lineThickness: 1.0,
                                  dashLength: 2.5,
                                  dashColor: ColorTheme.hintText,
                                ),
                              ],
                            );
            }),
      ],
    );
  }
}

String formatQty(num? qty) {
  final q = qty ?? 0;
  return q % 1 == 0 ? q.toInt().toString() : q.toString();
}