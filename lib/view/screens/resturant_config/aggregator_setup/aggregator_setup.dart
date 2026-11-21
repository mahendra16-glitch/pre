import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/aggregator_setup/category_timing_group_dialog.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/aggregator_setup_controller.dart';

class AggregatorSetupScreen extends StatefulWidget {
  const AggregatorSetupScreen({super.key});

  @override
  State<AggregatorSetupScreen> createState() => _AggregatorSetupScreenState();
}

class _AggregatorSetupScreenState extends State<AggregatorSetupScreen> {
  static const Color _dropdownFill = Color(0xFFFFF1EB);
  static const List<String> _tabs = [
    'Operational Settings',
    'Sync Catalog',
    'Category Timings',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AggregatorSetupController>().loadScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.manageBgColor,
      appBar: AppBar(
        backgroundColor: ColorTheme.whiteColor,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: ColorTheme.green),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Aggregator Setup',
          style: montserratSemiBold.copyWith(
            color: ColorTheme.black,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        actions: [
          GetBuilder<AggregatorSetupController>(
            builder: (controller) {
              final bool busy = controller.isLoading ||
                  controller.isConfigLoading ||
                  controller.isSettingsLoading ||
                  controller.isSaving ||
                  controller.isCatalogBusy ||
                  controller.isStoreToggleBusy ||
                  controller.isTimingsLoading ||
                  controller.isSavingTimings ||
                  controller.isPushingTimings;
              return IconButton(
                icon: Icon(Icons.refresh, color: ColorTheme.appColor),
                tooltip: 'Refresh',
                onPressed: busy ? null : () => controller.loadScreen(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GetBuilder<AggregatorSetupController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorTheme.whiteColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColorTheme.borderGrey2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Brand Setup',
                    style: montserratSemiBold.copyWith(
                      color: ColorTheme.foodValue,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select a brand to view and edit its UrbanPiper configuration',
                    style: montserratRegular.copyWith(
                      color: ColorTheme.grey1,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFieldLabel('ACTIVE BRAND'),
                  const SizedBox(height: 8),
                  _buildBrandDropdown(controller),
                  const SizedBox(height: 20),
                  _buildFieldLabel('STORE POS ID'),
                  const SizedBox(height: 8),
                  _buildStorePosIdField(controller),
                  const SizedBox(height: 24),
                  _buildPlatformStatusSection(controller),
                  const SizedBox(height: 24),
                  _buildTabBar(controller),
                  const SizedBox(height: 20),
                  if (controller.selectedTabIndex == 0)
                    _buildOperationalSettings(controller)
                  else if (controller.selectedTabIndex == 1)
                    _buildSyncCatalogTab(controller)
                  else
                    _buildCategoryTimingsTab(controller),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: montserratMedium.copyWith(
        color: ColorTheme.grey1,
        fontSize: 11,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildTabBar(AggregatorSetupController controller) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final bool isSelected = controller.selectedTabIndex == index;
          return Expanded(
            child: InkWell(
              onTap: () => controller.selectTab(index),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? ColorTheme.appColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _tabs[index],
                  textAlign: TextAlign.center,
                  style: montserratMedium.copyWith(
                    color: isSelected
                        ? ColorTheme.whiteColor
                        : ColorTheme.foodValue,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCategoryTimingsTab(AggregatorSetupController controller) {
    final bool busy = controller.isTimingsLoading ||
        controller.isSavingTimings ||
        controller.isPushingTimings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6E5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFD89A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: ColorTheme.orangeColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Category timings are shared across all brands. Saving here updates schedules for all stores. The “Save & Push to” selector picks which store credentials to use for the UrbanPiper push.',
                  style: montserratRegular.copyWith(
                    color: ColorTheme.foodValue,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: busy
                  ? null
                  : () async {
                      final group = await showCategoryTimingGroupDialog(
                        categories: controller.productCategories,
                      );
                      if (group != null) controller.upsertTimingGroup(group);
                    },
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: Text(
                'New Timing Group',
                style: montserratSemiBold.copyWith(
                  color: ColorTheme.whiteColor,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTheme.green,
                disabledBackgroundColor: ColorTheme.green.withOpacity(0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: _buildBrandDropdown(controller),
            ),
            ElevatedButton(
              onPressed: busy ? null : controller.saveAndPushCategoryTimings,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTheme.appColor,
                disabledBackgroundColor: ColorTheme.appColor.withOpacity(0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: controller.isSavingTimings
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save & Push',
                      style: montserratSemiBold.copyWith(
                        color: ColorTheme.whiteColor,
                        fontSize: 12,
                      ),
                    ),
            ),
            OutlinedButton(
              onPressed: busy ? null : controller.pushCategoryTimingsOnly,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: ColorTheme.borderGrey2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: controller.isPushingTimings
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ColorTheme.appColor,
                      ),
                    )
                  : Text(
                      'Push Only',
                      style: montserratSemiBold.copyWith(
                        color: ColorTheme.foodValue,
                        fontSize: 12,
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (controller.isTimingsLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (controller.timingGroups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No timing groups yet. Add one to get started.',
                style: montserratMedium.copyWith(color: ColorTheme.grey1),
              ),
            ),
          )
        else
          ...List.generate(controller.timingGroups.length, (index) {
            final group = controller.timingGroups[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorTheme.whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorTheme.borderGrey2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.title,
                            style: montserratSemiBold.copyWith(
                              color: ColorTheme.foodValue,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Categories: ${controller.categoryNamesLabel(group.categoryIds)}',
                            style: montserratRegular.copyWith(
                              color: ColorTheme.grey1,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            group.scheduleLabel(),
                            style: montserratRegular.copyWith(
                              color: ColorTheme.foodValue,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: busy
                          ? null
                          : () async {
                              final updated =
                                  await showCategoryTimingGroupDialog(
                                categories: controller.productCategories,
                                existing: group,
                              );
                              if (updated != null) {
                                controller.upsertTimingGroup(
                                  updated,
                                  index: index,
                                );
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ColorTheme.borderGrey2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Edit',
                        style: montserratMedium.copyWith(
                          color: ColorTheme.foodValue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: busy
                          ? null
                          : () async {
                              final bool confirmed =
                                  await _confirmCatalogAction(
                                title: 'Delete Timing Group',
                                message:
                                    'Remove "${group.title}" from the list? Save & Push to persist this change.',
                              );
                              if (confirmed) {
                                controller.removeTimingGroup(index);
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: const Color(0xFFFFC9C9)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: montserratMedium.copyWith(
                          color: ColorTheme.badgeRed,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildSyncCatalogTab(AggregatorSetupController controller) {
    final String brandName = controller.selectedBrand.name;
    final bool busy = controller.isCatalogBusy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: 'Selected brand: ',
            style: montserratMedium.copyWith(
              color: ColorTheme.grey1,
              fontSize: 13,
            ),
            children: [
              TextSpan(
                text: controller.selectedBrandLabel,
                style: montserratSemiBold.copyWith(
                  color: ColorTheme.foodValue,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCatalogActionCard(
          title: 'Sync Menu to UrbanPiper',
          description:
              'Pushes $brandName\'s full menu to Swiggy & Zomato. This is asynchronous — the store pass fires a few seconds after the response.',
          buttonLabel: 'Sync Catalog',
          loading: controller.catalogActionInProgress == 'sync',
          enabled: !busy,
          onPressed: controller.syncCatalog,
        ),
        const SizedBox(height: 12),
        _buildCatalogActionCard(
          title: 'Force Enable All Items on Swiggy',
          description:
              'Re-enables all currently-active Swiggy items for $brandName on UrbanPiper. Use after a store outage or reset.',
          buttonLabel: 'Force Enable Swiggy',
          loading: controller.catalogActionInProgress == 'forceSwiggy',
          enabled: !busy,
          onPressed: controller.forceEnableSwiggy,
        ),
        if (controller.isOwner) ...[
          const SizedBox(height: 12),
          _buildCatalogActionCard(
            title: 'Clear Store Catalog',
            description:
                'Removes $brandName\'s items from UrbanPiper. Other brands are not affected. (full_master_reset: false)',
            buttonLabel: 'Clear Store',
            loading: controller.catalogActionInProgress == 'clearStore',
            enabled: !busy,
            onPressed: () async {
              final bool confirmed = await _confirmCatalogAction(
                title: 'Clear Store Catalog',
                message:
                    'Remove $brandName items from UrbanPiper? Other brands will not be affected.',
              );
              if (confirmed) controller.clearStoreCatalog();
            },
          ),
          const SizedBox(height: 12),
          _buildCatalogActionCard(
            title: 'Clear Modifiers',
            description:
                'Removes option/modifier groups for $brandName\'s store. Does not affect the other brand\'s modifiers.',
            buttonLabel: 'Clear Modifiers',
            loading: controller.catalogActionInProgress == 'clearModifiers',
            enabled: !busy,
            onPressed: () async {
              final bool confirmed = await _confirmCatalogAction(
                title: 'Clear Modifiers',
                message:
                    'Remove option/modifier groups for $brandName? Other brands will not be affected.',
              );
              if (confirmed) controller.clearModifiers();
            },
          ),
          const SizedBox(height: 12),
          _buildCatalogActionCard(
            title: 'Full Master Reset',
            description:
                'DANGER: Wipes the shared master catalog for ALL brands on UrbanPiper. Use only when instructed by support. Cannot be undone.',
            buttonLabel: 'Full Reset',
            loading: controller.catalogActionInProgress == 'fullReset',
            enabled: !busy,
            danger: true,
            onPressed: () async {
              final bool confirmed = await _confirmCatalogAction(
                title: 'Full Master Reset',
                message:
                    'This wipes the shared master catalog for ALL brands and cannot be undone. Continue only if support instructed you to do this.',
                danger: true,
              );
              if (confirmed) controller.fullMasterReset();
            },
          ),
        ],
      ],
    );
  }

  Future<bool> _confirmCatalogAction({
    required String title,
    required String message,
    bool danger = false,
  }) async {
    final bool? confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          title,
          style: montserratSemiBold.copyWith(
            color: danger ? ColorTheme.badgeRed : ColorTheme.foodValue,
            fontSize: 16,
          ),
        ),
        content: Text(
          message,
          style: montserratRegular.copyWith(
            color: ColorTheme.foodValue,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: montserratMedium.copyWith(color: ColorTheme.grey1),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              danger ? 'Full Reset' : 'Confirm',
              style: montserratSemiBold.copyWith(
                color: danger ? ColorTheme.badgeRed : ColorTheme.appColor,
              ),
            ),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Widget _buildCatalogActionCard({
    required String title,
    required String description,
    required String buttonLabel,
    required bool loading,
    required bool enabled,
    required VoidCallback onPressed,
    bool danger = false,
  }) {
    final Color accent = danger ? ColorTheme.badgeRed : ColorTheme.green;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorTheme.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: danger ? const Color(0xFFFFC9C9) : ColorTheme.borderGrey2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (danger) ...[
                      Icon(Icons.error, color: ColorTheme.badgeRed, size: 18),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: montserratSemiBold.copyWith(
                          color: danger
                              ? ColorTheme.badgeRed
                              : ColorTheme.foodValue,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: montserratRegular.copyWith(
                    color: ColorTheme.grey1,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: enabled && !loading ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                disabledBackgroundColor: accent.withOpacity(0.5),
                foregroundColor: ColorTheme.whiteColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '$buttonLabel  →',
                      style: montserratSemiBold.copyWith(
                        color: ColorTheme.whiteColor,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalSettings(AggregatorSetupController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggleRow(
          label: 'Auto KOT',
          value: controller.autoKot,
          enabled: !controller.isSettingsLoading && !controller.isSaving,
          onChanged: controller.setAutoKot,
        ),
        _buildToggleRow(
          label: 'Auto Bill',
          value: controller.autoBill,
          enabled: !controller.isSettingsLoading && !controller.isSaving,
          onChanged: controller.setAutoBill,
        ),
        if (controller.autoBill) ...[
          const SizedBox(height: 8),
          _buildFieldLabel('PRINT BILL WHEN ORDER IS'),
          const SizedBox(height: 8),
          _buildSimpleDropdown<String>(
            value: controller.autoBillStage,
            items: AggregatorSetupController.billStageOptions,
            labelBuilder: (value) => value,
            enabled: !controller.isSettingsLoading && !controller.isSaving,
            onChanged: controller.setAutoBillStage,
          ),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 8),
        _buildFieldLabel('AGGREGATOR ORDER TONE'),
        const SizedBox(height: 8),
        _buildSimpleDropdown<String>(
          value: controller.orderTone,
          items: AggregatorSetupController.orderToneOptions
              .map((option) => option['value']!)
              .toList(),
          labelBuilder: (value) {
            return AggregatorSetupController.orderToneOptions.firstWhere(
              (option) => option['value'] == value,
              orElse: () => const {'label': 'Default', 'value': 'default'},
            )['label']!;
          },
          enabled: !controller.isSettingsLoading && !controller.isSaving,
          onChanged: controller.setOrderTone,
        ),
        const SizedBox(height: 28),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: (controller.isSettingsLoading || controller.isSaving)
                  ? null
                  : controller.saveOperationalSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTheme.appColor,
                disabledBackgroundColor: ColorTheme.appColor.withOpacity(0.5),
                foregroundColor: ColorTheme.whiteColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: controller.isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save Settings',
                      style: montserratSemiBold.copyWith(
                        color: ColorTheme.whiteColor,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: montserratMedium.copyWith(
          color: ColorTheme.foodValue,
          fontSize: 15,
        ),
      ),
      trailing: Transform.scale(
        scale: 0.75,
        child: Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: ColorTheme.appColor,
        ),
      ),
    );
  }

  Widget _buildSimpleDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T value) labelBuilder,
    required bool enabled,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        isExpanded: true,
        value: value,
        items: items.map((item) {
          final bool isSelected = item == value;
          return DropdownMenuItem<T>(
            value: item,
            child: SizedBox(
              height: 42,
              child: Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                color: isSelected ? ColorTheme.appColor : ColorTheme.whiteColor,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  labelBuilder(item),
                  overflow: TextOverflow.ellipsis,
                  style: montserratMedium.copyWith(
                    color: isSelected
                        ? ColorTheme.whiteColor
                        : ColorTheme.foodValue,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) {
          return items.map((item) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                labelBuilder(item),
                overflow: TextOverflow.ellipsis,
                style: montserratMedium.copyWith(
                  color: ColorTheme.foodValue,
                  fontSize: 14,
                ),
              ),
            );
          }).toList();
        },
        onChanged: enabled ? onChanged : null,
        buttonStyleData: ButtonStyleData(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: ColorTheme.whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorTheme.appColor, width: 1.2),
          ),
        ),
        iconStyleData: IconStyleData(
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: ColorTheme.foodValue,
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 280,
          offset: const Offset(0, 4),
          decoration: BoxDecoration(
            color: ColorTheme.whiteColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 42,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildBrandDropdown(AggregatorSetupController controller) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<int>(
        isExpanded: true,
        value: controller.selectedBrandId,
        items: controller.brands.map((brand) {
          final bool isSelected = brand.id == controller.selectedBrandId;
          return DropdownMenuItem<int>(
            value: brand.id,
            child: SizedBox(
              height: 42,
              child: Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                color: isSelected ? ColorTheme.appColor : ColorTheme.whiteColor,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  brand.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: montserratMedium.copyWith(
                    color: isSelected
                        ? ColorTheme.whiteColor
                        : ColorTheme.foodValue,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) {
          return controller.brands.map((brand) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                brand.displayName,
                overflow: TextOverflow.ellipsis,
                style: montserratMedium.copyWith(
                  color: ColorTheme.foodValue,
                  fontSize: 14,
                ),
              ),
            );
          }).toList();
        },
        onChanged: controller.isLoading ? null : controller.selectBrand,
        buttonStyleData: ButtonStyleData(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: ColorTheme.whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorTheme.appColor, width: 1.2),
          ),
        ),
        iconStyleData: IconStyleData(
          icon: (controller.isLoading || controller.isConfigLoading)
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  Icons.keyboard_arrow_down,
                  color: ColorTheme.foodValue,
                ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 280,
          offset: const Offset(0, 4),
          decoration: BoxDecoration(
            color: ColorTheme.whiteColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 42,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildPlatformStatusSection(AggregatorSetupController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF5C4A8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Platform Status',
                  style: montserratSemiBold.copyWith(
                    color: ColorTheme.foodValue,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Control whether this brand is accepting orders on each platform',
                  style: montserratRegular.copyWith(
                    color: ColorTheme.grey1,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorTheme.whiteColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF5C4A8)),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6E5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Toggling platforms immediately affects live order acceptance on Zomato / Swiggy',
                      style: montserratMedium.copyWith(
                        color: ColorTheme.appColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildPlatformCard(
                          controller: controller,
                          platform: AggregatorSetupController.zomatoPlatform,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPlatformCard(
                          controller: controller,
                          platform: AggregatorSetupController.swiggyPlatform,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformCard({
    required AggregatorSetupController controller,
    required String platform,
  }) {
    final bool live = controller.isPlatformLive(platform);
    final String name = controller.platformLabel(platform);
    final bool toggling = controller.storeToggleInProgress == platform;
    final bool enabled = !controller.isConfigLoading &&
        !controller.isStoreToggleBusy;
    final Color cardBg =
        live ? const Color(0xFFE8F8EE) : const Color(0xFFFDECEC);
    final Color cardBorder =
        live ? const Color(0xFF9DD6A8) : const Color(0xFFF5C0C0);
    final Color statusColor =
        live ? ColorTheme.green : ColorTheme.badgeRed;
    final Color actionColor =
        live ? ColorTheme.badgeRed : ColorTheme.green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: montserratSemiBold.copyWith(
                    color: ColorTheme.foodValue,
                    fontSize: 16,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child:IgnorePointer(
  child:  Switch(
                  value: live,
                  // onChanged: enabled
                  //     ? (_) => _onPlatformToggle(controller, platform, !live)
                  //     : null,
                  onChanged: (_) {},
                  activeColor: ColorTheme.whiteColor,
                  activeTrackColor: ColorTheme.green,
                  inactiveThumbColor: ColorTheme.whiteColor,
                  inactiveTrackColor: ColorTheme.greyBE,
                ),),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.circle, size: 8, color: statusColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  live
                      ? 'LIVE — accepting orders'
                      : 'OFFLINE — not accepting orders',
                  style: montserratMedium.copyWith(
                    color: statusColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: enabled
                  ? () => _onPlatformToggle(controller, platform, !live)
                  : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: actionColor,
                side: BorderSide(color: actionColor),
                backgroundColor: ColorTheme.whiteColor.withOpacity(0.55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: toggling
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: actionColor,
                      ),
                    )
                  : Text(
                      live ? 'Disable on $name' : 'Enable on $name',
                      style: montserratMedium.copyWith(
                        color: actionColor,
                        fontSize: 13,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onPlatformToggle(
    AggregatorSetupController controller,
    String platform,
    bool enable,
  ) async {
    if (controller.isStoreToggleBusy) return;
    final bool confirmed = await _confirmPlatformToggle(
      platformName: controller.platformLabel(platform),
      enable: enable,
    );
    if (!confirmed) return;
    await controller.toggleStorePlatform(platform: platform, enable: enable);
  }

  Future<bool> _confirmPlatformToggle({
    required String platformName,
    required bool enable,
  }) async {
    final bool? confirmed = await Get.dialog<bool>(
      Dialog(
        backgroundColor: ColorTheme.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  enable
                      ? 'Enable on $platformName?'
                      : 'Disable on $platformName?',
                  textAlign: TextAlign.center,
                  style: montserratSemiBold.copyWith(
                    color: ColorTheme.foodValue,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    text:
                        'This will immediately affect live order acceptance on ',
                    style: montserratRegular.copyWith(
                      color: ColorTheme.grey1,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: platformName,
                        style: montserratSemiBold.copyWith(
                          color: ColorTheme.foodValue,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: '. You can reverse this at any time.',
                        style: montserratRegular.copyWith(
                          color: ColorTheme.grey1,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorTheme.foodValue,
                        side: BorderSide(color: ColorTheme.borderGrey2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: montserratMedium.copyWith(
                          color: ColorTheme.foodValue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorTheme.badgeRed,
                        foregroundColor: ColorTheme.whiteColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        'Confirm',
                        style: montserratSemiBold.copyWith(
                          color: ColorTheme.whiteColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return confirmed == true;
  }

  Widget _buildStorePosIdField(AggregatorSetupController controller) {
    return TextFormField(
      controller: controller.storePosIdController,
      readOnly: true,
      enableInteractiveSelection: false,
      textCapitalization: TextCapitalization.none,
      style: montserratMedium.copyWith(
        color: ColorTheme.foodValue,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'Store POS ID',
        hintStyle: montserratMedium.copyWith(
          color: ColorTheme.grey1,
          fontSize: 14,
        ),
        filled: true,
        fillColor: _dropdownFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: controller.isConfigLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorTheme.appColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorTheme.appColor, width: 1.2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorTheme.appColor, width: 1.2),
        ),
      ),
    );
  }
}
