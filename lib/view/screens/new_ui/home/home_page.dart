// new home page work on every platform

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/printer.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/home/order_view.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/home/table_view.dart';
import 'package:mygenie_restaurant/view/screens/waiter/home/widget/waiter_order_list.dart';

class WindowPosHome extends StatefulWidget {
  StreamSubscription<BTStatus>? subscriptionBtStatus;
  StreamSubscription<BTStatus>? singleSplitBleStatus;
  TextEditingController? searchController;

  WindowPosHome(
      {super.key, this.subscriptionBtStatus, this.singleSplitBleStatus,this.searchController});

  @override
  State<WindowPosHome> createState() => _WindowPosHomeState();
}

class _WindowPosHomeState extends State<WindowPosHome> {
  String selectedStatus = 'Cooking';

  final List<String> statusOptions = ['Cooking', 'Ready', 'Serve'];

  final List<Map<String, dynamic>> tables = List.generate(14, (index) {
    if (index == 0) {
      return {
        'id': 'T1',
        'status': 'occupied',
        'guests': 2,
        'items': 14,
        'time': '35 Min',
        'amount': '₹3500'
      };
    } else if (index == 1) {
      return {'id': 'T2', 'status': 'reserved', 'guests': 4, 'time': '2:30 PM'};
    } else {
      return {'id': 'T${index + 1}', 'status': 'empty'};
    }
  });

  bool isSwitched = true;

  // bool isMobile(BuildContext context) {
  //   return MediaQuery.of(context).size.width < 600;
  // }

  // bool isTablet(BuildContext context) {
  //   double width = MediaQuery.of(context).size.width;
  //   return width >= 600 && width < 1100;
  // }

  // bool isDesktop(BuildContext context) {
  //   return MediaQuery.of(context).size.width >= 1100;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: GetBuilder<KdsController>(builder: (kdsController) {
          return kdsController.isTableView
              ?  TableViewHome(subscriptionBtStatus: widget.subscriptionBtStatus)
              : OrderViewScreen(
                searchController: widget.searchController,
                  singleSplitBleStatus: widget.singleSplitBleStatus,
                  subscriptionBtStatus: widget.subscriptionBtStatus,
                );
        }),
      ),
    );
  }
}
