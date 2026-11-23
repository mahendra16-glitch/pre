import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/widget/url_launcher/url_launcher.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/expense_repo/expense_repo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExpenseManagementController extends GetxController
    implements GetxService {
  final ExpenseManagementRepo expenseManagementRepo;
  ExpenseManagementController({required this.expenseManagementRepo});

  String selectedPaymentType = "All";
  String? chooseFilePath;

  final manageExpenseFormKey = GlobalKey<FormState>();

  TextEditingController manageAmountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController ChooseFileController = TextEditingController();
  TextEditingController newCategoryNameController = TextEditingController();

  String? categoryValue;
  String? deleteReason;

  RxInt tabValue = 0.obs;
  int totalAmount = 0;

  RxBool isImportLoader = false.obs;
  RxBool isExportLoader = false.obs;
  RxBool exportSampleLoader = false.obs;
  bool chooseFileLoader = false;
  bool isManageListLoading = false;
  bool isEditMode = false;
  RxBool isDeleteSubmitting = false.obs;
  bool isSubmitting = false;
  RxBool isSubmitLoader = false.obs;
  bool isDownloadLoader = false;

  List<String> deleteFoodReasonList = [
    'Wrong Entry',
    'Wrong Amount',
    'Change Payment method',
    'Change stock Name',
  ];
  List<Map<String, dynamic>> manageList = [];
  List<String> getUnitList = [];
  List<String> getAllPaymentList = [];
  List<String> getPaymentList = [];

  Map<String, dynamic>? currentEditExpense;

  //============================================== MANAGE EXPENSE(EXPENSE) ==============================================//

  //* get Manage List data
  Future<void> fetchManageExpenses() async {
    try {
      isManageListLoading = true;
      update();
      Map<String, dynamic> data = {
        "from": formattedFromDate ??
            DateFormat('dd/MM/yyyy').format(DateTime.now()),
        "to":
            formattedToDate ?? DateFormat('dd/MM/yyyy').format(DateTime.now()),
        "payment_method": selectedPaymentType,
      };

      log("fetchManageExpenses data :$data");

      final response = await expenseManagementRepo.manageExpenses(data);
      log("fetchManageExpenses response body:${response?.body}");

      if (response?.statusCode == 200) {
        final responseData = response?.body;
        if (responseData != null) {
          List<dynamic> reportData = responseData['report'] ?? [];
          manageList = reportData
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          manageAmountController.text =
              responseData["total_amount"]?.toString() ?? "";
          print('${manageAmountController.text}');
          log("manageList :${manageList.toList()}");
        }
      } else {
        ApiChecker.checkApi(response!);
      }

      update();
    } catch (e) {
      log("fetchManageExpenses :$e");
    } finally {
      isManageListLoading = false;
      update();
    }
  }

  //* edit manage expense
  editManageExpense(dynamic expId) async {
    try {
      final parsedExpId = int.tryParse(expId?.toString() ?? '');
      if (parsedExpId == null) {
        appToast(AppString.somethingWrong);
        return;
      }
      if (!manageExpenseFormKey.currentState!.validate()) {
        appToast("Please fill all required fields");
        return;
      }
      if (!validateStockNames()) {
        appToast(AppString.pleaseSelectStockName);
        update();
        return;
      }
      if (!validateExpenseSplits()) {
        appToast("Please fill all required fields");
        update();
        return;
      }
      if (isSubmitting) return;
      isSubmitting = true;
      setLoader(true);

      // Map<String, dynamic> data = {
      //   "exp_name": addStockTextController[0].text.trim(),
      //   "e_dates": dateController.text.trim(),
      //   "d_amount": addAmountTextController[0].text.trim(),
      //   "payment_method": addExpenseSelectedPaymentType[0].toString(),
      //   "quantity": addQuantityTextController[0].text.toString(),
      //   "unit": addExpenseSelectedUnit[0].toString(),
      //   'physical_quantity': addPQuantityTextController[0].text.toString(),
      //   "notes": addNotesTextController.isNotEmpty
      //       ? addNotesTextController[0].text.trim()
      //       : "",
      //   "payment_made_to": addPaidToTextController.isNotEmpty
      //       ? addPaidToTextController[0].text.trim()
      //       : "",
      //   "payment_ref_id": addRefIdTextController.isNotEmpty
      //       ? addRefIdTextController[0].text.trim()
      //       : "",
      // };

      final totalAmount =
          double.tryParse(addAmountTextController[0].text.trim()) ?? 0.0;
      final List<Map<String, dynamic>> details = [];
      if (isExpenseSplit.isNotEmpty && isExpenseSplit[0]) {
        details.add(buildUpdateExpenseDetail(
          0,
          double.tryParse(splitAmountTextController[0].text.trim()) ?? 0.0,
          addExpenseSelectedPaymentType[0],
        ));
        details.add(buildUpdateExpenseDetail(
          0,
          double.tryParse(splitAmount2TextController[0].text.trim()) ?? 0.0,
          splitPaymentMethod2[0],
        ));
      } else {
        details.add(buildUpdateExpenseDetail(
          0,
          totalAmount,
          addExpenseSelectedPaymentType[0],
        ));
      }

      Map<String, dynamic> data = {
        "e_date": _expenseApiDate(dateController.text),
        "total_amount": totalAmount,
        "details": details,
      };

      final response =
          await expenseManagementRepo.updateDirectExpenses(parsedExpId, data);

      if (response?.statusCode == 200) {
        manageExpenseResetData(false);
        await fetchManageExpenses();

        final message = response?.body?["message"] ?? AppString.somethingWrong;
        (Platform.isAndroid || Platform.isIOS)
            ? appToast(message)
            : Get.snackbar(
                'Updated',
                message,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
        // Get.back();
      } else if (response?.statusCode == 403) {
        Get.snackbar(
          response?.body['errors'][0]['code'],
          response?.body['errors'][0]['message'],
          colorText: Colors.white,
          backgroundColor: const Color.fromARGB(255, 195, 69, 15),
        );
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("editManageExpense :$e");
    } finally {
      setLoader(false);
      isSubmitting = false;
    }
  }

  //* delete manage expense
  deleteManageExpense(int id) async {
    if (isDeleteSubmitting.value) return;
    try {
      isDeleteSubmitting.value = true;
      setDeleteLoader(true);

      if (deleteReason?.isNotEmpty ?? false) {
        Map<String, dynamic> data = {"delete_reason": deleteReason};
        final response =
            await expenseManagementRepo.deleteManageExpense(id, data);

        if (response?.statusCode == 200) {
          await fetchManageExpenses();
          Get.back();

          final message =
              response?.body?["message"] ?? AppString.somethingWrong;
          (Platform.isAndroid || Platform.isIOS)
              ? appToast(message)
              : Get.snackbar(
                  'Deleted',
                  message,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
        } else {
          ApiChecker.checkApi(response!);
        }
      } else {
        appToast(AppString.selectReason);
      }
      update();
    } catch (e) {
      log("deleteManageExpense :$e");
    } finally {
      setDeleteLoader(false);
      isDeleteSubmitting.value = false;
    }
  }

  //* add manage expense
  addManageExpense() async {
    try {
      if (!manageExpenseFormKey.currentState!.validate()) {
        appToast("Please fill all required fields");
        return;
      }
      if (!validateStockNames()) {
        appToast(AppString.pleaseSelectStockName);
        update();
        return;
      }
      if (!validateExpenseSplits()) {
        appToast("Please fill all required fields");
        update();
        return;
      }
      if (isSubmitting) return;
      isSubmitting = true;
      setLoader(true);
      if (addStockTextController.isNotEmpty &&
          addAmountTextController.isNotEmpty &&
          addExpenseSelectedPaymentType.isNotEmpty) {
        double totalAmount = addAmountTextController.fold(
          0.0,
          (previousValue, controller) {
            double value = double.tryParse(controller.text) ?? 0.0;
            return previousValue + value;
          },
        );

        // Prepare the details list
        List<Map<String, dynamic>> details = [];
        for (int index = 0; index < addStockExpenseList.length; index++) {
          if (index < isExpenseSplit.length && isExpenseSplit[index]) {
            details.add(buildExpenseDetail(
              index,
              double.tryParse(splitAmountTextController[index].text.trim()) ??
                  0.0,
              addExpenseSelectedPaymentType[index],
            ));
            details.add(buildExpenseDetail(
              index,
              double.tryParse(splitAmount2TextController[index].text.trim()) ??
                  0.0,
              splitPaymentMethod2[index],
            ));
          } else {
            details.add(buildExpenseDetail(
              index,
              double.tryParse(addAmountTextController[index].text.trim()) ??
                  0.0,
              addExpenseSelectedPaymentType[index],
            ));
          }
        }

        Map<String, dynamic> data = {
          "e_date": dateController.text,
          "total_amount": totalAmount,
          "details": details,
        };

        final response = await expenseManagementRepo.addManageExpense(data);
        log('addManageExpense response?.statusCode :${response?.statusCode}');
        if (response?.statusCode == 200) {
          manageExpenseResetData(false);
          await fetchManageExpenses();
          (Platform.isAndroid || Platform.isIOS)
              ? appToast(AppString.addedExpensesSuccessfully)
              : Get.snackbar(
                  'Added',
                  AppString.addedExpensesSuccessfully,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
          // Get.back();
        } else if (response?.statusCode == 403) {
          Get.snackbar(
            response?.body['errors'][0]['code'],
            response?.body['errors'][0]['message'],
            colorText: Colors.white,
            backgroundColor: const Color.fromARGB(255, 195, 69, 15),
          );
        } else {
          ApiChecker.checkApi(response!);
          appToast(AppString.failedToAddExpense);
        }
      } else {
        appToast(AppString.pleaseFillInAllFields);
      }
    } catch (e) {
      log("addMasterExpense error: $e");
      appToast(AppString.pleaseFillAllExpensesData);
    } finally {
      setLoader(false);
      isSubmitting = false;
    }
  }

  //* Get Expense Unit List
  Future<void> getUnit() async {
    try {
      final Response? response = await expenseManagementRepo.getUnit();

      if (response?.statusCode == 200) {
        final Map<String, dynamic> data = response?.body ?? {};
        List<dynamic> units = data['units'] ?? [];
        getUnitList = List<String>.from(units);
        log("getUnitList: $getUnitList");
      } else {
        ApiChecker.checkApi(response!);

        log("Failed to get units. Status: ${response.statusCode}");
      }
    } catch (e) {
      log("getUnit error: $e");
    }
    update();
  }

  //* Get Expense Payment Method List
  expensePaymentMethod({bool isShowAll = false}) async {
    try {
      Map<String, dynamic> data = {"filter": true};

      final Response? response = await expenseManagementRepo
          .expensePaymentMethod(isShowAll ? {} : data);

      print(
          "expensePaymentMethod response?.statusCode :${response?.statusCode}");

      if (response?.statusCode == 200) {
        List<dynamic> paymentMethods = response?.body?["Payment_method"] ?? [];

        getAllPaymentList = ['All', ...paymentMethods];
        getPaymentList =
            getAllPaymentList.where((item) => item != 'All').toList();
        // Auto-select if only one payment type available
        autoSelectSinglePaymentType();
      } else {
        ApiChecker.checkApi(response!);
      }
      log('getAllPaymentList :${getAllPaymentList.toList()}');
      log('getPaymentList :${getPaymentList.toList()}');
      update();
    } catch (e) {
      log("expensePaymentMethod :$e");
    }
  }

  exportSample() async {
    exportSampleLoader.value = true;
    update();
    print('Downloading Expense Bulk Import Sample Excel File ...');
    await appLaunchUrl(
        '${AppConstants.BASE_URL}/bulk_upload_sample/expense/Expense_Bulk_Import_Sample.xlsx');
    print('Expense Bulk Upload Downloaded Successfully.');
    Get.snackbar('Downloaded Successfully',
        'Expense Bulk Upload Downloaded Successfully.',
        backgroundColor: ColorTheme.green, colorText: Colors.white);
    exportSampleLoader.value = false;
    update();
  }

  bulkExport() async {
    try {
      isExportLoader.value = true;
      final Response? response =
          await expenseManagementRepo.expenseDownloadSample();

      if (response?.statusCode == 200) {
        final downloadUrl = response?.body["download_url"];
        final message = response?.body["message"];

        if (downloadUrl != null) {
          appLaunchUrl(downloadUrl);
        }

        if (message != null) {
          appToast(message);
        }
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("expenseDownloadSample :$e");
    } finally {
      isExportLoader.value = false;
    }
  }

  bulkImport() async {
    try {
      // FilePickerResult? result = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: ['xlsx'],
      // );
      // if (result != null && result.files.single.path != null) {
      isImportLoader.value = true;
      if (chooseFilePath?.isNotEmpty ?? false) {
        final Response? response = await expenseManagementRepo
            .expenseImportExpense(
                data: {}, fileName: chooseFilePath ?? "", keyFileName: "file");

        if (response?.statusCode == 200) {
          Get.back();
          await fetchManageExpenses();
          // await fetchManageExpenses();
          Get.snackbar(
              'Imported Successfully Message', response?.body['message'],
              backgroundColor: Colors.green, colorText: Colors.white);
          await fetchMasterExpenses();
          await fetchCategory();
          // appToast(response?.body["Massage"]);
        } else {
          ApiChecker.checkApi(response!);

          // appToast(response?.body["error"]);
          Get.snackbar('Error', response.body['error'],
              backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
        chooseFilePath = null;
        ChooseFileController.clear();
        update();
      } else {
        log("No file selected or file path is null.");
        // appToast(AppString.pleaseChooseFile);
        Get.snackbar('Check Again', AppString.pleaseChooseFile,
            backgroundColor: ColorTheme.appColor, colorText: Colors.white);
      }

      update();
    } catch (e) {
      log("expenseImportExpense :$e");
    } finally {
      isImportLoader.value = false;
    }
  }

  setLoader(bool val) {
    isSubmitLoader.value = val;
  }

  void autoSelectSinglePaymentType() {
    // Only auto-select if there's exactly one payment type
    if (getPaymentList.length == 1) {
      final singlePaymentType = getPaymentList.first;

      // Auto-select for all expense items that don't have a selection
      for (int i = 0; i < addExpenseSelectedPaymentType.length; i++) {
        if (addExpenseSelectedPaymentType[i].isEmpty) {
          addExpenseSelectedPaymentType[i] = singlePaymentType;
        }
      }
      update();
    }
  }

  //============================================== MANAGE EXPENSE(EXPENSE) ==============================================//

  //============================================== MASTER EXPENSE(EXPENSE STOCK) ==============================================//

  final masterExpenseFormKey = GlobalKey<FormState>();
  ScrollController masterScrollController = ScrollController();
  String? formattedFromDate;
  String? formattedToDate;
  DateTime selectedDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();

  int? editMasterExpenseId;

  RxBool isEditMaster = false.obs;
  bool isMasterExpenseLoading = false;
  RxBool isMasterSubmitting = false.obs;
  RxBool isMasterLoader = false.obs;
  RxBool isDeleteLoader = false.obs;

  List<int> localStockWidgetList = [];
  List<TextEditingController> expenseMasterStockTextControllers = [];
  List<Map<String, dynamic>> masterList = [];

  //* stock initState call
  stockInitStateCalling() async {
    masterScrollController = ScrollController();
    isEditMaster.value = false;
    await fetchManageExpenses();
    await fetchMasterExpenses();
    await fetchCategory();
    editMasterExpenseId = 0;
    if (localStockWidgetList.length == 0) {
      expenseMasterStockTextControllers.add(TextEditingController());
      localStockWidgetList.add(localStockWidgetList.length);
      categoryValue = null;
    } else {
      expenseMasterStockTextControllers = [];
      localStockWidgetList = [];
      expenseMasterStockTextControllers.add(TextEditingController());
      localStockWidgetList.add(localStockWidgetList.length);

      categoryValue = null;
    }
  }

  //* manage expense selectFromDate
  Future<void> selectFromDate(
    BuildContext context,
  ) async {
    log("selectedDate:$selectedDate");
    if (formattedFromDate != null) {
      DateFormat format = DateFormat("dd/MM/yyyy");
      DateTime parsedDate = format.parse(formattedFromDate ?? "");
      selectedDate = parsedDate;
    }
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      DateTime selectedDate = pickedDate;

      formattedFromDate = DateFormat('dd/MM/yyyy').format(selectedDate);
      await fetchManageExpenses();
      log("formattedFromDate :$formattedFromDate");
      update();
    }
  }

  //* manage expense selectToDate
  Future<void> selectToDate(
    BuildContext context,
  ) async {
    if (formattedFromDate != null) {
      DateFormat format = DateFormat("dd/MM/yyyy");
      DateTime parsedDate = format.parse(formattedToDate ?? "");
      selectedToDate = parsedDate;
    }
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedToDate,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != selectedToDate) {
      DateTime selectedDate = pickedDate;
      formattedToDate = DateFormat('dd/MM/yyyy').format(selectedDate);
      await fetchManageExpenses();
      update();
    }
  }

  //* master list scroll up side
  void scrollToBottom() {
    if (masterScrollController.hasClients) {
      masterScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  //* local Stock remove
  void removeStockWidget(int index) {
    try {
      if (expenseMasterStockTextControllers.length != 1) {
        expenseMasterStockTextControllers.removeAt(index);
        localStockWidgetList.removeAt(index);
      }
      update();
    } catch (e) {
      log("removeStockWidget :$e");
    }
  }

  //* get Master data
  Future<void> fetchMasterExpenses() async {
    try {
      isMasterExpenseLoading = true;
      update();
      final response = await expenseManagementRepo.masterExpenses();

      if (response != null && response.statusCode == 200) {
        final data = response.body?['expenses'] ?? [];

        masterList = List<Map<String, dynamic>>.from(
          data.map((item) => Map<String, dynamic>.from(item)),
        );
      } else {
        ApiChecker.checkApi(response!);
        log("fetchExpensesReport: No expenses data found or response is null.");
      }

      log("masterList : ${masterList.toList()}");
      update();
    } catch (e) {
      log("fetchMasterExpenses: $e");
    } finally {
      isMasterExpenseLoading = false;
      update();
    }
  }

  //* add expense stock
  addMasterExpense() async {
    try {
      if (!masterExpenseFormKey.currentState!.validate()) {
        appToast("Please fill all stock names");
        return;
      }
      if (isMasterSubmitting.value) return;
      isMasterSubmitting.value = true;
      setMasterLoader(true);
      if ((categoryValue?.isNotEmpty ?? false) &&
          expenseMasterStockTextControllers
              .every((controller) => controller.text.isNotEmpty)) {
        List<String> stockTitles = expenseMasterStockTextControllers
            .map((controller) => controller.text.trim())
            .toList();

        Map<String, dynamic> data = {
          "category_name": categoryValue,
          "stock_title": stockTitles,
        };

        final response = await expenseManagementRepo.addMasterExpense(data);

        if (response?.statusCode == 200) {
          await fetchMasterExpenses();
          // expenseMasterStockTextControllers = [];

          // var firstElement = localStockWidgetList.first;
          // localStockWidgetList.clear();
          // expenseMasterStockTextControllers
          //     .add(TextEditingController(text: ""));
          // localStockWidgetList.add(firstElement);
          resetExpense();
          categoryValue = null;
          (Platform.isAndroid || Platform.isIOS)
              ? appToast(AppString.stockAddedSuccessfully)
              : Get.snackbar(
                  'Added',
                  AppString.stockAddedSuccessfully,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
        } else {
          ApiChecker.checkApi(response!);
        }
        update();
      } else {
        appToast(AppString.pleaseSelectFields);
      }
    } catch (e) {
      log("addExpense :$e");
    } finally {
      setMasterLoader(false);
      isMasterSubmitting.value = false;
    }
  }

  //* edit expense stock
  editMasterExpense(int id) async {
    try {
      if (!masterExpenseFormKey.currentState!.validate()) {
        appToast("Please fill all stock names");
        return;
      }
      if (isMasterSubmitting.value) return;

      isMasterSubmitting.value = true;
      setMasterLoader(true);

      Map<String, dynamic> data = {
        "category_name": categoryValue,
        "stock_title": [
          {"title": expenseMasterStockTextControllers[0].text}
        ]
      };

      final response = await expenseManagementRepo.editMasterExpense(id, data);

      if (response != null && response.statusCode == 200) {
        await fetchMasterExpenses();

        // Reset the form
        resetExpense();
        expenseMasterStockTextControllers[0].text = "";
        isEditMaster.value = false;
        categoryValue = null;

        log("editMasterExpense==>>>");

        final message = response.body?["message"] ?? AppString.somethingWrong;
        (Platform.isAndroid || Platform.isIOS)
            ? appToast(message)
            : Get.snackbar(
                'Updated',
                message,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
      } else {
        ApiChecker.checkApi(response!);

        // appToast(AppString.somethingWrong);
      }

      update();
    } catch (e) {
      log("editMasterExpense :$e");
    } finally {
      setMasterLoader(false);
      isMasterSubmitting.value = false;
    }
  }

  //* delete expense stock
  deleteMasterExpense(int id) async {
    if (isDeleteSubmitting.value) return;

    try {
      isDeleteSubmitting.value = true;
      setDeleteLoader(true);

      if (deleteReason?.isNotEmpty ?? false) {
        Map<String, dynamic> data = {"delete_reason": deleteReason};

        final response =
            await expenseManagementRepo.deleteMasterExpense(id, data);

        if (response?.statusCode == 200) {
          await fetchMasterExpenses();
          Get.back();

          final message =
              response?.body?["message"] ?? AppString.somethingWrong;
          (Platform.isAndroid || Platform.isIOS)
              ? appToast(message)
              : Get.snackbar(
                  'Deleted',
                  message,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
        } else {
          ApiChecker.checkApi(response!);
        }
      } else {
        appToast(AppString.selectReason);
      }
    } catch (e) {
      log("deleteMasterExpense :$e");
    } finally {
      setDeleteLoader(false);
      isDeleteSubmitting.value = false;
    }
  }

  //* local Stock add
  void addStockWidget() {
    try {
      expenseMasterStockTextControllers.add(TextEditingController(text: ""));

      localStockWidgetList.add(localStockWidgetList.length ?? 0);

      update();
    } catch (e) {
      print("addStockWidget :$e");
    }
  }

  resetExpense() {
    if (expenseMasterStockTextControllers.length != 1) {
      var firstElement = localStockWidgetList.first;
      expenseMasterStockTextControllers = [];
      localStockWidgetList = [];
      expenseMasterStockTextControllers.add(TextEditingController(text: null));
      localStockWidgetList.add(firstElement);
      categoryValue = null;
    } else {
      categoryValue = null;
      expenseMasterStockTextControllers = [];
      expenseMasterStockTextControllers.add(TextEditingController(text: null));
    }
    masterExpenseFormKey.currentState!.reset();
    update();
  }

  initalResetMasterExpense() {
    masterList.clear();
    if (localStockWidgetList.length == 0) {
      expenseMasterStockTextControllers.add(TextEditingController());
      localStockWidgetList.add(localStockWidgetList.length);
      categoryValue = null;
    } else {
      expenseMasterStockTextControllers = [];
      localStockWidgetList = [];
      expenseMasterStockTextControllers.add(TextEditingController());
      localStockWidgetList.add(localStockWidgetList.length);

      categoryValue = null;
    }
  }

  setDeleteLoader(bool val) {
    isDeleteLoader.value = val;
  }

  setMasterLoader(bool val) {
    isMasterLoader.value = val;
  }

  //* bulk import master expense
  bulkMasterExpenseImport() async {
    try {
      isImportLoader.value = true;
      update();
      if (chooseFilePath?.isNotEmpty ?? false) {
        final Response? response = await expenseManagementRepo
            .expenseStockImport(
                data: {},
                fileName: chooseFilePath ?? "",
                keyFileName: "expense_file");

        if (response?.statusCode == 200) {
          Get.back();

          // await fetchManageExpenses();
          // appToast(response?.body["Massage"]);
          Get.snackbar('Imported Successfully Message',
              '${response?.body['message']} , Imported : ${response?.body['imported']} , Updated : ${response?.body['updated']}',
              backgroundColor: Colors.green, colorText: Colors.white);
          await fetchMasterExpenses();
          await fetchCategory();
        } else {
          ApiChecker.checkApi(response!);

          // appToast(response?.body["error"]);
          Get.snackbar('Error', response.body['errors'],
              backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
        chooseFilePath = null;
        ChooseFileController.clear();
        update();
      } else {
        log("No file selected or file path is null.");
        // appToast(AppString.pleaseChooseFile);
        Get.snackbar('Check Again', AppString.pleaseChooseFile,
            backgroundColor: ColorTheme.appColor, colorText: Colors.white);
      }

      update();
    } catch (e) {
      log("expenseImportExpense :$e");
    } finally {
      isImportLoader.value = false;
      update();
    }
  }

//* bulk export master expense
  bulkMasterExpenseExport() async {
    try {
      isExportLoader.value = true;
      final data = {"type": "all"};
      final Response? response =
          await expenseManagementRepo.expenseStockExistingSample(data);

      if (response?.statusCode == 200) {
        final downloadUrl = response?.body["download_url"];
        final message = response?.body["message"];

        if (downloadUrl != null) {
          appLaunchUrl(downloadUrl);
        }

        if (message != null) {
          Get.snackbar(
              'Exported Successfully Message', response?.body['message'],
              backgroundColor: Colors.green, colorText: Colors.white);
        }
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("expenseDownloadSample :$e");
    } finally {
      isExportLoader.value = false;
    }
  }

//* export sample excel file of master expense
  exportExpenseMasterSample() async {
    exportSampleLoader.value = true;
    update();
    print('Downloading Expense stock Bulk Import Sample Excel File ...');
    await appLaunchUrl(
        '${AppConstants.BASE_URL}/bulk_upload_sample/expense/expense_stock_sample.xlsx');
    print('Expense Bulk Upload Downloaded Successfully.');
    Get.snackbar('Downloaded Successfully',
        'Expense Bulk Upload Downloaded Successfully.',
        backgroundColor: ColorTheme.green, colorText: Colors.white);
    exportSampleLoader.value = false;
    update();
  }
  //============================================== MASTER EXPENSE(EXPENSE STOCK) ==============================================//

  //===================================================== EXPENSE CATEGORY ===================================================//

  RxBool isCategorySubmitting = false.obs;
  RxBool isAddCategoryLoader = false.obs;

  List<String> categoryList = [];

  //* get category
  Future<void> fetchCategory() async {
    try {
      final Response? response = await expenseManagementRepo.getCategoryList();

      if (response?.statusCode == 200) {
        List<dynamic> data = response?.body?['categories'];
        categoryList =
            data.map((item) => item['category_name'].toString()).toList();
      } else {
        ApiChecker.checkApi(response!);
      }
      log("categoryList :${categoryList.toList()}");
      update();
    } catch (e) {
      log("fetchCategory :$e");
    }
  }

  //* add category
  addCategory() async {
    try {
      if (newCategoryNameController.text.isNotEmpty) {
        bool isUnique =
            !categoryList.contains(newCategoryNameController.text.trim());

        if (isCategorySubmitting.value) return;
        if (isUnique) {
          isCategorySubmitting.value = true;
          setAddCategory(true);
          Map<String, dynamic> data = {
            "category_name": newCategoryNameController.text
          };

          Response? response = await expenseManagementRepo.addCategory(data);

          if (response?.statusCode == 200 || response?.statusCode == 201) {
            await fetchCategory();
            categoryValue = newCategoryNameController.text;
            Get.back();
            appToast(AppString.categoryAddedSuccessfully);
          } else {
            ApiChecker.checkApi(response!);
            log("Expense Category Failed to Add");
          }
        } else {
          appToast(AppString.categoryAlreadyExists);
        }

        update();
      } else {
        appToast(AppString.pleaseSelectCategory);
      }
    } catch (e) {
      log("addCategory :$e");
    } finally {
      setAddCategory(false);
      isCategorySubmitting.value = false;
    }
  }

  setAddCategory(bool val) {
    isAddCategoryLoader.value = val;
  }

  //===================================================== EXPENSE CATEGORY ===================================================//

  //* set dafault data bottom sheet
  List<int> addStockExpenseList = [];
  List<TextEditingController> addStockTextController = [];
  List<TextEditingController> addAmountTextController = [];
  List<TextEditingController> addQuantityTextController = [];
  List<TextEditingController> addPQuantityTextController = [];
  List<TextEditingController> addNotesTextController = [];
  List<TextEditingController> addPaidToTextController = [];
  List<TextEditingController> addRefIdTextController = [];
  List<TextEditingController> splitAmountTextController = [];
  List<TextEditingController> splitAmount2TextController = [];
  List<String> addExpenseSelectedPaymentType = [];
  List<String> addExpenseSelectedUnit = [];
  List<String> splitPaymentMethod2 = [];
  List<bool> isExpenseSplit = [];
  List<int> splitRowVersion = [];
  List<bool> stockNameHasError = [];

  void _appendBlankExpenseExtraFields() {
    addNotesTextController.add(TextEditingController());
    addPaidToTextController.add(TextEditingController());
    addRefIdTextController.add(TextEditingController());
    splitAmountTextController.add(TextEditingController());
    splitAmount2TextController.add(TextEditingController());
    splitPaymentMethod2.add("");
    isExpenseSplit.add(false);
    splitRowVersion.add(0);
    stockNameHasError.add(false);
  }

  void _clearExpenseExtraFields() {
    addNotesTextController.clear();
    addPaidToTextController.clear();
    addRefIdTextController.clear();
    splitAmountTextController.clear();
    splitAmount2TextController.clear();
    splitPaymentMethod2.clear();
    isExpenseSplit.clear();
    splitRowVersion.clear();
    stockNameHasError.clear();
  }

  String _expenseText(Map<String, dynamic> expense, List<String> keys) {
    for (final key in keys) {
      final value = expense[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  void _applyEditExtraFields(Map<String, dynamic>? expense) {
    if (expense == null || addNotesTextController.isEmpty) return;
    addNotesTextController[0].text =
        _expenseText(expense, const ['notes', 'Notes']);
    addPaidToTextController[0].text = _expenseText(
        expense, const ['payment_made_to', 'Paid to', 'paid_to']);
    addRefIdTextController[0].text = _expenseText(
        expense, const ['payment_ref_id', 'Ref ID', 'ref_id']);
    _applyEditPayment(expense);
  }

  String _knownPaymentMethod(dynamic raw) {
    final value = raw?.toString().trim() ?? '';
    if (value.isEmpty) return '';
    for (final method in getPaymentList) {
      if (method.toLowerCase() == value.toLowerCase()) return method;
    }
    return '';
  }

  List<Map<String, dynamic>> _paymentBreakdown(Map<String, dynamic> expense) {
    final raw = expense['payment_breakdown'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  bool _isSplitExpense(Map<String, dynamic> expense) {
    final flag = expense['is_split_payment'];
    return flag == true || flag == 1 || flag?.toString() == 'true';
  }

  void _applyEditPayment(Map<String, dynamic> expense) {
    final breakdown = _paymentBreakdown(expense);
    final split = _isSplitExpense(expense) && breakdown.isNotEmpty;
    if (isExpenseSplit.isNotEmpty) isExpenseSplit[0] = split;
    if (splitAmountTextController.isNotEmpty) {
      splitAmountTextController[0].clear();
    }
    if (splitAmount2TextController.isNotEmpty) {
      splitAmount2TextController[0].clear();
    }
    if (splitPaymentMethod2.isNotEmpty) splitPaymentMethod2[0] = "";
    if (addExpenseSelectedPaymentType.isEmpty) return;

    if (!split) {
      final method = breakdown.isNotEmpty
          ? breakdown.first['payment_method']
          : expense['Payment Method'];
      addExpenseSelectedPaymentType[0] = _knownPaymentMethod(method);
      return;
    }

    addExpenseSelectedPaymentType[0] =
        _knownPaymentMethod(breakdown.first['payment_method']);
    if (splitAmountTextController.isNotEmpty) {
      splitAmountTextController[0].text =
          breakdown.first['amount']?.toString() ?? '';
    }
    if (breakdown.length > 1) {
      if (splitPaymentMethod2.isNotEmpty) {
        splitPaymentMethod2[0] =
            _knownPaymentMethod(breakdown[1]['payment_method']);
      }
      if (splitAmount2TextController.isNotEmpty) {
        splitAmount2TextController[0].text =
            breakdown[1]['amount']?.toString() ?? '';
      }
    }
  }

  Map<String, dynamic> buildExpenseDetail(
      int index, double amount, String paymentMethod) {
    final expense = addStockTextController[index].text.trim();
    return {
      "expense": expense.isNotEmpty ? expense : "N/A",
      "amount": amount,
      "payment_method": paymentMethod,
      "quantity":
          double.tryParse(addQuantityTextController[index].text.trim()) ?? 0.0,
      "unit": addExpenseSelectedUnit[index],
      "physical_quantity":
          double.tryParse(addPQuantityTextController[index].text.trim()) ?? 0.0,
      "notes": index < addNotesTextController.length
          ? addNotesTextController[index].text.trim()
          : "",
      "payment_made_to": index < addPaidToTextController.length
          ? addPaidToTextController[index].text.trim()
          : "",
      "payment_ref_id": index < addRefIdTextController.length
          ? addRefIdTextController[index].text.trim()
          : "",
    };
  }

  String _expenseApiDate(String text) {
    try {
      return DateFormat('yyyy-MM-dd')
          .format(DateFormat('dd/MM/yyyy').parse(text.trim()));
    } catch (_) {
      return text.trim();
    }
  }

  Map<String, dynamic> buildUpdateExpenseDetail(
      int index, double amount, String paymentMethod) {
    final detail = buildExpenseDetail(index, amount, paymentMethod);
    detail['exp_master_id'] = currentEditExpense?['exp_master_id'];
    detail['physical_quantity'] =
        index < addPQuantityTextController.length
            ? addPQuantityTextController[index].text.trim()
            : "";
    return detail;
  }

  double splitParentAmount(int index) =>
      double.tryParse(addAmountTextController[index].text.trim()) ?? 0;

  double splitFirstAmount(int index) =>
      double.tryParse(splitAmountTextController[index].text.trim()) ?? 0;

  double splitSecondAmount(int index) =>
      double.tryParse(splitAmount2TextController[index].text.trim()) ?? 0;

  bool splitAmountsMatch(int index) {
    final first = splitFirstAmount(index);
    final second = splitSecondAmount(index);
    final parent = splitParentAmount(index);
    return first > 0 &&
        second > 0 &&
        (first + second - parent).abs() < 0.01;
  }

  String formatExpenseAmount(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  String splitStatusMessage(int index) {
    if (splitAmountsMatch(index)) {
      return AppString.splitAmountsMatch;
    }
    final diff = splitParentAmount(index) -
        (splitFirstAmount(index) + splitSecondAmount(index));
    if (diff.abs() < 0.01) {
      return AppString.enterBothSplitAmounts;
    }
    if (diff > 0) {
      return "Amounts don't match — ₹${diff.toStringAsFixed(2)} remaining";
    }
    return "Amounts don't match — ₹${diff.abs().toStringAsFixed(2)} extra";
  }

  String splitEquation(int index) {
    final first = splitFirstAmount(index);
    final second = splitSecondAmount(index);
    final parent = splitParentAmount(index);
    return '₹${formatExpenseAmount(first)} + ₹${formatExpenseAmount(second)} = ₹${formatExpenseAmount(first + second)} / ₹${formatExpenseAmount(parent)}';
  }

  bool validateStockNames() {
    var valid = true;
    while (stockNameHasError.length < addStockTextController.length) {
      stockNameHasError.add(false);
    }
    for (int i = 0; i < addStockTextController.length; i++) {
      final empty = addStockTextController[i].text.trim().isEmpty;
      stockNameHasError[i] = empty;
      if (empty) valid = false;
    }
    return valid;
  }

  bool validateExpenseSplits() {
    for (int index = 0; index < isExpenseSplit.length; index++) {
      if (!isExpenseSplit[index]) continue;
      final firstMethod = index < addExpenseSelectedPaymentType.length
          ? addExpenseSelectedPaymentType[index].trim()
          : '';
      final secondMethod = index < splitPaymentMethod2.length
          ? splitPaymentMethod2[index].trim()
          : '';
      if (firstMethod.isEmpty ||
          secondMethod.isEmpty ||
          !splitAmountsMatch(index)) {
        return false;
      }
    }
    return true;
  }

  void enableExpenseSplit(int index) {
    if (index >= isExpenseSplit.length) return;
    isExpenseSplit[index] = true;
    update();
  }

  void cancelExpenseSplit(int index) {
    if (index >= isExpenseSplit.length) return;
    isExpenseSplit[index] = false;
    if (index < splitAmountTextController.length) {
      splitAmountTextController[index].clear();
    }
    if (index < splitAmount2TextController.length) {
      splitAmount2TextController[index].clear();
    }
    if (index < splitPaymentMethod2.length) {
      splitPaymentMethod2[index] = "";
    }
    update();
  }

  void clearSplitPaymentRow(int index, int row) {
    if (row == 1) {
      if (index < addExpenseSelectedPaymentType.length) {
        addExpenseSelectedPaymentType[index] = "";
      }
      if (index < splitAmountTextController.length) {
        splitAmountTextController[index].clear();
      }
    } else {
      if (index < splitPaymentMethod2.length) {
        splitPaymentMethod2[index] = "";
      }
      if (index < splitAmount2TextController.length) {
        splitAmount2TextController[index].clear();
      }
    }
    while (splitRowVersion.length <= index) {
      splitRowVersion.add(0);
    }
    splitRowVersion[index] = splitRowVersion[index] + 1;
    update();
  }
  showDefaultBottomsSheetData(
    bool isEdit, {
    Map<String, dynamic>? expense,
  }) {
    try {
      if (addStockExpenseList.length == 0) {
        print('1');
        dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
        addStockTextController.add(TextEditingController());
        addAmountTextController.add(TextEditingController());

        addExpenseSelectedPaymentType.add("");
        addQuantityTextController.add(TextEditingController());
        addPQuantityTextController.add(TextEditingController());
        addExpenseSelectedUnit.add("");
        _appendBlankExpenseExtraFields();

        addStockExpenseList.add(addStockExpenseList.length);
        if (isEdit && expense != null) {
          print('2');
          dateController.text = expense['Date & Time'];
          addStockTextController[0].text = expense['EXPENSE'] ?? '';
          addAmountTextController[0].text = expense['Amount'] ?? '';
          addExpenseSelectedPaymentType[0] = expense['Payment Method'] ?? '';
          addQuantityTextController[0].text = expense['quantity'] ?? '';
          addPQuantityTextController[0].text =
              expense['physical_quantity'] ?? '';
          addExpenseSelectedUnit[0] = expense['unit'] ?? '';
          _applyEditExtraFields(expense);
        }
      } else {
        print('3');
        // dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
        // addStockExpenseList = [];
        // addStockTextController = [];
        // addAmountTextController = [];
        // addExpenseSelectedPaymentType = [];
        // addExpenseSelectedUnit = [];
        // addQuantityTextController = [];
        // addPQuantityTextController = [];

        // addStockTextController.add(TextEditingController());
        // addAmountTextController.add(TextEditingController());
        // addExpenseSelectedPaymentType.add("");
        // addQuantityTextController.add(TextEditingController());
        // addPQuantityTextController.add(TextEditingController());
        // addExpenseSelectedUnit.add("");

        // addStockExpenseList.add(
        //   addStockExpenseList.length,
        // );

        if (isEdit) {
          print('4');
          dateController.text = expense?['Date & Time'];
          addStockTextController[0].text = expense?['EXPENSE'] ?? '';
          addAmountTextController[0].text = expense?['Amount'] ?? '';
          addExpenseSelectedPaymentType[0] = expense?['Payment Method'] ?? '';
          addQuantityTextController[0].text = expense?['quantity'] ?? '';
          addPQuantityTextController[0].text =
              expense?['physical_quantity'] ?? '';
          addExpenseSelectedUnit[0] = expense?['unit'] ?? '';
          _applyEditExtraFields(expense);
        }
      }
    } catch (e) {
      log("showDefaultBottomsSheetData :$e");
    }
  }
  // showDefaultBottomsSheetData(
  //   bool isEdit, {
  //   Map<String, dynamic>? expense,
  // }) {
  //   try {
  //     // Always clear first
  //     dateController.clear();
  //     addStockExpenseList.clear();
  //     addStockTextController.clear();
  //     addAmountTextController.clear();
  //     addExpenseSelectedPaymentType.clear();
  //     addQuantityTextController.clear();
  //     addPQuantityTextController.clear();
  //     addExpenseSelectedUnit.clear();

  //     // // Initialize fresh
  //     // dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  //     // addStockTextController.add(TextEditingController(text: ""));
  //     // addAmountTextController.add(TextEditingController(text: ""));
  //     // addExpenseSelectedPaymentType.add("");
  //     // addQuantityTextController.add(TextEditingController(text: ""));
  //     // addPQuantityTextController.add(TextEditingController(text: ""));
  //     // addExpenseSelectedUnit.add("");
  //     // addStockExpenseList.add(0);

  //     // Fill with edit data if needed
  //     if (isEdit && expense != null && expense.isNotEmpty) {
  //       dateController.text = expense['Date & Time']?.toString() ??
  //           DateFormat('dd/MM/yyyy').format(DateTime.now());
  //       addStockTextController[0].text = expense['EXPENSE']?.toString() ?? '';
  //       addAmountTextController[0].text = expense['Amount']?.toString() ?? '';
  //       addExpenseSelectedPaymentType[0] =
  //           expense['Payment Method']?.toString() ?? '';
  //       addQuantityTextController[0].text =
  //           expense['quantity']?.toString() ?? '';
  //       addPQuantityTextController[0].text =
  //           expense['physical_quantity']?.toString() ?? '';
  //       addExpenseSelectedUnit[0] = expense['unit']?.toString() ?? '';

  //       log("✅ Edit data loaded: ${expense['EXPENSE']}");
  //     }
  //   } catch (e) {
  //     log("showDefaultBottomsSheetData: $e");
  //   }
  // }
  // void addStockExpense(int length) {
  //   try {
  //     addStockTextController.add(TextEditingController(text: ""));
  //     addAmountTextController.add(TextEditingController(text: ""));

  //     addExpenseSelectedPaymentType.add("");
  //     addQuantityTextController.add(TextEditingController(text: ""));
  //     addPQuantityTextController.add(TextEditingController(text: ""));
  //     addExpenseSelectedUnit.add("");
  //     addStockExpenseList.add(length);

  //     update();
  //   } catch (e) {
  //     log("addStockExpense : $e");
  //   }
  // }

  void addStockExpense(int length) {
    try {
      addStockTextController.add(TextEditingController(text: ""));
      addAmountTextController.add(TextEditingController(text: ""));
      addExpenseSelectedPaymentType.add("");
      addQuantityTextController.add(TextEditingController(text: ""));
      addPQuantityTextController.add(TextEditingController(text: ""));
      addExpenseSelectedUnit.add("");
      _appendBlankExpenseExtraFields();
      addStockExpenseList.add(length);

      update(); // ✅ Safe update here
    } catch (e) {
      log("addStockExpense : $e");
    }
  }

  //* manage expense reset data
  // manageExpenseResetData(bool isEdit) {
  //   try {
  //     if (isEdit) {
  //       dateController.clear();
  //       addStockTextController[0].clear();
  //       addAmountTextController[0].clear();
  //       addQuantityTextController[0].clear();
  //       addPQuantityTextController[0].clear();
  //       if (addExpenseSelectedPaymentType.isNotEmpty) {
  //         addExpenseSelectedPaymentType[0] = "";
  //         update();
  //       }
  //       if (addExpenseSelectedUnit.isNotEmpty) {
  //         addExpenseSelectedUnit[0] = "";
  //         update();
  //       }
  //       manageExpenseFormKey.currentState!.reset();
  //       update();
  //     } else {
  //       dateController.clear();
  //       addStockExpenseList = [];
  //       addStockTextController = [];
  //       addAmountTextController = [];
  //       addQuantityTextController = [];
  //       addPQuantityTextController = [];
  //       addExpenseSelectedPaymentType = [];
  //       addExpenseSelectedUnit = [];

  //       addStockTextController.add(TextEditingController());
  //       addAmountTextController.add(TextEditingController());
  //       addQuantityTextController.add(TextEditingController());
  //       addPQuantityTextController.add(TextEditingController());
  //       addExpenseSelectedPaymentType.add("");
  //       addExpenseSelectedUnit.add("");
  //       addStockExpenseList.add(addStockExpenseList.length);
  //       manageExpenseFormKey.currentState!.reset();
  //       update();
  //     }
  //   } catch (e) {
  //     log("manageExpenseResetData :$e");
  //   }
  // }

  manageExpenseResetData(bool isEdit) {
    try {
      if (isEdit) {
        // Partial reset for edit mode
        for (var controller in addStockTextController) controller.clear();
        for (var controller in addAmountTextController) controller.clear();
        for (var controller in addQuantityTextController) controller.clear();
        for (var controller in addPQuantityTextController) controller.clear();
        for (var controller in addNotesTextController) controller.clear();
        for (var controller in addPaidToTextController) controller.clear();
        for (var controller in addRefIdTextController) controller.clear();
        for (var controller in splitAmountTextController) controller.clear();
        for (var controller in splitAmount2TextController) controller.clear();
        addExpenseSelectedPaymentType.clear();
        addExpenseSelectedUnit.clear();
        addStockExpenseList.clear();
        for (int i = 0; i < isExpenseSplit.length; i++) {
          isExpenseSplit[i] = false;
        }
        for (int i = 0; i < splitPaymentMethod2.length; i++) {
          splitPaymentMethod2[i] = "";
        }

        // Reinitialize with single empty item
        addExpenseSelectedPaymentType.add("");
        addExpenseSelectedUnit.add("");
        addStockExpenseList.add(0);
        if (addStockTextController.isNotEmpty &&
            addNotesTextController.isEmpty) {
          _appendBlankExpenseExtraFields();
        }
      } else {
        // for (int i = 0; i < addStockTextController.length; i++) {
        //   try {
        //     addStockTextController[i].dispose();
        //     addAmountTextController[i].dispose();
        //     addQuantityTextController[i].dispose();
        //     addPQuantityTextController[i].dispose();
        //   } catch (e) {
        //     log("Dispose error: $e");
        //   }
        // }

        // Full reset for add mode
        dateController.clear();
        addStockExpenseList.clear();
        addStockTextController.clear();
        addAmountTextController.clear();
        addQuantityTextController.clear();
        addPQuantityTextController.clear();
        addExpenseSelectedPaymentType.clear();
        addExpenseSelectedUnit.clear();
        _clearExpenseExtraFields();

        // Fresh initialization
        dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
        addStockTextController.add(TextEditingController());
        addAmountTextController.add(TextEditingController());
        addQuantityTextController.add(TextEditingController());
        addPQuantityTextController.add(TextEditingController());
        addExpenseSelectedPaymentType.add("");
        addExpenseSelectedUnit.add("");
        _appendBlankExpenseExtraFields();
        addStockExpenseList.add(0);

        print(
            '${addStockTextController.length} ${addStockTextController[0].text} - Reset for add mode');
      }

      manageExpenseFormKey.currentState?.reset();
      update();
    } catch (e) {
      log("manageExpenseResetData: $e");
    }
  }

  // expense report
  List<Map<String, dynamic>> expenseReportList = [];
  DateTime? selectedReportFromDate;
  DateTime? selectedReportToDate;
  String? totalExpenseReportAmount;
  bool isExpenseReportLoading = false;

  Future<void> fetchExpenseReport() async {
    try {
      isExpenseReportLoading = true;
      update();
      selectedReportFromDate = formattedFromDate != null
          ? DateFormat('dd/MM/yyyy').parse(formattedFromDate!)
          : DateTime.now();
      selectedReportToDate = formattedToDate != null
          ? DateFormat('dd/MM/yyyy').parse(formattedToDate!)
          : DateTime.now();
      //to get all data make the from and to empty/blank
      Map<String, dynamic> data = {
        "from": formattedFromDate != null
            ? '${DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(formattedFromDate!))}'
            : '${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
        "to": formattedToDate != null
            ? '${DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(formattedToDate!))}'
            : '${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
        // "from": "2025-03-27",
        // "to": "2025-09-05"
      };

      log("fetchExpenseReport data :$data");

      final response = await expenseManagementRepo.expenseReport(data);
      log("fetchExpenseReport response body:${response?.body}");

      if (response?.statusCode == 200) {
        final responseData = response?.body;
        if (responseData != null) {
          totalExpenseReportAmount = responseData["total"]?.toString();
          List<dynamic> reportData = responseData['report'] ?? [];
          expenseReportList = reportData
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          manageAmountController.text =
              responseData["total_amount"]?.toString() ?? "";
          log("expenseReportList :${expenseReportList.toList()}");
        }
      } else {
        ApiChecker.checkApi(response!);
        log("fetchExpensesListReport: No expenses data found or response is null.");
      }

      update();
    } catch (e) {
      log("fetchExpenseReport :$e");
    } finally {
      isExpenseReportLoading = false;
      update();
    }
  }

  Future<void> pickExcelFile() async {
    chooseFileLoader = true;
    update();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      chooseFilePath = result.files.single.path;
      print("chooseFilePath :$chooseFilePath");
      ChooseFileController.text = chooseFilePath?.split("/").last ?? "";
      update();
    } else {
      log("No file selected or file path is null.");
    }
    chooseFileLoader = false;
    update();
  }

  int autoCompleteRefreshKey = 0;

  void refreshAutoComplete() {
    autoCompleteRefreshKey++;
    update();
  }

  //============================================== UNIT PRICE MASTER ==============================================//

  RxBool isUnitPriceMasterLoading = false.obs;
  RxBool isUnitPriceMasterSubmitting = false.obs;
  RxBool isUnitPriceMasterUpdating = false.obs;
  RxBool isUnitPriceMasterDeleting = false.obs;
  RxInt editingUnitPriceMasterId = (-1).obs;
  RxInt updatingUnitPriceMasterId = (-1).obs;

  List<Map<String, dynamic>> unitPriceMasterList = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> expensesWithoutUnitPricesList =
      <Map<String, dynamic>>[];

  TextEditingController unitPriceMasterPriceController =
      TextEditingController();
  TextEditingController unitPriceMasterQuantityController =
      TextEditingController();
  int? selectedStockId;
  String? selectedStockName;

  void clearUnitPriceMasterList() {
    unitPriceMasterList.clear();
  }

  Future<void> getExpensesWithoutUnitPrices() async {
    try {
      expensesWithoutUnitPricesList.clear();
      final response =
          await expenseManagementRepo.getExpensesWithoutUnitPrices();

      if (response != null && response.statusCode == 200) {
        final data = response.body?['data'] ?? [];
        expensesWithoutUnitPricesList = List<Map<String, dynamic>>.from(
          data.map((item) => Map<String, dynamic>.from(item)),
        );
        log('Expenses Without Unit Prices List: ${expensesWithoutUnitPricesList.length} items');
      } else {
        ApiChecker.checkApi(response!);
        expensesWithoutUnitPricesList.clear();
      }
      update();
    } catch (e) {
      log("getExpensesWithoutUnitPrices error: $e");
      expensesWithoutUnitPricesList.clear();
      update();
    }
  }

  Future<void> getUnitPriceMasterList() async {
    try {
      isUnitPriceMasterLoading.value = true;
      clearUnitPriceMasterList();
      update();

      final response = await expenseManagementRepo.getStockUnitPrices();

      if (response != null && response.statusCode == 200) {
        final data = response.body?['data'] ?? [];
        unitPriceMasterList = List<Map<String, dynamic>>.from(
          data.map((item) => Map<String, dynamic>.from(item)),
        );
        log('Unit Price Master List: ${unitPriceMasterList.length} items');
      } else {
        ApiChecker.checkApi(response!);
        unitPriceMasterList.clear();
      }
    } catch (e) {
      log("getUnitPriceMasterList error: $e");
      unitPriceMasterList.clear();
    } finally {
      isUnitPriceMasterLoading.value = false;
      update();
    }
  }

  List<Map<String, dynamic>> getFilteredUnitPriceMasterList() {
    return unitPriceMasterList;
  }

  Future<void> addUnitPriceMaster() async {
    try {
      if (selectedStockId == null) {
        Get.snackbar(
          'Validation',
          'Please select stock name',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // if (unitPriceMasterQuantityController.text.trim().isEmpty) {
      //   Get.snackbar(
      //     'Validation',
      //     'Please enter quantity',
      //     backgroundColor: Colors.red,
      //     colorText: Colors.white,
      //   );
      //   return;
      // }

      if (unitPriceMasterPriceController.text.trim().isEmpty) {
        Get.snackbar(
          'Validation',
          'Please enter price',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (isUnitPriceMasterSubmitting.value) return;
      isUnitPriceMasterSubmitting.value = true;

      Map<String, dynamic> data = {
        "stock_id": selectedStockId,
        "quantity":
            int.tryParse(unitPriceMasterQuantityController.text.trim()) ?? 1,
        "price":
            double.tryParse(unitPriceMasterPriceController.text.trim()) ?? 0.0,
      };

      final response = await expenseManagementRepo.addStockUnitPrice(data);

      if (response != null && response.statusCode == 200 ||
          response?.statusCode == 201) {
        await getExpensesWithoutUnitPrices();
        await getUnitPriceMasterList();
        resetUnitPriceMasterForm();
        Get.snackbar(
          'Success',
          'Unit price added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response?.body?['errors'][0] ?? 'Failed to add unit price',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("addUnitPriceMaster error: $e");
      Get.snackbar(
        'Error',
        'Failed to add unit price',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUnitPriceMasterSubmitting.value = false;
    }
  }

  Future<void> updateUnitPriceMaster(int id, String price) async {
    try {
      if (price.trim().isEmpty) {
        Get.snackbar(
          'Validation',
          'Please enter price',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (isUnitPriceMasterUpdating.value) return;
      isUnitPriceMasterUpdating.value = true;
      updatingUnitPriceMasterId.value = id;

      Map<String, dynamic> data = {
        "price": double.tryParse(price.trim()) ?? 0.0,
      };

      final response = await expenseManagementRepo.editStockUnitPrice(id, data);

      if (response != null && response.statusCode == 200) {
        updatingUnitPriceMasterId.value = -1;
        resetUnitPriceMasterForm();
        await getExpensesWithoutUnitPrices();
        await getUnitPriceMasterList();
        Get.snackbar(
          'Success',
          'Unit price updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("updateUnitPriceMaster error: $e");
      Get.snackbar(
        'Error',
        'Failed to update unit price',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUnitPriceMasterUpdating.value = false;
      updatingUnitPriceMasterId.value = -1;
    }
  }

  Future<void> deleteUnitPriceMaster(int id) async {
    try {
      if (isUnitPriceMasterDeleting.value) return;
      isUnitPriceMasterDeleting.value = true;

      final response = await expenseManagementRepo.deleteStockUnitPrice(id);

      if (response != null && response.statusCode == 200) {
        await getExpensesWithoutUnitPrices();
        await getUnitPriceMasterList();
        Get.snackbar(
          'Success',
          response.body?['message'] ?? 'Unit price deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      log("deleteUnitPriceMaster error: $e");
      Get.snackbar(
        'Error',
        'Failed to delete unit price',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUnitPriceMasterDeleting.value = false;
    }
  }

  void resetUnitPriceMasterForm() {
    unitPriceMasterPriceController.clear();
    unitPriceMasterQuantityController.clear();
    selectedStockId = null;
    selectedStockName = null;
    editingUnitPriceMasterId.value = -1;
  }

  void disposeUnitPriceMasterControllers() {
    unitPriceMasterPriceController.dispose();
    unitPriceMasterQuantityController.dispose();
  }

  // Method to get stock details by name
  Map<String, dynamic>? getStockDetailsByName(String stockName) {
    try {
      return masterList.firstWhere(
        (element) =>
            element["stock_title"].toString().toLowerCase() ==
            stockName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> exportUnitPriceMaster( {bool isSample = false}) async {
    try {
     isSample ? exportSampleLoader.value =true :isExportLoader.value = true ;
      update();

      print('============================ Exporting unit price stock data =============================');

      final data = {"type": "all"};
      Response? response =
          await expenseManagementRepo.exportUnitPriceMaster(data);

      if (response?.statusCode == 200 && response?.body != null) {
        var data = response?.body;

        String? downloadUrl = data['download_url'];

        String message = data['message'] ?? 'Unit Price exported successfully';

        if (downloadUrl != null && downloadUrl.isNotEmpty) {
          // Launch URL to download the file
          await appLaunchUrl(downloadUrl);

          Get.snackbar(
            'Exported Successfully',
            '$message',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 1),
          );
        } else {
          Get.snackbar(
            'Error',
            'Download URL not found',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        ApiChecker.checkApi(response!);
      }
    } catch (e) {
      print('Error exporting existing data: $e');
      Get.snackbar(
        'Error',
        'Failed to export unit price data',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
       isSample ? exportSampleLoader.value =false :isExportLoader.value = false ;
      update();
    }
  }

  Future<void> importUnitPriceMaster() async {
    try {
      isImportLoader.value = true;
      update();

      // Check if file is selected
      if (chooseFilePath == null || chooseFilePath!.isEmpty) {
        Get.snackbar(
          'Check Again',
          AppString.pleaseChooseFile,
          backgroundColor: ColorTheme.appColor,
          colorText: Colors.white,
        );
        return;
      }

      print('Importing unit price master from: $chooseFilePath');

      Response response = await expenseManagementRepo.importUnitPriceMaster(
          data: {},
          fileName: chooseFilePath ?? "",
          keyFileName: "stock_unit_price_file");

      if (response.statusCode == 200 && response.body != null) {
        var data = response.body;

        int imported = data['imported'] ?? 0;
        int updated = data['updated'] ?? 0;
        int totalProcessed = data['total'] ?? 0;
        String message = data['message'] ?? 'Unit Price imported successfully';

        // Clear file selection before going back
        chooseFilePath = null;
        ChooseFileController.clear();

        // Close the bulk import screen
        Get.back();

        // Show success message with details
        Get.snackbar(
          'Imported Successfully',
          '$message\nImported: $imported, Updated: $updated, Total: $totalProcessed',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );

        // Refresh the table list and area options
        await getUnitPriceMasterList();
      } else {
        ApiChecker.checkApi(response);
        // Clear file selection before going back
        chooseFilePath = null;
        ChooseFileController.clear();

        if (response.body != null && response.body['message'] != null) {
          Get.snackbar(
            'Error',
            response.body['message'].toString(),
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('Error importing unit price : $e');
    } finally {
      isImportLoader.value = false;
      update();
    }
  }

  //============================================== UNIT PRICE MASTER ==============================================//
}
