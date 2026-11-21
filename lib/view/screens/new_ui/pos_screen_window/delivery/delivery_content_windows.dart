
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/online_delivery_mode/widget/order_status_card.dart';

class DeliveryDashboard extends StatelessWidget {
  final List<Map<String, dynamic>> confirmList = [
    {
      "id": "#D8310",
      "time": "15 mins ago",
      "orderType": 'swiggy',
      'status': '1',
      "items": [
        {
          "name": "Chicken Biryani",
          "qty": 1,
          "variant": "Extra Boiled Egg",
          "addons": "Raita"
        },
        {"name": "Chicken Tikka Roll", "qty": 1},
        {"name": "Paneer Fry", "qty": 1},
      ],
      "amount": "₹2436.50",
      "customerId": "XXXXXXX737",
      "type": "confirm"
    },
    {
      "id": "#D8321",
      "time": "12 mins ago",
      "orderType": 'zomatao',
      'status': '1',
      "items": [
        {"name": "Paneer Butter Masala", "qty": 1},
      ],
      "amount": "₹849.00",
      "customerId": "XXXXXXX123",
      "type": "confirm"
    },
    {
      "id": "#D8321",
      "time": "12 mins ago",
      "orderType": 'zomatao',
      "items": [
        {"name": "Paneer Butter Masala", "qty": 1},
      ],
      "amount": "₹849.00",
      "customerId": "XXXXXXX123",
      "type": "confirm"
    },
    {
      "id": "#D8310",
      "time": "15 mins ago",
      'status': '1',
      "orderType": 'mygenie',
      "items": [
        {
          "name": "Chicken Biryani",
          "qty": 1,
          "variant": "Extra Boiled Egg",
          "addons": "Raita"
        },
        {"name": "Chicken Tikka Roll", "qty": 1},
        {"name": "Paneer Fry", "qty": 1},
      ],
      "amount": "₹2436.50",
      "customerId": "XXXXXXX737",
      "type": "confirm"
    },
  ];

  final List<Map<String, dynamic>> cookingList = [
    {
      "id": "#D8333",
      "time": "10 mins ago",
      "runner": "Runner Name",
      "runnerId": "9662666737",
      "orderType": 'zomatao',
      'status': '2',
      "platform": "Zomato",
      "items": [
        {"name": "Fried Rice", "qty": 1},
        {"name": "Spring Roll", "qty": 1},
      ],
      "amount": "₹650.00",
      "customerId": "XXXXXXX999",
      "type": "cooking"
    },
    {
      "id": "#D8334",
      "time": "9 mins ago",
      "runner": "Runner Name",
      "runnerId": "9662666737",
      "orderType": 'swiggy',
      'status': '2',
      "platform": "MyGenie",
      "items": [
        {
          "name": "Veg Thali",
          "qty": 1,
          "type": "veg",
          "addon": "Extra Raita",
          "variant": "Large"
        },
      ],
      "amount": "₹299.00",
      "customerId": "XXXXXXX123",
      "type": "cooking"
    }
  ];

  final List<Map<String, dynamic>> dispatchList = [
    {
      "id": "#D8344",
      "time": "7 mins ago",
      "runner": "Runner Name",
      "runnerId": "9662666737",
      "orderType": 'mygenie',
      'status': '3',
      "platform": "Swiggy",
      "items": [
        {"name": "Dosa", "qty": 1},
        {"name": "Sambhar", "qty": 1},
      ],
      "amount": "₹199.00",
      "customerId": "XXXXXXX888",
      "type": "dispatch",
      "otp": "4365"
    },
    {
      "id": "#D8344",
      "time": "7 mins ago",
      "runner": "Runner Name",
      "runnerId": "9662666737",
      "orderType": 'swiggy',
      'status': '4',
      "platform": "Swiggy",
      "items": [
        {"name": "Dosa", "qty": 1},
        {"name": "Sambhar", "qty": 1},
        {"name": "Sambhar", "qty": 1},
        {"name": "Sambhar", "qty": 1},
        {"name": "Sambhar", "qty": 1},
        {"name": "Sambhar", "qty": 1},
        {"name": "Sambhar", "qty": 1},
        {"name": "Sambhar", "qty": 1},
      ],
      "amount": "₹199.00",
      "customerId": "XXXXXXX888",
      "type": "dispatch",
      "otp": "4365"
    }
  ];
  bool isSwitched = true;
  DeliveryDashboard({super.key});

  bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  bool isTablet(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1280;
  }

  bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1280;
  }

  double getExtentForDesktop(double width) {
    if (width >= 1920)
      return 380; // 5-6 cards
    else if (width >= 1600)
      return 350; // 4-5 cards
    else if (width >= 1440)
      return 320; // 4 cards
    else if (width >= 1280)
      return 300; // 3 cards
    else
      return 260; // fallback
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: SafeArea(
            child: Column(
          children: [
            if (isMobile(context) || isTablet(context))
              const SizedBox(
                height: 15,
              ),
            if (isMobile(context) || isTablet(context))
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(
                      width: 15,
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xFFDFDFDF),
                            ),
                            borderRadius: BorderRadius.circular(25)),
                        child: Text(
                          'Confirm',
                          style: poppinsSemiBold.copyWith(
                              fontSize: 12, color: Color(0xFFC6C6C6)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFFDFDFDF),
                          ),
                          borderRadius: BorderRadius.circular(25)),
                      child: Text(
                        'Cooking',
                        style: poppinsSemiBold.copyWith(
                            fontSize: 12, color: Color(0xFFC6C6C6)),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFFDFDFDF),
                          ),
                          borderRadius: BorderRadius.circular(25)),
                      child: Text(
                        'Ready',
                        style: poppinsSemiBold.copyWith(
                            fontSize: 12, color: Color(0xFFC6C6C6)),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFFDFDFDF),
                          ),
                          borderRadius: BorderRadius.circular(25)),
                      child: Text(
                        'Dispatch',
                        style: poppinsSemiBold.copyWith(
                            fontSize: 12, color: Color(0xFFC6C6C6)),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                  ],
                ),
              ),
            
            isMobile(context)
                // ? buildConfirmSection("Confirm", confirmList, context)
                ? Expanded(
                    child: ListView.builder(
                        itemCount: cookingList.length,
                        itemBuilder: (context, index) {
                          return OrderStatusCard();
                        }),
                  )
                : isTablet(context)
                    ? Expanded(
                        child: Row(
                          children: [
                            buildConfirmSection(
                                "Confirm", confirmList, context),
                            if (cookingList.isNotEmpty)
                              VerticalDivider(
                                  width: 2,
                                  thickness: 1,
                                  color: Color(0xFFDFDFDF)),
                            if (cookingList.isNotEmpty)
                              buildCookingSection(
                                  "Cooking", cookingList, context),
                          ],
                        ),
                      )
                    : Expanded(
                        child: Row(
                          children: [
                            buildConfirmSection(
                                "Confirm", confirmList, context),
                            if (cookingList.isNotEmpty)
                              VerticalDivider(
                                  width: 2,
                                  thickness: 1,
                                  color: Color(0xFFDFDFDF)),
                            if (cookingList.isNotEmpty)
                              buildCookingSection(
                                  "Cooking", cookingList, context),
                            if (dispatchList.isNotEmpty)
                              VerticalDivider(
                                  width: 2,
                                  thickness: 1,
                                  color: Color(0xFFDFDFDF)),
                            buildDispatchSection(
                                "Dispatch", dispatchList, context),
                          ],
                        ),
                      ),
          ],
        )));
  }

  Widget buildConfirmSection(
      String title, List<Map<String, dynamic>> dataList, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Flexible(
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop(context))
              Text(title,
                  style: poppinsSemiBold.copyWith(
                      fontSize: 13, color: Color(0xFF828282))),
            const SizedBox(height: 10),
            Expanded(
              child: MasonryGridView.extent(
                // crossAxisCount: 2,
                // maxCrossAxisExtent: isMobile(context)
                //     ? 550
                //     : isTablet(context)
                //         ? 400
                //         : 500, // Each card max 400px width
                maxCrossAxisExtent: isDesktop(context)
                    // ? getExtentForDesktop(screenWidth)
                    ? 500
                    : isTablet(context)
                        ? 400
                        : 550,
                mainAxisSpacing: 10,
                itemCount: dataList.length,
                itemBuilder: (context, index) {
                  return buildCard(dataList[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCookingSection(
      String title, List<Map<String, dynamic>> dataList, BuildContext context) {
    return Expanded(
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop(context))
              Text(title,
                  style: poppinsSemiBold.copyWith(
                      fontSize: 13, color: Color(0xFF828282))),
            const SizedBox(height: 10),
            Expanded(
              child: MasonryGridView.extent(
                // crossAxisCount: 2,
                maxCrossAxisExtent: isMobile(context)
                    ? 550
                    : isTablet(context)
                        ? 400
                        : 500, // Each card max 400px width
                mainAxisSpacing: 10,
                itemCount: dataList.length,
                itemBuilder: (context, index) {
                  return buildCard(dataList[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDispatchSection(
      String title, List<Map<String, dynamic>> dataList, BuildContext context) {
    return Expanded(
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop(context))
              Text(title,
                  style: poppinsSemiBold.copyWith(
                      fontSize: 13, color: Color(0xFF828282))),
            const SizedBox(height: 10),
            Expanded(
              child: MasonryGridView.extent(
                // crossAxisCount: 1,
                maxCrossAxisExtent: isMobile(context)
                    ? 550
                    : isTablet(context)
                        ? 400
                        : 500, // Each card max 340px width
                mainAxisSpacing: 10,
                itemCount: dataList.length,
                itemBuilder: (context, index) {
                  return buildCard(dataList[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(Map<String, dynamic> order) {
    return Container(
      width: 340,
      // padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      order['orderType'] == 'zomatao'
                          ? SizedBox(
                              width: 30,
                              child: SvgPicture.asset(Images.zomato),
                            )
                          : order['orderType'] == 'swiggy'
                              ? SizedBox(
                                  width: 20,
                                  child: SvgPicture.asset(Images.swiggy),
                                )
                              : SizedBox(
                                  width: 23,
                                  child: SvgPicture.asset(
                                    Images.app_logo,
                                  ),
                                ),
                      const SizedBox(
                        width: 7,
                      ),
                      Column(
                        children: [
                          Text(order['id'],
                              style: poppinsSemiBold.copyWith(
                                  fontSize: 13,
                                  color: order['orderType'] == 'zomatao'
                                      ? Color(0xFFE23744)
                                      : order['orderType'] == 'swiggy'
                                          ? Color(0xFFF08520)
                                          : Color(0xFF329937))),
                          const SizedBox(height: 2),
                          Text(
                            '15 mins ago',
                            style: poppinsSemiBold.copyWith(
                                fontSize: 7, color: Color(0xFF828282)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                // Spacer(),
                Row(
                  children: [
                    order['status'] == '1'
                        ? ConstrainedBox(
                            // constraints: BoxConstraints(maxWidth: 45),
                            constraints: BoxConstraints(maxWidth: 100),

                            child: Text(
                              'Cooking',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: poppinsSemiBold.copyWith(
                                  fontSize: 12, color: Color(0xFF828282)),
                            ),
                          )
                        : order['status'] == '2'
                            ? ConstrainedBox(
                                // constraints: BoxConstraints(maxWidth: 45),
                                constraints: BoxConstraints(maxWidth: 100),

                                child: Text(
                                  'Dispatched',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: poppinsSemiBold.copyWith(
                                      fontSize: 12, color: Color(0xFF828282)),
                                ),
                              )
                            : order['status'] == '3'
                                ? ConstrainedBox(
                                    // constraints: BoxConstraints(maxWidth: 50),
                                    constraints: BoxConstraints(maxWidth: 100),

                                    child: Text(
                                      'Delivered',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: poppinsSemiBold.copyWith(
                                          fontSize: 12,
                                          color: Color(0xFF828282)),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () {
                                      // setState(() {
                                      //   status++;
                                      // });
                                    },
                                    child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            // border: Border.all(
                                            //     color: Color(0xFFDFDFDF)),
                                            color: Color(0xFFC6C6C6),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Icon(
                                          Icons.close,
                                          size: 18,
                                          // color: ColorTheme.borderGrey,
                                          color: Colors.white,
                                        )),
                                  ),
                    const SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            // border: Border.all(color: Color(0xFFDFDFDF)),
                            color: ColorTheme.green,
                            borderRadius: BorderRadius.circular(20)),
                        child: Icon(
                          Icons.check,
                          size: 18,
                          // color: ColorTheme.borderGrey,
                          color: ColorTheme.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Divider(
              color: Color(0xFFEFEFEF),
              height: 0,
            ),
          ),
          if (order.containsKey('runner')) SizedBox(height: 5),
          if (order.containsKey('runner'))
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 17,
                      backgroundImage: NetworkImage(
                          'https://randomuser.me/api/portraits/men/1.jpg'),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Runner Name',
                              style: poppinsSemiBold.copyWith(
                                  fontSize: 10, color: Color(0xFF828282))),

                          // Text('9662666737  |  MyGenie ID No.')
                          RichText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              text: TextSpan(children: [
                                TextSpan(
                                    text: '9662666737',
                                    style: poppinsSemiBold.copyWith(
                                        fontSize: 9, color: Color(0xFF828282))),
                                TextSpan(
                                    text: ' ',
                                    style: poppinsSemiBold.copyWith(
                                        fontSize: 8.5,
                                        color: Color(0xFF828282))),
                                TextSpan(
                                    text: '|',
                                    style: poppinsSemiBold.copyWith(
                                        fontSize: 10,
                                        color: Color(0xFF828282))),
                                TextSpan(
                                    text: ' ',
                                    style: poppinsSemiBold.copyWith(
                                        fontSize: 8, color: Color(0xFF828282))),
                                TextSpan(
                                    text: 'MyGenie ID No.',
                                    style: poppinsSemiBold.copyWith(
                                        fontSize: 9,
                                        color: order['orderType'] == 'zomatao'
                                            ? Color(0xFFE23744)
                                            : order['orderType'] == 'swiggy'
                                                ? Color(0xFFF08520)
                                                : Color(0xFF329937))),
                              ])),
                        ],
                      ),
                    ),
                    // const Spacer(),
                    InkWell(
                        onTap: () {
                          // _launchCaller('9662666737');
                        },
                        child: SizedBox(
                            width: 29,
                            child: SvgPicture.asset(Images.Phone_icon2)))
                  ],
                )),
          if (order.containsKey('runner'))
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(
                color: Color(0xFFEFEFEF),
                height: 0,
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: order.containsKey('runner')
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...order['items'].map<Widget>((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.circle,
                                        size: 6,
                                        color: item['type'] == 'veg'
                                            ? Colors.green
                                            : Colors.red),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${item['name']} (${item['qty']})',
                                            style: poppinsSemiBold.copyWith(
                                              fontSize: 11,
                                              color: Color(0xFF828282),
                                            ),
                                          ),
                                          if (item.containsKey('variant'))
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Variant: ',
                                                    style: poppinsSemiBold
                                                        .copyWith(
                                                            fontSize: 8,
                                                            color: ColorTheme
                                                                .blue),
                                                  ),
                                                  TextSpan(
                                                    text: item['variant'],
                                                    style: poppinsSemiBold
                                                        .copyWith(
                                                            fontSize: 8,
                                                            color: Color(
                                                                0xFF828282)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (item.containsKey('addon'))
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Addon:',
                                                    style: poppinsSemiBold
                                                        .copyWith(
                                                            fontSize: 8,
                                                            color: ColorTheme
                                                                .blue),
                                                  ),
                                                  TextSpan(
                                                    text: item['addon'],
                                                    style: poppinsSemiBold
                                                        .copyWith(
                                                            fontSize: 8,
                                                            color: Color(
                                                                0xFF828282)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${order['amount']}  ',
                                  style: poppinsSemiBold.copyWith(
                                      fontSize: 13, color: ColorTheme.green),
                                ),
                                const SizedBox(height: 0),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Customer ID: ',
                                        style: poppinsSemiBold.copyWith(
                                            fontSize: 8,
                                            color: Color(0xFF828282)),
                                      ),
                                      TextSpan(
                                        text: order['customerId'],
                                        style: poppinsSemiBold.copyWith(
                                            fontSize: 8,
                                            color: Color(0xFF828282)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: order['items'].length * 22 +
                                10.toDouble(), // dynamic height based on items
                            width: 1,
                            color: Color(0xFFDFDFDF),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: ColorTheme.borderGrey),
                              ),
                              child: SvgPicture.asset(
                                Images.Phone_icon,
                                height: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: order['items'].map<Widget>((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.grey.shade300, width: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6,
                              color: item['type'] == 'veg'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${item['name']} (${item['qty']})',
                                style: poppinsSemiBold.copyWith(
                                  fontSize: 11,
                                  color: Color(0xFF828282),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          if (order.containsKey('runner'))
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(
                color: Color(0xFFEFEFEF),
                height: 0,
              ),
            ),
          if (!order.containsKey('runner'))
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 9, top: 9, right: 10, left: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(order['amount'],
                          style: poppinsSemiBold.copyWith(
                              fontSize: 15, color: ColorTheme.green)),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 80),
                        child: Text(
                          'Customer ID | ${order['customerId']}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: poppinsSemiBold.copyWith(
                              fontSize: 8, color: Color(0xFF828282)),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFDFDFDF),
                        ),
                        borderRadius: BorderRadius.circular(25)),
                    child: ConstrainedBox(
                      // constraints: BoxConstraints(maxWidth: 50),
                      constraints: BoxConstraints(maxWidth: 100),

                      child: Text(
                        'Call Customer',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: poppinsSemiBold.copyWith(
                            fontSize: 9, color: Color(0xFFFF7E27)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (order['type'] == 'cooking')
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, right: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFE100),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Print Bill',
                      style: poppinsSemiBold.copyWith(
                        fontSize: 12,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFE100),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Print KOT',
                      style: poppinsSemiBold.copyWith(
                        fontSize: 12,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                  ),
                  if (order['orderType'] == 'mygenie') Spacer(),
                  if (order['orderType'] == 'mygenie')
                    InkWell(
                      onTap: () {
                        // setState(() {
                        //   status++;
                        // });
                      },
                      child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              // border: Border.all(
                              //     color: Color(0xFFDFDFDF)),
                              color: Color(0xFFC6C6C6),
                              borderRadius: BorderRadius.circular(20)),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            // color: ColorTheme.borderGrey,
                            color: Colors.white,
                          )),
                    ),
                ],
              ),
            ),
          // Text(order['amount'],
          //     style:
          //         TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          // Text('Customer ID | ${order['customerId']}',
          //    style: poppinsSemiBold.copyWith(
          //                               fontSize: 8, color: Color(0xFF828282)),),
          if (order['type'] == 'dispatch' && order.containsKey('otp'))
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, right: 10, left: 10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFE100),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Print Bill',
                        style: poppinsSemiBold.copyWith(
                          fontSize: 12,
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                    ),
                    if (order['orderType'] == 'mygenie')
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: InkWell(
                          onTap: () {
                            // setState(() {
                            //   status++;
                            // });
                          },
                          child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  // border: Border.all(
                                  //     color: Color(0xFFDFDFDF)),
                                  color: Color(0xFFC6C6C6),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                // color: ColorTheme.borderGrey,
                                color: Colors.white,
                              )),
                        ),
                      ),
                    if (order['orderType'] == 'mygenie') Spacer(),
                    if (order['orderType'] == 'mygenie')
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xFFDFDFDF),
                            ),
                            borderRadius: BorderRadius.circular(25)),
                        child: ConstrainedBox(
                          // constraints: BoxConstraints(maxWidth: 45),
                          constraints: BoxConstraints(maxWidth: 100),

                          child: Text(
                            'Assign Runner',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: poppinsSemiBold.copyWith(
                                fontSize: 9, color: Color(0xFFFF7E27)),
                          ),
                        ),
                      ),
                    if (order['orderType'] != 'mygenie')
                      Text(
                        'OTP 4356',
                        style: poppinsSemiBold.copyWith(
                            fontSize: 13, color: Color(0xFF2E2E2E)),
                      ),
                  ]),
            )
        ],
      ),
    );
  }
}
