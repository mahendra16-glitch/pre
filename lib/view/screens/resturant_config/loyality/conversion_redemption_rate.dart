import 'package:flutter/material.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/loyalty_controller.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/loyality/conversion_rate.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/loyality/redemption_rate.dart';

class LoyaltyProgramScreen extends StatefulWidget {
  const LoyaltyProgramScreen({super.key});

  @override
  State<LoyaltyProgramScreen> createState() => _LoyaltyProgramScreenState();
}

class _LoyaltyProgramScreenState extends State<LoyaltyProgramScreen> {
  @override
  void initState() {
    super.initState();
    final loyaltyController = Get.find<LoyaltyController>();
    loyaltyController.getConversionRateList();

    loyaltyController.getRedemptionRateList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(Icons.arrow_back_ios, color: Color(0xFFF36C3F))),
          titleSpacing: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Use the local asset for the logo and increase its size
              // Image.asset(
              //   'assets/logo.png',
              //   height: 36, // Increased logo size
              //   errorBuilder: (context, error, stackTrace) =>
              //       const Icon(Icons.store, color: Color(0xFFF36C3F), size: 36),
              // ),
              // const SizedBox(width: 12),
              // Replaced "Captain" with "Loyalty Program" in green
              Text(
                'Loyalty Program',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          // actions: <Widget>[
          //   Stack(
          //     alignment: Alignment.center,
          //     children: <Widget>[
          //       IconButton(
          //         icon: const Icon(Icons.notifications, color: Colors.black),
          //         onPressed: () {},
          //       ),
          //       Positioned(
          //         top: 10,
          //         right: 10,
          //         child: Container(
          //           padding: const EdgeInsets.all(2),
          //           decoration: BoxDecoration(
          //             color: Colors.green,
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //           constraints: const BoxConstraints(
          //             minWidth: 16,
          //             minHeight: 16,
          //           ),
          //           child: const Text(
          //             '12',
          //             style: TextStyle(color: Colors.white, fontSize: 10),
          //             textAlign: TextAlign.center,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          //   const SizedBox(width: 10),
          //   const CircleAvatar(
          //     backgroundColor: Color(0xFFF36C3F),
          //     child: Icon(Icons.add, color: Colors.white),
          //   ),
          //   const SizedBox(width: 16),
          // ],
        ),
        body: Column(
          children: [
            // The main "Loyalty Program" title has been removed from the body
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 10.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: const Color(0xFFF36C3F),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.normal),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  tabs: const [
                    Tab(text: 'Conversion'),
                    Tab(text: 'Redemption'),
                  ],
                ),
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [ConversionRatePage(), RedemptionPage()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
