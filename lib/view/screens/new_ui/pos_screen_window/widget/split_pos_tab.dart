
import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';

class SplitPosTabContent extends StatefulWidget {
  const SplitPosTabContent({super.key});

  
  @override
  _SplitTabContent createState() => _SplitTabContent();
}

class _SplitTabContent extends State<SplitPosTabContent> {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
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
                    Text(
                      "Total : 2517.00",
                      style: poppinsMedium.copyWith(
                          fontSize: 16, color: ColorTheme.green),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Divider(
                color: Color(0xFFE7E7E7),
              ),
              SizedBox(height: 20),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                child: DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  value: selectedSplitPaymentMethod1,
                  decoration: InputDecoration(
                    // labelText: "Payment Method",
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorTheme.borderGrey2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorTheme.borderGrey2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorTheme.borderGrey2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorTheme.borderGrey2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: "Cash",
                        child: Text("Payment by Cash",
                            style: montserratMedium.copyWith(
                                fontSize: 16, color: ColorTheme.borderGrey1))),
                    DropdownMenuItem(
                        value: "Card",
                        child: Text("Payment by Card",
                            style: montserratMedium.copyWith(
                                fontSize: 16, color: ColorTheme.borderGrey1))),
                    DropdownMenuItem(
                        value: "UPI",
                        child: Text("Payment by UPI",
                            style: montserratMedium.copyWith(
                                fontSize: 16, color: ColorTheme.borderGrey1))),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedSplitPaymentMethod1 = value!;
                    });
                  },
                ),
              ),
              SizedBox(height: 15),
              if (selectedSplitPaymentMethod1 == "Cash") ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            decoration: InputDecoration(
                              // hintText: "10000",
                              labelText: "Amount",
                              labelStyle: montserratMedium.copyWith(
                                  fontSize: 16, color: ColorTheme.borderGrey1),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
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
                              labelText: "Change",
                              labelStyle: montserratMedium.copyWith(
                                  fontSize: 16, color: ColorTheme.borderGrey1),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
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
              ] else if (selectedSplitPaymentMethod1 == "Card") ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            decoration: InputDecoration(
                              // hintText: "10000",
                              labelText: "Amount",
                              labelStyle: montserratMedium.copyWith(
                                  fontSize: 16, color: ColorTheme.borderGrey1),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
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
                              labelText: "Card No.",
                              labelStyle: montserratMedium.copyWith(
                                  fontSize: 16, color: ColorTheme.borderGrey1),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
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
              ] else if (selectedSplitPaymentMethod1 == "UPI") ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            decoration: InputDecoration(
                              // hintText: "10000",
                              labelText: "Amount",
                              labelStyle: montserratMedium.copyWith(
                                  fontSize: 16, color: ColorTheme.borderGrey1),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
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
                              labelStyle: montserratMedium.copyWith(
                                  fontSize: 16, color: ColorTheme.borderGrey1),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
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
                SizedBox(height: 15),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: Center(child: Text("QR Code")),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Payment Status",
                            style: montserratMedium.copyWith(
                                fontSize: 14, color: ColorTheme.blackColor),
                          ),
                          Text(
                            "Processing",
                            style: montserratMedium.copyWith(
                                fontSize: 16, color: ColorTheme.blackColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 20),
              Divider(
                color: Color(0xFFE7E7E7),
              ),
              SizedBox(height: 20),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                child: DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  value: selectedSplitPaymentMethod2,
                  decoration: InputDecoration(
                    // labelText: "Payment Method",
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorTheme.borderGrey2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorTheme.borderGrey2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorTheme.borderGrey2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorTheme.borderGrey2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: "Cash",
                        child: Text(
                          "Payment by Cash",
                          style: montserratMedium.copyWith(
                              fontSize: 16, color: ColorTheme.borderGrey1),
                        )),
                    DropdownMenuItem(
                        value: "Card",
                        child: Text("Payment by Card",
                            style: montserratMedium.copyWith(
                                fontSize: 16, color: ColorTheme.borderGrey1))),
                    DropdownMenuItem(
                        value: "UPI",
                        child: Text("Payment by UPI",
                            style: montserratMedium.copyWith(
                                fontSize: 16, color: ColorTheme.borderGrey1))),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedSplitPaymentMethod2 = value!;
                    });
                  },
                ),
              ),
              SizedBox(height: 15),
              if (selectedSplitPaymentMethod2 == "Cash") ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            decoration: InputDecoration(
                              // hintText: "10000",
                              labelText: "Amount",
                              labelStyle: montserratMedium.copyWith(
                                  fontSize: 16, color: ColorTheme.borderGrey1),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
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
                              labelText: "Change",
                              labelStyle: montserratMedium.copyWith(
                                  fontSize: 16, color: ColorTheme.borderGrey1),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
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
              ] else if (selectedSplitPaymentMethod2 == "Card") ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            decoration: InputDecoration(
                              // hintText: "10000",
                              labelText: "Amount",
                              labelStyle: montserratMedium.copyWith(
                                  fontSize: 16, color: ColorTheme.borderGrey1),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
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
                              labelText: "Card No.",
                              labelStyle: montserratMedium.copyWith(
                                  fontSize: 16, color: ColorTheme.borderGrey1),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
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
              ] else if (selectedSplitPaymentMethod2 == "UPI") ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            decoration: InputDecoration(
                              // hintText: "10000",
                              labelText: "Amount",
                              labelStyle: montserratMedium.copyWith(
                                  fontSize: 16, color: ColorTheme.borderGrey1),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
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
                              labelStyle: montserratMedium.copyWith(
                                  fontSize: 16, color: ColorTheme.borderGrey1),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorTheme.borderGrey2,
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
                SizedBox(height: 15),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: Center(child: Text("QR Code")),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Payment Status",
                            style: montserratMedium.copyWith(
                                fontSize: 14, color: ColorTheme.blackColor),
                          ),
                          Text(
                            "Processing",
                            style: montserratMedium.copyWith(
                                fontSize: 16, color: ColorTheme.blackColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 20),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                  child: Container(
                    width: 230,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorTheme.borderGrey2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add,
                          color: ColorTheme.borderGrey1,
                        ),
                        SizedBox(width: 10,),
                        Text(
                          "Add Payment Split",
                          style: montserratMedium.copyWith(
                              fontSize: 16, color: ColorTheme.green),
                        ),
                      ],
                    ),
                  )),
              SizedBox(height: 20),
              Divider(
                color: Color(0xFFE7E7E7),
              ),
              SizedBox(height: 20),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          decoration: InputDecoration(
                            // hintText: "10000",
                            labelText: "Name",
                            labelStyle: montserratMedium.copyWith(
                                fontSize: 16, color: ColorTheme.borderGrey1),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: ColorTheme.borderGrey2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: ColorTheme.borderGrey2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: ColorTheme.borderGrey2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: ColorTheme.borderGrey2,
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
                            labelStyle: montserratMedium.copyWith(
                                fontSize: 16, color: ColorTheme.borderGrey1),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: ColorTheme.borderGrey2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: ColorTheme.borderGrey2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: ColorTheme.borderGrey2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: ColorTheme.borderGrey2,
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
        ),
      ),
    );
  }
}