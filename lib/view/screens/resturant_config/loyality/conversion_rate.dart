// --- Conversion Page ---
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/loyalty_controller.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/loyality/conversion_redemption_rate.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/widget/content_card.dart';

class ConversionRatePage extends StatefulWidget {
  const ConversionRatePage({super.key});

  @override
  State<ConversionRatePage> createState() => _ConversionRatePageState();
}

class _ConversionRatePageState extends State<ConversionRatePage> {


  @override
  Widget build(BuildContext context) {
    // Adjusted text styles to be bold and larger, matching the CSS feel
    const TextStyle inputTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF8C8C8C),
    );
    final OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: const BorderSide(color: Color(0xFFDCDCDC), width: 1.5),
    );

    return GetBuilder<LoyaltyController>(builder: (loyaltyController) {
      return ContentCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Set Conversion Rate',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: loyaltyController.conversionRateController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: inputTextStyle.copyWith(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Conversion Rate',
                labelStyle: inputTextStyle,
                hintText: 'Enter the conversion rate',
                hintStyle: inputTextStyle,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 20.0,
                ),
                border: inputBorder,
                enabledBorder: inputBorder,
                focusedBorder: inputBorder.copyWith(
                  borderSide: const BorderSide(
                    color: Color(0xFFF36C3F),
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            loyaltyController.isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (loyaltyController
                            .conversionRateController.text.isEmpty) {
                          Get.snackbar(
                            "Error",
                            "Conversion rate cannot be empty",
                            backgroundColor: ColorTheme.redF13,
                            colorText: ColorTheme.whiteColor,
                          );
                          return;
                        }
                        loyaltyController.conversionRateId == null
                            ? loyaltyController.addConversionRate()
                            : loyaltyController.updateConversionRate();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF36C3F),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        loyaltyController.conversionRateId == null
                            ? 'Add Rate'
                            : 'Update Rate',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
            // const SizedBox(height: 20),
            // loyaltyController.isLoading1
            //     ? Center(child: CircularProgressIndicator())
            //     : SizedBox(
            //         width: double.infinity,
            //         child: ElevatedButton(
            //           onPressed: () {
            //             if (loyaltyController.conversionRateId == null) {
            //               Get.snackbar(
            //                 "Error",
            //                 "No conversion rate to delete",
            //                 backgroundColor: ColorTheme.redF13,
            //                 colorText: ColorTheme.whiteColor,
            //               );
            //               return;
            //             }
            //             loyaltyController.deleteConversionRate();
            //           },
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: const Color(0xFFF36C3F),
            //             padding: const EdgeInsets.symmetric(vertical: 16),
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(30),
            //             ),
            //           ),
            //           child: Text(
            //             'Delete Rate',
            //             style: TextStyle(
            //               fontSize: 18,
            //               color: Colors.white,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //         ),
            //       ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Current Rate: ${loyaltyController.conversionRateController.text.isEmpty ? '0' : loyaltyController.conversionRateController.text}',
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    });
  }
}
