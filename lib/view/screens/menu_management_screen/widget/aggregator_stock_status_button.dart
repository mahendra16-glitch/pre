import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/dialog/disable_aggregator_stock_dialog.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/dialog/offline_aggregator_stock_dialog.dart';

class AggregatorStockStatusButton extends StatelessWidget {
  final Map<String, dynamic> food;

  const AggregatorStockStatusButton({super.key, required this.food});

  static const Color _liveGreen = Color(0xFF22C55E);
  static const Color _offlineOrange = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MenuManagementController>();
    final isLive = controller.isAggregatorFoodLive(food);
    final color = isLive ? _liveGreen : _offlineOrange;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (isLive) {
            showDisableAggregatorStockDialog(context, food);
          } else {
            showOfflineAggregatorStockDialog(context, food);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: ColorTheme.whiteColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 1.4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isLive ? 'Live' : 'Offline',
                style: poppinsMedium.copyWith(
                  fontSize: 12.5,
                  color: color,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
