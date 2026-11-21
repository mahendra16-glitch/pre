import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/loyalty_controller.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/coupon/widget/add_edit_coupon_scree.dart';
import 'package:print_bluetooth_thermal/post_code.dart';

class CouponManagementScreen extends StatefulWidget {
  @override
  _CouponManagementScreenState createState() => _CouponManagementScreenState();
}

class _CouponManagementScreenState extends State<CouponManagementScreen> {
  @override
  void initState() {
    super.initState();
    final loyaltyController = Get.find<LoyaltyController>();
    loyaltyController.getCouponList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Text(
              'Coupon',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditCouponScreen(
                    isEdit: false,
                    coupon: {},
                    id: 0,
                  ),
                ),
              );
            },
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.shortestSide > 570 ? 18 : 15,
              backgroundColor: Color(0xFFF36C3F),
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: GetBuilder<LoyaltyController>(builder: (loyaltyController) {
          return loyaltyController.isLoading
              ? Center(child: CircularProgressIndicator())
              : loyaltyController.coupons.isEmpty
                  ? Center(child: Text('Coupons not found'))
                  : ListView.builder(
                      itemCount: loyaltyController.coupons.length,
                      itemBuilder: (context, index) {
                        return couponCard(
                          context: context,
                          coupon: loyaltyController.coupons[index],
                          index: index,
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddEditCouponScreen(
                                  isEdit: true,
                                  coupon: loyaltyController.coupons[index],
                                  id: loyaltyController.coupons[index]['id'] ??
                                      0,
                                ),
                              ),
                            );
                          },
                          onDelete: () {
                            loyaltyController.deleteCoupon(
                                loyaltyController.coupons[index]['id']);
                          },
                        );
                      },
                    );
        }),
      ),
    );
  }
}

Widget couponCard({
  required Map<String, dynamic> coupon,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
  required BuildContext context,
  required int index,
}) {
  DateTime? startDate = DateTime.tryParse(coupon['start_date'] ?? '');
  DateTime? endDate = DateTime.tryParse(coupon['end_date'] ?? '');

  TextStyle _textStyle({Color? color, double? fontSize}) {
    final resolvedColor = color ?? ColorTheme.black;
    final resolvedFontSize = fontSize ??
        (MediaQuery.of(context).size.shortestSide > 570 ? 16.0 : 13.0);
    return TextStyle(
      fontSize: resolvedFontSize,
      color: resolvedColor,
      fontFamily: 'Poppins',
    );
  }

  return Card(
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    color: index % 2 == 0
        ? ColorTheme.roomCardBgColor
        : ColorTheme.bgSettleCardYellowColor,
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coupon['code'] ?? '',
                style: _textStyle(),
              ),
              // SizedBox(height: 3),
              // Text(
              //   'Discount: ₹${coupon['discount_value'] ?? ''}',
              //   style: _textStyle(color: ColorTheme.hintText, fontSize: 13),
              // ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 3.0),
                child: Row(
                  children: [
                    Text(
                      '${startDate != null ? '${startDate.day}/${startDate.month}/${startDate.year}' : ''} ',
                      style:
                          _textStyle(color: ColorTheme.hintText, fontSize: 10),
                    ),
                    Text(
                      '- ${endDate != null ? '${endDate.day}/${endDate.month}/${endDate.year}' : ''}',
                      style:
                          _textStyle(color: ColorTheme.hintText, fontSize: 10),
                    ),
                  ],
                ),
              )
            ],
          ),
          Spacer(),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
                tooltip: "Edit Coupon",
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
                tooltip: "Delete Coupon",
              ),
            ],
          )
        ],
      ),
    ),
  );
}
