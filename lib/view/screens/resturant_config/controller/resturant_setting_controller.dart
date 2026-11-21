// ---------- resturant_setting_controller.dart ----------
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/repo/resturant_setting_repo.dart';

class RestaurantSettingsController extends GetxController
    implements GetxService {
  final RestaurantSettingsRepo restaurantSettingsRepo;
  RestaurantSettingsController({required this.restaurantSettingsRepo});

  final formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneBillCtrl = TextEditingController();
  final TextEditingController gstNumCtrl = TextEditingController();
  final TextEditingController vatNumCtrl = TextEditingController();
  final TextEditingController fssaiCtrl = TextEditingController();
  final TextEditingController reportContactCtrl = TextEditingController();
  final TextEditingController deliveryContactCtrl = TextEditingController();
  final TextEditingController upiIdCtrl = TextEditingController();
  final TextEditingController ownerFirstNameCtrl = TextEditingController();
  final TextEditingController ownerSecondtNameCtrl = TextEditingController();
  final TextEditingController ownerNumberCtrl = TextEditingController();
  final TextEditingController uploadMenuCtrl = TextEditingController();
  final TextEditingController inventoryAlertNumber = TextEditingController();
  final TextEditingController serviceChargeTax = TextEditingController();
  final TextEditingController serviceChargeText = TextEditingController();
  final TextEditingController resturantAddress = TextEditingController();
  final TextEditingController feedbackUrlCtrl = TextEditingController();
  final TextEditingController gstTaxCtrl = TextEditingController();
  final TextEditingController taxCtrl = TextEditingController();
  final TextEditingController phoneNumberOnBillCtrl = TextEditingController();
  final TextEditingController emailIdOnBillCtrl = TextEditingController();
  final TextEditingController inventoryManagerNameCtrl =
      TextEditingController();
  final TextEditingController deliveryContactPersonNameCtrl =
      TextEditingController();
  final TextEditingController onlineOrderingLinkCtrl = TextEditingController();

  XFile? logoFile;
  String? logoUrl;

  String? pdfMenuUrl;

  PlatformFile? pickedFile;
  XFile? pdfXFile;

  bool gstCheck = false;
  bool vatCheck = false;

  final Set<String> selectedPayments = <String>{};
  final Set<String> selectedChannels = <String>{};

  TimeOfDay openingTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay closingTime = const TimeOfDay(hour: 22, minute: 0);

  bool isResetting = false;
  bool isSubmitting = false;

  final textStyle = TextStyle(
      color: ColorTheme.foodValue,
      fontFamily: "Montserrat",
      fontSize: 13,
      fontWeight: FontWeight.w500);
  final textStyle1 = TextStyle(
      color: ColorTheme.foodValue,
      fontFamily: "Montserrat",
      fontSize: 15,
      fontWeight: FontWeight.w600);

  List<String> defFoodStatus = ['Accept', 'Ready', 'Serve', 'Delivered'];
  List<String> orderPaymentTypes = ['prepaid', 'postpaid', 'both'];
  List<String> restaurantForTypes = ['Normal', 'Hotel', 'food_court'];
  List<String> restaurentGstOptions = ['restaurant', 'category'];
  List<String> listServeItemOptions = ['Dynamic', 'Fixed'];
  List<String> sendFeedbackLinkOptions = ['external', 'internal', 'no'];
  List<String> shortCodeOptions = ['Yes', 'No', 'Both'];

  // New advanced fields
  bool roomEnabled = false;
  bool tipEnabled = false;
  bool availableDiscount = false;
  bool inventoryEnabled = false;
  bool inventoryNegative = false;
  bool dynamicUpiValue = false;
  bool totalRound = false;
  bool autoServiceCharge = false;
  bool serviceCharge = false;
  bool settlementReport = false;
  bool realTimeOrderStatus = false;
  bool showPopularCategory = false;
  bool foodLevelNotes = false;
  bool orderConfirmForWeb = false;
  bool showFoodVariance = false;
  bool billingAutoBillPrint = false;
  bool PrintKot = false;
  bool showAcNonMenu = false;
  bool foodDate = false;
  bool feedBack = false;
  bool deliveryOnlinePayment = false;
  bool takeawayOnlinePayment = false;
  bool dineinOnlinePayment = false;
  bool walkinOnlinePayment = false;
  bool canclePostServe = false;
  bool voiceInKds = false;
  String shortCode = 'No';

  List<String> searchBy = [];
  String orderPaymentType = 'both';
  String restaurantFor = 'Normal';
  String restaurentGst = 'restaurant'; // options: 'restaurant', 'category'
  String listServeItem = 'Dynamic'; // options: 'Dynamic', 'Fixed'
  String sendFeedbackLink =
      'external'; // options: 'external', 'internal', 'both'

  int defOrdStatus = 0;

  Future<void> getResturantSettings() async {
    try {
      final response = await restaurantSettingsRepo.getResturantSetting();
      if (response.statusCode == 200) {
        final data = response.body['data'];
        final basic = data['basic'];
        nameCtrl.text = basic['name'] ?? '';
        logoUrl = basic['logo'] ?? '';
        phoneBillCtrl.text = basic['phone'] ?? '';
        gstNumCtrl.text = basic['gst']['code'] ?? '';
        gstCheck = basic['gst']['status'] == 1;
        vatNumCtrl.text = basic['vat']['code'] ?? '';
        vatCheck = basic['vat']['status'] == 1;
        fssaiCtrl.text = basic['fssai'] ?? '';
        reportContactCtrl.text = basic['report_number'] ?? '';
        deliveryContactCtrl.text = basic['delivery_contact_no'] ?? '';
        pdfMenuUrl = basic['pdf_menu'] ?? '';
        resturantAddress.text = basic['address'] ?? '';
        onlineOrderingLinkCtrl.text = basic['online_ordering_link'] ?? '';
        inventoryManagerNameCtrl.text = basic['inventory_manager_name'] ?? '';
        phoneNumberOnBillCtrl.text = basic['phone_number_on_bill'] ?? '';
        shortCode = basic['short_code']?.toString() ?? 'No';
        restaurantFor = basic['restaurant_for']?.toString() ?? 'Normal';
        if (!restaurantForTypes.contains(restaurantFor)) {
          restaurantFor = 'Normal';
        }

        final advanced = data['advanced'];
        upiIdCtrl.text = advanced['upi_id'] ?? '';
        deliveryContactPersonNameCtrl.text =
            advanced['delivery_person_name'] ?? '';

        // clear previous selections
        selectedPayments.clear();
        selectedChannels.clear();

        // payments
        if (advanced['pay_cash'] == 'Yes') selectedPayments.add('Cash');
        if (advanced['pay_cc'] == 'Yes') selectedPayments.add('Card');
        if (advanced['pay_tab'] == 'Yes') selectedPayments.add('Tab');
        if (advanced['pay_upi'] == 'Yes') selectedPayments.add('UPI');
        // if (advanced['online_payment'] == 'Yes') selectedPayments.add('Online');
        // if (advanced['show_cash_on_delivery'] == 'Yes')
        //   selectedPayments.add('Cash on Delivery');
        if (advanced['room'] == 'Yes') selectedPayments.add('Room');

        // channels
        if (advanced['dine_in'] == 'Yes') selectedChannels.add('Dinein');
        if (advanced['take_away'] == true) selectedChannels.add('Takeaway');
        if (advanced['delivery'] == true) selectedChannels.add('Delivery');

        tipEnabled = advanced['tip'] == 'Yes';
        availableDiscount = advanced['available_discount'] == 'Yes';
        inventoryEnabled = advanced['inventory'] == 'Yes';
        inventoryNegative = advanced['inventory_negative'] == 'Yes';
        dynamicUpiValue = advanced['dynamic_upi_value'] == 'Yes';
        totalRound = advanced['total_round'] == 'Yes';
        inventoryAlertNumber.text = advanced['inventory_alert_number'] ?? '';
        autoServiceCharge = advanced['auto_service_charge'] == 'Yes';
        serviceChargeText.text =
            advanced['service_charge_percentage'] ?? '0.00';
        serviceChargeTax.text = advanced['service_charge_tax'] ?? '0.00';
        serviceCharge = advanced['service_charge'] == 'Yes';
        settlementReport = advanced['settelment_report'] == 'Yes';
        realTimeOrderStatus = advanced['real_time_order_status'] == 'Yes';
        showPopularCategory = advanced['show_popular_category'] == 'Yes';
        foodLevelNotes = advanced['food_level_notes'] == 'Yes';
        orderConfirmForWeb = advanced['order_confirm_for_web'] == 'Yes';
        showFoodVariance = advanced['show_food_varriance'] == 'Yes';
        billingAutoBillPrint = advanced['billing_auto_bill_print'] == 'Yes';
        showAcNonMenu = advanced['show_ac_non_menu'] == 'Yes';
        foodDate = advanced['food_date'] == 'Yes';
        feedBack = advanced['feed_back'] == 'Yes' ? true : false;
        searchBy = List<String>.from(advanced['search_by'] ?? []);
        orderPaymentType = advanced['order_payment_type'] ?? 'both';
        defOrdStatus = advanced['def_ord_status'] ?? 0;
        PrintKot = advanced['print_kot'] == 'Yes';
        walkinOnlinePayment =
            advanced['walkin_online_payment'] == 'Yes' ? true : false;
        dineinOnlinePayment =
            advanced['dinein_online_payment'] == 'Yes' ? true : false;
        takeawayOnlinePayment =
            advanced['takeaway_online_payment'] == 'Yes' ? true : false;
        deliveryOnlinePayment =
            advanced['delivery_online_payment'] == 'Yes' ? true : false;
        feedbackUrlCtrl.text = advanced['feedback_url'] ?? '';
        gstTaxCtrl.text = advanced['gst_tax'] ?? '0.00';
        taxCtrl.text = advanced['tax'].toString() ?? '0.00';
        restaurentGst = advanced['restaurent_gst'] ?? 'restaurant';
        listServeItem = advanced['list_serve_item'] ?? 'Dynamic';
        sendFeedbackLink = advanced['send_feedback_link'] ?? 'internal';
        canclePostServe = advanced['cancle_post_serve'] == 'Yes';
        voiceInKds = advanced['voice_in_kds'] == 'Yes';

        final vendor = data['vendor'];
        ownerFirstNameCtrl.text = vendor['f_name'] ?? '';
        ownerSecondtNameCtrl.text = vendor['l_name'] ?? '';
        ownerNumberCtrl.text = vendor['phone'] ?? '';
        update();
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateResturantSetting() async {
    if (!formKey.currentState!.validate()) return;
    isSubmitting = true;
    update();

    Map<String, dynamic> basic = {
      'name': nameCtrl.text.trim(),
      'phone': phoneBillCtrl.text.trim(),
      // 'gst': gstCheck ? gstNumCtrl.text : '',
      // 'vat': vatCheck ? vatNumCtrl.text : '',
      'gst': {
        'status': gstCheck ? 1 : 0,
        'code': gstNumCtrl.text.trim().trim(),
      },
      'vat': {
        'status': vatCheck ? 1 : 0,
        'code': vatNumCtrl.text.trim(),
      },
      'fssai': fssaiCtrl.text.trim(),
      'report_number': reportContactCtrl.text.trim(),
      'delivery_contact_no': deliveryContactCtrl.text.trim(),
      'address': resturantAddress.text.trim(),
      'phone_number_on_bill': phoneNumberOnBillCtrl.text.trim(),
      'inventory_manager_name': inventoryManagerNameCtrl.text.trim(),
      'online_ordering_link': onlineOrderingLinkCtrl.text.trim(),
      'short_code': shortCode,
      'restaurant_for': restaurantFor,
    };

    Map<String, dynamic> advanced = {
      'upi_id': upiIdCtrl.text.trim(),
      'delivery_person_name': deliveryContactPersonNameCtrl.text.trim(),

      'pay_upi': selectedPayments.contains('UPI') ? 'Yes' : 'No',
      'pay_cash': selectedPayments.contains('Cash') ? 'Yes' : 'No',
      'pay_cc': selectedPayments.contains('Card') ? 'Yes' : 'No',
      // 'online_payment': selectedPayments.contains('Online') ? 'Yes' : 'No',
      'pay_tab': selectedPayments.contains('Tab') ? 'Yes' : 'No',
      'room': selectedPayments.contains('Room') ? 'Yes' : 'No',
      'dine_in': selectedChannels.contains('Dinein') ? 'Yes' : 'No',
      'take_away': selectedChannels.contains('Takeaway') ? true : false,
      'delivery': selectedChannels.contains('Delivery') ? true : false,
      // 'show_cash_on_delivery':  selectedPayments.contains('Cash on Delivery') ? 'Yes' : 'No',
      'settelment_report': settlementReport ? 'Yes' : 'No',
      'real_time_order_status': realTimeOrderStatus ? 'Yes' : 'No',
      'show_popular_category': showPopularCategory ? 'Yes' : 'No',
      'food_level_notes': foodLevelNotes ? 'Yes' : 'No',
      'order_confirm_for_web': orderConfirmForWeb ? 'Yes' : 'No',
      'show_food_varriance': showFoodVariance ? 'Yes' : 'No',
      'service_charge': serviceCharge ? 'Yes' : 'No',
      'auto_service_charge': autoServiceCharge ? 'Yes' : 'No',
      'service_charge_percentage': serviceChargeText.text.isNotEmpty
          ? serviceChargeText.text.trim()
          : '0.00',
      'service_charge_tax': serviceChargeTax.text.isNotEmpty
          ? serviceChargeTax.text.trim()
          : '0.00',
      'available_discount': availableDiscount ? 'Yes' : 'No',
      'tip': tipEnabled ? 'Yes' : 'No',
      'inventory': inventoryEnabled ? 'Yes' : 'No',
      'inventory_negative': inventoryNegative ? 'Yes' : 'No',
      'dynamic_upi_value': dynamicUpiValue ? 'Yes' : 'No',
      'total_round': totalRound ? 'Yes' : 'No',
      'inventory_alert_number': inventoryAlertNumber.text.trim(),
      'search_by': searchBy,
      'billing_auto_bill_print': billingAutoBillPrint ? 'Yes' : 'No',
      'show_ac_non_menu': showAcNonMenu ? 'Yes' : 'No',
      'food_date': foodDate ? 'Yes' : 'No',
      'feed_back': feedBack ? 'Yes' : 'No',
      'order_payment_type': orderPaymentType,
      'print_kot': PrintKot ? 'Yes' : 'No',
      'def_ord_status': defOrdStatus,
      'walkin_online_payment': walkinOnlinePayment ? 'Yes' : 'No',
      'dinein_online_payment': dineinOnlinePayment ? 'Yes' : 'No',
      'takeaway_online_payment': takeawayOnlinePayment ? 'Yes' : 'No',
      'delivery_online_payment': deliveryOnlinePayment ? 'Yes' : 'No',
      'feedback_url': feedbackUrlCtrl.text.trim(),
      'gst_tax': gstTaxCtrl.text.isNotEmpty
          ? gstTaxCtrl.text.trim()
          : '5', // gst percentage
      'tax': taxCtrl.text.isNotEmpty
          ? taxCtrl.text.trim()
          : '0.00', // vat percentage
      'restaurent_gst': restaurentGst,
      'list_serve_item': listServeItem,
      'send_feedback_link': sendFeedbackLink,
      'cancle_post_serve': canclePostServe ? 'Yes' : 'No',
      'voice_in_kds': voiceInKds ? 'Yes' : 'No',
    };

    Map<String, dynamic> vendor = {
      'f_name': ownerFirstNameCtrl.text.trim(),
      'l_name': ownerSecondtNameCtrl.text.trim(),
      'phone': ownerNumberCtrl.text.trim(),
    };

    Map<String, dynamic> settingsData = {
      'basic': basic,
      'advanced': advanced,
      'vendor': vendor,
    };

    Map<String, String> fields = {
      'data': jsonEncode(settingsData),
    };

    try {
      final response = await restaurantSettingsRepo.updateResturantSetting(
          fields, logoFile, pdfXFile);
      if (response.statusCode == 200) {
        resetSettings();
        Get.snackbar('Success',
            response.body['message'] ?? 'Settings updated successfully',
            backgroundColor: ColorTheme.green, colorText: Colors.white);
        getResturantSettings();
        update();
      } else {
        ApiChecker.checkApi(response);

        Get.snackbar(
            'Error', response.body['message'] ?? 'Failed to update settings',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Failed to update settings: $e');
    }

    isSubmitting = false;
    update();
  }

  void resetSettings() {
    isResetting = true;
    update();
    nameCtrl.clear();
    phoneBillCtrl.clear();
    gstNumCtrl.clear();
    vatNumCtrl.clear();
    fssaiCtrl.clear();
    reportContactCtrl.clear();
    deliveryContactCtrl.clear();
    upiIdCtrl.clear();
    ownerFirstNameCtrl.clear();
    ownerSecondtNameCtrl.clear();
    ownerNumberCtrl.clear();
    uploadMenuCtrl.clear();
    resturantAddress.clear();
    inventoryAlertNumber.clear();
    phoneNumberOnBillCtrl.clear();
    onlineOrderingLinkCtrl.clear();
    emailIdOnBillCtrl.clear();
    inventoryManagerNameCtrl.clear();

    logoFile = null;
    logoUrl = '';
    gstCheck = false;
    vatCheck = false;
    selectedPayments.clear();
    selectedChannels.clear();
    openingTime = const TimeOfDay(hour: 9, minute: 0);
    closingTime = const TimeOfDay(hour: 22, minute: 0);

    pdfMenuUrl = '';
    deliveryContactPersonNameCtrl.clear();
    roomEnabled = false;
    tipEnabled = false;
    availableDiscount = false;
    inventoryEnabled = false;
    inventoryNegative = false;
    dynamicUpiValue = false;
    totalRound = false;
    inventoryAlertNumber.clear();
    autoServiceCharge = false;
    serviceChargeText.clear();
    serviceChargeTax.clear();
    serviceCharge = false;
    settlementReport = false;
    realTimeOrderStatus = false;
    showPopularCategory = false;
    foodLevelNotes = false;
    orderConfirmForWeb = false;
    showFoodVariance = false;
    billingAutoBillPrint = false;
    showAcNonMenu = false;
    foodDate = false;
    feedBack = false;
    deliveryOnlinePayment = false;
    takeawayOnlinePayment = false;
    dineinOnlinePayment = false;
    walkinOnlinePayment = false;
    canclePostServe = false;
    voiceInKds = false;
    shortCode = 'No';
    searchBy.clear();
    orderPaymentType = 'both';
    restaurantFor = 'Normal';
    defOrdStatus = 0;
    feedbackUrlCtrl.clear();
    gstTaxCtrl.clear();
    taxCtrl.clear();
    restaurentGst = 'restaurant';
    listServeItem = 'Dynamic';
    sendFeedbackLink = 'external';

    isResetting = false;
    update();
  }

  String? validatePhone(String value) {
    String pattern = r'^\+?[0-9]{10}$';
    RegExp regex = RegExp(pattern);
    if (value.isEmpty) {
      return 'This field is required';
    }
    if (!regex.hasMatch(value)) {
      return 'Invalid phone number format';
    }
    return null;
  }

  Future<void> pickLogo() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      logoFile = XFile(pickedImage.path);
      update();
    }
  }

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      pickedFile = result.files.first;
      uploadMenuCtrl.text = pickedFile!.name;
      pdfXFile = XFile(pickedFile!.path!);
      update();
    }
  }
}
