import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/loyalty_controller.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/loyality/conversion_redemption_rate.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/widget/content_card.dart';

class RedemptionPage extends StatefulWidget {
  const RedemptionPage({super.key});

  @override
  State<RedemptionPage> createState() => _RedemptionPageState();
}

class _RedemptionPageState extends State<RedemptionPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoyaltyController>(builder: (loyaltyController) {
      return ContentCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Set Redemption Limits',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildSliderWithTextField(
              label: 'Max Percentage',
              controller: loyaltyController.redemptionMaxPercentageController,
              sliderValue: loyaltyController.maxPercentage,
              loyaltyController: loyaltyController,
              onSliderChanged: (value) {
                loyaltyController.maxPercentage = value;
                loyaltyController.redemptionMaxPercentageController.text =
                    value.toStringAsFixed(1);
                loyaltyController.update();
              },
              onValueUpdate: (value) {
                loyaltyController.maxPercentage = value;
                loyaltyController.update();
              },
              suffixText: '%',
              maxValue: 100.0,
              divisions: 100,
            ),
            const SizedBox(height: 30),
            _buildSliderWithTextField(
              label: 'Max Amount',
              controller: loyaltyController.redemptionMaxAmountController,
              sliderValue: loyaltyController.maxAmount,
              loyaltyController: loyaltyController,
              onSliderChanged: (value) {
                loyaltyController.maxAmount = value;
                loyaltyController.redemptionMaxAmountController.text =
                    value.toStringAsFixed(2);
                loyaltyController.update();
              },
              onValueUpdate: (value) {
                loyaltyController.maxAmount = value;
                loyaltyController.update();
              },
              prefixText: '\₹',
              maxValue: 1000.0,
              divisions: 200,
            ),
            const SizedBox(height: 30),
            loyaltyController.isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (loyaltyController
                                .redemptionMaxAmountController.text.isEmpty ||
                            loyaltyController.redemptionMaxPercentageController
                                .text.isEmpty) {
                          Get.snackbar(
                            "Error",
                            "Conversion rate cannot be empty",
                            backgroundColor: ColorTheme.redF13,
                            colorText: ColorTheme.whiteColor,
                          );
                          return;
                        }
                        loyaltyController.redemptionRateId == null
                            ? loyaltyController.addRedemptionRate()
                            : loyaltyController.updateRedemptionRate();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF36C3F),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        loyaltyController.redemptionRateId == null
                            ? 'Add Settings'
                            : 'Update Settings',
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
            //             if (loyaltyController.redemptionRateId == null) {
            //               Get.snackbar(
            //                 "Error",
            //                 "No conversion rate to delete",
            //                 backgroundColor: ColorTheme.redF13,
            //                 colorText: ColorTheme.whiteColor,
            //               );
            //               return;
            //             }
            //             loyaltyController.deleteRedemptionRate();
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
                'Current Max: ${loyaltyController.maxPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Current Max: \₹${loyaltyController.maxAmount.toStringAsFixed(2)}',
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

  Widget _buildSliderWithTextField({
    required String label,
    required TextEditingController controller,
    required double sliderValue,
    required ValueChanged<double> onSliderChanged,
    required ValueChanged<double> onValueUpdate,
    required dynamic loyaltyController,
    required double maxValue,
    required int divisions,
    String? suffixText,
    String? prefixText,
  }) {
    final FocusNode focusNode = FocusNode();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Slider(
                value: sliderValue,
                min: 0.0,
                max: maxValue,
                divisions: divisions,
                label: sliderValue.toStringAsFixed(suffixText == '%' ? 1 : 2),
                activeColor: const Color(0xFFF36C3F),
                onChanged: onSliderChanged,
              ),
            ),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
                onChanged: (text) {
                  final value = double.tryParse(text);
                  if (value != null && value >= 0 && value <= maxValue) {
                    // Only update slider value, don't update controller text while typing
                    onValueUpdate(value);
                  }
                },
                onEditingComplete: () {
                  // Sync controller text with formatted value when done editing
                  final value = double.tryParse(controller.text);
                  if (value != null && value >= 0 && value <= maxValue) {
                    controller.text =
                        value.toStringAsFixed(suffixText == '%' ? 1 : 2);
                    onSliderChanged(value);
                  }
                  focusNode.unfocus();
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 12.0,
                  ),
                  prefixText: prefixText,
                  suffixText: suffixText,
                  prefixStyle: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  suffixStyle: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Color(0xFFF36C3F)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
