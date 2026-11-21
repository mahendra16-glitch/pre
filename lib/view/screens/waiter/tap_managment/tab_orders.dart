import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tap_managment/tab_order_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabOrders extends StatefulWidget {
  @override
  State<TabOrders> createState() => _TabOrdersState();
}

class _TabOrdersState extends State<TabOrders> {
  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    await Get.find<KdsController>().getTabOrderList('');
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
        title: Column(
          children: [
            MediaQuery.of(context).size.shortestSide > 570
                ? Image.asset(
                    logoHelper.appLogo!,
                    width: Get.width * 0.13,
                  )
                : Image.asset(
                    logoHelper.appLogo!,
                    width: Get.width * 0.3,
                  ),
          ],
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
                    child: TabOrderContent(paidSearch: paidController));
            // WaiterOrderList(
            // orderList: kdsController.getOrderListResponse.orders
            // );
          }),
        ]),
      ),
    );
  }
}
