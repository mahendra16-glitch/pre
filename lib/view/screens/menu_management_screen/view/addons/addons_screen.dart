import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/admin/widget/search_field.dart';
import 'package:mygenie_restaurant/admin/widget/upload_icon/upload_icon.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/bottom_sheet/add_addons_sheet.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/dialog/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_bulk_import.dart';

class AddonsScreen extends StatefulWidget {
  const AddonsScreen({Key? key}) : super(key: key);

  @override
  State<AddonsScreen> createState() => _AddonsScreenState();
}

class _AddonsScreenState extends State<AddonsScreen> {
  MenuManagementController? menuManagementController;

  @override
  void initState() {
    menuManagementController = Get.find<MenuManagementController>();
    addonCallApi();
    super.initState();
  }

  addonCallApi() async {
    await menuManagementController?.getAddonList();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        backgroundColor: ColorTheme.grey200Color,
        appBar: CustomAppBar(
          titleText: AppString.addons,
          actions: [
            uploadIconWidget(
              onDownLoadTap: () async {
                // await menuManagementController?.exportWithoutAddon();
                Get.to(() => BulkImportScreen(
                      tittleName: 'Addons',
                      controller: Get.find<MenuManagementController>(),
                      isFunction: true,
                      onDownloadSampleDataTap: () {
                        menuManagementController?.exportAddonSample();
                      },
                      onDownloadExistingDataTap: () {
                        menuManagementController?.exportWithoutAddon();
                      },
                      onuploadTap: () {
                        menuManagementController?.importAddon();
                      },
                    ));
              },
              onUploadTap: () async {
                // await menuManagementController?.importAddon();
                Get.to(() => BulkImportScreen(
                      tittleName: 'Addons',
                      controller: Get.find<MenuManagementController>(),
                      isFunction: true,
                      onDownloadSampleDataTap: () {
                        menuManagementController?.exportAddonSample();
                      },
                      onDownloadExistingDataTap: () {
                        menuManagementController?.exportWithoutAddon();
                      },
                      onuploadTap: () {
                        menuManagementController?.importAddon();
                      },
                    ));
              },
              isPLusShow: true,
              onPlusTap: () {
                addAddonsSheet(context, menuManagementController!,
                    onTap: menuManagementController!.isAddonsSubmitting.value
                        ? null
                        : () async {
                            if (menuManagementController!
                                .addAddonsFormKey.currentState!
                                .validate()) {
                              await menuManagementController!.addAddons();
                            }
                          },
                    menuAddons: {});
              },
            ).paddingOnly(right: 5),
          ],
        ),
        body: Column(
          children: [
            15.height,
            CustomSearchField(
              onChanged: (p0) {
                menuManagementController?.update();
              },
              controller: menuManagementController!.addonsSearchController,
              hitText: AppString.search,
            ).paddingSymmetric(horizontal: 20),
            15.height,
            Container(
              height: 40,
              color: ColorTheme.whiteColor,
              child: Row(children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    height: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        15.width,
                        Text(AppString.name, style: AppStyle.tx18mediumRed),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            vertical: BorderSide(color: ColorTheme.whiteE7))),
                    child: Text(AppString.price, style: AppStyle.tx18mediumRed),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: double.infinity,
                    alignment: Alignment.center,
                    child:
                        Text(AppString.status, style: AppStyle.tx18mediumRed),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            vertical: BorderSide(color: ColorTheme.whiteE7))),
                    child:
                        Text(AppString.action, style: AppStyle.tx18mediumRed),
                  ),
                ),
              ]),
            ),
            Expanded(child: GetBuilder<MenuManagementController>(
              builder: (controller) {
                var filteredMenuAddonsList =
                    menuManagementController!.addonList.where((element) {
                  return element["name"].toString().toLowerCase().contains(
                      menuManagementController!.addonsSearchController.text
                          .toLowerCase());
                }).toList();

                return menuManagementController!.isAddonLoader.value
                    ? AppLoader()
                    : filteredMenuAddonsList.isNotEmpty
                        ? Container(
                            color: ColorTheme.whiteColor,
                            child: ListView.builder(
                              itemCount: filteredMenuAddonsList.length ?? 0,
                              itemBuilder: (context, index) {
                                final menuAddons =
                                    filteredMenuAddonsList[index];
                                return Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            color: ColorTheme.whiteE7)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                            width: double.infinity,
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20.0, top: 7),
                                              child: Text(
                                                menuAddons["name"],
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Montserrat",
                                                  fontSize: 13.7,
                                                  color: ColorTheme.foodValue,
                                                ),
                                              ),
                                            )),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          height: double.infinity,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border.symmetric(
                                              vertical: BorderSide(
                                                  color: ColorTheme.whiteE7),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 7),
                                            child: Center(
                                              child: Text(
                                                "₹ ${menuAddons["price"].toString()}",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Montserrat",
                                                  fontSize: 13,
                                                  color: ColorTheme.foodValue,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          height: double.infinity,
                                          alignment: Alignment.center,
                                          child: Transform.scale(
                                            scale: 0.7,
                                            child: Switch(
                                              inactiveTrackColor:
                                                  ColorTheme.switchITrackColor,
                                              inactiveThumbColor:
                                                  ColorTheme.switchIThumbColor,
                                              value: menuAddons['status'] == 1
                                                  ? true
                                                  : false,
                                              onChanged: (value) {
                                                final data = {
                                                  "status": value ? 1 : 0
                                                };
                                                menuManagementController
                                                    ?.addonStatusChange(
                                                        menuAddons['id'],
                                                        data: data);
                                              },
                                              activeColor: ColorTheme.green,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.symmetric(
                                                vertical: BorderSide(
                                                    color: ColorTheme.whiteE7)),
                                          ),
                                          height: double.infinity,
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  addAddonsSheet(context,
                                                      menuManagementController!,
                                                      onTap: menuManagementController!
                                                              .isAddonsSubmitting
                                                              .value
                                                          ? null
                                                          : () async {
                                                              if (menuManagementController!
                                                                  .addAddonsFormKey
                                                                  .currentState!
                                                                  .validate()) {
                                                                await menuManagementController!
                                                                    .updateAddon(
                                                                        menuAddons[
                                                                            "id"]);
                                                              }
                                                            },
                                                      menuAddons: menuAddons,
                                                      isEdit: true);
                                                },
                                                child: Container(
                                                  height: 20,
                                                  width: 20,
                                                  child: SvgPicture.asset(
                                                      Images.Edit,
                                                      color: ColorTheme.green,
                                                      width: 20.7),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Get.bottomSheet(
                                                      confirmationDialog(
                                                    confirmDescriptionText:
                                                        "${AppString.areYouSureDelete} ${menuAddons["name"]}",
                                                    onYesTap: () async {
                                                      await menuManagementController
                                                          ?.deleteAddon(
                                                              menuAddons["id"]);
                                                    },
                                                  ));
                                                },
                                                child: Container(
                                                  height: 20,
                                                  width: 20,
                                                  child: SvgPicture.asset(
                                                    Images.deleteIcon,
                                                    width: 20.7,
                                                    color:
                                                        ColorTheme.greenColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(child: Text(AppString.noDataFound));
                ;
              },
            ))
          ],
        ),
      ),
    );
  }
}
