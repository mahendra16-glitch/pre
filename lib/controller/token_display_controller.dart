import 'package:get/get.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/model/response/get_token_display_response_model.dart';
import 'package:mygenie_restaurant/data/repository/token_display_repo.dart';

class TokenDisplayController extends GetxController implements GetxService {
  final TokenDisplayRepo tokenDisplayRepo;
  TokenDisplayController({required this.tokenDisplayRepo});

  bool _isLoading = false;
  String orderIdFromSocket = '';

  bool get isLoading => _isLoading;
  List<TokenEmployeeList> order = [];
  Future<void> fetchOrders() async {
    _isLoading = true;
    update();
    try {
      final response = await tokenDisplayRepo.getOrderList();
      order = [];
      _isLoading = false;
      update();
      if (response.statusCode == 200) {
        GetTokenDisplayResponseModel tokenDisplayResponseModel =
            GetTokenDisplayResponseModel.fromJson(response.body);
        order = tokenDisplayResponseModel.tokenEmployeeList ?? [];
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  clearOrderList() {
    order.clear();
    update();
  }

  Future getOrderDetailFromSocket({String? type, String? orderId}) async {
    Response response =
        await tokenDisplayRepo.getOrderDetailFromSocket('$orderId');
    GetTokenDisplayResponseModel jsonData =
        GetTokenDisplayResponseModel.fromJson(response.body);
    if (response.statusCode == 200) {
      if (jsonData.tokenEmployeeList != null &&
          jsonData.tokenEmployeeList!.isNotEmpty) {
        if (type == 'new-order') {
          order.addAll(jsonData.tokenEmployeeList!);
        } else if (type == 'update-order' ||
            type == 'update-food-status' ||
            type == 'update-item-status' ||
            type == 'scan-new-order' ||
            type == 'update-order-status') {
          upsertOrders(
            updatedOrders: jsonData.tokenEmployeeList!,
          );
        }
        // if (type == 'update-order' ||
        //     type == 'update-food-status' ||
        //     type == 'scan-new-order' ||
        //     type == 'update-order-status') {
        //   int? index;

        //   for (int i = 0; i < order.length; i++) {
        //     if ((order[i].orderId == jsonData.tokenEmployeeList?[0].orderId) &&
        //         (order[i].stationName ==
        //             jsonData.tokenEmployeeList?[0].stationName)) {
        //       index = i;
        //       if (type == 'update-order-status') {
        //         order[index] = jsonData.tokenEmployeeList!.first;
        //       }
        //     } else if ((jsonData.tokenEmployeeList!.length == 2 &&
        //             order[i].orderId ==
        //                 jsonData.tokenEmployeeList?[1].orderId) &&
        //         (jsonData.tokenEmployeeList!.length == 2 &&
        //             order[i].stationName ==
        //                 jsonData.tokenEmployeeList?[1].stationName)) {
        //       index = i;
        //       if (type == 'update-order-status') {
        //         order[index] = jsonData.tokenEmployeeList!.last;
        //       }
        //     }
        //   }

        //   if (type == 'update-order' && index == null) {
        //     order.addAll(jsonData.tokenEmployeeList!);
        //   } else if ((type == 'update-order' ||
        //           type == 'update-food-status' ||
        //           type == 'scan-new-order') &&
        //       index != null) {
        //     order[index] = jsonData.tokenEmployeeList!.first;
        //   }
        // } else if (type == 'new-order') {
        //   order.addAll(jsonData.tokenEmployeeList!);
        // }
      }
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  void upsertOrders({
    required List<TokenEmployeeList> updatedOrders,
  }) {
    if (updatedOrders.isEmpty) return;

    // 1️⃣ Group updated orders by orderId
    final Map<int, List<TokenEmployeeList>> updatesByOrderId = {};
    for (final item in updatedOrders) {
      updatesByOrderId.putIfAbsent(item.orderId!, () => []).add(item);
    }

    // 2️⃣ Process each orderId group
    for (final entry in updatesByOrderId.entries) {
      final orderId = entry.key;
      final updatedGroup = entry.value;

      // Find first index of this orderId in full list
      final startIndex = order.indexWhere((e) => e.orderId == orderId);

      if (startIndex != -1) {
        // Replace existing group at same position
        final oldCount = order.where((e) => e.orderId == orderId).length;
        order.replaceRange(startIndex, startIndex + oldCount, updatedGroup);
      } else {
        // Add new order at the end
        order.addAll(updatedGroup);
      }
    }
    update();
  }
}
