import 'package:flutter/material.dart';
import 'package:mygenie_restaurant/data/model/local/bill_layout_config.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/local_print_config_service.dart';
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
    _tabController = TabController(length: 2, vsync: this);
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
      onReorderItem: (oldIndex, newIndex) {
        setState(() {
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
              // Visible toggle
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
