import 'dart:math' as math;

import 'package:flutter/material.dart';

Future<T?> showAggregatorStockPopover<T>({
  required BuildContext buttonContext,
  required Widget child,
}) {
  final renderBox = buttonContext.findRenderObject();
  if (renderBox is! RenderBox || !renderBox.hasSize) return Future.value();

  final overlay = Overlay.of(buttonContext).context.findRenderObject();
  if (overlay is! RenderBox) return Future.value();

  final offset = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
  final buttonRect = offset & renderBox.size;

  return showDialog<T>(
    context: buttonContext,
    barrierColor: Colors.black.withOpacity(0.12),
    barrierDismissible: true,
    builder: (dialogContext) {
      return CustomSingleChildLayout(
        delegate: _AggregatorStockPopoverDelegate(
          buttonRect: buttonRect,
          overlaySize: overlay.size,
        ),
        child: Material(
          color: Colors.transparent,
          child: child,
        ),
      );
    },
  );
}

class _AggregatorStockPopoverDelegate extends SingleChildLayoutDelegate {
  final Rect buttonRect;
  final Size overlaySize;

  static const double _gap = 6;
  static const double _margin = 8;

  _AggregatorStockPopoverDelegate({
    required this.buttonRect,
    required this.overlaySize,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final maxBelow =
        overlaySize.height - buttonRect.bottom - _gap - _margin;
    final maxAbove = buttonRect.top - _gap - _margin;
    final maxHeight = math.max(maxBelow, maxAbove).clamp(
          80.0,
          overlaySize.height - (2 * _margin),
        );

    return BoxConstraints(
      maxWidth: math.min(320, overlaySize.width - (2 * _margin)),
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final spaceBelow = overlaySize.height - buttonRect.bottom - _margin;
    final openDownward = spaceBelow >= childSize.height + _gap;

    double top;
    if (openDownward) {
      top = buttonRect.bottom + _gap;
    } else {
      top = buttonRect.top - childSize.height - _gap;
    }

    final maxTop = overlaySize.height - childSize.height - _margin;
    top = top.clamp(_margin, math.max(_margin, maxTop));

    double left = buttonRect.left;
    if (left + childSize.width > overlaySize.width - _margin) {
      left = buttonRect.right - childSize.width;
    }
    final maxLeft = overlaySize.width - childSize.width - _margin;
    left = left.clamp(_margin, math.max(_margin, maxLeft));

    return Offset(left, top);
  }

  @override
  bool shouldRelayout(covariant _AggregatorStockPopoverDelegate oldDelegate) {
    return buttonRect != oldDelegate.buttonRect ||
        overlaySize != oldDelegate.overlaySize;
  }
}
