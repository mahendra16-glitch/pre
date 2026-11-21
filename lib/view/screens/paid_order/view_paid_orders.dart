import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/view/screens/paid_order/show_paid_order_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/styles.dart';

class ViewPaidOrders extends StatefulWidget {
  const ViewPaidOrders({Key? key}) : super(key: key);

  @override
  State<ViewPaidOrders> createState() => _ViewPaidOrdersState();
}

class _ViewPaidOrdersState extends State<ViewPaidOrders> {
  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await Get.find<KdsController>().getPaidOrderList('');
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
        actions: [
          GetBuilder<KdsController>(builder: (kdsController) {
            return kdsController.waiterList.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
                    height: MediaQuery.of(context).size.shortestSide > 570
                        ? 50
                        : 36,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        color: Colors.white,
                        border: Border.all(color: ColorTheme.borderGrey)),
                    child: DropdownButton<SelectedWaiter>(
                      value: kdsController.selectedWaiter ??
                          kdsController.waiterList.first,
                      items: kdsController.waiterList
                          .map<DropdownMenuItem<SelectedWaiter>>(
                              (SelectedWaiter value) {
                        return DropdownMenuItem<SelectedWaiter>(
                          value: value,
                          child: Text(
                            value.name,
                            style: poppinsMedium.copyWith(
                              color: Colors.grey,
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 13,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (SelectedWaiter? newValue) {
                        if (newValue != null) {
                          kdsController.selectedWaiter = newValue;
                          kdsController.update();
                        }
                      },
                      underline: const SizedBox(),
                      icon:
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ),
                  )
                : const SizedBox.shrink();
          }),
        ],
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
                    child: PaidOrdersContent(
                      paidSearch: paidController,
                    ));
          }),
        ]),
      ),
    );
  }
}

class SelectedWaiter {
  final int id;
  final String name;
  SelectedWaiter({required this.id, required this.name});
}
