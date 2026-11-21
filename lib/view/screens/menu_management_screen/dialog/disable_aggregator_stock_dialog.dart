import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/widget/aggregator_stock_popover.dart';

class _DisableOption {
  final String key;
  final String label;
  final String? preset;
  final bool isCustom;

  const _DisableOption({
    required this.key,
    required this.label,
    this.preset,
    this.isCustom = false,
  });
}

const List<_DisableOption> _disableOptions = [
  _DisableOption(key: 'indefinite', label: 'Indefinitely'),
  _DisableOption(key: '30m', label: '30 minutes', preset: '30m'),
  _DisableOption(key: '1h', label: '1 hour', preset: '1h'),
  _DisableOption(key: '2h', label: '2 hours', preset: '2h'),
  _DisableOption(key: '6h', label: '6 hours', preset: '6h'),
  _DisableOption(key: '12h', label: '12 hours', preset: '12h'),
  _DisableOption(key: '1d', label: '1 day', preset: '1d'),
  _DisableOption(key: '7d', label: '7 days', preset: '7d'),
  _DisableOption(
    key: 'custom',
    label: 'Custom date/time',
    isCustom: true,
  ),
];

void showDisableAggregatorStockDialog(
  BuildContext buttonContext,
  Map<String, dynamic> food,
) {
  showAggregatorStockPopover(
    buttonContext: buttonContext,
    child: DisableAggregatorStockDialog(food: food),
  );
}

class DisableAggregatorStockDialog extends StatefulWidget {
  final Map<String, dynamic> food;

  const DisableAggregatorStockDialog({super.key, required this.food});

  @override
  State<DisableAggregatorStockDialog> createState() =>
      _DisableAggregatorStockDialogState();
}

class _DisableAggregatorStockDialogState
    extends State<DisableAggregatorStockDialog> {
  static const Color _radioOrange = Color(0xFFF97316);
  static const Color _disableRed = Color(0xFFE11D48);

  String _selectedKey = 'indefinite';
  DateTime? _customDateTime;
  bool _isSubmitting = false;

  Future<void> _pickCustomDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _customDateTime ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (!mounted || pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _customDateTime != null
          ? TimeOfDay.fromDateTime(_customDateTime!)
          : TimeOfDay.fromDateTime(now.add(const Duration(minutes: 30))),
    );
    if (!mounted || pickedTime == null) return;

    setState(() {
      _customDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _onSelectOption(_DisableOption option) async {
    setState(() => _selectedKey = option.key);
    if (option.isCustom) {
      await _pickCustomDateTime();
    }
  }

  Future<void> _onDisable() async {
    if (_isSubmitting) return;

    final controller = Get.find<MenuManagementController>();
    final itemId = controller.parseFoodId(widget.food['id']);
    if (itemId == null) {
      appToast('Invalid item');
      return;
    }

    final option = _disableOptions.firstWhere((o) => o.key == _selectedKey);

    int? turnOnAtMs;
    String? turnOnPreset;
    if (option.isCustom) {
      if (_customDateTime == null) {
        appToast('Please select a date and time');
        return;
      }
      if (!_customDateTime!.isAfter(DateTime.now())) {
        appToast('Please select a future date and time');
        return;
      }
      turnOnAtMs = controller.localDateTimeToUnixMs(_customDateTime!);
    } else if (option.preset != null) {
      turnOnPreset = option.preset;
    }

    setState(() => _isSubmitting = true);
    Navigator.of(context).pop();
    await controller.aggregatorStockToggle(
      itemId: itemId,
      action: 'disable',
      turnOnPreset: turnOnPreset,
      turnOnAtMs: turnOnAtMs,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorTheme.whiteColor,
      elevation: 8,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Disable on UrbanPiper',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 15,
                    color: ColorTheme.blackColor,
                  ),
                ),
                const SizedBox(height: 8),
                ..._disableOptions.map((option) {
                  final isSelected = _selectedKey == option.key;
                  return InkWell(
                    onTap: () => _onSelectOption(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Radio<String>(
                                  value: option.key,
                                  groupValue: _selectedKey,
                                  onChanged: (_) => _onSelectOption(option),
                                  activeColor: _radioOrange,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  option.isCustom
                                      ? 'Custom date/time  \u2192'
                                      : option.label,
                                  style: poppinsRegular.copyWith(
                                    fontSize: 13.5,
                                    color: ColorTheme.blackColor,
                                    fontWeight: isSelected
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (option.isCustom && _customDateTime != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 32, bottom: 4),
                              child: Text(
                                DateFormat('d MMM yyyy, h:mm a')
                                    .format(_customDateTime!),
                                style: poppinsMedium.copyWith(
                                  fontSize: 12,
                                  color: ColorTheme.greenColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: poppinsMedium.copyWith(
                          fontSize: 13,
                          color: ColorTheme.grey8C,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _onDisable,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _disableRed,
                          foregroundColor: ColorTheme.whiteColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Disable',
                          style: poppinsMedium.copyWith(
                            fontSize: 13,
                            color: ColorTheme.whiteColor,
                          ),
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
  }
}
