import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/print_debug_controller.dart';
import 'package:mygenie_restaurant/util/styles.dart';

/// Live status bar shown at the top of the debug panel.
/// Shows socket, printer busy, queue lengths, and log counts.
class PrintDebugSummaryBar extends StatelessWidget {
  const PrintDebugSummaryBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PrintDebugController>(
      builder: (ctrl) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title row ──────────────────────────────
              Row(
                children: [
                  const Icon(Icons.bug_report_rounded,
                      color: Color(0xFF00BCD4), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'PRINT DEBUG CONSOLE',
                    style: poppinsSemiBold.copyWith(
                      fontSize: 13,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  _LiveDot(active: ctrl.socketConnected),
                  const SizedBox(width: 4),
                  Text(
                    ctrl.socketConnected ? 'Socket ON' : 'Socket OFF',
                    style: poppinsRegular.copyWith(
                      fontSize: 11,
                      color: ctrl.socketConnected
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFF44336),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ── Indicator chips ────────────────────────
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _StatusChip(
                    label: 'Printer',
                    value: ctrl.isPrinterBusy ? 'BUSY' : 'FREE',
                    color: ctrl.isPrinterBusy
                        ? const Color(0xFFF44336)
                        : const Color(0xFF4CAF50),
                    icon: Icons.print_rounded,
                  ),
                  _StatusChip(
                    label: 'OrderQ',
                    value: '${ctrl.orderQueueLen}',
                    color: ctrl.orderQueueLen > 0
                        ? const Color(0xFFFF9800)
                        : const Color(0xFF9E9E9E),
                    icon: Icons.queue_rounded,
                  ),
                  _StatusChip(
                    label: 'SocketQ',
                    value: '${ctrl.socketQueueLen}',
                    color: ctrl.socketQueueLen > 0
                        ? const Color(0xFFFF9800)
                        : const Color(0xFF9E9E9E),
                    icon: Icons.wifi_rounded,
                  ),
                  _StatusChip(
                    label: 'Total',
                    value: '${ctrl.totalCount}',
                    color: const Color(0xFF2196F3),
                    icon: Icons.list_alt_rounded,
                  ),
                  _StatusChip(
                    label: 'Errors',
                    value: '${ctrl.errorCount}',
                    color: ctrl.errorCount > 0
                        ? const Color(0xFFF44336)
                        : const Color(0xFF9E9E9E),
                    icon: Icons.error_outline_rounded,
                  ),
                  _StatusChip(
                    label: 'Warns',
                    value: '${ctrl.warnCount}',
                    color: ctrl.warnCount > 0
                        ? const Color(0xFFFF9800)
                        : const Color(0xFF9E9E9E),
                    icon: Icons.warning_amber_rounded,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Live dot indicator
// ─────────────────────────────────────────────
class _LiveDot extends StatefulWidget {
  final bool active;
  const _LiveDot({required this.active});

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFFF44336),
          shape: BoxShape.circle,
        ),
      );
    }
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF4CAF50),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Status chip
// ─────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatusChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: poppinsRegular.copyWith(
              fontSize: 10,
              color: Colors.white60,
            ),
          ),
          Text(
            value,
            style: poppinsSemiBold.copyWith(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
