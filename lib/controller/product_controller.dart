import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/model/response/category_model.dart';
import 'package:mygenie_restaurant/data/model/response/product_model.dart';
import 'package:get/get.dart';
import '../data/repository/product_repo.dart';

class ProductController extends GetxController implements GetxService {
  final ProductRepo productRepo;
  ProductController({required this.productRepo});

  bool _isLoading = false;
  // List<Product> _productList = [];
  // Product? _product;
  List<Product> _popularFoodList = [];
  List<CategoryModel> _categoryList = [];
  List<CategoryModel> _posFoodCategoryList = [];
  int _categoryIndex = 0;
  List<int> _categoryIds = [];
  // List<Product> get productList => _productList;
  List<Product> get popularFoodList => _popularFoodList;
  bool get isLoading => _isLoading;
  List<CategoryModel> get categoryList => _categoryList;
  List<CategoryModel> get posFoodCategoryList => _posFoodCategoryList;
  int get categoryIndex => _categoryIndex;
  List<int> get categoryIds => _categoryIds;

  // Future<void> getWaiterProductList(String offset, String type,
  //     {String loginType}) async {
  //   Response response;
  //   if (loginType == 'Billing') {
  //     response = await productRepo.getBillingProductList(offset, type);
  //   } else {
  //     response = await productRepo.getWaiterProductList(offset, type);
  //   }
  //   if (response.statusCode == 200) {
  //     _productList.addAll(ProductModel.fromJson(response.body).products);
  //     _isLoading = false;
  //     update();
  //   } else {
  //     ApiChecker.checkApi(response);
  //   }
  // }
  Future<Product?> getSingleProduct(String productId) async {
    Product? product;
    Response response = await productRepo.getSingleProduct(productId);

    if (response.statusCode == 200) {
      product = Product.fromJson(response.body['product']);
    } else {
      ApiChecker.checkApi(response);
    }

    return product;
  }

  void setCategoryList() {
    if (_categoryList.isNotEmpty &&
        Get.find<AuthController>().profileModel != null) {
      _posFoodCategoryList = [];
      for (var category in _categoryList) {
        if (Get.find<AuthController>()
            .profileModel!
            .categoryIds!
            .contains(category.id)) {
          if (category.name != 'CHECK IN') {
            _posFoodCategoryList
                .add(CategoryModel(id: category.id, name: category.name));
          }
        }
      }
      _posFoodCategoryList.sort((a, b) => a.name.compareTo(b.name));
      _posFoodCategoryList.insert(0, CategoryModel(id: 0, name: 'all'.tr));
    }
  }

  // void getProductListFromLocal(List<Product> productList) {
  //   _productList.addAll(productList);
  //   update();
  // }

  void getProductCategoryListFromLocal(List<CategoryModel> categoryList) {
    _posFoodCategoryList = [];
    _posFoodCategoryList.addAll(categoryList);
    update();
  }

  Future<void> getPopularFoodList() async {
    _popularFoodList = [];
    Response response;
    response = await productRepo.getPopularFoodList();

    if (response.statusCode == 200) {
      _popularFoodList
          .addAll(ProductModel.fromJson(response.body).products ?? []);
      _isLoading = false;
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<void> getPOSFoodCategoryList() async {
    _isLoading = true;
    update();
    // if (_categoryList == null) {
    _categoryList = [];
    Response response = await productRepo.getCategoryList();
    if (response.statusCode == 200) {
      response.body['restaurant_category'].forEach((category) {
        if (Get.find<AuthController>()
                .profileModel!
                .categoryIds!
                .contains(category['category_id']) &&
            category['name'].toString().toUpperCase() != 'CHECK IN') {
          _categoryList.add(CategoryModel(
              id: category['category_id'],
              name: category['name'].toString().toUpperCase()));
        }
      });
      _categoryList.insert(0, CategoryModel(id: 0, name: 'all'.tr));
      _isLoading = false;
    } else {
      _isLoading = false;

      ApiChecker.checkApi(response);
    }
    update();
  }

  void setCategoryIndex(int index, bool notify) {
    _categoryIndex = index;
    if (notify) {
      update();
    }
  }

  void setPOSCategoryIndex(int index, int categoryId) {
    _categoryIndex = index;
  }

  void setPOSWaiterCategoryIndex(int index) {
    _categoryIndex = index;
    update();
  }

  void clearProductList() {
    // _productList = [];
    _posFoodCategoryList = [];
    _popularFoodList = [];

    update();
  }
}
