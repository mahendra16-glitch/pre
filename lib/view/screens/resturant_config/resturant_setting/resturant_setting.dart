// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mygenie_restaurant/admin/constant/app_style.dart';
// import 'package:mygenie_restaurant/helper/colors.dart';
// import 'package:mygenie_restaurant/util/images.dart';
// import 'package:mygenie_restaurant/util/styles.dart';
// import 'package:mygenie_restaurant/view/screens/menu_management_screen/widget/custom_textform_field.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:mygenie_restaurant/view/screens/resturant_config/controller/resturant_setting_controller.dart';

// class RestaurantSettingsScreen extends StatefulWidget {
//   const RestaurantSettingsScreen({super.key});

//   @override
//   State<RestaurantSettingsScreen> createState() =>
//       _RestaurantSettingsScreenState();
// }

// class _RestaurantSettingsScreenState extends State<RestaurantSettingsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Get.find<RestaurantSettingsController>().resetSettings();
//     Get.find<RestaurantSettingsController>().getResturantSettings();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorTheme.whiteColor,
//       appBar: AppBar(
//         backgroundColor: ColorTheme.whiteColor,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           color: ColorTheme.green,
//           onPressed: () => Get.back(),
//         ),
//         titleSpacing: 0,
//         elevation: 0,
//         centerTitle: false,
//         title: Text(
//           'Restaurant Settings',
//           style: montserratSemiBold.copyWith(
//               color: ColorTheme.black, fontSize: 16),
//         ),
//         actions: [
//           IconButton(
//               onPressed: () {
//                 Get.find<RestaurantSettingsController>().resetSettings();
//                 Get.find<RestaurantSettingsController>().getResturantSettings();
//               },
//               icon: Icon(
//                 Icons.replay_rounded,
//                 color: ColorTheme.white,
//               )),
//           SizedBox(width: 20),
//         ],
//       ),
//       body: GetBuilder<RestaurantSettingsController>(builder: (c) {
//         return SingleChildScrollView(
//           child: Form(
//             key: c.formKey,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: ExpansionPanelList.radio(
//                 expandIconColor: ColorTheme.green,
//                 initialOpenPanelValue: 'basic',
//                 dividerColor: ColorTheme.whiteE4,
//                 elevation: 0,
//                 expandedHeaderPadding: EdgeInsets.zero,
//                 children: [
//                   // Basic panel
//                   ExpansionPanelRadio(
//                     canTapOnHeader: true,
//                     value: 'basic',
//                     headerBuilder: (ctx, isExp) => ListTile(
//                       selectedTileColor: ColorTheme.green,
//                       selectedColor: ColorTheme.green,
//                       contentPadding: EdgeInsets.zero,
//                       leading: SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: SvgPicture.asset(Images.food_varations),
//                       ),
//                       title: Text(
//                         "Basic",
//                         style: TextStyle(
//                           color: ColorTheme.foodValue,
//                           fontFamily: "Montserrat",
//                         ),
//                       ),
//                     ),
//                     body: Padding(
//                       padding: EdgeInsets.all(
//                           (Platform.isAndroid || Platform.isIOS) ? 5 : 16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           CustomTextformField(
//                             keyboardType: TextInputType.text,
//                             labelText: 'Name as on Bill',
//                             controller: c.nameCtrl,
//                           ),
//                           const SizedBox(height: 16),
//                           CustomTextformField(
//                             keyboardType: TextInputType.text,
//                             labelText: 'Resturant Address',
//                             controller: c.resturantAddress,
//                           ),
//                           const SizedBox(height: 16),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: GestureDetector(
//                                   onTap: c.pickLogo,
//                                   child: Container(
//                                     height:
//                                         (Platform.isAndroid || Platform.isIOS)
//                                             ? 150
//                                             : 200,
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey[200],
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: c.logoFile != null
//                                         ? ClipRRect(
//                                             borderRadius:
//                                                 BorderRadius.circular(8),
//                                             child: Image.file(
//                                                 File(c.logoFile!.path),
//                                                 fit: BoxFit.cover),
//                                           )
//                                         : ((c.logoUrl != null &&
//                                                 c.logoUrl != '')
//                                             ? ClipRRect(
//                                                 borderRadius:
//                                                     BorderRadius.circular(8),
//                                                 child: CachedNetworkImage(
//                                                   imageUrl: c.logoUrl!,
//                                                   placeholder: (ci, url) =>
//                                                       CupertinoActivityIndicator(),
//                                                   errorWidget: (ci, url, e) =>
//                                                       Icon(Icons.error),
//                                                   fit: BoxFit.cover,
//                                                 ),
//                                               )
//                                             : Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   Icon(
//                                                       Icons.add_photo_alternate,
//                                                       size: (Platform
//                                                                   .isAndroid ||
//                                                               Platform.isIOS)
//                                                           ? 30
//                                                           : 50),
//                                                   Text(
//                                                     'Upload Logo',
//                                                     style: montserratMedium
//                                                         .copyWith(
//                                                             fontSize: (Platform
//                                                                         .isAndroid ||
//                                                                     Platform
//                                                                         .isIOS)
//                                                                 ? 10
//                                                                 : 15,
//                                                             color:
//                                                                 Colors.black),
//                                                   ),
//                                                 ],
//                                               )),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 flex: 2,
//                                 child: Column(
//                                   children: [
//                                     CustomTextformField(
//                                       keyboardType: TextInputType.text,
//                                       labelText: 'GST Number',
//                                       controller: c.gstNumCtrl,
//                                     ),
//                                     const SizedBox(height: 16),
//                                     CustomTextformField(
//                                       keyboardType: TextInputType.text,
//                                       labelText: 'VAT number',
//                                       controller: c.vatNumCtrl,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: CustomTextformField(
//                                   keyboardType: TextInputType.text,
//                                   labelText: 'UPI ID',
//                                   controller: c.upiIdCtrl,
//                                 ),
//                               ),
//                               const SizedBox(width: 20),
//                               Expanded(
//                                 child: CustomTextformField(
//                                   keyboardType: TextInputType.text,
//                                   labelText: 'FSSAI',
//                                   controller: c.fssaiCtrl,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: CustomTextformField(
//                                   keyboardType: TextInputType.phone,
//                                   labelText: 'Report Contact number',
//                                   controller: c.reportContactCtrl,
//                                   autovalidateMode:
//                                       AutovalidateMode.onUserInteraction,
//                                   validator: (value) {
//                                     if (value != null && value.isNotEmpty) {
//                                       return c.validatePhone(value.trim());
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(width: 20),
//                               Expanded(
//                                 child: CustomTextformField(
//                                   keyboardType: TextInputType.phone,
//                                   autovalidateMode:
//                                       AutovalidateMode.onUserInteraction,
//                                   labelText: 'Delivery contact number',
//                                   controller: c.deliveryContactCtrl,
//                                   validator: (value) {
//                                     if (value != null && value.isNotEmpty) {
//                                       return c.validatePhone(value.trim());
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           // const SizedBox(height: 16),
//                           // CustomTextformField(
//                           //   keyboardType: TextInputType.text,
//                           //   labelText: 'PDF Menu URL',
//                           //   readOnly: true,
//                           //   controller:
//                           //       TextEditingController(text: c.pdfMenuUrl),
//                           // ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   // Advanced panel
//                   ExpansionPanelRadio(
//                     canTapOnHeader: true,
//                     value: 'advanced',
//                     headerBuilder: (ctx, isExp) => ListTile(
//                       selectedTileColor: ColorTheme.green,
//                       selectedColor: ColorTheme.green,
//                       contentPadding: EdgeInsets.zero,
//                       leading: SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: SvgPicture.asset(Images.food_varations),
//                       ),
//                       title: Text(
//                         'Advanced',
//                         style: TextStyle(
//                           color: ColorTheme.foodValue,
//                           fontFamily: "Montserrat",
//                         ),
//                       ),
//                     ),
//                     body: Padding(
//                       padding: EdgeInsets.all(
//                           (Platform.isAndroid || Platform.isIOS) ? 5 : 16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CustomTextformField(
//                                   keyboardType: TextInputType.text,
//                                   labelText: 'Owner First Name',
//                                   controller: c.ownerFirstNameCtrl,
//                                 ),
//                               ),
//                               const SizedBox(width: 20),
//                               Expanded(
//                                 child: CustomTextformField(
//                                   keyboardType: TextInputType.text,
//                                   labelText: 'Owner Second Name',
//                                   controller: c.ownerSecondtNameCtrl,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 20),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CustomTextformField(
//                                     keyboardType: TextInputType.number,
//                                     labelText: 'Service Charge',
//                                     controller: c.serviceChargeText),
//                               ),
//                               const SizedBox(width: 20),
//                               Expanded(
//                                 child: CustomTextformField(
//                                     keyboardType: TextInputType.number,
//                                     labelText: 'Service Charge Tax (%)',
//                                     controller: c.serviceChargeTax),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 20),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CustomTextformField(
//                                   keyboardType: TextInputType.phone,
//                                   labelText: 'Owner Number',
//                                   controller: c.ownerNumberCtrl,
//                                   autovalidateMode:
//                                       AutovalidateMode.onUserInteraction,
//                                   validator: (value) {
//                                     if (value != null && value.isNotEmpty) {
//                                       return c.validatePhone(value.trim());
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(width: 20),
//                               Expanded(
//                                 child: CustomTextformField(
//                                   keyboardType: TextInputType.number,
//                                   labelText: 'Inventory Alert Number',
//                                   controller: c.inventoryAlertNumber,
//                                   autovalidateMode:
//                                       AutovalidateMode.onUserInteraction,
//                                   validator: (value) {
//                                     if (value != null && value.isNotEmpty) {
//                                       return c.validatePhone(value.trim());
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           // const SizedBox(height: 16),
//                           const SizedBox(height: 20),

// // Text Fields Row
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CustomTextformField(
//                                   keyboardType: TextInputType.number,
//                                   labelText: 'VAT Tax (%)',
//                                   controller: c.taxCtrl,
//                                 ),
//                               ),
//                               const SizedBox(width: 20),
//                               Expanded(
//                                 child: CustomTextformField(
//                                   keyboardType: TextInputType.number,
//                                   labelText: 'GST Tax (%)',
//                                   controller: c.gstTaxCtrl,
//                                 ),
//                               ),
//                             ],
//                           ),

//                           const SizedBox(height: 20),

//                           CustomTextformField(
//                             keyboardType: TextInputType.url,
//                             labelText: 'Feedback URL',
//                             controller: c.feedbackUrlCtrl,
//                           ),

//                           const SizedBox(height: 20),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: DropdownButtonFormField2<int>(
//                                   value: c.defOrdStatus,
//                                   items: c.defFoodStatus.map((status) {
//                                     // Determine the value for each status
//                                     int value = c.defFoodStatus.indexOf(status);

//                                     // Special case for 'Delivered'
//                                     if (status == 'Delivered') {
//                                       return DropdownMenuItem<int>(
//                                         value: 5,
//                                         child: Text(
//                                           status,
//                                           style: montserratMedium.copyWith(
//                                             color: Color(0xFF828282),
//                                             fontSize: 12,
//                                           ),
//                                         ),
//                                       );
//                                     }

//                                     return DropdownMenuItem<int>(
//                                       value: value,
//                                       child: Text(
//                                         status,
//                                         style: montserratMedium.copyWith(
//                                           color: Color(0xFF828282),
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                     );
//                                   }).toList(),
//                                   onChanged: (val) {
//                                     c.defOrdStatus = val ?? 0;
//                                     c.update();
//                                   },
//                                   buttonStyleData: ButtonStyleData(
//                                     padding:
//                                         EdgeInsets.symmetric(horizontal: 0),
//                                     // height: 48,
//                                     width: double.infinity,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(30),
//                                     ),
//                                     overlayColor: WidgetStateProperty.all(
//                                         Colors.transparent),
//                                   ),
//                                   dropdownStyleData: DropdownStyleData(
//                                     maxHeight: 400,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(14),
//                                       border: Border.all(
//                                         color: Color(0xFFDCDCDC),
//                                       ),
//                                     ),
//                                   ),
//                                   menuItemStyleData: MenuItemStyleData(
//                                     height: 45,
//                                   ),
//                                   decoration: InputDecoration(
//                                     labelText: 'Default Food Status',
//                                     labelStyle: montserratMedium.copyWith(
//                                         color: ColorTheme.black, fontSize: 17),
//                                     floatingLabelBehavior:
//                                         FloatingLabelBehavior.auto,
//                                     border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(30)),
//                                         borderSide: BorderSide(
//                                             color: Color(0xFFDCDCDC))),
//                                     focusedBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(30)),
//                                         borderSide: BorderSide(
//                                             color: Color(0xFFDCDCDC))),
//                                     errorBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(30)),
//                                         borderSide: BorderSide(
//                                             color: Color(0xFFDCDCDC))),
//                                     enabledBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(30)),
//                                         borderSide: BorderSide(
//                                             color: Color(0xFFDCDCDC))),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 20),
//                               Expanded(
//                                 child: DropdownButtonFormField2<String>(
//                                   value: c.orderPaymentType,
//                                   items: c.orderPaymentTypes.map((paymentType) {
//                                     return DropdownMenuItem<String>(
//                                       value: paymentType,
//                                       child: Text(
//                                         paymentType == 'prepaid'
//                                             ? 'Prepaid'
//                                             : paymentType == 'postpaid'
//                                                 ? 'Postpaid'
//                                                 : 'Both',
//                                         style: montserratMedium.copyWith(
//                                           color: Color(0xFF828282),
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                     );
//                                   }).toList(),
//                                   onChanged: (val) {
//                                     c.orderPaymentType = val ?? 'both';
//                                     c.update();
//                                   },
//                                   buttonStyleData: ButtonStyleData(
//                                     padding:
//                                         EdgeInsets.symmetric(horizontal: 0),
//                                     // height: 48,
//                                     width: double.infinity,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(30),
//                                     ),
//                                     overlayColor: WidgetStateProperty.all(
//                                         Colors.transparent),
//                                   ),
//                                   dropdownStyleData: DropdownStyleData(
//                                     maxHeight: 400,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(14),
//                                       border: Border.all(
//                                         color: Color(0xFFDCDCDC),
//                                       ),
//                                     ),
//                                   ),
//                                   menuItemStyleData: MenuItemStyleData(
//                                     height: 45,
//                                   ),
//                                   decoration: InputDecoration(
//                                     labelText: 'Order Payment Type',
//                                     labelStyle: montserratMedium.copyWith(
//                                         color: ColorTheme.black, fontSize: 17),
//                                     floatingLabelBehavior:
//                                         FloatingLabelBehavior.auto,
//                                     border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(30)),
//                                         borderSide: BorderSide(
//                                             color: Color(0xFFDCDCDC))),
//                                     focusedBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(30)),
//                                         borderSide: BorderSide(
//                                             color: Color(0xFFDCDCDC))),
//                                     errorBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(30)),
//                                         borderSide: BorderSide(
//                                             color: Color(0xFFDCDCDC))),
//                                     enabledBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(30)),
//                                         borderSide: BorderSide(
//                                             color: Color(0xFFDCDCDC))),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 20),

//                           Row(
//                             children: [
//                               Expanded(
//                                 child: DropdownButtonFormField2<String>(
//                                   value: c.listServeItem,
//                                   items: c.listServeItemOptions.map((option) {
//                                     return DropdownMenuItem<String>(
//                                       value: option,
//                                       child: Text(
//                                         option,
//                                         style: montserratMedium.copyWith(
//                                           color: Color(0xFF828282),
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                     );
//                                   }).toList(),
//                                   onChanged: (val) {
//                                     c.listServeItem = val ?? 'Dynamic';
//                                     c.update();
//                                   },
//                                   buttonStyleData: ButtonStyleData(
//                                     padding:
//                                         EdgeInsets.symmetric(horizontal: 0),
//                                     width: double.infinity,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(30),
//                                     ),
//                                     overlayColor: WidgetStateProperty.all(
//                                         Colors.transparent),
//                                   ),
//                                   dropdownStyleData: DropdownStyleData(
//                                     maxHeight: 400,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(14),
//                                       border: Border.all(
//                                         color: Color(0xFFDCDCDC),
//                                       ),
//                                     ),
//                                   ),
//                                   menuItemStyleData: MenuItemStyleData(
//                                     height: 45,
//                                   ),
//                                   decoration: InputDecoration(
//                                     labelText: 'List Serve Item',
//                                     labelStyle: montserratMedium.copyWith(
//                                         color: ColorTheme.black, fontSize: 17),
//                                     floatingLabelBehavior:
//                                         FloatingLabelBehavior.auto,
//                                     border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(30)),
//                                         borderSide: BorderSide(
//                                             color: Color(0xFFDCDCDC))),
//                                     focusedBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(30)),
//                                         borderSide: BorderSide(
//                                             color: Color(0xFFDCDCDC))),
//                                     errorBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(30)),
//                                         borderSide: BorderSide(
//                                             color: Color(0xFFDCDCDC))),
//                                     enabledBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(30)),
//                                         borderSide: BorderSide(
//                                             color: Color(0xFFDCDCDC))),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 20),

// // Dropdown for Send Feedback Link
//                               Expanded(
//                                 child: DropdownButtonFormField2<String>(
//                                   value: c.sendFeedbackLink,
//                                   items:
//                                       c.sendFeedbackLinkOptions.map((option) {
//                                     return DropdownMenuItem<String>(
//                                       value: option,
//                                       child: Text(
//                                         option.capitalize ?? option,
//                                         style: montserratMedium.copyWith(
//                                           color: Color(0xFF828282),
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                     );
//                                   }).toList(),
//                                   onChanged: (val) {
//                                     c.sendFeedbackLink = val ?? 'external';
//                                     c.update();
//                                   },
//                                   buttonStyleData: ButtonStyleData(
//                                     padding:
//                                         EdgeInsets.symmetric(horizontal: 0),
//                                     width: double.infinity,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(30),
//                                     ),
//                                     overlayColor: WidgetStateProperty.all(
//                                         Colors.transparent),
//                                   ),
//                                   dropdownStyleData: DropdownStyleData(
//                                     maxHeight: 400,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(14),
//                                       border: Border.all(
//                                         color: Color(0xFFDCDCDC),
//                                       ),
//                                     ),
//                                   ),
//                                   menuItemStyleData: MenuItemStyleData(
//                                     height: 45,
//                                   ),
//                                   decoration: InputDecoration(
//                                     labelText: 'Send Feedback Link',
//                                     labelStyle: montserratMedium.copyWith(
//                                         color: ColorTheme.black, fontSize: 17),
//                                     floatingLabelBehavior:
//                                         FloatingLabelBehavior.auto,
//                                     border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(30)),
//                                         borderSide: BorderSide(
//                                             color: Color(0xFFDCDCDC))),
//                                     focusedBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(30)),
//                                         borderSide: BorderSide(
//                                             color: Color(0xFFDCDCDC))),
//                                     errorBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(30)),
//                                         borderSide: BorderSide(
//                                             color: Color(0xFFDCDCDC))),
//                                     enabledBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(30)),
//                                         borderSide: BorderSide(
//                                             color: Color(0xFFDCDCDC))),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 20),

//                           // Dropdown for Restaurant GST
//                           DropdownButtonFormField2<String>(
//                             value: c.restaurentGst,
//                             items: c.restaurentGstOptions.map((option) {
//                               return DropdownMenuItem<String>(
//                                 value: option,
//                                 child: Text(
//                                   option == 'restaurant'
//                                       ? 'Restaurant'
//                                       : 'Item',
//                                   style: montserratMedium.copyWith(
//                                     color: Color(0xFF828282),
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                             onChanged: (val) {
//                               c.restaurentGst = (val == 'Item')
//                                   ? 'category'
//                                   : val ?? 'restaurant';
//                               c.update();
//                             },
//                             buttonStyleData: ButtonStyleData(
//                               padding: EdgeInsets.symmetric(horizontal: 0),
//                               width: double.infinity,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               overlayColor:
//                                   WidgetStateProperty.all(Colors.transparent),
//                             ),
//                             dropdownStyleData: DropdownStyleData(
//                               maxHeight: 400,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(14),
//                                 border: Border.all(
//                                   color: Color(0xFFDCDCDC),
//                                 ),
//                               ),
//                             ),
//                             menuItemStyleData: MenuItemStyleData(
//                               height: 45,
//                             ),
//                             decoration: InputDecoration(
//                               labelText: 'Restaurant GST',
//                               labelStyle: montserratMedium.copyWith(
//                                   color: ColorTheme.black, fontSize: 17),
//                               floatingLabelBehavior: FloatingLabelBehavior.auto,
//                               border: OutlineInputBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(30)),
//                                   borderSide:
//                                       BorderSide(color: Color(0xFFDCDCDC))),
//                               focusedBorder: OutlineInputBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(30)),
//                                   borderSide:
//                                       BorderSide(color: Color(0xFFDCDCDC))),
//                               errorBorder: OutlineInputBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(30)),
//                                   borderSide:
//                                       BorderSide(color: Color(0xFFDCDCDC))),
//                               enabledBorder: OutlineInputBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(30)),
//                                   borderSide:
//                                       BorderSide(color: Color(0xFFDCDCDC))),
//                             ),
//                           ),

//                           const SizedBox(height: 20),
//                           CustomTextformField(
//                             keyboardType: TextInputType.text,
//                             readOnly: true,
//                             labelText: 'Upload Pdf Menu',
//                             controller: c.uploadMenuCtrl,
//                             suffixIcon: InkWell(
//                               onTap: c.pickPdf,
//                               child: Padding(
//                                 padding: EdgeInsets.all(10),
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal:
//                                           (Platform.isAndroid || Platform.isIOS)
//                                               ? 40
//                                               : 60,
//                                       vertical: 10),
//                                   decoration: BoxDecoration(
//                                       borderRadius:
//                                           BorderRadius.all(Radius.circular(40)),
//                                       color: ColorTheme.appColor),
//                                   child: Icon(
//                                     Icons.upload_file_rounded,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 20),
//                           // const SizedBox(height: 20),

//                           Row(
//                             children: [
//                               Text('Search By ', style: c.textStyle1),
//                               const SizedBox(width: 20),
//                               Expanded(
//                                 child: Wrap(
//                                   spacing: 8,
//                                   children: [
//                                     'table no',
//                                     'order id',
//                                     'user id',
//                                     'phone no'
//                                   ].map((label) {
//                                     String formattedLabel =
//                                         label.split(' ').map((word) {
//                                       return word[0].toUpperCase() +
//                                           word.substring(1).toLowerCase();
//                                     }).join(' ');
//                                     return ChoiceChip(
//                                       label: Text(
//                                         formattedLabel,
//                                         style: montserratMedium.copyWith(
//                                             color: c.searchBy.contains(label)
//                                                 ? ColorTheme.black
//                                                 : Color(0xFF828282),
//                                             fontSize: 12),
//                                       ),
//                                       selected: c.searchBy.contains(label),
//                                       selectedColor: Colors.yellow,
//                                       backgroundColor: Colors.white,
//                                       onSelected: (sel) {
//                                         setState(() {
//                                           if (sel)
//                                             c.searchBy.add(label);
//                                           else
//                                             c.searchBy.remove(label);
//                                         });
//                                         c.update();
//                                       },
//                                     );
//                                   }).toList(),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 20),

//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text(
//                                     'GST',
//                                     style: c.textStyle,
//                                   ),
//                                   value: c.gstCheck,
//                                   onChanged: (v) {
//                                     c.gstCheck = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text(
//                                     'VAT',
//                                     style: c.textStyle,
//                                   ),
//                                   value: c.vatCheck,
//                                   onChanged: (v) {
//                                     c.vatCheck = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           // const SizedBox(height: 25),
//                           // Text('Payment Types', style: c.textStyle1),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Cash', style: c.textStyle),
//                                   value: c.selectedPayments.contains('Cash'),
//                                   onChanged: (v) {
//                                     if (v!) {
//                                       c.selectedPayments.add('Cash');
//                                     } else {
//                                       c.selectedPayments.remove('Cash');
//                                     }
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Card', style: c.textStyle),
//                                   value: c.selectedPayments.contains('Card'),
//                                   onChanged: (v) {
//                                     if (v!) {
//                                       c.selectedPayments.add('Card');
//                                     } else {
//                                       c.selectedPayments.remove('Card');
//                                     }
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Tab', style: c.textStyle),
//                                   value: c.selectedPayments.contains('Tab'),
//                                   onChanged: (v) {
//                                     if (v!) {
//                                       c.selectedPayments.add('Tab');
//                                     } else {
//                                       c.selectedPayments.remove('Tab');
//                                     }
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('UPI', style: c.textStyle),
//                                   value: c.selectedPayments.contains('UPI'),
//                                   onChanged: (v) {
//                                     if (v!) {
//                                       c.selectedPayments.add('UPI');
//                                     } else {
//                                       c.selectedPayments.remove('UPI');
//                                     }
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Room', style: c.textStyle),
//                                   value: c.selectedPayments.contains('Room'),
//                                   onChanged: (v) {
//                                     if (v!) {
//                                       c.selectedPayments.add('Room');
//                                     } else {
//                                       c.selectedPayments.remove('Room');
//                                     }
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Cash on Delivery(web)',
//                                       style: c.textStyle),
//                                   value: c.selectedPayments
//                                       .contains('Cash on Delivery'),
//                                   onChanged: (v) {
//                                     if (v!) {
//                                       c.selectedPayments
//                                           .add('Cash on Delivery');
//                                     } else {
//                                       c.selectedPayments
//                                           .remove('Cash on Delivery');
//                                     }
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),

//                           // const SizedBox(height: 25),
//                           // Text('Channels', style: c.textStyle1),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Delivery', style: c.textStyle),
//                                   value:
//                                       c.selectedChannels.contains('Delivery'),
//                                   onChanged: (v) {
//                                     if (v!) {
//                                       c.selectedChannels.add('Delivery');
//                                     } else {
//                                       c.selectedChannels.remove('Delivery');
//                                     }
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Takeaway', style: c.textStyle),
//                                   value:
//                                       c.selectedChannels.contains('Takeaway'),
//                                   onChanged: (v) {
//                                     if (v!) {
//                                       c.selectedChannels.add('Takeaway');
//                                     } else {
//                                       c.selectedChannels.remove('Takeaway');
//                                     }
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Print KOT', style: c.textStyle),
//                                   value: c.PrintKot,
//                                   onChanged: (v) {
//                                     c.PrintKot = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Dinein', style: c.textStyle),
//                                   value: c.selectedChannels.contains('Dinein'),
//                                   onChanged: (v) {
//                                     if (v!) {
//                                       c.selectedChannels.add('Dinein');
//                                     } else {
//                                       c.selectedChannels.remove('Dinein');
//                                     }
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),

//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Tip', style: c.textStyle),
//                                   // contentPadding: EdgeInsets.zero,

//                                   value: c.tipEnabled,
//                                   onChanged: (v) {
//                                     c.tipEnabled = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Discount', style: c.textStyle),
//                                   value: c.availableDiscount,
//                                   onChanged: (v) {
//                                     c.availableDiscount = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Inventory', style: c.textStyle),
//                                   value: c.inventoryEnabled,
//                                   onChanged: (v) {
//                                     c.inventoryEnabled = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Inventory Negative',
//                                       style: c.textStyle),
//                                   value: c.inventoryNegative,
//                                   onChanged: (v) {
//                                     c.inventoryNegative = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Dynamic UPI Value',
//                                       style: c.textStyle),
//                                   value: c.dynamicUpiValue,
//                                   onChanged: (v) {
//                                     c.dynamicUpiValue = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title:
//                                       Text('Total Round', style: c.textStyle),
//                                   value: c.totalRound,
//                                   onChanged: (v) {
//                                     c.totalRound = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Auto Service Charge',
//                                       style: c.textStyle),
//                                   value: c.autoServiceCharge,
//                                   onChanged: (v) {
//                                     c.autoServiceCharge = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Service Charge',
//                                       style: c.textStyle),
//                                   value: c.serviceCharge,
//                                   onChanged: (v) {
//                                     c.serviceCharge = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Settlement Report',
//                                       style: c.textStyle),
//                                   value: c.settlementReport,
//                                   onChanged: (v) {
//                                     c.settlementReport = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Real-time Order Status',
//                                       style: c.textStyle),
//                                   value: c.realTimeOrderStatus,
//                                   onChanged: (v) {
//                                     c.realTimeOrderStatus = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Show Popular Food',
//                                       style: c.textStyle),
//                                   value: c.showPopularCategory,
//                                   onChanged: (v) {
//                                     c.showPopularCategory = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Food Level Notes',
//                                       style: c.textStyle),
//                                   value: c.foodLevelNotes,
//                                   onChanged: (v) {
//                                     c.foodLevelNotes = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Order Confirm for Web',
//                                       style: c.textStyle),
//                                   value: c.orderConfirmForWeb,
//                                   onChanged: (v) {
//                                     c.orderConfirmForWeb = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Show Food Variance',
//                                       style: c.textStyle),
//                                   value: c.showFoodVariance,
//                                   onChanged: (v) {
//                                     c.showFoodVariance = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Billing Auto Bill Print',
//                                       style: c.textStyle),
//                                   value: c.billingAutoBillPrint,
//                                   onChanged: (v) {
//                                     c.billingAutoBillPrint = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Show AC & Non-AC Menu',
//                                       style: c.textStyle),
//                                   value: c.showAcNonMenu,
//                                   onChanged: (v) {
//                                     c.showAcNonMenu = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Show Food Date',
//                                       style: c.textStyle),
//                                   value: c.foodDate,
//                                   onChanged: (v) {
//                                     c.foodDate = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Feedback', style: c.textStyle),
//                                   value: c.feedBack,
//                                   onChanged: (v) {
//                                     c.feedBack = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Delivery Online Payment',
//                                       style: c.textStyle),
//                                   value: c.deliveryOnlinePayment,
//                                   onChanged: (v) {
//                                     c.deliveryOnlinePayment = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Walkin Online Payment ',
//                                       style: c.textStyle),
//                                   value: c.walkinOnlinePayment,
//                                   onChanged: (v) {
//                                     c.walkinOnlinePayment = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Dinein Online Payment',
//                                       style: c.textStyle),
//                                   value: c.dineinOnlinePayment,
//                                   onChanged: (v) {
//                                     c.dineinOnlinePayment = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Takeaway Online Payment',
//                                       style: c.textStyle),
//                                   value: c.takeawayOnlinePayment,
//                                   onChanged: (v) {
//                                     c.takeawayOnlinePayment = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),

//                           Row(
//                             children: [
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title: Text('Cancel Pre Serve',
//                                       style: c.textStyle),
//                                   value: c.canclePostServe,
//                                   onChanged: (v) {
//                                     c.canclePostServe = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                               Expanded(
//                                 child: CheckboxListTile(
//                                   title:
//                                       Text('Voice in KDS', style: c.textStyle),
//                                   value: c.voiceInKds,
//                                   onChanged: (v) {
//                                     c.voiceInKds = v!;
//                                     c.update();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }),
//       bottomNavigationBar:
//           GetBuilder<RestaurantSettingsController>(builder: (controller) {
//         return Padding(
//           padding: const EdgeInsets.all(0.0),
//           child: Container(
//             height: 80,
//             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18),
//             decoration: BoxDecoration(color: ColorTheme.white),
//             child: Row(
//               children: [
//                 Expanded(
//                     child: InkWell(
//                   onTap: controller.resetSettings,
//                   child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 10),
//                       decoration: const BoxDecoration(
//                           color: Color(0xFFEFEFEF),
//                           borderRadius: BorderRadius.all(Radius.circular(30))),
//                       child: controller.isResetting
//                           ? SpinKitFadingCircle(
//                               color: ColorTheme.borderGrey,
//                               size: 25.0,
//                             )
//                           : Center(
//                               child: Text(
//                               'Reset',
//                               style: montserratSemiBold.copyWith(
//                                   color: ColorTheme.borderGrey, fontSize: 15),
//                             ))),
//                 )),
//                 const SizedBox(width: 10),
//                 Expanded(
//                     child: InkWell(
//                   onTap: controller.updateResturantSetting,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(vertical: 10),
//                     decoration: BoxDecoration(
//                         color: ColorTheme.green,
//                         borderRadius:
//                             const BorderRadius.all(Radius.circular(30))),
//                     child: !controller.isSubmitting
//                         ? Center(
//                             child: Text(
//                             "Update ",
//                             style: montserratSemiBold.copyWith(
//                                 color: ColorTheme.white, fontSize: 15),
//                           ))
//                         : const SpinKitFadingCircle(
//                             color: Colors.white,
//                             size: 20.0,
//                           ),
//                   ),
//                 )),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/widget/custom_textform_field.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/resturant_setting_controller.dart';

class RestaurantSettingsScreen extends StatefulWidget {
  const RestaurantSettingsScreen({super.key});

  @override
  State<RestaurantSettingsScreen> createState() =>
      _RestaurantSettingsScreenState();
}

class _RestaurantSettingsScreenState extends State<RestaurantSettingsScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<RestaurantSettingsController>().resetSettings();
    Get.find<RestaurantSettingsController>().getResturantSettings();
  }

  @override
  Widget build(BuildContext context) {
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
          'Restaurant Settings',
          style: montserratSemiBold.copyWith(
              color: ColorTheme.black, fontSize: 16),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Get.find<RestaurantSettingsController>().resetSettings();
                Get.find<RestaurantSettingsController>().getResturantSettings();
              },
              icon: Icon(
                Icons.replay_rounded,
                color: ColorTheme.white,
              )),
          SizedBox(width: 20),
        ],
      ),
      body: GetBuilder<RestaurantSettingsController>(builder: (c) {
        return SingleChildScrollView(
          child: Form(
            key: c.formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ExpansionPanelList.radio(
                expandIconColor: ColorTheme.green,
                initialOpenPanelValue: 'basic',
                dividerColor: ColorTheme.whiteE4,
                elevation: 0,
                expandedHeaderPadding: EdgeInsets.zero,
                children: [
                  // ==================== BASIC SETTINGS ====================
                  ExpansionPanelRadio(
                    canTapOnHeader: true,
                    value: 'basic',
                    headerBuilder: (ctx, isExp) => ListTile(
                      selectedTileColor: ColorTheme.green,
                      selectedColor: ColorTheme.green,
                      contentPadding: EdgeInsets.zero,
                      leading: SizedBox(
                        width: 20,
                        height: 20,
                        child: SvgPicture.asset(Images.food_varations),
                      ),
                      title: Text(
                        "Basic Settings",
                        style: TextStyle(
                          color: ColorTheme.foodValue,
                          fontFamily: "Montserrat",
                        ),
                      ),
                    ),
                    body: Padding(
                      padding: EdgeInsets.all(
                          (Platform.isAndroid || Platform.isIOS) ? 5 : 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Restaurant Name and Address in Row
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextformField(
                                  keyboardType: TextInputType.text,
                                  labelText: 'Restaurant Name',
                                  controller: c.nameCtrl,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomTextformField(
                                  keyboardType: TextInputType.text,
                                  labelText: 'Restaurant Address',
                                  controller: c.resturantAddress,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Phone Number on Bill and Email ID on Bill in Row
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextformField(
                                  keyboardType: TextInputType.phone,
                                  labelText: 'Phone Number on Bill',
                                  controller: c.phoneNumberOnBillCtrl,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      return c.validatePhone(value.trim());
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              // const SizedBox(width: 16),
                              // Expanded(
                              //   child: CustomTextformField(
                              //     keyboardType: TextInputType.emailAddress,
                              //     labelText: 'Email ID on Bill',
                              //     controller: c.emailIdOnBillCtrl,
                              //   ),
                              // ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // FSSAI Number and GST Number in Row
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextformField(
                                  keyboardType: TextInputType.text,
                                  labelText: 'FSSAI Number',
                                  controller: c.fssaiCtrl,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomTextformField(
                                  keyboardType: TextInputType.text,
                                  labelText: 'GST Number',
                                  controller: c.gstNumCtrl,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Configuration Type and GST Calculation in Row
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField2<int>(
                                  value: c.defOrdStatus,
                                  items: c.defFoodStatus.map((status) {
                                    int value = c.defFoodStatus.indexOf(status);
                                    if (status == 'Delivered') {
                                      return DropdownMenuItem<int>(
                                        value: 5,
                                        child: Text(
                                          status,
                                          style: montserratMedium.copyWith(
                                            color: Color(0xFF828282),
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    }
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(
                                        status,
                                        style: montserratMedium.copyWith(
                                          color: Color(0xFF828282),
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    c.defOrdStatus = val ?? 0;
                                    c.update();
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    overlayColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 400,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Color(0xFFDCDCDC),
                                      ),
                                    ),
                                  ),
                                  menuItemStyleData: MenuItemStyleData(
                                    height: 45,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Configuration Type',
                                    labelStyle: montserratMedium.copyWith(
                                        color: ColorTheme.black, fontSize: 17),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField2<String>(
                                  value: c.restaurentGst,
                                  items: c.restaurentGstOptions.map((option) {
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(
                                        option == 'restaurant'
                                            ? 'Restaurant'
                                            : 'Item',
                                        style: montserratMedium.copyWith(
                                          color: Color(0xFF828282),
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    c.restaurentGst = (val == 'Item')
                                        ? 'category'
                                        : val ?? 'restaurant';
                                    c.update();
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    overlayColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 400,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Color(0xFFDCDCDC),
                                      ),
                                    ),
                                  ),
                                  menuItemStyleData: MenuItemStyleData(
                                    height: 45,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'GST Calculation',
                                    labelStyle: montserratMedium.copyWith(
                                        color: ColorTheme.black, fontSize: 17),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // UPI ID and GST Tax Percentage in Row
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextformField(
                                  keyboardType: TextInputType.text,
                                  labelText: 'UPI ID',
                                  controller: c.upiIdCtrl,
                                ),
                              ),
                              if (c.restaurentGst == 'restaurant')
                                const SizedBox(width: 16),
                              // GST Tax Percentage - Only show when GST Calculation is 'restaurant'
                              if (c.restaurentGst == 'restaurant')
                                Expanded(
                                    child: CustomTextformField(
                                  keyboardType: TextInputType.number,
                                  labelText: 'GST Tax Percentage (%)',
                                  controller: c.gstTaxCtrl,
                                )),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: c.pickLogo,
                                  child: Container(
                                    height:
                                        (Platform.isAndroid || Platform.isIOS)
                                            ? 150
                                            : 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: c.logoFile != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.file(
                                                File(c.logoFile!.path),
                                                fit: BoxFit.cover),
                                          )
                                        : ((c.logoUrl != null &&
                                                c.logoUrl != '')
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: CachedNetworkImage(
                                                  imageUrl: c.logoUrl!,
                                                  placeholder: (ci, url) =>
                                                      CupertinoActivityIndicator(),
                                                  errorWidget: (ci, url, e) =>
                                                      Icon(Icons.error),
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                      Icons.add_photo_alternate,
                                                      size: (Platform
                                                                  .isAndroid ||
                                                              Platform.isIOS)
                                                          ? 30
                                                          : 50),
                                                  Text(
                                                    'Upload Logo',
                                                    style: montserratMedium
                                                        .copyWith(
                                                            fontSize: (Platform
                                                                        .isAndroid ||
                                                                    Platform
                                                                        .isIOS)
                                                                ? 10
                                                                : 15,
                                                            color:
                                                                Colors.black),
                                                  ),
                                                ],
                                              )),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    _buildMultiSelectPaymentDropdown(c),
                                    const SizedBox(height: 16),
                                    CustomTextformField(
                                      keyboardType: TextInputType.text,
                                      readOnly: true,
                                      labelText: 'Upload Pdf Menu',
                                      controller: c.uploadMenuCtrl,
                                      suffixIcon: InkWell(
                                        onTap: c.pickPdf,
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    (Platform.isAndroid ||
                                                            Platform.isIOS)
                                                        ? 40
                                                        : 60,
                                                vertical: 10),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(40)),
                                                color: ColorTheme.appColor),
                                            child: Icon(
                                              Icons.upload_file_rounded,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Auto Print KOT',
                                      style: c.textStyle),
                                  value: c.PrintKot,
                                  onChanged: (v) {
                                    c.PrintKot = v!;
                                    c.update();
                                  },
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Auto Print Bill',
                                      style: c.textStyle),
                                  value: c.billingAutoBillPrint,
                                  onChanged: (v) {
                                    c.billingAutoBillPrint = v!;
                                    c.update();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Bill Round off',
                                      style: c.textStyle),
                                  value: c.totalRound,
                                  onChanged: (v) {
                                    c.totalRound = v!;
                                    c.update();
                                  },
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Send feedback link',
                                      style: c.textStyle),
                                  value: c.feedBack,
                                  onChanged: (v) {
                                    c.feedBack = v!;
                                    c.update();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ==================== ADVANCED SETTINGS ====================
                  ExpansionPanelRadio(
                    canTapOnHeader: true,
                    value: 'advanced',
                    headerBuilder: (ctx, isExp) => ListTile(
                      selectedTileColor: ColorTheme.green,
                      selectedColor: ColorTheme.green,
                      contentPadding: EdgeInsets.zero,
                      leading: SizedBox(
                        width: 20,
                        height: 20,
                        child: SvgPicture.asset(Images.food_varations),
                      ),
                      title: Text(
                        'Advanced Settings',
                        style: TextStyle(
                          color: ColorTheme.foodValue,
                          fontFamily: "Montserrat",
                        ),
                      ),
                    ),
                    body: Padding(
                      padding: EdgeInsets.all(
                          (Platform.isAndroid || Platform.isIOS) ? 5 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Channels dropdown - showing selected items
                          _buildMultiSelectChannelsDropdown(c),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextformField(
                                  keyboardType: TextInputType.text,
                                  labelText: 'VAT Number',
                                  controller: c.vatNumCtrl,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CustomTextformField(
                                  keyboardType: TextInputType.number,
                                  labelText: 'VAT Percentage',
                                  controller: c.taxCtrl,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Feedback Link and Online ordering link in Row
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextformField(
                                  keyboardType: TextInputType.url,
                                  labelText: 'Feedback Link',
                                  controller: c.feedbackUrlCtrl,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CustomTextformField(
                                  keyboardType: TextInputType.url,
                                  labelText: 'Online ordering link',
                                  controller: c.onlineOrderingLinkCtrl,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Service Charge Percentage and Service Charge Tax in Row
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextformField(
                                  keyboardType: TextInputType.number,
                                  labelText: 'Service Charge',
                                  controller: c.serviceChargeText,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CustomTextformField(
                                  keyboardType: TextInputType.number,
                                  // labelText: 'Service Charge Tax (%)',
                                  labelText: 'GST on Service Charge',
                                  controller: c.serviceChargeTax,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Order Payment Type - single dropdown
                          DropdownButtonFormField2<String>(
                            value: c.orderPaymentType,
                            items: c.orderPaymentTypes.map((paymentType) {
                              return DropdownMenuItem<String>(
                                value: paymentType,
                                child: Text(
                                  paymentType == 'prepaid'
                                      ? 'Prepaid'
                                      : paymentType == 'postpaid'
                                          ? 'Postpaid'
                                          : 'Both',
                                  style: montserratMedium.copyWith(
                                    color: Color(0xFF828282),
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              c.orderPaymentType = val ?? 'both';
                              c.update();
                            },
                            buttonStyleData: ButtonStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              overlayColor:
                                  WidgetStateProperty.all(Colors.transparent),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 400,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Color(0xFFDCDCDC),
                                ),
                              ),
                            ),
                            menuItemStyleData: MenuItemStyleData(
                              height: 45,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Order Payment Type',
                              labelStyle: montserratMedium.copyWith(
                                  color: ColorTheme.black, fontSize: 17),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  borderSide:
                                      BorderSide(color: Color(0xFFDCDCDC))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  borderSide:
                                      BorderSide(color: Color(0xFFDCDCDC))),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  borderSide:
                                      BorderSide(color: Color(0xFFDCDCDC))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  borderSide:
                                      BorderSide(color: Color(0xFFDCDCDC))),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Restaurant Type - single dropdown
                          DropdownButtonFormField2<String>(
                            value: c.restaurantFor,
                            items: c.restaurantForTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  type == 'food_court'
                                      ? 'Food Court'
                                      : type,
                                  style: montserratMedium.copyWith(
                                    color: Color(0xFF828282),
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              c.restaurantFor = val ?? 'Normal';
                              c.update();
                            },
                            buttonStyleData: ButtonStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              overlayColor:
                                  WidgetStateProperty.all(Colors.transparent),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 400,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Color(0xFFDCDCDC),
                                ),
                              ),
                            ),
                            menuItemStyleData: MenuItemStyleData(
                              height: 45,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Restaurant Type',
                              labelStyle: montserratMedium.copyWith(
                                  color: ColorTheme.black, fontSize: 17),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  borderSide:
                                      BorderSide(color: Color(0xFFDCDCDC))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  borderSide:
                                      BorderSide(color: Color(0xFFDCDCDC))),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  borderSide:
                                      BorderSide(color: Color(0xFFDCDCDC))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  borderSide:
                                      BorderSide(color: Color(0xFFDCDCDC))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ==================== OTHER CONFIGURATIONS ====================
                  ExpansionPanelRadio(
                    canTapOnHeader: true,
                    value: 'other',
                    headerBuilder: (ctx, isExp) => ListTile(
                      selectedTileColor: ColorTheme.green,
                      selectedColor: ColorTheme.green,
                      contentPadding: EdgeInsets.zero,
                      leading: SizedBox(
                        width: 20,
                        height: 20,
                        child: SvgPicture.asset(Images.food_varations),
                      ),
                      title: Text(
                        'Other Configurations',
                        style: TextStyle(
                          color: ColorTheme.foodValue,
                          fontFamily: "Montserrat",
                        ),
                      ),
                    ),
                    body: Padding(
                      padding: EdgeInsets.all(
                          (Platform.isAndroid || Platform.isIOS) ? 5 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Text('Search By ', style: c.textStyle1),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  children: [
                                    'table no',
                                    'order id',
                                    'user id',
                                    'phone no'
                                  ].map((label) {
                                    String formattedLabel =
                                        label.split(' ').map((word) {
                                      return word[0].toUpperCase() +
                                          word.substring(1).toLowerCase();
                                    }).join(' ');
                                    return ChoiceChip(
                                      label: Text(
                                        formattedLabel,
                                        style: montserratMedium.copyWith(
                                            color: c.searchBy.contains(label)
                                                ? ColorTheme.black
                                                : Color(0xFF828282),
                                            fontSize: 12),
                                      ),
                                      selected: c.searchBy.contains(label),
                                      selectedColor: Colors.yellow,
                                      backgroundColor: Colors.white,
                                      onSelected: (sel) {
                                        setState(() {
                                          if (sel)
                                            c.searchBy.add(label);
                                          else
                                            c.searchBy.remove(label);
                                        });
                                        c.update();
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text(
                                    'GST',
                                    style: c.textStyle,
                                  ),
                                  value: c.gstCheck,
                                  onChanged: (v) {
                                    c.gstCheck = v!;
                                    c.update();
                                  },
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text(
                                    'VAT',
                                    style: c.textStyle,
                                  ),
                                  value: c.vatCheck,
                                  onChanged: (v) {
                                    c.vatCheck = v!;
                                    c.update();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Tip', style: c.textStyle),
                                  value: c.tipEnabled,
                                  onChanged: (v) {
                                    c.tipEnabled = v!;
                                    c.update();
                                  },
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Discount', style: c.textStyle),
                                  value: c.availableDiscount,
                                  onChanged: (v) {
                                    c.availableDiscount = v!;
                                    c.update();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Inventory', style: c.textStyle),
                                  value: c.inventoryEnabled,
                                  onChanged: (v) {
                                    c.inventoryEnabled = v!;
                                    c.update();
                                  },
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Inventory Negative',
                                      style: c.textStyle),
                                  value: c.inventoryNegative,
                                  onChanged: (v) {
                                    c.inventoryNegative = v!;
                                    c.update();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Dynamic UPI Value',
                                      style: c.textStyle),
                                  value: c.dynamicUpiValue,
                                  onChanged: (v) {
                                    c.dynamicUpiValue = v!;
                                    c.update();
                                  },
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Auto Service Charge',
                                      style: c.textStyle),
                                  value: c.autoServiceCharge,
                                  onChanged: (v) {
                                    c.autoServiceCharge = v!;
                                    c.update();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Service Charge',
                                      style: c.textStyle),
                                  value: c.serviceCharge,
                                  onChanged: (v) {
                                    c.serviceCharge = v!;
                                    c.update();
                                  },
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Settlement Report',
                                      style: c.textStyle),
                                  value: c.settlementReport,
                                  onChanged: (v) {
                                    c.settlementReport = v!;
                                    c.update();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Real-time Order Status',
                                      style: c.textStyle),
                                  value: c.realTimeOrderStatus,
                                  onChanged: (v) {
                                    c.realTimeOrderStatus = v!;
                                    c.update();
                                  },
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Show Popular Food',
                                      style: c.textStyle),
                                  value: c.showPopularCategory,
                                  onChanged: (v) {
                                    c.showPopularCategory = v!;
                                    c.update();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Food Level Notes',
                                      style: c.textStyle),
                                  value: c.foodLevelNotes,
                                  onChanged: (v) {
                                    c.foodLevelNotes = v!;
                                    c.update();
                                  },
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Order Confirm for Web',
                                      style: c.textStyle),
                                  value: c.orderConfirmForWeb,
                                  onChanged: (v) {
                                    c.orderConfirmForWeb = v!;
                                    c.update();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Show Food Variance',
                                      style: c.textStyle),
                                  value: c.showFoodVariance,
                                  onChanged: (v) {
                                    c.showFoodVariance = v!;
                                    c.update();
                                  },
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Show AC & Non-AC Menu',
                                      style: c.textStyle),
                                  value: c.showAcNonMenu,
                                  onChanged: (v) {
                                    c.showAcNonMenu = v!;
                                    c.update();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Show Food Date',
                                      style: c.textStyle),
                                  value: c.foodDate,
                                  onChanged: (v) {
                                    c.foodDate = v!;
                                    c.update();
                                  },
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Delivery Online Payment',
                                      style: c.textStyle),
                                  value: c.deliveryOnlinePayment,
                                  onChanged: (v) {
                                    c.deliveryOnlinePayment = v!;
                                    c.update();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Walkin Online Payment ',
                                      style: c.textStyle),
                                  value: c.walkinOnlinePayment,
                                  onChanged: (v) {
                                    c.walkinOnlinePayment = v!;
                                    c.update();
                                  },
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Dinein Online Payment',
                                      style: c.textStyle),
                                  value: c.dineinOnlinePayment,
                                  onChanged: (v) {
                                    c.dineinOnlinePayment = v!;
                                    c.update();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Takeaway Online Payment',
                                      style: c.textStyle),
                                  value: c.takeawayOnlinePayment,
                                  onChanged: (v) {
                                    c.takeawayOnlinePayment = v!;
                                    c.update();
                                  },
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: Text('Cancel Pre Serve',
                                      style: c.textStyle),
                                  value: c.canclePostServe,
                                  onChanged: (v) {
                                    c.canclePostServe = v!;
                                    c.update();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title:
                                      Text('Voice in KDS', style: c.textStyle),
                                  value: c.voiceInKds,
                                  onChanged: (v) {
                                    c.voiceInKds = v!;
                                    c.update();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField2<String>(
                                  value: c.listServeItem,
                                  items: c.listServeItemOptions.map((option) {
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(
                                        option,
                                        style: montserratMedium.copyWith(
                                          color: Color(0xFF828282),
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    c.listServeItem = val ?? 'Dynamic';
                                    c.update();
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    overlayColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 400,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Color(0xFFDCDCDC),
                                      ),
                                    ),
                                  ),
                                  menuItemStyleData: MenuItemStyleData(
                                    height: 45,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'List Serve Item',
                                    labelStyle: montserratMedium.copyWith(
                                        color: ColorTheme.black, fontSize: 17),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: DropdownButtonFormField2<String>(
                                  value: c.sendFeedbackLink,
                                  items:
                                      c.sendFeedbackLinkOptions.map((option) {
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(
                                        option.capitalize ?? option,
                                        style: montserratMedium.copyWith(
                                          color: Color(0xFF828282),
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    c.sendFeedbackLink = val ?? 'external';
                                    c.update();
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    overlayColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 400,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Color(0xFFDCDCDC),
                                      ),
                                    ),
                                  ),
                                  menuItemStyleData: MenuItemStyleData(
                                    height: 45,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Send Feedback Link',
                                    labelStyle: montserratMedium.copyWith(
                                        color: ColorTheme.black, fontSize: 17),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField2<String>(
                                  value: c.shortCode,
                                  items: c.shortCodeOptions.map((option) {
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(
                                        option,
                                        style: montserratMedium.copyWith(
                                          color: Color(0xFF828282),
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    c.shortCode = val ?? 'No';
                                    c.update();
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    overlayColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 400,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Color(0xFFDCDCDC),
                                      ),
                                    ),
                                  ),
                                  menuItemStyleData: MenuItemStyleData(
                                    height: 45,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Short Code',
                                    labelStyle: montserratMedium.copyWith(
                                        color: ColorTheme.black, fontSize: 17),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ==================== CONTACT DETAILS ====================
                  ExpansionPanelRadio(
                    canTapOnHeader: true,
                    value: 'contact',
                    headerBuilder: (ctx, isExp) => ListTile(
                      selectedTileColor: ColorTheme.green,
                      selectedColor: ColorTheme.green,
                      contentPadding: EdgeInsets.zero,
                      leading: SizedBox(
                        width: 20,
                        height: 20,
                        child: SvgPicture.asset(Images.food_varations),
                      ),
                      title: Text(
                        'Contact Details',
                        style: TextStyle(
                          color: ColorTheme.foodValue,
                          fontFamily: "Montserrat",
                        ),
                      ),
                    ),
                    body: Padding(
                      padding: EdgeInsets.all(
                          (Platform.isAndroid || Platform.isIOS) ? 5 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextformField(
                                  keyboardType: TextInputType.text,
                                  labelText: 'Owner First Name',
                                  controller: c.ownerFirstNameCtrl,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CustomTextformField(
                                  keyboardType: TextInputType.text,
                                  labelText: 'Owner Second Name',
                                  controller: c.ownerSecondtNameCtrl,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          CustomTextformField(
                            keyboardType: TextInputType.phone,
                            labelText: 'Owner Phone Number',
                            controller: c.ownerNumberCtrl,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                return c.validatePhone(value.trim());
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Delivery Contact Person Name and Number in Row
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextformField(
                                  keyboardType: TextInputType.text,
                                  labelText: 'Delivery Contact Person Name',
                                  controller: c.deliveryContactPersonNameCtrl,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CustomTextformField(
                                  keyboardType: TextInputType.phone,
                                  labelText: 'Delivery Contact Person Number',
                                  controller: c.deliveryContactCtrl,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      return c.validatePhone(value.trim());
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Inventory Manager Name and Number in Row
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextformField(
                                  keyboardType: TextInputType.text,
                                  labelText: 'Inventory Manager Name',
                                  controller: c.inventoryManagerNameCtrl,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CustomTextformField(
                                  keyboardType: TextInputType.number,
                                  labelText: 'Inventory Manager Number',
                                  controller: c.inventoryAlertNumber,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      return c.validatePhone(value.trim());
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar:
          GetBuilder<RestaurantSettingsController>(builder: (controller) {
        return Padding(
          padding: const EdgeInsets.all(0.0),
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18),
            decoration: BoxDecoration(color: ColorTheme.white),
            child: Row(
              children: [
                Expanded(
                    child: InkWell(
                  onTap: controller.resetSettings,
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                          color: Color(0xFFEFEFEF),
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: controller.isResetting
                          ? SpinKitFadingCircle(
                              color: ColorTheme.borderGrey,
                              size: 25.0,
                            )
                          : Center(
                              child: Text(
                              'Reset',
                              style: montserratSemiBold.copyWith(
                                  color: ColorTheme.borderGrey, fontSize: 15),
                            ))),
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: InkWell(
                  onTap: controller.updateResturantSetting,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: ColorTheme.green,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30))),
                    child: !controller.isSubmitting
                        ? Center(
                            child: Text(
                            "Update ",
                            style: montserratSemiBold.copyWith(
                                color: ColorTheme.white, fontSize: 15),
                          ))
                        : const SpinKitFadingCircle(
                            color: Colors.white,
                            size: 20.0,
                          ),
                  ),
                )),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Multi-select dropdown for Payment Method - Shows selected items
  Widget _buildMultiSelectPaymentDropdown(RestaurantSettingsController c) {
    List<String> paymentOptions = [
      'Cash',
      'Card',
      'UPI',
      'Tab',
      'Room',
      // 'Partial'
    ];

    String displayText = c.selectedPayments.isEmpty
        ? 'Select Payment Methods'
        : c.selectedPayments.join(' , ');

    return DropdownButtonFormField2<String>(
      value: null,
      items: paymentOptions.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          enabled: false,
          child: StatefulBuilder(
            builder: (context, menuSetState) {
              final isSelected = c.selectedPayments.contains(option);
              return InkWell(
                onTap: () {
                  if (isSelected) {
                    c.selectedPayments.remove(option);
                  } else {
                    c.selectedPayments.add(option);
                  }
                  c.update();
                  menuSetState(() {});
                },
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          if (value!) {
                            c.selectedPayments.add(option);
                          } else {
                            c.selectedPayments.remove(option);
                          }
                          c.update();
                          menuSetState(() {});
                        },
                      ),
                      Text(
                        option,
                        style: montserratMedium.copyWith(
                          color: Color(0xFF828282),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
      onChanged: (val) {},
      selectedItemBuilder: (context) {
        return paymentOptions.map((option) {
          return Container();
        }).toList();
      },
      buttonStyleData: ButtonStyleData(
        padding: EdgeInsets.only(left: 0, right: 8, top: 0),
        height: 40,
        width: double.infinity,
      ),
      dropdownStyleData: DropdownStyleData(
        useSafeArea: true,
        // padding: EdgeInsets.only(top: 50),
        maxHeight: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Color(0xFFDCDCDC),
          ),
        ),
      ),
      menuItemStyleData: MenuItemStyleData(
        height: 45,
        padding: EdgeInsets.symmetric(horizontal: 8),
      ),
      decoration: InputDecoration(
        labelText: 'Payment Method',
        labelStyle:
            montserratMedium.copyWith(color: ColorTheme.black, fontSize: 17),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Color(0xFFDCDCDC))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Color(0xFFDCDCDC))),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Color(0xFFDCDCDC))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Color(0xFFDCDCDC))),
      ),
      isDense: true,
      // isExpanded: true,

      hint: Text(
        displayText,
        style: montserratMedium.copyWith(
          color: c.selectedPayments.isEmpty
              ? Color(0xFF828282)
              : ColorTheme.grey8C,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // Multi-select dropdown for Channels - Shows selected items
  Widget _buildMultiSelectChannelsDropdown(RestaurantSettingsController c) {
    List<String> channelOptions = ['Delivery', 'Takeaway', 'Dinein'];

    String displayText = c.selectedChannels.isEmpty
        ? 'Select Channels'
        : c.selectedChannels.join(' , ');

    return DropdownButtonFormField2<String>(
      isExpanded: true,
      value: null,
      style: montserratMedium.copyWith(
          color: ColorTheme.grey8C,
          fontSize: 12,
          overflow: TextOverflow.ellipsis),
      items: channelOptions.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          enabled: false,
          child: StatefulBuilder(
            builder: (context, menuSetState) {
              final isSelected = c.selectedChannels.contains(option);
              return InkWell(
                onTap: () {
                  if (isSelected) {
                    c.selectedChannels.remove(option);
                  } else {
                    c.selectedChannels.add(option);
                  }
                  c.update();
                  menuSetState(() {});
                },
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          if (value!) {
                            c.selectedChannels.add(option);
                          } else {
                            c.selectedChannels.remove(option);
                          }
                          c.update();
                          menuSetState(() {});
                        },
                      ),
                      Text(
                        option,
                        overflow: TextOverflow.ellipsis,
                        style: montserratMedium.copyWith(
                          color: Color(0xFF828282),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
      onChanged: (val) {},
      selectedItemBuilder: (context) {
        return channelOptions.map((option) {
          return Container();
        }).toList();
      },
      buttonStyleData: ButtonStyleData(
        padding: EdgeInsets.only(left: 0, right: 8),
        // height: 60,
        // width: double.infinity,
      ),
      dropdownStyleData: DropdownStyleData(
        useSafeArea: true,
        maxHeight: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Color(0xFFDCDCDC),
          ),
        ),
      ),
      menuItemStyleData: MenuItemStyleData(
        height: 45,
        padding: EdgeInsets.symmetric(horizontal: 8),
      ),
      decoration: InputDecoration(
        labelText: 'Channels',
        labelStyle: montserratMedium.copyWith(
            color: ColorTheme.black,
            fontSize: 17,
            overflow: TextOverflow.ellipsis),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Color(0xFFDCDCDC))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Color(0xFFDCDCDC))),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Color(0xFFDCDCDC))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Color(0xFFDCDCDC))),
      ),

      // isDense: true,
      hint: Text(
        displayText,
        //  overflow: TextOverflow.ellipsis,
        // maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: montserratMedium.copyWith(
          color: c.selectedChannels.isEmpty
              ? Color(0xFF828282)
              : ColorTheme.grey8C,
          fontSize: 12,
        ),
      ),
    );
  }
}
