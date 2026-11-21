
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/pos_screen_window/widget/category_pos_tab.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/pos_screen_window/widget/normal_pos_tab.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/pos_screen_window/widget/split_pos_tab.dart';

class PaymentPosScreen extends StatefulWidget {
  const PaymentPosScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentPosScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String selectedPaymentMethod = "Cash";
  String selectedSplitPaymentMethod1 =
      "Cash"; // For first dropdown in Split tab
  String selectedSplitPaymentMethod2 =
      "Card"; // For second dropdown in Split tab
  String selectedCategoryPaymentMethod1 =
      "Cash"; // For Kitchen dropdown in Category tab
  String selectedCategoryPaymentMethod2 =
      "Cash"; // For Bar dropdown in Category tab

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController = TabController(length: 3, vsync: this);
    // _tabController.animationDuration = Duration(milliseconds: 500); // Add this line for smooth animation
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize18 = screenWidth * 0.0095;
    final fontSize19 = screenWidth * 0.0098;
    return Scaffold(
      backgroundColor: ColorTheme.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "Collect Payment",
          style: montserratMedium.copyWith(color: Colors.black, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(0)),
          // border: Border(top: BorderSide(color: Color(0xFFE7E7E7)))
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(0),
                  border: Border(
                      bottom: BorderSide(color: Color(0xFFE7E7E7)),
                      top: BorderSide(color: Color(0xFFE7E7E7))),
                ),
                child: TabBar(
                  automaticIndicatorColorAdjustment: true,
                  controller: _tabController,
                  labelColor: Colors.white,
                  dividerColor: Colors.transparent,
                  unselectedLabelColor: Color(0xFF828282),
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle:
                      TextStyle(fontWeight: FontWeight.normal),
                  indicator: BoxDecoration(
                    // color: ColorTheme.appColor, //yaha se running color aata hai usko sahi kr skte hai
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tabs: [
                    Tab(
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        // padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                          color: _tabController.index == 0
                              ? ColorTheme.green
                              : Colors.white,
                        ),
                        child: Text(
                          "Normal",
                          style: montserratMedium.copyWith(fontSize: fontSize19),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                          // border: Border(
                          //     left: BorderSide(color: Color(0xFFE7E7E7)),
                          //     right: BorderSide(color: Color(0xFFE7E7E7))),
                          color: _tabController.index == 1
                              ? ColorTheme.green
                              : Colors.white,
                        ),
                        child: Text(
                          "Split",
                          style: montserratMedium.copyWith(fontSize: fontSize19),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        // height: 10,
                        // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                          color: _tabController.index == 2
                              ? ColorTheme.green
                              : Colors.white,
                        ),
                        child: Text(
                          "Category",
                          style: montserratMedium.copyWith(fontSize: fontSize19),
                        ),
                      ),
                    ),
                  ],
                  onTap: (index) {
                    setState(() {
                      _tabController.index = index;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: BouncingScrollPhysics(),
                children: [
                  NormalPosTabContent(), // Normal Tab
                  SplitPosTabContent(), // Split Tab
                  CategoryPosTabContent(), // Category Tab
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: screenHeight * 0.07,
              decoration: BoxDecoration(color: ColorTheme.green),
              child: Text(
                'Confirm Payment',
                style: montserratBold.copyWith(
                  color: ColorTheme.white,
                  fontSize: fontSize18,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
