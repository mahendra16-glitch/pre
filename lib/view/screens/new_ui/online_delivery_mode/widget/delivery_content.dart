import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:animated_read_more_text/animated_read_more_text.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/online_delivery_mode/widget/order_status_card.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryContent extends StatefulWidget {
  const DeliveryContent({super.key});

  @override
  State<DeliveryContent> createState() => _DeliveryContentState();
}

class _DeliveryContentState extends State<DeliveryContent> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
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
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 12),
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
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 12),
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
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 12),
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
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 12),
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
          SingleChildScrollView(
            child: Column(
              children: [
                // ListView.builder(
                //   shrinkWrap: true,
                //   physics: NeverScrollableScrollPhysics(),
                //   itemCount: ['D8310', 'D8311'].length,
                //   itemBuilder: (context, index) {
                //     return OrderStatusCard();
                //   },
                // ),

                MasonryGridView.extent(
                  maxCrossAxisExtent:
                      500, 
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: ['D8310', 'D8311'].length,
                  itemBuilder: (context, index) {
                    return OrderStatusCard(); 
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
