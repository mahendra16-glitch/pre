import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:flutter/material.dart';

class CustomAutoCompleteWidget extends StatefulWidget {
  final void Function(String)? onSelected;
  final String hintText;
  final List list;
  final TextEditingController? customTextEditingController;
  final String? appToastMessage, validatorText;
  final bool isEnabled;
  final bool filled;
  final Color? fillColor;

  const CustomAutoCompleteWidget(
      {Key? key,
      this.onSelected,
      required this.list,
      this.fillColor,
      this.validatorText,
      this.filled = false,
      this.isEnabled = true,
      required this.hintText,
      this.customTextEditingController,
      this.appToastMessage})
      : super(key: key);

  @override
  State<CustomAutoCompleteWidget> createState() =>
      _CustomAutoCompleteWidgetState();
}

class _CustomAutoCompleteWidgetState extends State<CustomAutoCompleteWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AbsorbPointer(
        absorbing: !widget.isEnabled,
        child: Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            final suggestions = widget.list
                .where((element) => element
                    .toString()
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()))
                .map((e) => e.toString());
            if (suggestions.isEmpty &&
                textEditingValue.text.isNotEmpty &&
                FocusScope.of(context).hasFocus) {
              widget.customTextEditingController?.clear();

              setState(() {});

              appToast(widget.appToastMessage ?? "");
              // WidgetsBinding.instance.addPostFrameCallback((_) {
              //   appToast(widget.appToastMessage ?? "No Data Found");
              // });
            }

            return suggestions;
          },
          onSelected: widget.onSelected,
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            textEditingController.text =
                widget.customTextEditingController?.text ?? "";
            return TextFormField(
              style: AppStyle.txt14FoodValue,
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                fillColor: widget.fillColor,
                filled: widget.filled,
                hintText: widget.hintText,
                hintStyle: AppStyle.txt14FoodValue
                    .copyWith(color: ColorTheme.foodValue.withOpacity(.7)),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                border: border,
                enabledBorder: border,
                focusedBorder: border,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return widget.validatorText;
                }
                return null;
              },
            );
          },
          optionsViewBuilder: (
            BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 150, minWidth: 175),
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorTheme.whiteColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ColorTheme.whiteDC),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(option, style: AppStyle.txt14FoodValue),
                          ),
                          onTap: () {
                            onSelected(option);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(color: ColorTheme.whiteDC),
  );
}
