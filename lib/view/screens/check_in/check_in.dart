import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/check_in_controller.dart';
import 'package:mygenie_restaurant/data/model/response/crm_customer_documents_response.dart';
import 'package:mygenie_restaurant/data/model/response/crm_customer_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/data/model/response/table_response_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_button.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/check_in/photo_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class CheckIn extends StatefulWidget {
  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  DateTime? checkInDateTime;
  DateTime? checkOutDateTime;
  int _radioSelected = 1;
  int _bookingRadioSelected = 1;
  double gstAmount = 0;
  double gstPercent = 0;
  String? _selectedPaymentMethod;
  double roomTotalAmount = 0;
  bool isTapButton = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController gstnameController = TextEditingController();
  TextEditingController gstNoController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController advancePayController = TextEditingController(text: '0');
  TextEditingController balanceDueController = TextEditingController(text: '0');
  TextEditingController commentController = TextEditingController();
  TextEditingController nameOneController = TextEditingController();
  TextEditingController nameTwoController = TextEditingController();
  TextEditingController nameThirdController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  List<CrmCustomerDocument> _crmDocumentsOnFile = [];
  String? _crmDocsCustomerId;
  bool _isApplyingCrmSuggestion = false;
  bool get _hasCrmDocsOnFile => _crmDocumentsOnFile.isNotEmpty;
  TextEditingController childNameOneController = TextEditingController();
  TextEditingController childNameTwoController = TextEditingController();
  TextEditingController childNameThreeController = TextEditingController();
  TextEditingController childNameFourthController = TextEditingController();
  TextEditingController childNameFiveController = TextEditingController();
  TextEditingController childNameSixController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  List<String> childrenName = [];
  bool isValidRoomPrice = true;
  @override
  void initState() {
    super.initState();
    initData();
  }

  List<String> documentList = [
    'Select document type',
    'License',
    'Passport',
    'Aadhar card',
    'PAN card',
    'Other'
  ];

  initData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Get.find<CartController>().clearTableList();
      Get.find<CartController>().setTableIndex(null);
      await Get.find<CartController>().getRoomList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: Get.height / 10.72,
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.chevron_left, color: ColorTheme.green, size: 36),
            color: ColorTheme.appColor,
            onPressed: () {
              Get.back();
              Get.find<CheckInController>().clearData();
            }),
        titleSpacing: 0,
        elevation: 0,
        centerTitle: false,
        title: MediaQuery.of(context).size.shortestSide > 570
            ? Image.asset(
                logoHelper.appLogo!,
                height: Get.height / 10.72,
              )
            : Image.asset(
                logoHelper.appLogo!,
                width: Get.width * 0.3,
              ),
      ),
      body: SafeArea(
        child: GetBuilder<CheckInController>(
          builder: (checkInController) {
            return checkInController.isLoading
                ? Center(child: CircularProgressIndicator())
                : GetBuilder<CartController>(builder: (cartController) {
                    return cartController.isLoading
                        ? Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  // padding: EdgeInsets.symmetric(
                                  //     horizontal: 14, vertical: 14),
                                  margin: EdgeInsets.only(
                                      left: 15, right: 15, bottom: 10, top: 0),
                                  decoration: BoxDecoration(
                                      color: ColorTheme.bgSettleCardGreyColor,
                                      borderRadius: BorderRadius.circular(13)),
                                  child: Center(
                                    child: SizedBox(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 14, right: 14, top: 14),
                                            child: Text(
                                              'Check In',
                                              style: poppinsSemiBold.copyWith(
                                                  fontSize: 15),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 15),
                                            child: DottedLine(
                                              direction: Axis.horizontal,
                                              alignment: WrapAlignment.center,
                                              lineThickness: 1.0,
                                              dashLength: 2.5,
                                              dashColor: ColorTheme.hintText,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 14,
                                                right: 14,
                                                bottom: 14),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  primaryGuestNameTextField(),
                                                  if (isTapButton &&
                                                      nameController
                                                          .text.isEmpty)
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5),
                                                        child: Text(
                                                          'Please enter primary guest name'
                                                              .tr,
                                                          style: poppinsRegular
                                                              .copyWith(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: 10),
                                                        ),
                                                      ),
                                                    ),

                                                  SizedBox(
                                                      height: Dimensions
                                                          .PADDING_SIZE_DEFAULT),
                                                  phoneTextField(),
                                                  if (isTapButton &&
                                                      phoneController
                                                          .text.isEmpty)
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5),
                                                        child: Text(
                                                          'enter_phone_number'
                                                              .tr,
                                                          style: poppinsRegular
                                                              .copyWith(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: 10),
                                                        ),
                                                      ),
                                                    ),
                                                  if (isTapButton &&
                                                      phoneController
                                                          .text.isNotEmpty &&
                                                      phoneController
                                                              .text.length <
                                                          10)
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5),
                                                        child: Text(
                                                          'enter_a_valid_phone_number'
                                                              .tr,
                                                          style: poppinsRegular
                                                              .copyWith(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: 10),
                                                        ),
                                                      ),
                                                    ),
                                                  if (_hasCrmDocsOnFile)
                                                    crmDocumentsOnFileSection(),
                                                  SizedBox(
                                                      height: Dimensions
                                                          .PADDING_SIZE_DEFAULT),
                                                  // room selection
                                                  cartController
                                                          .roomList.isEmpty
                                                      ? SizedBox.shrink()
                                                      : roomSelect(
                                                          cartController),
                                                  emailTextField(),
                                                  if (isTapButton &&
                                                      emailController
                                                          .text.isNotEmpty &&
                                                      !GetUtils.isEmail(
                                                          emailController.text
                                                              .trim()))
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5),
                                                        child: Text(
                                                          'Please enter valid email address'
                                                              .tr,
                                                          style: poppinsRegular
                                                              .copyWith(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: 10),
                                                        ),
                                                      ),
                                                    ),

                                                  if (Get.find<AuthController>()
                                                          .profileModel!
                                                          .restaurants!
                                                          .first
                                                          .bookingDetail ==
                                                      'Yes')
                                                    selectBookingType(),
                                                  if (Get.find<AuthController>()
                                                          .profileModel!
                                                          .restaurants!
                                                          .first
                                                          .bookingDetail ==
                                                      'Yes')
                                                    checkInDateTimeRow(),
                                                  if (Get.find<AuthController>()
                                                          .profileModel!
                                                          .restaurants!
                                                          .first
                                                          .bookingDetail ==
                                                      'Yes')
                                                    gstBookingField(),
                                                  if (Get.find<AuthController>()
                                                          .profileModel!
                                                          .restaurants!
                                                          .first
                                                          .bookingDetail ==
                                                      'Yes')
                                                    nameTextField(
                                                        priceController,
                                                        'Enter price of room'),
                                                  if (Get.find<AuthController>()
                                                              .profileModel!
                                                              .restaurants!
                                                              .first
                                                              .bookingDetail ==
                                                          'Yes' &&
                                                      isTapButton &&
                                                      (priceController
                                                              .text.isEmpty ||
                                                          priceController
                                                                  .text ==
                                                              '0'))
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5),
                                                        child: Text(
                                                          'Please enter room price'
                                                              .tr,
                                                          style: poppinsRegular
                                                              .copyWith(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: 10),
                                                        ),
                                                      ),
                                                    ),
                                                  if (Get.find<AuthController>()
                                                          .profileModel!
                                                          .restaurants!
                                                          .first
                                                          .bookingDetail ==
                                                      'Yes')
                                                    balanceTextField(),
                                                  if (Get.find<AuthController>()
                                                          .profileModel!
                                                          .restaurants!
                                                          .first
                                                          .bookingDetail ==
                                                      'Yes')
                                                    _paymentMethodField(),
                                                  if (Get.find<AuthController>()
                                                          .profileModel!
                                                          .restaurants!
                                                          .first
                                                          .bookingDetail ==
                                                      'Yes')
                                                    _roomGstCard(),

                                                  if (Get.find<AuthController>()
                                                          .profileModel!
                                                          .restaurants!
                                                          .first
                                                          .guestDetail ==
                                                      'Yes')
                                                    SizedBox(
                                                        height: Dimensions
                                                            .PADDING_SIZE_DEFAULT),

                                                  if (Get.find<AuthController>()
                                                          .profileModel!
                                                          .restaurants!
                                                          .first
                                                          .guestDetail ==
                                                      'Yes')
                                                    selectNumberOfGuest(
                                                        checkInController),

                                                  if (Get.find<AuthController>()
                                                          .profileModel!
                                                          .restaurants!
                                                          .first
                                                          .guestDetail ==
                                                      'Yes')
                                                    SizedBox(
                                                        height: Dimensions
                                                            .PADDING_SIZE_DEFAULT),

                                                  if (Get.find<AuthController>()
                                                          .profileModel!
                                                          .restaurants!
                                                          .first
                                                          .guestDetail ==
                                                      'Yes')
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        selectDocumentType(
                                                            checkInController,
                                                            checkInController
                                                                .selectCategoryDocument,
                                                            1),
                                                      ],
                                                    ),

                                                  if (Get.find<AuthController>()
                                                          .profileModel!
                                                          .restaurants!
                                                          .first
                                                          .guestDetail ==
                                                      'Yes')
                                                    SizedBox(
                                                        height: Dimensions
                                                            .PADDING_SIZE_DEFAULT),

                                                  if (Get.find<AuthController>()
                                                          .profileModel!
                                                          .restaurants!
                                                          .first
                                                          .guestDetail ==
                                                      'Yes')
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        frontImg(
                                                            checkInController,
                                                            1,
                                                            checkInController
                                                                        .selectCategoryDocument ==
                                                                    'Select document type'
                                                                ? 'Front side +'
                                                                : 'Front side of ${checkInController.selectCategoryDocument} +',
                                                            checkInController
                                                                .frontImg),
                                                        SizedBox(width: 10),
                                                        backSide(
                                                            checkInController,
                                                            1,
                                                            checkInController
                                                                        .selectCategoryDocument ==
                                                                    'Select document type'
                                                                ? 'Back side +'
                                                                : 'Back side of ${checkInController.selectCategoryDocument} +',
                                                            checkInController
                                                                .backImg),
                                                      ],
                                                    ),
                                                  // SizedBox(
                                                  //     height:
                                                  //         Dimensions.PADDING_SIZE_SMALL),
                                                  if (checkInController.selectGuestCount == '2' ||
                                                      checkInController
                                                              .selectGuestCount ==
                                                          '3' ||
                                                      checkInController
                                                              .selectGuestCount ==
                                                          '4')
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 20),
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                              color: ColorTheme
                                                                  .appColor)),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Second guest detail',
                                                            style: poppinsMedium
                                                                .copyWith(
                                                              fontSize: 14,
                                                              color: ColorTheme
                                                                  .appColor,
                                                            ),
                                                          ),
                                                          nameTextField(
                                                              nameOneController,
                                                              'Second guest name'),
                                                          SizedBox(height: 10),
                                                          Row(
                                                            children: [
                                                              selectDocumentType(
                                                                  checkInController,
                                                                  checkInController
                                                                      .selectCategoryDocumentOne,
                                                                  2)
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              height: Dimensions
                                                                  .PADDING_SIZE_SMALL),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              frontImg(
                                                                  checkInController,
                                                                  2,
                                                                  checkInController
                                                                              .selectCategoryDocumentOne ==
                                                                          'Select document type'
                                                                      ? 'Front side +'
                                                                      : 'Front side of ${checkInController.selectCategoryDocumentOne}+',
                                                                  checkInController
                                                                      .frontImgOne ?? XFile('')),
                                                              SizedBox(
                                                                  width: Dimensions
                                                                      .PADDING_SIZE_SMALL),
                                                              backSide(
                                                                  checkInController,
                                                                  2,
                                                                  checkInController
                                                                              .selectCategoryDocumentOne ==
                                                                          'Select document type'
                                                                      ? 'Back side +'
                                                                      : 'Back side of ${checkInController.selectCategoryDocumentOne}+',
                                                                  checkInController
                                                                      .backImgOne ?? XFile('')),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  if (checkInController
                                                              .selectGuestCount ==
                                                          '3' ||
                                                      checkInController
                                                              .selectGuestCount ==
                                                          '4')
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 20),
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                              color: ColorTheme
                                                                  .appColor)),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Third guest detail',
                                                            style: poppinsMedium
                                                                .copyWith(
                                                              fontSize: 14,
                                                              color: ColorTheme
                                                                  .appColor,
                                                            ),
                                                          ),
                                                          nameTextField(
                                                              nameTwoController,
                                                              'Third guest name'),
                                                          SizedBox(height: 10),
                                                          Row(
                                                            children: [
                                                              selectDocumentType(
                                                                  checkInController,
                                                                  checkInController
                                                                      .selectCategoryDocumentTwo,
                                                                  3)
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              height: Dimensions
                                                                  .PADDING_SIZE_SMALL),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              frontImg(
                                                                  checkInController,
                                                                  3,
                                                                  checkInController
                                                                              .selectCategoryDocumentTwo ==
                                                                          'Select document type'
                                                                      ? 'Front side +'
                                                                      : 'Front side of ${checkInController.selectCategoryDocumentTwo}+',
                                                                  checkInController
                                                                      .frontImgTwo ?? XFile('')),
                                                              SizedBox(
                                                                  width: Dimensions
                                                                      .PADDING_SIZE_SMALL),
                                                              backSide(
                                                                  checkInController,
                                                                  3,
                                                                  checkInController
                                                                              .selectCategoryDocumentTwo ==
                                                                          'Select document type'
                                                                      ? 'Back side +'
                                                                      : 'Back side of ${checkInController.selectCategoryDocumentTwo}+',
                                                                  checkInController
                                                                      .backImgTwo ?? XFile(''))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  if (checkInController
                                                          .selectGuestCount ==
                                                      '4')
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 20),
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                              color: ColorTheme
                                                                  .appColor)),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Fourth guest detail',
                                                            style: poppinsMedium
                                                                .copyWith(
                                                              fontSize: 14,
                                                              color: ColorTheme
                                                                  .appColor,
                                                            ),
                                                          ),
                                                          nameTextField(
                                                              nameThirdController,
                                                              'Fourth guest name'),
                                                          SizedBox(height: 10),
                                                          Row(
                                                            children: [
                                                              selectDocumentType(
                                                                  checkInController,
                                                                  checkInController
                                                                      .selectCategoryDocumentThird,
                                                                  4)
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              height: Dimensions
                                                                  .PADDING_SIZE_SMALL),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              frontImg(
                                                                  checkInController,
                                                                  4,
                                                                  checkInController
                                                                              .selectCategoryDocumentThird ==
                                                                          'Select document type'
                                                                      ? 'Front side +'
                                                                      : 'Front side of ${checkInController.selectCategoryDocumentThird}+',
                                                                  checkInController
                                                                      .frontImgThird ?? XFile('')),
                                                              SizedBox(
                                                                  width: Dimensions
                                                                      .PADDING_SIZE_SMALL),
                                                              backSide(
                                                                  checkInController,
                                                                  4,
                                                                  checkInController
                                                                              .selectCategoryDocumentThird ==
                                                                          'Select document type'
                                                                      ? 'Back side +'
                                                                      : 'Back side of ${checkInController.selectCategoryDocumentThird}+',
                                                                  checkInController
                                                                      .backImgThird ?? XFile(''))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                  ///
                                                  if (checkInController
                                                              .selectChildCount !=
                                                          'Total children' &&
                                                      checkInController
                                                              .selectChildCount !=
                                                          '0')
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 20),
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                              color: ColorTheme
                                                                  .appColor)),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Children's  detail",
                                                            style: poppinsSemiBold.copyWith(
                                                                fontSize: 14,
                                                                color: ColorTheme
                                                                    .appColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                          nameTextField(
                                                              childNameOneController,
                                                              'First child name'),
                                                          if (int.parse(
                                                                  checkInController
                                                                      .selectChildCount) >
                                                              1)
                                                            nameTextField(
                                                                childNameTwoController,
                                                                'Second child name'),
                                                          if (int.parse(
                                                                  checkInController
                                                                      .selectChildCount) >
                                                              2)
                                                            nameTextField(
                                                                childNameThreeController,
                                                                'Third child name'),
                                                          if (int.parse(
                                                                  checkInController
                                                                      .selectChildCount) >
                                                              3)
                                                            nameTextField(
                                                                childNameFourthController,
                                                                'Fourth child name'),
                                                          if (int.parse(
                                                                  checkInController
                                                                      .selectChildCount) >
                                                              4)
                                                            nameTextField(
                                                                childNameFiveController,
                                                                'Fifth child name'),
                                                          if (int.parse(
                                                                  checkInController
                                                                      .selectChildCount) >
                                                              5)
                                                            nameTextField(
                                                                childNameSixController,
                                                                'Sixth child name'),
                                                        ],
                                                      ),
                                                    ),

                                                  commentTextField(
                                                      commentController,
                                                      'Comment'),
                                                  // checkInBtn(checkInController),
                                                ]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                //  if (roomTotalAmount != 0)
                                //   Padding(
                                //     padding: const EdgeInsets.only(
                                //         right: 15, top: 10),
                                //     child: Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.end,
                                //         children: [
                                //           Text('Room Price'.tr,
                                //               textAlign: TextAlign.right,
                                //               style: poppinsMedium.copyWith(
                                //                   fontSize: MediaQuery.of(
                                //                                   context)
                                //                               .size
                                //                               .shortestSide >
                                //                           570
                                //                       ? 15
                                //                       : 11)),
                                //           Text(
                                //               ' :   ' +
                                //                   PriceConverter.convertPrice(
                                //                       roomTotalAmount,
                                //                       isHideCurrency: true,
                                //                       asFixed: 2),
                                //               style: poppinsMedium.copyWith(
                                //                   fontSize: MediaQuery.of(
                                //                                   context)
                                //                               .size
                                //                               .shortestSide >
                                //                           570
                                //                       ? 15
                                //                       : 11)),
                                //         ]),
                                //   ),
                                // if (gstAmount != 0)
                                //   Padding(
                                //     padding: const EdgeInsets.only(
                                //         right: 15, top: 10),
                                //     child: Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.end,
                                //         children: [
                                //           Text('Room GST'.tr,
                                //               textAlign: TextAlign.right,
                                //               style: poppinsMedium.copyWith(
                                //                   fontSize: MediaQuery.of(
                                //                                   context)
                                //                               .size
                                //                               .shortestSide >
                                //                           570
                                //                       ? 15
                                //                       : 11)),
                                //           Text(
                                //               ' :   ' +
                                //                   PriceConverter.convertPrice(
                                //                       gstAmount,
                                //                       isHideCurrency: true,
                                //                       asFixed: 2),
                                //               style: poppinsMedium.copyWith(
                                //                   fontSize: MediaQuery.of(
                                //                                   context)
                                //                               .size
                                //                               .shortestSide >
                                //                           570
                                //                       ? 15
                                //                       : 11)),
                                //         ]),
                                //   ),

                                // if (roomTotalAmount != 0)
                                //   Padding(
                                //     padding: const EdgeInsets.only(
                                //         right: 15, top: 10),
                                //     child: Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.end,
                                //         children: [
                                //           Text('Room Total Amount'.tr,
                                //               textAlign: TextAlign.right,
                                //               style: poppinsMedium.copyWith(
                                //                   fontSize: MediaQuery.of(
                                //                                   context)
                                //                               .size
                                //                               .shortestSide >
                                //                           570
                                //                       ? 15
                                //                       : 11)),
                                //           Text(
                                //               ' :   ' +
                                //                   PriceConverter.convertPrice(
                                //                       roomTotalAmount +
                                //                           gstAmount,
                                //                       isHideCurrency: true,
                                //                       asFixed: 2),
                                //               style: poppinsMedium.copyWith(
                                //                   fontSize: MediaQuery.of(
                                //                                   context)
                                //                               .size
                                //                               .shortestSide >
                                //                           570
                                //                       ? 15
                                //                       : 11)),
                                //         ]),
                                //   ),
                                checkInBtn(Get.find<CheckInController>())
                              ],
                            ),
                          );
                  });
          },
        ),
      ),
      // bottomNavigationBar: checkInBtn(Get.find<CheckInController>()),
    );
  }

  Widget selectBookingType() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Booking Type:',
                  style: poppinsMedium.copyWith(
                      fontSize: 13, color: ColorTheme.hintText)),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 5,
                    child: Radio(
                      value: 1,
                      groupValue: _radioSelected,
                      activeColor: ColorTheme.appColor,
                      onChanged: (value) {
                        _radioSelected = value as int;
                        // _radioVal = 'Check In';
                        // print(_radioVal);
                        setState(() {});
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: InkWell(
                        onTap: () {
                          _radioSelected = 1;

                          setState(() {});
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Text("Walk In",
                            style: poppinsMedium.copyWith(
                                fontSize: 13, color: ColorTheme.hintText))),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 5,
                      child: Radio(
                        value: 2,
                        groupValue: _radioSelected,
                        activeColor: ColorTheme.appColor,
                        onChanged: (value) {
                          _radioSelected = value as int;
                          // _radioVal = 'Check Out';
                          // print(_radioVal);
                          setState(() {});
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: InkWell(
                          onTap: () {
                            _radioSelected = 2;
                            setState(() {});
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: Text("Online",
                              style: poppinsMedium.copyWith(
                                  fontSize: 13, color: ColorTheme.hintText))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _clearCrmDocuments() {
    if (_crmDocumentsOnFile.isEmpty && _crmDocsCustomerId == null) return;
    _crmDocumentsOnFile = [];
    _crmDocsCustomerId = null;
    if (mounted) setState(() {});
  }

  Future<void> _loadCrmDocuments(String? customerId) async {
    if (customerId == null || customerId.isEmpty) {
      _clearCrmDocuments();
      return;
    }
    _crmDocsCustomerId = customerId;
    _crmDocumentsOnFile = [];
    if (mounted) setState(() {});
    try {
      final docs =
          await Get.find<CartController>().getCrmCustomerDocuments(customerId);
      if (!mounted || _crmDocsCustomerId != customerId) return;
      setState(() {
        _crmDocumentsOnFile = docs;
      });
    } catch (_) {
      if (!mounted || _crmDocsCustomerId != customerId) return;
      setState(() {
        _crmDocumentsOnFile = [];
      });
    }
  }

  void _showCrmDocumentPreview(String url) {
    Get.dialog(
      barrierDismissible: true,
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Icon(Icons.broken_image_outlined,
                  color: ColorTheme.hintText, size: 48),
            ),
          ),
        ),
      ),
    );
  }

  Widget crmDocumentsOnFileSection() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorTheme.green.withOpacity(0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user, color: ColorTheme.green, size: 18),
              const SizedBox(width: 6),
              Text(
                'Documents on File',
                style: poppinsMedium.copyWith(
                  color: ColorTheme.green,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: ColorTheme.green,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${_crmDocumentsOnFile.length}',
                  style: poppinsMedium.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _crmDocumentsOnFile.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final doc = _crmDocumentsOnFile[index];
                return InkWell(
                  onTap: () {
                    if (doc.url != null && doc.url!.isNotEmpty) {
                      _showCrmDocumentPreview(doc.url!);
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 140,
                      height: 110,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            doc.url ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: Icon(Icons.image_outlined,
                                  color: ColorTheme.hintText),
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black54,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            right: 8,
                            bottom: 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.displayType,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: poppinsMedium.copyWith(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: ColorTheme.green,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check,
                                          color: Colors.white, size: 8),
                                      const SizedBox(width: 3),
                                      Text(
                                        'Verified',
                                        style: poppinsMedium.copyWith(
                                          color: Colors.white,
                                          fontSize: 7,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Docs on file — no need to re-upload unless expired',
            style: poppinsRegular.copyWith(
              color: ColorTheme.green,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget primaryGuestNameTextField() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        height: 40,
        child: TypeAheadField<CrmCustomerItem>(
          getImmediateSuggestions: true,
          textFieldConfiguration: TextFieldConfiguration(
            controller: nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.search,
            textCapitalization: TextCapitalization.words,
            autofocus: false,
            onChanged: (_) {
              if (_isApplyingCrmSuggestion) return;
              _clearCrmDocuments();
            },
            decoration: InputDecoration(
              hintText: 'Primary guest name',
              contentPadding: EdgeInsets.symmetric(
                  horizontal: Dimensions.PADDING_SIZE_SMALL,
                  vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: ColorTheme.borderGrey),
                borderRadius: BorderRadius.circular(7),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorTheme.borderGrey),
                borderRadius: BorderRadius.circular(7),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorTheme.borderGrey),
                borderRadius: BorderRadius.circular(7),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorTheme.borderGrey),
                borderRadius: BorderRadius.circular(7),
              ),
              hintStyle: poppinsMedium.copyWith(
                fontSize:
                    MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
                color: ColorTheme.hintText,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: poppinsMedium.copyWith(
              fontSize:
                  MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
            ),
          ),
          loadingBuilder: (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ColorTheme.appColor,
                  ),
                ),
                SizedBox(width: 8),
                Text('Searching...',
                    style: poppinsRegular.copyWith(
                        fontSize: 12, color: ColorTheme.hintText)),
              ],
            ),
          ),
          noItemsFoundBuilder: (context) => SizedBox.shrink(),
          suggestionsCallback: (pattern) async {
            final trimmed = pattern.trim();
            if (trimmed.length < 2) return <CrmCustomerItem>[];
            await Get.find<CartController>()
                .getCustomerFromApiCrm(search: trimmed, limit: 10);
            return Get.find<CartController>().crmCustomerList?.customerList ??
                [];
          },
          itemBuilder: (context, CrmCustomerItem suggestion) {
            return Padding(
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.name?.trim().isNotEmpty == true
                        ? suggestion.name!.trim()
                        : 'No Name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: poppinsRegular.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      fontSize: Dimensions.FONT_SIZE_SMALL,
                    ),
                  ),
                  Text(
                    suggestion.phone ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: poppinsRegular.copyWith(
                      color: ColorTheme.hintText,
                      fontSize: Dimensions.FONT_SIZE_SMALL,
                    ),
                  ),
                ],
              ),
            );
          },
          onSuggestionSelected: (CrmCustomerItem suggestion) {
            _isApplyingCrmSuggestion = true;
            nameController.text = suggestion.name?.trim() ?? '';
            phoneController.text = suggestion.phone ?? '';
            _isApplyingCrmSuggestion = false;
            _loadCrmDocuments(suggestion.id);
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  Widget nameTextField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        height: 40,
        child: TextField(
          controller: controller,
          keyboardType: hint == 'Enter price of room'
              ? TextInputType.numberWithOptions(signed: true)
              : TextInputType.name,
          autofocus: false,
          // maxLines: 4,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_SMALL,
                vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: ColorTheme.borderGrey),
              borderRadius: BorderRadius.circular(7),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorTheme.borderGrey),
              borderRadius: BorderRadius.circular(7),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorTheme.borderGrey),
              borderRadius: BorderRadius.circular(7),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorTheme.borderGrey),
              borderRadius: BorderRadius.circular(7),
            ),
            hintStyle: poppinsMedium.copyWith(
              fontSize:
                  MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
              color: ColorTheme.hintText,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: poppinsMedium.copyWith(
            fontSize: MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
          ),
          onChanged: (value) async {
            if (hint == 'Enter price of room') {
              changePaymentValue();
            }
          },
        ),
      ),
    );
  }

  Widget gstBookingField() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Booking For:',
                  style: poppinsMedium.copyWith(
                      fontSize: 13, color: ColorTheme.hintText)),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 5,
                    child: Radio(
                      value: 1,
                      groupValue: _bookingRadioSelected,
                      activeColor: ColorTheme.appColor,
                      onChanged: (value) {
                        _bookingRadioSelected = value as int;
                        // _radioVal = 'Check In';
                        // print(_radioVal);
                        setState(() {});
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: InkWell(
                        onTap: () {
                          _bookingRadioSelected = 1;

                          setState(() {});
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Text("Individual",
                            style: poppinsMedium.copyWith(
                                fontSize: 13, color: ColorTheme.hintText))),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 5,
                      child: Radio(
                        value: 2,
                        groupValue: _bookingRadioSelected,
                        activeColor: ColorTheme.appColor,
                        onChanged: (value) {
                          _bookingRadioSelected = value as int;
                          // _radioVal = 'Check Out';
                          // print(_radioVal);
                          setState(() {});
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: InkWell(
                          onTap: () {
                            _bookingRadioSelected = 2;
                            setState(() {});
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: Text("Corporate",
                              style: poppinsMedium.copyWith(
                                  fontSize: 13, color: ColorTheme.hintText))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_bookingRadioSelected != 1)
          nameTextField(gstnameController, 'GST Company name'),
        if (_bookingRadioSelected == 2 &&
            isTapButton &&
            gstnameController.text.isEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'Please enter Corporate GST Name'.tr,
                style: poppinsRegular.copyWith(color: Colors.red, fontSize: 10),
              ),
            ),
          ),
        if (_bookingRadioSelected != 1)
          nameTextField(gstNoController, 'GST No.'),
        if (_bookingRadioSelected == 2 &&
            isTapButton &&
            gstNoController.text.isEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'Please Enter Corporate GST No.'.tr,
                style: poppinsRegular.copyWith(color: Colors.red, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  Widget balanceTextField() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Advance Pay:',
                  style: poppinsMedium.copyWith(
                      fontSize: 13, color: ColorTheme.hintText),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 40,
                  child: TextField(
                    controller: advancePayController,
                    keyboardType:
                        TextInputType.numberWithOptions(signed: true),
                    autofocus: false,
                    // maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Advance Pay',
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: Dimensions.PADDING_SIZE_SMALL,
                          vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: ColorTheme.borderGrey),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ColorTheme.borderGrey),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ColorTheme.borderGrey),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ColorTheme.borderGrey),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      hintStyle: poppinsMedium.copyWith(
                        fontSize:
                            MediaQuery.of(context).size.shortestSide > 570
                                ? 15
                                : 13,
                        color: ColorTheme.hintText,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: poppinsMedium.copyWith(
                      fontSize: MediaQuery.of(context).size.shortestSide > 570
                          ? 15
                          : 13,
                    ),
                    onChanged: (value) async {
                      changePaymentValue();
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance Due:',
                  style: poppinsMedium.copyWith(
                      fontSize: 13, color: ColorTheme.hintText),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 40,
                  child: TextField(
                    readOnly: true,
                    controller: balanceDueController,
                    keyboardType:
                        TextInputType.numberWithOptions(signed: true),
                    autofocus: false,
                    // maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Balance Due',
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: Dimensions.PADDING_SIZE_SMALL,
                          vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: ColorTheme.borderGrey),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ColorTheme.borderGrey),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ColorTheme.borderGrey),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ColorTheme.borderGrey),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      hintStyle: poppinsMedium.copyWith(
                        fontSize:
                            MediaQuery.of(context).size.shortestSide > 570
                                ? 15
                                : 13,
                        color: ColorTheme.hintText,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: poppinsMedium.copyWith(
                      fontSize: MediaQuery.of(context).size.shortestSide > 570
                          ? 15
                          : 13,
                    ),
                    onChanged: (value) async {
                      changePaymentValue();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodField() {
    const options = [
      {'label': 'Cash', 'value': 'cash'},
      {'label': 'Card', 'value': 'card'},
      {'label': 'UPI', 'value': 'upi'},
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method:',
            style: poppinsMedium.copyWith(
                fontSize: 13, color: ColorTheme.hintText),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(options.length, (index) {
              final option = options[index];
              final selected = _selectedPaymentMethod == option['value'];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: index == options.length - 1 ? 0 : 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod =
                            selected ? null : option['value'];
                      });
                    },
                    child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? ColorTheme.appColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? ColorTheme.appColor
                              : ColorTheme.borderGrey,
                        ),
                      ),
                      child: Text(
                        option['label']!,
                        style: poppinsMedium.copyWith(
                          fontSize: 13,
                          color: selected
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (isTapButton &&
              (double.tryParse(advancePayController.text) ?? 0) > 0 &&
              (_selectedPaymentMethod == null ||
                  _selectedPaymentMethod!.isEmpty))
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  'Please select payment method'.tr,
                  style: poppinsRegular.copyWith(
                      color: Colors.red, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _roomGstCard() {
    if (gstAmount <= 0 || gstPercent <= 0) return const SizedBox.shrink();
    final halfRate = gstPercent / 2;
    final halfAmount = gstAmount / 2;
    final roomPrice = double.tryParse(priceController.text) ?? 0;
    final totalInclGst = roomPrice + gstAmount;
    final percentLabel = gstPercent % 1 == 0
        ? gstPercent.toStringAsFixed(0)
        : gstPercent.toStringAsFixed(2);
    final halfLabel = halfRate % 1 == 0
        ? halfRate.toStringAsFixed(0)
        : halfRate.toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F6EC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFB7E0C2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'GST (ACCOMMODATION)',
                  style: poppinsSemiBold.copyWith(
                      fontSize: 12, color: Colors.black),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ColorTheme.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$percentLabel% Slab',
                    style: poppinsMedium.copyWith(
                        fontSize: 10, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _gstRow('CGST ($halfLabel%)', halfAmount),
            _gstRow('SGST ($halfLabel%)', halfAmount),
            const SizedBox(height: 6),
            const Divider(height: 1, color: Color(0xFFB7E0C2)),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'Total incl. GST',
                  style: poppinsSemiBold.copyWith(
                      fontSize: 12, color: Colors.black),
                ),
                const Spacer(),
                Text(
                  _formatInr(totalInclGst),
                  style: poppinsSemiBold.copyWith(
                      fontSize: 13, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gstRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Text(
            label,
            style: poppinsRegular.copyWith(
                fontSize: 11, color: Colors.black87),
          ),
          const Spacer(),
          Text(
            _formatInr(amount),
            style: poppinsMedium.copyWith(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget checkInDateTimeRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();

                _selectDate(context, checkInDateTime ?? DateTime.now(), '0');
              },
              child: Container(
                height: 40,
                padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.PADDING_SIZE_SMALL),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.white,
                    border: Border.all(color: ColorTheme.borderGrey)),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    checkInDateTime == null
                        ? 'Check In Datetime'
                        : DateFormat('yyyy-MM-dd hh:mm a')
                            .format(checkInDateTime!),
                    style: poppinsMedium.copyWith(
                      color: ColorTheme.hintText,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: InkWell(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();

                _selectDate(context, checkOutDateTime ?? DateTime.now(), '1');
              },
              child: Container(
                height: 40,
                padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.PADDING_SIZE_SMALL),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.white,
                    border: Border.all(color: ColorTheme.borderGrey)),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    checkOutDateTime == null
                        ? 'Check Out Datetime'
                        : DateFormat('yyyy-MM-dd hh:mm a')
                            .format(checkOutDateTime!),
                    style: poppinsMedium.copyWith(
                      color: ColorTheme.hintText,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget commentTextField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 10),
      child: Container(
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.name,
          autofocus: false,
          // maxLines: 4,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: 7),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: ColorTheme.borderGrey),
              borderRadius: BorderRadius.circular(7),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorTheme.borderGrey),
              borderRadius: BorderRadius.circular(7),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorTheme.borderGrey),
              borderRadius: BorderRadius.circular(7),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorTheme.borderGrey),
              borderRadius: BorderRadius.circular(7),
            ),
            hintStyle: poppinsMedium.copyWith(
              fontSize:
                  MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
              color: ColorTheme.hintText,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 3,
          style: poppinsMedium.copyWith(
            fontSize: MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
          ),
          onChanged: (value) async {},
        ),
      ),
    );
  }

  Widget phoneTextField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: ColorTheme.borderGrey),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        CountryCodePicker(
          onChanged: (CountryCode _countryCode) {},
          initialSelection: 'IN',
          showDropDownButton: true,
          padding: EdgeInsets.zero,
          showFlagMain: false,
          flagWidth: 20,
          dialogBackgroundColor: Colors.white,
          backgroundColor: Colors.white,
          textStyle: poppinsMedium.copyWith(
            fontSize: 13,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(right: 5),
            alignment: Alignment.center,
            height: 40,
            child: TypeAheadField<CrmCustomerItem>(
              getImmediateSuggestions: true,
              textFieldConfiguration: TextFieldConfiguration(
                controller: phoneController,
                keyboardType: TextInputType.numberWithOptions(signed: true),
                textInputAction: TextInputAction.search,
                textAlignVertical: TextAlignVertical.center,
                onChanged: (_) {
                  if (_isApplyingCrmSuggestion) return;
                  _clearCrmDocuments();
                },
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp("[0-9,+]")),
                ],
                style: poppinsMedium.copyWith(
                    fontSize: MediaQuery.of(context).size.shortestSide > 570
                        ? 16
                        : 13),
                cursorColor: Theme.of(context).primaryColor,
                autofocus: false,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Mobile Number',
                  fillColor: Colors.white,
                  hintStyle: poppinsMedium.copyWith(
                      fontSize: MediaQuery.of(context).size.shortestSide > 570
                          ? 16
                          : 13,
                      color: ColorTheme.hintText),
                  filled: true,
                ),
              ),
              loadingBuilder: (context) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ColorTheme.appColor,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Searching...',
                        style: poppinsRegular.copyWith(
                            fontSize: 12, color: ColorTheme.hintText)),
                  ],
                ),
              ),
              noItemsFoundBuilder: (context) => SizedBox.shrink(),
              suggestionsCallback: (pattern) async {
                final trimmed = pattern.trim();
                if (trimmed.length < 3) return <CrmCustomerItem>[];
                await Get.find<CartController>()
                    .getCustomerFromApiCrm(search: trimmed, limit: 10);
                return Get.find<CartController>()
                        .crmCustomerList
                        ?.customerList ??
                    [];
              },
              itemBuilder: (context, CrmCustomerItem suggestion) {
                return Padding(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.phone ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: poppinsRegular.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          fontSize: Dimensions.FONT_SIZE_SMALL,
                        ),
                      ),
                      Text(
                        suggestion.name?.trim().isNotEmpty == true
                            ? suggestion.name!.trim()
                            : 'No Name',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: poppinsRegular.copyWith(
                          color: ColorTheme.hintText,
                          fontSize: Dimensions.FONT_SIZE_SMALL,
                        ),
                      ),
                    ],
                  ),
                );
              },
              onSuggestionSelected: (CrmCustomerItem suggestion) {
                _isApplyingCrmSuggestion = true;
                nameController.text = suggestion.name?.trim() ?? '';
                phoneController.text = suggestion.phone ?? '';
                _isApplyingCrmSuggestion = false;
                _loadCrmDocuments(suggestion.id);
                if (mounted) setState(() {});
              },
            ),
          ),
        )
      ]),
    );
  }

  Widget emailTextField() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        height: 40,
        child: TextField(
          controller: emailController,
          autofocus: false,
          // maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Email',
            contentPadding: EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_SMALL,
                vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: ColorTheme.borderGrey),
              borderRadius: BorderRadius.circular(7),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorTheme.borderGrey),
              borderRadius: BorderRadius.circular(7),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorTheme.borderGrey),
              borderRadius: BorderRadius.circular(7),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorTheme.borderGrey),
              borderRadius: BorderRadius.circular(7),
            ),
            hintStyle: poppinsSemiBold.copyWith(
              fontSize:
                  MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
              color: ColorTheme.hintText,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: poppinsMedium.copyWith(
            fontSize: MediaQuery.of(context).size.shortestSide > 570 ? 15 : 13,
          ),
          onChanged: (value) async {},
        ),
      ),
    );
  }

  Widget selectDocumentType(
      CheckInController checkInController, String selectedValue, int type) {
    return Expanded(
      child: Container(
        height: 40,
        // width: Get.width * 0.4,
        padding:
            EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
        decoration: BoxDecoration(
          border: Border.all(color: ColorTheme.borderGrey),
          color: Colors.white,
          borderRadius: BorderRadius.circular(7),
        ),
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue,
          icon: Icon(Icons.keyboard_arrow_down, color: ColorTheme.hintText),
          items: documentList.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                '$value',
                maxLines: 1,
                style: poppinsMedium.copyWith(
                  color: value == 'Select document type'
                      ? ColorTheme.hintText
                      : Colors.black,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? value) {
            if (type == 1) {
              checkInController.setDocumentType(value!, type);
            } else if (type == 2) {
              checkInController.setDocumentType(value!, type);
            } else if (type == 3) {
              checkInController.setDocumentType(value!, type);
            } else if (type == 4) {
              checkInController.setDocumentType(value!, type);
            }
          },
          underline: SizedBox(),
        ),
      ),
    );
  }

  Widget selectNumberOfGuest(CheckInController checkInController) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            // width: Get.width * 0.4,
            padding:
                EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
            decoration: BoxDecoration(
              border: Border.all(color: ColorTheme.borderGrey),
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
            child: DropdownButton<String>(
              icon: Icon(Icons.keyboard_arrow_down, color: ColorTheme.hintText),
              isExpanded: true,
              value: checkInController.selectGuestCount,
              items: <String>['Total adults', '1', '2', '3', '4']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    '$value',
                    maxLines: 1,
                    style: poppinsMedium.copyWith(
                      color: value == 'Total adults'
                          ? ColorTheme.hintText
                          : Colors.black,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                checkInController.setGuestCount(value!);
              },
              underline: SizedBox(),
            ),
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: Container(
            height: 40,
            // width: Get.width * 0.4,
            padding:
                EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
            decoration: BoxDecoration(
              border: Border.all(color: ColorTheme.borderGrey),
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
            child: DropdownButton<String>(
              icon: Icon(Icons.keyboard_arrow_down, color: ColorTheme.hintText),
              isExpanded: true,
              value: checkInController.selectChildCount,
              items: <String>[
                'Total children',
                '0',
                '1',
                '2',
                '3',
                '4',
                '5',
                '6'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    '$value',
                    maxLines: 1,
                    style: poppinsMedium.copyWith(
                      color: value == 'Total children'
                          ? ColorTheme.hintText
                          : Colors.black,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                checkInController.setChildCount(value!);
              },
              underline: SizedBox(),
            ),
          ),
        ),
      ],
    );
  }

  // Widget roomSelect(CartController cartController) {
  //   return Container(
  //     height: 40,
  //     // margin: EdgeInsets.only(top: 10),
  //     padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
  //     decoration: BoxDecoration(
  //       border: Border.all(color: ColorTheme.borderGrey),
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(7),
  //     ),
  //     child: DropdownButton<TableResponseModel>(
  //       isExpanded: true,
  //       value: cartController.selectedTable == null
  //           ? cartController.roomList.first
  //           : cartController.selectedTable,
  //       icon: Icon(Icons.keyboard_arrow_down, color: ColorTheme.hintText),
  //       items: cartController.roomList.map((TableResponseModel value) {
  //         return DropdownMenuItem<TableResponseModel>(
  //           value: value,
  //           child: Text(
  //             '${value.title} ${value.tableNo}',
  //             maxLines: 1,
  //             style: poppinsMedium.copyWith(
  //               color: value.id == 0 ? ColorTheme.hintText : Colors.black,
  //               fontSize: 13,
  //             ),
  //           ),
  //         );
  //       }).toList(),
  //       onChanged: (TableResponseModel? value) {
  //         cartController.setTableIndex(value);
  //       },
  //       underline: SizedBox(),
  //     ),
  //   );
  // }

    Widget roomSelect(CartController cartController) {
    return MultiSelectDialogField<TableResponseModel>(
      checkColor: ColorTheme.white,
      selectedColor: ColorTheme.appColor,
      searchHint: 'Search Rooms',
      searchHintStyle:
          poppinsMedium.copyWith(fontSize: 13, color: ColorTheme.hintText),
      searchTextStyle:
          poppinsMedium.copyWith(fontSize: 13, color: ColorTheme.hintText),
      searchIcon: Icon(Icons.search, color: ColorTheme.hintText),
      closeSearchIcon: Icon(Icons.close, color: ColorTheme.hintText),
      buttonIcon: Icon(Icons.keyboard_arrow_down, color: ColorTheme.hintText),
      decoration: BoxDecoration(
        border: Border.all(color: ColorTheme.borderGrey),
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),dialogHeight: 200,
      itemsTextStyle:
          poppinsMedium.copyWith(fontSize: 13, color: ColorTheme.hintText),
      items: cartController.roomList
          .map((e) =>
              MultiSelectItem<TableResponseModel>(e, '${e.title} ${e.tableNo}'))
          .toList(),
      title: Text('--Room Select--',
          style:
              poppinsMedium.copyWith(fontSize: 13, color: ColorTheme.hintText)),
      // buttonText: Text("Select Rooms"),
      searchable: true,
      buttonText: Text(
        cartController.selectedTables.isNotEmpty
            ? cartController.selectedTables
                .map((e) => '${e.title} ${e.tableNo}')
                .join(', ')
            : '--Room Select--',
        overflow: TextOverflow.ellipsis,
        style: poppinsMedium.copyWith(fontSize: 13, color:cartController.selectedTables.isEmpty  ? ColorTheme.hintText :  ColorTheme.black),
      ),
      initialValue: cartController.selectedTables,
      onConfirm: (List<TableResponseModel> values) {
        cartController.setSelectedRooms(values);
        print(
            'Selected Rooms: ${cartController.selectedTables.map((e) => e.tableNo).join(',')}');
      },
      selectedItemsTextStyle:
          poppinsMedium.copyWith(fontSize: 13, color: ColorTheme.hintText),
      chipDisplay: MultiSelectChipDisplay(
        chipColor: ColorTheme.white,
        textStyle:
            poppinsMedium.copyWith(fontSize: 13, color: ColorTheme.hintText),
        shape: RoundedRectangleBorder(
            side: BorderSide(color: ColorTheme.borderGrey),
            borderRadius: BorderRadius.circular(7)),
        icon: Icon(
          Icons.check,
          size: 0,
          color: Colors.transparent,
        ),
        // : Colors.transparent,
        onTap: (item) {
          cartController.selectedTables.remove(item);
          cartController.setSelectedRooms([...cartController.selectedTables]);
        },
      ),
      // chipDisplay: MultiSelectChipDisplay.none(),
    );
  }


  Widget frontImg(CheckInController checkInController, int count, String text,
      XFile? path) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();

              Get.dialog(selectOption(checkInController, count, isFront: true),
                  useSafeArea: false);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: ColorTheme.borderGrey)),
              child: Text(text,
                  style: poppinsMedium.copyWith(
                      fontSize: 13, color: ColorTheme.appColor)),
            ),
          ),
          path == null
              ? SizedBox.shrink()
              : InkWell(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) =>
                                DocumentView(File(path?.path ?? ''))));
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(File(path?.path ?? '')),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(10)),
                    height: Get.height * 0.15,
                    // child: Image.file(
                    //   File(path.path),
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget backSide(CheckInController checkInController, int count, String text,
      XFile? path) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();

              Get.dialog(selectOption(checkInController, count, isFront: false),
                  useSafeArea: false);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: ColorTheme.borderGrey)),
              child: Text(text,
                  style: poppinsMedium.copyWith(
                      fontSize: 13, color: ColorTheme.appColor)),
            ),
          ),
          path == null
              ? SizedBox.shrink()
              : InkWell(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) =>
                                DocumentView(File(path?.path ?? ''))));
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(File(path?.path ?? '')),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(10)),
                    height: Get.height * 0.15,
                    // child: Image.file(
                    //   File(path.path),
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget checkInBtn(CheckInController checkInController) {
    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.only(top: 20),
        height: 30,
        child: GetBuilder<CartController>(builder: (cartController) {
          return cartController.isLoading
              ? SizedBox()
              : InkWell(
                  onTap: () async {
                    isTapButton = true;
                    FocusManager.instance.primaryFocus?.unfocus();

                    checkInController.update();
                    childrenName = [];
                    if (childNameOneController.text.isNotEmpty)
                      childrenName.add(childNameOneController.text);
                    if (childNameTwoController.text.isNotEmpty)
                      childrenName.add(childNameTwoController.text);
                    if (childNameThreeController.text.isNotEmpty)
                      childrenName.add(childNameThreeController.text);
                    if (childNameFourthController.text.isNotEmpty)
                      childrenName.add(childNameFourthController.text);
                    if (childNameFiveController.text.isNotEmpty)
                      childrenName.add(childNameFiveController.text);
                    if (childNameSixController.text.isNotEmpty)
                      childrenName.add(childNameSixController.text);
                    if (Get.find<CartController>().selectedTable?.id == 0) {
                      showErrorToast('Please select room number');
                    }
                    //  else if (checkInController.selectGuestCount ==
                    //     'Total adults') {
                    //   showErrorToast('Please select total counts of adults',
                    //      );
                    // }
                    else if (nameController.text.isEmpty) {
                      // showErrorToast('Please enter primary guest name',
                      //    );
                    } else if (phoneController.text.isEmpty) {
                      // showErrorToast('Please enter phone number',
                      //    );
                    } else if (phoneController.text.length < 10) {
                      // showErrorToast('Please enter phone number',
                      //    );
                    } else if (Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .bookingDetail ==
                            'Yes' &&
                        (checkInDateTime == null || checkOutDateTime == null)) {
                      showErrorToast(
                        'Please enter check-in date and check-Out date',
                      );
                    } else if (Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .bookingDetail ==
                            'Yes' &&
                        (checkInDateTime != null &&
    checkOutDateTime != null && checkOutDateTime!.isBefore(checkInDateTime!))) {
                      showErrorToast(
                        'Please enter valid check-in date and check-Out date',
                      );
                    } else if (Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .bookingDetail ==
                            'Yes' &&
                        (priceController.text.isEmpty ||
                            priceController.text == '0')) {
                      // showErrorToast('Please enter room price',
                      //    );
                    } else if (Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .bookingDetail ==
                            'Yes' &&
                        _bookingRadioSelected == 2 &&
                        gstnameController.text.isEmpty) {
                    } else if (Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .bookingDetail ==
                            'Yes' &&
                        _bookingRadioSelected == 2 &&
                        gstNoController.text.isEmpty) {
                    } else if (Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .bookingDetail ==
                            'Yes' &&
                        !isValidRoomPrice) {
                      showErrorToast(
                        'Please enter valid price',
                      );
                    } else if (Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .guestDetail ==
                            'Yes' &&
                        checkInController.selectGuestCount == 'Total adults') {
                      showErrorToast(
                        'Please select counts of adults',
                      );
                    } else if (Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .guestDetail ==
                            'Yes' &&
                        !_hasCrmDocsOnFile &&
                        checkInController.selectCategoryDocument ==
                            'Select document type') {
                      showErrorToast(
                        "Please select document type",
                      );
                    } else if (Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .guestDetail ==
                            'Yes' &&
                        !_hasCrmDocsOnFile &&
                        (checkInController.frontImg == null &&
                            checkInController.backImg == null)) {
                      showErrorToast(
                        'Please upload image of your selected document',
                      );
                    }
                    // else if (checkInController.frontImg == null) {
                    //   showErrorToast(
                    //       'Please upload front image of your selected document',
                    //      );
                    // }
                    //else if (checkInController.backImg == null) {
                    //   showErrorToast(
                    //       'Please upload back image of your selected document',
                    //      );
                    // }
                    else if ((checkInController.selectGuestCount == '2' ||
                            checkInController.selectGuestCount == '3' ||
                            checkInController.selectGuestCount == '4') &&
                        nameOneController.text.isEmpty) {
                      showErrorToast(
                        'Please enter name of second guest',
                      );
                    } else if (((checkInController.selectGuestCount == '2' ||
                            checkInController.selectGuestCount == '3' ||
                            checkInController.selectGuestCount == '4') &&
                        checkInController.selectCategoryDocumentOne ==
                            'Select document type')) {
                      showErrorToast(
                        "Please select document type of second guest",
                      );
                    } else if ((checkInController.selectGuestCount == '2' ||
                            checkInController.selectGuestCount == '3' ||
                            checkInController.selectGuestCount == '4') &&
                        checkInController.frontImgOne == null &&
                        checkInController.backImgOne == null) {
                      showErrorToast(
                        "Please upload  image of second guest's selected document",
                      );
                    }
                    //else if ((checkInController.selectGuestCount == '2' ||
                    //         checkInController.selectGuestCount == '3' ||
                    //         checkInController.selectGuestCount == '4') &&
                    //     checkInController.backImgOne == null) {
                    //   showErrorToast(
                    //       "Please upload back image of second guest's selected document",
                    //      );
                    // }

                    ///
                    else if ((checkInController.selectGuestCount == '3' ||
                            checkInController.selectGuestCount == '4') &&
                        nameTwoController.text.isEmpty) {
                      showErrorToast(
                        'Please enter name of third guest',
                      );
                    } else if ((checkInController.selectGuestCount == '3' ||
                            checkInController.selectGuestCount == '4') &&
                        checkInController.selectCategoryDocumentTwo ==
                            'Select document type') {
                      showErrorToast(
                        "Please select document type of third guest",
                      );
                    } else if ((checkInController.selectGuestCount == '3' ||
                            checkInController.selectGuestCount == '4') &&
                        checkInController.frontImgTwo == null &&
                        checkInController.backImgTwo == null) {
                      showErrorToast(
                        "Please upload  image of third guest's selected document",
                      );
                    }
                    //  else if ((checkInController.selectGuestCount == '3' ||
                    //         checkInController.selectGuestCount == '4') &&
                    //     checkInController.backImgTwo == null) {
                    //   showErrorToast(
                    //       "Please upload back image of third guest's selected document",
                    //      );
                    // }

                    ///
                    else if (checkInController.selectGuestCount == '4' &&
                        nameThirdController.text.isEmpty) {
                      showErrorToast(
                        'Please enter name of fourth guest',
                      );
                    } else if (checkInController.selectGuestCount == '4' &&
                        checkInController.selectCategoryDocumentThird ==
                            'Select document type') {
                      showErrorToast(
                        "Please select document type of fourth guest",
                      );
                    }                     else if (checkInController.selectGuestCount == '4' &&
                        checkInController.frontImgThird == null &&
                        checkInController.backImgThird == null) {
                      showErrorToast(
                        "Please upload  image of fourth guest's selected document",
                      );
                    } else if ((double.tryParse(advancePayController.text) ??
                                0) >
                            0 &&
                        (_selectedPaymentMethod == null ||
                            _selectedPaymentMethod!.isEmpty)) {
                      showErrorToast(
                        'Please select payment method',
                      );
                    }
                    //  else if (checkInController.selectGuestCount == '4' &&
                    //     checkInController.backImgThird == null) {
                    //   showErrorToast(
                    //       "Please upload back image of fourth guest's selected document",
                    //      );
                    // }
                    else {
                      String? crmId;
                      try {
                        crmId = await Get.find<CartController>()
                            .lookupAndSyncCrmCustomer(
                          phone: phoneController.text,
                          name: nameController.text,
                          email: emailController.text,
                          backToPrevious: false,
                        );
                      } catch (_) {}
                      final guestDetailOn = Get.find<AuthController>()
                              .profileModel
                              ?.restaurants
                              ?.first
                              .guestDetail ==
                          'Yes';
                      checkInController.checkIn(
                          context,
                          emailController.text.isEmpty
                              ? ''
                              : emailController.text,
                          phoneController.text,
                          nameController.text,
                          gstName: gstnameController.text.isEmpty
                              ? ''
                              : gstnameController.text,
                          gstNo: gstNoController.text.isEmpty
                              ? ''
                              : gstNoController.text,
                          gstAmount: gstAmount,
                          paymentMethod: _selectedPaymentMethod ?? '',
                          checkInDateTime: checkInDateTime == null
                              ? ''
                              : DateFormat('yyyy-MM-dd hh:mm:ss')
                                  .format(checkInDateTime!),
                          checkOutDateTime: checkOutDateTime == null
                              ? ''
                              : DateFormat('yyyy-MM-dd hh:mm:ss')
                                  .format(checkOutDateTime!),
                          bookingType:
                              _radioSelected == 1 ? 'WalkIn' : 'Online',
                          bookingFor: _bookingRadioSelected == 1
                              ? 'Individual'
                              : 'Corporate',
                          balanceDue: _exclusiveBalanceDue(),
                          advancePay: advancePayController.text.isEmpty
                              ? '0'
                              : advancePayController.text,
                          childName: childrenName.isEmpty
                              ? ''
                              : childrenName.join(','),
                          comment: commentController.text.isEmpty
                              ? ''
                              : commentController.text,
                          orderAmount: priceController.text.isEmpty
                              ? ''
                              : priceController.text,
                          secondName: nameOneController.text.isEmpty ? '' : nameOneController.text,
                          thirdName: nameTwoController.text.isEmpty ? '' : nameTwoController.text,
                          fourthName: nameThirdController.text.isEmpty ? '' : nameThirdController.text,
                          crmCustomerId: crmId,
                          uploadCrmDocuments: guestDetailOn &&
                              (checkInController.frontImg != null ||
                                  checkInController.backImg != null));
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            height: 30,
                            padding: EdgeInsets.symmetric(horizontal: 20 ,),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: ColorTheme.appColor),
                            child: Center(
                              child: Text('Check In',
                                  style: poppinsMedium.copyWith(
                                      color: Colors.white, fontSize: 14)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
        }),
      ),
    );
  }

  pickImageFromCamera(CheckInController checkInController, int count,
      {bool isFront = true}) async {
    try {
      XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo == null) return;
      if (await photo.length() > 900000)
        photo = await testCompressAndGetFile(File(photo.path));

      if (isFront) {
        checkInController.setImage(count, isFront: true, file: photo);
      } else {
        checkInController.setImage(count, isFront: false, file: photo);
      }
    } catch (e) {}
  }

  pickImageFromGallary(CheckInController checkInController, int count,
      {bool isFront = true}) async {
    try {
      XFile? photo = await picker.pickImage(source: ImageSource.gallery);
      if (photo == null) return;
      if (await photo.length() > 900000)
        photo = await testCompressAndGetFile(File(photo.path));
      if (isFront) {
        checkInController.setImage(count, isFront: true, file: photo);
      } else {
        checkInController.setImage(count, isFront: false, file: photo);
      }
    } catch (e) {}
  }

  Future<XFile> testCompressAndGetFile(File file) async {
    final lastIndex = file.path.lastIndexOf(RegExp(r'.jp'));
    final splitted = file.path.substring(0, (lastIndex));
    final outPath = '${splitted}_out${file.path.substring(lastIndex)}';
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, outPath,
        minWidth: 700
        // quality: 70,
        );

    return result ?? XFile(file.path);
  }

  selectOption(CheckInController checkInController, int count,
      {bool isFront = true}) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
      insetPadding: EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
          width: 500,
          child: Padding(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.PADDING_SIZE_LARGE),
                child: Text(
                  'Select Option',
                  textAlign: TextAlign.center,
                  style: poppinsSemiBold.copyWith(
                      fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                      color: Colors.red),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                child: Text('Please select any one option',
                    style: poppinsSemiBold.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE),
                    textAlign: TextAlign.center),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
              Row(children: [
                Expanded(
                    child: TextButton(
                  onPressed: () async {
                    Get.back();
                    await pickImageFromCamera(checkInController, count,
                        isFront: isFront);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).disabledColor.withOpacity(0.3),
                    minimumSize: Size(1170, 40),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Dimensions.RADIUS_SMALL)),
                  ),
                  child: Text(
                    'Camera',
                    textAlign: TextAlign.center,
                    style: poppinsBold.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                )),
                SizedBox(width: Dimensions.PADDING_SIZE_LARGE),
                Expanded(
                    child: CustomButton(
                  buttonText: 'Gallary',
                  onPressed: () async {
                    Get.back();
                    await pickImageFromGallary(checkInController, count,
                        isFront: isFront);
                  },
                  height: 40,
                )),
              ]),
            ]),
          )),
    );
  }

  Future<void> _selectDate(
      BuildContext context, DateTime initialDate, String type) async {
    showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: initialDate ?? DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 90)),
    ).then((selectedDate) {
      // After selecting the date, display the time picker.
      if (selectedDate != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((selectedTime) {
          // Handle the selected date and time here.
          if (selectedTime != null) {
            DateTime selectedDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
            type == '0'
                ? checkInDateTime = selectedDateTime
                : checkOutDateTime = selectedDateTime;
            Get.find<CheckInController>().update();
            // You can use the selectedDateTime as needed.
          }
          roomDayCalculate();
        });
      }
    });
  }

  changePaymentValue() {
    if (priceController.text.isEmpty || priceController.text == '0') {
      advancePayController.text = '0';
      balanceDueController.text = '0';
      gstAmount = 0;
      gstPercent = 0;
      isValidRoomPrice = true;
    } else {
      _calculateRoomGst();
      final roomPrice = double.tryParse(priceController.text) ?? 0;
      if (advancePayController.text.isEmpty) {
        isValidRoomPrice = true;
        balanceDueController.text =
            (roomPrice + gstAmount).toStringAsFixed(2);
      } else {
        if (roomPrice < (double.tryParse(advancePayController.text) ?? 0)) {
          isValidRoomPrice = false;
          showErrorToast('Please enter valid advance payment amount');
        } else {
          isValidRoomPrice = true;
          final exclusive = roomPrice -
              (double.tryParse(advancePayController.text) ?? 0);
          balanceDueController.text =
              (exclusive + gstAmount).toStringAsFixed(2);
        }
      }
    }
    Get.find<CheckInController>().update();
  }

  int _stayNights() {
    if (checkInDateTime == null || checkOutDateTime == null) return 1;
    final inDate = DateTime(
        checkInDateTime!.year, checkInDateTime!.month, checkInDateTime!.day);
    final outDate = DateTime(checkOutDateTime!.year, checkOutDateTime!.month,
        checkOutDateTime!.day);
    final nights = outDate.difference(inDate).inDays;
    return nights < 1 ? 1 : nights;
  }

  void _calculateRoomGst() {
    gstAmount = 0;
    gstPercent = 0;
    final restaurant =
        Get.find<AuthController>().profileModel?.restaurants?.first;
    if (restaurant?.roomGstApply != 'Yes') return;
    final config = restaurant?.settings?.roomGst ?? restaurant?.roomGst;
    if (config == null || config.slabs.isEmpty) return;

    final roomPrice = double.tryParse(priceController.text) ?? 0;
    if (roomPrice <= 0) return;

    final perNight = roomPrice / _stayNights();
    RoomGstSlab? matched;
    for (final slab in config.slabs) {
      final inMin = perNight >= slab.min;
      final inMax = slab.max == null || perNight <= slab.max!;
      if (inMin && inMax) {
        matched = slab;
        break;
      }
    }
    if (matched == null) return;
    gstPercent = matched.gstPercent;
    gstAmount = roomPrice * gstPercent / 100;
  }

  String _exclusiveBalanceDue() {
    final roomPrice = double.tryParse(priceController.text) ?? 0;
    final advance = double.tryParse(advancePayController.text) ?? 0;
    final exclusive = roomPrice - advance;
    return (exclusive < 0 ? 0 : exclusive).toStringAsFixed(2);
  }

  String _formatInr(double value) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format(value);
  }

  roomDayCalculate() {
    changePaymentValue();
  }
}
