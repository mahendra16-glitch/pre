import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/aggregator_setup/category_timing_models.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/repo/aggregator_setup_repo.dart';

class AggregatorBrand {
  static const int mainBrandId = 0;

  final int id;
  final String name;

  const AggregatorBrand({
    required this.id,
    required this.name,
  });

  bool get isMainBrand => id == mainBrandId;

  String get displayName => isMainBrand ? name : '$name (Client #$id)';

  static const AggregatorBrand main = AggregatorBrand(
    id: mainBrandId,
    name: 'Main Brand',
  );
}

class AggregatorSetupController extends GetxController implements GetxService {
  final AggregatorSetupRepo aggregatorSetupRepo;

  AggregatorSetupController({required this.aggregatorSetupRepo});

  static const String zomatoPlatform = 'zomato';
  static const String swiggyPlatform = 'swiggy';
  static const List<String> billStageOptions = ['Acknowledged', 'Ready'];
  static const List<Map<String, String>> orderToneOptions = [
    {'label': 'Default', 'value': 'default'},
    {'label': 'Silent', 'value': 'silent'},
    {'label': 'Buzzer', 'value': 'buzzer'},
  ];

  final TextEditingController storePosIdController = TextEditingController();

  bool isLoading = false;
  bool isConfigLoading = false;
  bool isSettingsLoading = false;
  bool isSaving = false;
  int _configRequestId = 0;
  int selectedBrandId = AggregatorBrand.mainBrandId;
  int selectedTabIndex = 0;
  List<AggregatorBrand> brands = const [AggregatorBrand.main];

  bool autoKot = false;
  bool autoBill = false;
  String autoBillStage = 'Acknowledged';
  String orderTone = 'default';
  bool zomatoLive = false;
  bool swiggyLive = false;
  String? storeToggleInProgress;
  String? catalogActionInProgress;
  bool isTimingsLoading = false;
  bool isSavingTimings = false;
  bool isPushingTimings = false;
  List<TimingGroup> timingGroups = [];
  List<Map<String, dynamic>> productCategories = [];

  bool get isCatalogBusy => catalogActionInProgress != null;

  bool get isStoreToggleBusy => storeToggleInProgress != null;

  bool get isOwner {
    final List<String>? roles = Get.find<AuthController>().profileModel?.role;
    return roles?.contains('Manager') == true;
  }

  int? get selectedClientId =>
      selectedBrand.isMainBrand ? null : selectedBrandId;

  String get selectedBrandLabel => selectedBrand.displayName;

  Map<String, dynamic> _brandPayload({bool? fullMasterReset}) {
    final Map<String, dynamic> body = {};
    if (selectedClientId != null) {
      body['client_id'] = selectedClientId;
    }
    if (fullMasterReset != null) {
      body['full_master_reset'] = fullMasterReset;
    }
    return body;
  }

  Future<void> loadScreen() async {
    selectedBrandId = AggregatorBrand.mainBrandId;
    storePosIdController.clear();
    zomatoLive = false;
    swiggyLive = false;
    update();
    await Future.wait([
      fetchRestaurantClients(),
      fetchAggregatorConfig(),
      fetchRestaurantSettings(),
    ]);
    if (selectedTabIndex == 2) {
      await Future.wait([
        fetchProductCategories(),
        fetchCategoryTimings(),
      ]);
    }
  }

  Future<void> fetchRestaurantClients() async {
    isLoading = true;
    update();

    try {
      final Response response =
          await aggregatorSetupRepo.getRestaurantClients();
      if (response.statusCode == 200) {
        final List<AggregatorBrand> nextBrands = [AggregatorBrand.main];
        final bool clientsFound = response.body?['clients_found'] == true;
        final dynamic clients = response.body?['clients'];

        if (clientsFound && clients is List) {
          final Set<int> seenIds = {AggregatorBrand.mainBrandId};
          for (final client in clients) {
            if (client is! Map) continue;
            final int? id = int.tryParse(client['id']?.toString() ?? '');
            final String name = (client['name'] ?? '').toString().trim();
            if (id == null || id == AggregatorBrand.mainBrandId) continue;
            if (!seenIds.add(id)) continue;
            nextBrands.add(AggregatorBrand(
              id: id,
              name: name.isEmpty ? 'Client #$id' : name,
            ));
          }
        }
        brands = nextBrands;
        if (!brands.any((brand) => brand.id == selectedBrandId)) {
          selectedBrandId = AggregatorBrand.mainBrandId;
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      log('fetchRestaurantClients Error: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> fetchAggregatorConfig({int? clientId}) async {
    final int requestId = ++_configRequestId;
    isConfigLoading = true;
    update();

    try {
      final Response response = await aggregatorSetupRepo.getAggregatorConfig(
        clientId: clientId,
      );
      if (requestId != _configRequestId) return;
      if (response.statusCode == 200) {
        _applyAggregatorConfig(response.body);
      } else {
        storePosIdController.clear();
        zomatoLive = false;
        swiggyLive = false;
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      if (requestId != _configRequestId) return;
      storePosIdController.clear();
      zomatoLive = false;
      swiggyLive = false;
      log('fetchAggregatorConfig Error: $e');
    } finally {
      if (requestId == _configRequestId) {
        isConfigLoading = false;
        update();
      }
    }
  }

  Future<void> fetchRestaurantSettings() async {
    isSettingsLoading = true;
    update();

    try {
      final Response response =
          await aggregatorSetupRepo.getRestaurantSettings();
      if (response.statusCode == 200) {
        _applyRestaurantSettings(response.body);
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      log('fetchRestaurantSettings Error: $e');
    } finally {
      isSettingsLoading = false;
      update();
    }
  }

  void _applyRestaurantSettings(dynamic body) {
    if (body is! Map) return;
    final dynamic data = body['data'];
    if (data is! Map) return;
    final Map<String, dynamic> source = Map<String, dynamic>.from(data);
    if (data['basic'] is Map) {
      source.addAll(Map<String, dynamic>.from(data['basic']));
    }

    autoKot = _isYes(source['aggregator_auto_kot']);
    autoBill = _isYes(source['aggregator_auto_bill']);
    autoBillStage = _normalizeBillStage(source['aggregator_auto_bill_stage']);
    orderTone = _normalizeOrderTone(source['aggregator_order_tone']);
  }

  void _applyAggregatorConfig(dynamic body) {
    storePosIdController.text = _parseStoreId(body);
    zomatoLive = false;
    swiggyLive = false;
    if (body is! Map) return;
    final dynamic data = body['data'];
    if (data is! Map) return;
    zomatoLive = _isYes(data['zomato_status']);
    swiggyLive = _isYes(data['swiggy_status']);
  }

  bool isPlatformLive(String platform) {
    return platform == zomatoPlatform ? zomatoLive : swiggyLive;
  }

  Future<void> toggleStorePlatform({
    required String platform,
    required bool enable,
  }) async {
    if (isStoreToggleBusy) return;
    storeToggleInProgress = platform;
    update();

    final Map<String, dynamic> body = {
      'action': enable ? 'enable' : 'disable',
      'platforms': [platform],
    };
    if (selectedClientId != null) {
      body['client_id'] = selectedClientId;
    }

    try {
      final Response response =
          await aggregatorSetupRepo.toggleStorePlatform(body);
      final bool success = response.statusCode == 200 &&
          (response.body is! Map || response.body['status'] != false);
      final String fallback = enable
          ? 'Enabled on ${platformLabel(platform)}'
          : 'Disabled on ${platformLabel(platform)}';
      final String message = response.body is Map
          ? (response.body['message']?.toString() ?? fallback)
          : fallback;

      if (success) {
        if (platform == zomatoPlatform) {
          zomatoLive = enable;
        } else {
          swiggyLive = enable;
        }
        Get.snackbar(
          'Success',
          message,
          backgroundColor: ColorTheme.green,
          colorText: Colors.white,
        );
      } else {
        ApiChecker.checkApi(response);
        Get.snackbar(
          'Error',
          message.isNotEmpty ? message : 'Failed to update platform status',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log('toggleStorePlatform Error: $e');
      Get.snackbar(
        'Error',
        'Failed to update platform status',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      storeToggleInProgress = null;
      update();
    }
  }

  String platformLabel(String platform) {
    return platform == zomatoPlatform ? 'Zomato' : 'Swiggy';
  }

  bool _isYes(dynamic value) =>
      value?.toString().trim().toLowerCase() == 'yes';

  String _normalizeBillStage(dynamic value) {
    final String stage = value?.toString().trim() ?? '';
    if (billStageOptions.contains(stage)) return stage;
    return 'Acknowledged';
  }

  String _normalizeOrderTone(dynamic value) {
    final String tone = value?.toString().trim().toLowerCase() ?? '';
    final bool isKnown =
        orderToneOptions.any((option) => option['value'] == tone);
    return isKnown ? tone : 'default';
  }

  String _parseStoreId(dynamic body) {
    if (body is! Map) return '';
    final dynamic data = body['data'];
    if (data is Map && data['store_id'] != null) {
      return data['store_id'].toString();
    }
    if (body['suggested_store_id'] != null) {
      return body['suggested_store_id'].toString();
    }
    return '';
  }

  void selectBrand(int? brandId) {
    selectedBrandId = brandId ?? AggregatorBrand.mainBrandId;
    update();
    fetchAggregatorConfig(clientId: selectedClientId);
    if (selectedTabIndex == 2) {
      fetchCategoryTimings();
    }
  }

  void selectTab(int index) {
    selectedTabIndex = index;
    update();
    if (index == 2) {
      fetchProductCategories();
      fetchCategoryTimings();
    }
  }

  void setAutoKot(bool value) {
    autoKot = value;
    update();
  }

  void setAutoBill(bool value) {
    autoBill = value;
    update();
  }

  void setAutoBillStage(String? value) {
    if (value == null) return;
    autoBillStage = _normalizeBillStage(value);
    update();
  }

  void setOrderTone(String? value) {
    if (value == null) return;
    orderTone = _normalizeOrderTone(value);
    update();
  }

  Future<void> saveOperationalSettings() async {
    isSaving = true;
    update();

    final Map<String, String> fields = {
      'data': jsonEncode({
        'basic': {
          'aggregator_auto_kot': autoKot ? 'Yes' : 'No',
          'aggregator_auto_bill': autoBill ? 'Yes' : 'No',
          'aggregator_auto_bill_stage': autoBillStage,
          'aggregator_order_tone': orderTone,
        },
      }),
    };

    try {
      final Response response =
          await aggregatorSetupRepo.updateOperationalSettings(fields);
      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          response.body['message'] ?? 'Settings updated successfully',
          backgroundColor: ColorTheme.green,
          colorText: Colors.white,
        );
        await fetchRestaurantSettings();
      } else {
        ApiChecker.checkApi(response);
        Get.snackbar(
          'Error',
          response.body['message'] ?? 'Failed to update settings',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log('saveOperationalSettings Error: $e');
      Get.snackbar(
        'Error',
        'Failed to update settings',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving = false;
      update();
    }
  }

  Future<void> syncCatalog() {
    return _runCatalogAction(
      actionKey: 'sync',
      request: () => aggregatorSetupRepo.syncCatalog(_brandPayload()),
      fallbackMessage: 'Catalog sync queued',
    );
  }

  Future<void> forceEnableSwiggy() {
    return _runCatalogAction(
      actionKey: 'forceSwiggy',
      request: () => aggregatorSetupRepo.forceSwiggyEnable(_brandPayload()),
      fallbackMessage: 'Swiggy items enabled',
    );
  }

  Future<void> clearStoreCatalog() {
    if (!_guardOwnerAction()) return Future.value();
    return _runCatalogAction(
      actionKey: 'clearStore',
      request: () => aggregatorSetupRepo.clearCatalog(
        _brandPayload(fullMasterReset: false),
      ),
      fallbackMessage: 'Store catalog cleared',
    );
  }

  Future<void> clearModifiers() {
    if (!_guardOwnerAction()) return Future.value();
    return _runCatalogAction(
      actionKey: 'clearModifiers',
      request: () => aggregatorSetupRepo.clearModifiers(_brandPayload()),
      fallbackMessage: 'Modifiers cleared',
    );
  }

  Future<void> fullMasterReset() {
    if (!_guardOwnerAction()) return Future.value();
    return _runCatalogAction(
      actionKey: 'fullReset',
      request: () => aggregatorSetupRepo.clearCatalog(
        _brandPayload(fullMasterReset: true),
      ),
      fallbackMessage: 'Full master reset queued',
    );
  }

  bool _guardOwnerAction() {
    if (isOwner) return true;
    Get.snackbar(
      'Error',
      'Only the owner can perform this action',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return false;
  }

  Future<void> _runCatalogAction({
    required String actionKey,
    required Future<Response> Function() request,
    required String fallbackMessage,
  }) async {
    if (isCatalogBusy) return;
    catalogActionInProgress = actionKey;
    update();

    try {
      final Response response = await request();
      final bool success = response.statusCode == 200 &&
          (response.body is! Map || response.body['status'] != false);
      final String message = response.body is Map
          ? (response.body['message']?.toString() ?? fallbackMessage)
          : fallbackMessage;

      if (success) {
        Get.snackbar(
          'Success',
          message,
          backgroundColor: ColorTheme.green,
          colorText: Colors.white,
        );
      } else {
        ApiChecker.checkApi(response);
        Get.snackbar(
          'Error',
          message.isNotEmpty ? message : 'Action failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log('_runCatalogAction $actionKey Error: $e');
      Get.snackbar(
        'Error',
        'Action failed',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      catalogActionInProgress = null;
      update();
    }
  }

  Future<void> fetchProductCategories() async {
    try {
      final Response response =
          await aggregatorSetupRepo.getProductCategories();
      if (response.statusCode == 200) {
        productCategories = _parseCategories(response.body);
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      log('fetchProductCategories Error: $e');
    } finally {
      update();
    }
  }

  Future<void> fetchCategoryTimings() async {
    isTimingsLoading = true;
    update();
    try {
      final Response response = await aggregatorSetupRepo.getCategoryTimings(
        clientId: selectedClientId,
      );
      if (response.statusCode == 200) {
        timingGroups = _parseTimingGroups(response.body);
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      log('fetchCategoryTimings Error: $e');
    } finally {
      isTimingsLoading = false;
      update();
    }
  }

  List<Map<String, dynamic>> _parseCategories(dynamic body) {
    dynamic raw = body;
    if (body is Map) {
      raw = body['data'] ?? body['categories'] ?? body['category'];
    }
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  List<TimingGroup> _parseTimingGroups(dynamic body) {
    dynamic raw;
    if (body is List) {
      raw = body;
    } else if (body is Map) {
      raw = body['timing_groups'] ?? body['data'];
      if (raw is Map) {
        raw = raw['timing_groups'] ?? raw['groups'] ?? raw['data'];
      }
    }
    if (raw is! List) return [];
    return raw.map(TimingGroup.fromJson).toList();
  }

  String categoryName(int id) {
    for (final category in productCategories) {
      final int? categoryId = int.tryParse(category['id']?.toString() ?? '');
      if (categoryId == id) {
        return (category['name'] ?? 'Category #$id').toString();
      }
    }
    return 'Category #$id';
  }

  String categoryNamesLabel(List<int> ids) {
    if (ids.isEmpty) return 'No categories';
    return ids.map(categoryName).join(', ');
  }

  void upsertTimingGroup(TimingGroup group, {int? index}) {
    if (index != null && index >= 0 && index < timingGroups.length) {
      timingGroups[index] = group;
    } else {
      timingGroups.add(group);
    }
    update();
  }

  void removeTimingGroup(int index) {
    if (index < 0 || index >= timingGroups.length) return;
    timingGroups.removeAt(index);
    update();
  }

  Future<void> saveAndPushCategoryTimings() async {
    isSavingTimings = true;
    update();
    final Map<String, dynamic> body = {
      'timing_groups': timingGroups.map((group) => group.toJson()).toList(),
    };
    if (selectedClientId != null) {
      body['client_id'] = selectedClientId;
    }
    try {
      final Response response =
          await aggregatorSetupRepo.saveCategoryTimings(body);
      _handleTimingResponse(
        response,
        fallbackMessage: 'Category timings saved and pushed',
      );
      if (response.statusCode == 200 &&
          (response.body is! Map || response.body['status'] != false)) {
        await fetchCategoryTimings();
      }
    } catch (e) {
      log('saveAndPushCategoryTimings Error: $e');
      Get.snackbar(
        'Error',
        'Failed to save category timings',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSavingTimings = false;
      update();
    }
  }

  Future<void> pushCategoryTimingsOnly() async {
    isPushingTimings = true;
    update();
    try {
      final Response response = await aggregatorSetupRepo.pushCategoryTimings(
        _brandPayload(),
      );
      _handleTimingResponse(
        response,
        fallbackMessage: 'Category timings pushed',
      );
    } catch (e) {
      log('pushCategoryTimingsOnly Error: $e');
      Get.snackbar(
        'Error',
        'Failed to push category timings',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isPushingTimings = false;
      update();
    }
  }

  void _handleTimingResponse(Response response, {required String fallbackMessage}) {
    final bool success = response.statusCode == 200 &&
        (response.body is! Map || response.body['status'] != false);
    final String message = response.body is Map
        ? (response.body['message']?.toString() ?? fallbackMessage)
        : fallbackMessage;
    if (success) {
      Get.snackbar(
        'Success',
        message,
        backgroundColor: ColorTheme.green,
        colorText: Colors.white,
      );
    } else {
      ApiChecker.checkApi(response);
      Get.snackbar(
        'Error',
        message.isNotEmpty ? message : 'Action failed',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  AggregatorBrand get selectedBrand {
    return brands.firstWhere(
      (brand) => brand.id == selectedBrandId,
      orElse: () => AggregatorBrand.main,
    );
  }

  @override
  void onClose() {
    storePosIdController.dispose();
    super.onClose();
  }
}
