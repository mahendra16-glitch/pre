import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/aggregator_setup/category_timing_models.dart';

Future<TimingGroup?> showCategoryTimingGroupDialog({
  required List<Map<String, dynamic>> categories,
  TimingGroup? existing,
}) {
  return Get.dialog<TimingGroup>(
    CategoryTimingGroupDialog(
      categories: categories,
      existing: existing,
    ),
  );
}

class CategoryTimingGroupDialog extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final TimingGroup? existing;

  const CategoryTimingGroupDialog({
    super.key,
    required this.categories,
    this.existing,
  });

  @override
  State<CategoryTimingGroupDialog> createState() =>
      _CategoryTimingGroupDialogState();
}

class _CategoryTimingGroupDialogState extends State<CategoryTimingGroupDialog> {
  late final TextEditingController _titleController;
  late bool _allDays;
  late List<int> _selectedCategoryIds;
  late List<TimingSlot> _allDaySlots;
  late Map<String, List<TimingSlot>> _customSlots;

  @override
  void initState() {
    super.initState();
    final TimingGroup group = widget.existing?.copy() ?? TimingGroup();
    _titleController = TextEditingController(text: group.title);
    _selectedCategoryIds = List<int>.from(group.categoryIds);
    _allDays = group.isAllDays;
    _allDaySlots = group.isAllDays
        ? group.daySlots.first.slots.map((slot) => slot.copy()).toList()
        : [TimingSlot()];
    _customSlots = {
      for (final day in TimingGroup.weekDays) day: [TimingSlot()],
    };
    if (!group.isAllDays) {
      for (final daySlot in group.daySlots) {
        _customSlots[daySlot.day] =
            daySlot.slots.map((slot) => slot.copy()).toList();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF3FFF6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorTheme.green.withOpacity(0.35)),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Title'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titleController,
                        decoration: _inputDecoration('e.g. Breakfast'),
                      ),
                      const SizedBox(height: 16),
                      _label('Categories'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.categories.map((category) {
                          final int? id =
                              int.tryParse(category['id']?.toString() ?? '');
                          if (id == null) return const SizedBox.shrink();
                          final bool selected =
                              _selectedCategoryIds.contains(id);
                          final String name =
                              (category['name'] ?? 'Category #$id').toString();
                          return FilterChip(
                            selected: selected,
                            showCheckmark: false,
                            label: Text(name),
                            selectedColor: ColorTheme.green,
                            backgroundColor: ColorTheme.whiteColor,
                            labelStyle: montserratMedium.copyWith(
                              color: selected
                                  ? ColorTheme.whiteColor
                                  : ColorTheme.foodValue,
                              fontSize: 12,
                            ),
                            side: BorderSide(
                              color: selected
                                  ? ColorTheme.green
                                  : ColorTheme.borderGrey2,
                            ),
                            onSelected: (value) {
                              setState(() {
                                if (value) {
                                  _selectedCategoryIds.add(id);
                                } else {
                                  _selectedCategoryIds.remove(id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      _label('Days'),
                      Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: _allDays,
                            activeColor: ColorTheme.appColor,
                            onChanged: (_) => setState(() => _allDays = true),
                          ),
                          Text('All days',
                              style: montserratMedium.copyWith(fontSize: 13)),
                          const SizedBox(width: 12),
                          Radio<bool>(
                            value: false,
                            groupValue: _allDays,
                            activeColor: ColorTheme.appColor,
                            onChanged: (_) => setState(() => _allDays = false),
                          ),
                          Text('Custom',
                              style: montserratMedium.copyWith(fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_allDays)
                        _buildDaySlots('all', _allDaySlots)
                      else
                        ...TimingGroup.weekDays.map((day) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildDaySlots(day, _customSlots[day]!),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: montserratMedium.copyWith(color: ColorTheme.grey1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTheme.green,
                      foregroundColor: ColorTheme.whiteColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Save Group',
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
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: montserratSemiBold.copyWith(
        color: ColorTheme.foodValue,
        fontSize: 13,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: ColorTheme.whiteColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ColorTheme.green.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ColorTheme.green),
      ),
    );
  }

  Widget _buildDaySlots(String day, List<TimingSlot> slots) {
    final String label = day == 'all'
        ? ''
        : (TimingGroup.weekDayLabels[day] ?? day);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label,
              style: montserratMedium.copyWith(
                color: ColorTheme.foodValue,
                fontSize: 13,
              ),
            ),
          ),
        ...List.generate(slots.length, (index) {
          final TimingSlot slot = slots[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(child: _timeField(slot.startTime, (value) {
                  setState(() => slot.startTime = value);
                })),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('to',
                      style: montserratMedium.copyWith(color: ColorTheme.grey1)),
                ),
                Expanded(child: _timeField(slot.endTime, (value) {
                  setState(() => slot.endTime = value);
                })),
                if (slots.length > 1)
                  IconButton(
                    onPressed: () => setState(() => slots.removeAt(index)),
                    icon: const Icon(Icons.close, size: 18),
                  ),
              ],
            ),
          );
        }),
        TextButton(
          onPressed: () => setState(() => slots.add(TimingSlot())),
          child: Text(
            '+ Add slot',
            style: montserratMedium.copyWith(
              color: ColorTheme.appColor,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _timeField(String value, ValueChanged<String> onPicked) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showDialog<TimeOfDay>(
          context: context,
          builder: (_) => _QuarterHourPickerDialog(
            initial: _snapMinutesDown(_parseTime(value)),
          ),
        );
        if (picked != null) {
          onPicked(_formatTime(picked));
        }
      },
      child: InputDecorator(
        decoration: _inputDecoration('').copyWith(
          suffixIcon: Icon(Icons.access_time, color: ColorTheme.grey1, size: 18),
        ),
        child: Text(
          value,
          style: montserratMedium.copyWith(fontSize: 13),
        ),
      ),
    );
  }

  TimeOfDay _parseTime(String value) {
    final List<String> parts = value.split(':');
    if (parts.length < 2) return const TimeOfDay(hour: 7, minute: 0);
    return TimeOfDay(
      hour: (int.tryParse(parts[0]) ?? 7).clamp(0, 23).toInt(),
      minute: (int.tryParse(parts[1]) ?? 0).clamp(0, 59).toInt(),
    );
  }

  TimeOfDay _snapMinutesDown(TimeOfDay time) {
    final int minute;
    if (time.minute < 15) {
      minute = 0;
    } else if (time.minute < 30) {
      minute = 15;
    } else if (time.minute < 45) {
      minute = 30;
    } else {
      minute = 45;
    }
    return TimeOfDay(hour: time.hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _save() {
    final String title = _titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a title',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (_selectedCategoryIds.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one category',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final List<TimingDaySlots> daySlots = _allDays
        ? [TimingDaySlots(day: 'all', slots: _allDaySlots.map((s) => s.copy()).toList())]
        : TimingGroup.weekDays
            .map((day) => TimingDaySlots(
                  day: day,
                  slots: (_customSlots[day] ?? [TimingSlot()])
                      .map((slot) => slot.copy())
                      .toList(),
            ))
            .toList();

    Get.back(
      result: TimingGroup(
        title: title,
        categoryIds: List<int>.from(_selectedCategoryIds),
        daySlots: daySlots,
      ),
    );
  }
}

class _QuarterHourPickerDialog extends StatefulWidget {
  final TimeOfDay initial;

  const _QuarterHourPickerDialog({required this.initial});

  @override
  State<_QuarterHourPickerDialog> createState() =>
      _QuarterHourPickerDialogState();
}

class _QuarterHourPickerDialogState extends State<_QuarterHourPickerDialog> {
  static const List<int> _minutes = [0, 15, 30, 45];

  late int _hour;
  late int _minuteIndex;
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _hour = widget.initial.hour.clamp(0, 23).toInt();
    final int minuteIndex = _minutes.indexOf(widget.initial.minute);
    _minuteIndex = minuteIndex < 0 ? 0 : minuteIndex;
    _hourController = FixedExtentScrollController(initialItem: _hour);
    _minuteController = FixedExtentScrollController(initialItem: _minuteIndex);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorTheme.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Select time',
        style: montserratSemiBold.copyWith(
          color: ColorTheme.foodValue,
          fontSize: 16,
        ),
      ),
      content: SizedBox(
        height: 180,
        width: 260,
        child: Row(
          children: [
            Expanded(child: _buildWheelColumn('Hour', _hourWheel())),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                ':',
                style: montserratSemiBold.copyWith(
                  fontSize: 22,
                  color: ColorTheme.foodValue,
                ),
              ),
            ),
            Expanded(child: _buildWheelColumn('Min', _minuteWheel())),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: montserratMedium.copyWith(color: ColorTheme.grey1),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(
              TimeOfDay(hour: _hour, minute: _minutes[_minuteIndex]),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorTheme.green,
            foregroundColor: ColorTheme.whiteColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'OK',
            style: montserratSemiBold.copyWith(color: ColorTheme.whiteColor),
          ),
        ),
      ],
    );
  }

  Widget _buildWheelColumn(String label, Widget wheel) {
    return Column(
      children: [
        Text(
          label,
          style: montserratMedium.copyWith(
            fontSize: 12,
            color: ColorTheme.grey1,
          ),
        ),
        const SizedBox(height: 4),
        Expanded(child: wheel),
      ],
    );
  }

  Widget _hourWheel() {
    return ListWheelScrollView.useDelegate(
      controller: _hourController,
      itemExtent: 40,
      perspective: 0.003,
      diameterRatio: 1.4,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (index) => setState(() => _hour = index),
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: 24,
        builder: (context, index) => _wheelItem(
          index.toString().padLeft(2, '0'),
          selected: index == _hour,
        ),
      ),
    );
  }

  Widget _minuteWheel() {
    return ListWheelScrollView.useDelegate(
      controller: _minuteController,
      itemExtent: 40,
      perspective: 0.003,
      diameterRatio: 1.4,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (index) => setState(() => _minuteIndex = index),
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: _minutes.length,
        builder: (context, index) => _wheelItem(
          _minutes[index].toString().padLeft(2, '0'),
          selected: index == _minuteIndex,
        ),
      ),
    );
  }

  Widget _wheelItem(String text, {required bool selected}) {
    return Center(
      child: Text(
        text,
        style: montserratSemiBold.copyWith(
          fontSize: selected ? 20 : 16,
          color: selected ? ColorTheme.appColor : ColorTheme.grey1,
        ),
      ),
    );
  }
}
