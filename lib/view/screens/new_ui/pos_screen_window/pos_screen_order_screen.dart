// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/pos_screen_window/review_order.dart';

// Guru ji ki jai ho
//mai comment me sari cheeze likh de rha hu ..by any chance if you face any problem please call me

// ye controller mai apne liye banaya tha ....aap ise hata skte ho
class OrderPosController extends GetxController {
  var orders = <Map<String, dynamic>>[].obs;
  var selectedReason = ''.obs;
  var isClicked = false.obs;

  void toggleColor() {
    isClicked.value = !isClicked.value;
  }

  List<String> reasons = [
    "Order placed by mistake",
    "Food quality issue",
    "Delivery is taking too long"
  ];

  void setReason(String? reason) {
    selectedReason.value = reason!;
  }

  void addOrder(String? name, int? quantity, double? price,
      {String? customization}) {
    orders.add({
      'name': name ?? '',
      'quantity': quantity ?? '1',
      'price': price ?? '600',
      'customization': customization ?? "",
    });
  }

  void removeOrder(int index) {
    orders.removeAt(index);
  }
}

class OrderPosTabletScreen extends StatelessWidget {
  OrderPosTabletScreen({super.key});

  final OrderPosController orderController = Get.put(OrderPosController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    bool isSwitched = true;
    List selectedOrder = [0, 1, 2, 3, 4];

    final gridItemWidth = screenWidth * 0.1;
    final gridItemHeight = screenHeight * 0.22;
    final circleAvatarSize = gridItemWidth * 0.25;
    final fontSize18 = screenWidth * 0.0095;
    final fontSize24 = screenWidth * 0.013;

    final fontSize25 = screenWidth * 0.0095;

    //  Add Food Dialog
    void showAddFoodCustomizationDialog(BuildContext context, String itemName) {
      TextEditingController customController = TextEditingController();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          bool? switchNotes ;
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            child: Container(
              width: 520,
              decoration: BoxDecoration(color: Colors.white),
              // padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Close Button
                  Padding(
                    padding: EdgeInsets.only(top: 20, right: 20, left: 20),
                    child: Row(
                      children: [
                        Text(
                          itemName,
                          style: montserratMedium.copyWith(
                              fontSize: 20, color: Color(0xFF747474)),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(
                             Icons.close,
                            color: Color(0xFF747474),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      color: Color(0xFFE7E7E7),
                      height: 20,
                      thickness: 1,
                    ),
                  ),

                  SizedBox(height: 10),

                  // Size Selection
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Size (Required)',
                      textAlign: TextAlign.start,
                      style: montserratMedium.copyWith(
                          fontSize: 12, color: Color(0xFF8C8C8C)),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Radio(
                            //     value: value['label'],
                            //     groupValue: selectedValue,
                            //     onChanged: () {}),
                            Icon(
                              Icons.radio_button_checked,
                              color: Color(0xFF797979),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              '30 ml',
                              style: montserratMedium.copyWith(
                                  fontSize: fontSize18,
                                  color: Color(0xFF2E2E2E)),
                            ),
                            Spacer(),
                            Text(
                              '₹ 300',
                              style: montserratMedium.copyWith(
                                  fontSize: fontSize18,
                                  color: Color(0xFF18A84A)),
                            )
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            // Radio(
                            //     value: value['label'],
                            //     groupValue: selectedValue,
                            //     onChanged: () {}),
                            Icon(
                              Icons.radio_button_checked,
                              color: Color(0xFF797979),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              '60 ml',
                              style: montserratMedium.copyWith(
                                  fontSize: fontSize18,
                                  color: Color(0xFF2E2E2E)),
                            ),
                            Spacer(),
                            Text(
                              '₹ 600',
                              style: montserratMedium.copyWith(
                                  fontSize: fontSize18,
                                  color: ColorTheme.green),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                   SizedBox(height: 30),

                  // Addon Here
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Addon',
                      textAlign: TextAlign.start,
                      style: montserratMedium.copyWith(
                          fontSize: 12, color: Color(0xFF8C8C8C)),
                    ),
                  ),
                  SizedBox(height: 10),

                  Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20),

                    child: Row(
                            children: [
                            Checkbox(
                    value: switchNotes ?? true ,
                    onChanged: (value) {
                      // setState(() {
                      //   switchNotes = value;
                      // });
                    },
                    activeColor: Color(0xFFFF7E27),
                  ),
                             
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Garlic',
                                style: montserratMedium.copyWith(
                                    fontSize: fontSize18,
                                    color: Color(0xFF2E2E2E)),
                              ),
                              Spacer(),
                              Text(
                                '₹ 20',
                                style: montserratMedium.copyWith(
                                    fontSize: fontSize18,
                                    color: Color(0xFF18A84A)),
                              )
                            ],
                          ),
                  ),
                  // SizedBox(height: 10),

                  Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20),

                    child: Row(
                            children: [
                            Checkbox(
                    value: switchNotes ?? true ,
                    onChanged: (value) {
                      // setState(() {
                      //   switchNotes = value;
                      // });
                    },
                    activeColor: Color(0xFFFF7E27),
                  ),
                             
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Cheese',
                                style: montserratMedium.copyWith(
                                    fontSize: fontSize18,
                                    color: Color(0xFF2E2E2E)),
                              ),
                              Spacer(),
                              Text(
                                '₹ 150',
                                style: montserratMedium.copyWith(
                                    fontSize: fontSize18,
                                    color: Color(0xFF18A84A)),
                              )
                            ],
                          ),
                  ),

                  SizedBox(height: 20),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          'Quantity',
                          style: montserratMedium.copyWith(
                              fontSize: 12, color: Color(0xFF8C8C8C)),
                        ),
                        Spacer(),
                        Text(
                          'Total',
                          style: montserratMedium.copyWith(
                              fontSize: 12, color: Color(0xFF8C8C8C)),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                            height: 40,
                            width: 119,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Color(0xFFDCDCDC)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.remove,
                                      color: Color(0xFF707070),
                                    )),
                                Text(
                                  '1',
                                  style: montserratMedium.copyWith(
                                      fontSize: fontSize18,
                                      color: Color(0xFF18A84A)),
                                ),
                                IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.add,
                                        color: Color(0xFF707070))),
                              ],
                            )),
                        Spacer(),
                        Text(
                          '₹ 600',
                          style: montserratMedium.copyWith(
                              fontSize: fontSize24, color: Color(0xFF18A84A)),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Notes Input
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: customController,
                      decoration: InputDecoration(
                        labelText: "Add Notes",
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                        labelStyle: montserratMedium.copyWith(
                            fontSize: 15, color: Color(0xFF8C8C8C)),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 35, horizontal: 20),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xFFDCDCDC),width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xFFDCDCDC),width: 2),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xFFDCDCDC),width: 2),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xFFDCDCDC),width: 2),
                        ),
                      ),
                      style: montserratMedium.copyWith(
                        fontSize: fontSize24,
                        color: Color(0xFF8C8C8C),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),
                  Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 20),

                    child: Row(
                                children: [
                                  Transform.scale(
                                    scale: 0.7,
                                    child: Switch(
                    value: isSwitched,
                    activeColor: Color(0xFF8C8C8C),
                    onChanged: (bool value) {},
                                    ),
                                  ),
                                  Text('Print KOT',
                    style: montserratMedium.copyWith(
                        color: Color(0xFF8C8C8C), fontSize: 16, height: 19 / 16)),
                                ],
                              ),
                  ),
                  SizedBox(height: 30),


                  GestureDetector(
                    onTap: () {
                      orderController.addOrder(itemName, 1, 600,
                          customization: customController.text);

                      Get.back();
                    },
                    child: Container(
                      height: screenHeight * 0.07,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFF18A84A),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Text(
                        'Add to Order',
                        style: montserratSemiBold.copyWith(
                            fontSize: fontSize18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    void showCancelFoodCustomizationDialog( BuildContext context, String itemName, int id) {
      TextEditingController customController = TextEditingController();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            child: Container(
              width: 520,
              decoration: BoxDecoration(color: Colors.white),
              // padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Close Button
                  Padding(
                    padding: EdgeInsets.only(top: 20, right: 20, left: 20),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Cancel $itemName',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: montserratMedium.copyWith(
                                fontSize: 20, color: Color(0xFF747474)),
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                             Icons.close,
                            color: Color(0xFF747474),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      color: Color(0xFFE7E7E7),
                      height: 20,
                      thickness: 1,
                    ),
                  ),

                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFDCDCDC) , width: 2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Obx(() => DropdownButton<String>(
                            dropdownColor: Color(0xFFFFFFFF),
                            items: orderController.reasons.map((String reason) {
                              return DropdownMenuItem<String>(
                                child: Text(reason,
                                    style: montserratMedium.copyWith(
                                        color: Color(0xFF8C8C8C),
                                        fontSize: 15)),
                                value: reason,
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              orderController.setReason(newValue!);
                            },
                            value: orderController.selectedReason.value == ''
                                ? null
                                : orderController.selectedReason.value,
                            hint: Text(
                              "Select the Reason",
                              style: montserratMedium.copyWith(
                                  color: Color(0xFF8C8C8C), fontSize: 15),
                            ),
                            underline: SizedBox.shrink(),
                            isExpanded: true,
                          )),
                    ),
                  ),

                  SizedBox(height: 30),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      // controller: customController,
                      decoration: InputDecoration(
                        helperMaxLines: 4,
                        labelText: "Type here...",
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                        labelStyle: montserratMedium.copyWith(
                            fontSize: 15, color: Color(0xFF8C8C8C)),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 35, horizontal: 20),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                        ),
                      ),
                      style: montserratMedium.copyWith(
                        fontSize: fontSize24,
                        color: Color(0xFF8C8C8C),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  GestureDetector(
                    onTap: () {
                      orderController.removeOrder(id);
                      orderController.selectedReason.value = '';
                      Get.back();
                    },
                    child: Container(
                      height: screenHeight * 0.07,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFF18A84A),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Text(
                        'Cancel',
                        style: montserratSemiBold.copyWith(
                            fontSize: fontSize18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    List<String> names = [
      'black dog',
      'Food item Name Here',
      'Wine(red , white , sula , madira , big banayan ,mocktail , cocktail, white , sula , madira , big banayan ,mocktail , cocktail)'
          'madira',
      'sula ',
      'Food item Name Here',
      "Gorgons Gin",
      'black dog',
      'sula ',
      'Food item Name Here',
      'black dog',
      'madira',
      'black dog',
      'Food item Name Here',
      'sula ',
      "Gorgons Gin",
      'Food item Name Here',
      'sula ',
      'Food item Name Here',
      'black dog',
    ];

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.09,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.deepOrangeAccent, size: screenHeight * 0.035),
            onPressed: () {
              orderController.orders.clear();
              Get.back();
            },
          ),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            selectedOrder[0] == 1
                ? CircleAvatar(
                    backgroundColor: selectedOrder[0] == 0
                        ? Color(0xFFFF7E27)
                        : Color(0xFF18A84A),
                    // radius: circleAvatarSize,
                    radius: screenWidth * 0.017,
                    child: Text(
                      'T 1',
                      style: montserratSemiBold.copyWith(
                        fontSize: fontSize24,
                        color: Colors.white,
                      ),
                    ),
                  )
                : CircleAvatar(
                    backgroundColor: Color(0xFFF1F1F1),
                    // radius: circleAvatarSize,
                    radius: screenWidth * 0.017,
                    child: Text(
                      'T 1',
                      style: montserratSemiBold.copyWith(
                        fontSize: fontSize24,
                        color: Color(0xFF848484),
                      ),
                    ),
                  ),
            SizedBox(
              width: 30,
            ),
            Container(
              color: Color(0xFFDFDFDF),
              width: 2,
              height: screenHeight * 0.09,
            ),
            SizedBox(
              width: 30,
            ),
            IconButton(
              icon: Obx(() => Icon(Icons.person,
                  size: screenHeight * 0.035,
                  color: orderController.isClicked.value
                      ? Color(0xFF18A84A)
                      : Color(0xFFDADADA))),
              onPressed: () {
                orderController.isClicked.value =
                    !orderController.isClicked.value;
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return CustomerDetails();
                    });
              },
            ),
            SizedBox(
              width: 30,
            ),
            InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AddNoteDialog();
                      });
                },
                child: SvgPicture.asset(
                  Images.article_icon,
                  width: screenWidth * 0.016,
                )),
            SizedBox(
              width: 30,
            ),
            InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return MergeTableDialog();
                    });
              },
              child: Image.asset(
                Images.merge_table,
                // width: 40,
                // height: 50,
                width: screenWidth * 0.021, height: screenHeight * 0.041,
              ),
            ),
            SizedBox(
              width: 30,
            ),
            InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return ShiftTableDialog();
                    });
              },
              child: Image.asset(
                Images.shift_table,
                // width: 35,
                // height: 40,
                width: screenWidth * 0.018, height: screenHeight * 0.03,
              ),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          Row(
            children: [
              Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: isSwitched,
                  activeColor: Color(0xFF18A84A),
                  onChanged: (bool value) {},
                ),
              ),
              Text('Print All KOT\'s',
                  style: montserratMedium.copyWith(
                      color: Color(0xFF8C8C8C), fontSize: 13, height: 19 / 16)),
            ],
          ),
          VerticalDivider(
            color: Color(0xFFDFDFDF),
            width: 30,
            thickness: 1,
            endIndent: 12,
            indent: 12,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: Colors.green[500],
                    size: 15,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Online',
                    style: montserratBold.copyWith(
                        fontSize: 16,
                        color: Color(0xFF18A84A),
                        height: 19 / 16),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Last Synced',
                    style: montserratMedium.copyWith(
                      fontSize: 12,
                      color: Color(0xFF8C8C8C),
                      height: 15 / 12,
                    ),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Text(
                    'Just Now',
                    style: montserratSemiBold.copyWith(
                      fontSize: 12,
                      color: Color(0xFF636363),
                      height: 15 / 12,
                    ),
                  ),
                ],
              )
            ],
          ),
          SizedBox(
            width: 40,
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar Menu container
          Expanded(
            flex: 2,
            child: Container(
              // width: screenWidth*0.3,
              color: Color(0xFFF1F1F1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SidebarButton(title: "Popular", isSelected: true),
                  SidebarButton(title: "Starters"),
                  SidebarButton(title: "Main Course"),
                  SidebarButton(title: "Bar"),
                  SidebarButton(title: "Dessert"),
                ],
              ),
            ),
          ),

          // Middle Section (Search + Items) container
          Expanded(
            flex: 5,
            child: Container(
              // width: screenWidth*0.8,
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  // Search Bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: TextField(
                      decoration: InputDecoration(
                        fillColor: Color(0xFFFFFFFF),
                        filled: true,
                        hintText: 'Search Food',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFFBEBEBE),
                        ),
                        hintStyle: montserratMedium.copyWith(
                          fontSize: 16,
                          color: Color(0xFFBEBEBE),
                          height: 16 / 19,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      style: montserratMedium.copyWith(
                        fontSize: 16,
                        color: Color(0xFFBEBEBE),
                        height: 16 / 19,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Divider(),
                  SizedBox(
                    height: 20,
                  ),
                  // Items List (Chips Style)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: SingleChildScrollView(
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 20,
                          runSpacing: 30,
                          children: names
                              .map((name) => GestureDetector(
                                    onTap: () {
                                      if (name == "Gorgons Gin") {
                                        showAddFoodCustomizationDialog(
                                            context, name);
                                      } else {
                                        orderController.addOrder(name, 1, 600);
                                      }
                                    },
                                    child: ItemChip(name: name),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // Order Summary container
          Expanded(
            flex: 3,
            child: Container(
              // width: screenWidth*0.6,
              color: Color(0xFFFFFFFF),
              child: Column(
                //  mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ye wala sirf add order krne pe show krega
                  Expanded(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Table(
                          columnWidths: {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                          },
                          border: TableBorder(
                            top: BorderSide(color: Color(0xFFE7E7E7), width: 1),
                            // bottom: BorderSide(color: Colors.grey, width: 1.5),
                            horizontalInside:
                                BorderSide(color: Color(0xFFE7E7E7), width: 1),
                            verticalInside:
                                BorderSide(color: Color(0xFFE7E7E7), width: 1),
                          ),
                          children: [
                            TableRow(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text('Food Item',
                                      style: montserratMedium.copyWith(
                                          fontSize: 12,
                                          color: Color(0xFF8C8C8C))),
                                ),
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text('Quantity',
                                        style: montserratMedium.copyWith(
                                            fontSize: 12,
                                            color: Color(0xFF8C8C8C))),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text('Price',
                                        style: montserratMedium.copyWith(
                                            fontSize: 12,
                                            color: Color(0xFF8C8C8C))),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Obx(
                              () => Table(
                                columnWidths: {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(1),
                                },
                                border: TableBorder(
                                  top: BorderSide(
                                      color: Color(0xFFE7E7E7), width: 1),
                                  bottom: BorderSide(
                                      color: Color(0xFFE7E7E7), width: 1),
                                  horizontalInside: BorderSide(
                                      color: Color(0xFFE7E7E7), width: 1),
                                  verticalInside: BorderSide(
                                      color: Color(0xFFE7E7E7), width: 1),
                                ),
                                children: orderController.orders.map((order) {
                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                showCancelFoodCustomizationDialog(
                                                    context,
                                                    order['name'],
                                                    orderController.orders
                                                        .indexOf(order));
                                              },
                                              icon: SvgPicture.asset(
                                                  Images.Cancel),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    order['name'],
                                                    style: montserratMedium
                                                        .copyWith(
                                                            fontSize:
                                                                fontSize18,
                                                            color: Color(
                                                                0xFF2E2E2E)),
                                                    // overflow: TextOverflow.fade,
                                                    // maxLines: 2,
                                                  ),
                                                  if (order['customization'] !=
                                                          null &&
                                                      order['customization']
                                                          .toString()
                                                          .trim()
                                                          .isNotEmpty)
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 5.0),
                                                      child: RichText(
                                                          text: TextSpan(
                                                              children: [
                                                            TextSpan(
                                                                text:
                                                                    'Variant: ',
                                                                style: montserratMedium
                                                                    .copyWith(
                                                                        fontSize:
                                                                            16,
                                                                        color: Color(
                                                                            0xFF0090FF))),
                                                            TextSpan(
                                                                text: order[
                                                                    'customization'],
                                                                style: montserratMedium
                                                                    .copyWith(
                                                                        fontSize:
                                                                            16,
                                                                        color: Color(
                                                                            0xFF2E2E2E))),
                                                          ])),
                                                    ),
                                                  SizedBox(height: 10),
                                                    (order['customization'] !=
                                                          null &&
                                                      order['customization']
                                                          .toString()
                                                          .trim()
                                                          .isNotEmpty) ? Text(
                                                    'Customization',
                                                    style: montserratBold
                                                        .copyWith(
                                                            fontSize: 15,
                                                            color: ColorTheme.green),
                                                  ) : SizedBox.shrink(),
                                                  SizedBox(height: 10),
                                                  InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AddNoteDialog();
                                                        },
                                                      );
                                                    },
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text('Add Note',
                                                          style: montserratSemiBold
                                                              .copyWith(
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                      0xFFCACACA))),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          // height: 40,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(Icons.remove,
                                                      color:
                                                          Color(0xFF707070))),
                                              Text(
                                                '1',
                                                style:
                                                    montserratSemiBold.copyWith(
                                                        fontSize: fontSize18,
                                                        color:
                                                            Color(0xFF18A84A)),
                                              ),
                                              IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(Icons.add,
                                                      color:
                                                          Color(0xFF707070))),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Text(
                                            "₹${order['price']}",
                                            style: montserratMedium.copyWith(
                                                fontSize: fontSize18,
                                                color: Color(0xFF18A84A)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Spacer(),
                  // Divider(),

                  // ye jab hum order place krne ke baad edit order pe jate hai...to food status config. based rehga ( ready , serve)
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Obx(
                        () => Table(
                          columnWidths: {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                          },
                          border: TableBorder(
                            top: BorderSide(color: Color(0xFFE7E7E7), width: 1),
                            bottom:
                                BorderSide(color: Color(0xFFE7E7E7), width: 1),
                            horizontalInside:
                                BorderSide(color: Color(0xFFE7E7E7), width: 1),
                            verticalInside:
                                BorderSide(color: Color(0xFFE7E7E7), width: 1),
                          ),
                          children: orderController.orders.map((order) {
                            return TableRow(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          showCancelFoodCustomizationDialog(
                                              context,
                                              order['name'],
                                              orderController.orders
                                                  .indexOf(order));
                                        },
                                        icon: SvgPicture.asset(Images.Cancel),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              order['name'],
                                              style: montserratMedium.copyWith(
                                                  fontSize: fontSize18,
                                                  color: Color(0xFF2E2E2E)),
                                              // overflow: TextOverflow.fade,
                                              // maxLines: 2,
                                            ),
                                            if (order['customization'] !=
                                                    null &&
                                                order['customization']
                                                    .toString()
                                                    .trim()
                                                    .isNotEmpty)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5.0),
                                                child: RichText(
                                                    text: TextSpan(children: [
                                                  TextSpan(
                                                      text: 'Variant: ',
                                                      style: montserratMedium
                                                          .copyWith(
                                                              fontSize: 16,
                                                              color: Color(
                                                                  0xFF0090FF))),
                                                  TextSpan(
                                                      text: order[
                                                          'customization'],
                                                      style: montserratMedium
                                                          .copyWith(
                                                              fontSize: 16,
                                                              color: Color(
                                                                  0xFF2E2E2E))),
                                                ])),
                                              ),
                                            SizedBox(height: 10),
                                            Text(
                                              '15 min ago',
                                              style: montserratMedium.copyWith(
                                                  fontSize: 13,
                                                  color: Color(0xFF8C8C8C)),
                                            ),
                                            SizedBox(height: 10),
                                            InkWell(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return TransferFoodDialog();
                                                  },
                                                );
                                              },
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  'Transfer Food',
                                                  style:
                                                      montserratSemiBold.copyWith(
                                                          fontSize: 12,
                                                          color: Color(
                                                              0xFFCACACA)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                //yaha pe agr hum edit pe click krte hai to -1+ is trah aayega
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    // height: 40,
                                    child: selectedOrder[0] == 0
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '1',
                                                style:
                                                    montserratSemiBold.copyWith(
                                                        fontSize: fontSize18,
                                                        color:
                                                            Color(0xFF18A84A)),
                                              ),
                                              IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(Icons.edit,
                                                      color:
                                                          Color(0xFF707070))),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(Icons.remove,
                                                      color:
                                                          Color(0xFF707070))),
                                              Text(
                                                '1',
                                                style:
                                                    montserratSemiBold.copyWith(
                                                        fontSize: fontSize18,
                                                        color:
                                                            Color(0xFF18A84A)),
                                              ),
                                              IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(Icons.add,
                                                      color:
                                                          Color(0xFF707070))),
                                            ],
                                          ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      "₹${order['price']}",
                                      style: montserratMedium.copyWith(
                                          fontSize: fontSize18,
                                          color: Color(0xFF18A84A)),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),

                  // ye jab hum order place krne ke baad edit order pe jate hai...to food status config. based rehga ( delivered)
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Obx(
                        () => Table(
                          columnWidths: {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                          },
                          border: TableBorder(
                            top: BorderSide(color: Color(0xFFE7E7E7), width: 1),
                            bottom:
                                BorderSide(color: Color(0xFFE7E7E7), width: 1),
                            horizontalInside:
                                BorderSide(color: Color(0xFFE7E7E7), width: 1),
                            verticalInside:
                                BorderSide(color: Color(0xFFE7E7E7), width: 1),
                          ),
                          children: orderController.orders.map((order) {
                            return TableRow(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          showCancelFoodCustomizationDialog(
                                              context,
                                              order['name'],
                                              orderController.orders
                                                  .indexOf(order));
                                        },
                                        icon: SvgPicture.asset(Images.Cancel),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              order['name'],
                                              style: montserratMedium.copyWith(
                                                  fontSize: fontSize18,
                                                  color: Color(0xFF2E2E2E)),
                                              // overflow: TextOverflow.fade,
                                              // maxLines: 2,
                                            ),
                                            if (order['customization'] !=
                                                    null &&
                                                order['customization']
                                                    .toString()
                                                    .trim()
                                                    .isNotEmpty)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5.0),
                                                child: RichText(
                                                    text: TextSpan(children: [
                                                  TextSpan(
                                                      text: 'Variant: ',
                                                      style: montserratMedium
                                                          .copyWith(
                                                              fontSize: 16,
                                                              color: Color(
                                                                  0xFF0090FF))),
                                                  TextSpan(
                                                      text: order[
                                                          'customization'],
                                                      style: montserratMedium
                                                          .copyWith(
                                                              fontSize: 16,
                                                              color: Color(
                                                                  0xFF2E2E2E))),
                                                ])),
                                              ),
                                            SizedBox(height: 10),
                                            Text(
                                              '15 min ago',
                                              style: montserratMedium.copyWith(
                                                  fontSize: 13,
                                                  color: Color(0xFF8C8C8C)),
                                            ),
                                            SizedBox(height: 10),
                                            InkWell(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return TransferFoodDialog();
                                                  },
                                                );
                                              },
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  'Transfer Food',
                                                  style:
                                                      montserratMedium.copyWith(
                                                          fontSize: 12,
                                                          color: Color(
                                                              0xFFCACACA)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // yaha pe sirf quantity show kregi (1)
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      '1',
                                      style: montserratSemiBold.copyWith(
                                          fontSize: fontSize18,
                                          color: Color(0xFF18A84A)),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      "₹${order['price']}",
                                      style: montserratMedium.copyWith(
                                          fontSize: fontSize18,
                                          color: Color(0xFF18A84A)),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),

                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                Future.delayed(Duration(seconds: 1), () {
                                  Navigator.of(context).pop();
                                });
                                return OrderEditDailog();
                              },
                            );
                          },
                          //yaha color pe first time order le rhe hai to grey wala background color ke sath black text color ....or agr edit pe hai to oraange with white
                          child: Container(
                            height: screenHeight * 0.08,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: selectedOrder[0] == 1
                                    ? Color(0xFFFF7E27)
                                    : Color(0xFFDCDCDC)),
                            child: Text(
                              'Place Order(2)',
                              style: montserratSemiBold.copyWith(
                                fontSize: fontSize18,
                                color: selectedOrder[0] == 1
                                    ? Color(0xFFFFFFFF)
                                    : Color(0xFF2E2E2E),
                                height: 18 / 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Builder(builder: (context) {
                          return InkWell(
                            onTap: () {
                              // Get.back();
                              Scaffold.of(context).openEndDrawer();
                            },
                            child: Container(
                              height: screenHeight * 0.08,
                              alignment: Alignment.center,
                              decoration:
                                  BoxDecoration(color: Color(0xFF18A84A)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  InkWell(
                                    onTap: () {},
                                    child: Text(
                                      'Collect Bill',
                                      style: montserratSemiBold.copyWith(
                                        fontSize: fontSize18,
                                        color: Color(0xFFFFFFFF),
                                        height: 18 / 22,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '1800',
                                    style: montserratSemiBold.copyWith(
                                      fontSize: 25,
                                      color: Color(0xFFFFFFFF),
                                      height: 18 / 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      // ElevatedButton(
                      //   style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.green),
                      //   onPressed: () {
                      //     showDialog(
                      //       context: context,
                      //       builder: (BuildContext context) {
                      //         Future.delayed(Duration(seconds: 1), () {
                      //           Navigator.of(context).pop();
                      //         });
                      //         return OrderEditDailog();
                      //       },
                      //     );
                      //   },
                      //   child: Text("Collect Bill"),
                      // ),
                    ],
                  ),

                  // Positioned(child: Icon(Icons.a.))
                ],
              ),
            ),
          ),
        ],
      ),
      endDrawer: SizedBox(
        width: screenWidth*0.3,
        // height: 700,
        child: Drawer(
          shape: BeveledRectangleBorder(),
          child: OrderReviewPosScreen(),
        ),
      ),
    );
  }
}

// Sidebar Button Widget
class SidebarButton extends StatelessWidget {
  final String? title;
  final bool isSelected;

  SidebarButton({this.title, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize18 = screenWidth * 0.0095;
    final fontSize20 = screenWidth * 0.0105;

    return Container(
      // padding: EdgeInsets.all(15),
      width: double.infinity,
      decoration: BoxDecoration(
          color: isSelected ? Color(0xFF18A84A) : Colors.transparent,
          border: Border(bottom: BorderSide(color: Color(0xFFE4E4E4)))),
      height: screenHeight * 0.08, //80

      child: Row(
        children: [
          SizedBox(
            width: 50,
          ),
          Text(
            title!,
            style: montserratMedium.copyWith(
                color: isSelected ? Color(0xFFFFFFFF) : Color(0xFF747474),
                fontSize: fontSize20),
          ),
          isSelected
              ? Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isSelected ? Color(0xFFFFFFFF) : Color(0xFF747474),
                  size: 20,
                )
              : SizedBox.shrink()
        ],
      ),
    );
  }
}

// Food Item Chips Widget
// yaha pe agr food item ke varations ya fir addon hai to customize show krega nd click krnw pw dialog box aayega ...other wise wo normal rhega
class ItemChip extends StatelessWidget {
  final String? name;

  const ItemChip({super.key, this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Color(0xFFDCDCDC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              name!,
              softWrap: true,
              overflow: TextOverflow.visible,
              style: montserratMedium.copyWith(
                  color: Color(0xFF747474), fontSize: 20),
            ),
          ),
          if (name == "Gorgons Gin")
            Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                "Customize",
                style: montserratBold.copyWith(color: Colors.green, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

// customer detail dialog box
class CustomerDetails extends StatelessWidget {
  final OrderPosController orderController = Get.put(OrderPosController());
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize18 = screenWidth * 0.0095;
    final fontSize25 = screenWidth * 0.0095;
    final fontSize24 = screenWidth * 0.013;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Container(
        width: screenWidth * 0.27, //520
        // padding: EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20, right: 20, left: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Customer Details',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: montserratMedium.copyWith(
                          fontSize: 20, color: Color(0xFF747474)),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      orderController.isClicked.value =
                          !orderController.isClicked.value;
                    },
                    icon: Icon(
                      Icons.close,
                      color: Color(0xFF747474),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Color(0xFFE7E7E7),
                height: 20,
                thickness: 1,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 55,
                child: TextField(
                  // controller: customController,
                  decoration: InputDecoration(
                    helperMaxLines: 4,
                    labelText: "Customer Name",
                    floatingLabelAlignment: FloatingLabelAlignment.center,
                    labelStyle: montserratMedium.copyWith(
                        fontSize: 15, color: Color(0xFF8C8C8C)),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                    ),
                  ),
                  style: montserratMedium.copyWith(
                    fontSize: fontSize24,
                    color: Color(0xFF8C8C8C),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 55,
                child: TextField(
                  // controller: customController,
                  decoration: InputDecoration(
                    helperMaxLines: 4,
                    labelText: "Customer Phone No. ",
                    floatingLabelAlignment: FloatingLabelAlignment.center,
                    labelStyle: montserratMedium.copyWith(
                        fontSize: 15, color: Color(0xFF8C8C8C)),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFDCDCDC) , width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                    ),
                  ),
                  style: montserratMedium.copyWith(
                    fontSize: fontSize24,
                    color: Color(0xFF8C8C8C),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                height: screenHeight * 0.07,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xFF18A84A),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Text(
                  'Save Details',
                  style: montserratSemiBold.copyWith(
                      fontSize: fontSize18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//order placed dialog box
class OrderEditDailog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
            width: 520,
            // height: 224,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 70,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Order Placed Successfully',
                  // 'Order Edited Successfully',
                  style: montserratMedium.copyWith(
                      fontSize: 20, color: Color(0xFF747474)),
                ),
              ],
            )));
  }
}

//merge table dialog box
//yaha pe jab hum table ko select krte hai to uska color yellow ho jaye
class MergeTableDialog extends StatelessWidget {
  final OrderPosController orderController = Get.put(OrderPosController());
  @override
  Widget build(BuildContext context) {
    bool switchNotes = false;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize18 = screenWidth * 0.0095;
    final fontSize25 = screenWidth * 0.0095;
    final fontSize24 = screenWidth * 0.013;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Container(
        width: screenWidth * 0.27,
        decoration: BoxDecoration(color: Colors.white),
        // padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20, right: 20, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Table 3",
                    style: montserratMedium.copyWith(
                        fontSize: 20, color: Color(0xFF747474)),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Merge Table",
                  style: montserratMedium.copyWith(
                      fontSize: 12, color: Color(0xFF8C8C8C)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Color(0xFFE7E7E7),
                height: 20,
                thickness: 1,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search, color: Color(0xFF8C8C8C)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFDCDCDC),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                style: montserratMedium.copyWith(
                  fontSize: fontSize18,
                  color: Color(0xFF8C8C8C),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                //  crossAxisAlignment: WrapCrossAlignment.center,
                children: List.generate(6, (index) {
                  return ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Color(0xFFDCDCDC) ,width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding:
                          EdgeInsets.symmetric(vertical: 25, horizontal: 40),
                    ),
                    child: Text(
                      "Table ${index + 1}",
                      style: montserratMedium.copyWith(
                          fontSize: 13, color: Color(0xFF8C8C8C)),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Checkbox(
                    value: switchNotes,
                    onChanged: (value) {
                      // setState(() {
                      //   switchNotes = value;
                      // });
                    },
                    activeColor: Color(0xFF18A84A),
                  ),
                  Text(
                    "Switch Notes",
                    style: montserratMedium.copyWith(
                        fontSize: 16, color: Color(0xFF747474)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                height: screenHeight * 0.07, // 70
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xFF18A84A),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Text(
                  'Merge Table',
                  style: montserratSemiBold.copyWith(
                      fontSize: fontSize18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//shift table dialog box
//yaha pe jab hum table ko select krte hai to uska color yellow ho jaye
class ShiftTableDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool switchNotes = false;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize18 = screenWidth * 0.0095;
    final fontSize25 = screenWidth * 0.0095;
    final fontSize24 = screenWidth * 0.013;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Container(
        width: screenWidth * 0.27,
        decoration: BoxDecoration(color: Colors.white),
        // padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20, right: 20, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Table / Room",
                    style: montserratMedium.copyWith(
                        fontSize: 20, color: Color(0xFF747474)),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Color(0xFFE7E7E7),
                height: 20,
                thickness: 1,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search, color: Color(0xFF8C8C8C)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFDCDCDC),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                style: montserratMedium.copyWith(
                  fontSize: fontSize18,
                  color: Color(0xFF8C8C8C),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                //  crossAxisAlignment: WrapCrossAlignment.center,
                children: List.generate(6, (index) {
                  return ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding:
                          EdgeInsets.symmetric(vertical: 25, horizontal: 40),
                    ),
                    child: Text(
                      "Table ${index + 1}",
                      style: montserratMedium.copyWith(
                          fontSize: 13, color: Color(0xFF8C8C8C)),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                height: screenHeight * 0.07,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xFF18A84A),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Text(
                  'Shift Table',
                  style: montserratSemiBold.copyWith(
                      fontSize: fontSize18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//transfer food dialog widget
//yaha pe jab hum table ko select krte hai to uska color yellow ho jaye
class TransferFoodDialog extends StatelessWidget {
  final OrderPosController orderController = Get.put(OrderPosController());
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize18 = screenWidth * 0.0095;
    final fontSize25 = screenWidth * 0.0095;
    final fontSize24 = screenWidth * 0.013;
    bool switchNotes = false;
  

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Container(
        width: screenWidth * 0.27,
        decoration: BoxDecoration(color: Colors.white),
        // padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20, right: 20, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Transfer Panner Tikka to",
                    style: montserratMedium.copyWith(
                        fontSize: 20, color: Color(0xFF747474)),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Size Table",
                  style: montserratMedium.copyWith(
                      fontSize: 12, color: Color(0xFF8C8C8C)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Color(0xFFE7E7E7),
                height: 20,
                thickness: 1,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search, color: Color(0xFFDCDCDC)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFDCDCDC),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                style: montserratMedium.copyWith(
                  fontSize: fontSize18,
                  color: Color(0xFF8C8C8C),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                //  crossAxisAlignment: WrapCrossAlignment.center,
                children: List.generate(6, (index) {
                  return ElevatedButton(
                    onPressed: () {
                 
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      foregroundColor: Colors.black,
                      backgroundColor:
                       Colors.white ,
                      side: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding:
                          EdgeInsets.symmetric(vertical: 25, horizontal: 40),
                    ),
                    child: Text(
                      "Table ${index + 1}",
                      style: montserratMedium.copyWith(
                          fontSize: 13, color: Color(0xFF8C8C8C)),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Checkbox(
                    value: switchNotes,
                    onChanged: (value) {
                      // setState(() {
                      //   switchNotes = value;
                      // });
                    },
                    activeColor: Color(0xFF18A84A),
                  ),
                  Text(
                    "Switch Notes",
                    style: montserratMedium.copyWith(
                        fontSize: 16, color: Color(0xFF747474)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                height: 70,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xFF18A84A),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Text(
                  'Transfer To Table',
                  style: montserratSemiBold.copyWith(
                      fontSize: fontSize18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//add note widget
//add note widget
class AddNoteDialog extends StatelessWidget {
  final OrderPosController orderController = Get.put(OrderPosController());
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize18 = screenWidth * 0.0095;
    final fontSize24 = screenWidth * 0.013;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Container(
        width: screenWidth * 0.27,
        decoration: BoxDecoration(color: Colors.white),
        // padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20, right: 20, left: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Add Notes',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: montserratMedium.copyWith(
                          fontSize: 20, color: Color(0xFF747474)),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: Color(0xFF747474),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Color(0xFFE7E7E7),
                height: 20,
                thickness: 1,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                // controller: customController,
                decoration: InputDecoration(
                  helperMaxLines: 4,
                  labelText: "Add Note",
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  labelStyle: montserratMedium.copyWith(
                      fontSize: 15, color: Color(0xFF8C8C8C)),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 35, horizontal: 20),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 2),
                  ),
                ),
                style: montserratMedium.copyWith(
                  fontSize: fontSize24,
                  color: Color(0xFF8C8C8C),
                ),
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        color: Color(0xFF18A84A),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Add Note',
                        style: montserratSemiBold.copyWith(
                            fontSize: 16, color: Color(0xFF18A84A)),
                      ),
                    ],
                  )),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                height: screenHeight * 0.07,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xFF18A84A),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Text(
                  'Save Notes',
                  style: montserratSemiBold.copyWith(
                      fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
