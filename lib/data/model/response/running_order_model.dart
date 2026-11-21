import 'package:mygenie_restaurant/data/model/response/order_model.dart';

class RunningOrderModel {
  final String status;
  List<OrderModel> orderList;

  RunningOrderModel({required this.status, required this.orderList});
}
