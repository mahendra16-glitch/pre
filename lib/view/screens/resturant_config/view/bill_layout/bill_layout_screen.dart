import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/data/model/local/bill_layout_config.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/local_print_config_service.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';

class BillLayoutScreen extends StatefulWidget {
  const BillLayoutScreen({Key? key}) : super(key: key);

  @override
  State<BillLayoutScreen> createState() => _BillLayoutScreenState();
}

class _BillLayoutScreenState extends State<BillLayoutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BillLayoutConfig? _config;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final cfg = await LocalPrintConfigService.instance.load();
    if (mounted) setState(() { _config = cfg; _loading = false; });
  }

  Future<void> _save() async {
    if (_config == null) return;
    setState(() => _saving = true);
    await LocalPrintConfigService.instance.save(_config!);
    setState(() => _saving = false);
    showCustomSnackBar('Bill / KOT layout saved', isError: false);
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reset to defaults', style: montserratSemiBold.copyWith(fontSize: 16)),
        content: Text('This will remove all your customizations.', style: montserratRegular),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _config = BillLayoutConfig.defaults());
            },
            child: Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showTestPrint() {
    final printers = Get.find<AuthController>().profileModel?.restaurantPrinterNew ?? [];
    if (printers.isEmpty) {
      showCustomSnackBar('No printers configured', isError: true);
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _TestPrintSheet(config: _config!, printers: printers),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.manageBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: ColorTheme.green),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bill / KOT Layout',
          style: montserratSemiBold.copyWith(color: Colors.black, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.print_outlined, color: ColorTheme.appColor),
            tooltip: 'Test Print',
            onPressed: _config == null ? null : () => _showTestPrint(),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: ColorTheme.appColor),
            tooltip: 'Reset to defaults',
            onPressed: _resetToDefaults,
          ),
          _saving
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                )
              : IconButton(
                  icon: Icon(Icons.save_rounded, color: ColorTheme.appColor),
                  tooltip: 'Save',
                  onPressed: _save,
                ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorTheme.appColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: ColorTheme.appColor,
          labelStyle: montserratSemiBold.copyWith(fontSize: 13),
          tabs: const [
            Tab(text: 'Bill'),
            Tab(text: 'KOT'),
            Tab(text: 'Preview'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _BillTab(config: _config!, onChanged: () => setState(() {})),
                _KotTab(config: _config!, onChanged: () => setState(() {})),
                _PreviewTab(config: _config!),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTheme.appColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            child: Text(
              _saving ? 'Saving...' : 'Save layout',
              style: montserratSemiBold.copyWith(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bill tab
// ─────────────────────────────────────────────────────────────
class _BillTab extends StatelessWidget {
  final BillLayoutConfig config;
  final VoidCallback onChanged;
  const _BillTab({required this.config, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SectionHeader(title: 'Header', icon: Icons.business),
        const SizedBox(height: 6),
        _ReorderableList(
          sections: config.billHeader,
          onChanged: onChanged,
        ),
        const SizedBox(height: 14),
        _SectionHeader(title: 'Footer / totals', icon: Icons.receipt_long),
        const SizedBox(height: 6),
        _ReorderableList(
          sections: config.billFooter,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// KOT tab
// ─────────────────────────────────────────────────────────────
class _KotTab extends StatelessWidget {
  final BillLayoutConfig config;
  final VoidCallback onChanged;
  const _KotTab({required this.config, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SectionHeader(title: 'KOT sections', icon: Icons.kitchen),
        const SizedBox(height: 6),
        _ReorderableList(
          sections: config.kotSections,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Preview tab — live receipt simulation
// ─────────────────────────────────────────────────────────────
class _PreviewTab extends StatelessWidget {
  final BillLayoutConfig config;
  const _PreviewTab({required this.config});

  static double _fontSize(int size) {
    switch (size) {
      case 2: return 14;
      case 3: return 18;
      case 4: return 22;
      default: return 11;
    }
  }

  static TextAlign _align(String a) {
    switch (a) {
      case 'L': return TextAlign.left;
      case 'R': return TextAlign.right;
      default:  return TextAlign.center;
    }
  }

  BillSectionConfig _sec(List<BillSectionConfig> list, String id) =>
      list.firstWhere((s) => s.id == id,
          orElse: () => BillSectionConfig(id: id, label: id));

  Widget _line(BillSectionConfig s, String text) {
    if (!s.visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        text,
        textAlign: _align(s.align),
        style: TextStyle(
          fontFamily: 'Courier',
          fontSize: _fontSize(s.size),
          fontWeight: s.bold ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Two columns in fixed ratio (simulates row() on 80mm)
  Widget _twoCol(
    BillSectionConfig s,
    String left, String right, {
    int leftFlex = 8, int rightFlex = 4,
    bool rightBold = false,
  }) {
    if (!s.visible) return const SizedBox.shrink();
    final fs = _fontSize(s.size);
    final style = TextStyle(
      fontFamily: 'Courier',
      fontSize: fs,
      fontWeight: s.bold ? FontWeight.bold : FontWeight.normal,
      color: Colors.black87,
    );
    final rightStyle = style.copyWith(
      fontWeight: rightBold ? FontWeight.bold : style.fontWeight,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(children: [
        Expanded(flex: leftFlex, child: Text(left, style: style, textAlign: TextAlign.left)),
        Expanded(flex: rightFlex, child: Text(right, style: rightStyle, textAlign: TextAlign.right)),
      ]),
    );
  }

  // Three columns: name / qty / price
  Widget _itemRow(BillSectionConfig s, String name, String qty, String price) {
    if (!s.visible) return const SizedBox.shrink();
    final fs = _fontSize(s.size);
    final style = TextStyle(
      fontFamily: 'Courier',
      fontSize: fs,
      fontWeight: s.bold ? FontWeight.bold : FontWeight.normal,
      color: Colors.black87,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(children: [
        Expanded(flex: 7, child: Text(name, style: style, textAlign: TextAlign.left)),
        Expanded(flex: 2, child: Text(qty, style: style, textAlign: TextAlign.left)),
        Expanded(flex: 3, child: Text(price, style: style, textAlign: TextAlign.right)),
      ]),
    );
  }

  Widget _hr() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Divider(height: 1, color: Colors.black54),
      );

  Widget _dottedHr() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Text('- - - - - - - - - - - - - - - - - - - - -',
            style: TextStyle(fontFamily: 'Courier', fontSize: 10, color: Colors.black38),
            overflow: TextOverflow.clip),
      );

  String _restaurantName() {
    try {
      return Get.find<AuthController>().profileModel?.restaurants?.firstOrNull?.name ?? 'My Restaurant';
    } catch (_) {
      return 'My Restaurant';
    }
  }

  Widget _billReceipt() {
    final bh = config.billHeader;
    final bf = config.billFooter;
    final itemSec = _sec(bh, 'bill_items');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _line(_sec(bh, 'restaurant_name'), _restaurantName()),
        _line(_sec(bh, 'address'), '123, Sample Street, City'),
        _line(_sec(bh, 'phone'), '+91 98765 43210'),
        _line(_sec(bh, 'gst'), 'GST: 27AABCU9603R1ZX'),
        _line(_sec(bh, 'fssai'), 'FSSAI: 12345678901234'),
        _hr(),
        _twoCol(_sec(bh, 'order_id'),   'Bill No: 1042',      'Date: 25-Nov',    leftFlex: 7, rightFlex: 5),
        _twoCol(_sec(bh, 'order_type'), 'Dine In',            'Waiter: Ravi',    leftFlex: 6, rightFlex: 6),
        _twoCol(_sec(bh, 'customer_name'), 'Rahul Kumar',     '+91 99999 00000', leftFlex: 6, rightFlex: 6),
        if (_sec(bh, 'table_number').visible)
          _line(_sec(bh, 'table_number'), 'TABLE  T-5'),
        _hr(),
        // Item header
        if (itemSec.visible) ...[
          _itemRow(itemSec.copyWith(bold: true), 'Item', 'Qty', 'Price'),
          _dottedHr(),
          _itemRow(itemSec, 'Paneer Butter Masala', '1', '₹240'),
          _itemRow(itemSec, 'Butter Naan', '2', '₹80'),
          _itemRow(itemSec, 'Veg Biryani', '1', '₹180'),
        ],
        _hr(),
        _twoCol(_sec(bf, 'item_total'),       'Item Total',        '₹500'),
        _twoCol(_sec(bf, 'discount'),         'Discount',          '-₹25'),
        _twoCol(_sec(bf, 'coupon_discount'),  'Coupon Discount',   '-₹10'),
        _twoCol(_sec(bf, 'loyalty'),          'Loyalty Points',    '-₹5'),
        _twoCol(_sec(bf, 'wallet'),           'Wallet Used',       '-₹0'),
        _twoCol(_sec(bf, 'tips'),             'Tips',              '₹20'),
        _twoCol(_sec(bf, 'service_charge'),   'Service Charge',    '₹25'),
        _twoCol(_sec(bf, 'delivery_charge'),  'Delivery Charge',   '₹0'),
        _twoCol(_sec(bf, 'packing_charge'),   'Packing Charge',    '₹10'),
        _twoCol(_sec(bf, 'subtotal'),         'Subtotal',          '₹515'),
        _twoCol(_sec(bf, 'cgst'),             'CGST (2.5%)',        '₹12.88'),
        _twoCol(_sec(bf, 'sgst'),             'SGST (2.5%)',        '₹12.88'),
        _twoCol(_sec(bf, 'vat'),              'VAT',               '₹0'),
        _hr(),
        _twoCol(_sec(bf, 'grand_total'),      'GRAND TOTAL',       '₹540.76', leftFlex: 7, rightFlex: 5, rightBold: true),
        _hr(),
        _twoCol(_sec(bf, 'payment_type'),     'Payment',           'Cash'),
        _line(_sec(bf, 'powered_by'), 'Powered by MyGenie'),
      ],
    );
  }

  Widget _kotReceipt() {
    final ks = config.kotSections;
    final itemSec = _sec(ks, 'k_items');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _line(_sec(ks, 'k_station'), 'KITCHEN'),
        _line(_sec(ks, 'k_title'), 'KOT'),
        _hr(),
        _twoCol(_sec(ks, 'k_order_id'), 'Order: #1042', '25-Nov 1:30PM', leftFlex: 6, rightFlex: 6),
        _twoCol(_sec(ks, 'k_order_type'), 'Dine In', 'Waiter: Ravi', leftFlex: 6, rightFlex: 6),
        _line(_sec(ks, 'k_customer'), 'Rahul Kumar'),
        if (_sec(ks, 'k_table').visible)
          _line(_sec(ks, 'k_table'), 'TABLE  T-5'),
        _hr(),
        if (itemSec.visible) ...[
          _itemRow(itemSec.copyWith(bold: true), 'Item', 'Qty', ''),
          _dottedHr(),
          _itemRow(itemSec, 'Paneer Butter Masala', 'x1', ''),
          _itemRow(itemSec, 'Butter Naan', 'x2', ''),
        ],
        _hr(),
        if (_sec(ks, 'k_note').visible)
          _line(_sec(ks, 'k_note'), 'Note: Less spicy please'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      children: [
        // Bill preview
        _SectionHeader(title: 'Bill preview', icon: Icons.receipt_long),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
          ),
          child: _billReceipt(),
        ),
        const SizedBox(height: 20),
        // KOT preview
        _SectionHeader(title: 'KOT preview', icon: Icons.kitchen),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
          ),
          child: _kotReceipt(),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Preview uses sample data — switch to Bill or KOT tab to edit',
            style: montserratRegular.copyWith(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Reorderable list of sections
// ─────────────────────────────────────────────────────────────
class _ReorderableList extends StatefulWidget {
  final List<BillSectionConfig> sections;
  final VoidCallback onChanged;
  const _ReorderableList({required this.sections, required this.onChanged});

  @override
  State<_ReorderableList> createState() => _ReorderableListState();
}

class _ReorderableListState extends State<_ReorderableList> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.sections.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = widget.sections.removeAt(oldIndex);
          widget.sections.insert(newIndex, item);
        });
        widget.onChanged();
      },
      itemBuilder: (context, index) {
        final section = widget.sections[index];
        return _SectionRow(
          key: ValueKey(section.id),
          section: section,
          onChanged: () {
            setState(() {});
            widget.onChanged();
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Single section row
// ─────────────────────────────────────────────────────────────
class _SectionRow extends StatefulWidget {
  final BillSectionConfig section;
  final VoidCallback onChanged;
  const _SectionRow({Key? key, required this.section, required this.onChanged})
      : super(key: key);

  @override
  State<_SectionRow> createState() => _SectionRowState();
}

class _SectionRowState extends State<_SectionRow> {
  @override
  Widget build(BuildContext context) {
    final s = widget.section;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: s.visible ? Colors.grey.shade200 : Colors.grey.shade100,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Opacity(
        opacity: s.visible ? 1.0 : 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              // drag handle — provided by ReorderableListView
              const Icon(Icons.drag_handle, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.label,
                  style: montserratMedium.copyWith(fontSize: 13, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 6),
              // Font size dropdown
              _SizeDropdown(
                value: s.size,
                onChanged: (v) {
                  setState(() => s.size = v);
                  widget.onChanged();
                },
              ),
              const SizedBox(width: 4),
              // Alignment buttons
              _AlignButtons(
                align: s.align,
                onChanged: (a) {
                  setState(() => s.align = a);
                  widget.onChanged();
                },
              ),
              const SizedBox(width: 4),
              // Bold toggle
              _IconToggle(
                icon: Icons.format_bold,
                active: s.bold,
                activeColor: ColorTheme.appColor,
                tooltip: 'Bold',
                onTap: () {
                  setState(() => s.bold = !s.bold);
                  widget.onChanged();
                },
              ),
              const SizedBox(width: 4),
              // Visible toggle — hidden for sections that must always print
              if (s.id != 'powered_by')
                _IconToggle(
                  icon: s.visible ? Icons.visibility : Icons.visibility_off,
                  active: s.visible,
                  activeColor: ColorTheme.green,
                  tooltip: s.visible ? 'Hide' : 'Show',
                  onTap: () {
                    setState(() => s.visible = !s.visible);
                    widget.onChanged();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: ColorTheme.appColor),
        const SizedBox(width: 6),
        Text(title,
            style: montserratSemiBold.copyWith(fontSize: 13, color: Colors.black54)),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: Colors.grey.shade300)),
        const SizedBox(width: 6),
        Text('drag to reorder',
            style: montserratRegular.copyWith(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class _SizeDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _SizeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isDense: true,
          style: montserratMedium.copyWith(fontSize: 12, color: Colors.black87),
          items: [1, 2, 3, 4]
              .map((s) => DropdownMenuItem(value: s, child: Text('S$s')))
              .toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

class _AlignButtons extends StatelessWidget {
  final String align;
  final ValueChanged<String> onChanged;
  const _AlignButtons({required this.align, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ['L', 'C', 'R'].map((a) {
        final active = align == a;
        return GestureDetector(
          onTap: () => onChanged(a),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: active ? ColorTheme.appColor : Colors.transparent,
              border: Border.all(
                color: active ? ColorTheme.appColor : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              a,
              style: montserratMedium.copyWith(
                fontSize: 11,
                color: active ? Colors.white : Colors.grey,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _IconToggle extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color activeColor;
  final String tooltip;
  final VoidCallback onTap;
  const _IconToggle({
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
            border: Border.all(
              color: active ? activeColor : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: active ? activeColor : Colors.grey,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Test Print bottom sheet
// ─────────────────────────────────────────────────────────────
class _TestPrintSheet extends StatefulWidget {
  final BillLayoutConfig config;
  final List<RestaurantPrinterNew> printers;
  const _TestPrintSheet({required this.config, required this.printers});

  @override
  State<_TestPrintSheet> createState() => _TestPrintSheetState();
}

class _TestPrintSheetState extends State<_TestPrintSheet> {
  int? _printingIndex;

  Future<List<int>> _buildBytes(RestaurantPrinterNew printer) async {
    final paperRoll = printer.printerPaperRoll == 58 ? 58 : 80;
    final paperSize = paperRoll == 58 ? PaperSize.mm58 : PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final gen = Generator(paperSize, profile);
    final cfg = widget.config;
    final ip80 = paperRoll == 80;
    List<int> bytes = [];

    BillSectionConfig _sec(List<BillSectionConfig> list, String id) =>
        list.firstWhere((s) => s.id == id,
            orElse: () => BillSectionConfig(id: id, label: id));

    final restaurantName = Get.find<AuthController>()
            .profileModel
            ?.restaurants
            ?.firstOrNull
            ?.name ??
        'Restaurant';

    // ── Bill test ──────────────────────────────────────────────
    final nameSec = _sec(cfg.billHeader, 'restaurant_name');
    bytes += gen.text(restaurantName,
        styles: LocalPrintConfigService.stylesFromSection(nameSec, isPaperSize80: ip80));
    bytes += gen.hr();
    bytes += gen.text('-- BILL LAYOUT TEST --',
        styles: const PosStyles(align: PosAlign.center));
    bytes += gen.hr();

    final itemSec = _sec(cfg.billHeader, 'bill_items');
    bytes += gen.row([
      PosColumn(text: 'Item', width: 7, styles: LocalPrintConfigService.stylesFromSectionWithAlign(itemSec, PosAlign.left, isPaperSize80: ip80)),
      PosColumn(text: 'Qty', width: 2, styles: LocalPrintConfigService.stylesFromSectionWithAlign(itemSec, PosAlign.left, isPaperSize80: ip80)),
      PosColumn(text: 'Price', width: 3, styles: LocalPrintConfigService.stylesFromSectionWithAlign(itemSec, PosAlign.right, isPaperSize80: ip80)),
    ]);
    bytes += gen.hr(ch: '--');
    bytes += gen.row([
      PosColumn(text: 'Sample Item', width: 7, styles: LocalPrintConfigService.stylesFromSectionWithAlign(itemSec, PosAlign.left, isPaperSize80: ip80)),
      PosColumn(text: '2', width: 2, styles: LocalPrintConfigService.stylesFromSectionWithAlign(itemSec, PosAlign.left, isPaperSize80: ip80)),
      PosColumn(text: '240.00', width: 3, styles: LocalPrintConfigService.stylesFromSectionWithAlign(itemSec, PosAlign.right, isPaperSize80: ip80)),
    ]);
    bytes += gen.hr();

    final gtSec = _sec(cfg.billFooter, 'grand_total');
    bytes += gen.row([
      PosColumn(text: 'Grand Total', width: 8, styles: LocalPrintConfigService.labelStyleFromSection(gtSec, isPaperSize80: ip80)),
      PosColumn(text: '480.00', width: 4, styles: LocalPrintConfigService.valueStyleFromSection(gtSec, isPaperSize80: ip80)),
    ]);

    final pbSec = _sec(cfg.billFooter, 'powered_by');
    bytes += gen.text('Powered by MyGenie',
        styles: LocalPrintConfigService.stylesFromSection(pbSec, isPaperSize80: ip80));

    // ── KOT test ───────────────────────────────────────────────
    bytes += gen.feed(1);
    bytes += gen.hr();
    bytes += gen.text('-- KOT LAYOUT TEST --',
        styles: const PosStyles(align: PosAlign.center));
    bytes += gen.hr();

    final kotTitleSec = _sec(cfg.kotSections, 'k_title');
    bytes += gen.text('KOT - KITCHEN',
        styles: LocalPrintConfigService.stylesFromSection(kotTitleSec, isPaperSize80: ip80));

    final kotItemSec = _sec(cfg.kotSections, 'k_items');
    bytes += gen.row([
      PosColumn(text: 'Item', width: 9, styles: LocalPrintConfigService.stylesFromSectionWithAlign(kotItemSec, PosAlign.left, isPaperSize80: ip80)),
      PosColumn(text: 'Qty', width: 3, styles: LocalPrintConfigService.stylesFromSectionWithAlign(kotItemSec, PosAlign.right, isPaperSize80: ip80)),
    ]);
    bytes += gen.hr(ch: '--');
    bytes += gen.row([
      PosColumn(text: 'Sample Item', width: 9, styles: LocalPrintConfigService.stylesFromSectionWithAlign(kotItemSec, PosAlign.left, isPaperSize80: ip80)),
      PosColumn(text: 'x2', width: 3, styles: LocalPrintConfigService.stylesFromSectionWithAlign(kotItemSec, PosAlign.right, isPaperSize80: ip80)),
    ]);

    bytes += gen.feed(3);
    bytes += gen.cut();
    return bytes;
  }

  Future<void> _print(int index, RestaurantPrinterNew printer) async {
    setState(() => _printingIndex = index);
    try {
      final bytes = await _buildBytes(printer);
      if (Platform.isIOS) {
        final wifiTarget = NetworkPrinterResolver.kotPrinter(printer);
        final mac = printer.macPrinterIp ?? '';
        final ok = await IosPrintTransport.connect(
            wifiPrinter: wifiTarget, macPrinterAddress: mac);
        if (ok) {
          await IosPrintTransport.writeBytes(bytes);
          await Future.delayed(const Duration(seconds: 2));
          await IosPrintTransport.disconnect;
          showCustomSnackBar('Test print sent', isError: false);
        } else {
          showCustomSnackBar('Could not connect to printer', isError: true);
        }
      } else {
        // Android — Bluetooth
        final mgr = PrinterManager.instance;
        await mgr.connect(
          type: PrinterType.bluetooth,
          model: BluetoothPrinterInput(
            name: printer.printerName ?? '',
            address: printer.printerIp ?? '',
            isBle: false,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        await mgr.send(type: PrinterType.bluetooth, bytes: bytes);
        await Future.delayed(const Duration(seconds: 2));
        await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
        showCustomSnackBar('Test print sent', isError: false);
      }
    } catch (e) {
      showCustomSnackBar('Print error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _printingIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.print_outlined, color: ColorTheme.appColor, size: 20),
                const SizedBox(width: 8),
                Text('Select printer for test print',
                    style: montserratSemiBold.copyWith(fontSize: 15)),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.printers.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
            itemBuilder: (_, i) {
              final p = widget.printers[i];
              final loading = _printingIndex == i;
              return ListTile(
                leading: Icon(Icons.print, color: ColorTheme.appColor),
                title: Text(p.printerName ?? 'Printer ${i + 1}',
                    style: montserratMedium.copyWith(fontSize: 14)),
                subtitle: Text(
                  '${p.areaName ?? ''} • ${p.printerPaperRoll ?? 80}mm',
                  style: montserratRegular.copyWith(fontSize: 12, color: Colors.grey),
                ),
                trailing: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.chevron_right, color: Colors.grey),
                onTap: loading ? null : () => _print(i, p),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
