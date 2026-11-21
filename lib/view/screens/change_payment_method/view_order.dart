import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'change_payment_order_content.dart';

class ChangePaymentViewOrders extends StatefulWidget {
  @override
  State<ChangePaymentViewOrders> createState() =>
      _ChangePaymentViewOrdersState();
}

class _ChangePaymentViewOrdersState extends State<ChangePaymentViewOrders> {
  // SelectedWaiter selectedWaiter;
  // List<SelectedWaiter> waiterList = [];
  // List<int> waiterListId = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    await Get.find<KdsController>().getPaidOrderList('');
  }

  TextEditingController paidController = TextEditingController();
  TextEditingController searchTable = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // toolbarHeight: Get.height / 10.72,
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
                width: Get.width * 0.2,
              )
            : Image.asset(
                logoHelper.appLogo!,
                width: Get.width * 0.3,
              ),
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(children: [
          SizedBox(height: 20),
          GetBuilder<KdsController>(builder: (kdsController) {
            return kdsController.isLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.PADDING_SIZE_LARGE),
                    child:
                        ChangePaymentOrderContent(paidSearch: paidController));
          }),
        ]),
      ),
    );
  }
}

class SelectedWaiter {
  int? id;
  String? name;
  SelectedWaiter({this.id, this.name});
}
