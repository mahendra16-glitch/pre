class TimingSlot {
  String startTime;
  String endTime;

  TimingSlot({
    this.startTime = '07:00',
    this.endTime = '23:00',
  });

  TimingSlot copy() => TimingSlot(startTime: startTime, endTime: endTime);

  Map<String, dynamic> toJson() => {
        'start_time': startTime,
        'end_time': endTime,
      };

  factory TimingSlot.fromJson(dynamic json) {
    if (json is! Map) return TimingSlot();
    return TimingSlot(
      startTime: (json['start_time'] ?? json['start'] ?? '07:00').toString(),
      endTime: (json['end_time'] ?? json['end'] ?? '23:00').toString(),
    );
  }
}

class TimingDaySlots {
  String day;
  List<TimingSlot> slots;

  TimingDaySlots({
    required this.day,
    List<TimingSlot>? slots,
  }) : slots = slots ?? [TimingSlot()];

  TimingDaySlots copy() => TimingDaySlots(
        day: day,
        slots: slots.map((slot) => slot.copy()).toList(),
      );

  Map<String, dynamic> toJson() => {
        'day': day,
        'slots': slots.map((slot) => slot.toJson()).toList(),
      };

  factory TimingDaySlots.fromJson(dynamic json) {
    if (json is! Map) {
      return TimingDaySlots(day: 'all');
    }
    final dynamic rawSlots = json['slots'] ?? json['time_slots'];
    final List<TimingSlot> slots = rawSlots is List
        ? rawSlots.map(TimingSlot.fromJson).toList()
        : [TimingSlot()];
    return TimingDaySlots(
      day: (json['day'] ?? 'all').toString().toLowerCase(),
      slots: slots.isEmpty ? [TimingSlot()] : slots,
    );
  }
}

class TimingGroup {
  static const List<String> weekDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  static const Map<String, String> weekDayLabels = {
    'all': 'All days',
    'monday': 'Mon',
    'tuesday': 'Tue',
    'wednesday': 'Wed',
    'thursday': 'Thu',
    'friday': 'Fri',
    'saturday': 'Sat',
    'sunday': 'Sun',
  };

  String title;
  List<int> categoryIds;
  List<TimingDaySlots> daySlots;

  TimingGroup({
    this.title = '',
    List<int>? categoryIds,
    List<TimingDaySlots>? daySlots,
  })  : categoryIds = categoryIds ?? [],
        daySlots = daySlots ??
            [
              TimingDaySlots(day: 'all'),
            ];

  bool get isAllDays =>
      daySlots.length == 1 && daySlots.first.day.toLowerCase() == 'all';

  TimingGroup copy() => TimingGroup(
        title: title,
        categoryIds: List<int>.from(categoryIds),
        daySlots: daySlots.map((day) => day.copy()).toList(),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'category_ids': categoryIds,
        'day_slots': daySlots
            .where((day) => day.slots.isNotEmpty)
            .map((day) => day.toJson())
            .toList(),
      };

  String scheduleLabel() {
    return daySlots.map((day) {
      final String label = weekDayLabels[day.day] ?? day.day;
      final String slots = day.slots
          .map((slot) => '${slot.startTime}–${slot.endTime}')
          .join(', ');
      return '$label: $slots';
    }).join(' · ');
  }

  factory TimingGroup.fromJson(dynamic json) {
    if (json is! Map) return TimingGroup();
    final dynamic rawIds = json['category_ids'] ?? json['categories'];
    final List<int> categoryIds = [];
    if (rawIds is List) {
      for (final id in rawIds) {
        if (id is Map) {
          final int? parsed = int.tryParse(id['id']?.toString() ?? '');
          if (parsed != null) categoryIds.add(parsed);
        } else {
          final int? parsed = int.tryParse(id.toString());
          if (parsed != null) categoryIds.add(parsed);
        }
      }
    }
    final dynamic rawDays = json['day_slots'] ?? json['days'];
    final List<TimingDaySlots> daySlots = rawDays is List
        ? rawDays.map(TimingDaySlots.fromJson).toList()
        : [TimingDaySlots(day: 'all')];
    return TimingGroup(
      title: (json['title'] ?? json['name'] ?? '').toString(),
      categoryIds: categoryIds,
      daySlots: daySlots.isEmpty ? [TimingDaySlots(day: 'all')] : daySlots,
    );
  }
}
