import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/view/screens/online_unpaid_order/unpaid_order_list_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnlineUnpaidOrder extends StatefulWidget {
  const OnlineUnpaidOrder({Key? key}) : super(key: key);

  @override
  State<OnlineUnpaidOrder> createState() => _OnlineUnpaidOrderState();
}

class _OnlineUnpaidOrderState extends State<OnlineUnpaidOrder> {
  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<KdsController>().getOnlineUnpaidOrders();
    });
  }

  final TextEditingController searchController = TextEditingController();

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
      body: GetBuilder<KdsController>(builder: (kdsController) {
        return kdsController.isLoading
            ? Center(child: CircularProgressIndicator())
            : kdsController.getUnpaidOnlineOrderListResponse == null
                ? const SizedBox.shrink()
                : kdsController.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: orderListContent(kdsController));

        // WaiterOrderList(
        // orderList: kdsController.getOrderListResponse.orders
        // );
      }),
    );
  }

  Widget orderListContent(KdsController kdsController) {
    final auth = Get.find<AuthController>();
    final restaurant = auth.profileModel!.restaurants!.first;
    final searchText = searchController.text.trim().toUpperCase();

    bool matchesSearch(OrderList order) {
      if (searchText.isEmpty) return true;

      final searchBy = restaurant.searchBy ?? [];

      bool tableMatch = searchBy.contains('table no') &&
          order.restaurantTable != null &&
          (order.restaurantTable!.tableNo ?? '')
              .toUpperCase()
              .contains(searchText);

      bool orderIdMatch = searchBy.contains('order id') &&
          (order.restaurantOrderId ?? '').toUpperCase().contains(searchText);

      bool userMatch = searchBy.contains('user id') &&
          ((order.userName ?? '').toUpperCase().contains(searchText) ||
              (order.user != null &&
                  ('${order.user!.fName ?? ''} ${order.user!.lName ?? ''}')
                      .toUpperCase()
                      .contains(searchText)));

      bool phoneMatch = searchBy.contains('phone no') &&
          ((order.user?.phone ?? '').toUpperCase().contains(searchText) ||
              (order.deliveryAddress?.contactPersonNumber ?? '')
                  .toUpperCase()
                  .contains(searchText));

      bool deliveryNameMatch = order.deliveryAddress?.contactPersonName
              ?.toUpperCase()
              .contains(searchText) ??
          false;

      return tableMatch ||
          orderIdMatch ||
          userMatch ||
          phoneMatch ||
          deliveryNameMatch;
    }

    bool filterOrder(OrderList order) {
      return matchesSearch(order);
    }

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: StaggeredGrid.count(
          crossAxisCount: isMobile(context)
              ? 1
              : isTablet(context)
                  ? 2
                  : 3,
          crossAxisSpacing: isMobile(context) ? 0 : 15,
          mainAxisSpacing: isMobile(context) ? 0 : 10,
          children: kdsController.getUnpaidOnlineOrderListResponse!.orders!
              .where(filterOrder)
              .map((order) {
            return OnlineUnpaidOrderListContent(
              searchOrder: searchController,
              order: order,
            );
          }).toList(),
        ));
  }
}
