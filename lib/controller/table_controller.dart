import 'dart:convert';

import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/model/response/table_response_model.dart';
import '../data/repository/table_repo.dart';

class TableController extends GetxController implements GetxService {
  final TableRepo tableRepo;
  TableController({required this.tableRepo});

  List<TableResponseModel> _tableList = [];
  List<TableResponseModel> _allTableList = [];
  List<TableResponseModel> _searchTableList = [];
  TableResponseModel? _selectedTable;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<TableResponseModel> get tableList => _tableList;
  List<TableResponseModel> get allTableList => _allTableList;
  List<TableResponseModel> get searchTableList => _searchTableList;
  TableResponseModel? get selectedTable => _selectedTable;

  Future<void> getAllTableList() async {
    Response response = await tableRepo.getTableList();
    if (response.statusCode == 200) {
      _allTableList = [];
      for (var table in response.body) {
        if (table['rtype'] == 'TB') {
          _allTableList.add(TableResponseModel.fromJson(table));
          for (var e in _tableList) {
            if (e.id == table['id']) {
              e.isEngage = table['engage'] ?? 'No';
              break;
            }
          }
        }
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<Response> saveTableListLocally() async {
    Response response = await tableRepo.getTableList();
    if (response.statusCode == 200) {
      List<TableResponseModel> tempTableList = [];
      Restaurant restaurant =
          Get.find<AuthController>().profileModel!.restaurants!.first;

      if (restaurant.isDineIn == 'Yes')
        tempTableList.add(TableResponseModel(
            id: 0, tableNo: 'Select Table', title: '', isEngage: 'No'));
      if (restaurant.takeAway!) {
        tempTableList.add(TableResponseModel(
            id: 0, tableNo: 'Take Away', title: '', isEngage: 'No'));
      }
      if (restaurant.delivery!) {
        tempTableList.add(TableResponseModel(
            id: 0, tableNo: 'Delivery', title: '', isEngage: 'No'));
      }
      for (var table in response.body) {
        if (table['rtype'] == 'TB' ||
            Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .settings!
                    .autoPaid ==
                'Yes') {
          tempTableList.add(TableResponseModel.fromJson(table));
        }
      }
      List<String> tableListJson =
          tempTableList.map((table) => jsonEncode(table.toJson())).toList();
      tableRepo.saveTableLocal(tableListJson);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  Future<void> getTableListFromLocally() async {
    List<String> tableListJson = tableRepo.getTableListFromLocal();
    _tableList = [];
    if (tableListJson.isNotEmpty) {
      _tableList = tableListJson
          .map((jsonString) =>
              TableResponseModel.fromJson(jsonDecode(jsonString)))
          .toList();
    }
    update();
    await getAllTableList();
  }

  getWaiterOrderListForTableView() async {
    _isLoading = true;
    List<OrderList> _orderList =
        Get.find<KdsController>().getWaiterOrderListResponse?.orders ?? [];
    for (var order in _orderList) {
      if (order.restaurantTable != null && order.restaurantTable!.id != null) {
        allTableList.forEach((table) {
          if (table.id == order.restaurantTable!.id) {
            table.order = order;
          }
        });
      } else if (order.restaurantTable == null &&
          (order.orderType == 'pos' ||
              order.orderType == 'WalkIn' ||
              order.orderType == 'dinein')) {
        allTableList.add(TableResponseModel(
          id: 0,
          isEngage: 'Yes',
          order: order,
          tableNo: order.userName == ''
              ? 'WC'
              : (order.userName.length >= 2
                  ? order.userName.substring(0, 2)
                  : order.userName),
        ));
      }
    }
    _isLoading = false;

    update();
  }

  updateTableViewData(OrderList order, {bool? isAdd}) async {
    int? index;
    if (order.restaurantTable != null) {
      allTableList.forEach((table) {
        if (table.id == order.restaurantTable!.id) {
          if (order.fOrderStatus == 6 || order.fOrderStatus == 3) {
            table.isEngage = 'No';
          } else {
            table.isEngage = 'Yes';
          }
          table.order = (order.fOrderStatus == 6 || order.fOrderStatus == 3)
              ? null
              : order;
        }
      });
    } else {
      if (isAdd == true) {
        allTableList.add(TableResponseModel(
          id: 0,
          isEngage: 'Yes',
          order: order,
          title: '',
          tableNo: order.userName == ''
              ? 'WC'
              : (order.userName.length >= 2
                  ? order.userName.substring(0, 2)
                  : order.userName),
        ));
      }
      {
        allTableList.forEach((table) {
          if (table.order != null && table.order!.id == order.id) {
            if (order.fOrderStatus == 6 || order.fOrderStatus == 3) {
              table.isEngage = 'No';
            } else {
              table.isEngage = 'Yes';
            }

            if (order.fOrderStatus == 6 || order.fOrderStatus == 3) {
              index = allTableList.indexOf(table);
            } else {
              table.order = order;
            }
          }
        });
        if (index != null) allTableList.removeAt(index!);
      }
    }

    update();
  }

  switchTableForTableView(TableResponseModel emptyTable,
      TableResponseModel engageTable, OrderList? order) async {
    // allTableList.forEach((table) {
    //   if (table.tableNo == order.restaurantTable!.tableNo) {
    //     if (order.fOrderStatus == 6 || order.fOrderStatus == 3) {
    //       table.isEngage = 'No';
    //     } else {
    //       table.isEngage = 'Yes';
    //     }
    //     table.order =
    //         (order.fOrderStatus == 6 || order.fOrderStatus == 3) ? null : order;
    //   }
    // });
    emptyTable.isEngage = 'Yes';
    engageTable.isEngage = 'No';
    if (order != null) emptyTable.order = order;
    engageTable.order = null;

    update();
  }

  Future<void> setValueOfTableFromSocket(
      {required String tableId, required String value}) async {
    for (var e in _tableList) {
      if (tableId == e.id.toString()) {
        e.isEngage = value;
      }
    }
    update();
  }

  Future<List<TableResponseModel>> searchTable(
      BuildContext context, String text) async {
    _searchTableList = [];
    if (text.isNotEmpty) {
      for (var prediction in _tableList) {
        if (prediction.tableNo.toLowerCase().contains(text.toLowerCase()) &&
            prediction.isEngage != 'Yes') {
          _searchTableList.add(prediction);
        }
      }
    }
    return _searchTableList.isEmpty
        ? _tableList.where((element) => element.isEngage != 'Yes').toList()
        : _searchTableList;
  }

  Future<void> changeTable(
      String type, Map<String, dynamic> body, Function(bool) callback) async {
    showToast('Please wait..');
    Get.find<LoadingController>().startLoading(true);
    Response response = await tableRepo.changeTable(body);
    Get.find<LoadingController>().startLoading(false);
    if (response.statusCode == 200) {
      callback(true);
      await Get.find<LoadingController>().changeText(
          data: type == 'RM'
              ? 'Room change successfully'
              : 'Table change successfully');
      await Get.find<LoadingController>().changeStatus(data: true);
    } else {
      callback(false);
      ApiChecker.checkApi(response);
    }
    update();
  }

  void clearTableList() {
    _selectedTable = null;
    _tableList = [];
    update();
  }

  void setTableIndex(TableResponseModel? table) {
    _selectedTable = table;
    update();
  }
}
