import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/print_debug_controller.dart';
import 'package:mygenie_restaurant/data/model/print_debug_log_model.dart';
import 'package:mygenie_restaurant/util/styles.dart';

/// Filter + Search bar for the print debug console.
class PrintDebugFilterBar extends StatefulWidget {
  const PrintDebugFilterBar({super.key});

  @override
  State<PrintDebugFilterBar> createState() => _PrintDebugFilterBarState();
}

class _PrintDebugFilterBarState extends State<PrintDebugFilterBar> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PrintDebugController>(
      builder: (ctrl) {
        return Container(
          color: const Color(0xFF12122A),
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Filter chips ───────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: ctrl.selectedFlow == PrintFlowTag.all &&
                          !ctrl.showOnlyErrors &&
                          !ctrl.showOnlyWarns,
                      onTap: ctrl.resetFilters,
                      color: const Color(0xFF2196F3),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Aggregator',
                      selected: ctrl.selectedFlow == PrintFlowTag.aggregator,
                      onTap: () => ctrl.setFlowFilter(PrintFlowTag.aggregator),
                      color: const Color(0xFF00BCD4),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Normal POS',
                      selected: ctrl.selectedFlow == PrintFlowTag.normalPos,
                      onTap: () => ctrl.setFlowFilter(PrintFlowTag.normalPos),
                      color: const Color(0xFF9C27B0),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Fixed Manual',
                      selected:
                          ctrl.selectedFlow == PrintFlowTag.fixedManual,
                      onTap: () =>
                          ctrl.setFlowFilter(PrintFlowTag.fixedManual),
                      color: const Color(0xFFFF9800),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Waiter',
                      selected: ctrl.selectedFlow == PrintFlowTag.waiter,
                      onTap: () => ctrl.setFlowFilter(PrintFlowTag.waiter),
                      color: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Bill',
                      selected: ctrl.selectedFlow == PrintFlowTag.bill,
                      onTap: () => ctrl.setFlowFilter(PrintFlowTag.bill),
                      color: const Color(0xFFFF9800),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Errors',
                      selected: ctrl.showOnlyErrors,
                      onTap: ctrl.setErrorsOnly,
                      color: const Color(0xFFF44336),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Warnings',
                      selected: ctrl.showOnlyWarns,
                      onTap: ctrl.setWarnsOnly,
                      color: const Color(0xFFFF9800),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Search bar ─────────────────────────────
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E3F),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF3A3A5C), width: 1),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    const Icon(Icons.search_rounded,
                        size: 16, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        style: poppinsRegular.copyWith(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintText:
                              'Search orderId / traceId / station / printer...',
                          hintStyle: poppinsRegular.copyWith(
                            fontSize: 11,
                            color: const Color(0xFF5C5C7A),
                          ),
                        ),
                        onChanged: (v) => ctrl.setSearch(v),
                      ),
                    ),
                    if (_searchCtrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          ctrl.setSearch('');
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.close_rounded,
                              size: 16, color: Color(0xFF9E9E9E)),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // ── Result count line ──────────────────────
              Text(
                'Showing ${ctrl.filteredLogs.length} of ${ctrl.totalCount} logs',
                style: poppinsRegular.copyWith(
                  fontSize: 10,
                  color: const Color(0xFF5C5C7A),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Individual filter chip
// ─────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: poppinsMedium.copyWith(
            fontSize: 11,
            color: selected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
