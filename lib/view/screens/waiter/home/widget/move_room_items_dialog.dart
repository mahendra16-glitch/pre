import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';

void showMoveRoomItemsDialog(OrderList order) {
  Get.dialog(
    MoveRoomItemsDialog(order: order),
    barrierDismissible: true,
  );
}

class MoveRoomItemsDialog extends StatefulWidget {
  final OrderList order;

  const MoveRoomItemsDialog({super.key, required this.order});

  @override
  State<MoveRoomItemsDialog> createState() => _MoveRoomItemsDialogState();
}

class _MoveRoomItemsDialogState extends State<MoveRoomItemsDialog> {
  final TextEditingController _remarkController = TextEditingController();
  final Set<int> _selectedIds = {};
  bool _isSubmitting = false;

  List<OrderDetails> get _items => widget.order.orderDetails ?? [];

  bool _isCheckIn(OrderDetails item) {
    final name = (item.foodDetails?.name ?? '').toUpperCase().trim();
    return name == 'CHECK IN' ||
        name == 'CHECKIN' ||
        name.contains('ROOM STAY');
  }

  double _lineTotal(OrderDetails item) {
    if ((item.price ?? 0) > 0) return item.price!;
    return (item.unitPrice ?? 0) * (item.quantity ?? 0);
  }

  double get _movingTotal {
    double total = 0;
    for (final item in _items) {
      if (_selectedIds.contains(item.id)) total += _lineTotal(item);
    }
    return total;
  }

  String _formatAmount(double value) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format(value);
  }

  Future<void> _submit() async {
    if (_isSubmitting || _selectedIds.isEmpty) return;
    final orderId = int.tryParse(widget.order.id ?? '') ?? 0;
    final roomId = widget.order.restaurantTable?.id ?? widget.order.tableId ?? 0;
    if (orderId == 0 || roomId == 0) {
      showCustomSnackBar('Invalid room order');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await Get.find<PosController>().splitRoomOrder(
        {
          'order_id': orderId,
          'room_id': roomId,
          'order_detail_ids': _selectedIds.toList(),
          'remark': _remarkController.text.trim(),
        },
        (success, message) {
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          if (success) {
            if (Get.isDialogOpen ?? false) Get.back();
            if (message.isNotEmpty) {
              showCustomSnackBar(message, isError: false);
            }
          } else {
            showCustomSnackBar(message);
          }
        },
      );
    } catch (_) {
      if (mounted) setState(() => _isSubmitting = false);
      showCustomSnackBar('Failed to move items');
    }
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _selectedIds.isNotEmpty && !_isSubmitting;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 8, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: ColorTheme.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.swap_horiz,
                          size: 18, color: ColorTheme.green),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Move Items to Table',
                            style: poppinsSemiBold.copyWith(
                                fontSize: 15, color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Moving from ',
                                style: poppinsRegular.copyWith(
                                    fontSize: 11, color: ColorTheme.hintText),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: ColorTheme.appColor),
                                ),
                                child: Text(
                                  'Room',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 10,
                                      color: ColorTheme.appColor),
                                ),
                              ),
                              Text(
                                '  · Select items to split out',
                                style: poppinsRegular.copyWith(
                                    fontSize: 11, color: ColorTheme.hintText),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close,
                          size: 18, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SELECT ITEMS TO MOVE',
                        style: poppinsMedium.copyWith(
                            fontSize: 10,
                            color: ColorTheme.hintText,
                            letterSpacing: 0.4),
                      ),
                      const SizedBox(height: 8),
                      ..._items.map(_itemTile),
                      const SizedBox(height: 12),
                      Text(
                        'NOTE (OPTIONAL)',
                        style: poppinsMedium.copyWith(
                            fontSize: 10,
                            color: ColorTheme.hintText,
                            letterSpacing: 0.4),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _remarkController,
                          style: poppinsRegular.copyWith(
                              fontSize: 12, color: Colors.black),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'e.g. friends paying separately...',
                            hintStyle: poppinsRegular.copyWith(
                                fontSize: 11, color: ColorTheme.hintText),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide:
                                  BorderSide(color: ColorTheme.borderGrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide:
                                  BorderSide(color: ColorTheme.appColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Moving',
                          style: poppinsRegular.copyWith(
                              fontSize: 11, color: ColorTheme.hintText),
                        ),
                        Text(
                          _formatAmount(_movingTotal),
                          style: poppinsBold.copyWith(
                              fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ColorTheme.borderGrey),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text('Cancel',
                          style: poppinsMedium.copyWith(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: canSubmit ? _submit : null,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.swap_horiz, size: 16),
                      label: Text(
                        _selectedIds.isEmpty
                            ? 'Select items'
                            : 'Move ${_selectedIds.length} item${_selectedIds.length == 1 ? '' : 's'}',
                        style: poppinsMedium.copyWith(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorTheme.green,
                        disabledBackgroundColor: ColorTheme.borderGrey,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemTile(OrderDetails item) {
    final isCheckIn = _isCheckIn(item);
    final selected = _selectedIds.contains(item.id);
    final name = item.foodDetails?.name ?? '';
    final qty = item.quantity ?? 0;
    final unit = item.unitPrice ??
        ((qty > 0) ? _lineTotal(item) / qty : _lineTotal(item));
    final total = _lineTotal(item);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: isCheckIn || item.id == null
            ? null
            : () {
                setState(() {
                  if (selected) {
                    _selectedIds.remove(item.id);
                  } else {
                    _selectedIds.add(item.id!);
                  }
                });
              },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isCheckIn ? const Color(0xFFF7F7F7) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? ColorTheme.green : ColorTheme.borderGrey,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? ColorTheme.green : Colors.transparent,
                  border: Border.all(
                    color: isCheckIn
                        ? ColorTheme.borderGrey
                        : (selected
                            ? ColorTheme.green
                            : ColorTheme.borderGrey1),
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCheckIn ? 'Room Stay Marker' : name,
                      style: poppinsMedium.copyWith(
                        fontSize: 12,
                        color: isCheckIn ? ColorTheme.hintText : Colors.black,
                      ),
                    ),
                    Text(
                      isCheckIn
                          ? 'Check-in item — cannot be moved'
                          : '${qty.toStringAsFixed(qty % 1 == 0 ? 0 : 1)} × ${_formatAmount(unit)}',
                      style: poppinsRegular.copyWith(
                          fontSize: 10, color: ColorTheme.hintText),
                    ),
                  ],
                ),
              ),
              if (isCheckIn)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ColorTheme.borderGrey.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'excluded',
                    style: poppinsMedium.copyWith(
                        fontSize: 10, color: ColorTheme.hintText),
                  ),
                )
              else
                Text(
                  _formatAmount(total),
                  style: poppinsSemiBold.copyWith(
                      fontSize: 12, color: Colors.black),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
