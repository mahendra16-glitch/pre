import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/widget/aggregator_stock_popover.dart';

void showOfflineAggregatorStockDialog(
  BuildContext buttonContext,
  Map<String, dynamic> food,
) {
  showAggregatorStockPopover(
    buttonContext: buttonContext,
    child: OfflineAggregatorStockDialog(food: food),
  );
}

class OfflineAggregatorStockDialog extends StatelessWidget {
  final Map<String, dynamic> food;

  const OfflineAggregatorStockDialog({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MenuManagementController>();
    final backAt = controller.formatAggregatorBackAt(food['turn_on_at']);

    return Material(
      color: ColorTheme.whiteColor,
      elevation: 8,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Item is offline',
                style: poppinsSemiBold.copyWith(
                  fontSize: 15,
                  color: ColorTheme.blackColor,
                ),
              ),
              if (backAt != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Back at $backAt',
                  style: poppinsMedium.copyWith(
                    fontSize: 13,
                    color: ColorTheme.greenColor,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () async {
                    final itemId = controller.parseFoodId(food['id']);
                    if (itemId == null) {
                      appToast('Invalid item');
                      return;
                    }
                    Navigator.of(context).pop();
                    await controller.aggregatorStockToggle(
                      itemId: itemId,
                      action: 'enable',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTheme.greenColor,
                    foregroundColor: ColorTheme.whiteColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Enable Now',
                    style: poppinsMedium.copyWith(
                      fontSize: 13.5,
                      color: ColorTheme.whiteColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
