import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_customer_list_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/loyalty_controller.dart';

class AddEditCouponScreen extends StatefulWidget {
  bool isEdit;
  Map<String, dynamic> coupon;
  int id;

  AddEditCouponScreen(
      {Key? key, required this.isEdit, required this.coupon, required this.id})
      : super(key: key);

  @override
  _AddEditCouponScreenState createState() => _AddEditCouponScreenState();
}

class _AddEditCouponScreenState extends State<AddEditCouponScreen> {
  InputDecoration _inputDecoration(
    String hint,
  ) =>
      InputDecoration(
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorTheme.borderGrey),
          borderRadius: BorderRadius.circular(7),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorTheme.borderGrey),
          borderRadius: BorderRadius.circular(7),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorTheme.borderGrey),
          borderRadius: BorderRadius.circular(7),
        ),
        labelText: hint,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorTheme.borderGrey),
          borderRadius: BorderRadius.circular(7),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorTheme.borderGrey),
          borderRadius: BorderRadius.circular(7),
        ),
        hintStyle: poppinsMedium.copyWith(
            fontSize: MediaQuery.of(context).size.shortestSide > 570 ? 16 : 13,
            color: ColorTheme.hintText),
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: ColorTheme.borderGrey),
          borderRadius: BorderRadius.circular(7),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: poppinsMedium.copyWith(
            fontSize: MediaQuery.of(context).size.shortestSide > 570 ? 16 : 13,
            color: ColorTheme.hintText),
      );

  TextStyle _textStyle({Color? color}) {
    final resolvedColor = color ?? ColorTheme.black;
    return TextStyle(
      fontSize: MediaQuery.of(context).size.shortestSide > 570 ? 16 : 13,
      color: resolvedColor,
      fontFamily: 'Poppins',
    );
  }

  Widget _dottedLine() {
    return DottedLine(
      direction: Axis.horizontal,
      alignment: WrapAlignment.center,
      lineThickness: 1.0,
      dashLength: 2.5,
      dashColor: ColorTheme.hintText,
    );
  }

  @override
  void initState() {
    super.initState();
    final loyaltyController = Get.find<LoyaltyController>();
    loyaltyController.getCustomerFromApi();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loyaltyController.initializeCouponData(widget.isEdit, widget.coupon);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Get.back();
              Get.find<LoyaltyController>().clearCouponData();
              Get.find<LoyaltyController>().update();
            },
            icon: Icon(Icons.arrow_back_ios, color: Color(0xFFF36C3F))),
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.isEdit ? 'Edit Coupon' : 'Add Coupon',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: GetBuilder<LoyaltyController>(builder: (loyaltyController) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 25,
              ),
              decoration: BoxDecoration(
                  color: ColorTheme.bgSettleCardGreyColor,
                  borderRadius: BorderRadius.circular(13)),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Coupon',
                      textAlign: TextAlign.start,
                      style: poppinsSemiBold.copyWith(
                          fontSize: 18, color: ColorTheme.black2E),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  DottedLine(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.center,
                    lineThickness: 1.0,
                    dashLength: 2.5,
                    dashColor: ColorTheme.hintText,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: loyaltyController.formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: loyaltyController.CouponCodeController,
                          decoration: _inputDecoration('Coupon Code'),
                          style: _textStyle(),
                          validator: (val) =>
                              val!.isEmpty ? 'Enter code' : null,
                        ),
                        SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          style: _textStyle(),
                          validator: (val) => (val == null || val.isEmpty)
                              ? 'Select discount type'
                              : null,
                          value: loyaltyController.discountType.isEmpty
                              ? null
                              : loyaltyController.discountTypeList
                                      .contains(loyaltyController.discountType)
                                  ? loyaltyController.discountType
                                  : null,
                          items: loyaltyController.discountTypeList
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type, style: _textStyle()),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            loyaltyController.discountType = val!;
                            loyaltyController.update();
                          },
                          decoration: _inputDecoration('Discount Type'),
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: loyaltyController.discountValueController,
                          decoration: _inputDecoration('Discount Value'),
                          keyboardType: TextInputType.number,
                          style: _textStyle(),
                          validator: (val) =>
                              val!.isEmpty ? 'Enter value' : null,
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          readOnly: true,
                          onTap: () {
                            loyaltyController.pickDate(
                                isStart: true, context: context);
                            loyaltyController.update();
                          },
                          controller: loyaltyController.startDateController,
                          decoration:
                              _inputDecoration('Start Date (YYYY-MM-DD)'),
                          style: _textStyle(),
                          validator: (val) =>
                              val!.isEmpty ? 'Enter start date' : null,
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          readOnly: true,
                          onTap: () {
                            loyaltyController.pickDate(
                                isStart: false, context: context);
                            loyaltyController.update();
                          },
                          controller: loyaltyController.endDateController,
                          decoration: _inputDecoration('End Date (YYYY-MM-DD)'),
                          style: _textStyle(),
                          validator: (val) =>
                              val!.isEmpty ? 'Enter end date' : null,
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: loyaltyController.usageLimitController,
                          decoration: _inputDecoration('Usage Limit'),
                          keyboardType: TextInputType.number,
                          style: _textStyle(),
                          validator: (val) =>
                              val!.isEmpty ? 'Enter usage limit' : null,
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: loyaltyController.perUserLimitController,
                          decoration: _inputDecoration('Per User Limit'),
                          style: _textStyle(),
                          keyboardType: TextInputType.number,
                          // validator: (val) => val!.isEmpty ? 'Enter per user limit' : null,
                        ),
                        SizedBox(height: 15),
                        CheckboxListTile(
                          title:
                              Text('Select Specific Users', style: _textStyle()),
                          value: loyaltyController.addMultipleUsers,
                          contentPadding: EdgeInsets.zero,
                          activeColor: ColorTheme.appColor,
                          checkColor: Colors.white,
                          onChanged: (val) {
                            loyaltyController.addMultipleUsers = val!;
                            if (!val) {
                              loyaltyController.selectedUsers.clear();
                            }
                            loyaltyController.update();
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                        if (loyaltyController.addMultipleUsers) ...[
                          Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              _dottedLine(),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'User Name',
                                    style: _textStyle(),
                                  ),
                                  Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      loyaltyController.selectedUsers =
                                          List.from(loyaltyController.allUsers);
                                      loyaltyController.update();
                                    },
                                    child: Text('Select All',
                                        style: _textStyle(
                                            color: ColorTheme.hintText)),
                                  )
                                ],
                              ),
                            ],
                          ),
                          ...loyaltyController.allUsers.map(
                            (user) => CheckboxListTile(
                              value: loyaltyController.selectedUsers
                                  .contains(user),
                              title: Text('${user}',
                                  style:
                                      _textStyle(color: ColorTheme.hintText)),
                              activeColor: ColorTheme.appColor,
                              checkColor: Colors.white,
                              onChanged: (_) =>
                                  loyaltyController.toggleUserSelection(user),
                            ),
                          )
                        ],
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Applicable Channels',
                              style: _textStyle(),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            _dottedLine(),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Channel Name',
                                  style: _textStyle(),
                                ),
                                TextButton(
                                  onPressed: () {
                                    loyaltyController.selectedChannels =
                                        List.from(
                                            loyaltyController.allChannels);
                                    loyaltyController.update();
                                  },
                                  child: Text('Select All',
                                      style: _textStyle(
                                          color: ColorTheme.hintText)),
                                )
                              ],
                            ),
                          ],
                        ),
                        ...loyaltyController.allChannels.map(
                          (channel) => CheckboxListTile(
                            value: loyaltyController.selectedChannels
                                .contains(channel),
                            title: Text(channel,
                                style: _textStyle(color: ColorTheme.hintText)),
                            activeColor: ColorTheme.appColor,
                            checkColor: Colors.white,
                            onChanged: (_) => loyaltyController
                                .toggleChannelSelection(channel),
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: MediaQuery.of(context).size.shortestSide > 570
                              ? Get.width / 5
                              : Get.width / 2,
                          child: ElevatedButton(
                            onPressed: () {
                              if (widget.isEdit) {
                                loyaltyController.saveCoupon(widget.id,
                                    isEdit: true);
                              } else {
                                loyaltyController.saveCoupon(widget.id,
                                    isEdit: false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: ColorTheme.appColor),
                            child: loyaltyController.isLoading
                                ? SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 20.0,
                                  )
                                : Text(
                                    widget.isEdit
                                        ? 'Update Coupon'
                                        : 'Save Coupon',
                                    style: _textStyle(color: Colors.white)),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
