import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/admin/get_storage/get_storage.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/admin/widget/search_field.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/bottomsheet/vendor_form_sheet.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/controller/inventory_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ManageVendor extends StatefulWidget {
  @override
  State<ManageVendor> createState() => _ManageVendorState();
}

class _ManageVendorState extends State<ManageVendor> {
  InventoryController? inventoryController;

  @override
  void initState() {
    inventoryController = Get.find<InventoryController>();
    // authController = Get.find<AuthController>();

    menuApiCalling();
    super.initState();
  }

  menuApiCalling() async {
    Future.delayed(Duration.zero, () async {
      await inventoryController?.getVendor();
      // await inventoryController?.getRecipesIngredients();
    });
  }

  GetStoragePref getStoragePref = GetStoragePref();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: ColorTheme.whiteColor,
        appBar: AppBar(
          backgroundColor: ColorTheme.whiteColor,
          elevation: 0,
          // leading: IconButton(
          //   icon: Icon(Icons.menu, color: ColorTheme.appColor),
          //   onPressed: () {
          //     scaffoldKey.currentState?.openDrawer();
          //   },
          // ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: ColorTheme.appColor,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          actions: [
            IconButton(
                onPressed: () {
                  vendorForm(context,
                      inventoryController: inventoryController!,
                      isEdit: false,
                      vendorData: {});
                },
                icon: Icon(
                  Icons.add_circle_outline,
                  size: 30,
                  color: ColorTheme.appColor,
                ))
          ],
          titleSpacing: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Manage Vendor',
            style:
                poppinsMedium.copyWith(fontSize: 16, color: ColorTheme.black2E),
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: ColorTheme.grey200Color),
              child: CustomSearchField(
                onChanged: (p0) {
                  inventoryController?.update();
                },
                controller: inventoryController!.vendorSearchController,
                hitText: AppString.searchByVendor,
              ),
            ),
            // 20.height,
            Divider(
              height: 1,
              color: ColorTheme.whiteE7,
            ),
            Container(
              height: 40,
              child: Row(children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    height: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        15.width,
                        Text('Vendor', style: AppStyle.tx18mediumRed),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    // width: 20.w,
                    height: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            vertical: BorderSide(color: ColorTheme.whiteE7))),
                    child: Text('Edit', style: AppStyle.tx18mediumRed),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    // width: 25.w,
                    height: double.infinity,
                    alignment: Alignment.center,
                    child: Text('Action', style: AppStyle.tx18mediumRed),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: GetBuilder<InventoryController>(
                builder: (controller) {
                  var filteredVendorList =
                      controller.getVendorList.where((element) {
                    return element["vendor_name"]
                        .toString()
                        .toLowerCase()
                        .contains(controller.vendorSearchController.text
                            .toLowerCase());
                  }).toList();

                  return (inventoryController?.isvendorLoader ?? false)
                      ? Center(
                          child: Center(
                              child: CircularProgressIndicator(
                          backgroundColor: ColorTheme.whiteColor,
                          color: ColorTheme.greenColor,
                        )))
                      : (filteredVendorList.isNotEmpty ?? false)
                          ? ListView.builder(
                              itemCount: filteredVendorList.length,
                              itemBuilder: (context, index) {
                                final vendors = filteredVendorList[index];

                                return Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            color: ColorTheme.whiteE7),
                                        bottom: BorderSide(
                                            color: ColorTheme.whiteE7)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          height: double.infinity,
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              10.width,
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundColor:
                                                    ColorTheme.appColor,
                                                child: Icon(
                                                  Icons.person,
                                                  color: ColorTheme.white,
                                                ),
                                                // backgroundImage: NetworkImage(
                                                //     'https://randomuser.me/api/portraits/men/1.jpg'),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0, top: 0),
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: 120,
                                                        child: Text(
                                                          vendors['vendor_name'] ??
                                                              "",
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "Montserrat",
                                                            fontSize: 14,
                                                            color: ColorTheme
                                                                .foodValue,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
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
                                                  vertical: BorderSide(
                                                      color:
                                                          ColorTheme.whiteE7)),
                                            ),
                                            child: IconButton(
                                                onPressed: () {
                                                  vendorForm(context,
                                                      inventoryController:
                                                          inventoryController!,
                                                      isEdit: true,
                                                      id: vendors['id'],
                                                      vendorData: vendors);
                                                },
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: ColorTheme.green,
                                                ))),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          height: double.infinity,
                                          alignment: Alignment.center,
                                          // child: IconButton(
                                          //     onPressed: () {
                                          // controller.deleteVendor(
                                          //     id: vendors['id']);
                                          //     },
                                          //     icon: Icon(
                                          //       Icons.delete,
                                          //       color: const Color.fromARGB(
                                          //           255, 243, 102, 102),
                                          //     )),
                                          child: GestureDetector(
                                            onTap: () {
                                              controller.deleteVendor(
                                                  id: vendors['id']);
                                            },
                                            child: SizedBox(
                                              width: 18,
                                              child: SvgPicture.asset(
                                                  Images.deleteIcon),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Center(child: Text(AppString.noDataFound));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
