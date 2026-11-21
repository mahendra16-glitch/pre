import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mygenie_restaurant/data/model/print_debug_log_model.dart';
import 'package:mygenie_restaurant/util/styles.dart';

/// A single collapsible log row in the print debug console.
///
/// Collapsed  → shows:  time  |  level badge  |  event  |  summary
/// Expanded   → shows full detail key-value table
class PrintDebugLogTile extends StatefulWidget {
  final PrintDebugLogEntry entry;
  const PrintDebugLogTile({super.key, required this.entry});

  @override
  State<PrintDebugLogTile> createState() => _PrintDebugLogTileState();
}

class _PrintDebugLogTileState extends State<PrintDebugLogTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animCtrl;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _animCtrl.forward() : _animCtrl.reverse();
  }

  PrintDebugLogEntry get e => widget.entry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: e.level.bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: e.level.color.withOpacity(_expanded ? 0.6 : 0.25),
            width: _expanded ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Collapsed row ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Time
                  Text(
                    e.timeLabel,
                    style: poppinsRegular.copyWith(
                      fontSize: 10,
                      color: const Color(0xFF5C5C7A),
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Level badge
                  _LevelBadge(entry: e),
                  const SizedBox(width: 8),

                  // Event tag
                  _EventTag(label: e.event, color: e.level.color),
                  const SizedBox(width: 8),

                  // Summary
                  Expanded(
                    child: Text(
                      e.summary,
                      style: poppinsRegular.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF2E2E2E),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),

                  // Flow tag
                  if (e.flow != PrintFlowTag.all)
                    _FlowTag(flow: e.flow),

                  const SizedBox(width: 4),

                  // Expand arrow
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: e.level.color,
                    ),
                  ),
                ],
              ),
            ),

            // ── Expanded detail ───────────────────────────
            SizeTransition(
              sizeFactor: _expandAnim,
              child: _ExpandedDetail(entry: e),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Level badge
// ─────────────────────────────────────────────
class _LevelBadge extends StatelessWidget {
  final PrintDebugLogEntry entry;
  const _LevelBadge({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: entry.level.color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(entry.level.icon, size: 10, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            entry.level.label,
            style: poppinsSemiBold.copyWith(
              fontSize: 9,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Event tag
// ─────────────────────────────────────────────
class _EventTag extends StatelessWidget {
  final String label;
  final Color color;
  const _EventTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Text(
        label,
        style: poppinsMedium.copyWith(
          fontSize: 9,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Flow tag
// ─────────────────────────────────────────────
class _FlowTag extends StatelessWidget {
  final PrintFlowTag flow;
  const _FlowTag({required this.flow});

  Color get _color {
    switch (flow) {
      case PrintFlowTag.aggregator:
        return const Color(0xFF00BCD4);
      case PrintFlowTag.normalPos:
        return const Color(0xFF9C27B0);
      case PrintFlowTag.fixedManual:
        return const Color(0xFFFF9800);
      case PrintFlowTag.waiter:
        return const Color(0xFF4CAF50);
      case PrintFlowTag.bill:
        return const Color(0xFFFF5722);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        flow.label.toUpperCase(),
        style: poppinsMedium.copyWith(
          fontSize: 8,
          color: _color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Expanded detail section
// ─────────────────────────────────────────────
class _ExpandedDetail extends StatelessWidget {
  final PrintDebugLogEntry entry;
  const _ExpandedDetail({required this.entry});

  @override
  Widget build(BuildContext context) {
    final flat = entry.flatDetails;
    if (flat.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(9),
          bottomRight: Radius.circular(9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: entry.level.color.withOpacity(0.2),
          ),

          // Full message if long
          if (entry.message != null && entry.message!.length > 60)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: SelectableText(
                entry.message!,
                style: poppinsRegular.copyWith(
                  fontSize: 11,
                  color: const Color(0xFF2E2E2E),
                ),
              ),
            ),

          // Key-value rows
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: flat.entries.map((e) => _KVChip(k: e.key, v: e.value)).toList(),
            ),
          ),

          // Copy to clipboard
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: _buildCopyText()));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Log entry copied to clipboard'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.copy_rounded,
                        size: 12, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 3),
                    Text(
                      'Copy',
                      style: poppinsRegular.copyWith(
                        fontSize: 10,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildCopyText() {
    final buf = StringBuffer();
    buf.writeln('[${entry.timeLabel}] [${entry.level.label}] [${entry.event}] trace=${entry.traceId}');
    buf.writeln('${entry.message ?? ''}');
    entry.flatDetails.forEach((k, v) => buf.writeln('  $k: $v'));
    return buf.toString();
  }
}

// ─────────────────────────────────────────────
//  Key-value chip in detail
// ─────────────────────────────────────────────
class _KVChip extends StatelessWidget {
  final String k;
  final String v;
  const _KVChip({required this.k, required this.v});

  Color get _valueColor {
    if (v == 'true' || v == 'Yes' || v == 'success' || v == 'yes') {
      return const Color(0xFF4CAF50);
    }
    if (v == 'false' || v == 'No' || v == 'no') {
      return const Color(0xFFF44336);
    }
    if (v.contains('FAILED') || v.contains('ERROR') || v.contains('fail')) {
      return const Color(0xFFF44336);
    }
    return const Color(0xFF2E2E2E);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$k: ',
              style: poppinsRegular.copyWith(
                fontSize: 10,
                color: const Color(0xFF9E9E9E),
              ),
            ),
            TextSpan(
              text: v,
              style: poppinsMedium.copyWith(
                fontSize: 10,
                color: _valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
