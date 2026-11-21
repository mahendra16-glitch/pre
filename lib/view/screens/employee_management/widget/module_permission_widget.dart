// import 'dart:io';

// import 'package:mygenie_restaurant/view/screens/employee_management/controller/role_management_controller.dart';
// import 'package:mygenie_restaurant/view/screens/employee_management/response/get_all_role_types_modules_model.dart';
// import 'package:mygenie_restaurant/helper/colors.dart';
// import 'package:mygenie_restaurant/util/styles.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:get/get_state_manager/src/simple/get_state.dart';

// class modulePermissionWidget extends StatefulWidget {
//   final String moduleName;
//   final List<RoleModule> moduleList;
//   final List<bool> isModuleCheckList;
//   final Function onModuleSelected;

//   modulePermissionWidget(
//       {Key? key,
//       required this.moduleName,
//       required this.moduleList,
//       required this.isModuleCheckList,
//       required this.onModuleSelected});

//   @override
//   State<modulePermissionWidget> createState() => _modulePermissionWidgetState();
// }

// class _modulePermissionWidgetState extends State<modulePermissionWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<RoleManagementController>(
//         builder: (roleManagementController) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(0),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 15),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Text(
//                 '${widget.moduleName} Module Permission',
//                 style:
//                     poppinsBold.copyWith(color: ColorTheme.grey1, fontSize: 14),
//               ),
//             ),
//             SizedBox(height: 10),
//             Divider(
//               color: ColorTheme.grey1,
//             ),
//             SizedBox(height: 0),
//             // roleManagementController.selectedRole == 'Manager' ?
//             Padding(
//               padding:
//                   EdgeInsets.symmetric(horizontal: Platform.isWindows ? 30 : 0),
//               child: GridView.builder(
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemCount: widget.moduleList.length,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: Platform.isWindows ? 5 : 2, // 2 items per row
//                   mainAxisSpacing: 10,
//                   crossAxisSpacing: 10,
//                   childAspectRatio: 4, // adjust as needed
//                 ),
//                 itemBuilder: (context, index) {
//                   final Module = widget.moduleList[index];
//                   final isModuleChecked = widget.isModuleCheckList[index];
//                   return Row(
//                     children: [
//                       Checkbox(
//                         value: isModuleChecked,
//                         onChanged: (value) {
//                           widget.isModuleCheckList[index] = value ?? false;
//                           roleManagementController.update();
//                           widget.onModuleSelected();

//                           print(
//                               'Checkbox $index tapped: $value , name: ${Module.name}');
//                         },
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         activeColor: Colors.blue,
//                         side: BorderSide(
//                             color: isModuleChecked
//                                 ? Colors.blue
//                                 : ColorTheme.grey1,
//                             width: 2),
//                       ),
//                       Expanded(
//                         child: Text(
//                           Module.name.toLowerCase() ?? '',
//                           style: poppinsMedium.copyWith(
//                               color: ColorTheme.grey1, fontSize: 14),
//                           overflow: TextOverflow.visible,
//                           maxLines: 3,
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//             // : Padding(
//             //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
//             //     child: Text(
//             //       'Select Role Type for more details',
//             //       style: poppinsMedium.copyWith(
//             //           color: ColorTheme.borderGrey, fontSize: 15),
//             //     ),
//             //   ),
//             SizedBox(height: 15),
//           ],
//         ),
//       );
//     });
//   }
// }

import 'dart:io';

import 'package:mygenie_restaurant/view/screens/employee_management/controller/role_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/response/get_all_role_types_modules_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class modulePermissionWidget extends StatefulWidget {
  final String moduleName;
  final List<RoleModule> moduleList;
  final List<bool> isModuleCheckList;
  final Function onModuleSelected;
  final Set<String>? coreModuleSet;

  modulePermissionWidget(
      {Key? key,
      required this.moduleName,
      required this.moduleList,
      required this.isModuleCheckList,
      required this.onModuleSelected,
      this.coreModuleSet});

  @override
  State<modulePermissionWidget> createState() => _modulePermissionWidgetState();
}

class _modulePermissionWidgetState extends State<modulePermissionWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoleManagementController>(
        builder: (roleManagementController) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 15),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
            //   child: Text(
            //     '${widget.moduleName} Module Permission',
            //     style:
            //         poppinsBold.copyWith(color: ColorTheme.grey1, fontSize: 14),
            //   ),
            // ),
            // SizedBox(height: 10),
            // Divider(
            //   color: ColorTheme.grey1,
            // ),
            // SizedBox(height: 0),
            // roleManagementController.selectedRole == 'Manager' ?
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Platform.isWindows ? 30 : 0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.moduleList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Platform.isWindows ? 5 : 2, // 2 items per row
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 4, // adjust as needed
                ),
                itemBuilder: (context, index) {
                  final Module = widget.moduleList[index];
                  final isModuleChecked = widget.isModuleCheckList[index];
                  final moduleValue = Module.rolePassValue.toLowerCase();
                  final isCore =
                      widget.coreModuleSet?.contains(moduleValue) ?? false;
                  return Row(
                    children: [
                      Checkbox(
                        value: isCore ? true : isModuleChecked,
                        onChanged: isCore
                            ? null
                            : (value) {
                                widget.isModuleCheckList[index] =
                                    value ?? false;
                                roleManagementController.update();
                                widget.onModuleSelected();

                                print(
                                    'Checkbox $index tapped: $value , name: ${Module.name}');
                              },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        activeColor: Colors.blue,
                        side: BorderSide(
                            color: isModuleChecked
                                ? Colors.blue
                                : ColorTheme.grey1,
                            width: 2),
                      ),
                      Expanded(
                        child: Text(
                          Module.name.toLowerCase() ?? '',
                          style: montserratMedium.copyWith(
                              color: ColorTheme.grey1, fontSize: 14),
                          overflow: TextOverflow.visible,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // : Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
            //     child: Text(
            //       'Select Role Type for more details',
            //       style: poppinsMedium.copyWith(
            //           color: ColorTheme.borderGrey, fontSize: 15),
            //     ),
            //   ),
            SizedBox(height: 15),
          ],
        ),
      );
    });
  }
}
