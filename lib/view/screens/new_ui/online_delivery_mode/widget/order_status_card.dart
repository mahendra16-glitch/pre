import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:animated_read_more_text/animated_read_more_text.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderStatusCard extends StatefulWidget {
  const OrderStatusCard({super.key});

  @override
  State<OrderStatusCard> createState() => _OrderStatusCardState();
}

class _OrderStatusCardState extends State<OrderStatusCard> {
  bool swiggy = true;
  int status = 0;
  int outOfStock = 0;

  void _launchCaller(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  List<bool> example = [true, false];

  @override
  Widget build(BuildContext context) {
    print(status);
    return SafeArea(
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(
                              width: 40,
                              child: SvgPicture.asset(
                                  swiggy ? Images.zomato : Images.swiggy)),
                          const SizedBox(
                            width: 7,
                          ),
                          Column(
                            children: [
                              Text('#D8310',
                                  style: poppinsSemiBold.copyWith(
                                      fontSize: 15,
                                      color: swiggy
                                          ? Color(0xFFE23744)
                                          : Color(0xFFF08520))),
                              const SizedBox(height: 2),
                              Text(
                                '15 mins ago',
                                style: poppinsSemiBold.copyWith(
                                    fontSize: 9, color: Color(0xFF828282)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    // Spacer(),
                    Row(
                      children: [
                        status == 1
                            ? Text(
                                'COOKING',
                                style: poppinsSemiBold.copyWith(
                                    fontSize: 15, color: Color(0xFF828282)),
                              )
                            : status == 2
                                ? Text(
                                    'Dispatch',
                                    style: poppinsSemiBold.copyWith(
                                        fontSize: 15, color: Color(0xFF828282)),
                                  )
                                : status == 3
                                    ? Text(
                                        'Delivered',
                                        style: poppinsSemiBold.copyWith(
                                            fontSize: 15,
                                            color: Color(0xFF828282)),
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
                                              size: 23,
                                              // color: ColorTheme.borderGrey,
                                              color: Colors.white,
                                            )),
                                      ),
                        const SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              status++;
                              // swiggy = !swiggy;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                // border: Border.all(color: Color(0xFFDFDFDF)),
                                color: ColorTheme.green,
                                borderRadius: BorderRadius.circular(20)),
                            child: Icon(
                              Icons.check,
                              size: 23,
                              // color: ColorTheme.borderGrey,
                              color: ColorTheme.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                status != 0 ? const SizedBox(height: 12) : SizedBox.shrink(),
                status != 0
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 3.5, horizontal: 8),
                        decoration: BoxDecoration(
                          color: status == 4
                              ? Color(0xFFC6C6C6)
                              : ColorTheme.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Order on Time',
                              style: poppinsMedium.copyWith(
                                  fontSize: 10, color: Colors.white),
                            ),
                            Spacer(),
                            Text(
                              '43:44',
                              style: poppinsMedium.copyWith(
                                  fontSize: 10, color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
                status != 0 ? const SizedBox(height: 12) : SizedBox.shrink(),
                status != 0
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildStatusDot(
                              status == 4 ? Colors.grey : Colors.green),
                          Expanded(
                              child: _buildLine(context, 'Confirm', '13:26')),
                          _buildStatusDot(status == 1
                              ? Color(0xFFFF7E27)
                              : status == 4
                                  ? Colors.grey
                                  : Colors.green),
                          Expanded(
                              child: _buildLine(context, 'Cooking', '3:26')),
                          _buildStatusDot(status == 2
                              ? Color(0xFFFF7E27)
                              : status == 3
                                  ? Colors.green
                                  : Colors.grey),
                          Expanded(child: _buildLine(context, 'Dispatch', '')),
                          _buildStatusDot(status == 3
                              ? Color(0xFFFF7E27)
                              : status == 4
                                  ? Colors.green
                                  : Colors.grey),
                          Expanded(child: _buildLine(context, 'Delivered', '')),
                          // _buildStatusDot(Colors.grey),
                        ],
                      )
                    : SizedBox.shrink(),
                const SizedBox(
                  height: 11,
                ),

                const Divider(
                  height: 0,
                  color: Color(0xFFEFEFEF),
                ),

                const SizedBox(
                  height: 8,
                ),
                status != 0
                    ? Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Runner Name',
                                    style: poppinsBold.copyWith(
                                        fontSize: 12,
                                        color: Color(0xFF828282))),

                                // Text('9662666737  |  MyGenie ID No.')
                                RichText(
                                    text: TextSpan(children: [
                                  TextSpan(
                                      text: '9662666737',
                                      style: poppinsSemiBold.copyWith(
                                          fontSize: 10,
                                          color: Color(0xFF828282))),
                                  TextSpan(
                                      text: '   ',
                                      style: poppinsSemiBold.copyWith(
                                          fontSize: 10,
                                          color: Color(0xFF828282))),
                                  TextSpan(
                                      text: '|',
                                      style: poppinsSemiBold.copyWith(
                                          fontSize: 12,
                                          color: Color(0xFF828282))),
                                  TextSpan(
                                      text: '   ',
                                      style: poppinsSemiBold.copyWith(
                                          fontSize: 10,
                                          color: Color(0xFF828282))),
                                  TextSpan(
                                      text: 'MyGenie ID No.',
                                      style: poppinsSemiBold.copyWith(
                                          fontSize: 10,
                                          color: ColorTheme.green)),
                                ])),
                                (status != 1 || status != 2)
                                    ? const SizedBox(
                                        height: 5,
                                      )
                                    : SizedBox.shrink(),

                                (status != 1 || status != 2)
                                    ? Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 3.5, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: status == 4
                                              ? Color(0xFFC6C6C6)
                                              : status == 3
                                                  ? ColorTheme.green
                                                  : Color(0xFFC6C6C6),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Order on Time',
                                              style: poppinsMedium.copyWith(
                                                  fontSize: 10,
                                                  color: Colors.white),
                                            ),
                                            Spacer(),
                                            Text(
                                              '43:44',
                                              style: poppinsMedium.copyWith(
                                                  fontSize: 10,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      )
                                    : SizedBox.shrink()
                              ],
                            ),
                          ),
                          // const Spacer(),
                          InkWell(
                              onTap: () {
                                _launchCaller('9662666737');
                              },
                              child: SizedBox(
                                  width: 38,
                                  child: SvgPicture.asset(Images.Phone_icon2)))
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: Colors.blue),
                          const SizedBox(width: 6),
                          Expanded(
                            child: AnimatedReadMoreText(
                                '4144, Sobha Royal Pavilion, Sarjapur Rd, Carmelaram, Hadosiddapura addres 4144,Hadosiddapura Sobha Royal Pavilion, Sarjapur Rd, Carmelaram, Hadosiddapura address..',
                                maxLines: 2,
                                readMoreText: 'View More',
                                readLessText: 'View Less',
                                textStyle: poppinsSemiBold.copyWith(
                                    fontSize: 10, color: Color(0xFF828282)),
                                buttonTextStyle: poppinsBold.copyWith(
                                    fontSize: 11, color: Color(0xFF047DD4))),
                          )
                        ],
                      ),
                const SizedBox(
                  height: 8,
                ),
                const Divider(
                  height: 0,
                  color: Color(0xFFEFEFEF),
                ),
                const SizedBox(height: 8),
                status == 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.circle, size: 8, color: Colors.green),
                              SizedBox(width: 6),
                              Text(
                                'Food Item Name Here (1)',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: poppinsSemiBold.copyWith(
                                    decoration: outOfStock == 1
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    fontSize: 13,
                                    color: Color(0xFF828282)),
                              ),
                              Spacer(),
                              outOfStock == 1
                                  ? Text(
                                      'Out of stock',
                                      style: poppinsSemiBold.copyWith(
                                          fontSize: 8,
                                          color: Color(0xFFFF7E27)),
                                    )
                                  : SizedBox.shrink(),
                              Transform.scale(
                                  scale: 0.5,
                                  child: Switch(
                                    value: outOfStock == 1 ? true : false,
                                    onChanged: (value) {
                                      setState(() {
                                        outOfStock = value ? 1 : 0;
                                      });
                                    },
                                    activeColor: ColorTheme.green,
                                    activeTrackColor: Colors.transparent,
                                    inactiveTrackColor: Colors.transparent,
                                    trackOutlineWidth:
                                        const WidgetStatePropertyAll(3),
                                    thumbColor: outOfStock == 0
                                        ? WidgetStatePropertyAll(
                                            ColorTheme.green)
                                        : const WidgetStatePropertyAll(
                                            Color(0xFFCACACA)),
                                    inactiveThumbColor: const Color(0xFFCACACA),
                                    trackOutlineColor: outOfStock == 0
                                        ? WidgetStatePropertyAll(
                                            ColorTheme.green)
                                        : const WidgetStatePropertyAll(
                                            Color(0xFFCACACA)),
                                  ))
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Icon(Icons.circle,
                                    size: 8, color: Colors.red),
                              ),
                              SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Food Item Name Comes Here (1)',
                                    style: poppinsSemiBold.copyWith(
                                        fontSize: 13, color: Color(0xFF828282)),
                                  ),
                                  RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                        text: 'Variant',
                                        style: poppinsSemiBold.copyWith(
                                            fontSize: 10,
                                            color: ColorTheme.blue)),
                                    TextSpan(
                                        text: ':',
                                        style: poppinsSemiBold.copyWith(
                                            fontSize: 10,
                                            color: Color(0xFF828282))),
                                    TextSpan(
                                        text: ' ',
                                        style: poppinsSemiBold.copyWith(
                                            fontSize: 10,
                                            color: Color(0xFF828282))),
                                    TextSpan(
                                        text: 'Choice (Extra Boiled Egg)',
                                        style: poppinsSemiBold.copyWith(
                                            fontSize: 10,
                                            color: Color(0xFF828282))),
                                  ])),
                                  RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                        text: 'Addon',
                                        style: poppinsSemiBold.copyWith(
                                            fontSize: 10,
                                            color: ColorTheme.blue)),
                                    TextSpan(
                                        text: ':',
                                        style: poppinsSemiBold.copyWith(
                                            fontSize: 10,
                                            color: Color(0xFF828282))),
                                    TextSpan(
                                        text: ' ',
                                        style: poppinsSemiBold.copyWith(
                                            fontSize: 10,
                                            color: Color(0xFF828282))),
                                    TextSpan(
                                        text: 'Raita',
                                        style: poppinsSemiBold.copyWith(
                                            fontSize: 10,
                                            color: Color(0xFF828282))),
                                  ]))
                                ],
                              ),
                              // Spacer(),
                              Transform.scale(
                                  scale: 0.5,
                                  child: Switch(
                                    value: false,
                                    onChanged: (value) {},
                                    activeColor: ColorTheme.green,
                                    activeTrackColor: Colors.transparent,
                                    inactiveTrackColor: Colors.transparent,
                                    trackOutlineWidth:
                                        const WidgetStatePropertyAll(3),
                                    thumbColor: outOfStock == 0
                                        ? WidgetStatePropertyAll(
                                            ColorTheme.green)
                                        : const WidgetStatePropertyAll(
                                            Color(0xFFCACACA)),
                                    inactiveThumbColor: const Color(0xFFCACACA),
                                    trackOutlineColor: outOfStock == 0
                                        ? WidgetStatePropertyAll(
                                            ColorTheme.green)
                                        : const WidgetStatePropertyAll(
                                            Color(0xFFCACACA)),
                                  ))
                            ],
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.circle,
                                      size: 8, color: Colors.green),
                                  SizedBox(width: 6),
                                  Text(
                                    'Food Item Name Here (1)',
                                    style: poppinsSemiBold.copyWith(
                                        fontSize: 13, color: Color(0xFF828282)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Icon(Icons.circle,
                                        size: 8, color: Colors.red),
                                  ),
                                  SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Food Item Name Comes Here (1)',
                                        style: poppinsSemiBold.copyWith(
                                            fontSize: 13,
                                            color: Color(0xFF828282)),
                                      ),
                                      RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: 'Variant',
                                            style: poppinsSemiBold.copyWith(
                                                fontSize: 10,
                                                color: ColorTheme.blue)),
                                        TextSpan(
                                            text: ':',
                                            style: poppinsSemiBold.copyWith(
                                                fontSize: 10,
                                                color: Color(0xFF828282))),
                                        TextSpan(
                                            text: ' ',
                                            style: poppinsSemiBold.copyWith(
                                                fontSize: 10,
                                                color: Color(0xFF828282))),
                                        TextSpan(
                                            text: 'Choice (Extra Boiled Egg)',
                                            style: poppinsSemiBold.copyWith(
                                                fontSize: 10,
                                                color: Color(0xFF828282))),
                                      ])),
                                      RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: 'Addon',
                                            style: poppinsSemiBold.copyWith(
                                                fontSize: 10,
                                                color: ColorTheme.blue)),
                                        TextSpan(
                                            text: ':',
                                            style: poppinsSemiBold.copyWith(
                                                fontSize: 10,
                                                color: Color(0xFF828282))),
                                        TextSpan(
                                            text: ' ',
                                            style: poppinsSemiBold.copyWith(
                                                fontSize: 10,
                                                color: Color(0xFF828282))),
                                        TextSpan(
                                            text: 'Raita',
                                            style: poppinsSemiBold.copyWith(
                                                fontSize: 10,
                                                color: Color(0xFF828282))),
                                      ]))
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              status != 0
                                  ? RichText(
                                      text: TextSpan(children: [
                                      TextSpan(
                                          text: '₹ 2436.50',
                                          style: poppinsSemiBold.copyWith(
                                              fontSize: 13,
                                              color: ColorTheme.green)),
                                      TextSpan(
                                          text: '   ',
                                          style: poppinsSemiBold.copyWith(
                                              fontSize: 10,
                                              color: Color(0xFF828282))),
                                      TextSpan(
                                          text: 'Customer No.',
                                          style: poppinsSemiBold.copyWith(
                                              fontSize: 10,
                                              color: Color(0xFF828282))),
                                    ]))
                                  : SizedBox.shrink(),
                            ],
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: Color(0xFFDFDFDF),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                swiggy = !swiggy;
                              });
                            },
                            child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: ColorTheme.borderGrey),
                                    borderRadius: BorderRadius.circular(20)),
                                child: SvgPicture.asset(
                                  Images.Phone_icon,
                                  height: 30,
                                )),
                          ),
                        ],
                      ),

                const SizedBox(height: 8),

                const Divider(
                  height: 0,
                  color: Color(0xFFEFEFEF),
                ),

                const SizedBox(height: 8),
                status != 0
                    ? Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: Colors.blue),
                          const SizedBox(width: 6),
                          Expanded(
                            child: AnimatedReadMoreText(
                                '4144, Sobha Royal Pavilion, Sarjapur Rd, Carmelaram, Hadosiddapura addres 4144,Hadosiddapura Sobha Royal Pavilion, Sarjapur Rd, Carmelaram, Hadosiddapura address..',
                                maxLines: 2,
                                readMoreText: 'View More',
                                readLessText: 'View Less',
                                textStyle: poppinsSemiBold.copyWith(
                                    fontSize: 10, color: Color(0xFF828282)),
                                buttonTextStyle: poppinsBold.copyWith(
                                    fontSize: 11, color: Color(0xFF047DD4))),
                          )
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Instruction',
                                  style: poppinsSemiBold.copyWith(
                                      fontSize: 10, color: Colors.blue),
                                ),
                                const SizedBox(height: 6),
                                AnimatedReadMoreText(
                                    '4144, Sobha Royal Pavilion, Sarjapur Rd, Carmelaram, Hadosiddapura addres 4144,Hadosiddapura Sobha Royal Pavilion, Sarjapur Rd, Carmelaram, Hadosiddapura address..',
                                    maxLines: 2,
                                    readMoreText: 'View More',
                                    readLessText: 'View Less',
                                    textStyle: poppinsSemiBold.copyWith(
                                        fontSize: 10, color: Color(0xFF828282)),
                                    buttonTextStyle: poppinsBold.copyWith(
                                        fontSize: 11, color: Color(0xFF047DD4)))
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: Color(0xFFDFDFDF),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          InkWell(
                            onTap: () {
                              // setState(() {
                              //   swiggy = !swiggy;
                              // });
                            },
                            child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    color: Color(0xFFC6C6C6),
                                    border: Border.all(
                                        color: ColorTheme.borderGrey),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                )),
                          ),
                        ],
                      ),
                const SizedBox(height: 8),

                const Divider(
                  height: 0,
                  color: Color(0xFFEFEFEF),
                ),
                // const SizedBox(height: 8),
                const SizedBox(height: 8),
                status == 0
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text('₹ 2436.50',
                                  style: poppinsSemiBold.copyWith(
                                      fontSize: 15, color: ColorTheme.green)),
                              Text('Customer Name Here',
                                  style: poppinsSemiBold.copyWith(
                                      fontSize: 10, color: Color(0xFF828282))),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 10),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xFFDFDFDF),
                                ),
                                borderRadius: BorderRadius.circular(25)),
                            child: Text(
                              'Call Customer',
                              style: poppinsSemiBold.copyWith(
                                  fontSize: 13, color: Color(0xFFFF7E27)),
                            ),
                          ),
                        ],
                      )
                    : status == 1
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 35,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFFFE100)),
                                  child: Text('Print Bill',
                                      style: poppinsSemiBold.copyWith(
                                          fontSize: 13,
                                          color: Color(0xFF2E2E2E))),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 35,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFFFE100)),
                                  child: Text('Print KOT',
                                      style: poppinsSemiBold.copyWith(
                                          fontSize: 13,
                                          color: Color(0xFF2E2E2E))),
                                ),
                              ),
                            ],
                          )
                        : status == 2
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                    SizedBox(
                                      height: 35,
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFFFE100)),
                                        child: Text('Print Bill',
                                            style: poppinsSemiBold.copyWith(
                                                fontSize: 13,
                                                color: Color(0xFF2E2E2E))),
                                      ),
                                    ),
                                    Text(
                                      'OTP 4356',
                                      style: poppinsSemiBold.copyWith(
                                          fontSize: 18,
                                          color: Color(0xFF2E2E2E)),
                                    ),
                                  ])
                            : SizedBox(
                                height: 35,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFFFE100)),
                                  child: Text('Print Bill',
                                      style: poppinsSemiBold.copyWith(
                                          fontSize: 13,
                                          color: Color(0xFF2E2E2E))),
                                ),
                              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLine(
    BuildContext context,
    String label,
    String time,
  ) {
    return Column(
      children: [
        Text(label,
            style: poppinsSemiBold.copyWith(
                fontSize: 9, color: Color(0xFFC6C6C6))),
        const SizedBox(height: 4),
        Container(
          width: MediaQuery.of(context).size.width / 4,
          height: 1.5,
          color: Color(0xFFDFDFDF),
        ),
        const SizedBox(height: 4),
        Text(time,
            style: poppinsBold.copyWith(fontSize: 9, color: Color(0xFF828282))),
      ],
    );
  }

  Widget _buildStatusDot(Color color) =>
      CircleAvatar(radius: 6, backgroundColor: color);
}
