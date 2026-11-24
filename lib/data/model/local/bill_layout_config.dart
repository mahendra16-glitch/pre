import 'dart:convert';

class BillSectionConfig {
  final String id;
  final String label;
  bool visible;
  int size;
  String align; // 'L', 'C', 'R'
  bool bold;

  BillSectionConfig({
    required this.id,
    required this.label,
    this.visible = true,
    this.size = 1,
    this.align = 'C',
    this.bold = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'visible': visible,
        'size': size,
        'align': align,
        'bold': bold,
      };

  factory BillSectionConfig.fromJson(Map<String, dynamic> json) =>
      BillSectionConfig(
        id: json['id'] as String,
        label: json['label'] as String,
        visible: json['visible'] as bool? ?? true,
        size: json['size'] as int? ?? 1,
        align: json['align'] as String? ?? 'C',
        bold: json['bold'] as bool? ?? false,
      );

  BillSectionConfig copyWith({
    bool? visible,
    int? size,
    String? align,
    bool? bold,
  }) =>
      BillSectionConfig(
        id: id,
        label: label,
        visible: visible ?? this.visible,
        size: size ?? this.size,
        align: align ?? this.align,
        bold: bold ?? this.bold,
      );
}

class BillLayoutConfig {
  List<BillSectionConfig> billHeader;
  List<BillSectionConfig> billFooter;
  List<BillSectionConfig> kotSections;

  BillLayoutConfig({
    required this.billHeader,
    required this.billFooter,
    required this.kotSections,
  });

  static BillLayoutConfig defaults() => BillLayoutConfig(
        billHeader: [
          BillSectionConfig(id: 'logo', label: 'Logo', visible: true, size: 2, align: 'C', bold: false),
          BillSectionConfig(id: 'restaurant_name', label: 'Restaurant name', visible: true, size: 3, align: 'C', bold: true),
          BillSectionConfig(id: 'address', label: 'Address', visible: true, size: 1, align: 'C', bold: false),
          BillSectionConfig(id: 'phone', label: 'Phone number', visible: true, size: 1, align: 'C', bold: false),
          BillSectionConfig(id: 'gst', label: 'GST number', visible: true, size: 1, align: 'C', bold: false),
          BillSectionConfig(id: 'fssai', label: 'FSSAI number', visible: false, size: 1, align: 'C', bold: false),
          BillSectionConfig(id: 'order_id', label: 'Bill / Order ID', visible: true, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'date_time', label: 'Date & time', visible: true, size: 1, align: 'R', bold: false),
          BillSectionConfig(id: 'order_type', label: 'Order type (Dine In)', visible: true, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'waiter_name', label: 'Waiter / biller name', visible: true, size: 1, align: 'R', bold: false),
          BillSectionConfig(id: 'customer_name', label: 'Customer name', visible: true, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'customer_phone', label: 'Customer phone', visible: true, size: 1, align: 'R', bold: false),
          BillSectionConfig(id: 'table_number', label: 'Table number', visible: true, size: 3, align: 'C', bold: true),
        ],
        billFooter: [
          BillSectionConfig(id: 'item_total', label: 'Item total', visible: true, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'discount', label: 'Discount', visible: true, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'coupon_discount', label: 'Coupon discount', visible: true, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'loyalty', label: 'Loyalty points used', visible: true, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'wallet', label: 'Wallet amount used', visible: true, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'tips', label: 'Tips', visible: false, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'service_charge', label: 'Service charge', visible: false, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'delivery_charge', label: 'Delivery charge', visible: false, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'packing_charge', label: 'Packing charge', visible: false, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'subtotal', label: 'Sub total', visible: true, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'cgst', label: 'CGST', visible: true, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'sgst', label: 'SGST', visible: true, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'vat', label: 'VAT', visible: false, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'grand_total', label: 'Grand total', visible: true, size: 3, align: 'C', bold: true),
          BillSectionConfig(id: 'payment_type', label: 'Payment type', visible: true, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'powered_by', label: 'Powered by MyGenie', visible: true, size: 1, align: 'C', bold: false),
        ],
        kotSections: [
          BillSectionConfig(id: 'k_station', label: 'Station name', visible: true, size: 2, align: 'C', bold: true),
          BillSectionConfig(id: 'k_title', label: 'KOT title', visible: true, size: 2, align: 'C', bold: true),
          BillSectionConfig(id: 'k_order_id', label: 'Order ID', visible: true, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'k_date', label: 'Date & time', visible: true, size: 1, align: 'R', bold: false),
          BillSectionConfig(id: 'k_table', label: 'Table number', visible: true, size: 3, align: 'C', bold: true),
          BillSectionConfig(id: 'k_waiter', label: 'Waiter name', visible: true, size: 1, align: 'R', bold: false),
          BillSectionConfig(id: 'k_order_type', label: 'Order type', visible: true, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'k_customer', label: 'Customer name', visible: false, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'k_items', label: 'Item + qty list', visible: true, size: 1, align: 'L', bold: false),
          BillSectionConfig(id: 'k_note', label: 'Order notes', visible: true, size: 1, align: 'L', bold: false),
        ],
      );

  Map<String, dynamic> toJson() => {
        'billHeader': billHeader.map((e) => e.toJson()).toList(),
        'billFooter': billFooter.map((e) => e.toJson()).toList(),
        'kotSections': kotSections.map((e) => e.toJson()).toList(),
      };

  factory BillLayoutConfig.fromJson(Map<String, dynamic> json) {
    final defaults = BillLayoutConfig.defaults();
    return BillLayoutConfig(
      billHeader: _mergeList(json['billHeader'], defaults.billHeader),
      billFooter: _mergeList(json['billFooter'], defaults.billFooter),
      kotSections: _mergeList(json['kotSections'], defaults.kotSections),
    );
  }

  // Merges saved JSON list with defaults — adds any new default sections not yet in saved data
  static List<BillSectionConfig> _mergeList(
      dynamic savedJson, List<BillSectionConfig> defaults) {
    if (savedJson == null) return defaults;
    final saved = (savedJson as List)
        .map((e) => BillSectionConfig.fromJson(e as Map<String, dynamic>))
        .toList();
    final savedIds = saved.map((e) => e.id).toSet();
    final missing = defaults.where((d) => !savedIds.contains(d.id)).toList();
    return [...saved, ...missing];
  }

  String toJsonString() => jsonEncode(toJson());

  factory BillLayoutConfig.fromJsonString(String jsonStr) =>
      BillLayoutConfig.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
}
