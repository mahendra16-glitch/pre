import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/pos_screen_window/pos_partail_paymeny.dart';




// sir is wale aap bar me menu icon apne aap aa rha hai....i don't know why

class OrderReviewPosScreen extends StatelessWidget {
  const OrderReviewPosScreen({super.key});
  

  @override
  Widget build(BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize18 = screenWidth * 0.0095;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "Review Order",
          style: montserratMedium.copyWith(color: Colors.black, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: Container(
        width: 800,
        height: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(0)),
            border: Border(top: BorderSide(color: Color(0xFFE7E7E7)))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Order Id :",
                          style: montserratSemiBold.copyWith(
                            color: ColorTheme.blue,
                            fontSize: 20,
                          ),
                        ),
                        TextSpan(
                          text: " D-108219",
                          style: montserratSemiBold.copyWith(
                            color: ColorTheme.blackColor,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                _buildOrderItem(
                    "Absolute Vodka, Small(30ML), Addon Garlic x1", 250),
                _buildOrderItem("Banjara Chicken x1", 250),
                _buildOrderItem("Food Name Comes Here x1", 250),
                SizedBox(height: 15),
                Divider(
                  color: Color(0xFFE7E7E7),
                ),
                _buildPriceRow("Sub Total", "₹0.00"),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Discount',
                          style: montserratMedium.copyWith(
                            color: Color(0xFF8C8C8C),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                        width: 60,
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: "0",
                            // labelText: "0",
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 1), //
                            labelStyle: poppinsMedium.copyWith(
                                fontSize: 16, color: Color(0xFF828282)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFC6C6C6),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFC6C6C6),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFC6C6C6),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFC6C6C6),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Add Tips',
                          style: montserratMedium.copyWith(
                            color: Color(0xFF8C8C8C),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                        width: 60,
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: "0",
                            // labelText: "0",
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 1), //
                            labelStyle: poppinsMedium.copyWith(
                                fontSize: 16, color: Color(0xFF828282)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFC6C6C6),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFC6C6C6),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFC6C6C6),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFC6C6C6),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: true,
                          onChanged: (value) {},
                          activeColor: Color(0xFF8C8C8C),
                        ),
                        Text(
                          'Service Charge 10%',
                          style: montserratMedium.copyWith(
                            color: Color(0xFF8C8C8C),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Text(
                        '10%',
                        style: montserratMedium.copyWith(
                          color: Color(0xFF8C8C8C),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                _buildPriceRow("CGST", "19.13"),
                _buildPriceRow("SGST", "19.13"),
                // Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Bill",
                        style: poppinsBold.copyWith(
                          color: Color(0xFF8C8C8C),
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        "1800",
                        style: poppinsBold.copyWith(
                          color: ColorTheme.green,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Divider(
                  color: Color(0xFFE7E7E7),
                ),
                SizedBox(height: 10),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            decoration: InputDecoration(
                              // hintText: "10000",
                              labelText: "Name",
                              labelStyle: poppinsMedium.copyWith(
                                  fontSize: 16, color: Color(0xFF828282)),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFC6C6C6),
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFC6C6C6),
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFC6C6C6),
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFC6C6C6),
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: "Phone No.",
                              labelStyle: poppinsMedium.copyWith(
                                  fontSize: 16, color: Color(0xFF828282)),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFC6C6C6),
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFC6C6C6),
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFC6C6C6),
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFC6C6C6),
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
            Builder(
              builder: (context) {
                return InkWell(
                  onTap: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: screenHeight*0.07,
                    decoration: BoxDecoration(color: ColorTheme.green),
                    child: Text(
                      'Confirm Payment',
                      style: montserratBold.copyWith(
                        color: ColorTheme.white,
                        fontSize: fontSize18,
                      ),
                    ),
                  ),
                );
              }
            )
          ],
        ),
      ),
      endDrawer: SizedBox(
        width: screenWidth*0.3,
        // height: 700,
        child: Drawer(
          shape: BeveledRectangleBorder(),
          child: PaymentPosScreen(),
        ),
      ),
    );
  }

  Widget _buildOrderItem(String name, double price) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(
            name,
            style: montserratMedium.copyWith(
              color: ColorTheme.blackColor,
              fontSize: 15,
            ),
          )),
          Text(
            "₹$price",
            style: montserratBold.copyWith(
              color: ColorTheme.blackColor,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: montserratMedium.copyWith(
              color: Color(0xFF8C8C8C),
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: montserratMedium.copyWith(
              color: Color(0xFF8C8C8C),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
