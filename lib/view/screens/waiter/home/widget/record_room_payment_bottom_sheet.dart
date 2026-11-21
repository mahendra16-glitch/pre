import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';

void showRecordRoomPaymentBottomSheet(OrderList order) {
  Get.bottomSheet(
    RecordRoomPaymentBottomSheet(order: order),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    ignoreSafeArea: false,
  );
}

class RecordRoomPaymentBottomSheet extends StatefulWidget {
  final OrderList order;

  const RecordRoomPaymentBottomSheet({super.key, required this.order});

  @override
  State<RecordRoomPaymentBottomSheet> createState() =>
      _RecordRoomPaymentBottomSheetState();
}

class _RecordRoomPaymentBottomSheetState
    extends State<RecordRoomPaymentBottomSheet> {
  static const List<String> _paymentModes = [
    'Cash',
    'Card',
    'UPI',
    'Online',
    'NEFT',
    'Razorpay',
  ];

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedMode = 'Cash';
  bool _isHistoryExpanded = false;
  bool _isSubmitting = false;

  double get _outstanding => widget.order.roomInfo?.remainingPay ?? 0;

  List<RoomPaymentRecord> get _history {
    final payments = widget.order.roomInfo?.payments;
    if (payments != null && payments.isNotEmpty) return payments;
    final advance = widget.order.roomInfo?.advancePay ?? 0;
    if (advance > 0) {
      return [
        RoomPaymentRecord(
          amount: advance,
          paymentMode: '',
          paymentType: 'advance',
          note: 'Advance payment',
        ),
      ];
    }
    return [];
  }

  String _formatAmount(double value) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: value % 1 == 0 ? 0 : 2,
    ).format(value);
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      return DateFormat('dd MMM, hh:mm a').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  Future<void> _confirmPayment() async {
    if (_isSubmitting) return;
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      showCustomSnackBar('Please enter a valid amount');
      return;
    }

    final roomOrderId = int.tryParse(widget.order.id ?? '') ?? 0;
    if (roomOrderId == 0) {
      showCustomSnackBar('Invalid room order');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await Get.find<PosController>().recordRoomPayment(
        {
          'room_order_id': roomOrderId,
          'payment_amount': amount,
          'payment_mode': _selectedMode.toLowerCase(),
          'payment_type': 'advance',
          'transaction_id': '',
          'payment_note': _noteController.text.trim(),
        },
        (success, message) {
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          if (success) {
            if (Get.isBottomSheetOpen ?? false) Get.back();
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
      showCustomSnackBar('Payment failed');
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 16, 8, 12),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: ColorTheme.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(Icons.payments_outlined,
                          size: 14, color: ColorTheme.green),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Record Payment',
                      style: poppinsSemiBold.copyWith(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                          minWidth: 32, minHeight: 32),
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close,
                          size: 18, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: ColorTheme.appColor.withOpacity(0.45)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Outstanding Balance',
                              style: poppinsMedium.copyWith(
                                fontSize: 11,
                                color: const Color(0xFF8D4B1A),
                              ),
                            ),
                            Text(
                              _formatAmount(_outstanding),
                              style: poppinsBold.copyWith(
                                fontSize: 20,
                                color: ColorTheme.appColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Amount (₹)',
                        style: poppinsMedium.copyWith(
                            fontSize: 11, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      _inputField(
                        controller: _amountController,
                        hint: 'Enter amount',
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Payment Mode',
                        style: poppinsMedium.copyWith(
                            fontSize: 11, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _paymentModes.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          childAspectRatio: 3.4,
                        ),
                        itemBuilder: (context, index) {
                          final mode = _paymentModes[index];
                          final selected = _selectedMode == mode;
                          return InkWell(
                            onTap: () => setState(() => _selectedMode = mode),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected
                                    ? ColorTheme.green.withOpacity(0.08)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: selected
                                      ? ColorTheme.green
                                      : ColorTheme.borderGrey,
                                ),
                              ),
                              child: Text(
                                mode,
                                style: poppinsMedium.copyWith(
                                  fontSize: 11,
                                  color: selected
                                      ? ColorTheme.green
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Note (optional)',
                        style: poppinsMedium.copyWith(
                            fontSize: 11, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      _inputField(
                        controller: _noteController,
                        hint: 'e.g. Partial advance Day 3',
                      ),
                      const SizedBox(height: 8),
                      // InkWell(
                      //   onTap: () => setState(
                      //       () => _isHistoryExpanded = !_isHistoryExpanded),
                      //   child: Padding(
                      //     padding: const EdgeInsets.symmetric(vertical: 4),
                      //     child: Row(
                      //       children: [
                      //         Icon(Icons.receipt_long_outlined,
                      //             size: 16, color: ColorTheme.appColor),
                      //         const SizedBox(width: 6),
                      //         Text(
                      //           'Payment History',
                      //           style: poppinsMedium.copyWith(
                      //               fontSize: 12, color: Colors.black87),
                      //         ),
                      //         const Spacer(),
                      //         Container(
                      //           padding: const EdgeInsets.symmetric(
                      //               horizontal: 6, vertical: 1),
                      //           decoration: BoxDecoration(
                      //             color: ColorTheme.appColor.withOpacity(0.12),
                      //             borderRadius: BorderRadius.circular(8),
                      //           ),
                      //           child: Text(
                      //             '${_history.length}',
                      //             style: poppinsSemiBold.copyWith(
                      //               fontSize: 11,
                      //               color: ColorTheme.appColor,
                      //             ),
                      //           ),
                      //         ),
                      //         Icon(
                      //           _isHistoryExpanded
                      //               ? Icons.keyboard_arrow_up
                      //               : Icons.keyboard_arrow_down,
                      //           size: 18,
                      //           color: ColorTheme.appColor,
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                     
                      // if (_isHistoryExpanded) _historyList(),
                      // const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _confirmPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorTheme.green,
                            disabledBackgroundColor:
                                ColorTheme.green.withOpacity(0.6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'CONFIRM PAYMENT',
                                  style: poppinsSemiBold.copyWith(
                                    fontSize: 12,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: poppinsRegular.copyWith(fontSize: 12, color: Colors.black),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: poppinsRegular.copyWith(
              fontSize: 11, color: ColorTheme.hintText),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: ColorTheme.borderGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: ColorTheme.appColor),
          ),
        ),
      ),
    );
  }

  Widget _historyList() {
    if (_history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          'No previous payments',
          style: poppinsRegular.copyWith(
              fontSize: 12, color: ColorTheme.hintText),
        ),
      );
    }
    return Column(
      children: _history.map((item) {
        final mode = item.paymentMode.isNotEmpty
            ? item.paymentMode[0].toUpperCase() +
                item.paymentMode.substring(1)
            : (item.paymentType.isNotEmpty ? item.paymentType : 'Payment');
        final date = _formatDate(item.date);
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: ColorTheme.grey200Color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode,
                      style: poppinsMedium.copyWith(
                          fontSize: 13, color: Colors.black87),
                    ),
                    if (item.note.isNotEmpty)
                      Text(
                        item.note,
                        style: poppinsRegular.copyWith(
                            fontSize: 11, color: ColorTheme.hintText),
                      ),
                    if (date.isNotEmpty)
                      Text(
                        date,
                        style: poppinsRegular.copyWith(
                            fontSize: 11, color: ColorTheme.hintText),
                      ),
                  ],
                ),
              ),
              Text(
                _formatAmount(item.amount),
                style: poppinsSemiBold.copyWith(
                    fontSize: 13, color: Colors.black),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
