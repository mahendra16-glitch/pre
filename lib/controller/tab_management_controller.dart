import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/model/response/get_collect_bill_resoonse_model.dart';
import 'package:mygenie_restaurant/data/model/response/get_view_tab_bill_response.dart';
import 'package:mygenie_restaurant/data/model/response/tap_managment_reesponse_model.dart';
import 'package:mygenie_restaurant/data/repository/tab_management_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TabManagementController extends GetxController implements GetxService {
  final TabManagementRepo tabManagementRepo;
  TabManagementController({required this.tabManagementRepo});

  GetViewTabBillsResponseModel? _getViewTabBillsResponseModel;
  TapManagmentCustomerListResponse? _tapManagmentCustomerListResponse;

  bool _isLoading = false;
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  bool get isLoading => _isLoading;
  GetViewTabBillsResponseModel? get getViewTabBillsResponseModel =>
      _getViewTabBillsResponseModel;
  TapManagmentCustomerListResponse? get tapManagmentCustomerListResponse =>
      _tapManagmentCustomerListResponse;
  Future getTapManageMentCustomerList() async {
    Response response =
        await tabManagementRepo!.getTapManageMentCustomerList({});
    if (response.statusCode == 200) {
      _tapManagmentCustomerListResponse =
          TapManagmentCustomerListResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future getViewTabBills(String id) async {
    _isLoading = true;
    update();
    Response response = await tabManagementRepo!.getViewTabBills(id);
    _isLoading = false;

    if (response.statusCode == 200) {
      _getViewTabBillsResponseModel =
          GetViewTabBillsResponseModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void setProcessing(bool value) {
    _isProcessing = value;
    update();
  }

  List<OrderDetailsBar> mergeFoodItems(List<OrderDetailsBar> foodItems,
      {String? type}) {
    Map<String, OrderDetailsBar> mergedItems = {};

    // Iterate through the original list and merge items
    for (var item in foodItems) {
      String variationText = '';
      String createDate =
          '${DateFormat('dd-MMM-yyyy').format(DateTime.parse(item.createdAt!))}';
      if (item.variation != null && item.variation!.isNotEmpty) {
        for (int j = 0; j < item.variation!.length; j++) {
          variationText +=
              '${variationText.isNotEmpty ? ', ' : ''}${item.variation![j].name} (';

          if (item.variation![j].values != null) {
            List<String> labelList = [];
            for (var element in item.variation![j].values!) {
              labelList.add(element.level!);
            }
            variationText +=
                '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
          }

          variationText += ')';
        }
      }

      String addons = '';
      for (var i = 0; i < item.addOns!.length; i++) {
        addons += '${item.addOns![i].name} (${item.addOns![i].quantity})';
      }
      if (item.foodStatus == 3) {
        mergedItems['${item.foodId}, $variationText, $addons, ${item.id}'] =
            item;
      } else {
        if (double.parse('${item.foodDetails!['price'] ?? '1'}') != 1) {
          if (mergedItems.containsKey(type == 'date'
              ? '${item.foodId}, $variationText, $addons, $createDate'
              : '${item.foodId}, $variationText, $addons')) {
            // If the item is already in the merged map, add the quantities
            // item.quantity = item.quantity +
            //     mergedItems['${item.foodId}, $variationText, $addons'].quantity;
            mergedItems[
                type == 'date'
                    ? '${item.foodId}, $variationText, $addons, $createDate'
                    : '${item.foodId}, $variationText, $addons'] = OrderDetailsBar(
                addOns: item.addOns,
                createdAt: item.createdAt,
                foodDetails: item.foodDetails,
                foodId: item.foodId,
                discountOnFood: item.discountOnFood,
                discountType: item.discountType,
                foodStatus: item.foodStatus,
                gstTaxAmount: item.gstTaxAmount,
                id: item.id,
                itemCampaignId: item.itemCampaignId,
                orderId: item.orderId,
                price: item.price,
                totalAddOnPrice: item.totalAddOnPrice,
                unitPrice: item.unitPrice,
                variation: item.variation,
                quantity: item.quantity! +
                    mergedItems[type == 'date'
                            ? '${item.foodId}, $variationText, $addons, $createDate'
                            : '${item.foodId}, $variationText, $addons']!
                        .quantity!);
          } else {
            // If the item is not in the merged map, add it with its quantity
            mergedItems[type == 'date'
                ? '${item.foodId}, $variationText, $addons, $createDate'
                : '${item.foodId}, $variationText, $addons'] = item;
          }
        } else {
          mergedItems['${item.foodId}, $variationText, $addons, ${item.id}'] =
              item;
        }
      }
    }

    // Create a new list of FoodItems from the merged map
    List<OrderDetailsBar> mergedFoodItems = [];
    mergedItems.forEach((name, data) {
      // print('ppppppppp${quantity.quantity}');
      mergedFoodItems.add(data);
    });

    return mergedFoodItems;
  }

  Future<void> collectTapPayment(Function callback,
      {Map<String, dynamic>? jsonData}) async {
    _isLoading = true;
    update();

    Response response;

    response = await tabManagementRepo!.collectTapPayment(jsonData!);

    _isLoading = false;
    if (response.statusCode == 200) {
      String message = response.body['message'];
      // orderRepo.sendNotificationRequest(orderID);
      callback(true, message);
      if (kDebugMode) {
        // print('-------- Order placed successfully $orderID ----------');
      }
    } else {
      callback(false, response.statusText);
    }
    update();
  }
}
