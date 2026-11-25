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
// Preview tab — live receipt simulation with paper-size toggle
// ─────────────────────────────────────────────────────────────

// ESC/POS 80 mm paper: ~48 chars/line using fontA (12-dot glyphs, ~203 DPI)
// ESC/POS 58 mm paper: ~32 chars/line using fontB (9-dot glyphs, ~203 DPI)
// fontB ≈ 9/12 = 75 % the width of fontA — we scale base font to match.

class _PreviewTab extends StatefulWidget {
  final BillLayoutConfig config;
  const _PreviewTab({required this.config});

  @override
  State<_PreviewTab> createState() => _PreviewTabState();
}

class _PreviewTabState extends State<_PreviewTab>
    with AutomaticKeepAliveClientMixin {
  bool _is80mm = true;

  @override
  bool get wantKeepAlive => true;

  // Triggered when the parent rebuilds with a new config object; redraws preview.
  @override
  void didUpdateWidget(_PreviewTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  // ── font helpers ────────────────────────────────────────────
  // Preview size scale — each step is roughly ×1.3 the previous (gentle climb).
  // 80 mm fontA base ≈ 11 sp; 58 mm fontB base ≈ 9 sp.
  static const _base80 = {1: 11.0, 2: 14.0, 3: 18.0, 4: 24.0};
  static const _base58 = {1:  9.0, 2: 12.0, 3: 15.0, 4: 20.0};

  double _fs(int size) =>
      (_is80mm ? _base80 : _base58)[size.clamp(1, 4)] ?? 11.0;

  static TextAlign _align(String a) {
    switch (a) {
      case 'L': return TextAlign.left;
      case 'R': return TextAlign.right;
      default:  return TextAlign.center;
    }
  }

  TextStyle _style(BillSectionConfig s) => TextStyle(
        fontFamily: 'Courier',
        fontSize: _fs(s.size),
        fontWeight: s.bold ? FontWeight.bold : FontWeight.normal,
        color: Colors.black87,
      );

  BillSectionConfig _sec(List<BillSectionConfig> list, String id) =>
      list.firstWhere((s) => s.id == id,
          orElse: () => BillSectionConfig(id: id, label: id));

  // ── row builders ────────────────────────────────────────────

  Widget _line(BillSectionConfig s, String text) {
    if (!s.visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(text, textAlign: _align(s.align), style: _style(s)),
    );
  }

  Widget _twoCol(
    BillSectionConfig s,
    String left, String right, {
    int leftFlex = 8, int rightFlex = 4,
    bool rightBold = false,
  }) {
    if (!s.visible) return const SizedBox.shrink();
    final base = _style(s);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(children: [
        Expanded(flex: leftFlex,  child: Text(left,  style: base, textAlign: TextAlign.left,  overflow: TextOverflow.ellipsis)),
        Expanded(flex: rightFlex, child: Text(right, style: base.copyWith(fontWeight: rightBold ? FontWeight.bold : base.fontWeight), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  Widget _itemRow(BillSectionConfig s, String name, String qty, String price, {bool header = false}) {
    if (!s.visible) return const SizedBox.shrink();
    final base0 = _style(s);
    final base = header ? base0.copyWith(fontWeight: FontWeight.bold) : base0;
    // 58 mm: 3-col layout is tighter — reduce item name column slightly
    final nameFlex = _is80mm ? 7 : 6;
    final qtyFlex  = _is80mm ? 2 : 2;
    final priceFlex = _is80mm ? 3 : 4;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(children: [
        Expanded(flex: nameFlex,  child: Text(name,  style: base, textAlign: TextAlign.left,  overflow: TextOverflow.ellipsis)),
        Expanded(flex: qtyFlex,   child: Text(qty,   style: base, textAlign: TextAlign.left)),
        Expanded(flex: priceFlex, child: Text(price, style: base, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  Widget _hr() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: const Divider(height: 1, color: Colors.black54),
      );

  Widget _dottedHr() {
    // 80 mm ≈ 48 dashes at size 1; 58 mm ≈ 32 dashes
    final dashes = _is80mm ? '- ' * 24 : '- ' * 16;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(dashes,
          style: TextStyle(fontFamily: 'Courier', fontSize: _is80mm ? 10.0 : 8.5, color: Colors.black38),
          overflow: TextOverflow.clip,
          maxLines: 1),
    );
  }

  String _restaurantName() {
    try {
      return Get.find<AuthController>().profileModel?.restaurants?.firstOrNull?.name ?? 'My Restaurant';
    } catch (_) {
      return 'My Restaurant';
    }
  }

  // ── receipt contents ────────────────────────────────────────

  Widget _billReceipt() {
    final bh = widget.config.billHeader;
    final bf = widget.config.billFooter;
    final itemSec = _sec(bh, 'bill_items');
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _line(_sec(bh, 'restaurant_name'), _restaurantName()),
      _line(_sec(bh, 'address'), '123, Sample Street, City'),
      _line(_sec(bh, 'phone'), '+91 98765 43210'),
      _line(_sec(bh, 'gst'),   'GST: 27AABCU9603R1ZX'),
      _line(_sec(bh, 'fssai'), 'FSSAI: 12345678901234'),
      _hr(),
      _twoCol(_sec(bh, 'order_id'),      'Bill No: 1042', 'Date: 25-Nov',     leftFlex: 7, rightFlex: 5),
      _twoCol(_sec(bh, 'order_type'),    'Dine In',       'Waiter: Ravi',     leftFlex: 6, rightFlex: 6),
      _twoCol(_sec(bh, 'customer_name'), 'Rahul Kumar',   '+91 99999 00000',  leftFlex: 6, rightFlex: 6),
      if (_sec(bh, 'table_number').visible) _line(_sec(bh, 'table_number'), 'TABLE  T-5'),
      _hr(),
      if (itemSec.visible) ...[
        _itemRow(itemSec, 'Item', 'Qty', 'Price', header: true),
        _dottedHr(),
        _itemRow(itemSec, 'Paneer Butter Masala', '1', '₹240'),
        _itemRow(itemSec, 'Butter Naan',          '2', '₹80'),
        _itemRow(itemSec, 'Veg Biryani',          '1', '₹180'),
      ],
      _hr(),
      _twoCol(_sec(bf, 'item_total'),      'Item Total',      '₹500'),
      _twoCol(_sec(bf, 'discount'),        'Discount',        '-₹25'),
      _twoCol(_sec(bf, 'coupon_discount'), 'Coupon Discount', '-₹10'),
      _twoCol(_sec(bf, 'loyalty'),         'Loyalty Points',  '-₹5'),
      _twoCol(_sec(bf, 'wallet'),          'Wallet Used',     '-₹0'),
      _twoCol(_sec(bf, 'tips'),            'Tips',            '₹20'),
      _twoCol(_sec(bf, 'service_charge'),  'Service Charge',  '₹25'),
      _twoCol(_sec(bf, 'delivery_charge'), 'Delivery Charge', '₹0'),
      _twoCol(_sec(bf, 'packing_charge'),  'Packing Charge',  '₹10'),
      _twoCol(_sec(bf, 'subtotal'),        'Subtotal',        '₹515'),
      _twoCol(_sec(bf, 'cgst'),            'CGST (2.5%)',     '₹12.88'),
      _twoCol(_sec(bf, 'sgst'),            'SGST (2.5%)',     '₹12.88'),
      _twoCol(_sec(bf, 'vat'),             'VAT',             '₹0'),
      _hr(),
      _twoCol(_sec(bf, 'grand_total'),  'GRAND TOTAL', '₹540.76', leftFlex: 7, rightFlex: 5, rightBold: true),
      _hr(),
      _twoCol(_sec(bf, 'payment_type'), 'Payment', 'Cash'),
      _line(_sec(bf, 'powered_by'), 'Powered by MyGenie'),
    ]);
  }

  Widget _kotReceipt() {
    final ks = widget.config.kotSections;
    final itemSec = _sec(ks, 'k_items');
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _line(_sec(ks, 'k_station'), 'KITCHEN'),
      _line(_sec(ks, 'k_title'),   'KOT'),
      _hr(),
      _twoCol(_sec(ks, 'k_order_id'),   'Order: #1042', '25-Nov 1:30PM', leftFlex: 6, rightFlex: 6),
      _twoCol(_sec(ks, 'k_order_type'), 'Dine In',      'Waiter: Ravi',  leftFlex: 6, rightFlex: 6),
      _line(_sec(ks, 'k_customer'), 'Rahul Kumar'),
      if (_sec(ks, 'k_table').visible) _line(_sec(ks, 'k_table'), 'TABLE  T-5'),
      _hr(),
      if (itemSec.visible) ...[
        _itemRow(itemSec, 'Item', 'Qty', '', header: true),
        _dottedHr(),
        _itemRow(itemSec, 'Paneer Butter Masala', 'x1', ''),
        _itemRow(itemSec, 'Butter Naan',          'x2', ''),
      ],
      _hr(),
      if (_sec(ks, 'k_note').visible)
        _line(_sec(ks, 'k_note'), 'Note: Less spicy please'),
    ]);
  }

  // ── paper-size ruler ────────────────────────────────────────
  // 80 mm printable area ≈ 72 mm; 58 mm ≈ 48 mm
  // We fill the available width for 80 mm and scale 58 mm proportionally.

  Widget _receipt(String label, IconData icon, Widget body, double receiptW) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionHeader(title: label, icon: icon),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: receiptW,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: body,
        ),
      ),
    ]);
  }

  @override
  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    // Max width available minus outer padding
    final screenW = MediaQuery.of(context).size.width;
    final maxW = (screenW - 32).clamp(200.0, 420.0);
    // 80 mm receipt takes all available; 58 mm is 58/80 ≈ 72.5 % as wide
    final receiptW = _is80mm ? maxW : maxW * 58 / 80;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // ── paper-size toggle ──────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Paper size:', style: montserratMedium.copyWith(fontSize: 13, color: Colors.black54)),
            const SizedBox(width: 10),
            _PaperChip(label: '80 mm', selected: _is80mm,  onTap: () => setState(() => _is80mm = true)),
            const SizedBox(width: 6),
            _PaperChip(label: '58 mm', selected: !_is80mm, onTap: () => setState(() => _is80mm = false)),
          ],
        ),
        // ── paper width ruler ──────────────────────────────────
        const SizedBox(height: 8),
        _PaperRuler(receiptW: receiptW, maxW: maxW, is80mm: _is80mm),
        const SizedBox(height: 16),
        // ── bill ──────────────────────────────────────────────
        _receipt('Bill preview', Icons.receipt_long, _billReceipt(), receiptW),
        const SizedBox(height: 20),
        // ── KOT ───────────────────────────────────────────────
        _receipt('KOT preview', Icons.kitchen, _kotReceipt(), receiptW),
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

// Small chip for paper-size toggle
class _PaperChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PaperChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? ColorTheme.appColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? ColorTheme.appColor : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: montserratSemiBold.copyWith(
            fontSize: 13,
            color: selected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}

// Visual ruler showing the paper width proportionally
class _PaperRuler extends StatelessWidget {
  final double receiptW;
  final double maxW;
  final bool is80mm;
  const _PaperRuler({required this.receiptW, required this.maxW, required this.is80mm});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // background full-width bar
          Container(
            width: maxW,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // active width bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: receiptW,
            height: 6,
            decoration: BoxDecoration(
              color: ColorTheme.appColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // label
          Positioned(
            left: receiptW + 6,
            child: Text(
              is80mm ? '80 mm' : '58 mm',
              style: montserratRegular.copyWith(fontSize: 10, color: ColorTheme.appColor),
            ),
          ),
        ],
      ),
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
  bool _billMode = true; // true = Bill test, false = KOT test

  BillSectionConfig _sec(List<BillSectionConfig> list, String id) =>
      list.firstWhere((s) => s.id == id,
          orElse: () => BillSectionConfig(id: id, label: id));

  String get _restaurantName =>
      Get.find<AuthController>().profileModel?.restaurants?.firstOrNull?.name ??
      'Restaurant';

  // ── Bill test ────────────────────────────────────────────────
  Future<List<int>> _buildBillBytes(RestaurantPrinterNew printer) async {
    final paperRoll = printer.printerPaperRoll == 58 ? 58 : 80;
    final ip80 = paperRoll == 80;
    final lineChars = ip80 ? 48 : 32;
    final gen = Generator(
        paperRoll == 58 ? PaperSize.mm58 : PaperSize.mm80,
        await CapabilityProfile.load());
    final bh = widget.config.billHeader;
    final bf = widget.config.billFooter;
    List<int> bytes = [];

    // Footer row with overflow guard
    List<int> fr(BillSectionConfig sec, String label, String value) {
      if (!sec.visible) return [];
      final maxLabel = (8 * lineChars / 12 / sec.size).floor();
      if (label.length > maxLabel) {
        return [
          ...gen.text(label, styles: LocalPrintConfigService.labelStyleFromSection(sec, isPaperSize80: ip80)),
          ...gen.text(value, styles: LocalPrintConfigService.valueStyleFromSection(sec, isPaperSize80: ip80)),
        ];
      }
      return gen.row([
        PosColumn(text: label, width: 8, styles: LocalPrintConfigService.labelStyleFromSection(sec, isPaperSize80: ip80)),
        PosColumn(text: value, width: 4, styles: LocalPrintConfigService.valueStyleFromSection(sec, isPaperSize80: ip80)),
      ]);
    }

    // Two-column header row
    List<int> twoCol(BillSectionConfig sec, String left, String right, {int lw = 7, int rw = 5}) {
      if (!sec.visible) return [];
      return gen.row([
        PosColumn(text: left,  width: lw, styles: LocalPrintConfigService.stylesFromSectionWithAlign(sec, PosAlign.left,  isPaperSize80: ip80)),
        PosColumn(text: right, width: rw, styles: LocalPrintConfigService.stylesFromSectionWithAlign(sec, PosAlign.right, isPaperSize80: ip80)),
      ]);
    }

    void txt(BillSectionConfig sec, String text) {
      if (sec.visible)
        bytes += gen.text(text, styles: LocalPrintConfigService.stylesFromSection(sec, isPaperSize80: ip80));
    }

    txt(_sec(bh, 'restaurant_name'), _restaurantName);
    txt(_sec(bh, 'address'),  '123, Sample Street, City');
    txt(_sec(bh, 'phone'),    '+91 98765 43210');
    txt(_sec(bh, 'gst'),     'GST: 27AABCU9603R1ZX');
    txt(_sec(bh, 'fssai'),   'FSSAI: 12345678901234');
    bytes += gen.hr();
    bytes += twoCol(_sec(bh, 'order_id'),      'Bill No: 1042', '25-Nov');
    bytes += twoCol(_sec(bh, 'order_type'),    'Dine In',       'Waiter: Ravi');
    bytes += twoCol(_sec(bh, 'customer_name'), 'Rahul Kumar',   '+91 99999 00000');
    txt(_sec(bh, 'table_number'), 'TABLE  T-5');
    bytes += gen.hr();

    final itemSec = _sec(bh, 'bill_items');
    if (itemSec.visible) {
      bytes += gen.row([
        PosColumn(text: 'Item',  width: 7, styles: LocalPrintConfigService.stylesFromSectionWithAlign(itemSec, PosAlign.left,  isPaperSize80: ip80)),
        PosColumn(text: 'Qty',   width: 2, styles: LocalPrintConfigService.stylesFromSectionWithAlign(itemSec, PosAlign.left,  isPaperSize80: ip80)),
        PosColumn(text: 'Price', width: 3, styles: LocalPrintConfigService.stylesFromSectionWithAlign(itemSec, PosAlign.right, isPaperSize80: ip80)),
      ]);
      bytes += gen.hr(ch: '--');
      for (final row in [['Paneer Masala', '1', '240.00'], ['Butter Naan', '2', '80.00']]) {
        bytes += gen.row([
          PosColumn(text: row[0], width: 7, styles: LocalPrintConfigService.stylesFromSectionWithAlign(itemSec, PosAlign.left,  isPaperSize80: ip80)),
          PosColumn(text: row[1], width: 2, styles: LocalPrintConfigService.stylesFromSectionWithAlign(itemSec, PosAlign.left,  isPaperSize80: ip80)),
          PosColumn(text: row[2], width: 3, styles: LocalPrintConfigService.stylesFromSectionWithAlign(itemSec, PosAlign.right, isPaperSize80: ip80)),
        ]);
      }
    }
    bytes += gen.hr();
    bytes += fr(_sec(bf, 'item_total'),      'Item Total',      '500.00');
    bytes += fr(_sec(bf, 'discount'),        'Discount',        '-25.00');
    bytes += fr(_sec(bf, 'coupon_discount'), 'Coupon Discount', '-10.00');
    bytes += fr(_sec(bf, 'loyalty'),         'Loyalty Points',  '-5.00');
    bytes += fr(_sec(bf, 'wallet'),          'Wallet Used',     '-0.00');
    bytes += fr(_sec(bf, 'tips'),            'Tips',            '20.00');
    bytes += fr(_sec(bf, 'service_charge'),  'Service Charge',  '25.00');
    bytes += fr(_sec(bf, 'delivery_charge'), 'Delivery Charge', '0.00');
    bytes += fr(_sec(bf, 'packing_charge'),  'Packing Charge',  '10.00');
    bytes += fr(_sec(bf, 'subtotal'),        'Subtotal',        '515.00');
    bytes += fr(_sec(bf, 'cgst'),            'CGST (2.5%)',     '12.88');
    bytes += fr(_sec(bf, 'sgst'),            'SGST (2.5%)',     '12.88');
    bytes += fr(_sec(bf, 'vat'),             'VAT',             '0.00');
    bytes += gen.hr(ch: '....');
    final gtSec = _sec(bf, 'grand_total');
    if (gtSec.visible) {
      final maxGt = (8 * lineChars / 12 / gtSec.size).floor();
      if ('Grand Total'.length > maxGt) {
        bytes += gen.text('Grand Total', styles: LocalPrintConfigService.labelStyleFromSection(gtSec, isPaperSize80: ip80));
        bytes += gen.text('540.76',      styles: LocalPrintConfigService.valueStyleFromSection(gtSec, isPaperSize80: ip80));
      } else {
        bytes += gen.row([
          PosColumn(text: 'Grand Total', width: 8, styles: LocalPrintConfigService.labelStyleFromSection(gtSec, isPaperSize80: ip80)),
          PosColumn(text: '540.76',      width: 4, styles: LocalPrintConfigService.valueStyleFromSection(gtSec, isPaperSize80: ip80)),
        ]);
      }
    }
    bytes += fr(_sec(bf, 'payment_type'), 'Payment', 'Cash');
    txt(_sec(bf, 'powered_by'), 'Powered by MyGenie');
    bytes += gen.feed(3);
    bytes += gen.cut();
    return bytes;
  }

  // ── KOT test ─────────────────────────────────────────────────
  Future<List<int>> _buildKotBytes(RestaurantPrinterNew printer) async {
    final paperRoll = printer.printerPaperRoll == 58 ? 58 : 80;
    final ip80 = paperRoll == 80;
    final gen = Generator(
        paperRoll == 58 ? PaperSize.mm58 : PaperSize.mm80,
        await CapabilityProfile.load());
    final ks = widget.config.kotSections;
    List<int> bytes = [];

    List<int> twoCol(BillSectionConfig sec, String left, String right) {
      if (!sec.visible) return [];
      return gen.row([
        PosColumn(text: left,  width: 6, styles: LocalPrintConfigService.stylesFromSectionWithAlign(sec, PosAlign.left,  isPaperSize80: ip80)),
        PosColumn(text: right, width: 6, styles: LocalPrintConfigService.stylesFromSectionWithAlign(sec, PosAlign.right, isPaperSize80: ip80)),
      ]);
    }

    void txt(BillSectionConfig sec, String text) {
      if (sec.visible)
        bytes += gen.text(text, styles: LocalPrintConfigService.stylesFromSection(sec, isPaperSize80: ip80));
    }

    txt(_sec(ks, 'k_station'), 'KITCHEN');
    txt(_sec(ks, 'k_title'),   'KOT');
    bytes += gen.hr();
    bytes += twoCol(_sec(ks, 'k_order_id'),   'Order: #1042', '25-Nov 1:30PM');
    bytes += twoCol(_sec(ks, 'k_order_type'), 'Dine In',      'Waiter: Ravi');
    txt(_sec(ks, 'k_customer'), 'Rahul Kumar');
    txt(_sec(ks, 'k_table'),    'TABLE  T-5');
    bytes += gen.hr();

    final itemSec = _sec(ks, 'k_items');
    if (itemSec.visible) {
      bytes += gen.row([
        PosColumn(text: 'Item', width: 9, styles: LocalPrintConfigService.stylesFromSectionWithAlign(itemSec, PosAlign.left,  isPaperSize80: ip80)),
        PosColumn(text: 'Qty',  width: 3, styles: LocalPrintConfigService.stylesFromSectionWithAlign(itemSec, PosAlign.right, isPaperSize80: ip80)),
      ]);
      bytes += gen.hr(ch: '--');
      bytes += gen.row([
        PosColumn(text: 'Paneer Masala', width: 9, styles: LocalPrintConfigService.stylesFromSectionWithAlign(itemSec, PosAlign.left,  isPaperSize80: ip80)),
        PosColumn(text: 'x1',            width: 3, styles: LocalPrintConfigService.stylesFromSectionWithAlign(itemSec, PosAlign.right, isPaperSize80: ip80)),
      ]);
      bytes += gen.row([
        PosColumn(text: 'Butter Naan', width: 9, styles: LocalPrintConfigService.stylesFromSectionWithAlign(itemSec, PosAlign.left,  isPaperSize80: ip80)),
        PosColumn(text: 'x2',          width: 3, styles: LocalPrintConfigService.stylesFromSectionWithAlign(itemSec, PosAlign.right, isPaperSize80: ip80)),
      ]);
    }
    bytes += gen.hr();
    txt(_sec(ks, 'k_note'), 'Note: Less spicy');
    bytes += gen.feed(3);
    bytes += gen.cut();
    return bytes;
  }

  Future<void> _print(int index, RestaurantPrinterNew printer) async {
    setState(() => _printingIndex = index);
    try {
      final bytes = _billMode
          ? await _buildBillBytes(printer)
          : await _buildKotBytes(printer);
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
                Text('Test print',
                    style: montserratSemiBold.copyWith(fontSize: 15)),
                const Spacer(),
                _PaperChip(
                  label: 'Bill', selected: _billMode,
                  onTap: () => setState(() => _billMode = true),
                ),
                const SizedBox(width: 6),
                _PaperChip(
                  label: 'KOT', selected: !_billMode,
                  onTap: () => setState(() => _billMode = false),
                ),
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
                        width: 20, height: 20,
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
