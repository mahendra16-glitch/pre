import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/admin/constant/app_border.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/payment_type_controller.dart';
import 'package:mygenie_restaurant/view/screens/settlement/widget/custom_textformfield.dart';

class PaymentTypeScreen extends StatefulWidget {
  const PaymentTypeScreen({super.key});

  @override
  State<PaymentTypeScreen> createState() => _PaymentTypeScreenState();
}

class _PaymentTypeScreenState extends State<PaymentTypeScreen> {
  final ExpansionTileController _paymentTypesTile = ExpansionTileController();
  final ExpansionTileController _razorpayTile = ExpansionTileController();

  @override
  void initState() {
    super.initState();
    Get.find<PaymentTypeController>().getPaymentTypes();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle normalStyle = montserratMedium.copyWith(
      color: ColorTheme.grey1,
      fontSize: 15,
    );

    return Scaffold(
      backgroundColor: ColorTheme.whiteColor,
      appBar: AppBar(
        backgroundColor: ColorTheme.whiteColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: ColorTheme.green,
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Payment Type',
          style: montserratSemiBold.copyWith(
            color: ColorTheme.black,
            fontSize: 16,
          ),
        ),
        actions: [
          GetBuilder<PaymentTypeController>(
            builder: (controller) {
              final bool busy = controller.isLoading || controller.isSubmitting;
              return IconButton(
                tooltip: 'Refresh',
                onPressed: busy ? null : () => controller.getPaymentTypes(),
                icon: Icon(Icons.refresh, color: ColorTheme.green),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GetBuilder<PaymentTypeController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                _sectionCard(
                  controller: _paymentTypesTile,
                  initiallyExpanded: true,
                  icon: Icons.payments_outlined,
                  title: 'Payment Types',
                  subtitle: 'Enable or disable payment methods',
                  children: [
                    if (controller.paymentTypes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No payment types found',
                          style: normalStyle,
                        ),
                      )
                    else
                      ...List.generate(controller.paymentTypes.length, (index) {
                        final type = controller.paymentTypes[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            top: index == 0 ? 18 : 0,
                            bottom: index == controller.paymentTypes.length - 1
                                ? 0
                                : 16,
                          ),
                          child: _paymentTypeToggle(
                            label: type.displayName,
                            enabled: type.enabled,
                            onChanged: (value) =>
                                controller.togglePaymentType(index, value),
                          ),
                        );
                      }),
                  ],
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  controller: _razorpayTile,
                  initiallyExpanded: false,
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Razorpay Settings',
                  subtitle: 'Razorpay key and token',
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: _paymentTypeToggle(
                        label: 'Razorpay',
                        enabled: controller.razorpayEnabled,
                        onChanged: controller.toggleRazorpay,
                      ),
                    ),
                    if (controller.razorpayEnabled) ...[
                      const SizedBox(height: 20),
                      Form(
                        key: controller.razorpayFormKey,
                        child: Column(
                          children: [
                            CustomTextformField(
                              labelText: 'Razorpay Key',
                              controller: controller.razorpayKeyController,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              errorBorder: AppBorder.errorBorder,
                              focusedErrorBorder: AppBorder.errorBorder,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter Razorpay key';
                                }
                                return null;
                              },
                              onChanged: (_) {},
                            ),
                            const SizedBox(height: 12),
                            CustomTextformField(
                              labelText: 'Razorpay Token',
                              controller: controller.razorpayTokenController,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              errorBorder: AppBorder.errorBorder,
                              focusedErrorBorder: AppBorder.errorBorder,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter Razorpay token';
                                }
                                return null;
                              },
                              onChanged: (_) {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: GetBuilder<PaymentTypeController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const SizedBox.shrink();
          }
          return Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: ColorTheme.white,
            child: Center(
              child: InkWell(
                onTap: controller.isSubmitting
                    ? null
                    : () {
                        if (controller.razorpayEnabled) {
                          final form = controller.razorpayFormKey.currentState;
                          if (form == null || !form.validate()) {
                            if (!_razorpayTile.isExpanded) {
                              _razorpayTile.expand();
                            }
                            if (form == null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                controller.razorpayFormKey.currentState
                                    ?.validate();
                              });
                            }
                            return;
                          }
                        }
                        controller.submit();
                      },
                child: Container(
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: controller.isSubmitting
                        ? ColorTheme.green.withOpacity(0.6)
                        : ColorTheme.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: controller.isSubmitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Submit',
                            style: montserratMedium.copyWith(
                              color: ColorTheme.white,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _paymentTypeToggle({
    required String label,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: montserratMedium.copyWith(
          color: ColorTheme.black,
          fontSize: 15,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Color(0xFFDCDCDC)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 1.5),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Color(0xFFDCDCDC)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            enabled ? 'Yes' : 'No',
            style: montserratMedium.copyWith(
              color: const Color(0xFF828282),
              fontSize: 14,
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: enabled,
              onChanged: onChanged,
              activeColor: ColorTheme.appColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required ExpansionTileController controller,
    required bool initiallyExpanded,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTheme.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorTheme.borderGrey2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          controller: controller,
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorTheme.blueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: ColorTheme.blueColor,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: montserratSemiBold.copyWith(
              color: ColorTheme.black,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: montserratRegular.copyWith(
              color: ColorTheme.grey1,
              fontSize: 12,
            ),
          ),
          children: children,
        ),
      ),
    );
  }
}
