import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/model/response/delivery_man_model.dart';
import 'package:mygenie_restaurant/data/model/response/review_model.dart';
import 'package:mygenie_restaurant/data/repository/delivery_man_repo.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../data/model/response/get_delivery_man_list_response.dart';
import '../data/model/response/get_waiter_order_list_response.dart';
import '../data/model/response/profile_model.dart';
import 'loader_contoller.dart';

class DeliveryManController extends GetxController implements GetxService {
  final DeliveryManRepo deliveryManRepo;
  DeliveryManController({required this.deliveryManRepo});

  // List<DeliveryManModel> _deliveryManList = [];
  List<GetDeliveryBoyList> _deliveryManList = [];
  GetWaiterOrderListResponse? _getWaiterOrderListResponse;
  GetWaiterOrderListResponse? get getWaiterOrderListResponse =>
      _getWaiterOrderListResponse;
  int _updatedOrderIndex = 0;
  String orderIdFromSocket = '';

  XFile? _pickedImage;
  List<XFile> _pickedIdentities = [];
  final List<String> _identityTypeList = ['passport', 'driving_license', 'nid'];
  int _identityTypeIndex = 0;
  bool _isLoading = false;
  List<ReviewModel>? _dmReviewList;
  bool _isSuspended = false;

  List<GetDeliveryBoyList> get deliveryManList => _deliveryManList;
  XFile? get pickedImage => _pickedImage;
  List<XFile> get pickedIdentities => _pickedIdentities;
  List<String> get identityTypeList => _identityTypeList;
  int get identityTypeIndex => _identityTypeIndex;
  bool get isLoading => _isLoading;
  List<ReviewModel>? get dmReviewList => _dmReviewList;
  bool get isSuspended => _isSuspended;

  Future getDeliveryManList() async {
    _deliveryManList = [];
    showToast('Loading');
    Get.find<LoadingController>().startLoading(true);

    Response response = await deliveryManRepo.getDeliveryManList();
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
    Get.find<LoadingController>().startLoading(false);
    if (response.statusCode == 200) {
      response.body.forEach((deliveryMan) =>
          _deliveryManList.add(GetDeliveryBoyList.fromJson(deliveryMan)));
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future assignDeliveryMan(Map<String, dynamic> body, Function callback,
      {String name = ''}) async {
    showToast('Please wait..');
    Get.find<LoadingController>().startLoading(true);
    Response response = await deliveryManRepo.assignDeliveryMan(body);
    Get.find<LoadingController>().startLoading(false);
    if (response.statusCode == 200) {
      await Get.find<LoadingController>()
          .changeText(data: response.body['message']);
      await Get.find<LoadingController>().changeStatus(data: true);
      Future.delayed(Duration(milliseconds: 500), () {
        callback(true);
      });
    } else {
      callback(false);
      ApiChecker.checkApi(response);
    }

    update();
  }

  Future rejectDeliveryMan(Map<String, dynamic> body, Function callback,
      {String name = ''}) async {
    showToast('Please wait..');
    Get.find<LoadingController>().startLoading(true);
    Response response = await deliveryManRepo.rejectDeliveryMan(body);
    Get.find<LoadingController>().startLoading(false);
    if (response.statusCode == 200) {
      await Get.find<LoadingController>()
          .changeText(data: response.body['message']);
      await Get.find<LoadingController>().changeStatus(data: true);
      Future.delayed(Duration(milliseconds: 500), () {
        callback(true);
      });
    } else {
      callback(false);
      ApiChecker.checkApi(response);
    }

    update();
  }

  Future<void> getDeliveryOrderList() async {
    Response response = await deliveryManRepo.getOrderList();
    _isLoading = false;
    if (response.statusCode == 200) {
      _getWaiterOrderListResponse =
          GetWaiterOrderListResponse.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future getOrderDetailFromSocket({
    String? type,
    String? orderId,
    String? foodStatus,
    dynamic socketJson,
    Function? callbackFunction,
  }) async {
    Response response;
    response = await deliveryManRepo.getOrderDetailFromSocket('$orderId');
    GetWaiterOrderListResponse jsonData =
        GetWaiterOrderListResponse.fromJson(response.body);
    if (response.statusCode == 200) {
      ProfileModel? profileModel = Get.find<AuthController>().profileModel;
      if (jsonData.orders != null && jsonData.orders!.isNotEmpty) {
        if (type == 'delivery-assign-order' ||
            type == 'update-order-status' ||
            type == 'update-order' ||
            type == 'update-food-status' ||
            type == 'update-item-status' ||
            type == 'update-order-paid'
            ) {
          int? index;
          if (_getWaiterOrderListResponse!.orders != null) {
            for (int i = 0;
                i < _getWaiterOrderListResponse!.orders!.length;
                i++) {
              if (_getWaiterOrderListResponse!.orders![i].id ==
                  jsonData.orders![0].id) {
                index = i;
                break;
              }
            }
          }

          if (type == 'update-order-status' &&
              jsonData.orders!.first.fOrderStatus == 2) {
            if (index != null &&
                _getWaiterOrderListResponse!.orders![index].fOrderStatus == 7 &&
                (jsonData.orders!.first.fOrderStatus == 1 ||
                    jsonData.orders!.first.fOrderStatus == 2 ||
                    jsonData.orders!.first.fOrderStatus == 5) &&
                jsonData.orders!.first.employeeId == profileModel?.empId) {
              _updatedOrderIndex = index;
              _getWaiterOrderListResponse!.orders![index] =
                  jsonData.orders!.first;

              update();
              return true;
            }
          } else if (type == 'update-order-status' &&
              jsonData.orders!.first.fOrderStatus != null &&
              jsonData.orders!.first.fOrderStatus! < 2) {
            if (index != null &&
                _getWaiterOrderListResponse!.orders![index].fOrderStatus == 7 &&
                (jsonData.orders!.first.fOrderStatus == 1 ||
                    jsonData.orders!.first.fOrderStatus == 2 ||
                    jsonData.orders!.first.fOrderStatus == 5) &&
                jsonData.orders!.first.employeeId == profileModel?.empId) {
              _updatedOrderIndex = index;
              _getWaiterOrderListResponse!.orders![index] =
                  jsonData.orders!.first;

              update();
              return true;
            }
          } else if (type == 'delivery-assign-order') {
            if (index == null && foodStatus == profileModel?.empId.toString()) {
              _getWaiterOrderListResponse!.orders?.add(jsonData.orders!.first);
              _updatedOrderIndex = _getWaiterOrderListResponse!.orders
                      ?.indexOf(_getWaiterOrderListResponse!.orders!.last) ??
                  0;
            } else {
              if (index != null &&
                  foodStatus == profileModel?.empId.toString() &&
                  jsonData.orders!.first.deliveryManId != null) {
                _getWaiterOrderListResponse!.orders![index] =
                    jsonData.orders!.first;
              } else if (index != null) {
                _getWaiterOrderListResponse!.orders?.removeAt(index);
              }
            }
          }
          if (type != 'scan-new-order' &&
              type != 'delivery-assign-order' &&
              index != null) {
            _getWaiterOrderListResponse!.orders![index] =
                jsonData.orders!.first;
          }

          // Get.find<RestaurantController>().update();
        }
      }
    } else {
      ApiChecker.checkApi(response);
      return false;
    }
    _isLoading = false;

    update();
  }

  Future<void> changeOrderStatus(
      Map<String, dynamic> jsonBody, Function callback) async {
    showToast('Loading');
    Get.find<LoadingController>().startLoading(true);

    Response response = await deliveryManRepo.orderStatusUpdate(jsonBody);
    Get.find<LoadingController>().startLoading(false);
    if (response.statusCode == 200) {
      String message = response.body['message'];
      callback(true, message);
      await Get.find<LoadingController>().changeText(data: message);
      await Get.find<LoadingController>().changeStatus(data: true);
      // _getOrderListResponse =
      //     GetPosOrderListResponseModel.fromJson(response.body);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  // Future<void> addDeliveryMan(DeliveryManModel deliveryMan, String pass,
  //     String token, bool isAdd) async {
  //   _isLoading = true;
  //   update();
  //   Response response = await deliveryManRepo.addDeliveryMan(
  //       deliveryMan, pass, _pickedImage, _pickedIdentities, token, isAdd);
  //   if (response.statusCode == 200) {
  //     Get.back();
  //     showCustomSnackBar(
  //         isAdd
  //             ? 'delivery_man_added_successfully'.tr
  //             : 'delivery_man_updated_successfully'.tr,
  //         isError: false);
  //     getDeliveryManList();
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  //   _isLoading = false;
  //   update();
  // }

  // Future<void> deleteDeliveryMan(int deliveryManID) async {
  //   _isLoading = true;
  //   update();
  //   Response response = await deliveryManRepo.deleteDeliveryMan(deliveryManID);
  //   if (response.statusCode == 200) {
  //     Get.back();
  //     showCustomSnackBar('delivery_man_deleted_successfully'.tr,
  //         isError: false);
  //     getDeliveryManList();
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  //   _isLoading = false;
  //   update();
  // }

  // void setSuspended(bool isSuspended) {
  //   _isSuspended = isSuspended;
  // }

  // void toggleSuspension(int deliveryManID) async {
  //   _isLoading = true;
  //   update();
  //   Response response = await deliveryManRepo.updateDeliveryManStatus(
  //       deliveryManID, _isSuspended ? 1 : 0);
  //   if (response.statusCode == 200) {
  //     Get.back();
  //     getDeliveryManList();
  //     showCustomSnackBar(
  //       _isSuspended
  //           ? 'delivery_man_unsuspended_successfully'.tr
  //           : 'delivery_man_suspended_successfully'.tr,
  //       isError: false,
  //     );
  //     _isSuspended = !_isSuspended;
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  //   _isLoading = false;
  //   update();
  // }

  // Future<void> getDeliveryManReviewList(int deliveryManID) async {
  //   _dmReviewList = null;
  //   Response response =
  //       await deliveryManRepo.getDeliveryManReviews(deliveryManID);
  //   if (response.statusCode == 200) {
  //     _dmReviewList = [];
  //     response.body['reviews'].forEach(
  //         (review) => _dmReviewList!.add(ReviewModel.fromJson(review)));
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  //   update();
  // }

  void setIdentityTypeIndex(String identityType, bool notify) {
    int _index = 0;
    for (int index = 0; index < _identityTypeList.length; index++) {
      if (_identityTypeList[index] == identityType) {
        _index = index;
        break;
      }
    }
    _identityTypeIndex = _index;
    if (notify) {
      update();
    }
  }

  Future<void> pickImage(bool isLogo, bool isRemove) async {
    if (isRemove) {
      _pickedImage = null;
      _pickedIdentities = [];
    } else {
      final ImagePicker picker = ImagePicker();
      if (isLogo) {
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          _pickedImage = image;
        }
      } else {
        final XFile? identity =
            await picker.pickImage(source: ImageSource.gallery);
        if (identity != null) {
          _pickedIdentities.add(identity);
        }
      }
    }
    update();
  }

  void removeIdentityImage(int index) {
    _pickedIdentities.removeAt(index);
    update();
  }
}
