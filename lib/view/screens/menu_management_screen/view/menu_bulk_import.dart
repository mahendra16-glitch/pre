import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/widget/my_custom_button.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/settlement/widget/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class BulkImportScreen extends StatefulWidget {
  bool isFunction;
  String? tittleName;
  void Function()? onuploadTap;
  void Function()? onDownloadExistingDataTap;
  void Function()? onDownloadSampleDataTap;
  dynamic controller;

  BulkImportScreen(
      {Key? key,
      this.tittleName,
      this.onuploadTap,
      this.onDownloadExistingDataTap,
      this.onDownloadSampleDataTap,
      required this.controller,
      this.isFunction = false})
      : super(key: key);

  @override
  State<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends State<BulkImportScreen> {
  // MenuManagementController? menuController;

  @override
  void initState() {
    widget.controller?.chooseFilePath = null;
    widget.controller?.ChooseFileController.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        backgroundColor: ColorTheme.grey200Color,
        appBar: CustomAppBar(
          titleText: widget.tittleName ?? '',
        ),
        body: GetBuilder<GetxController>(
          init: widget.controller as GetxController,
          builder: (_) => Container(
            color: ColorTheme.whiteColor,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      10.height,
                      Text(
                        AppString.downloadSpreadsheetTemplate,
                        style: AppStyle.txt14FoodValue.copyWith(
                            fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                      20.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Obx(
                            () => MyCustomButton(
                              isLoader:
                                  widget.controller!.exportSampleLoader.value,
                              height: 42,
                              text: AppString.sampleTemplate,
                              onTap: () async {
                                if (widget.isFunction &&
                                    widget.onDownloadSampleDataTap != null) {
                                  widget.onDownloadSampleDataTap!();
                                } else {
                                  widget.controller.exportSample();
                                }
                              },
                              style: AppStyle.orangeButtonStyle
                                  .copyWith(fontSize: 10),
                            ),
                          )),
                          10.width,
                          Expanded(
                              child: Obx(
                            () => MyCustomButton(
                              height: 42,
                              isLoader: widget.controller?.isExportLoader.value,
                              text: AppString.templateWithExistingData,
                              onTap: () async {
                                if (widget.isFunction &&
                                    widget.onDownloadExistingDataTap != null) {
                                  widget.onDownloadExistingDataTap!();
                                } else {
                                  widget.controller.bulkExport();
                                }
                              },
                              style: AppStyle.orangeButtonStyle
                                  .copyWith(fontSize: 10),
                            ),
                          )),
                        ],
                      ),
                      20.height,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: widget.controller.chooseFileLoader
                            ? AppLoader()
                            : Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.10,
                                child: CustomTextformField(
                                  controller:
                                      widget.controller!.ChooseFileController,
                                  onTap: () async {
                                    await widget.controller?.pickExcelFile();
                                  },
                                  readOnly: true,
                                  labelText: AppString.chooseFile,
                                )),
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 15),
                ),
                Row(
                  children: [
                    GetBuilder<GetxController>(
                      init: widget.controller as GetxController,
                      builder: (_) => Expanded(
                        child: InkWell(
                          onTap: () {
                            widget.controller?.ChooseFileController.clear();
                            widget.controller?.chooseFilePath = null;
                            FocusManager.instance.primaryFocus?.unfocus();
                            widget.controller?.update();
                          },
                          child: Container(
                            height: 50,
                            color: ColorTheme.greyColor.withOpacity(0.2),
                            alignment: Alignment.center,
                            child: Text(AppString.Reset),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Obx(
                        () => InkWell(
                          onTap: () async {
                            if (widget.isFunction &&
                                widget.onuploadTap != null) {
                              widget.onuploadTap!();
                            } else {
                              widget.controller.bulkImport();
                            }
                          },
                          child: Container(
                            height: 50,
                            color: ColorTheme.greenColor,
                            alignment: Alignment.center,
                            child: widget.controller!.isImportLoader.value
                                ? SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 30.0,
                                  )
                                : Text(AppString.import,
                                    style: TextStyle(
                                        color: ColorTheme.whiteColor,
                                        fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
