import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/print_debug_controller.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'print_debug_filter_bar.dart';
import 'print_debug_log_tile.dart';
import 'print_debug_summary_bar.dart';

// ─────────────────────────────────────────────────────────────
//  Entry point
//  Call PrintDebugPanel.show(context) from anywhere to open.
// ─────────────────────────────────────────────────────────────
class PrintDebugPanel {
  PrintDebugPanel._();

  /// Opens the debug console as a full-screen page.
  /// Suitable for both mobile and tablet/desktop.
  static Future<void> show(BuildContext context) async {
    // Ensure controller is registered
    PrintDebugController.ensure();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _PrintDebugConsolePage(),
        fullscreenDialog: true,
      ),
    );
  }

  /// Opens as a bottom sheet (useful for quick access on tablet).
  static Future<void> showSheet(BuildContext context) async {
    PrintDebugController.ensure();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PrintDebugSheetContent(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Full screen page
// ─────────────────────────────────────────────────────────────
class _PrintDebugConsolePage extends StatelessWidget {
  const _PrintDebugConsolePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.bug_report_rounded,
                color: Color(0xFF00BCD4), size: 20),
            const SizedBox(width: 8),
            Text(
              'Print Debug Console',
              style: poppinsSemiBold.copyWith(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: const [
          _ClearButton(),
          _CopyAllButton(),
          SizedBox(width: 6),
        ],
      ),
      body: const _ConsoleBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Bottom sheet content (80% height)
// ─────────────────────────────────────────────────────────────
class _PrintDebugSheetContent extends StatelessWidget {
  const _PrintDebugSheetContent();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.85;
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F23),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A5C),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.bug_report_rounded,
                    color: Color(0xFF00BCD4), size: 18),
                const SizedBox(width: 6),
                Text(
                  'Print Debug Console',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                const _ClearButton(),
                const _CopyAllButton(),
              ],
            ),
          ),

          // Body
          const Expanded(child: _ConsoleBody(showSummaryTop: false)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Console body  (shared between full-screen and sheet)
// ─────────────────────────────────────────────────────────────
class _ConsoleBody extends StatelessWidget {
  final bool showSummaryTop;
  const _ConsoleBody({this.showSummaryTop = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Summary status bar
        if (showSummaryTop) const PrintDebugSummaryBar(),

        // Filter + search bar
        const PrintDebugFilterBar(),

        // Log list
        const Expanded(child: _LogList()),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Scrollable list of log tiles
// ─────────────────────────────────────────────────────────────
class _LogList extends StatefulWidget {
  const _LogList();

  @override
  State<_LogList> createState() => _LogListState();
}

class _LogListState extends State<_LogList> {
  final ScrollController _scrollCtrl = ScrollController();
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      // If user scrolls up, disable auto-scroll
      if (_scrollCtrl.position.pixels <
          _scrollCtrl.position.maxScrollExtent - 60) {
        if (_autoScroll) setState(() => _autoScroll = false);
      } else {
        if (!_autoScroll) setState(() => _autoScroll = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PrintDebugController>(
      builder: (ctrl) {
        final logs = ctrl.filteredLogs;

        if (logs.isEmpty) {
          return _EmptyState();
        }

        // Auto scroll to newest (top, since list is reversed)
        if (_autoScroll) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollCtrl.hasClients) {
              _scrollCtrl.animateTo(
                0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            }
          });
        }

        return Stack(
          children: [
            ListView.builder(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 80, top: 6),
              itemCount: logs.length,
              itemBuilder: (_, i) =>
                  PrintDebugLogTile(key: ValueKey(logs[i].id), entry: logs[i]),
            ),

            // Auto-scroll indicator
            if (!_autoScroll)
              Positioned(
                bottom: 16,
                right: 16,
                child: _ScrollToTopButton(onTap: _scrollToTop),
              ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Empty state
// ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 56,
            color: const Color(0xFF3A3A5C),
          ),
          const SizedBox(height: 12),
          Text(
            'No logs yet',
            style: poppinsSemiBold.copyWith(
              fontSize: 16,
              color: const Color(0xFF5C5C7A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Logs will appear here as print events occur.',
            style: poppinsRegular.copyWith(
              fontSize: 12,
              color: const Color(0xFF3A3A5C),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Scroll-to-top FAB
// ─────────────────────────────────────────────────────────────
class _ScrollToTopButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ScrollToTopButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x552196F3),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_upward_rounded,
                size: 14, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              'New logs',
              style: poppinsMedium.copyWith(
                fontSize: 11,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Action buttons in app bar
// ─────────────────────────────────────────────────────────────
class _ClearButton extends StatelessWidget {
  const _ClearButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Clear all logs',
      icon: const Icon(Icons.delete_sweep_rounded, size: 20),
      color: const Color(0xFFF44336),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            title: Text(
              'Clear all logs?',
              style: poppinsSemiBold.copyWith(color: Colors.white),
            ),
            content: Text(
              'This will remove all ${PrintDebugController.instance.totalCount} log entries.',
              style: poppinsRegular.copyWith(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                    style: poppinsRegular.copyWith(
                        color: const Color(0xFF9E9E9E))),
              ),
              TextButton(
                onPressed: () {
                  PrintDebugController.instance.clearAll();
                  Navigator.pop(context);
                },
                child: Text('Clear',
                    style: poppinsSemiBold.copyWith(
                        color: const Color(0xFFF44336))),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CopyAllButton extends StatelessWidget {
  const _CopyAllButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Copy all logs',
      icon: const Icon(Icons.copy_all_rounded, size: 20),
      color: const Color(0xFF4CAF50),
      onPressed: () {
        final text = PrintDebugController.instance.buildExportText();
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'All logs copied (${PrintDebugController.instance.totalCount} entries)',
              style: poppinsRegular.copyWith(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1A1A2E),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Convenience button widget – drop into any AppBar or drawer
// ─────────────────────────────────────────────────────────────

/// Drop this widget anywhere to open the debug console.
///
/// Example in AppBar actions:
///   PrintDebugOpenButton()
class PrintDebugOpenButton extends StatelessWidget {
  /// If true, shows as an IconButton (for AppBar).
  /// If false, shows as a full ListTile row (for drawer).
  final bool compact;
  const PrintDebugOpenButton({super.key, this.compact = true});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return GetBuilder<PrintDebugController>(
        builder: (ctrl) {
          final hasErrors = ctrl.errorCount > 0;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'Print Debug Console',
                icon: Icon(
                  Icons.bug_report_rounded,
                  color: hasErrors
                      ? const Color(0xFFF44336)
                      : const Color(0xFF9E9E9E),
                  size: 22,
                ),
                onPressed: () => PrintDebugPanel.show(context),
              ),
              // Error badge
              if (hasErrors)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF44336),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }

    // Drawer row style
    return GetBuilder<PrintDebugController>(
      builder: (ctrl) => ListTile(
        leading: Icon(
          Icons.bug_report_rounded,
          color: ctrl.errorCount > 0
              ? const Color(0xFFF44336)
              : const Color(0xFF9E9E9E),
        ),
        title: Row(
          children: [
            Text(
              'Print Debug Console',
              style: poppinsMedium.copyWith(fontSize: 13),
            ),
            if (ctrl.errorCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF44336),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${ctrl.errorCount} err',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${ctrl.totalCount} logs  •  ${ctrl.warnCount} warns',
          style: poppinsRegular.copyWith(
            fontSize: 11,
            color: const Color(0xFF9E9E9E),
          ),
        ),
        onTap: () => PrintDebugPanel.show(context),
      ),
    );
  }
}
